--Create dim tables dates

DROP TABLE IF EXISTS bl_dm.dim_dates;

CREATE TABLE IF NOT EXISTS bl_dm.dim_dates
(
  --date_id                  integer PRIMARY KEY NOT NULL ,
  date_id              	   date PRIMARY KEY NOT NULL,
  day_suffix               varchar(4) NOT NULL,
  day_name                 varchar(9) NOT NULL,
  day_of_week              integer NOT NULL,
  day_of_month             integer NOT NULL,
  day_of_quarter           integer NOT NULL,
  day_of_year              integer NOT NULL,
  week_of_month            integer NOT NULL,
  week_of_year             integer NOT NULL,
  month_actual             integer NOT NULL,
  month_name               varchar(9) NOT NULL,
  month_name_abbreviated   char(3) NOT NULL,
  quarter_actual           integer NOT NULL,
  quarter_name             varchar(9) NOT NULL,
  year_actual              integer NOT NULL,
  first_day_of_week        date NOT NULL,
  last_day_of_week         date NOT NULL,
  first_day_of_month       date NOT NULL,
  last_day_of_month        date NOT NULL,
  first_day_of_quarter     date NOT NULL,
  last_day_of_quarter      date NOT NULL,
  first_day_of_year        date NOT NULL,
  last_day_of_year         date NOT NULL,
  weekend	               boolean NOT NULL
);