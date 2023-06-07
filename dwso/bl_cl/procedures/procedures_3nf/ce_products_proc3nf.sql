-- Fill product table with data
--FIXED: add default values for varchar, integer and date data, previously it was only FK id.

CREATE OR REPLACE PROCEDURE bl_cl.load_products_3nf()
LANGUAGE plpgsql
AS $$
DECLARE
	affect_rows integer;
	affect_rows1 integer;
	affect_rows2 integer;
	log_msg TEXT;
BEGIN
	--Create a sourse table
	DROP TABLE IF EXISTS bl_cl.product_source;
	CREATE TABLE IF NOT EXISTS bl_cl.product_source AS 
	(
		SELECT DISTINCT sos.product_id AS source_id, COALESCE(sos.product_name, 'NA') AS product_name, COALESCE(sos.product_number, 'NA') AS product_number, COALESCE(c.color_id, -1) AS color_id, COALESCE(s.subcategory_id, -1) AS subcategory_id , 'src_online_sales' AS source_system, 'src_online_sales' AS source_entity
			FROM sa_online_sales.src_online_sales_view sos
			LEFT JOIN bl_3nf.ce_subcategories s ON s.source_id = sos.subcategory_id AND s.source_system = 'src_online_sales' AND s.source_entity = 'src_online_sales'
			LEFT JOIN bl_3nf.ce_colors c ON c.source_id = sos.color_id AND c.source_system = 'src_online_sales' AND c.source_entity = 'src_online_sales'
			--WHERE sos.insert_dt = (SELECT max(insert_dt) FROM sa_online_sales.src_online_sales)
		UNION ALL
			SELECT DISTINCT sos2.product_id AS source_id, COALESCE(sos2.product_name, 'NA') AS product_name, COALESCE(sos2.product_number, 'NA') AS product_number, COALESCE(c2.color_id, -1) AS color_id, COALESCE(s2.subcategory_id, -1) AS subcategory_id, 'src_offline_sales' AS source_system, 'src_offline_sales' AS source_entity
			FROM sa_offline_sales.src_offline_sales_view sos2
			LEFT JOIN bl_3nf.ce_subcategories s2 ON s2.source_id = sos2.subcategory_id AND s2.source_system = 'src_offline_sales' AND s2.source_entity = 'src_offline_sales'
			LEFT JOIN bl_3nf.ce_colors c2 ON c2.source_id = sos2.color_id AND c2.source_system = 'src_offline_sales' AND c2.source_entity = 'src_offline_sales'
			--WHERE sos2.insert_dt = (SELECT max(insert_dt) FROM sa_offline_sales.src_offline_sales)
	) ;

	--Insert new products
	INSERT INTO bl_3nf.ce_products
	(source_id, product_name, product_number, color_id, subcategory_id, source_system, source_entity, date_start, date_end, insert_dt)
	SELECT source_id, product_name, product_number, color_id, subcategory_id, source_system, source_entity, '1900-01-01'::TIMESTAMP AS date_start , '9999-12-31'::TIMESTAMP AS date_end , now() AS insert_dt 
	FROM bl_cl.product_source AS p
	WHERE NOT EXISTS (SELECT 1 FROM bl_3nf.ce_products t  WHERE p.source_id=t.source_id AND p.source_system = t.source_system AND p.source_entity = t.source_entity)
	;

	GET DIAGNOSTICS affect_rows1 = row_count;

	--Update existing changing products, disable old record
	WITH update_products AS (
						UPDATE bl_3nf.ce_products AS p
						SET is_active = FALSE
						, date_end = now()
						WHERE
							EXISTS (SELECT 1 FROM bl_cl.product_source t  WHERE p.source_id=t.source_id AND p.source_system = t.source_system AND p.source_entity = t.source_entity)
							AND (p.product_name, p.product_number, p.color_id, p.subcategory_id) <> (SELECT t.product_name, t.product_number, t.color_id, t.subcategory_id FROM bl_cl.product_source t WHERE p.source_id=t.source_id AND p.source_system = t.source_system AND p.source_entity = t.source_entity)
							AND p.is_active = TRUE
						RETURNING *
							)
	--Insert new actual record for existing products
	INSERT INTO bl_3nf.ce_products
	(product_id , source_id, product_name, product_number, color_id, subcategory_id, source_system, source_entity, date_start, date_end, insert_dt)
	SELECT up.product_id, ps.source_id, ps.product_name, ps.product_number, ps.color_id, ps.subcategory_id, ps.source_system, ps.source_entity, now() AS date_start , '9999-12-31' AS date_end, now() AS insert_dt 
	FROM bl_cl.product_source ps JOIN update_products up ON up.source_id = ps.source_id AND up.source_system = ps.source_system AND up.source_entity = ps.source_entity;
		
	GET DIAGNOSTICS affect_rows2 = row_count;
	affect_rows = affect_rows1 + affect_rows2;	
	CALL bl_cl.load_log_data('bl_3nf', 'ce_products', 'success', 'Successfuly insert into ce_products table', affect_rows);
	EXCEPTION
		WHEN OTHERS THEN
			GET STACKED DIAGNOSTICS
				log_msg = message_text;
			CALL bl_cl.load_log_data('bl_3nf', 'ce_products', 'error', log_msg, 0);
		RAISE NOTICE 'some other error: %', sqlerrm;
		COMMIT;

	
END;$$;

COMMIT;