class ApplicationController < ActionController::Base
  before_action :set_current_cart

  protected

  def check_admin_priv
    if !current_admin
      redirect_to root_path
    end
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
  end
end
