class CartItemsController < ApplicationController
  def update_quantity
    cart_item = CartItem.find(params[:id])
    cart_item.update(quantity: params[:quantity])

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to cart_path }
    end
  end

  def remove_one
    item = @current_cart.cart_items.find_by(product_id: params[:product_id])
    if item
      item.quantity -= 1
      item.quantity > 0 ? item.save : item.destroy
    end

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to cart_path }
    end
  end

  def remove_all
    item = @current_cart.cart_items.find_by(product_id: params[:product_id])
    item&.destroy

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to cart_path }
    end
  end
end
