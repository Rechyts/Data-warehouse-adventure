/*Create schema for demension and fact tables*/

CREATE SCHEMA IF NOT EXISTS bl_dm;


/*Create tables*/
--Lets agree that DEFAULT value for varchar - 'NA', for integer - -1, for date - '9999-12-31'.
CREATE TABLE IF NOT EXISTS bl_dm.fct_sales (
  product_surr_id integer DEFAULT -1 NOT NULL,
  model_surr_id integer DEFAULT -1 NOT NULL,
  customer_surr_id integer DEFAULT -1 NOT NULL,
  employee_surr_id integer DEFAULT -1 NOT NULL,
  shop_surr_id integer DEFAULT -1 NOT NULL,
  --FIXED: add new attr for dim_addresses dimension table
  address_surr_id integer DEFAULT -1 NOT NULL,
  time_id timestamp DEFAULT '1900-01-01'::timestamp NOT NULL,
  transaction_id varchar(255) DEFAULT 'NA' NOT NULL,
  price numeric(10, 2) DEFAULT -1 NOT NULL,
  sale numeric(10, 2) DEFAULT -1 NOT NULL,
  quantity integer DEFAULT -1 NOT NULL,
  source_system varchar(255) NOT NULL,
  source_entity varchar(255) NOT NULL,
  insert_dt timestamp DEFAULT now() NOT NULL,
  UNIQUE(transaction_id, time_id)
)
PARTITION BY RANGE (time_id);

--Add constarins
ALTER TABLE bl_dm.fct_sales ADD FOREIGN KEY (product_surr_id) REFERENCES bl_dm.dim_products (product_surr_id);

ALTER TABLE bl_dm.fct_sales ADD FOREIGN KEY (model_surr_id) REFERENCES bl_dm.dim_models (model_surr_id);

ALTER TABLE bl_dm.fct_sales ADD FOREIGN KEY (customer_surr_id) REFERENCES bl_dm.dim_customers (customer_surr_id);

ALTER TABLE bl_dm.fct_sales ADD FOREIGN KEY (employee_surr_id) REFERENCES bl_dm.dim_employees (employee_surr_id);

ALTER TABLE bl_dm.fct_sales ADD FOREIGN KEY (shop_surr_id) REFERENCES bl_dm.dim_shops (shop_surr_id);

ALTER TABLE bl_dm.fct_sales ADD FOREIGN KEY (address_surr_id) REFERENCES bl_dm.dim_addresses (address_surr_id);

--ALTER TABLE bl_dm.fct_sales DROP CONSTRAINT fct_sales_time_id_fkey; 
ALTER TABLE bl_dm.fct_sales ADD FOREIGN KEY (time_id) REFERENCES bl_dm.dim_dates (date_id);

COMMIT;