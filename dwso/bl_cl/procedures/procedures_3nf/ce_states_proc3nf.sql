--State refer to source city id, not to iso id, to use iso country code for state we use temp table temp_union_iso_countries_sourcies
--FIXED: add default values for varchar and integer data, previously it was only FK id.

CREATE OR REPLACE PROCEDURE bl_cl.load_states_3nf()
LANGUAGE plpgsql
AS $$
DECLARE
	--affect_rows integer;
	log_msg TEXT;
	_var type_for_log_table;
BEGIN
	WITH insert_rows AS (
		INSERT INTO bl_3nf.ce_states  AS st
		(source_id, state_name, state_code, country_id, source_system, source_entity, insert_dt)
		--Select states from online source
			SELECT source_id, state_name, state_code, country_id,  'src_online_sales' AS source_system, 'src_online_sales' AS source_entity, now() AS insert_dt
			FROM (
				SELECT sos.state_id AS source_id, COALESCE(sos.state, 'NA') AS state_name, COALESCE(TRIM(sos.state_code), 'NA') AS state_code, COALESCE(cc.country_id, -1) AS country_id
				-- From source data we need to take the most recent information about states, because it can happend that state name or code have been changed a few times.
				-- State table has SCD-1 type and we don't have a separate column with updating time for states in our source data.
				-- We will take information about states from the last transaction for a particular state.
				,ROW_NUMBER () OVER(PARTITION BY sos.state_id ORDER BY CAST(sos.transaction_date AS timestamp) DESC ) AS number_row
				FROM sa_online_sales.src_online_sales_view sos
				LEFT JOIN bl_cl.temp_union_iso_countries_sourcies t ON sos.country_id = t.source_id AND t.source_entity = 'src_online_sales' AND t.source_system = 'src_online_sales' --this TABLE always updates, so it CONTAINS ONLY actual data
				LEFT JOIN bl_3nf.ce_countries cc ON cc.source_id = t.country_iso_id
				--WHERE sos.insert_dt = (SELECT max(insert_dt) FROM sa_online_sales.src_online_sales) --take ONLY actual DATA
				) AS t
			WHERE number_row=1
		UNION ALL
		--Select states from offline source
			SELECT source_id, state_name, state_code, country_id , 'src_offline_sales' AS source_system, 'src_offline_sales' AS source_entity, now() AS insert_dt
			FROM (
				SELECT sos2.state_id AS source_id, COALESCE(sos2.state, 'NA') AS state_name, COALESCE(TRIM(sos2.state_code), 'NA') AS state_code, COALESCE(cc.country_id, -1) AS country_id
				,ROW_NUMBER () OVER(PARTITION BY sos2.state_id ORDER BY CAST(sos2.transaction_date AS timestamp) DESC ) AS number_row
				FROM sa_offline_sales.src_offline_sales_view sos2
				LEFT JOIN bl_cl.temp_union_iso_countries_sourcies t ON sos2.country_id = t.source_id AND t.source_entity = 'src_offline_sales' AND t.source_system = 'src_offline_sales' --this TABLE always updates, so it CONTAINS ONLY actual data
				LEFT JOIN bl_3nf.ce_countries cc ON cc.source_id = t.country_iso_id
				--WHERE sos2.insert_dt = (SELECT max(insert_dt) FROM sa_offline_sales.src_offline_sales) --take ONLY actual DATA
				) AS t2
			WHERE number_row=1
		ON CONFLICT (source_id, source_system, source_entity) 
		DO UPDATE SET 
		(state_name, state_code, country_id, update_dt) = (excluded.state_name, excluded.state_code, excluded.country_id, now())
		WHERE st.state_name IS DISTINCT FROM excluded.state_name OR
		st.state_code IS DISTINCT FROM excluded.state_code OR
		st.country_id IS DISTINCT FROM excluded.country_id
		RETURNING state_id
		)
		
	SELECT array_agg(state_id), count(*) INTO _var
		FROM insert_rows;

	CALL bl_cl.load_log_data('bl_3nf', 'ce_states', 'success', 'Successfuly insert into ce_states table', _var.affect_rows, _var.updated_ids);
	EXCEPTION
		WHEN OTHERS THEN
			GET STACKED DIAGNOSTICS
				log_msg = message_text;
			CALL bl_cl.load_log_data('bl_3nf', 'ce_states', 'error', log_msg, 0, NULL);
		RAISE NOTICE 'some other error: %', sqlerrm;
		COMMIT;
	
END;$$;

COMMIT;