--Create a work table for products
CREATE TABLE IF NOT EXISTS bl_cl.work_products (
source_id varchar(255) NOT NULL NOT NULL,
product_name varchar(255) NOT NULL DEFAULT 'NA',
product_number varchar(255) NOT NULL DEFAULT 'NA',
color_id integer NOT NULL DEFAULT -1,
subcategory_id integer NOT NULL DEFAULT -1,
source_system varchar(255) NOT NULL,
source_entity varchar(255) NOT NULL,
transaction_date TIMESTAMP NOT NULL DEFAULT '1900-01-01'::TIMESTAMP
);
--Create procedure for combine info about both sources in one table and realisation of complex SCD2 logic
-- Choose records, that was changed and when it happend
CREATE OR REPLACE PROCEDURE bl_cl.load_work_products()
LANGUAGE plpgsql
AS $$
DECLARE
	--affect_rows integer;
	log_msg TEXT;
	_var type_for_log_table;
BEGIN
	TRUNCATE TABLE bl_cl.work_products;
	WITH insert_rows AS (	
		INSERT INTO bl_cl.work_products (
			SELECT source_id, product_name, product_number, color_id, subcategory_id, source_system, source_entity, transaction_date
			FROM (
				SELECT source_id, product_name, product_number, color_id, subcategory_id, source_system, source_entity, transaction_date, number_row
				,ROW_NUMBER() OVER(PARTITION BY source_id, number_row ORDER BY CAST(transaction_date AS timestamp)) AS number_row2
				FROM (
					SELECT sos.product_id AS source_id, COALESCE(sos.product_name, 'NA') AS product_name, COALESCE(sos.product_number, 'NA') AS product_number, COALESCE(c.color_id, -1) AS color_id, COALESCE(s.subcategory_id, -1) AS subcategory_id , 'src_online_sales' AS source_system, 'src_online_sales' AS source_entity
					,CAST(sos.transaction_date AS TIMESTAMP) AS transaction_date , DENSE_RANK () OVER(PARTITION BY sos.product_id ORDER BY sos.product_name, sos.product_number, COALESCE(c.color_id, -1), COALESCE(s.subcategory_id, -1)) AS number_row
					
					FROM sa_online_sales.src_online_sales_view sos
					LEFT JOIN bl_3nf.ce_subcategories s ON s.source_id = sos.subcategory_id AND s.source_system = 'src_online_sales' AND s.source_entity = 'src_online_sales'
					LEFT JOIN bl_3nf.ce_colors c ON c.source_id = sos.color_id AND c.source_system = 'src_online_sales' AND c.source_entity = 'src_online_sales'
					--WHERE sos.insert_dt = (SELECT max(insert_dt) FROM sa_online_sales.src_online_sales)
						) AS t
					) AS t1
			WHERE number_row2=1
		UNION ALL
			SELECT source_id, product_name, product_number, color_id, subcategory_id, source_system, source_entity, transaction_date
			FROM (
				SELECT source_id, product_name, product_number, color_id, subcategory_id, source_system, source_entity, transaction_date, number_row
				,ROW_NUMBER() OVER(PARTITION BY source_id, number_row ORDER BY CAST(transaction_date AS timestamp)) AS number_row2
				FROM (
					SELECT sos2.product_id AS source_id, COALESCE(sos2.product_name, 'NA') AS product_name, COALESCE(sos2.product_number, 'NA') AS product_number, COALESCE(c2.color_id, -1) AS color_id, COALESCE(s2.subcategory_id, -1) AS subcategory_id , 'src_offline_sales' AS source_system, 'src_offline_sales' AS source_entity
					,CAST(sos2.transaction_date AS TIMESTAMP) AS transaction_date , DENSE_RANK () OVER(PARTITION BY sos2.product_id ORDER BY sos2.product_name, sos2.product_number, COALESCE(c2.color_id, -1), COALESCE(s2.subcategory_id, -1)) AS number_row
					
					FROM sa_offline_sales.src_offline_sales_view sos2
					LEFT JOIN bl_3nf.ce_subcategories s2 ON s2.source_id = sos2.subcategory_id AND s2.source_system = 'src_offline_sales' AND s2.source_entity = 'src_offline_sales'
					LEFT JOIN bl_3nf.ce_colors c2 ON c2.source_id = sos2.color_id AND c2.source_system = 'src_offline_sales' AND c2.source_entity = 'src_offline_sales'
					--WHERE sos2.insert_dt = (SELECT max(insert_dt) FROM sa_offline_sales.src_offline_sales)
						) AS t
					) AS t1
			WHERE number_row2=1
								) 
		RETURNING source_id
		)
	
	SELECT array_agg(source_id), count(*) INTO _var
		FROM insert_rows;
	
	CALL bl_cl.load_log_data('bl_cl', 'work_products', 'success', 'Successfuly insert into work_products table', _var.affect_rows, _var.updated_ids);
	EXCEPTION
		WHEN OTHERS THEN
			GET STACKED DIAGNOSTICS
				log_msg = message_text;
			CALL bl_cl.load_log_data('bl_cl', 'work_products', 'error', log_msg, 0, NULL);
		RAISE NOTICE 'some other error: %', sqlerrm;
COMMIT;
END;
$$;

COMMIT;


