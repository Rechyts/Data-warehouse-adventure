
CREATE OR REPLACE PROCEDURE bl_cl.load_customers_dim()
LANGUAGE plpgsql
AS $$
DECLARE
	log_msg TEXT;
	_var type_for_log_table;
BEGIN
	WITH insert_rows AS (	
		INSERT INTO bl_dm.dim_customers AS dc
		(customer_id, customer_name, customer_surname, customer_email, customer_gender, customer_date_of_birth, source_system, source_entity, insert_dt)
		SELECT CAST(c.customer_id AS varchar) AS  customer_id, c.customer_name , c.customer_surname , c.customer_email , c.customer_gender , c.customer_date_of_birth , c.source_system , c.source_entity, now() AS insert_dt 
		FROM bl_3nf.ce_customers c
		WHERE c.customer_id <> -1
		ON CONFLICT(customer_id, source_system, source_entity) DO UPDATE 
		SET (customer_id, customer_name, customer_surname, customer_email, customer_gender, customer_date_of_birth, update_dt) =
		ROW (excluded.customer_id, excluded.customer_name, excluded.customer_surname, excluded.customer_email, excluded.customer_gender, excluded.customer_date_of_birth, now())
		WHERE md5(CONCAT(dc.customer_id, dc.customer_name, dc.customer_surname, dc.customer_email, dc.customer_gender, CAST(dc.customer_date_of_birth AS varchar))) 
		IS DISTINCT FROM md5(CONCAT(excluded.customer_id, excluded.customer_name, excluded.customer_surname, excluded.customer_email, excluded.customer_gender, CAST(excluded.customer_date_of_birth AS varchar)))
		RETURNING customer_surr_id
	)
	SELECT array_agg(customer_surr_id), count(*) INTO _var
	FROM insert_rows;

	--GET DIAGNOSTICS affect_rows = row_count;
	CALL bl_cl.load_log_data('bl_dm', 'dim_customers', 'success', 'Successfuly insert into dim_customers table', _var.affect_rows, _var.updated_ids);
	EXCEPTION
	WHEN OTHERS THEN
		GET STACKED DIAGNOSTICS
			log_msg = message_text;
		CALL bl_cl.load_log_data('bl_dm', 'dim_customers', 'error', log_msg, 0, NULL);
	RAISE NOTICE 'some other error: %', sqlerrm;
COMMIT;

END;$$;

COMMIT;

	