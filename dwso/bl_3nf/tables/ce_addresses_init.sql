/*Insert default values -1 in all tables except sales*/
INSERT INTO bl_3nf.ce_addresses
(address_id, source_id, address_line1, address_line2, postal_code, city_id, source_system, source_entity, insert_dt)
VALUES (-1, 'NA', 'NA', 'NA', 'NA', -1, 'MANUAL', 'MANUAL', now())
ON CONFLICT DO NOTHING;

COMMIT;