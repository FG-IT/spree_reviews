Deface::Override.new(
  virtual_path: 'spree/layouts/spree_application',
  name: 'add_rating_filter_js',
  insert_bottom: "[data-hook='inside_head']",
  text: "<%=  javascript_include_tag('spree/backend/spree_reviews.js', defer: 'defer' )%>"
)