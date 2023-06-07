YOUR_DIR="C:/Users/Veranika/Documents/Python-Course23/_0.DWH_Project/dwso/bl_dm/sequences"
for file in $YOUR_DIR/*; do
    "C:/Program Files/PostgreSQL/14/bin/psql" -d "dbname='adventure' user='postgres' password='12345678' host='localhost' port=5433" -f "${file}"
done