module Spree::Admin::ProductsControllerDecorator
  def self.prepended(base)
    base.helper Spree::ReviewsHelper
  end

  def reviews
    load_resource
    params[:q] ||= {}
    @search = Spree::Review.where(product: @product).ransack(params[:q])
    @reviews = @search.result.includes([:user, :feedback_reviews]).page(params[:page]).per(params[:per_page]).order(created_at: :desc)
    # @reviews = Spree::Review.where(product: @product)
    #                .includes([:user, :feedback_reviews])
    #                .page(params[:page]).per(params[:per_page]).order(created_at: :desc)
  end
end

Spree::Admin::ProductsController.prepend(Spree::Admin::ProductsControllerDecorator)
