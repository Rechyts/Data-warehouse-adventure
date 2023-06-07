--Fill data in dim_dates table for 2021-2025 years


CREATE OR REPLACE PROCEDURE bl_cl.load_dates_dim(start_date varchar, number_days integer)
LANGUAGE plpgsql
AS $$
DECLARE
	log_msg TEXT;
	_var type_for_log_table;
BEGIN
	WITH insert_rows AS (
		INSERT INTO bl_dm.dim_dates
		SELECT 
				--TO_CHAR(datum, 'yyyymmdd')::INT AS date_id,
		       datum AS date_id,
		       TO_CHAR(datum, 'fmDDth') AS day_suffix,
		       TO_CHAR(datum, 'TMDay') AS day_name,
		       EXTRACT(ISODOW FROM datum) AS day_of_week,
		       EXTRACT(DAY FROM datum) AS day_of_month,
		       datum - DATE_TRUNC('quarter', datum)::DATE + 1 AS day_of_quarter,
		       EXTRACT(DOY FROM datum) AS day_of_year,
		       TO_CHAR(datum, 'W')::INT AS week_of_month,
		       EXTRACT(WEEK FROM datum) AS week_of_year,
		       EXTRACT(MONTH FROM datum) AS month_actual,
		       TO_CHAR(datum, 'TMMonth') AS month_name,
		       TO_CHAR(datum, 'Mon') AS month_name_abbreviated,
		       EXTRACT(QUARTER FROM datum) AS quarter_actual,
		       CASE
		           WHEN EXTRACT(QUARTER FROM datum) = 1 THEN 'First'
		           WHEN EXTRACT(QUARTER FROM datum) = 2 THEN 'Second'
		           WHEN EXTRACT(QUARTER FROM datum) = 3 THEN 'Third'
		           WHEN EXTRACT(QUARTER FROM datum) = 4 THEN 'Fourth'
		           END AS quarter_name,
		       EXTRACT(YEAR FROM datum) AS year_actual,
		       datum + (1 - EXTRACT(ISODOW FROM datum))::INT AS first_day_of_week,
		       datum + (7 - EXTRACT(ISODOW FROM datum))::INT AS last_day_of_week,
		       datum + (1 - EXTRACT(DAY FROM datum))::INT AS first_day_of_month,
		       (DATE_TRUNC('MONTH', datum) + INTERVAL '1 MONTH - 1 day')::DATE AS last_day_of_month,
		       DATE_TRUNC('quarter', datum)::DATE AS first_day_of_quarter,
		       (DATE_TRUNC('quarter', datum) + INTERVAL '3 MONTH - 1 day')::DATE AS last_day_of_quarter,
		       TO_DATE(EXTRACT(YEAR FROM datum) || '-01-01', 'YYYY-MM-DD') AS first_day_of_year,
		       TO_DATE(EXTRACT(YEAR FROM datum) || '-12-31', 'YYYY-MM-DD') AS last_day_of_year,
		       CASE
		           WHEN EXTRACT(ISODOW FROM datum) IN (6, 7) THEN TRUE
		           ELSE FALSE
		           END AS weekend
		FROM (SELECT start_date::DATE + SEQUENCE.DAY AS datum
		      FROM GENERATE_SERIES(0, number_days) AS SEQUENCE (DAY)
		      GROUP BY SEQUENCE.DAY) DQ
		ORDER BY 1
		ON CONFLICT DO NOTHING
		RETURNING date_id
		)
		
	SELECT array_agg(TO_CHAR(date_id, 'yyyymmdd')::INT), count(*) INTO _var
		FROM insert_rows;
	
		CALL bl_cl.load_log_data('bl_dm', 'dim_dates', 'success', 'Successfuly insert into dim_dates table', _var.affect_rows, _var.updated_ids);
		EXCEPTION
		WHEN OTHERS THEN
			GET STACKED DIAGNOSTICS
				log_msg = message_text;
			CALL bl_cl.load_log_data('bl_dm', 'dim_dates', 'error', log_msg, 0, NULL);
		RAISE NOTICE 'some other error: %', sqlerrm;
	COMMIT;

END;$$;

COMMIT;
