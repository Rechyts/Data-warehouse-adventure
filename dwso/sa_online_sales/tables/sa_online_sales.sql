--DROP DATABASE IF EXISTS adventure;
--
--/*Create database Kindergarten*/
--CREATE DATABASE adventure;


/*___________________________________________________________________
*/


/*Create schema for online shops*/
CREATE SCHEMA IF NOT EXISTS sa_online_sales;

--Create extension for foreign data wrappers which can work with .csv files
CREATE EXTENSION IF NOT EXISTS file_fdw;
CREATE SERVER IF NOT EXISTS import FOREIGN DATA WRAPPER file_fdw;

--Create table for source data - online shops
DROP FOREIGN TABLE IF EXISTS sa_online_sales.ext_online_sales;
CREATE FOREIGN TABLE sa_online_sales.ext_online_sales (
  transaction_id varchar(255),
  product_id varchar(255),
  transaction_date varchar(255),
  quantity varchar(255),
  product_name varchar(255),
  product_number varchar(255),
  color_id varchar(255),
  color varchar(255),
  sale varchar(255),
  price varchar(255),
  model_id varchar(255),
  model_name varchar(255),
  model_desc TEXT, 
  subcategory_id varchar(255),
  subcategory varchar(255),
  category_id varchar(255),
  category varchar(255),
  customer_id varchar(255),
  customer_name varchar(255),
  customer_surname varchar(255),
  customer_email varchar(255),
  customer_gender varchar(255),
  --calculated date of birth from age, the same logic as for offline sales
  customer_date_of_birth varchar(255),
  country_id varchar(255),
  country varchar(255),
  country_code varchar(255),
  state_id varchar(255),
  state varchar(255),
  state_code varchar(255),
  city_id varchar(255),
  city varchar(255)
) SERVER import OPTIONS ( filename 'C:/raw_data/adventure_online_sales.csv', delimiter ',', HEADER 'true', format 'csv', encoding 'windows-1251');


/*Staging area for online sales*/

CREATE TABLE IF NOT EXISTS sa_online_sales.src_online_sales (
  transaction_id varchar(255),
  product_id varchar(255),
  transaction_date varchar(255),
  quantity varchar(255),
  product_name varchar(255),
  product_number varchar(255),
  color_id varchar(255),
  color varchar(255),
  sale varchar(255),
  price varchar(255),
  model_id varchar(255),
  model_name varchar(255),
  model_desc TEXT, 
  subcategory_id varchar(255),
  subcategory varchar(255),
  category_id varchar(255),
  category varchar(255),
  customer_id varchar(255),
  customer_name varchar(255),
  customer_surname varchar(255),
  customer_email varchar(255),
  customer_gender varchar(255),
  customer_date_of_birth varchar(255),
  country_id varchar(255),
  country varchar(255),
  country_code varchar(255),
  state_id varchar(255),
  state varchar(255),
  state_code varchar(255),
  city_id varchar(255),
  city varchar(255),
  insert_dt timestamp DEFAULT now()
  );


INSERT INTO sa_online_sales.src_online_sales
(transaction_id, product_id, transaction_date, quantity, product_name, product_number, color_id, color, sale, price, model_id, model_name, model_desc, 
subcategory_id, subcategory, category_id, category, customer_id, customer_name, customer_surname, customer_email, customer_gender, customer_date_of_birth, country_id, country, country_code, 
state_id, state, state_code, city_id, city)
SELECT transaction_id, product_id, transaction_date, quantity, product_name, product_number, color_id, color, sale, price, model_id, model_name, model_desc, 
subcategory_id, subcategory, category_id, category, customer_id, customer_name, customer_surname, customer_email, customer_gender, customer_date_of_birth, country_id, country, country_code, 
state_id, state, state_code, city_id, city
FROM sa_online_sales.ext_online_sales;

COMMIT;

