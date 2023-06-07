--Create partitions for sales for 3NF schema


CREATE OR REPLACE PROCEDURE bl_cl.main_procedure_3nf()
LANGUAGE plpgsql
AS $$
BEGIN
	CALL bl_cl.load_regions_3nf();
	CALL bl_cl.load_countries_3nf();
	CALL bl_cl.load_states_3nf();
	CALL bl_cl.load_cities_3nf();
	CALL bl_cl.load_addresses_3nf();
	CALL bl_cl.load_categories_3nf();
	CALL bl_cl.load_subcategories_3nf();
	CALL bl_cl.load_colors_3nf();
	CALL bl_cl.load_products_3nf_scd2_v2(); --WITH late arrived records
	--CALL bl_cl.load_products_3nf_scd2(); based on transaction date
	--CALL bl_cl.load_products_3nf(); -- based on current date
	CALL bl_cl.load_models_3nf();
	CALL bl_cl.load_customers_3nf();
	CALL bl_cl.load_shops_3nf();
	CALL bl_cl.load_employees_3nf();
	CALL bl_cl.load_sales_3nf();
	CALL bl_cl.update_load_table('bl_cl.main_procedure_3nf');


COMMIT;		
END;$$;


COMMIT;