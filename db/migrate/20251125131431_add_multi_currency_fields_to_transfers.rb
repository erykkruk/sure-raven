class AddMultiCurrencyFieldsToTransfers < ActiveRecord::Migration[7.2]
  def change
    add_column :transfers, :amount_from, :decimal, precision: 19, scale: 4
    add_column :transfers, :amount_to, :decimal, precision: 19, scale: 4
    add_column :transfers, :currency_from, :string
    add_column :transfers, :currency_to, :string
    add_column :transfers, :same_currency, :boolean, default: true, null: false
    
    # Add indexes for currency fields
    add_index :transfers, :currency_from
    add_index :transfers, :currency_to
    add_index :transfers, :same_currency
  end
end
