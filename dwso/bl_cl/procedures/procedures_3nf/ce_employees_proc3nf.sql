-- Fill employees table with data. Only offline shops contain data about their addesses
--FIXED: add default values for varchar, integer and date data, previously it was only FK id.

CREATE OR REPLACE PROCEDURE bl_cl.load_employees_3nf()
LANGUAGE plpgsql
AS $$
DECLARE
	--affect_rows integer;
	log_msg TEXT;
	_var type_for_log_table;
BEGIN
	WITH insert_rows AS (
		INSERT INTO bl_3nf.ce_employees AS e 
		(source_id, employee_name, employee_surname, employee_email, shop_id, source_system, source_entity, insert_dt)
		SELECT source_id, employee_name, employee_surname, employee_email, shop_id, 'src_offline_sales' AS source_system, 'src_offline_sales' AS source_entity, now() AS insert_dt
		FROM (
			SELECT sos2.employee_id AS source_id, COALESCE(sos2.employee_name, 'NA') AS employee_name, COALESCE(sos2.employee_surname, 'NA') AS employee_surname, COALESCE(sos2.employee_email, 'NA') AS employee_email, COALESCE(cs.shop_id, -1) AS shop_id 
			-- From source data we need to take the most recent information about employees, because it can happend that employee info have been changed a few times.
			-- Employee table has SCD-1 type and we don't have a separate column with updating time for employees in our source data.
			-- We will take information about employees from the last transaction for a particular employee.
			,ROW_NUMBER () OVER(PARTITION BY sos2.employee_id ORDER BY CAST(sos2.transaction_date AS timestamp) DESC ) AS number_row
			FROM sa_offline_sales.src_offline_sales_view sos2
			LEFT JOIN bl_3nf.ce_shops cs ON cs.source_id = sos2.shop_id AND cs.source_system = 'src_offline_sales' AND cs.source_entity = 'src_offline_sales'
			WHERE sos2.employee_id IS NOT NULL
			-- AND sos2.insert_dt = (SELECT max(insert_dt) FROM sa_offline_sales.src_offline_sales)
			) AS t 
		WHERE number_row=1
		ON CONFLICT(source_id, source_system, source_entity) 
		DO UPDATE SET 
		(employee_name, employee_surname, employee_email, shop_id, update_dt) = (excluded.employee_name, excluded.employee_surname, excluded.employee_email, excluded.shop_id, now())
		WHERE e.employee_name IS DISTINCT FROM excluded.employee_name OR
		e.employee_surname IS DISTINCT FROM excluded.employee_surname OR
		e.employee_email IS DISTINCT FROM excluded.employee_email OR
		e.shop_id IS DISTINCT FROM excluded.shop_id
		RETURNING employee_id
		)	
	
	SELECT array_agg(employee_id), count(*) INTO _var
		FROM insert_rows;
		
	CALL bl_cl.load_log_data('bl_3nf', 'ce_employees', 'success', 'Successfuly insert into ce_employees table', _var.affect_rows, _var.updated_ids);
	EXCEPTION
		WHEN OTHERS THEN
			GET STACKED DIAGNOSTICS
				log_msg = message_text;
			CALL bl_cl.load_log_data('bl_3nf', 'ce_employees', 'error', log_msg, 0, NULL);
		RAISE NOTICE 'some other error: %', sqlerrm;
		COMMIT;
	
END;$$;

COMMIT;