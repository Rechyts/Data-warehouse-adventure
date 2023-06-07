CREATE OR REPLACE FUNCTION bl_cl.refresh_materialized_view_load_data()
RETURNS integer
SECURITY DEFINER
AS $$
BEGIN
    REFRESH MATERIALIZED VIEW sa_online_sales.src_online_sales_view;
   	REFRESH MATERIALIZED VIEW sa_offline_sales.src_offline_sales_view;
    RETURN 1;
END;
$$ LANGUAGE plpgsql;

COMMIT;

SELECT * FROM bl_cl.refresh_materialized_view_load_data();