/*Insert default values -1 in all tables except sales*/
INSERT INTO bl_3nf.ce_subcategories 
(subcategory_id, source_id, subcategory_name, category_id, source_system, source_entity, insert_dt)
VALUES (-1, 'NA', 'NA', -1, 'MANUAL', 'MANUAL', now())
ON CONFLICT DO NOTHING;

COMMIT;