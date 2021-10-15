class Spree::Admin::ProductReviewsController < Spree::Admin::ResourceController
  belongs_to 'spree/product', find_by: :slug
  helper Spree::ReviewsHelper
  skip_before_action :load_resource, only: [:create]

  def index
    @reviews = collection
  end

  def new
    @review = Spree::Review.new(product: @product)
    # @product = product_scope.friendly.find(params[:id])
    authorize! :create, @review
  end

  # save if all ok
  def create
    params[:review][:rating].sub!(/\s*[^0-9]*\z/, '') unless params[:review][:rating].blank?
    @product = Spree::Product.friendly.find(params[:product_id])
    @review = Spree::Review.new(review_params)
    @review.product = @product
    @review.user = spree_current_user if spree_user_signed_in?
    @review.ip_address = request.remote_ip
    @review.locale = I18n.locale.to_s if Spree::Reviews::Config[:track_locale]
    @review.approved = true if spree_current_user&.has_spree_role?('admin')
    authorize! :create, @review
    if @review.save
      @review.images.attach(params[:review][:images])
      flash[:notice] = Spree.t(:review_successfully_submitted)
      redirect_to spree.reviews_admin_product_url(@product)
    else
      render :new
    end
  end


  def approve
    review = Spree::Review.find(params[:id])
    if review.update_attribute(:approved, true)
      flash[:notice] = Spree.t(:info_approve_review)
    else
      flash[:error] = Spree.t(:error_approve_review)
    end
    redirect_to reviews_admin_product_url(@product)
  end

  def edit
    @review = Spree::Review.find(params[:id])
    return if @review.product
    flash[:error] = Spree.t(:error_no_product)
    redirect_to reviews_admin_product_url(@product)
  end

  def model_class
    @model_class ||= Spree::Review
  end

  private

  def collection
    params[:q] ||= {}
    @search = Spree::Review.where(product: @product).ransack(params[:q])
    @collection = @search.result.includes([:product, :user, :feedback_reviews]).page(params[:page]).per(params[:per_page])
  end
  def permitted_review_attributes
    [:rating, :title, :review, :name, :show_identifier]
  end

  def review_params
    params.require(:review).permit(permitted_review_attributes)
  end
end
