

CREATE OR REPLACE PROCEDURE bl_cl.load_products_3nf_scd2()
LANGUAGE plpgsql
AS $$
DECLARE
    one_record RECORD;
    single_id integer;
	affect_rows1 integer;
	affect_rows2 integer;
	log_msg TEXT;
	_var type_for_log_table;
BEGIN
	_var.affect_rows := 0;
	CALL bl_cl.load_work_products();
    FOR one_record in SELECT * from bl_cl.work_products ps ORDER BY ps.transaction_date 
    LOOP
    	INSERT INTO bl_3nf.ce_products
		(source_id, product_name, product_number, color_id, subcategory_id, source_system, source_entity, date_start, date_end, insert_dt)
		SELECT one_record.source_id, one_record.product_name, one_record.product_number, one_record.color_id, one_record.subcategory_id, one_record.source_system, one_record.source_entity, '1900-01-01'::TIMESTAMP , '9999-12-31'::TIMESTAMP, now()	
		WHERE NOT EXISTS (SELECT 1 FROM bl_3nf.ce_products t  WHERE one_record.source_id=t.source_id AND one_record.source_system = t.source_system AND one_record.source_entity = t.source_entity)
		RETURNING product_id INTO single_id
		;
		IF single_id IS NOT NULL THEN
			_var.updated_ids = array_append(_var.updated_ids, single_id);
		END IF;
		GET DIAGNOSTICS affect_rows1 = row_count;
		_var.affect_rows = _var.affect_rows + affect_rows1;
		WITH update_products AS (
						UPDATE bl_3nf.ce_products AS p
						SET is_active = FALSE
						,date_end = one_record.transaction_date
						WHERE
								EXISTS (SELECT 1 WHERE p.source_id=one_record.source_id AND p.source_system = one_record.source_system AND p.source_entity = one_record.source_entity)
								AND (p.product_name, p.product_number, p.color_id, p.subcategory_id) <> (SELECT one_record.product_name, one_record.product_number, one_record.color_id, one_record.subcategory_id)
								AND p.is_active = TRUE AND p.date_start < one_record.transaction_date
						RETURNING *
							)
		--Insert new actual record for existing products
		INSERT INTO bl_3nf.ce_products
		(product_id , source_id, product_name, product_number, color_id, subcategory_id, source_system, source_entity, date_start, date_end, insert_dt)
		SELECT up.product_id, one_record.source_id, one_record.product_name, one_record.product_number, one_record.color_id, one_record.subcategory_id, one_record.source_system, one_record.source_entity, one_record.transaction_date AS date_start , '9999-12-31' AS date_end, now() AS insert_dt 
		FROM update_products up
		RETURNING product_id INTO single_id
		;
		IF single_id IS NOT NULL THEN
			_var.updated_ids = array_append(_var.updated_ids, single_id);
		END IF;
		GET DIAGNOSTICS affect_rows2 = row_count;
		_var.affect_rows = _var.affect_rows + affect_rows2;
		END LOOP;
	
	CALL bl_cl.load_log_data('bl_3nf', 'ce_products', 'success', 'Successfuly insert into ce_products table', _var.affect_rows, _var.updated_ids);
	EXCEPTION
		WHEN OTHERS THEN
			GET STACKED DIAGNOSTICS
				log_msg = message_text;
			CALL bl_cl.load_log_data('bl_3nf', 'ce_products', 'error', log_msg, 0, NULL);
		RAISE NOTICE 'some other error: %', sqlerrm;
		COMMIT;
END;
$$;




	
