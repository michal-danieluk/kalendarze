class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :calendar
  
  validates :quantity, presence: true, numericality: { greater_than: 0, only_integer: true }
  
  def subtotal
    quantity * calendar.price
  end
end
