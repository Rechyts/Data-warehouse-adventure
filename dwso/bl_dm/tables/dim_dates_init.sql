
-- Add default raw -1 to dim_dates table
INSERT INTO bl_dm.dim_dates  
(date_id, date_actual, day_suffix, day_name, day_of_week, day_of_month, day_of_quarter, day_of_year, week_of_month, week_of_year, month_actual, month_name, month_name_abbreviated, quarter_actual, quarter_name, year_actual, first_day_of_week, last_day_of_week, first_day_of_month, last_day_of_month, first_day_of_quarter, last_day_of_quarter, first_day_of_year, last_day_of_year, weekend)
VALUES (-1, '1900-01-01', 'NA', 'NA', -1, -1, -1, -1, -1, -1, -1, 'NA', 'NA', -1, 'NA', -1, '1900-01-01','1900-01-01','1900-01-01','1900-01-01','1900-01-01','1900-01-01','1900-01-01','1900-01-01', FALSE)
ON CONFLICT DO NOTHING;

COMMIT;