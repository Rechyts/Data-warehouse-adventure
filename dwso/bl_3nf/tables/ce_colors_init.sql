/*Insert default values -1 in all tables except sales*/
INSERT INTO bl_3nf.ce_colors  
(color_id, source_id, color_name, source_system, source_entity, insert_dt)
VALUES (-1, 'NA', 'NA', 'MANUAL', 'MANUAL', now())
ON CONFLICT DO NOTHING;

COMMIT;