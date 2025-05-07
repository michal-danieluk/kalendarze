class PopulateAddressFieldsForExistingOrders < ActiveRecord::Migration[8.0]
  def up
    # Set default values for all existing orders
    execute <<-SQL
      UPDATE orders 
      SET 
        street = 'Wprowadzono przed zmianą', 
        house_number = 'N/A', 
        postal_code = '00-000', 
        city = 'Brak danych', 
        phone_number = 'Brak danych',
        delivery_notes = delivery_address
      WHERE 
        street IS NULL 
        OR house_number IS NULL 
        OR postal_code IS NULL 
        OR city IS NULL 
        OR phone_number IS NULL;
    SQL
  end

  def down
    # No need to do anything in the down migration
  end
end
