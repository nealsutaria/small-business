class CartsController < ApplicationController
  before_action :set_product, only: [:create, :destroy]

  def create
    size = params[:size]
    color = params[:color]

    cart_item = @current_cart.cart_items.find_by(product_id: params[:product_id], size: size, color: color)

    if cart_item
      cart_item.increment!(:quantity)
    else
      @current_cart.cart_items.create(product_id: params[:product_id], size: size, color: color, quantity: 1)
    end

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to cart_path(@current_cart) }
    end
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
      line_items: @current_cart.cart_items.map do |item|
        {
          price_data: {
            currency: "usd",
            unit_amount: (item.product.price * 100).to_i,
            product_data: {
              name: item.product.name,
              description: "Color: #{item.color}, Size: #{item.size}"
            },
          },
          quantity: item.quantity
        }
      end,
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

  def remove_one_cart_item
    size = params[:size]
    color = params[:color]

    item = @current_cart.cart_items.find_by(product_id: params[:product_id], size: size, color: color)

    if item
      if item.quantity > 1
        item.decrement!(:quantity)
      else
        item.destroy
      end
    end

    dom_id = "cart_item_#{params[:product_id]}_#{size}_#{color}".parameterize

    respond_to do |format|
      format.turbo_stream do
        if @current_cart.cart_items.exists?(product_id: params[:product_id], size: size, color: color)
          updated_item = @current_cart.cart_items.find_by(product_id: params[:product_id], size: size, color: color)

          render turbo_stream: [
            turbo_stream.replace(dom_id, partial: "carts/cart_item", locals: { cart_item: updated_item, cart: @current_cart }),
            turbo_stream.update("cart", partial: "layouts/cart", locals: { cart: @current_cart }),
            turbo_stream.update("cart-summary", partial: "carts/cart_summary", locals: { cart: @current_cart })
          ]
        else
          render turbo_stream: [
            turbo_stream.remove(dom_id),
            turbo_stream.update("cart", partial: "layouts/cart", locals: { cart: @current_cart }),
            turbo_stream.update("cart-summary", partial: "carts/cart_summary", locals: { cart: @current_cart })
          ]
        end
      end
    end
  end



  def remove_all_cart_item
    size = params[:size]
    color = params[:color]

    @current_cart.cart_items.where(product_id: params[:product_id], size: size, color: color).destroy_all
    dom_id = "cart_item_#{params[:product_id]}_#{size}_#{color}".parameterize

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.remove(dom_id),
          turbo_stream.update("cart", partial: "layouts/cart", locals: { cart: @current_cart }),
          turbo_stream.update("cart-summary", partial: "carts/cart_summary", locals: { cart: @current_cart })
        ]
      end
    end
  end




  private

  def set_product
    @product = Product.find(params[:product_id])
  end
end


