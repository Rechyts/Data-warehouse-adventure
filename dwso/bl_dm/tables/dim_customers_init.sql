-- /*Insert default values -1 in all tables except fact table*/
INSERT INTO bl_dm.dim_customers
(customer_surr_id, customer_id, customer_name, customer_surname, customer_email, customer_gender, customer_date_of_birth, insert_dt, source_system, source_entity)
VALUES (-1, '-1', 'NA', 'NA', 'NA', 'NA', '9999-12-31', now(), 'MANUAL', 'MANUAL')
ON CONFLICT DO NOTHING;

COMMIT;