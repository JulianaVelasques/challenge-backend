class CartsController < ApplicationController
  before_action :set_cart, only: [:show, :destroy, :decrease_quantity]

  # GET /cart
  def show
    render json: cart_response(@cart)
  end

  # POST /cart - Create cart when adding a Product (do not update the item already in the cart, for that call '/add_item')
  def create
    add_or_update_item(params[:product_id], params[:quantity].to_i, replace_quantity: true)
  end

  # POST /cart/add_item - Only add to a existent product in the cart
  def add_item
    add_or_update_item(params[:product_id], params[:quantity].to_i, replace_quantity: false)
  end

  # DELETE /cart/:id
  def destroy
    cart_item = @cart.cart_items.find_by(product_id: params[:id])
    return render json: { error: "Product not found in cart" }, status: :not_found unless cart_item

    cart_item.destroy

    update_total_price!
    
    if @cart.cart_items.empty?
      @cart.destroy
      session[:cart_id] = nil
      return render json: { message: "Cart is now empty and has been deleted" }, status: :ok
    end

    render json: cart_response(@cart), status: :ok
  end

  # PATCH /cart/:product_id/decrease_quantity - Do not delete cart_item, only decrease its quantity in the cart
  def decrease_quantity
    cart_item = @cart.cart_items.find_by(product_id: params[:id])
    return render json: { error: "Product not found in cart" }, status: :not_found unless cart_item

    if cart_item.quantity > 1
      cart_item.update(quantity: cart_item.quantity - 1)
      update_total_price!
      render json: cart_response(@cart), status: :ok
    else
      render json: { error: "Quantity is already at minimum. Use DELETE to remove." }, status: :unprocessable_entity
    end
  end

  private
    def set_cart
      @cart = Cart.find_by(id: session[:cart_id])
      return render json: { error: "Cart not found" }, status: :not_found unless @cart
    end

    def add_or_update_item(product_id, quantity, replace_quantity:)
      @cart = Cart.find_by(id: session[:cart_id]) || Cart.create!(total_price: 0)
      session[:cart_id] ||= @cart.id
    
      product = Product.find_by(id: product_id)
      return render json: { error: "Product not found" }, status: :not_found unless product
    
      cart_item = @cart.cart_items.find_by(product_id: product.id)

      if cart_item
        new_quantity = replace_quantity ? quantity : cart_item.quantity + quantity
        cart_item.update(quantity: new_quantity)
      else
        new_item = @cart.cart_items.create!(product: product, quantity: quantity)
      end
    
      update_total_price!

      render json: cart_response(@cart), status: :ok
    end

    def update_total_price!
      total_price = @cart.cart_items.sum { |item| item.quantity * item.product.price }
      @cart.update(total_price: total_price)
    end

    def cart_response(cart)
      {
        id: cart.id,
        products: cart.cart_items.map do |item|
          {
            id: item.product.id,
            name: item.product.name,
            quantity: item.quantity,
            unit_price: item.product.price,
            total_price: item.quantity * item.product.price
          }
        end,
        total_price: cart.total_price
      }
    end
end