class AddAnonymousOrderFields < ActiveRecord::Migration[8.0]
  def change
    change_column_null :orders, :user_id, true
    add_column :orders, :customer_email, :string
    add_column :orders, :mpk_number, :string
    add_column :orders, :manager_email, :string
  end
end
