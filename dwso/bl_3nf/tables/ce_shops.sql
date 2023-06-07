/*Create schema for 3NF*/
CREATE SCHEMA IF NOT EXISTS bl_3nf;

--FIXED: We took out addresses in a separate dim table
CREATE TABLE IF NOT EXISTS bl_3nf.ce_shops (
  shop_id BIGINT NOT NULL UNIQUE DEFAULT NEXTVAL('bl_3nf.ce_shops_id_seq'),
  source_id varchar(255) NOT NULL,
  shop_name varchar(255) DEFAULT 'NA',
  address_id integer DEFAULT -1,
  source_system varchar(255) NOT NULL,
  source_entity varchar(255) NOT NULL,
  insert_dt timestamp  DEFAULT '1900-01-01' NOT NULL,
  update_dt timestamp DEFAULT '1900-01-01' NOT NULL,
  UNIQUE(source_id, source_system, source_entity)
);

-- All FK constrains in ce_sales.sql file
