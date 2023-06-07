/*Create schema for demension and fact tables*/

CREATE SCHEMA IF NOT EXISTS bl_dm;


/*Create dimension table dim_products in bl_dm schema*/
--Lets agree that DEFAULT value for varchar - 'NA', for integer - -1, for date - '9999-12-31'.
--FIXED: default start date as '1900-01-01'
CREATE TABLE IF NOT EXISTS bl_dm.dim_products (
  product_surr_id BIGINT NOT NULL UNIQUE DEFAULT NEXTVAL('bl_dm.dim_products_id_seq'),
  product_id varchar(255) DEFAULT 'NA' NOT NULL,
  product_name varchar(255) DEFAULT 'NA' NOT NULL,
  product_number varchar(255) DEFAULT 'NA' NOT NULL,
  product_subcategory_id varchar(255) DEFAULT '-1' NOT NULL,
  product_subcategory_name varchar(255) DEFAULT 'NA' NOT NULL,
  product_category_id varchar(255) DEFAULT '-1' NOT NULL,
  product_category_name varchar(255) DEFAULT 'NA' NOT NULL,
  product_color_id varchar(255) DEFAULT '-1' NOT NULL,
  product_color_name varchar(255) DEFAULT 'NA' NOT NULL,
  start_date timestamp DEFAULT '1900-01-01' NOT NULL,
  end_date timestamp DEFAULT '9999-12-31' NOT NULL,
  is_active boolean DEFAULT TRUE,
  insert_dt timestamp DEFAULT '1900-01-01' NOT NULL,
  update_dt timestamp  DEFAULT '1900-01-01' NOT NULL,
  source_system varchar(255) DEFAULT 'bl_3nf' NOT NULL,
  source_entity varchar(255) DEFAULT 'ce_products' NOT NULL,
  UNIQUE(product_id, start_date, source_system, source_entity)
);

COMMIT;