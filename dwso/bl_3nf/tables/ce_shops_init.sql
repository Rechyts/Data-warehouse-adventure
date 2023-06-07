/*Insert default values -1 in all tables except sales*/
INSERT INTO bl_3nf.ce_shops 
(shop_id, source_id, shop_name, address_id, source_system, source_entity, insert_dt)
VALUES (-1, 'NA', 'NA', -1, 'NA', 'NA', now())
ON CONFLICT DO NOTHING
;

COMMIT;