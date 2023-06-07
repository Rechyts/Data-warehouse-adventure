--Fill clors table with data

CREATE OR REPLACE PROCEDURE bl_cl.load_colors_3nf()
LANGUAGE plpgsql
AS $$
DECLARE
	_var type_for_log_table;
	log_msg TEXT;
BEGIN
	WITH insert_rows AS (
		INSERT INTO bl_3nf.ce_colors AS c
		(source_id, color_name, source_system, source_entity, insert_dt)
		--Use INITCAP to capitalizing first letter in words.
			SELECT source_id, color_name, 'src_online_sales' AS source_system, 'src_online_sales' AS source_entity, now() AS insert_dt
			FROM (
				SELECT sos.color_id  AS source_id, INITCAP(sos.color)  AS color_name
				-- From source data we need to take the most recent information about color, because it can happend that color name have been changed a few times.
				-- Color table has SCD-1 type and we don't have a separate column with updating time for colors in our source data.
				-- We will take information about colors from the last transaction for a particular color.
				,ROW_NUMBER() OVER(PARTITION BY sos.color_id ORDER BY CAST(sos.transaction_date AS timestamp) DESC) AS number_row
				FROM sa_online_sales.src_online_sales_view sos
				--WHERE sos.insert_dt = (SELECT max(insert_dt) FROM sa_online_sales.src_online_sales)
				) AS t
			WHERE number_row=1
		UNION ALL
			SELECT source_id, color_name, 'src_offline_sales' AS source_system, 'src_offline_sales' AS source_entity, now() AS insert_dt
			FROM (
				SELECT sos2.color_id  AS source_id, INITCAP(sos2.color)  AS color_name
				, ROW_NUMBER() OVER(PARTITION BY sos2.color_id ORDER BY CAST(sos2.transaction_date AS timestamp) DESC) AS number_row
				FROM sa_offline_sales.src_offline_sales_view sos2
				--WHERE sos2.insert_dt = (SELECT max(insert_dt) FROM sa_offline_sales.src_offline_sales)
				) AS t2
			WHERE number_row=1	
		ON CONFLICT(source_id, source_system, source_entity) 
		DO UPDATE SET 
		(color_name, update_dt) = (excluded.color_name, now())
		WHERE c.color_name IS DISTINCT FROM excluded.color_name
		RETURNING color_id
		)
		
	SELECT array_agg(color_id), count(*) INTO _var
	FROM insert_rows;
	
	CALL bl_cl.load_log_data('bl_3nf', 'ce_colors', 'success', 'Successfuly insert into ce_colors table', _var.affect_rows, _var.updated_ids);
	EXCEPTION
		WHEN OTHERS THEN
			GET STACKED DIAGNOSTICS
				log_msg = message_text;
			CALL bl_cl.load_log_data('bl_3nf', 'ce_colors', 'error', log_msg, 0, NULL);
		RAISE NOTICE 'some other error: %', sqlerrm;
		COMMIT;
	
END;$$;

COMMIT;