/*Create schema for demension and fact tables*/

CREATE SCHEMA IF NOT EXISTS bl_dm;


/*Create table dim_addresses*/
--Lets agree that DEFAULT value for varchar - 'NA', for integer - -1, for date - '1900-01-01'.
--FIXED: geo attributes are placed in a separate dimension table dim_addresses 
-- for offline sales address_id will be filled, for online sales - city_id
-- default update_dt as '1900-01-01'
CREATE TABLE IF NOT EXISTS bl_dm.dim_addresses (
  address_surr_id BIGINT NOT NULL UNIQUE DEFAULT NEXTVAL('bl_dm.dim_addresses_id_seq'),
  address_id varchar(255) DEFAULT '-1' NOT NULL,
  address_line1 varchar(255) DEFAULT 'NA' NOT NULL,
  address_line2 varchar(255) DEFAULT 'NA' NOT NULL, 
  postal_code varchar(255) DEFAULT 'NA' NOT NULL,  
  city_id varchar(255) DEFAULT '-1' NOT NULL,
  city_name varchar(255) DEFAULT 'NA' NOT NULL,
  state_id varchar(255) DEFAULT 'NA' NOT NULL,
  state_name varchar(255) DEFAULT 'NA' NOT NULL,
  state_code varchar(255) DEFAULT 'NA' NOT NULL,
  country_id varchar(255) DEFAULT '-1' NOT NULL,
  country_name varchar(255) DEFAULT 'NA' NOT NULL,
  country_code varchar(255) DEFAULT 'NA' NOT NULL,
  region_id varchar(255) DEFAULT '-1' NOT NULL,
  region_name varchar(255) DEFAULT 'NA' NOT NULL,
  insert_dt timestamp NOT NULL,
  update_dt timestamp DEFAULT '1900-01-01',
  source_system varchar(255) DEFAULT 'bl_3nf' NOT NULL,
  source_entity varchar(255) DEFAULT 'ce_addresses' NOT NULL,
  UNIQUE(address_id, city_id, source_system, source_entity)
);

