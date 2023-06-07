CREATE OR REPLACE PROCEDURE bl_cl.load_shops_dim()
 LANGUAGE plpgsql
AS $$
DECLARE
	log_msg TEXT;
	_var type_for_log_table;
BEGIN
	WITH insert_rows AS (	
		INSERT INTO bl_dm.dim_shops AS dc
		(shop_id, shop_name, source_system, source_entity, insert_dt)
		SELECT CAST(c.shop_id AS varchar) AS  shop_id, c.shop_name , c.source_system , c.source_entity, now() AS insert_dt 
		FROM bl_3nf.ce_shops c
		WHERE c.shop_id <> -1
		ON CONFLICT(shop_id, source_system, source_entity) DO UPDATE 
		SET (shop_id, shop_name, update_dt) =
		ROW (excluded.shop_id, excluded.shop_name, now())
		WHERE md5(CONCAT(dc.shop_id, dc.shop_name)) 
		IS DISTINCT FROM md5(CONCAT(excluded.shop_id, excluded.shop_name))
		RETURNING shop_surr_id
	)
	SELECT array_agg(shop_surr_id), count(*) INTO _var
	FROM insert_rows;

	--GET DIAGNOSTICS affect_rows = row_count;
	CALL bl_cl.load_log_data('bl_dm', 'dim_shops', 'success', 'Successfuly insert into dim_shops table', _var.affect_rows, _var.updated_ids);
	EXCEPTION
	WHEN OTHERS THEN
		GET STACKED DIAGNOSTICS
			log_msg = message_text;
		CALL bl_cl.load_log_data('bl_dm', 'dim_shops', 'error', log_msg, 0, NULL);
	RAISE NOTICE 'some other error: %', sqlerrm;
COMMIT;

END;$$
;
