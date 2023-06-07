
CREATE OR REPLACE FUNCTION bl_cl.grant_all_privileges_on_database_to_role(
    role_name TEXT,
    database_name TEXT,
    table_name_3nf TEXT,
    table_name_dm TEXT,
    schemas_list varchar[]
)
    RETURNS void
    LANGUAGE plpgsql AS
$$
DECLARE 
   schema_name varchar ;
BEGIN
	EXECUTE format ('CREATE ROLE %s', role_name);
	EXECUTE format ('GRANT CONNECT ON DATABASE %s TO %s', database_name, role_name);
-- make the cleansing role of the owner of the ce_sales table in order to be able to automatically create partitions using the bl_cl.create_sales_partitions procedure
	EXECUTE format('ALTER TABLE %s OWNER TO %s', table_name_3nf, role_name); 
	EXECUTE format('ALTER TABLE %s OWNER TO %s', table_name_dm, role_name);
	EXECUTE format('ALTER TABLE sa_offline_sales.src_offline_sales_view OWNER TO %s', role_name);
	EXECUTE format('ALTER TABLE sa_online_sales.src_online_sales_view OWNER TO %s', role_name); 
   
FOREACH schema_name IN ARRAY schemas_list
	LOOP
		EXECUTE format ('GRANT USAGE, CREATE ON SCHEMA %s TO %s', schema_name, role_name);
		EXECUTE format ('GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA %s TO %s', schema_name, role_name);
	    EXECUTE format ('GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA %s TO %s', schema_name, role_name);
		--EXECUTE format ('GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA %s TO %s', schema_name, role_name);
		--EXECUTE format ('ALTER DEFAULT PRIVILEGES IN SCHEMA %s GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO %s', schema_name, role_name);
	    EXECUTE format('ALTER DEFAULT PRIVILEGES IN SCHEMA %s GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE, REFERENCES, TRIGGER ON TABLES TO %s', schema_name, role_name);
	    EXECUTE format('GRANT USAGE ON ALL SEQUENCES IN SCHEMA %s TO %s', schema_name, role_name);
	    EXECUTE format('ALTER DEFAULT PRIVILEGES IN SCHEMA %s GRANT USAGE ON SEQUENCES TO %s',schema_name, role_name);   
    END LOOP;
	EXCEPTION WHEN duplicate_object THEN RAISE NOTICE '%, skipping', SQLERRM USING ERRCODE = SQLSTATE;
END;
$$;

CREATE OR REPLACE FUNCTION bl_cl.create_user(
	user_name TEXT,
	user_password TEXT,
	role_name TEXT
)
    RETURNS void
    LANGUAGE plpgsql AS
$$

BEGIN
	EXECUTE format('CREATE USER %1$s WITH PASSWORD %2$L', user_name, user_password);
	EXECUTE format('GRANT %s TO %s', role_name, user_name);
	EXCEPTION WHEN duplicate_object THEN RAISE NOTICE '%, skipping', SQLERRM USING ERRCODE = SQLSTATE;
END
$$;


SELECT * FROM bl_cl.grant_all_privileges_on_database_to_role('cleansing2', 'adventure', 'bl_3nf.ce_sales', 'bl_dm.fct_sales', ARRAY['bl_cl', 'sa_offline_sales', 'sa_online_sales', 'bl_3nf', 'bl_dm']);
SELECT * FROM bl_cl.create_user('adv_dev1', '12345678', 'cleansing2');
