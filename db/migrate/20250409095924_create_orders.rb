class CreateOrders < ActiveRecord::Migration[8.0]
  def change
    create_table :orders do |t|
      t.references :user, null: false, foreign_key: true
      t.string :status
      t.datetime :confirmed_at
      t.references :confirmed_by, null: true, foreign_key: { to_table: :users }

      t.timestamps
    end
  end
end
