class Transfer::Creator
  def initialize(family:, source_account_id:, destination_account_id:, date:, amount: nil, amount_from: nil, amount_to: nil, same_currency: true)
    @family = family
    @source_account = family.accounts.find(source_account_id) # early throw if not found
    @destination_account = family.accounts.find(destination_account_id) # early throw if not found
    @date = date
    @same_currency = same_currency

    # Handle both old and new parameter formats
    if amount_from.present?
      @amount_from = amount_from.to_d
      @amount_to = same_currency ? amount_from.to_d : amount_to.to_d
    elsif amount.present?
      # Legacy support - amount parameter
      @amount_from = amount.to_d
      @amount_to = @amount_from
    end
  end

  def create
    transfer = Transfer.new(
      inflow_transaction: inflow_transaction,
      outflow_transaction: outflow_transaction,
      status: "confirmed",
      amount_from: @amount_from,
      amount_to: @amount_to,
      currency_from: source_account.currency,
      currency_to: destination_account.currency,
      same_currency: @same_currency
    )

    if transfer.save
      source_account.sync_later
      destination_account.sync_later
    end

    transfer
  end

  private
    attr_reader :family, :source_account, :destination_account, :date, :amount_from, :amount_to, :same_currency

    def outflow_transaction
      name = "#{name_prefix} to #{destination_account.name}"

      Transaction.new(
        kind: outflow_transaction_kind,
        entry: source_account.entries.build(
          amount: @amount_from.abs,
          currency: source_account.currency,
          date: date,
          name: name,
        )
      )
    end

    def inflow_transaction
      name = "#{name_prefix} from #{source_account.name}"

      # Use the specific amount_to for multi-currency transfers
      inflow_amount = @same_currency ? @amount_from.abs : @amount_to.abs

      Transaction.new(
        kind: "funds_movement",
        entry: destination_account.entries.build(
          amount: inflow_amount * -1,
          currency: destination_account.currency,
          date: date,
          name: name,
        )
      )
    end

    # The "expense" side of a transfer is treated different in analytics based on where it goes.
    def outflow_transaction_kind
      if destination_account.loan?
        "loan_payment"
      elsif destination_account.liability?
        "cc_payment"
      else
        "funds_movement"
      end
    end

    def name_prefix
      if destination_account.liability?
        "Payment"
      else
        "Transfer"
      end
    end
end
