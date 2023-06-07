 -- FOR work/cleansing tables

--After agreeing with the business that we do not want to have duplicates for countries from several sources,
-- we agreed to use data from the standard iso3166

--We have USA and Great Britain in source data that does not match with iso data, make updated by using CASE statement (I am not sure about this solution)
--Create separate table for matching information about countries from different sources and ISO standard.
-- This table created for matching states from both sources with new country code from iso standard

--FIXED: Trancate table instead of droping it. 

CREATE OR REPLACE PROCEDURE bl_cl.match_iso_countries_and_sourcies()
LANGUAGE plpgsql
AS $$

BEGIN
	
	CREATE TABLE IF NOT EXISTS bl_cl.temp_union_iso_countries_sourcies(
	country_id serial PRIMARY KEY,
	country_iso_id varchar(255),
	source_id varchar(255),
	country_desc varchar(255),
	country_code varchar(255),
	source_system varchar(255),
	source_entity varchar(255)	
	);

	TRUNCATE table bl_cl.temp_union_iso_countries_sourcies;

	INSERT INTO bl_cl.temp_union_iso_countries_sourcies
	(country_iso_id, source_id, country_desc, country_code, source_system, source_entity)
	SELECT sgci.country_id AS country_iso_id, t.country_id AS source_id, sgci.country_desc, sgci.country_code, t.source_system, t.source_entity
	FROM (
	-- Select countries from online source
		SELECT country_id, country_name, country_code, 'src_online_sales' AS source_system, 'src_online_sales' AS source_entity
		FROM (
			SELECT sos.country_id ,
			-- Correct unmatched data from sourcies ans iso standart
			CASE 
				WHEN sos.country IN ('Great Britain', 'GB', 'England', 'Anglia', 'United Kingdom') THEN 'United Kingdom of Great Britain and Northern Ireland'
				WHEN sos.country IN ('US', 'USA', 'Amerika', 'States') THEN 'United States of America'
				ELSE sos.country
			END AS country_name, 
			sos.country_code
			-- From source data we need to take the most recent information about country, because it can happend that country name, code have been changed a few times.
			-- Country table has SCD-1 type and we don't have a separate column with updating time for countries in our source data.
			-- We will take information about countries from the last transaction for a particular country.
			,ROW_NUMBER () OVER(PARTITION BY sos.country_id ORDER BY CAST(sos.transaction_date AS timestamp) DESC ) AS number_row
			FROM sa_online_sales.src_online_sales sos
			WHERE sos.insert_dt = (SELECT max(insert_dt) FROM sa_online_sales.src_online_sales)
			) AS p
		WHERE number_row=1
	UNION ALL
	--Select countries from offline source
		SELECT country_id, country_name, country_code, 'src_offline_sales' AS source_system, 'src_offline_sales' AS source_entity
		FROM (
			SELECT sos2.country_id ,
			-- Correct unmatched data from sourcies ans iso standart
			CASE 
				WHEN sos2.country IN ('Great Britain', 'GB', 'England', 'Anglia', 'United Kingdom') THEN 'United Kingdom of Great Britain and Northern Ireland'
				WHEN sos2.country IN ('US', 'USA', 'Amerika', 'States') THEN 'United States of America'
				ELSE sos2.country
			END AS country_name, 
			sos2.country_code
			,ROW_NUMBER () OVER(PARTITION BY sos2.country_id ORDER BY CAST(sos2.transaction_date AS timestamp) DESC ) AS number_row
			FROM sa_offline_sales.src_offline_sales sos2
			WHERE sos2.insert_dt = (SELECT max(insert_dt) FROM sa_offline_sales.src_offline_sales)
			) AS p2
		WHERE number_row=1
		) AS t
	-- Join this data with ISO standart data
	LEFT JOIN sa_offline_sales.src_geo_countries_iso3166 sgci ON lower(t.country_name) = lower(sgci.country_desc) AND sgci.insert_dt = (SELECT max(insert_dt) FROM sa_offline_sales.src_geo_countries_iso3166)
	;
	

END;$$;

COMMIT;
