class Spree::ReviewsController < Spree::StoreController
  helper Spree::BaseHelper
  helper Spree::ProductsHelper
  helper Spree::FrontendHelper
  before_action :load_product, only: [:index, :new, :create]
  rescue_from ActiveRecord::RecordNotFound, with: :render_404

  def index
    @approved_reviews = Spree::Review.approved.where(product: @product).page(params[:page]).per(params[:per_page]).order(created_at: :desc)

    if params[:rating] && params[:rating] != ''
      @approved_reviews = @approved_reviews.rating_filter params[:rating]
    end
    if params[:search] && params[:search] != ''
      @approved_reviews = @approved_reviews.where("review LIKE ?", "%#{params[:search]}%")
    end
    if params[:sort]
      case params[:sort]
      when 'rating'
        @approved_reviews = @approved_reviews.highest_rating_first
      when 'created_at'
        @approved_reviews = @approved_reviews.most_recent_first
      when 'top_reviews'
        @approved_reviews = @approved_reviews.most_helpful_first
      when 'has_photo'
        @approved_reviews = @approved_reviews.has_photo
      end
    end

    @rating = params[:rating]
    @sort = params[:sort]
    @search = params[:search]
    if @approved_reviews.any?
      render template: 'spree/reviews/index', layout: false
    else
      head :no_content
    end
  end

  def new
    @review = Spree::Review.new(product: @product)
    authorize! :create, @review
  end

  # save if all ok
  def create
    params[:review][:rating].sub!(/\s*[^0-9]*\z/, '') unless params[:review][:rating].blank?

    @review = Spree::Review.new(review_params)
    @review.product = @product
    @review.user = spree_current_user if spree_user_signed_in?
    @review.ip_address = request.remote_ip
    @review.locale = I18n.locale.to_s if Spree::Reviews::Config[:track_locale]

    authorize! :create, @review
    if @review.save
      @review.images.attach(params[:review][:images])
      flash[:notice] = Spree.t(:review_successfully_submitted)
      redirect_to spree.product_path(@product)
    else
      render :new
    end
  end

  private

  def load_product
    @product = Spree::Product.friendly.find(params[:product_id])
  end

  def permitted_review_attributes
    [:rating, :title, :review, :name, :show_identifier]
  end

  def review_params
    params.require(:review).permit(permitted_review_attributes)
  end
end
