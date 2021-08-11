object false
child(@reviews => :reviews) do
  attributes :rating, :title, :review, :name, :show_identifier, :images, :verified_purchase
end
node(:count) { @reviews.count }
node(:current_page) { params[:page].try(:to_i) || 1 }
node(:pages) { @reviews.total_pages }
