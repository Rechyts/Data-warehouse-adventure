-- /*Insert default values -1 in all tables except fact table*/
INSERT INTO bl_dm.dim_models
(model_surr_id, model_id, model_name, model_desc, insert_dt, source_system, source_entity)
VALUES (-1, '-1', 'NA', 'NA', now(), 'MANUAL', 'MANUAL')
ON CONFLICT DO NOTHING;

COMMIT;