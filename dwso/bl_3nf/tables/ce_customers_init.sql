/*Insert default values -1 in all tables except sales*/
--for default date format set min server date - 1900-01-01
INSERT INTO bl_3nf.ce_customers  
(customer_id, source_id, customer_name, customer_surname, customer_email, customer_gender, customer_date_of_birth, source_system, source_entity, insert_dt)
VALUES (-1, 'NA', 'NA', 'NA','NA', 'NA', '1900-01-01', 'MANUAL', 'MANUAL', now())
ON CONFLICT DO NOTHING;

COMMIT;