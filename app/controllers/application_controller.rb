class ApplicationController < ActionController::Base
  before_action :set_current_cart

  protected

  def check_admin_priv
    redirect_to root_path unless current_admin
  end

  def after_sign_in_path_for(resource)
    # Only attach if the cart is a guest cart
    if session[:current_cart_id]
      guest_cart = Cart.find_by(secret_id: session[:current_cart_id])

      if guest_cart && guest_cart.user.nil?
        # If the user doesn't already have an open cart, attach guest cart
        if resource.carts.where(purchased_at: nil).none?
          guest_cart.update(user: resource)
        else
          # Optional: Merge guest_cart into user's existing cart
          user_cart = resource.carts.where(purchased_at: nil).last
          guest_cart.cart_items.each do |item|
            existing = user_cart.cart_items.find_by(product_id: item.product_id, size: item.size, color: item.color)
            if existing
              existing.increment!(:quantity, item.quantity)
            else
              user_cart.cart_items.create(
                product_id: item.product_id,
                size: item.size,
                color: item.color,
                quantity: item.quantity
              )
            end
          end
          guest_cart.destroy
          session[:current_cart_id] = user_cart.secret_id
        end
      end
    end

    super
  end

  private

  def set_current_cart
    if session[:current_cart_id]
      cart = Cart.find_by_secret_id(session[:current_cart_id])
      @current_cart = cart if cart && cart.purchased_at.nil?
    end

    if !@current_cart && current_user
      last_cart = current_user.carts.where(purchased_at: nil).last
      if last_cart
        @current_cart = last_cart
        session[:current_cart_id] = last_cart.secret_id
      end
    end

    unless @current_cart
      @current_cart = Cart.create(secret_id: SecureRandom.uuid)
      session[:current_cart_id] = @current_cart.secret_id
    end
  end
end
