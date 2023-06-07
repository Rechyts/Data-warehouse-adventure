/*Insert default values -1 in all tables except sales*/
INSERT INTO bl_3nf.ce_products  
(product_id, source_id, product_name, product_number, color_id, subcategory_id, source_system, source_entity, insert_dt)
VALUES (-1, 'NA', 'NA', 'NA', -1, -1, 'MANUAL', 'MANUAL', now())
ON CONFLICT DO NOTHING;

COMMIT;