CREATE OR REPLACE PROCEDURE bl_cl.load_models_dim()
LANGUAGE plpgsql
AS $$
DECLARE
	log_msg TEXT;
	_var type_for_log_table;
BEGIN
	WITH insert_rows AS (	
		INSERT INTO bl_dm.dim_models AS dc
		(model_id, model_name, model_desc, source_system, source_entity, insert_dt)
		SELECT CAST(c.model_id AS varchar) AS model_id, c.model_name , c.model_desc, c.source_system , c.source_entity, now() AS insert_dt 
		FROM bl_3nf.ce_models c
		WHERE c.model_id <> -1
		ON CONFLICT(model_id, source_system, source_entity) DO UPDATE 
		SET (model_id,model_name, model_desc, update_dt) =
		ROW (excluded.model_id, excluded.model_name, excluded.model_desc, now())
		WHERE md5(CONCAT(dc.model_id, dc.model_name, dc.model_desc))
		IS DISTINCT FROM md5(CONCAT(excluded.model_id, excluded.model_name, excluded.model_desc))
		RETURNING model_surr_id
	)
	SELECT array_agg(model_surr_id), count(*) INTO _var
	FROM insert_rows;

	--GET DIAGNOSTICS affect_rows = row_count;
	CALL bl_cl.load_log_data('bl_dm', 'dim_models', 'success', 'Successfuly insert into dim_models table', _var.affect_rows, _var.updated_ids);
	EXCEPTION
	WHEN OTHERS THEN
		GET STACKED DIAGNOSTICS
			log_msg = message_text;
		CALL bl_cl.load_log_data('bl_dm', 'dim_models', 'error', log_msg, 0, NULL);
	RAISE NOTICE 'some other error: %', sqlerrm;
COMMIT;

END;$$;

COMMIT;