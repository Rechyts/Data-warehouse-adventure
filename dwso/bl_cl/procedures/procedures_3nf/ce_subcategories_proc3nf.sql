-- Fill product subcategories table with data
--FIXED: add default values for varchar and integer data, previously it was only FK id.

CREATE OR REPLACE PROCEDURE bl_cl.load_subcategories_3nf()
LANGUAGE plpgsql
AS $$
DECLARE
	--affect_rows integer;
	log_msg TEXT;
	_var type_for_log_table;
BEGIN
	WITH insert_rows AS (
		INSERT INTO bl_3nf.ce_subcategories AS sc
		(source_id, subcategory_name, category_id, source_system, source_entity, insert_dt)
		SELECT subcategory_id, subcategory_name, category_id, 'src_online_sales' AS source_system, 'src_online_sales' AS source_entity, now() AS insert_dt
		FROM (
			SELECT sos.subcategory_id , COALESCE(INITCAP(sos.subcategory), 'NA') AS subcategory_name, COALESCE(c.category_id, -1) AS category_id,
			-- From source data we need to take the most recent information about subcategory, because it can happend that subcategory name have been changed a few times.
			-- Subcategory table has SCD-1 type and we don't have a separate column with updating time for subcategories in our source data.
			-- We will take information about subcategories from the last transaction for a particular subcategory.
			ROW_NUMBER () OVER (PARTITION BY sos.subcategory_id ORDER BY CAST(sos.transaction_date AS timestamp) DESC) AS number_row
			FROM sa_online_sales.src_online_sales_view sos
			LEFT JOIN bl_3nf.ce_categories c ON c.source_id = sos.category_id AND c.source_system  = 'src_online_sales' AND c.source_entity = 'src_online_sales'
			--WHERE sos.insert_dt = (SELECT max(insert_dt) FROM sa_online_sales.src_online_sales)
			) AS t
		WHERE number_row = 1
		UNION ALL
		SELECT subcategory_id, subcategory_name, category_id, 'src_offline_sales' AS source_system, 'src_offline_sales' AS source_entity, now() AS insert_dt
		FROM (
			SELECT sos2.subcategory_id , COALESCE(INITCAP(sos2.subcategory),'NA') AS subcategory_name, COALESCE(c2.category_id, -1) AS category_id,
			ROW_NUMBER () OVER (PARTITION BY sos2.subcategory_id ORDER BY CAST(sos2.transaction_date AS timestamp) DESC) AS number_row
			FROM sa_offline_sales.src_offline_sales_view sos2
			LEFT JOIN bl_3nf.ce_categories c2 ON c2.source_id = sos2.category_id AND c2.source_system  = 'src_offline_sales' AND c2.source_entity = 'src_offline_sales'
			--WHERE sos2.insert_dt = (SELECT max(insert_dt) FROM sa_offline_sales.src_offline_sales)
			) AS t2
		WHERE number_row = 1
		ON CONFLICT(source_id, source_system, source_entity) 
		DO UPDATE SET 
		(subcategory_name, category_id, update_dt) = (excluded.subcategory_name, excluded.category_id,  now())
		WHERE sc.subcategory_name IS DISTINCT FROM excluded.subcategory_name OR
		sc.category_id IS DISTINCT FROM excluded.category_id 
		RETURNING subcategory_id
		) 
	
	SELECT array_agg(subcategory_id), count(*) INTO _var
		FROM insert_rows;	
		
	--GET DIAGNOSTICS affect_rows = row_count;
	CALL bl_cl.load_log_data('bl_3nf', 'ce_subcategories', 'success', 'Successfuly insert into ce_subcategories table', _var.affect_rows, _var.updated_ids);
	EXCEPTION
		WHEN OTHERS THEN
			GET STACKED DIAGNOSTICS
				log_msg = message_text;
			CALL bl_cl.load_log_data('bl_3nf', 'ce_subcategories', 'error', log_msg, 0, NULL);
		RAISE NOTICE 'some other error: %', sqlerrm;
		COMMIT;
	
END;$$;

COMMIT;