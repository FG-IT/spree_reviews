module SpreeReview::Spree::AbilityDecorator
  protected

  def abilities_to_register
    super << Spree::ReviewsAbility
  end
end

Spree::Ability.prepend(SpreeReview::Spree::AbilityDecorator)
