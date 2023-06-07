/*Create schema for 3NF*/
CREATE SCHEMA IF NOT EXISTS bl_3nf;


--Create tables for 3NF schema
--FIXED: For al tables make Default value for insert and update as '1900-01-01'(Not Defined)
CREATE TABLE IF NOT EXISTS bl_3nf.ce_products (
  product_id bigint NOT NULL DEFAULT NEXTVAL('bl_3nf.ce_products_id_seq'),
  source_id varchar(255) NOT NULL,
  product_name varchar(255) DEFAULT 'NA',
  product_number varchar(255) DEFAULT 'NA',
  color_id integer DEFAULT -1,
  subcategory_id integer DEFAULT -1,
  source_system varchar(255) NOT NULL,
  source_entity varchar(255) NOT NULL,
  insert_dt timestamp DEFAULT '1900-01-01' NOT NULL,
  date_start timestamp DEFAULT '1900-01-01' NOT NULL,
  date_end timestamp DEFAULT '9999-12-31' NOT NULL,
  is_active boolean DEFAULT TRUE,
  first_transaction_date timestamp DEFAULT '1900-01-01' NOT NULL,
  UNIQUE(source_id, source_system, source_entity, date_start)
);

-- All FK constrains in ce_sales.sql file
--ALTER TABLE bl_3nf.ce_products DROP CONSTRAINT IF EXISTS ce_products_source_id_source_system_source_entity_date_star_key;
--ALTER TABLE bl_3nf.ce_products 
--ADD CONSTRAINT ce_products_pkey PRIMARY KEY (source_id, source_system, source_entity, date_start);