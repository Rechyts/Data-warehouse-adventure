--For sales tables create a function for automaticaly create partitions
--Function for creation a partion for month by input date
CREATE OR REPLACE FUNCTION bl_cl.create_sales_partition_by_date(month_date TIMESTAMP, schema_name TEXT, main_table TEXT)
RETURNS int AS $$
DECLARE
	main_table_name TEXT;
	partition_date TEXT;
	partition_name TEXT;
	start_of_month TEXT;
	end_of_next_month TEXT;
BEGIN
	main_table_name := schema_name||'.'||main_table;
	partition_date := to_char(month_date,'YYYY_MM');
 	partition_name := main_table_name||'_' || partition_date;
	start_of_month := to_char(month_date,'YYYY-MM') || '-01';
	end_of_next_month := to_char((month_date + interval '1 month'),'YYYY-MM') || '-01';
IF NOT EXISTS
	(SELECT 1
   	 FROM  information_schema.tables 
   	 WHERE schema_name||'.'||table_name = partition_name) 
THEN
	EXECUTE format('CREATE TABLE %s PARTITION OF %s FOR VALUES FROM (%L::DATE) TO (%L::DATE);', partition_name, main_table_name, start_of_month, end_of_next_month);
	RAISE NOTICE 'A partition has been created %', partition_name;
ELSE
	RAISE NOTICE 'Not created %', partition_name;
END IF;
RETURN 1;
END
$$
LANGUAGE plpgsql;
COMMIT;

--It's alternative to get list of month for which we want to create partitions
--Function for geting a list of transaction dates from source tables
--CREATE OR REPLACE FUNCTION bl_cl.list_of_date(_tbl1 regclass, _tbl2 regclass)
--RETURNS TABLE (
--			transaction_date timestamp
--) LANGUAGE plpgsql AS
--$$
--BEGIN
--	RETURN query
--    EXECUTE format('SELECT CAST(transaction_date as timestamp) as transaction_date
--					FROM %s sos
--				UNION 
--					SELECT CAST(transaction_date as timestamp) as transaction_date
--					FROM %s sos', _tbl1, _tbl2);
--END
--$$;
--COMMIT;



--Procedure for creation partions for a number of month from start date
CREATE OR REPLACE PROCEDURE bl_cl.create_sales_partitions(schema_name TEXT, main_table TEXT, _start_date TIMESTAMP, _number_of_month integer)
AS $$
DECLARE
	v_record record;
BEGIN
	FOR v_record IN (SELECT _start_date + (dates*interval '1 month') AS month_date
						FROM generate_series(0,_number_of_month,1) dates)
LOOP
	PERFORM bl_cl.create_sales_partition_by_date(CAST(v_record.month_date AS TIMESTAMP), schema_name, main_table);
END LOOP;
END;
$$ LANGUAGE plpgsql;

COMMIT;