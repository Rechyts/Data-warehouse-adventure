--DROP DATABASE IF EXISTS adventure;
--
--/*Create database Kindergarten*/
--CREATE DATABASE adventure;


/*___________________________________________________________________
*/


/*Create schemas for sources data: online and offline shops*/
CREATE SCHEMA IF NOT EXISTS sa_offline_sales;


--Create extension for foreign data wrappers which can work with .csv files
CREATE EXTENSION IF NOT EXISTS file_fdw;
CREATE SERVER IF NOT EXISTS import FOREIGN DATA WRAPPER file_fdw;
--Create table for source data - offline shops
DROP FOREIGN TABLE IF EXISTS sa_offline_sales.ext_offline_sales;
CREATE FOREIGN TABLE sa_offline_sales.ext_offline_sales (
  transaction_id varchar(255),
  transaction_date varchar(255),
  product_id varchar(255),
  product_name varchar(255),
  product_number varchar(255),
  model_id varchar(255),
  model_name varchar(255),
  model_desc TEXT,
  color_id varchar(255),
  color varchar(255),
  sale varchar(255),
  price varchar(255),
  quantity varchar(255),
  subcategory_id varchar(255),
  subcategory varchar(255),
  category_id varchar(255),
  category varchar(255),
  customer_id varchar(255),
  customer_name varchar(255),
  customer_surname varchar(255),
  customer_email varchar(255),
  customer_gender varchar(255),
  --calculated date of birth as a subtraction of the current date and age so that this attribute does not change often 
  --because it will be in dimension table, it's better to have not changable data here, get date of birth as "now() - INTERVAL '1 year' * CAST(customer_age AS INTEGER) "
  customer_date_of_birth varchar(255),
  country_id varchar(255),
  country varchar(255),
  country_code varchar(255),
  state_id varchar(255),
  state varchar(255),
  state_code varchar(255),
  city_id varchar(255),
  city varchar(255),
  address_id varchar(255),
  address_line1 varchar(255),
  address_line2 varchar(255),
  postal_code varchar(255),
  shop_id varchar(255),
  shop_name varchar(255),
  employee_id varchar(255),
  employee_name varchar(255),
  employee_surname varchar(255),
  employee_email varchar(255)
) SERVER import OPTIONS ( filename 'C:/raw_data/adventure_offline_sales.csv', delimiter ',', HEADER 'true', format 'csv', encoding 'windows-1251');


--Create tables for geo data
DROP FOREIGN TABLE IF EXISTS sa_offline_sales.geo_structure_iso3166;
CREATE FOREIGN TABLE sa_offline_sales.geo_structure_iso3166(
  child_code varchar(255),
  parent_code varchar(255),
  structure_desc varchar(255),
  structure_level varchar(255)
) SERVER import OPTIONS ( filename 'C:/Geo_data/geo_structure_iso3166.csv', delimiter ',', HEADER 'true', format 'csv');


DROP FOREIGN TABLE IF EXISTS sa_offline_sales.geo_countries_structure_iso3166;
CREATE FOREIGN TABLE sa_offline_sales.geo_countries_structure_iso3166 (
  country_id varchar(255),
  country_desc varchar(255),
  structure_code varchar(255),
  structure_desc varchar(255)
) SERVER import OPTIONS ( filename 'C:/Geo_data/geo_countries_structure_iso3166.csv', delimiter ',', HEADER 'true', format 'csv');


DROP FOREIGN TABLE IF EXISTS sa_offline_sales.geo_countries_iso3166;
CREATE FOREIGN TABLE sa_offline_sales.geo_countries_iso3166 (
  country_id varchar(255),
  country_desc varchar(255),
  country_code varchar(255)
) SERVER import OPTIONS ( filename 'C:/Geo_data/geo_countries_iso3166.csv', delimiter ',', HEADER 'true', format 'csv');



/*Staging area for offline sales*/
CREATE TABLE IF NOT EXISTS sa_offline_sales.src_offline_sales
(
  transaction_id varchar(255),
  transaction_date varchar(255),
  product_id varchar(255),
  product_name varchar(255),
  product_number varchar(255),
  model_id varchar(255),
  model_name varchar(255),
  model_desc TEXT,
  color_id varchar(255),
  color varchar(255),
  sale varchar(255),
  price varchar(255),
  quantity varchar(255),
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
  address_id varchar(255),
  address_line1 varchar(255),
  address_line2 varchar(255),
  postal_code varchar(255),
  shop_id varchar(255),
  shop_name varchar(255),
  employee_id varchar(255),
  employee_name varchar(255),
  employee_surname varchar(255),
  employee_email varchar(255),
  insert_dt timestamp DEFAULT now()
)
;

--I had invalid UTF8 data in my source files, and I couldn't insert data in src table, to hadle it I added encoding 'windows-1251' for fdw import
INSERT INTO sa_offline_sales.src_offline_sales 
(transaction_id, transaction_date, product_id, product_name, product_number, model_id, model_name, model_desc, color_id, color, sale, price, quantity, subcategory_id, subcategory, category_id, category, customer_id, customer_name, customer_surname, customer_email, customer_gender, customer_date_of_birth, country_id, country, country_code, state_id, state, state_code, city_id, city, address_id, address_line1, address_line2, postal_code, shop_id, shop_name, employee_id, employee_name, employee_surname, employee_email)
SELECT transaction_id, transaction_date, product_id, product_name, product_number, model_id, model_name, model_desc, color_id, color, sale, price, quantity, subcategory_id, subcategory, category_id, category, customer_id, customer_name, customer_surname, customer_email, customer_gender, customer_date_of_birth, country_id, country, country_code, state_id, state, state_code, city_id, city, address_id, address_line1, address_line2, postal_code, shop_id, shop_name, employee_id, employee_name, employee_surname, employee_email
FROM sa_offline_sales.ext_offline_sales eos ;

COMMIT;


-- Loading geo data to data staging
CREATE TABLE IF NOT EXISTS sa_offline_sales.src_geo_structure_iso3166 ( 
	child_code varchar(255),
	parent_code varchar(255),
	structure_desc varchar(255),
	structure_level varchar(255),
	insert_dt timestamp DEFAULT now()
);

INSERT INTO sa_offline_sales.src_geo_structure_iso3166
(child_code, parent_code, structure_desc, structure_level)
SELECT child_code, parent_code, structure_desc, structure_level
FROM sa_offline_sales.geo_structure_iso3166
;

COMMIT;

CREATE TABLE IF NOT EXISTS sa_offline_sales.src_geo_countries_structure_iso3166 (
  country_id varchar(255),
  country_desc varchar(255),
  structure_code varchar(255),
  structure_desc varchar(255),
  insert_dt timestamp DEFAULT now()
);


INSERT INTO sa_offline_sales.src_geo_countries_structure_iso3166
(country_id, country_desc, structure_code, structure_desc)
SELECT country_id, country_desc, structure_code, structure_desc
FROM sa_offline_sales.geo_countries_structure_iso3166
;

COMMIT;


CREATE TABLE IF NOT EXISTS sa_offline_sales.src_geo_countries_iso3166 (
  country_id varchar(255),
  country_desc varchar(255),
  country_code varchar(255),
  insert_dt timestamp DEFAULT now()
)  
;


INSERT INTO sa_offline_sales.src_geo_countries_iso3166
(country_id, country_desc, country_code)
SELECT country_id, country_desc, country_code
FROM sa_offline_sales.geo_countries_iso3166
;

COMMIT;
