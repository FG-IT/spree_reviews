require "open-uri"
module Spree
  module Api
    module V1
      class ReviewsController < ::Spree::Api::BaseController

        before_action :load_product, only: [:new, :create]

        def index
          @reviews = Spree::Review.approved.ransack(params[:q]).result.order(created_at: :desc).page(params[:page]).per(params[:per_page])
          respond_with(@reviews, status: 200, default_template: :index)
        end

        def create
          @review = Spree::Review.new(review_params)
          @review.product = @product
          @review.user = @current_api_user
          @review.ip_address = request.remote_ip
          @review.locale = I18n.locale.to_s if Spree::Reviews::Config[:track_locale]

          authorize! :create, @review
          if @review.save
            save_images
            respond_with(@review, status: 201, default_template: :show)
          else
            invalid_resource!(@review)
          end
        end


        private

        def load_product
          @product = Spree::Product.friendly.find(params[:product_id])
        end

        def save_images
          if params[:review].key? :images
            params[:review][:images].each do |image|
              url = URI.parse(image)
              filename = File.basename(url.path)
              file = URI.open(image)
              @review.images.attach(io: file, filename: filename, content_type: file.content_type_parse.first)
            end
          end
        end

        def permitted_review_attributes
          [:rating, :title, :review, :name, :show_identifier, :created_at, :images, :helpful_count, :verified_purchase, :approved]
        end

        def review_params
          params.require(:review).permit(permitted_review_attributes)
        end

      end
    end
  end
end
