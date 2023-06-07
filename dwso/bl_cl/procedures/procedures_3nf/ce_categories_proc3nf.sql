-- Fill product categories table with data
--FIXED: add default values for varchar, integer and date data, previously it was only FK id.

CREATE OR REPLACE PROCEDURE bl_cl.load_categories_3nf()
LANGUAGE plpgsql
AS $$
DECLARE
	log_msg TEXT;
	_var type_for_log_table;
BEGIN
	WITH insert_rows AS (
		INSERT INTO bl_3nf.ce_categories AS c
		(source_id, category_name, source_system, source_entity, insert_dt)
		SELECT source_id, category_name, 'src_online_sales' AS source_system, 'src_online_sales' AS source_entity, now() AS insert_dt 
		FROM (
			SELECT sos.category_id AS source_id, COALESCE(sos.category, 'NA') AS category_name
			-- From source data we need to take the most recent information about category, because it can happend that category name have been changed a few times.
			-- Category table has SCD-1 type and we don't have a separate column with updating time for categories in our source data.
			-- We will take information about categories from the last transaction for a particular category.
			, ROW_NUMBER () OVER(PARTITION BY sos.category_id ORDER BY CAST(sos.transaction_date AS timestamp) DESC) AS number_row
			FROM sa_online_sales.src_online_sales_view sos
			--WHERE sos.insert_dt = (SELECT max(insert_dt) FROM sa_online_sales.src_online_sales)
			) AS t
		WHERE number_row=1
		UNION ALL
		SELECT source_id, category_name, 'src_offline_sales' AS source_system, 'src_offline_sales' AS source_entity, now() AS insert_dt
		FROM (
			SELECT sos2.category_id AS source_id, COALESCE(sos2.category, 'NA') AS category_name
			,ROW_NUMBER () OVER(PARTITION BY sos2.category_id ORDER BY CAST(sos2.transaction_date AS timestamp) DESC) AS number_row
			FROM sa_offline_sales.src_offline_sales_view sos2
			--WHERE sos2.insert_dt = (SELECT max(insert_dt) FROM sa_offline_sales.src_offline_sales)
			) AS t2
		WHERE number_row=1
		ON CONFLICT(source_id, source_system, source_entity) 
		DO UPDATE SET 
		(category_name, update_dt) = (excluded.category_name, now())
		WHERE c.category_name IS DISTINCT FROM excluded.category_name
		RETURNING category_id
		)
		
	SELECT array_agg(category_id), count(*) INTO _var
		FROM insert_rows;
		
	--GET DIAGNOSTICS affect_rows = row_count;
	CALL bl_cl.load_log_data('bl_3nf', 'ce_categories', 'success', 'Successfuly insert into ce_categories table', _var.affect_rows, _var.updated_ids);
	EXCEPTION
		WHEN OTHERS THEN
			GET STACKED DIAGNOSTICS
				log_msg = message_text;
			CALL bl_cl.load_log_data('bl_3nf', 'ce_categories', 'error', log_msg, 0, NULL);
		RAISE NOTICE 'some other error: %', sqlerrm;
		COMMIT;
	
END;$$;

COMMIT;