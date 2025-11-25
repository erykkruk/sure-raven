module Accountable
  extend ActiveSupport::Concern

  TYPES = %w[Depository Investment Crypto Property Vehicle OtherAsset CreditCard Loan OtherLiability]

  # Define empty hash to ensure all accountables have this defined
  SUBTYPES = {}.freeze

  def self.from_type(type)
    return nil unless TYPES.include?(type)
    type.constantize
  end

  included do
    include Enrichable

    has_one :account, as: :accountable, touch: true
  end

  class_methods do
    def classification
      raise NotImplementedError, "Accountable must implement #classification"
    end

    def icon
      raise NotImplementedError, "Accountable must implement #icon"
    end

    def color
      raise NotImplementedError, "Accountable must implement #color"
    end

    # Given a subtype, look up the label for this accountable type
    def subtype_label_for(subtype, format: :short)
      return nil if subtype.nil?

      label_type = format == :long ? :long : :short
      self::SUBTYPES[subtype]&.fetch(label_type, nil)
    end

    # Convenience method for getting the short label
    def short_subtype_label_for(subtype)
      subtype_label_for(subtype, format: :short)
    end

    # Convenience method for getting the long label
    def long_subtype_label_for(subtype)
      subtype_label_for(subtype, format: :long)
    end

    def favorable_direction
      classification == "asset" ? "up" : "down"
    end

    def display_name
      self.name.pluralize.titleize
    end

    def balance_money(family)
      total = BigDecimal(0)
      
      family.accounts.active.where(accountable_type: self.name).find_each do |account|
        if account.currency == family.currency
          total += account.balance
        else
          # Use ExchangeRate.find_or_fetch_rate which supports USD triangulation
          rate = ExchangeRate.find_or_fetch_rate(
            from: account.currency,
            to: family.currency,
            date: Date.current
          )
          
          if rate
            total += account.balance * rate.rate
          else
            Rails.logger.warn "Could not find exchange rate from #{account.currency} to #{family.currency} for account #{account.id}"
            total += account.balance  # Fallback to unconverted balance
          end
        end
      end
      
      total
    end
  end

  def display_name
    self.class.display_name
  end

  def balance_display_name
    "account value"
  end

  def opening_balance_display_name
    "opening balance"
  end

  def icon
    self.class.icon
  end

  def color
    self.class.color
  end

  def classification
    self.class.classification
  end
end
