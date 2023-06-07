/*Insert default values -1 in all tables except sales*/
INSERT INTO bl_3nf.ce_models  
(model_id, source_id, model_name, model_desc, source_system, source_entity, insert_dt)
VALUES (-1, 'NA', 'NA', 'NA', 'MANUAL', 'MANUAL', now())
ON CONFLICT DO NOTHING;

COMMIT;