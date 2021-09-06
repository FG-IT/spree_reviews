Deface::Override.new(
    virtual_path: 'spree/admin/shared/_product_tabs',
    name: 'reviews_to_admin_product_tab',
    insert_bottom: '[data-hook="admin_product_tabs"]',
    partial: 'spree/admin/shared/reviews_product_sidebar_menu'
)
