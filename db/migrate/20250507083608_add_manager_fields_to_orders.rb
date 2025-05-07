class AddManagerFieldsToOrders < ActiveRecord::Migration[8.0]
  def change
    add_column :orders, :manager_first_name, :string
    add_column :orders, :manager_last_name, :string
  end
end
