/*Create schema for demension and fact tables*/

CREATE SCHEMA IF NOT EXISTS bl_dm;


/*Create dimension table dim_shops in bl_dm schema*/
--Lets agree that DEFAULT value for varchar - 'NA', for integer - -1, for date - '9999-12-31'.

--FIXED: geo attributes are placed in a separate dimension table dim_addresses
--FIXED: default update_dt as '1900-01-01'
CREATE TABLE IF NOT EXISTS bl_dm.dim_shops (
  shop_surr_id BIGINT NOT NULL UNIQUE DEFAULT NEXTVAL('bl_dm.dim_shops_id_seq'),
  shop_id varchar(255) DEFAULT '-1' NOT NULL,
  shop_name varchar(255) DEFAULT 'NA' NOT NULL, 
  insert_dt timestamp NOT NULL,
  update_dt timestamp DEFAULT '1900-01-01',
  is_active boolean DEFAULT TRUE,
  source_system varchar(255) DEFAULT 'bl_3nf' NOT NULL,
  source_entity varchar(255) DEFAULT 'ce_shops' NOT NULL,
  UNIQUE(shop_id, source_system, source_entity)
);