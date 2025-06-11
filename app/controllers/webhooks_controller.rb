class WebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token

  def stripe
    payload = request.body.read
    sig_header = request.env['HTTP_STRIPE_SIGNATURE']
    event = nil

    begin
      event = Stripe::Webhook.construct_event(
        payload, sig_header, Rails.application.credentials.dig(:stripe, :webhook_secret)
      )
    rescue JSON::ParserError => e
      render json: { error: "Invalid payload" }, status: 400 and return
    rescue Stripe::SignatureVerificationError => e
      render json: { error: "Invalid signature" }, status: 400 and return
    end

    case event.type
    when "checkout.session.completed"
      handle_successful_checkout(event.data.object)
    end

    render json: { message: "success" }
  end

  private

  def handle_successful_checkout(session)
    metadata = session.metadata
    user = User.find_by(id: metadata["user_id"]) if metadata["user_id"].present?

    case metadata["purchase_type"]
    when "buy_now"
      product = Product.find_by(id: metadata["product_id"])
      return unless product

      Purchase.create!(
        user: user,
        stripe_checkout_id: session.id,
        amount_total: session.amount_total,
        product_names: [product.name]
      )

    when "cart"
      cart = Cart.find_by(id: metadata["cart_id"])
      return unless cart

      Purchase.create!(
        user: user,
        stripe_checkout_id: session.id,
        amount_total: session.amount_total,
        product_names: cart.products.map(&:name)
      )
    end
  end
end
