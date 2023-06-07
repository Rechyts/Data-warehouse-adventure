/*Create schema for 3NF*/
CREATE SCHEMA IF NOT EXISTS bl_3nf;

CREATE TABLE IF NOT EXISTS bl_3nf.ce_regions (
  region_id BIGINT NOT NULL UNIQUE DEFAULT NEXTVAL('bl_3nf.ce_regions_id_seq'),
  source_id varchar(255) NOT NULL,
  region_name varchar(255) DEFAULT 'NA',
  source_system varchar(255) NOT NULL,
  source_entity varchar(255) NOT NULL,
  insert_dt timestamp DEFAULT '1900-01-01' NOT NULL,
  update_dt timestamp DEFAULT '1900-01-01' NOT NULL,
  UNIQUE(source_id, source_system, source_entity)
);

-- All FK constrains in ce_sales.sql file