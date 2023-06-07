
DROP TYPE IF EXISTS type_for_log_table;
CREATE TYPE type_for_log_table AS (updated_ids integer[], affect_rows integer);

CREATE OR REPLACE PROCEDURE bl_cl.load_addresses_dim()
LANGUAGE plpgsql
AS $$
DECLARE
	log_msg TEXT;
	_var type_for_log_table;
BEGIN
	WITH insert_rows AS (
		INSERT INTO bl_dm.dim_addresses AS a
		(address_id, address_line1, address_line2, postal_code, city_id, city_name, state_id, state_name, state_code, country_id, country_name, country_code, region_id, region_name, source_system, source_entity, insert_dt)
		SELECT CAST(ca.address_id AS varchar) AS address_id, ca.address_line1 , ca.address_line2 , ca.postal_code , CAST(ca.city_id AS varchar) AS city_id, cc.city_name , CAST(cc.state_id AS varchar) AS  state_id, cs.state_name , cs.state_code 
		, CAST(cs.country_id AS varchar) AS country_id, cc2.country_name , cc2.country_code , CAST(cc2.region_id AS varchar) AS region_id, cr.region_name , ca.source_system , ca.source_entity, now() AS insert_dt
		FROM bl_3nf.ce_addresses ca
		LEFT JOIN bl_3nf.ce_cities cc ON ca.city_id = cc.city_id AND ca.source_system = cc.source_system AND ca.source_entity = cc.source_entity 
		LEFT JOIN bl_3nf.ce_states cs ON cs.state_id = cc.state_id AND cs.source_system = cc.source_system AND cs.source_entity = cc.source_entity 
		LEFT JOIN bl_3nf.ce_countries cc2 ON cc2.country_id = cs.country_id
		LEFT JOIN bl_3nf.ce_regions cr ON cr.region_id = cc2.region_id
		WHERE ca.address_id <> -1
		UNION ALL
		SELECT '-1' AS address_id, 'NA' AS address_line1, 'NA' AS address_line2, 'NA' AS postal_code, CAST(cc.city_id AS varchar) AS city_id, cc.city_name , CAST(cc.state_id AS varchar) AS state_id , cs.state_name , cs.state_code
		, CAST(cs.country_id AS varchar) AS country_id, cc2.country_name , cc2.country_code , CAST(cc2.region_id AS varchar) AS region_id, cr.region_name , cc.source_system , cc.source_entity, now() AS insert_dt
		FROM bl_3nf.ce_cities cc
		LEFT JOIN bl_3nf.ce_states cs ON cs.state_id = cc.state_id AND cs.source_system = cc.source_system AND cs.source_entity = cc.source_entity 
		LEFT JOIN bl_3nf.ce_countries cc2 ON cc2.country_id = cs.country_id
		LEFT JOIN bl_3nf.ce_regions cr ON cr.region_id = cc2.region_id
		WHERE cc.city_id <> -1
		ON CONFLICT(address_id, city_id, source_system, source_entity) DO UPDATE 
		SET (address_id, address_line1, address_line2, postal_code, city_id, city_name, state_id, state_name, state_code, country_id, country_name, country_code, region_id, region_name, update_dt) = 
		ROW (excluded.address_id, excluded.address_line1, excluded.address_line2, excluded.postal_code, excluded.city_id, excluded.city_name, excluded.state_id, excluded.state_name, excluded.state_code, excluded.country_id, excluded.country_name, excluded.country_code, excluded.region_id, excluded.region_name, now())
		-- ROW syntax
		WHERE md5(CONCAT(a.address_id, a.address_line1, a.address_line2, a.postal_code, a.city_id, a.city_name, a.state_id, a.state_name, a.state_code, a.country_id, a.country_name, a.country_code, a.region_id, a.region_name)) IS DISTINCT FROM md5(CONCAT(excluded.address_id, excluded.address_line1, excluded.address_line2, excluded.postal_code, excluded.city_id, excluded.city_name, excluded.state_id, excluded.state_name, excluded.state_code, excluded.country_id, excluded.country_name, excluded.country_code, excluded.region_id, excluded.region_name)) 
		RETURNING address_surr_id
	)
	
	SELECT array_agg(address_surr_id), count(*) INTO _var
	FROM insert_rows;

	--GET DIAGNOSTICS affect_rows = row_count;
	CALL bl_cl.load_log_data('bl_dm', 'dim_addresses', 'success', 'Successfuly insert into dim_addresses table', _var.affect_rows, _var.updated_ids);
	EXCEPTION
	WHEN OTHERS THEN
		GET STACKED DIAGNOSTICS
			log_msg = message_text;
		CALL bl_cl.load_log_data('bl_dm', 'dim_addresses', 'error', log_msg, 0, NULL);
	RAISE NOTICE 'some other error: %', sqlerrm;
COMMIT;

END;$$;

COMMIT;


