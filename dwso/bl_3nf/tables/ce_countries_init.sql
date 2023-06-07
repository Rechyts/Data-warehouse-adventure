/*Insert default values -1 in all tables except sales*/
INSERT INTO bl_3nf.ce_countries
(country_id, source_id, country_name, country_code, region_id, source_system, source_entity, insert_dt)
VALUES (-1, 'NA', 'NA', 'NA', -1, 'MANUAL', 'MANUAL', now())
ON CONFLICT DO NOTHING;

COMMIT;