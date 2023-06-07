
-- We have full list of countries and updated it from iso standart

CREATE OR REPLACE PROCEDURE bl_cl.load_countries_3nf()
LANGUAGE plpgsql
AS $$
DECLARE
	_var type_for_log_table;
	log_msg TEXT;
BEGIN
	--Deduplication countries by match iso countries and source 
	CALL bl_cl.match_iso_countries_and_sourcies();
	WITH insert_rows AS (
		INSERT INTO bl_3nf.ce_countries AS ct
		(source_id, country_name, country_code,  source_system, source_entity, region_id, insert_dt)
		SELECT CAST(c.country_id AS varchar) AS source_id, COALESCE(c.country_desc, 'NA') AS country_name, c.country_code , (SELECT table_schema FROM information_schema.tables WHERE  table_name = 'src_geo_countries_iso3166') AS source_system , 'src_geo_countries_iso3166' AS source_entity, COALESCE(r.region_id, -1) AS region_id, now() AS insert_dt
		FROM sa_offline_sales.src_geo_countries_iso3166 c
		LEFT JOIN sa_offline_sales.src_geo_countries_structure_iso3166 cs ON cs.country_id = c.country_id AND cs.insert_dt = (SELECT max(insert_dt) FROM sa_offline_sales.src_geo_countries_structure_iso3166)
		LEFT JOIN bl_3nf.ce_regions r ON r.source_id = cs.structure_code 
		WHERE c.insert_dt = (SELECT max(insert_dt) FROM sa_offline_sales.src_geo_countries_iso3166)
		ON CONFLICT(source_id, source_system, source_entity) 
		DO UPDATE SET 
		(country_name, country_code, region_id, update_dt) = (excluded.country_name, excluded.country_code, excluded.region_id, now())
		WHERE ct.country_name IS DISTINCT FROM excluded.country_name OR
		ct.country_code IS DISTINCT FROM excluded.country_code OR
		ct.region_id IS DISTINCT FROM excluded.region_id
		RETURNING country_id
		)
	
	SELECT array_agg(country_id), count(*) INTO _var
		FROM insert_rows;
	
	CALL bl_cl.load_log_data('bl_3nf', 'ce_countries', 'success', 'Successfuly insert into ce_countries table', _var.affect_rows, _var.updated_ids);
	EXCEPTION
		WHEN OTHERS THEN
			GET STACKED DIAGNOSTICS
				log_msg = message_text;
			CALL bl_cl.load_log_data('bl_3nf', 'ce_countries', 'error', log_msg, 0);
		RAISE NOTICE 'some other error: %', sqlerrm;
		COMMIT;
END;$$;

COMMIT;

