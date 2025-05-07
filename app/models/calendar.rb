class Calendar < ApplicationRecord
  has_many :order_items
  has_many :orders, through: :order_items
  
  validates :name, presence: true
  validates :year, presence: true, numericality: { only_integer: true }
  validates :calendar_type, presence: true
  validates :price, presence: true, numericality: { greater_than: 0 }
  
  def self.available_types
    ['Ścienny', 'Biurkowy', 'Kieszonkowy', 'Trójdzielny']
  end
end
