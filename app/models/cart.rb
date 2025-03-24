class Cart < ApplicationRecord
  validates_numericality_of :total_price, greater_than_or_equal_to: 0

  # A cart can have multiple cartItem, if a cart is destroyed, then all the cartItem in this cart should be too
  has_many :cart_items, dependent: :destroy
  has_many :products, through: :cart_items

  scope :inactive_for, ->(time) { where("last_interaction_at <= ?", time) }
  
  def mark_as_abandoned
    update(abandoned: true) if last_interaction_at <= 3.hours.ago
  end

  def remove_if_abandoned
    destroy if last_interaction_at <= 7.days.ago
  end
end
