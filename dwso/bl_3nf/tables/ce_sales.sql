/*Create schema for 3NF*/
CREATE SCHEMA IF NOT EXISTS bl_3nf;
CREATE SCHEMA IF NOT EXISTS bl_cl;

CREATE TABLE IF NOT EXISTS bl_3nf.ce_sales (
  transaction_id BIGINT NOT NULL DEFAULT NEXTVAL('bl_3nf.ce_sales_id_seq'),
  source_id varchar(255) NOT NULL,
  product_id integer DEFAULT -1,
  model_id integer DEFAULT -1,
  customer_id integer DEFAULT -1,
  employee_id integer DEFAULT -1,
  shop_id integer DEFAULT -1,
  --FIXED: add address_id for dim_addresses dimension table
  address_id integer DEFAULT -1,
  city_id integer DEFAULT -1,
  transaction_date timestamp DEFAULT '1900-01-01' NOT NULL,
  quantity integer DEFAULT -1,
  sale numeric(10,2) DEFAULT -1,
  price numeric(10,2) DEFAULT -1,
  source_system varchar(255) NOT NULL,
  source_entity varchar(255) NOT NULL,
  insert_dt timestamp DEFAULT '1900-01-01' NOT NULL,
  update_dt timestamp DEFAULT '1900-01-01' NOT NULL,
  UNIQUE(source_id, transaction_date,  source_system, source_entity),
  CONSTRAINT ce_sales_pkey PRIMARY KEY (transaction_id, transaction_date)
)
PARTITION BY RANGE (transaction_date);



--Create constrains
ALTER TABLE bl_3nf.ce_products ADD FOREIGN KEY (color_id) REFERENCES bl_3nf.ce_colors (color_id);

ALTER TABLE bl_3nf.ce_products ADD FOREIGN KEY (subcategory_id) REFERENCES bl_3nf.ce_subcategories (subcategory_id);

ALTER TABLE bl_3nf.ce_shops ADD FOREIGN KEY (address_id) REFERENCES bl_3nf.ce_addresses (address_id);

ALTER TABLE bl_3nf.ce_employees ADD FOREIGN KEY (shop_id) REFERENCES bl_3nf.ce_shops (shop_id);

ALTER TABLE bl_3nf.ce_addresses ADD FOREIGN KEY (city_id) REFERENCES bl_3nf.ce_cities (city_id);

ALTER TABLE bl_3nf.ce_cities ADD FOREIGN KEY (state_id) REFERENCES bl_3nf.ce_states (state_id);

ALTER TABLE bl_3nf.ce_states ADD FOREIGN KEY (country_id) REFERENCES bl_3nf.ce_countries (country_id);

ALTER TABLE bl_3nf.ce_countries ADD FOREIGN KEY (region_id) REFERENCES bl_3nf.ce_regions (region_id);

ALTER TABLE bl_3nf.ce_subcategories ADD FOREIGN KEY (category_id) REFERENCES bl_3nf.ce_categories (category_id);

--ALTER TABLE bl_3nf.ce_sales ADD FOREIGN KEY (product_id) REFERENCES bl_3nf.ce_products (product_id);

ALTER TABLE bl_3nf.ce_sales ADD FOREIGN KEY (model_id) REFERENCES bl_3nf.ce_models (model_id);

ALTER TABLE bl_3nf.ce_sales ADD FOREIGN KEY (customer_id) REFERENCES bl_3nf.ce_customers (customer_id);

ALTER TABLE bl_3nf.ce_sales ADD FOREIGN KEY (employee_id) REFERENCES bl_3nf.ce_employees (employee_id);

ALTER TABLE bl_3nf.ce_sales ADD FOREIGN KEY (shop_id) REFERENCES bl_3nf.ce_shops (shop_id);

ALTER TABLE bl_3nf.ce_sales ADD FOREIGN KEY (city_id) REFERENCES bl_3nf.ce_cities (city_id);



