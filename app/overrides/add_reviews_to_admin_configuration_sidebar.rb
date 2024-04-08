if ::Spree.version.to_f < 4.7
  Deface::Override.new(
    virtual_path: 'spree/admin/shared/sub_menu/_configuration',
    name: 'converted_admin_configurations_menu',
    insert_bottom: '[data-hook="admin_configurations_sidebar_menu"]',
    partial: 'spree/shared/reviews_sidebar_menu'
  )
end
