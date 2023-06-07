--Fill cities table with data

CREATE OR REPLACE PROCEDURE bl_cl.load_cities_3nf()
LANGUAGE plpgsql
AS $$
DECLARE
	--affect_rows integer;
	log_msg TEXT;
	_var type_for_log_table;
BEGIN
	WITH insert_rows AS (
		INSERT INTO bl_3nf.ce_cities AS c
		(source_id, city_name, state_id, source_system, source_entity, insert_dt)
		--Select states from online source
			SELECT source_id, city_name, state_id, 'src_online_sales' AS source_system, 'src_online_sales' AS source_entity, now() AS insert_dt
			FROM (
				SELECT sos.city_id AS source_id, sos.city  AS city_name, COALESCE(s.state_id, -1) AS state_id
				-- From source data we need to take the most recent information about cities, because it can happend that city name or state has been changed a few times.
				-- City table has SCD-1 type and we don't have a separate column with updating time for cities in our source data.
				-- We will take information about cities from the last transaction for a particular city.
				,ROW_NUMBER () OVER(PARTITION BY sos.city_id ORDER BY CAST(sos.transaction_date AS timestamp) DESC) AS number_row
				FROM sa_online_sales.src_online_sales_view sos
				LEFT JOIN bl_3nf.ce_states s ON s.source_id = sos.state_id AND s.source_system = 'src_online_sales' AND s.source_entity = 'src_online_sales' -- unickness IN ce_tables indentifiers as source id+sourse system+source entity 
				--WHERE sos.insert_dt = (SELECT max(insert_dt) FROM sa_online_sales.src_online_sales) --take ONLY actual DATA
				) AS t
			WHERE number_row=1
		UNION ALL
		--Select states from offline source
			SELECT source_id, city_name, state_id, 'src_offline_sales' AS source_system, 'src_offline_sales' AS source_entity, now() AS insert_dt 
			FROM (
				SELECT sos2.city_id AS source_id, sos2.city AS city_name, COALESCE(s2.state_id, -1) AS state_id
				,ROW_NUMBER () OVER(PARTITION BY sos2.city_id ORDER BY CAST(sos2.transaction_date AS TIMESTAMP) DESC) AS number_row
				FROM sa_offline_sales.src_offline_sales_view sos2
				LEFT JOIN bl_3nf.ce_states s2 ON s2.source_id = sos2.state_id AND s2.source_system = 'src_offline_sales' AND s2.source_entity = 'src_offline_sales'
				--WHERE sos2.insert_dt = (SELECT max(insert_dt) FROM sa_offline_sales.src_offline_sales) --take ONLY actual DATA
				) AS t2
			WHERE number_row=1
		ON CONFLICT(source_id, source_system, source_entity) 
		DO UPDATE SET 
		(city_name, state_id, update_dt) = (excluded.city_name, excluded.state_id, now())
		WHERE c.city_name IS DISTINCT FROM excluded.city_name OR
		c.state_id IS DISTINCT FROM excluded.state_id
		RETURNING city_id
		)
		
	SELECT array_agg(city_id), count(*) INTO _var
		FROM insert_rows;
	--GET DIAGNOSTICS affect_rows = row_count;
	CALL bl_cl.load_log_data('bl_3nf', 'ce_cities', 'success', 'Successfuly insert into ce_cities table', _var.affect_rows, _var.updated_ids);
	EXCEPTION
		WHEN OTHERS THEN
			GET STACKED DIAGNOSTICS
				log_msg = message_text;
			CALL bl_cl.load_log_data('bl_3nf', 'ce_cities', 'error', log_msg, 0, NULL);
		RAISE NOTICE 'some other error: %', sqlerrm;
		COMMIT;
	
END;$$;

COMMIT;