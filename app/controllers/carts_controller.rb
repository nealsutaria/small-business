class CartsController < ApplicationController
  before_action :set_product, only: [:create]
   def create
    @current_cart.cart_items.create(product_id: @product.id)
  end

  private

  def set_product
    @product = Product.find(params[:product_id])
  end

end


