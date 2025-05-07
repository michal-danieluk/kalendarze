class AddAddressFieldsToOrders < ActiveRecord::Migration[8.0]
  def change
    add_column :orders, :street, :string
    add_column :orders, :house_number, :string
    add_column :orders, :postal_code, :string
    add_column :orders, :city, :string
    add_column :orders, :phone_number, :string
    add_column :orders, :delivery_notes, :text
  end
end
