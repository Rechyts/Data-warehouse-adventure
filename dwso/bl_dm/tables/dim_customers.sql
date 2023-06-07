/*Create schema for demension and fact tables*/

CREATE SCHEMA IF NOT EXISTS bl_dm;


/*Create dimension table dim_customers in bl_dm schema*/
--Lets agree that DEFAULT value for varchar - 'NA', for integer - -1, for date - '9999-12-31'.
--FIXED: default update_dt as '1900-01-01'
CREATE TABLE IF NOT EXISTS bl_dm.dim_customers (
  customer_surr_id BIGINT NOT NULL UNIQUE DEFAULT NEXTVAL('bl_dm.dim_customers_id_seq'),
  customer_id varchar(255) DEFAULT '-1' NOT NULL,
  customer_name varchar(255) DEFAULT 'NA' NOT NULL,
  customer_surname varchar(255)  DEFAULT 'NA' NOT NULL,
  customer_email varchar(255) DEFAULT 'NA' NOT NULL,
  customer_gender varchar(255)  DEFAULT 'NA' NOT NULL,
  customer_date_of_birth timestamp DEFAULT '9999-12-31' NOT NULL,
  insert_dt timestamp NOT NULL,
  update_dt timestamp DEFAULT '1900-01-01',
  --is_active boolean DEFAULT TRUE,
  source_system varchar(255) DEFAULT 'bl_3nf' NOT NULL,
  source_entity varchar(255) DEFAULT 'ce_customers' NOT NULL,
  UNIQUE(customer_id, source_system, source_entity)
);