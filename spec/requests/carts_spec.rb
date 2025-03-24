require 'rails_helper'

RSpec.describe "/carts", type: :request do
  def json_response
    JSON.parse(response.body || '{}')
  end

  describe "GET /cart" do
    let(:cart) { create(:cart) }
    before do
      allow_any_instance_of(ApplicationController).to receive(:session).and_return({ cart_id: cart.id })
    end

    context "when the cart has products" do
      let!(:cart_item) { create(:cart_item, cart: cart) }
      it "returns the cart items" do
        get "/cart", as: :json

        expect(response).to have_http_status(:ok)
        expect(json_response["products"].size).to eq(1)
      end
    end

    context "when the cart is empty" do
      it "returns an empty cart" do
        get "/cart", as: :json

        expect(response).to have_http_status(:ok)
        expect(json_response["products"]).to be_empty
      end
    end
  end

  describe "POST /cart" do
    let!(:product) { create(:product) }
    let(:cart) { create(:cart) }
  
    context "when creating a new cart by adding a product" do
      before do
        allow_any_instance_of(ApplicationController).to receive(:session).and_return({})
      end

      it "creates a new cart and adds the product" do
        post "/cart", params: { product_id: product.id, quantity: 1 }, as: :json
  
        expect(response).to have_http_status(:created)
        expect(json_response["products"].size).to eq(1)
        expect(json_response["products"].first["id"]).to eq(product.id)
      end
    end
  
    context "when product_id is invalid" do
      it "returns an error" do
        post "/cart", params: { product_id: nil, quantity: 1 }, as: :json
  
        expect(response).to have_http_status(:not_found)
        expect(json_response["error"]).to be_present
      end
    end
  
    context "when a cart already exists" do
      before do
        post "/cart", params: { product_id: product.id, quantity: 1 }, as: :json
      end

      it "returns an error when trying to create another cart" do
        post "/cart", params: { product_id: product.id, quantity: 1 }, as: :json
    
        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response["error"]).to eq("A cart already exists. Use /cart/add_item to add products.")
      end
    end
  end  

  describe "DELETE /cart/:id" do
    let(:cart) { create(:cart) }
    let(:cart_item) { create(:cart_item, cart: cart) }
    before do
      allow_any_instance_of(ApplicationController).to receive(:session).and_return({ cart_id: cart.id })
    end

    it "removes the item from the cart" do
      delete "/cart/#{cart_item.product.id}", as: :json

      expect(response).to have_http_status(:ok)
      expect(cart.cart_items.exists?(cart_item.id)).to be_falsey
    end

    it "deletes the cart when the last item is removed" do
      delete "/cart/#{cart_item.product.id}", as: :json
  
      expect(response).to have_http_status(:ok)
      expect(Cart.exists?(cart.id)).to be_falsey
      expect(json_response["message"]).to eq("Cart is now empty and has been deleted")
      expect(session[:cart_id]).to be_nil
    end
  end

  describe "PATCH /cart/:product_id/decrease_quantity" do
    let(:cart) { create(:cart) }
    let(:cart_item) { create(:cart_item, cart: cart, quantity: 2) }
    before do
      allow_any_instance_of(ApplicationController).to receive(:session).and_return({ cart_id: cart.id })
    end

    it "decreases the quantity of a product in the cart" do
      patch "/cart/#{cart_item.product.id}/decrease_quantity", as: :json

      expect(response).to have_http_status(:ok)
      expect(json_response["products"].first["quantity"]).to eq(1)
    end

    it "returns an error if trying to decrease below 1" do
      cart_item.update(quantity: 1)
      patch "/cart/#{cart_item.product.id}/decrease_quantity", as: :json

      expect(response).to have_http_status(:unprocessable_entity)
      expect(json_response["error"]).to be_present
    end
  end

  describe "POST /add_item" do
    let(:cart) { create(:cart) }
    let(:product) { create(:product) }
    let!(:cart_item) { create(:cart_item, cart: cart, product: product) }

    context 'when the product already is in the cart' do
      before do
        allow_any_instance_of(ApplicationController).to receive(:session).and_return({ cart_id: cart.id })
      end

      subject do
        post '/cart/add_item', params: { product_id: product.id, quantity: 1 }, as: :json
        post '/cart/add_item', params: { product_id: product.id, quantity: 1 }, as: :json
      end

      it 'updates the quantity of the existing item in the cart' do
        expect { subject }.to change { cart_item.reload.quantity }.by(2)
      end
    end

    context "when adding a new product to an existing cart" do
      before do
        allow_any_instance_of(ApplicationController).to receive(:session).and_return({ cart_id: cart.id })
      end
  
      it "adds the product to the cart" do
        post "/cart/add_item", params: { product_id: product.id, quantity: 1 }, as: :json
  
        expect(response).to have_http_status(:ok)
        expect(cart.cart_items.count).to eq(1)
        expect(cart.cart_items.first.product_id).to eq(product.id)
      end
    end
  end
end
