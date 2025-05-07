class CreateCalendars < ActiveRecord::Migration[8.0]
  def change
    create_table :calendars do |t|
      t.string :name
      t.text :description
      t.integer :year
      t.string :calendar_type
      t.decimal :price

      t.timestamps
    end
  end
end
