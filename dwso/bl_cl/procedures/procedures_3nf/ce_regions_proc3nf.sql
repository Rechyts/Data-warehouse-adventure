/*Insert into 3NF tables data from data staging with it processing*/
--FIXED: add default values for varchar, integer and date data, previously it was only FK id.
-- The business does not have information on the regions, but would like to. This can simplify reporting by region and make it more visible.
-- We agreed that we keep lists of regions in accordance with the ISO standard
-- We do not delete data on regions, we only accumulate and update it.

-- Insert data about regions from iso table


CREATE OR REPLACE PROCEDURE bl_cl.load_regions_3nf()
LANGUAGE plpgsql
AS $$
DECLARE
	--affect_rows integer;
	log_msg TEXT;
	_var type_for_log_table;
BEGIN
	WITH insert_rows AS (
		INSERT INTO bl_3nf.ce_regions AS rs
		(source_id, region_name, source_system, source_entity, insert_dt)
		SELECT COALESCE(CAST(r.child_code AS varchar), 'NA') AS source_id, COALESCE(r.structure_desc, 'NA') AS region_name, 'src_offline_sales' AS source_system, 'src_geo_structure_iso3166' AS source_entity, now()
		FROM sa_offline_sales.src_geo_structure_iso3166 r
		WHERE r.structure_level = 'Regions' AND r.insert_dt = (SELECT max(insert_dt) FROM sa_offline_sales.src_geo_structure_iso3166)
		ON CONFLICT(source_id, source_system, source_entity) 
		DO UPDATE SET 
		(region_name, update_dt) = (excluded.region_name, now())
		WHERE rs.region_name IS DISTINCT FROM excluded.region_name
		RETURNING region_id
		)
		
	SELECT array_agg(region_id), count(*) INTO _var
		FROM insert_rows;
	--GET DIAGNOSTICS affect_rows = row_count;
	CALL bl_cl.load_log_data('bl_3nf', 'ce_regions', 'success', 'Successfuly insert into ce_regions table', _var.affect_rows, _var.updated_ids);
	EXCEPTION
		WHEN OTHERS THEN
			GET STACKED DIAGNOSTICS
				log_msg = message_text;
			CALL bl_cl.load_log_data('bl_3nf', 'ce_regions', 'error', log_msg, 0, NULL);
		RAISE NOTICE 'some other error: %', sqlerrm;
		COMMIT;

END;$$;


COMMIT;