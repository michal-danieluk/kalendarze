class Order < ApplicationRecord
  belongs_to :confirmed_by, class_name: 'User', optional: true
  
  has_many :order_items, dependent: :destroy
  has_many :calendars, through: :order_items
  
  validates :status, presence: true, inclusion: { in: %w[pending confirmed rejected] }
  
  # Validate required fields for all orders
  validates :customer_email, presence: true
  validates :mpk_number, presence: true
  validates :manager_email, presence: true
  
  # Validate address fields
  validates :street, presence: true
  validates :house_number, presence: true
  validates :postal_code, presence: true
  validates :city, presence: true
  validates :phone_number, presence: true
  
  accepts_nested_attributes_for :order_items, reject_if: proc { |attributes| attributes['quantity'].to_i <= 0 }
  
  scope :pending, -> { where(status: 'pending') }
  scope :confirmed, -> { where(status: 'confirmed') }
  scope :rejected, -> { where(status: 'rejected') }
  
  def confirm(supervisor)
    update(status: 'confirmed', confirmed_by: supervisor, confirmed_at: Time.current)
  end
  
  def reject(supervisor)
    update(status: 'rejected', confirmed_by: supervisor, confirmed_at: Time.current)
  end
  
  def total_quantity
    order_items.sum(:quantity)
  end
  
  def total_price
    order_items.sum { |item| item.subtotal }
  end
end