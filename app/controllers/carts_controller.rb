class CartsController < ApplicationController
  before_action :set_product, only: [:create, :destroy]
   def create
    if !@current_cart
      @current_cart = Cart.create
      session[:current_cart_id] = @current_cart.secret_id
    end
    @current_cart.cart_items.create(product_id: @product.id)
  end

  def show
  end

  def checkout
    if !@current_cart&.cart_items&.any?
      redirect_to root_path, notice: "You don't have any items in cart yet!"
    end
  end

  def destroy
    @cart_item = @current_cart.cart_items.find_by_product_id(@product.id)
    @cart_item.destroy
    redirect_to cart_path(@current_cart)
  end

  def stripe_session
    session = Stripe::Checkout::Session.create({
      ui_mode: 'embedded',
      line_items: [{
          # Provide the exact Price ID (e.g. pr_1234) of the product you want to sell
          price_data: {
            currency: "usd",
            unit_amount: (@current_cart.products.sum(&:price) * 100).to_i,
            product_data: {
              name: @current_cart.products.map(&:name).join(", ")
            },
          },
          quantity: 1,
        }],
        shipping_address_collection: {
          allowed_countries: STRIPE_SUPPORTED_COUNTRIES
        },
        metadata: {
          user_id: current_user&.id,
          purchase_type: 'cart',
          cart_id: @current_cart.id
        },
        mode: 'payment',
        return_url: success_cart_url + "?id=#{@current_cart.secret_id}",
    })

    render json: { clientSecret: session.client_secret }
  end

  def success
    @purchased_cart = Cart.find_by(secret_id: params[:id])
    if @purchased_cart
      @purchased_cart.cart_items.destroy_all
      session[:current_cart_id] = nil
      respond_to do |format|
        format.turbo_stream
        format.html { render :success } # fallback if Turbo not used
      end
    else
      redirect_to root_path, alert: "Cart not found."
    end
  end


  private

  def set_product
    @product = Product.find(params[:product_id])
  end
end


