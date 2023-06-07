CREATE TABLE IF NOT EXISTS bl_cl.load_data
(
id serial PRIMARY KEY,
procedure_name varchar,
load_time timestamp DEFAULT now()
)
;

CREATE OR REPLACE PROCEDURE bl_cl.update_load_table(_procedure_name varchar)
LANGUAGE plpgsql
AS $$

BEGIN
	
	INSERT INTO bl_cl.load_data
	(procedure_name, load_time)
	VALUES (_procedure_name, now());
COMMIT;
END;$$;


COMMIT;

INSERT INTO bl_cl.load_data
(procedure_name, load_time)
VALUES ('bl_cl.main_procedure_3nf', '1900-01-01'::TIMESTAMP);
COMMIT;