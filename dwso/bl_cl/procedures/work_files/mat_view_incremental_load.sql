
CREATE MATERIALIZED VIEW IF NOT EXISTS sa_online_sales.src_online_sales_view
AS
SELECT transaction_id,product_id,transaction_date,quantity,product_name,product_number,color_id,color,sale,price,model_id,model_name,model_desc,subcategory_id,subcategory,category_id,category,customer_id,customer_name,customer_surname,customer_email,customer_gender,customer_date_of_birth,country_id,country,country_code,state_id,state,state_code,city_id,city
FROM sa_online_sales.src_online_sales sos 
WHERE sos.insert_dt >= (SELECT max(load_time) FROM bl_cl.load_data ld)
EXCEPT 
SELECT transaction_id,product_id,transaction_date,quantity,product_name,product_number,color_id,color,sale,price,model_id,model_name,model_desc,subcategory_id,subcategory,category_id,category,customer_id,customer_name,customer_surname,customer_email,customer_gender,customer_date_of_birth,country_id,country,country_code,state_id,state,state_code,city_id,city
FROM sa_online_sales.src_online_sales sos
WHERE sos.insert_dt < (SELECT max(load_time) FROM bl_cl.load_data ld)
WITH DATA;


CREATE MATERIALIZED VIEW IF NOT EXISTS sa_offline_sales.src_offline_sales_view
AS
SELECT transaction_id,transaction_date,product_id,product_name,product_number,model_id,model_name,model_desc,color_id,color,sale,price,quantity,subcategory_id,subcategory,category_id,category,customer_id,customer_name,customer_surname,customer_email,customer_gender,customer_date_of_birth,country_id,country,country_code,state_id,state,state_code,city_id,city,address_id,address_line1,address_line2,postal_code,shop_id,shop_name,employee_id,employee_name,employee_surname,employee_email
FROM sa_offline_sales.src_offline_sales sos 
WHERE sos.insert_dt >= (SELECT max(load_time) FROM bl_cl.load_data ld)
EXCEPT 
SELECT transaction_id,transaction_date,product_id,product_name,product_number,model_id,model_name,model_desc,color_id,color,sale,price,quantity,subcategory_id,subcategory,category_id,category,customer_id,customer_name,customer_surname,customer_email,customer_gender,customer_date_of_birth,country_id,country,country_code,state_id,state,state_code,city_id,city,address_id,address_line1,address_line2,postal_code,shop_id,shop_name,employee_id,employee_name,employee_surname,employee_email
FROM sa_offline_sales.src_offline_sales sos
WHERE sos.insert_dt < (SELECT max(load_time) FROM bl_cl.load_data ld)
WITH DATA;

