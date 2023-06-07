CREATE OR REPLACE FUNCTION BL_CL.get_partition_name(schema_name varchar, main_table varchar, _date timestamp)
RETURNS varchar
AS $$
DECLARE
	main_table_name varchar;
	partition_date varchar;
	partition_name varchar;
BEGIN 
	main_table_name := schema_name||'.'||main_table;
	partition_date := to_char(_date,'YYYY_MM');
 	partition_name := main_table_name||'_' || partition_date;
 	RETURN partition_name;
END
$$
LANGUAGE plpgsql;
COMMIT;