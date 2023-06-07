--Test data

CREATE TABLE IF NOT EXISTS bl_cl.test_dwh (
											id serial PRIMARY KEY,
											source_table TEXT,
											target_table TEXT,
											test_desc TEXT,
											test_result integer,
											test_time timestamp
											);

CREATE OR REPLACE FUNCTION bl_cl.test_keys_presenting( _source_table_name regclass, 
														_target_table_name regclass, 
														_source_id_field text, 
														_target_id_field text
														)
RETURNS TABLE (
				source_table text, 
				target_table text,
				test_desc text,
				test_result bigint,
				test_time timestamp
				)
AS $$
BEGIN
	RETURN query
	EXECUTE format 	
	('SELECT %L, %L, %L, count(*), now()::TIMESTAMP
					FROM %s
					WHERE %s::VARCHAR IN (SELECT %s::VARCHAR
								FROM %s
									EXCEPT 
								SELECT %s::VARCHAR
								FROM %s)', _source_table_name, _target_table_name, 'Number of identity mismatches between source and target tables', _source_table_name, _source_id_field, _source_id_field, _source_table_name, _target_id_field, _target_table_name
								
								);
	
END
$$ LANGUAGE plpgsql;
										
										
CREATE OR REPLACE PROCEDURE bl_cl.test_business_key_presenting_3nf()
LANGUAGE plpgsql
AS $$
BEGIN
	INSERT INTO bl_cl.test_dwh
	(source_table, target_table, test_desc, test_result, test_time)
	SELECT * FROM bl_cl.test_keys_presenting('sa_offline_sales.src_offline_sales', 'bl_3nf.ce_products', 'product_id', 'source_id')
	UNION ALL
	SELECT * FROM bl_cl.test_keys_presenting('sa_offline_sales.src_offline_sales', 'bl_3nf.ce_addresses', 'address_id', 'source_id')
	UNION ALL
	SELECT * FROM bl_cl.test_keys_presenting('sa_offline_sales.src_offline_sales', 'bl_3nf.ce_categories', 'category_id', 'source_id')
	UNION ALL
	SELECT * FROM bl_cl.test_keys_presenting('sa_offline_sales.src_offline_sales', 'bl_3nf.ce_cities', 'city_id', 'source_id')
	UNION ALL
	SELECT * FROM bl_cl.test_keys_presenting('sa_offline_sales.src_offline_sales', 'bl_3nf.ce_colors', 'color_id', 'source_id')
	--UNION ALL
	--SELECT * FROM bl_cl.test_keys_presenting('sa_offline_sales.src_offline_sales', 'bl_3nf.ce_countries', 'country_id', 'source_id')
	UNION ALL
	SELECT * FROM bl_cl.test_keys_presenting('sa_offline_sales.src_offline_sales', 'bl_3nf.ce_customers', 'customer_id', 'source_id')
	UNION ALL
	SELECT * FROM bl_cl.test_keys_presenting('sa_offline_sales.src_offline_sales', 'bl_3nf.ce_employees', 'employee_id', 'source_id')
	UNION ALL
	SELECT * FROM bl_cl.test_keys_presenting('sa_offline_sales.src_offline_sales', 'bl_3nf.ce_models', 'model_id', 'source_id')
	UNION ALL
	SELECT * FROM bl_cl.test_keys_presenting('sa_offline_sales.src_offline_sales', 'bl_3nf.ce_sales', 'transaction_id', 'source_id')
	UNION ALL
	SELECT * FROM bl_cl.test_keys_presenting('sa_offline_sales.src_offline_sales', 'bl_3nf.ce_shops', 'shop_id', 'source_id')
	UNION ALL
	SELECT * FROM bl_cl.test_keys_presenting('sa_offline_sales.src_offline_sales', 'bl_3nf.ce_states', 'state_id', 'source_id')
	UNION ALL
	SELECT * FROM bl_cl.test_keys_presenting('sa_offline_sales.src_offline_sales', 'bl_3nf.ce_subcategories', 'subcategory_id', 'source_id')
	UNION ALL
	SELECT * FROM bl_cl.test_keys_presenting('sa_offline_sales.src_offline_sales', 'bl_3nf.ce_subcategories', 'subcategory_id', 'source_id')
