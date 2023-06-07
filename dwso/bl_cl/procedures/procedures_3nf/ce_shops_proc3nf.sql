-- Fill shops table with data. Only offline sales contain data about shops
--FIXED: add default values for varchar and integer data, previously it was only FK id.

CREATE OR REPLACE PROCEDURE bl_cl.load_shops_3nf()
LANGUAGE plpgsql
AS $$
DECLARE
	--affect_rows integer;
	log_msg TEXT;
	_var type_for_log_table;
BEGIN
	WITH insert_rows AS (
		INSERT INTO bl_3nf.ce_shops AS s
		(source_id, shop_name, address_id, source_system , source_entity, insert_dt)
		SELECT source_id, shop_name, address_id, 'src_offline_sales' AS source_system, 'src_offline_sales' AS source_entity, now() AS insert_dt
		FROM (
			SELECT sos2.shop_id AS source_id, COALESCE(sos2.shop_name, 'NA') AS shop_name, COALESCE(a.address_id, -1) AS address_id
			-- From source data we need to take the most recent information about subcategory, because it can happend that shops name or address have been changed a few times.
			-- Shops table has SCD-1 type and we don't have a separate column with updating time for shops in our source data.
			-- We will take information about shops from the last transaction for a particular shop.
			,ROW_NUMBER () OVER(PARTITION BY sos2.shop_id ORDER BY CAST(sos2.transaction_date AS timestamp) DESC ) AS number_row
			FROM sa_offline_sales.src_offline_sales_view sos2
			LEFT JOIN bl_3nf.ce_addresses a ON a.source_id = sos2.address_id AND a.source_system = 'src_offline_sales' AND a.source_entity = 'src_offline_sales'
			WHERE sos2.address_id IS NOT NULL
			--AND sos2.insert_dt = (SELECT max(insert_dt) FROM sa_offline_sales.src_offline_sales) AND 
			) AS t 
		WHERE number_row=1
		ON CONFLICT(source_id, source_system, source_entity) 
		DO UPDATE SET 
		(shop_name, address_id, update_dt) = (excluded.shop_name, excluded.address_id, now())
		WHERE s.shop_name IS DISTINCT FROM excluded.shop_name OR
		s.address_id IS DISTINCT FROM excluded.address_id
		RETURNING shop_id
		)		
		
	SELECT array_agg(shop_id), count(*) INTO _var
		FROM insert_rows;
	
	CALL bl_cl.load_log_data('bl_3nf', 'ce_shops', 'success', 'Successfuly insert into ce_shops table', _var.affect_rows, _var.updated_ids);
	EXCEPTION
		WHEN OTHERS THEN
			GET STACKED DIAGNOSTICS
				log_msg = message_text;
			CALL bl_cl.load_log_data('bl_3nf', 'ce_shops', 'error', log_msg, 0, NULL);
		RAISE NOTICE 'some other error: %', sqlerrm;
		COMMIT;
	
END;$$;

COMMIT;