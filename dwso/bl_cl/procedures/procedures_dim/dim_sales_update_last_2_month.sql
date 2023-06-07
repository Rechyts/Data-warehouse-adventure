--Load data to fct sales table for last 2 month

CREATE OR REPLACE PROCEDURE bl_cl.load_sales_last_2month_in_partition(partition_name regclass, start_of_month timestamp, end_of_next_month timestamp)
LANGUAGE plpgsql
AS $$
DECLARE
	log_msg TEXT;
	_var type_for_log_table;
	v_query_string TEXT;

BEGIN
	v_query_string = format (
		'WITH insert_rows AS (
		INSERT INTO %s AS a
		(product_surr_id, model_surr_id,  customer_surr_id, employee_surr_id , shop_surr_id , address_surr_id , time_id , transaction_id , price, sale, quantity , source_system, source_entity, insert_dt)
		SELECT COALESCE(p.product_surr_id, -1) AS product_surr_id,COALESCE(m.model_surr_id, -1) AS model_surr_id, COALESCE(c.customer_surr_id, -1) AS customer_surr_id, COALESCE(e.employee_surr_id, -1) AS employee_surr_id , COALESCE(sh.shop_surr_id, -1) AS shop_surr_id, COALESCE(d.address_surr_id, -1) AS  address_surr_id, COALESCE(t.date_id, %L) AS date_id, CAST(COALESCE(s.transaction_id, -1) AS varchar) AS transaction_id, COALESCE(s.price, 0) AS price, COALESCE(s.sale, 0) AS sale, COALESCE(s.quantity, 0) AS quantity, s.source_system, s.source_entity, now() AS insert_dt
		FROM bl_3nf.ce_sales s
		LEFT JOIN bl_dm.dim_products p ON p.product_id = CAST(s.product_id AS varchar) AND p.source_system = s.source_system AND p.source_entity = s.source_entity AND s.transaction_date BETWEEN p.start_date AND p.end_date 
		LEFT JOIN bl_dm.dim_models m ON m.model_id = CAST(s.model_id AS varchar) AND m.source_system = s.source_system AND m.source_entity = s.source_entity
		LEFT JOIN bl_dm.dim_customers c ON c.customer_id = CAST(s.customer_id AS varchar) AND c.source_system = s.source_system AND c.source_entity = s.source_entity
		LEFT JOIN bl_dm.dim_employees e ON e.employee_id = CAST(s.employee_id AS varchar) AND e.source_system = s.source_system AND e.source_entity = s.source_entity
		LEFT JOIN bl_dm.dim_shops sh ON sh.shop_id = CAST(s.shop_id AS varchar) AND sh.source_system = s.source_system AND sh.source_entity = s.source_entity
		LEFT JOIN bl_dm.dim_addresses d ON d.address_id = CAST(s.address_id AS varchar) AND d.city_id = CAST(s.city_id AS varchar) AND d.source_system = s.source_system AND d.source_entity = s.source_entity
		LEFT JOIN bl_dm.dim_dates t ON t.date_id = s.transaction_date::DATE
		WHERE s.transaction_date BETWEEN %L AND %L
		ON CONFLICT DO NOTHING 
		RETURNING transaction_id
	)
	
	SELECT array_agg(transaction_id::integer), count(*)
	FROM insert_rows', partition_name, '1900-01-01'::timestamp, start_of_month, end_of_next_month);
	EXECUTE v_query_string INTO _var;

	CALL bl_cl.load_log_data('bl_dm', 'fct_sales_last_2month', 'success', 'Successfuly insert into fct_sales_last_2month table', _var.affect_rows, _var.updated_ids);
	EXCEPTION
	WHEN OTHERS THEN
		GET STACKED DIAGNOSTICS
			log_msg = message_text;
		CALL bl_cl.load_log_data('bl_dm', 'fct_sales_last_2month', 'error', log_msg, 0, NULL);
	RAISE NOTICE 'some other error: %', sqlerrm;

END;$$;

COMMIT;
