
echo "starting..."

cd C:/baraja/odoo_sh/

server="----------------.odoo.com"
#file="---------.sql.gz"
file="----------------.sql.gz"
#sqlfile="----------------.sql"
sqlfile="----------------.sql"
dir="/home/----------------.sql.gz"
#dir="/home/----------------.sql.gz"

echo "downloading backup..."
scp -i "baraja_nopass" $server:$dir .


echo "unzip backup..."
#echo $file
#"C:\Program Files\7-Zip\7z" e ----------------.sql.gz -o ./

"C:\Program Files\7-Zip\7z" e $file -o.\

echo "restoring backup..."
"C:\Program Files\PostgreSQL\14\bin\psql" -p 5432 -h ----------------------------------------------------------------  -U ---- -d ---- -c "SELECT pg_terminate_backend(pg_stat_activity.pid) FROM pg_stat_activity WHERE pg_stat_activity.datname = '----_old' AND pid <> pg_backend_pid();"
"C:\Program Files\PostgreSQL\14\bin\psql" -p 5432 -h ----------------------------------------------------------------  -U ---- -c "DROP DATABASE ----_old;"
"C:\Program Files\PostgreSQL\14\bin\psql" -p 5432 -h ----------------------------------------------------------------  -U ---- -d ---- -c "SELECT pg_terminate_backend(pg_stat_activity.pid) FROM pg_stat_activity WHERE pg_stat_activity.datname = '----_new' AND pid <> pg_backend_pid();"
"C:\Program Files\PostgreSQL\14\bin\psql" -p 5432 -h ----------------------------------------------------------------  -U ---- -c "DROP DATABASE ----_new;"
"C:\Program Files\PostgreSQL\14\bin\psql" -p 5432 -h ----------------------------------------------------------------  -U ---- -c "CREATE DATABASE ----_new"
"C:\Program Files\PostgreSQL\14\bin\psql" -p 5432 -h ----------------------------------------------------------------  -U ---- -d ----_new -f ./$sqlfile
"C:\Program Files\PostgreSQL\14\bin\psql" -p 5432 -h ----------------------------------------------------------------  -U ---- -d ---- -c "SELECT pg_terminate_backend(pg_stat_activity.pid) FROM pg_stat_activity WHERE pg_stat_activity.datname = '----' AND pid <> pg_backend_pid();"
"C:\Program Files\PostgreSQL\14\bin\psql" -p 5432 -h ----------------------------------------------------------------  -U ---- -d ----_new -c "SELECT pg_terminate_backend(pg_stat_activity.pid) FROM pg_stat_activity WHERE pg_stat_activity.datname = '----_new' AND pid <> pg_backend_pid();"
"C:\Program Files\PostgreSQL\14\bin\psql" -p 5432 -h ---------------------------------------------------------------- -U ---- -d ----_new -c "ALTER DATABASE ---- RENAME TO ----_old;"
"C:\Program Files\PostgreSQL\14\bin\psql" -p 5432 -h ----------------------------------------------------------------  -U ---- -d ----_old -c "ALTER DATABASE ----_new RENAME TO ----;"

rm ./$sqlfile

