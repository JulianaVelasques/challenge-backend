require 'rails_helper'
RSpec.describe MarkCartAsAbandonedJob, type: :job do
    describe "#perform" do
    let!(:active_cart) { create(:cart, last_interaction_at: 1.hour.ago, abandoned: false) }
    let!(:inactive_cart) { create(:cart, last_interaction_at: 4.hours.ago, abandoned: false) }
    let!(:abandoned_cart) { create(:cart, last_interaction_at: 8.days.ago, abandoned: true) }

    it "marks inactive carts as abandoned" do
      expect(inactive_cart.abandoned).to be_falsey
      MarkCartAsAbandonedJob.new.perform
      expect(inactive_cart.reload.abandoned).to be_truthy
    end

    it "removes carts abandoned for more than 7 days" do
      expect(Cart.exists?(abandoned_cart.id)).to be_truthy
      MarkCartAsAbandonedJob.new.perform
      expect(Cart.exists?(abandoned_cart.id)).to be_falsey
    end

    it "does not mark active carts as abandoned" do
      MarkCartAsAbandonedJob.new.perform
      expect(active_cart.reload.abandoned).to be_falsey
    end
  end
end
