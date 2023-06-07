--Create a procedure for logging data loading into a 3NF schema
CREATE TABLE IF NOT EXISTS bl_cl.log_table (
	id serial PRIMARY KEY,
    schemaname text,
    tabname text,
    log_flag varchar(7),
    log_msg TEXT,
    affect_rows integer,
    user_name text DEFAULT current_user,
    insert_dt timestamp DEFAULT now(),
    affected_ids integer[]

);


CREATE OR REPLACE PROCEDURE bl_cl.load_log_data(_schemaname TEXT, _tabname TEXT , _log_flag varchar(7), _log_msg TEXT, _affect_rows integer, _affected_ids integer[])
LANGUAGE plpgsql
AS $$

BEGIN
	
	INSERT INTO bl_cl.log_table
	(schemaname, tabname, log_flag, log_msg, affect_rows, affected_ids)
	VALUES (_schemaname, _tabname, _log_flag,  _log_msg, _affect_rows, _affected_ids);

END;$$;


COMMIT;



