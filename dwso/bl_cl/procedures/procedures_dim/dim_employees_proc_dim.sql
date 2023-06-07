CREATE OR REPLACE PROCEDURE bl_cl.load_employees_dim()
LANGUAGE plpgsql
AS $$
DECLARE
	log_msg TEXT;
	_var type_for_log_table;
BEGIN
	WITH insert_rows AS (	
		INSERT INTO bl_dm.dim_employees AS dc
		(employee_id, employee_name, employee_surname, employee_email, source_system, source_entity, insert_dt)
		SELECT CAST(c.employee_id AS varchar) AS employee_id, c.employee_name , c.employee_surname , c.employee_email,  c.source_system , c.source_entity, now() AS insert_dt 
		FROM bl_3nf.ce_employees c
		WHERE c.employee_id <> -1
		ON CONFLICT(employee_id, source_system, source_entity) DO UPDATE 
		SET (employee_id, employee_name, employee_surname, employee_email, update_dt) =
		ROW (excluded.employee_id, excluded.employee_name, excluded.employee_surname, excluded.employee_email, now())
		WHERE md5(CONCAT(dc.employee_id, dc.employee_name, dc.employee_surname, dc.employee_email))
		IS DISTINCT FROM md5(CONCAT(excluded.employee_id, excluded.employee_name, excluded.employee_surname, excluded.employee_email))
		RETURNING employee_surr_id
	)
	SELECT array_agg(employee_surr_id), count(*) INTO _var
	FROM insert_rows;

	--GET DIAGNOSTICS affect_rows = row_count;
	CALL bl_cl.load_log_data('bl_dm', 'dim_employees', 'success', 'Successfuly insert into dim_employees table', _var.affect_rows, _var.updated_ids);
	EXCEPTION
	WHEN OTHERS THEN
		GET STACKED DIAGNOSTICS
			log_msg = message_text;
		CALL bl_cl.load_log_data('bl_dm', 'dim_employees', 'error', log_msg, 0, NULL);
	RAISE NOTICE 'some other error: %', sqlerrm;
COMMIT;

END;$$;

COMMIT;