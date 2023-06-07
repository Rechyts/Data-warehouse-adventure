--Test your data

CREATE OR REPLACE PROCEDURE bl_cl.main_test_dwh()
LANGUAGE plpgsql
AS $$
BEGIN

	CALL bl_cl.test_business_key_presenting_3nf();
	CALL bl_cl.test_business_key_presenting_dm();
	CALL bl_cl.test_duplication_3nf();
	CALL bl_cl.test_duplication_dm();

COMMIT;		
END;$$;


COMMIT;
		

