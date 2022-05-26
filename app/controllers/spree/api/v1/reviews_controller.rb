require "open-uri"
module Spree
  module Api
    module V1
      class ReviewsController < ::Spree::Api::BaseController

        before_action :load_product, only: [:new, :create]

        def index
          Rails.logger.info params
          @reviews = Spree::Review.approved.ransack(params[:q]).result.order(created_at: :desc).page(params[:page]).per(params[:per_page])
          respond_with(@reviews, status: 200, default_template: :index)
        end

        def create
          review_id = review_params[:review_id]
          if review_id.present?
            @review = Spree::Review.find_by(review_id: review_id)
          else
            @review = nil
          end

          if @review.blank?
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
          else
            respond_with(@review, status: 201, default_template: :show)
          end
        end


        private

        def load_product
          begin
            if params[:product_id].present?
              @product = Spree::Product.friendly.find(params[:product_id])
            elsif params[:sku].present?
              @product = ::Spree::Variant.find_by(sku: params[:sku])&.product
            else
              @product = nil
            end
          rescue ActiveRecord::RecordNotFound
            @product = nil
          end

          not_found unless @product
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
          [:rating, :title, :review, :name, :show_identifier, :created_at, :helpful_count, :verified_purchase, :approved, :review_id]
        end

        def review_params
          params.require(:review).permit(permitted_review_attributes)
        end

      end
    end
  end
end
