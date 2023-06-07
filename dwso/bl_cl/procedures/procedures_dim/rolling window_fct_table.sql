
CREATE OR REPLACE PROCEDURE bl_cl.rolling_window_2month(schema_name varchar, main_table varchar)
LANGUAGE plpgsql
AS $$
DECLARE 
	start_of_next_month date;
	start_of_current_month date;
	start_of_last_month date;
	partition_name_current_month text;
	partition_name_last_month text;
	main_table_name varchar;
BEGIN
	main_table_name := schema_name||'.'||main_table;
	SELECT * INTO partition_name_current_month FROM BL_CL.get_partition_name('bl_dm', 'fct_sales', (now() - INTERVAL '15 month')::timestamp);
	SELECT * INTO partition_name_last_month  FROM BL_CL.get_partition_name('bl_dm', 'fct_sales', (now() - INTERVAL '16 month')::timestamp);
	start_of_next_month := (to_char((now()-INTERVAL '14 month'),'YYYY-MM') || '-01');
	start_of_current_month := (to_char(now()-INTERVAL '15 month','YYYY-MM') || '-01');
	start_of_last_month := (to_char(now()-INTERVAL '16 month','YYYY-MM') || '-01');
	EXECUTE format('ALTER TABLE %s DETACH PARTITION %s', main_table_name, partition_name_current_month);
	EXECUTE format('ALTER TABLE %s DETACH PARTITION %s', main_table_name, partition_name_last_month);
	EXECUTE format ('TRUNCATE %s', partition_name_current_month);
	EXECUTE format ('TRUNCATE %s', partition_name_last_month);
	CALL bl_cl.load_sales_last_2month_in_partition(partition_name_current_month, start_of_current_month::timestamp, (start_of_next_month - INTERVAL '1 day')::timestamp);
	CALL bl_cl.load_sales_last_2month_in_partition(partition_name_last_month, start_of_last_month::timestamp, (start_of_current_month - INTERVAL '1 day')::timestamp);
	EXECUTE format ('ALTER TABLE %s ATTACH PARTITION %s FOR VALUES FROM (%L::DATE) TO (%L)', main_table_name, partition_name_current_month, start_of_current_month, start_of_next_month);
	EXECUTE format ('ALTER TABLE %s ATTACH PARTITION %s FOR VALUES FROM (%L::DATE) TO (%L)', main_table_name, partition_name_last_month, start_of_last_month, start_of_current_month);
COMMIT;			
END;$$;

COMMIT;




