class CartsController < ApplicationController
  before_action :set_cart, except: :create

  # GET /cart
  def show
    if @cart.nil?
      render json: { error: "No cart found!" }, status: :not_found
    else
      render json: cart_response(@cart)
    end
  end

  # POST /cart
  def create
    # Check if there is a cart associated with the current session
    @cart = Cart.find_by(id: session[:cart_id])
    return render json: { error: "A cart already exists. Use /cart/add_item to add products." }, status: :unprocessable_entity if @cart.present?

    product = Product.find_by(id: params[:product_id])
    return render json: { error: "Product not found" }, status: :not_found unless product

    @cart = Cart.create!(total_price: 0)
    session[:cart_id] = @cart.id

    @cart.cart_items.create!(product: product, quantity: params[:quantity].to_i)

    update_cart_status!
    render json: cart_response(@cart), status: :created
  end

  # POST /cart/add_item 
  def add_item
    product = Product.find_by(id: params[:product_id])
    return render json: { error: "Product not found" }, status: :not_found unless product

    cart_item = @cart.cart_items.find_by(product_id: product.id)

    if cart_item
      cart_item.update!(quantity: cart_item.quantity + params[:quantity].to_i)
    else
      @cart.cart_items.create!(product: product, quantity: params[:quantity].to_i)
    end

    update_cart_status!
    render json: cart_response(@cart), status: :ok
  end

  # DELETE /cart/:id
  def destroy
    cart_item = @cart.cart_items.find_by(product_id: params[:id])
    return render json: { error: "Product not found in cart" }, status: :not_found unless cart_item
  
    cart_item.destroy
    clean_or_update_cart!
  end

  # PATCH /cart/:product_id/decrease_quantity - Do not delete cart_item, only decrease products quantity in the cart
  def decrease_quantity
    cart_item = @cart.cart_items.find_by(product_id: params[:id])
    return render json: { error: "Product not found in cart" }, status: :not_found unless cart_item

    if cart_item.quantity > 1
      cart_item.update(quantity: cart_item.quantity - 1)
      update_cart_status!
      render json: cart_response(@cart), status: :ok
    else
      render json: { error: "Quantity is already at minimum. Use DELETE to remove." }, status: :unprocessable_entity
    end
  end

  private
    def set_cart
      @cart = Cart.find_by(id: session[:cart_id]) 
    end

    def update_cart_status!
      total_price = @cart.cart_items.sum { |item| item.quantity * item.product.price }
      @cart.update(total_price: total_price, last_interaction_at: Time.current)
    end

    def clean_or_update_cart!
      if @cart.cart_items.empty?
        @cart.destroy
        session[:cart_id] = nil
        render json: { message: "Cart is now empty and has been deleted" }, status: :ok
      else
        update_cart_status!
        render json: cart_response(@cart)
      end
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