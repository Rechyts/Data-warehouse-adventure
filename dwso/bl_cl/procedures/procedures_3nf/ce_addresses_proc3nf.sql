-- Fill addresses table with data. Only offline shops contain data about their addesses
--FIXED: add default values for varchar, integer and date data, previously it was only FK id.


CREATE OR REPLACE PROCEDURE bl_cl.load_addresses_3nf()
LANGUAGE plpgsql
AS $$
DECLARE
	--affect_rows integer;
	log_msg TEXT;
	_var type_for_log_table;
BEGIN
	WITH insert_rows AS (
		INSERT INTO bl_3nf.ce_addresses AS a
		(source_id, address_line1 , address_line2, postal_code , city_id, source_system , source_entity, insert_dt)
		SELECT address_id, address_line1, address_line2, postal_code, city_id, 'src_offline_sales' AS source_system, 'src_offline_sales' AS source_entity, now() AS insert_dt
		FROM (
			SELECT sos2.address_id  , COALESCE(sos2.address_line1, 'NA') AS address_line1, COALESCE(sos2.address_line2, 'NA') AS address_line2, COALESCE(sos2.postal_code, 'NA') AS  postal_code, COALESCE(c.city_id, -1) AS city_id,
			-- From source data we need to take the most recent information about addresses, because it can happend that address have been changed a few times.
			-- Addresses table has SCD-1 type and we don't have a separate column with updating time for addresses in our source data.
			-- We will take information about address from the last transaction for a particular address.
			ROW_NUMBER () OVER(PARTITION BY sos2.address_id ORDER BY CAST(sos2.transaction_date AS timestamp) DESC) AS number_row
			FROM sa_offline_sales.src_offline_sales_view sos2
			LEFT JOIN bl_3nf.ce_cities c ON c.source_id = sos2.city_id AND c.source_system = 'src_offline_sales' AND c.source_entity = 'src_offline_sales'
			--WHERE sos2.insert_dt = (SELECT max(insert_dt) FROM sa_offline_sales.src_offline_sales) AND sos2.address_id IS NOT NULL
			) AS t
		WHERE number_row=1
		ON CONFLICT(source_id, source_system, source_entity) 
		DO UPDATE SET 
		(address_line1, address_line2, postal_code, city_id, update_dt) = (excluded.address_line1, excluded.address_line2, excluded.postal_code, excluded.city_id, now())
		WHERE a.address_line1 IS DISTINCT FROM excluded.address_line1 OR
		a.address_line2 IS DISTINCT FROM excluded.address_line2 OR
		a.postal_code IS DISTINCT FROM excluded.postal_code OR
		a.city_id IS DISTINCT FROM excluded.city_id
		RETURNING address_id
	)
	
	SELECT array_agg(address_id), count(*) INTO _var
		FROM insert_rows;
	
	--GET DIAGNOSTICS affect_rows = row_count;
	CALL bl_cl.load_log_data('bl_3nf', 'ce_addresses', 'success', 'Successfuly insert into ce_addresses table', _var.affect_rows, _var.updated_ids);
	EXCEPTION
		WHEN OTHERS THEN
			GET STACKED DIAGNOSTICS
				log_msg = message_text;
			CALL bl_cl.load_log_data('bl_3nf', 'ce_addresses', 'error', log_msg, 0, NULL );
		RAISE NOTICE 'some other error: %', sqlerrm;
		COMMIT;
		
END;$$;

COMMIT;

