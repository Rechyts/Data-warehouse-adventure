-- /*Insert default values -1 in all tables except fact table*/
INSERT INTO bl_dm.dim_products
(product_surr_id, product_id, product_name, product_number, product_subcategory_id, product_subcategory_name, product_category_id, product_category_name, product_color_id, product_color_name, source_system, source_entity)
VALUES (-1, '-1', 'NA', 'NA', '-1', 'NA', '-1', 'NA',  '-1', 'NA', 'MANUAL', 'MANUAL')
ON CONFLICT DO NOTHING;

COMMIT;