class UsersController < ApplicationController
  def purchase_history
    if current_user
      @purchases = current_user.purchases
                               .order(created_at: :desc)
    else
      redirect_to root_path, alert: "You must be signed in to view purchase history."
    end
  end
end
