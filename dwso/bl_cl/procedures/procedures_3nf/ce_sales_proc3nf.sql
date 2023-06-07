--Fill sales table with data
--FIXED: add city_id FK for all transactions online and offline, because we have this data in source tables and business wants have possability to analyze sales by regions/countries/cities 
--FIXED: add default values for varchar, integer and date data, previously it was only FK id.


CREATE OR REPLACE PROCEDURE bl_cl.load_sales_3nf()
LANGUAGE plpgsql
AS $$
DECLARE
	--affect_rows integer;
	log_msg TEXT;
	_var type_for_log_table;
BEGIN
	--Create partitioned for ce_sales table by month based on transaction date
	CALL bl_cl.create_sales_partitions('bl_3nf', 'ce_sales', '2020-01-01'::TIMESTAMP, 45);
	
	WITH insert_rows AS (
		INSERT INTO bl_3nf.ce_sales AS s
		(source_id, product_id, model_id, customer_id, employee_id, shop_id, address_id, city_id, transaction_date, quantity, sale, price, source_system, source_entity , insert_dt)
			SELECT DISTINCT sos.transaction_id AS source_id, COALESCE(p.product_id, -1) AS product_id, COALESCE(m.model_id, -1) AS model_id, COALESCE(c.customer_id, -1) AS customer_id, -1 AS employee_id, -1 AS shop_id, -1 AS address_id, COALESCE(ct.city_id, -1) AS city_id, COALESCE(CAST(sos.transaction_date AS TIMESTAMP), '9999-12-31'::TIMESTAMP) AS transaction_date, COALESCE(CAST(sos.quantity AS INTEGER), -1) AS quantity, COALESCE(CAST(sos.sale AS NUMERIC(10,2)), -1) AS sale, COALESCE(CAST(sos.price AS NUMERIC(10,2)), -1) AS price, 'src_online_sales' AS source_system, 'src_online_sales' AS source_entity, now() AS insert_dt 
			FROM sa_online_sales.src_online_sales_view sos
			LEFT JOIN bl_3nf.ce_products p ON p.source_id = sos.product_id AND p.source_system = 'src_online_sales' AND p.source_entity = 'src_online_sales' AND CAST(sos.transaction_date AS TIMESTAMP) BETWEEN p.date_start AND p.date_end --FIXED add additional parameter for join date_end because we need to get recent records of product. Product table has SCD-2.
			LEFT JOIN bl_3nf.ce_models m ON m.source_id = sos.model_id AND m.source_system = 'src_online_sales' AND m.source_entity = 'src_online_sales'
			LEFT JOIN bl_3nf.ce_customers c ON c.source_id = sos.customer_id AND c.source_system = 'src_online_sales' AND c.source_entity = 'src_online_sales'
			LEFT JOIN bl_3nf.ce_cities ct ON ct.source_id = sos.city_id AND ct.source_system = 'src_online_sales' AND ct.source_entity = 'src_online_sales'
			--WHERE sos.insert_dt = (SELECT max(insert_dt) FROM sa_online_sales.src_online_sales)
		UNION ALL
			SELECT DISTINCT sos2.transaction_id AS source_id, COALESCE(p2.product_id, -1) AS product_id, COALESCE(m2.model_id, -1) AS model_id, COALESCE (c2.customer_id, -1) AS customer_id, COALESCE (y.employee_id, -1) AS employee_id, COALESCE(sh.shop_id, -1) AS shop_id, COALESCE(a2.address_id, -1) AS address_id, COALESCE(ct2.city_id, -1) AS city_id, COALESCE(CAST(sos2.transaction_date AS TIMESTAMP), '9999-12-31'::TIMESTAMP) AS transaction_date, COALESCE(CAST(sos2.quantity AS INTEGER),-1) AS quantity, COALESCE(CAST(sos2.sale AS NUMERIC(10,2)),-1) AS sale, COALESCE(CAST(sos2.price AS NUMERIC(10,2)),-1) AS price, 'src_offline_sales' AS source_system, 'src_offline_sales' AS source_entity, now() AS insert_dt 
			FROM sa_offline_sales.src_offline_sales_view sos2
			LEFT JOIN bl_3nf.ce_products p2 ON p2.source_id = sos2.product_id AND p2.source_system = 'src_offline_sales' AND p2.source_entity = 'src_offline_sales' AND CAST(sos2.transaction_date AS TIMESTAMP) BETWEEN p2.date_start AND p2.date_end --FIXED add additional parameter for join date_end because we need to get recent records of product. Product table has SCD-2.
			LEFT JOIN bl_3nf.ce_models m2 ON m2.source_id = sos2.model_id AND m2.source_system = 'src_offline_sales' AND m2.source_entity = 'src_offline_sales'
			LEFT JOIN bl_3nf.ce_customers c2 ON c2.source_id = sos2.customer_id AND c2.source_system = 'src_offline_sales' AND c2.source_entity = 'src_offline_sales'
			LEFT JOIN bl_3nf.ce_employees y ON y.source_id = sos2.employee_id  AND y.source_system = 'src_offline_sales' AND y.source_entity = 'src_offline_sales'
			LEFT JOIN bl_3nf.ce_shops sh ON sh.source_id = sos2.shop_id AND sh.source_system = 'src_offline_sales' AND sh.source_entity = 'src_offline_sales'
			--FIXED: add address attribute to fact tables, because we took out addresses in a separate dim table
			LEFT JOIN bl_3nf.ce_addresses a2 ON a2.source_id = sos2.address_id AND a2.source_system = 'src_offline_sales' AND a2.source_entity = 'src_offline_sales'
			LEFT JOIN bl_3nf.ce_cities ct2 ON ct2.source_id = sos2.city_id AND ct2.source_system = 'src_offline_sales' AND ct2.source_entity = 'src_offline_sales'
			--WHERE sos2.insert_dt = (SELECT max(insert_dt) FROM sa_offline_sales.src_offline_sales)
		ON CONFLICT DO NOTHING	
		RETURNING transaction_id
		)
		
	SELECT array_agg(transaction_id), count(*) INTO _var
		FROM insert_rows;
	
	CALL bl_cl.load_log_data('bl_3nf', 'ce_sales', 'success', 'Successfuly insert into ce_sales table', _var.affect_rows, _var.updated_ids);
	EXCEPTION
		WHEN OTHERS THEN
			GET STACKED DIAGNOSTICS
				log_msg = message_text;
			CALL bl_cl.load_log_data('bl_3nf', 'ce_sales', 'error', log_msg, 0, NULL);
		RAISE NOTICE 'some other error: %', sqlerrm;
		COMMIT;
	
END;$$;

COMMIT;

