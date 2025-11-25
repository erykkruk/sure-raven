class BalanceSheet::AccountTotals
  def initialize(family, sync_status_monitor:)
    @family = family
    @sync_status_monitor = sync_status_monitor
  end

  def asset_accounts
    @asset_accounts ||= account_rows.filter { |t| t.classification == "asset" }
  end

  def liability_accounts
    @liability_accounts ||= account_rows.filter { |t| t.classification == "liability" }
  end

  private
    attr_reader :family, :sync_status_monitor

    AccountRow = Data.define(:account, :converted_balance, :is_syncing) do
      def syncing? = is_syncing

      # Allows Rails path helpers to generate URLs from the wrapper
      def to_param = account.to_param
      delegate_missing_to :account
    end

    def visible_accounts
      @visible_accounts ||= family.accounts.visible.with_attached_logo
    end

    def account_rows
      @account_rows ||= query.map do |account_row|
        AccountRow.new(
          account: account_row,
          converted_balance: account_row.converted_balance,
          is_syncing: sync_status_monitor.account_syncing?(account_row)
        )
      end
    end

    def cache_key
      family.build_cache_key(
        "balance_sheet_account_rows",
        invalidate_on_data_updates: true
      )
    end

    def query
      @query ||= Rails.cache.fetch(cache_key) do
        accounts_with_conversion = visible_accounts.map do |account|
          # Calculate converted balance using ExchangeRate.find_or_fetch_rate
          # which supports USD triangulation
          converted_balance = if account.currency == family.currency
            account.balance
          else
            rate = ExchangeRate.find_or_fetch_rate(
              from: account.currency,
              to: family.currency,
              date: Date.current
            )
            
            if rate
              account.balance * rate.rate
            else
              # Fallback to original balance if no rate found
              Rails.logger.warn "Could not find exchange rate from #{account.currency} to #{family.currency}"
              account.balance
            end
          end
          
          # Add converted_balance as a virtual attribute
          account.define_singleton_method(:converted_balance) { converted_balance }
          account
        end
        
        accounts_with_conversion
      end
    end
end
