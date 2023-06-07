CREATE OR REPLACE PROCEDURE bl_cl.load_products_dim()
 LANGUAGE plpgsql
AS $$
DECLARE
	log_msg TEXT;
	_var type_for_log_table;
BEGIN
	WITH insert_rows AS (	
		INSERT INTO bl_dm.dim_products AS dc
		(product_id, product_name, product_number, product_subcategory_id , product_subcategory_name, product_category_id , product_category_name, product_color_id, product_color_name , source_system, source_entity, insert_dt, start_date, end_date, is_active)
		SELECT CAST(c.product_id AS varchar) AS  product_id, c.product_name , c.product_number , CAST(c.subcategory_id AS varchar) AS product_subcategory_id , s.subcategory_name AS product_subcategory_name, CAST(s.category_id AS varchar) AS category_id , ca.category_name AS product_category_name, CAST(cl.color_id AS varchar) AS product_color_id , cl.color_name AS product_color_name , c.source_system , c.source_entity, now() AS insert_dt, c.date_start , c.date_end, c.is_active  
		FROM bl_3nf.ce_products c
		LEFT JOIN bl_3nf.ce_subcategories AS s ON s.subcategory_id = c.subcategory_id AND s.source_system = c.source_system AND s.source_system = c.source_entity 
		LEFT JOIN bl_3nf.ce_categories AS ca ON ca.category_id  = s.category_id AND ca.source_system = s.source_system AND ca.source_entity = s.source_entity 
		LEFT JOIN bl_3nf.ce_colors cl ON cl.color_id = c.color_id AND cl.source_system = c.source_system AND cl.source_entity = c.source_entity 
		WHERE c.product_id <> -1
		ON CONFLICT(product_id, start_date, source_system, source_entity) DO UPDATE 
		SET (product_name, product_subcategory_id , product_subcategory_name, product_category_id , product_category_name, product_color_id , product_color_name , end_date, is_active , update_dt) =
		ROW (excluded.product_name, excluded.product_subcategory_id , excluded.product_subcategory_name, excluded.product_category_id , excluded.product_category_name, excluded.product_color_id , excluded.product_color_name, excluded.end_date, excluded.is_active, now())
		WHERE md5(CONCAT(dc.product_id, dc.product_name, dc.product_subcategory_id , dc.product_subcategory_name, dc.product_category_id , dc.product_category_name, dc.product_color_id , dc.product_color_name , CAST(dc.end_date AS varchar), CAST(dc.is_active AS varchar), CAST(dc.start_date AS varchar), dc.source_system, dc.source_entity)) 
		IS DISTINCT FROM md5(CONCAT(excluded.product_id, excluded.product_name, excluded.product_subcategory_id , excluded.product_subcategory_name, excluded.product_category_id , excluded.product_category_name,  excluded.product_color_id , excluded.product_color_name, CAST(excluded.end_date AS varchar), CAST(excluded.is_active AS varchar), CAST(excluded.start_date AS varchar), excluded.source_system, excluded.source_entity))
		RETURNING product_surr_id
	)
	SELECT array_agg(product_surr_id), count(*) INTO _var
	FROM insert_rows;

	--GET DIAGNOSTICS affect_rows = row_count;
	CALL bl_cl.load_log_data('bl_dm', 'dim_products', 'success', 'Successfuly insert into dim_products table', _var.affect_rows, _var.updated_ids);
	EXCEPTION
	WHEN OTHERS THEN
		GET STACKED DIAGNOSTICS
			log_msg = message_text;
		CALL bl_cl.load_log_data('bl_dm', 'dim_products', 'error', log_msg, 0, NULL);
	RAISE NOTICE 'some other error: %', sqlerrm;
COMMIT;

END;$$
;

COMMIT;