COMMIT;		
END;$$;

CREATE OR REPLACE PROCEDURE bl_cl.test_business_key_presenting_dm()
LANGUAGE plpgsql
AS $$
BEGIN
	INSERT INTO bl_cl.test_dwh
	(source_table, target_table, test_desc, test_result, test_time)
	SELECT * FROM bl_cl.test_keys_presenting('bl_3nf.ce_products', 'bl_dm.dim_products', 'product_id', 'product_id')
	UNION ALL
	SELECT * FROM bl_cl.test_keys_presenting('bl_3nf.ce_addresses', 'bl_dm.dim_addresses', 'address_id', 'address_id')
	UNION ALL
	SELECT * FROM bl_cl.test_keys_presenting('bl_3nf.ce_categories', 'bl_dm.dim_products', 'category_id', 'product_category_id')
	UNION ALL
	SELECT * FROM bl_cl.test_keys_presenting('bl_3nf.ce_cities', 'bl_dm.dim_addresses', 'city_id', 'city_id')
	UNION ALL
	SELECT * FROM bl_cl.test_keys_presenting('bl_3nf.ce_colors', 'bl_dm.dim_products', 'color_id', 'product_color_id')
	--UNION ALL
	--SELECT * FROM bl_cl.test_keys_presenting('bl_3nf.ce_countries', 'bl_dm.dim_addresses', 'country_id', 'country_id')
	UNION ALL
	SELECT * FROM bl_cl.test_keys_presenting('bl_3nf.ce_customers', 'bl_dm.dim_customers', 'customer_id', 'customer_id')
	UNION ALL
	SELECT * FROM bl_cl.test_keys_presenting('bl_3nf.ce_employees', 'bl_dm.dim_employees', 'employee_id', 'employee_id')
	UNION ALL
	SELECT * FROM bl_cl.test_keys_presenting('bl_3nf.ce_models', 'bl_dm.dim_models', 'model_id', 'model_id')
	UNION ALL
	SELECT * FROM bl_cl.test_keys_presenting('bl_3nf.ce_products', 'bl_dm.dim_products', 'product_id', 'product_id')
	--UNION ALL
	--SELECT * FROM bl_cl.test_keys_presenting('bl_3nf.ce_regions', 'bl_dm.dim_addresses', 'region_id', 'region_id')
	UNION ALL
	SELECT * FROM bl_cl.test_keys_presenting('bl_3nf.ce_sales', 'bl_dm.fct_sales', 'transaction_id', 'transaction_id')
	UNION ALL
	SELECT * FROM bl_cl.test_keys_presenting('bl_3nf.ce_shops', 'bl_dm.dim_shops', 'shop_id', 'shop_id')
	UNION ALL
	SELECT * FROM bl_cl.test_keys_presenting('bl_3nf.ce_states', 'bl_dm.dim_addresses', 'state_id', 'state_id')
	UNION ALL
	SELECT * FROM bl_cl.test_keys_presenting('bl_3nf.ce_subcategories', 'bl_dm.dim_products', 'subcategory_id', 'product_subcategory_id')
COMMIT;		
END;$$;



