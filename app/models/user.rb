class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  belongs_to :supervisor, class_name: 'User', optional: true
  has_many :subordinates, class_name: 'User', foreign_key: 'supervisor_id'
  has_many :confirmed_orders, class_name: 'Order', foreign_key: 'confirmed_by_id'
  
  validates :email, presence: true, uniqueness: true
  validates :name, presence: true
  validates :role, presence: true, inclusion: { in: %w[user admin supervisor] }
  validates :department, presence: true
  validates :supervisor, presence: true, if: -> { role == 'user' }
  
  def supervisor?
    role == 'supervisor'
  end
  
  def admin?
    role == 'admin'
  end
end
