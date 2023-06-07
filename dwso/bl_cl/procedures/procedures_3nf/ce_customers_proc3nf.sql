-- Fill customers table with data. Only offline shops contain data about employees


CREATE OR REPLACE PROCEDURE bl_cl.load_customers_3nf()
LANGUAGE plpgsql
AS $$
DECLARE
	_var type_for_log_table;
	log_msg TEXT;
BEGIN
	WITH insert_rows AS (
		INSERT INTO bl_3nf.ce_customers AS c
		(source_id, customer_name, customer_surname, customer_email, customer_gender, customer_date_of_birth, source_system, source_entity, insert_dt)
			SELECT source_id, customer_name, customer_surname , customer_email, customer_gender, customer_date_of_birth, 'src_online_sales' AS source_system, 'src_online_sales' AS source_entity, now() AS insert_dt
			FROM (
				SELECT sos.customer_id AS source_id, COALESCE(sos.customer_name, 'NA') AS customer_name , COALESCE(sos.customer_surname, 'NA') AS customer_surname , COALESCE(sos.customer_email, 'NA') AS customer_email, COALESCE(sos.customer_gender, 'NA') AS customer_gender , COALESCE(CAST(sos.customer_date_of_birth AS TIMESTAMP), '1900-01-01'::TIMESTAMP) AS customer_date_of_birth
				-- From source data we need to take the most recent information about customer, because it can happend that customer info has been changed a few times.
				-- Customer table has SCD-1 type and we don't have a separate column with updating time for customers in our source data.
				-- We will take information about customers from the last transaction for a particular customer.
				,ROW_NUMBER () OVER(PARTITION BY sos.customer_id ORDER BY CAST(sos.transaction_date AS timestamp) DESC) AS number_row
				FROM sa_online_sales.src_online_sales_view sos
				WHERE sos.customer_id IS NOT NULL
				-- AND sos.insert_dt = (SELECT max(insert_dt) FROM sa_online_sales.src_online_sales)
				) AS t 
			WHERE number_row=1
		UNION ALL
			SELECT source_id, customer_name, customer_surname, customer_email, customer_gender, customer_date_of_birth, 'src_offline_sales' AS source_system, 'src_offline_sales' AS source_entity, now() AS insert_dt
			FROM (
				SELECT sos2.customer_id AS source_id, COALESCE(sos2.customer_name, 'NA') AS customer_name , COALESCE(sos2.customer_surname, 'NA') AS customer_surname , COALESCE(sos2.customer_email, 'NA') AS customer_email, COALESCE(sos2.customer_gender, 'NA') AS customer_gender  , COALESCE(CAST(sos2.customer_date_of_birth AS TIMESTAMP), '1900-01-01'::TIMESTAMP) AS customer_date_of_birth
				,ROW_NUMBER () OVER(PARTITION BY sos2.customer_id ORDER BY CAST(sos2.transaction_date AS timestamp) DESC) AS number_row
				FROM sa_offline_sales.src_offline_sales_view sos2
				WHERE sos2.customer_id IS NOT NULL
				--AND sos2.insert_dt = (SELECT max(insert_dt) FROM sa_offline_sales.src_offline_sales)
				) AS t2
			WHERE number_row=1
		ON CONFLICT(source_id, source_system, source_entity) 
		DO UPDATE SET 
		(customer_name, customer_surname, customer_email, customer_gender, customer_date_of_birth, update_dt) = (excluded.customer_name, excluded.customer_surname, excluded.customer_email, excluded.customer_gender, excluded.customer_date_of_birth, now())
		WHERE c.customer_name IS DISTINCT FROM excluded.customer_name OR
		c.customer_surname IS DISTINCT FROM excluded.customer_surname OR
		c.customer_email IS DISTINCT FROM excluded.customer_email OR
		c.customer_gender IS DISTINCT FROM excluded.customer_gender OR
		c.customer_date_of_birth IS DISTINCT FROM excluded.customer_date_of_birth
		RETURNING customer_id
		)
	
	SELECT array_agg(customer_id), count(*) INTO _var
		FROM insert_rows;	
		
	CALL bl_cl.load_log_data('bl_3nf', 'ce_customers', 'success', 'Successfuly insert into ce_customers table', _var.affect_rows, _var.updated_ids);
	EXCEPTION
		WHEN OTHERS THEN
			GET STACKED DIAGNOSTICS
				log_msg = message_text;
			CALL bl_cl.load_log_data('bl_3nf', 'ce_customers', 'error', log_msg, 0, NULL);
		RAISE NOTICE 'some other error: %', sqlerrm;
		COMMIT;
	
END;$$;

COMMIT;