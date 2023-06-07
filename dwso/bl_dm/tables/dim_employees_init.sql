-- /*Insert default values -1 in all tables except fact table*/
INSERT INTO bl_dm.dim_employees
(employee_surr_id, employee_id, employee_name, employee_surname, employee_email, insert_dt, source_system, source_entity)
VALUES (-1, '-1', 'NA', 'NA', 'NA', now(), 'MANUAL', 'MANUAL')
ON CONFLICT DO NOTHING;

COMMIT;