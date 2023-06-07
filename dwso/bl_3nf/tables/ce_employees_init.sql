/*Insert default values -1 in all tables except sales*/
INSERT INTO bl_3nf.ce_employees 
(employee_id, source_id, employee_name, employee_surname, employee_email, shop_id, source_system, source_entity, insert_dt)
VALUES(-1, 'NA', 'NA', 'NA', 'NA', -1, 'MANUAL', 'MANUAL', now())
ON CONFLICT DO NOTHING
;

COMMIT;