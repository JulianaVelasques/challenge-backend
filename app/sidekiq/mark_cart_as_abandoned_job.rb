class MarkCartAsAbandonedJob
  include Sidekiq::Job

  def perform
    # Mark carts as abandoned if inactive for at least 3 hours
    Cart.inactive_for(3.hours).where(abandoned: false).find_each(&:mark_as_abandoned)

    # Remove carts abandoned for more than 7 days
    Cart.inactive_for(7.days).where(abandoned: true).find_each(&:remove_if_abandoned)
  end
end
