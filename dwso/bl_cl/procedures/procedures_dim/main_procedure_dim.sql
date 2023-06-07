
CREATE OR REPLACE PROCEDURE bl_cl.main_procedure_dm()
LANGUAGE plpgsql
AS $$
BEGIN
	CALL bl_cl.load_dates_dim('2020-01-01', 2100);
	CALL bl_cl.load_addresses_dim();
	CALL bl_cl.load_customers_dim();
	CALL bl_cl.load_employees_dim();
	CALL bl_cl.load_models_dim();
	CALL bl_cl.load_products_dim();
	CALL bl_cl.load_shops_dim();
	CALL bl_cl.load_sales_dim(); -- full load sales data
	CALL bl_cl.rolling_window_2month('bl_dm', 'fct_sales'); -- incremental LOAD sales DATA FOR the LAST two month
COMMIT;		
END;$$;


COMMIT;


