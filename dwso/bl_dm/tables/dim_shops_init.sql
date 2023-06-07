-- /*Insert default values -1 in all tables except fact table*/
--FIXED: geo attributes are placed in a separate dimension table dim_addresses 
INSERT INTO bl_dm.dim_shops
(shop_surr_id, shop_id, shop_name, insert_dt, source_system, source_entity)
VALUES (-1, '-1', 'NA', now(), 'MANUAL', 'MANUAL')
ON CONFLICT DO NOTHING;

COMMIT;