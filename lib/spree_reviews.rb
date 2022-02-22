require 'spree_core'
require 'spree_reviews/engine'
require 'spree_reviews/version'
require 'spree_extension'
require 'sass/rails'
require 'ox'
require 'zip'

module Spree
  module Reviews
    module_function

    def config(*)
      yield(Spree::Reviews::Config)
    end
  end
end
