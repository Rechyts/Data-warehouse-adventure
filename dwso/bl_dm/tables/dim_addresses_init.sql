-- /*Insert default values -1 in all tables except fact table*/
INSERT INTO bl_dm.dim_addresses
(address_surr_id, address_id, address_line1, address_line2, postal_code, city_id, city_name, state_id, state_name, state_code, country_id, country_name, country_code, region_id, region_name, insert_dt, source_system, source_entity)
VALUES (-1, '-1', 'NA', 'NA', 'NA', '-1', 'NA', '-1', 'NA', 'NA', '-1', 'NA', 'NA', '-1', 'NA', now(), 'MANUAL', 'MANUAL')
ON CONFLICT DO NOTHING;

COMMIT;