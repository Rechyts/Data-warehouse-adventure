/*Insert default values -1 in all tables except sales*/
INSERT INTO bl_3nf.ce_states
(state_id, source_id, state_name, state_code, country_id, source_system, source_entity, insert_dt)
VALUES (-1, 'NA', 'NA', 'NA', -1, 'MANUAL', 'MANUAL', now())
ON CONFLICT DO NOTHING;

COMMIT;