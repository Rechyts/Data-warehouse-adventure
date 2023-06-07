/*Insert default values -1 in all tables except sales*/
INSERT INTO bl_3nf.ce_cities
(city_id, source_id, city_name, state_id, source_system, source_entity, insert_dt)
VALUES (-1, 'NA', 'NA', -1, 'MANUAL', 'MANUAL', now())
ON CONFLICT DO NOTHING;

COMMIT;