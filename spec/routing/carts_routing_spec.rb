require "rails_helper"

RSpec.describe CartsController, type: :routing do
  describe 'routes' do
    it 'routes to #show' do
      expect(get: '/cart').to route_to('carts#show')
    end

    it 'routes to #create' do
      expect(post: '/cart').to route_to('carts#create')
    end

    it 'routes to #add_item via POST' do
      expect(post: '/cart/add_item').to route_to('carts#add_item')
    end

    it 'routes to #remove_item via DELETE' do
      expect(delete: '/cart/1').to route_to('carts#destroy', id: '1')
    end

    it 'routes to #decrease_quantity via PATCH' do
      expect(patch: '/cart/1/decrease_quantity').to route_to('carts#decrease_quantity', id: '1')
    end
  end
end 
