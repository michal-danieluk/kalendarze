class Order < ApplicationRecord
  belongs_to :confirmed_by, class_name: 'User', optional: true
  belongs_to :user, optional: true

  has_many :order_items, dependent: :destroy
  has_many :calendars, through: :order_items

  validates :status, presence: true, inclusion: { in: %w[pending sent_for_approval confirmed rejected] }

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
  scope :sent_for_approval, -> { where(status: 'sent_for_approval') }
  scope :confirmed, -> { where(status: 'confirmed') }
  scope :rejected, -> { where(status: 'rejected') }

  # Callbacks
  after_create :send_manager_approval_email, if: :should_send_manager_email?

  def confirm(supervisor)
    update(status: 'confirmed', confirmed_by: supervisor, confirmed_at: Time.current)
  end

  def reject(supervisor)
    update(status: 'rejected', confirmed_by: supervisor, confirmed_at: Time.current)
  end

  def mark_as_sent_for_approval
    update(status: 'sent_for_approval') if status == 'pending'
  end

  def send_manager_approval_email
    # Send email to manager for approval
    OrderMailer.manager_approval_request(self).deliver_later
    mark_as_sent_for_approval
  end

  def send_manager_approval_email!
    # Send email immediately (for manual triggers)
    OrderMailer.manager_approval_request(self).deliver_now
    mark_as_sent_for_approval
  end

  def should_send_manager_email?
    # By default, automatically send approval emails
    # This can be customized based on business rules
    true
  end
  
  def total_quantity
    order_items.sum(:quantity)
  end
  
  def total_price
    order_items.sum { |item| item.subtotal }
  end
  
  def manager_name
    if manager_first_name.present? && manager_last_name.present?
      "#{manager_first_name} #{manager_last_name}"
    elsif manager_first_name.present?
      manager_first_name
    elsif manager_last_name.present?
      manager_last_name
    else
      # Try to find a user with this email
      user = User.find_by(email: manager_email)
      user&.name
    end
  end
  
  def manager_full_name
    if manager_name.present?
      manager_name
    else
      manager_email
    end
  end
  
  def manager_display_name
    if manager_name.present?
      "#{manager_name} (#{manager_email})"
    else
      manager_email
    end
  end
end