CREATE OR REPLACE PROCEDURE bl_cl.test_duplication_3nf(

)
LANGUAGE plpgsql
AS $$
DECLARE rec record;
BEGIN
	FOR rec IN SELECT table_schema, table_name
				FROM information_schema.TABLES
				WHERE  table_schema = 'bl_3nf'
				AND table_name <> 'ce_products' AND table_name NOT LIKE '%ce_sales%'
	LOOP
	EXECUTE format (
	'INSERT INTO bl_cl.test_dwh 
	(source_table, target_table, test_desc, test_result, test_time)
	SELECT %L AS source_table, %L AS target_table, %L, count(*), now() AS test_time
	FROM (
		SELECT count(*) AS count_duplicates
		FROM %s 
		GROUP BY source_id , source_system , source_entity
		) AS t 
	WHERE count_duplicates > 1', 'NA', rec.table_schema||'.'||rec.table_name, 'Number of duplications', rec.table_schema||'.'||rec.table_name);
	END LOOP;
	INSERT INTO bl_cl.test_dwh 
	(source_table, target_table, test_desc, test_result, test_time)
	SELECT 'NA' AS source_table, 'bl_3nf.ce_products' AS target_table, 'Number of duplications', count(*), now() AS test_time
	FROM (
		SELECT count(*) AS count_duplicates
		FROM bl_3nf.ce_products 
		GROUP BY source_id , date_start, source_system , source_entity
		) AS t 
	WHERE count_duplicates > 1;
	INSERT INTO bl_cl.test_dwh 
	(source_table, target_table, test_desc, test_result, test_time)
	SELECT 'NA' AS source_table, 'bl_3nf.ce_saless' AS target_table, 'Number of duplications', count(*), now() AS test_time
	FROM (
		SELECT count(*) AS count_duplicates
		FROM bl_3nf.ce_sales 
		GROUP BY source_id , transaction_date, source_system , source_entity
		) AS t 
	WHERE count_duplicates > 1;	
	

COMMIT;		
END;$$;


CREATE OR REPLACE FUNCTION bl_cl.test_duplication(
											_schema_name TEXT,
											_table_name TEXT,
											_column_name TEXT
											)

RETURNS TABLE (
				source_table text, 
				target_table text,
				test_desc text,
				test_result bigint,
				test_time timestamp
				)
AS $$
BEGIN
	RETURN query
	EXECUTE format (
	'SELECT %L AS source_table, %L AS target_table, %L, count(*), now()::TIMESTAMP AS test_time
	FROM (
		SELECT count(*) AS count_duplicates
		FROM %s 
		GROUP BY %s , source_system , source_entity
		) AS t 
	WHERE count_duplicates > 1', 'NA', _schema_name||'.'||_table_name, 'Number of duplications', _schema_name||'.'||_table_name, _column_name);

END
$$ LANGUAGE plpgsql;



CREATE OR REPLACE PROCEDURE bl_cl.test_duplication_dm(

)
LANGUAGE plpgsql
AS $$
DECLARE rec record;
BEGIN
	INSERT INTO bl_cl.test_dwh 
	(source_table, target_table, test_desc, test_result, test_time)
	SELECT * FROM bl_cl.test_duplication('bl_dm', 'dim_customers', 'customer_id')
	UNION ALL
	SELECT * FROM bl_cl.test_duplication('bl_dm', 'dim_employees', 'employee_id')
	UNION ALL
	SELECT * FROM bl_cl.test_duplication('bl_dm', 'dim_models', 'model_id')
	UNION ALL
	SELECT * FROM bl_cl.test_duplication('bl_dm', 'dim_shops', 'shop_id');
	
	--test adresses table which combine addresses and cities
	INSERT INTO bl_cl.test_dwh 
	(source_table, target_table, test_desc, test_result, test_time)
	SELECT 'NA' AS source_table, 'bl_3nf.dim_products' AS target_table, 'Number of duplications', count(*), now() AS test_time
	FROM (
		SELECT count(*) AS count_duplicates
		FROM bl_dm.dim_addresses
		GROUP BY address_id, city_id, source_system , source_entity
		) AS t 
	WHERE count_duplicates > 1;
	
	--test product scd2
	INSERT INTO bl_cl.test_dwh 
	(source_table, target_table, test_desc, test_result, test_time)
	SELECT 'NA' AS source_table, 'bl_3nf.dim_products' AS target_table, 'Number of duplications', count(*), now() AS test_time
	FROM (
		SELECT count(*) AS count_duplicates
		FROM bl_dm.dim_products 
		GROUP BY product_id , start_date, source_system , source_entity
		) AS t 
	WHERE count_duplicates > 1;
	--test fct tables
	INSERT INTO bl_cl.test_dwh 
	(source_table, target_table, test_desc, test_result, test_time)
	SELECT 'NA' AS source_table, 'bl_3nf.ce_saless' AS target_table, 'Number of duplications', count(*), now() AS test_time
	FROM (
		SELECT count(*) AS count_duplicates
		FROM bl_dm.fct_sales 
		GROUP BY transaction_id , time_id, source_system , source_entity
		) AS t 
	WHERE count_duplicates > 1;	
	

COMMIT;		
END;$$;


COMMIT;

