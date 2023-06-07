
--Convert integer to timestamp, it uses in partion by for fct_sales table
CREATE OR REPLACE FUNCTION bl_cl.integer_to_timestamp(some_time integer) 
  RETURNS timestamp
AS
$BODY$
    SELECT to_timestamp($1::text, 'YYYYMMDD');
$BODY$
LANGUAGE sql
IMMUTABLE;


CREATE SCHEMA IF NOT EXISTS bl_dm;