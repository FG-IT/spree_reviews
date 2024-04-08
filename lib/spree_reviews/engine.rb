module SpreeReviews
  class Engine < Rails::Engine
    require 'spree/core'
    isolate_namespace Spree
    engine_name 'spree_reviews'

    config.autoload_paths += %W(#{config.root}/lib)

    initializer 'spree_reviews.environment', before: :load_config_initializers do |_app|
      Config = Configuration.new
    end

    config.after_initialize do
      ::Spree::Reviews::Config = ::Spree::ReviewSetting.new
    end

    initializer "spree_reviews.assets.precompile" do |app|
      app.config.assets.precompile += %w( spree/backend/spree_reviews.js )
    end

    if ::Spree.version.to_f >= 4.7
      config.after_initialize do
        reviews_setting_menu_item = ::Spree::Admin::MainMenu::ItemBuilder.
          new('reviews_setting', ::Spree::Core::Engine.routes.url_helpers.edit_admin_review_settings_path).
          with_label_translation_key('spree_reviews.review_settings').
          with_match_path('/review_settings').
          build
        ::Rails.application.config.spree_backend.main_menu.add_to_section('settings', reviews_setting_menu_item)

        reviews_menu_item = ::Spree::Admin::MainMenu::ItemBuilder.
          new('reviews', ::Spree::Core::Engine.routes.url_helpers.admin_reviews_path).
          with_label_translation_key('reviews').
          with_match_path('/reviews').
          build
        ::Rails.application.config.spree_backend.main_menu.add_to_section('products', reviews_menu_item)
      end
    end

    def self.activate
      cache_klasses = %W(#{config.root}/app/**/*_decorator*.rb)
      Dir.glob(cache_klasses) do |klass|
        Rails.configuration.cache_classes ? require(klass) : load(klass)
      end
      Spree::Ability.register_ability(Spree::ReviewsAbility)
    end

    config.to_prepare(&method(:activate).to_proc)
  end
end
