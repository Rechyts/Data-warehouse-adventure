
-- Procedure for cleaning database with old tables
CREATE OR REPLACE PROCEDURE bl_cl.del_old_tables(_name_table_refer text) LANGUAGE plpgsql AS
$$DECLARE
   --define the variables
   c refcursor := 'curs';
   v_schema text;
   v_name text;
BEGIN
   --Create the cursor
   EXECUTE format ('DECLARE curs CURSOR WITH HOLD FOR
              SELECT table_schema, table_name
              FROM information_schema.tables
              WHERE table_name LIKE %L', _name_table_refer);
   LOOP
      FETCH c INTO v_schema, v_name; 
      EXIT WHEN NOT FOUND;
      BEGIN
         EXECUTE format(
                    'DROP TABLE %I.%I',
                    v_schema,
                    v_name
                 );
      EXCEPTION
         WHEN OTHERS THEN
            CLOSE c;
            RAISE;
         WHEN query_canceled THEN
            CLOSE c;
            RAISE;
      END;
      COMMIT;
   END LOOP; 
   -- Close the cursor
   CLOSE c;
END;$$;


--CALL bl_cl.del_old_tables('%old');