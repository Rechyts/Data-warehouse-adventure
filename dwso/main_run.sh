YOUR_DIR1="C:/Users/Veranika/Documents/Python-Course23/_0.DWH_Project/dwso/sa_online_sales/tables"
for file in $YOUR_DIR1/*; do
    "C:/Program Files/PostgreSQL/14/bin/psql" -d "dbname='adventure' user='postgres' password='12345678' host='localhost' port=5433" -f "${file}"
done
YOUR_DIR2="C:/Users/Veranika/Documents/Python-Course23/_0.DWH_Project/dwso/sa_offline_sales/tables"
for file in $YOUR_DIR2/*; do
    "C:/Program Files/PostgreSQL/14/bin/psql" -d "dbname='adventure' user='postgres' password='12345678' host='localhost' port=5433" -f "${file}"
done
YOUR_DIR31="C:/Users/Veranika/Documents/Python-Course23/_0.DWH_Project/dwso/bl_3nf/sequences"
for file in $YOUR_DIR31/*; do
    "C:/Program Files/PostgreSQL/14/bin/psql" -d "dbname='adventure' user='postgres' password='12345678' host='localhost' port=5433" -f "${file}"
done
YOUR_DIR3="C:/Users/Veranika/Documents/Python-Course23/_0.DWH_Project/dwso/bl_3nf/tables"
for file in $YOUR_DIR3/*; do
    "C:/Program Files/PostgreSQL/14/bin/psql" -d "dbname='adventure' user='postgres' password='12345678' host='localhost' port=5433" -f "${file}"
done
YOUR_DIR4="C:/Users/Veranika/Documents/Python-Course23/_0.DWH_Project/dwso/bl_cl/procedures/work_files"
for file in $YOUR_DIR4/*; do
    "C:/Program Files/PostgreSQL/14/bin/psql" -d "dbname='adventure' user='postgres' password='12345678' host='localhost' port=5433" -f "${file}"
done
YOUR_DIR51="C:/Users/Veranika/Documents/Python-Course23/_0.DWH_Project/dwso/bl_dm/sequences"
for file in $YOUR_DIR51/*; do
    "C:/Program Files/PostgreSQL/14/bin/psql" -d "dbname='adventure' user='postgres' password='12345678' host='localhost' port=5433" -f "${file}"
done
YOUR_DIR5="C:/Users/Veranika/Documents/Python-Course23/_0.DWH_Project/dwso/bl_dm/tables"
for file in $YOUR_DIR5/*; do
    "C:/Program Files/PostgreSQL/14/bin/psql" -d "dbname='adventure' user='postgres' password='12345678' host='localhost' port=5433" -f "${file}"
done
YOUR_DIR6="C:/Users/Veranika/Documents/Python-Course23/_0.DWH_Project/dwso/bl_cl/procedures/procedures_3nf"
for file in $YOUR_DIR6/*; do
    "C:/Program Files/PostgreSQL/14/bin/psql" -d "dbname='adventure' user='postgres' password='12345678' host='localhost' port=5433" -f "${file}"
done
YOUR_DIR7="C:/Users/Veranika/Documents/Python-Course23/_0.DWH_Project/dwso/bl_cl/procedures/procedures_dim"
for file in $YOUR_DIR7/*; do
    "C:/Program Files/PostgreSQL/14/bin/psql" -d "dbname='adventure' user='postgres' password='12345678' host='localhost' port=5433" -f "${file}"
done
"C:/Program Files/PostgreSQL/14/bin/psql" -d "dbname='adventure' user='postgres' password='12345678' host='localhost' port=5433" -f "C:/Users/Veranika/Documents/Python-Course23/_0.DWH_Project/dwso/bl_cl/procedures/user_management/grant_privileges.sql"
