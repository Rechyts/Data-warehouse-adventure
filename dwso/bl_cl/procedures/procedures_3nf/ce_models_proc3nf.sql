-- Fill models table with data
--FIXED: add default values for varchar, integer and date data, previously it was only FK id.

CREATE OR REPLACE PROCEDURE bl_cl.load_models_3nf()
LANGUAGE plpgsql
AS $$
DECLARE
	affect_rows integer;
	log_msg TEXT;
	_var type_for_log_table;
BEGIN
	WITH insert_rows AS (
		INSERT INTO bl_3nf.ce_models AS m
		(source_id, model_name, model_desc, source_system, source_entity, insert_dt)
		--Take data from online shops
			SELECT source_id, model_name, model_desc, 'src_online_sales' AS source_system, 'src_online_sales' AS source_entity, now() AS insert_dt
			FROM (
				SELECT sos.model_id AS source_id, COALESCE(INITCAP(sos.model_name), 'NA') AS model_name, COALESCE(sos.model_desc, 'NA') AS model_desc
				-- From source data we need to take the most recent information about product model, because it can happend that model name or model description have been changed a few times.
				-- Model table has SCD-1 type and we don't have a separate column with updating time for models in our source data.
				-- We will take information about models from the last transaction for a particular model.
				,ROW_NUMBER() OVER(PARTITION BY sos.model_id ORDER BY CAST(sos.transaction_date AS timestamp) DESC ) AS number_row 
				FROM sa_online_sales.src_online_sales_view sos
				--WHERE sos.insert_dt = (SELECT max(insert_dt) FROM sa_online_sales.src_online_sales)
				) AS t
			WHERE number_row=1
		UNION ALL
		--Take data from offline shops
			SELECT source_id, model_name, model_desc, 'src_offline_sales' AS source_system, 'src_offline_sales' AS source_entity, now() AS insert_dt
			FROM (
				SELECT sos2.model_id AS source_id, COALESCE(INITCAP(sos2.model_name), 'NA') AS model_name, COALESCE(sos2.model_desc, 'NA') AS model_desc
				,ROW_NUMBER() OVER(PARTITION BY sos2.model_id ORDER BY CAST(sos2.transaction_date AS timestamp) DESC ) AS number_row 
				FROM sa_offline_sales.src_offline_sales_view sos2
				--WHERE sos2.insert_dt = (SELECT max(insert_dt) FROM sa_offline_sales.src_offline_sales)
				) AS t2
			WHERE number_row=1
		ON CONFLICT(source_id, source_system, source_entity) 
		DO UPDATE SET 
		(model_name, model_desc, update_dt) = (excluded.model_name, excluded.model_desc, now())
		WHERE m.model_name IS DISTINCT FROM excluded.model_name OR
		m.model_desc IS DISTINCT FROM excluded.model_desc
		RETURNING model_id
		)
	
	SELECT array_agg(model_id), count(*) INTO _var
		FROM insert_rows;
	
	CALL bl_cl.load_log_data('bl_3nf', 'ce_models', 'success', 'Successfuly insert into ce_models table', _var.affect_rows, _var.updated_ids);
	EXCEPTION
		WHEN OTHERS THEN
			GET STACKED DIAGNOSTICS
				log_msg = message_text;
			CALL bl_cl.load_log_data('bl_3nf', 'ce_models', 'error', log_msg, 0, NULL);
		RAISE NOTICE 'some other error: %', sqlerrm;
		COMMIT;
	
END;$$;

COMMIT;