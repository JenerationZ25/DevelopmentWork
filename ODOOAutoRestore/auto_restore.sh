
echo "starting..."

cd C:/baraja/odoo_sh/

server="4577487@barajait-odoo15sh.odoo.com"
#file="2022-04-19_054527-barajait-odoo15sh-staging-4591955_manual.sql.gz"
file="barajait-odoo15sh-proddb-4577487_daily.sql.gz"
#sqlfile="2022-04-19_054527-barajait-odoo15sh-staging-4591955_manual.sql"
sqlfile="barajait-odoo15sh-proddb-4577487_daily.sql"
dir="/home/odoo/backup.daily/barajait-odoo15sh-proddb-4577487_daily.sql.gz"
#dir="/home/odoo/backup.daily/barajait-odoo15sh-staging-4883013_daily.sql.gz"

echo "downloading backup..."
scp -i "baraja_nopass" $server:$dir .


echo "unzip backup..."
#echo $file
#"C:\Program Files\7-Zip\7z" e barajait-odoo15sh-proddb-4577487_daily.sql.gz -o ./

"C:\Program Files\7-Zip\7z" e $file -o.\

echo "restoring backup..."
"C:\Program Files\PostgreSQL\14\bin\psql" -p 5432 -h odoosh-bar-aws.csqvxaloczsm.ap-southeast-2.rds.amazonaws.com  -U baraja -d baraja -c "SELECT pg_terminate_backend(pg_stat_activity.pid) FROM pg_stat_activity WHERE pg_stat_activity.datname = 'baraja_old' AND pid <> pg_backend_pid();"
"C:\Program Files\PostgreSQL\14\bin\psql" -p 5432 -h odoosh-bar-aws.csqvxaloczsm.ap-southeast-2.rds.amazonaws.com  -U baraja -c "DROP DATABASE baraja_old;"
"C:\Program Files\PostgreSQL\14\bin\psql" -p 5432 -h odoosh-bar-aws.csqvxaloczsm.ap-southeast-2.rds.amazonaws.com  -U baraja -d baraja -c "SELECT pg_terminate_backend(pg_stat_activity.pid) FROM pg_stat_activity WHERE pg_stat_activity.datname = 'baraja_new' AND pid <> pg_backend_pid();"
"C:\Program Files\PostgreSQL\14\bin\psql" -p 5432 -h odoosh-bar-aws.csqvxaloczsm.ap-southeast-2.rds.amazonaws.com  -U baraja -c "DROP DATABASE baraja_new;"
"C:\Program Files\PostgreSQL\14\bin\psql" -p 5432 -h odoosh-bar-aws.csqvxaloczsm.ap-southeast-2.rds.amazonaws.com  -U baraja -c "CREATE DATABASE baraja_new"
"C:\Program Files\PostgreSQL\14\bin\psql" -p 5432 -h odoosh-bar-aws.csqvxaloczsm.ap-southeast-2.rds.amazonaws.com  -U baraja -d baraja_new -f ./$sqlfile
"C:\Program Files\PostgreSQL\14\bin\psql" -p 5432 -h odoosh-bar-aws.csqvxaloczsm.ap-southeast-2.rds.amazonaws.com  -U baraja -d baraja -c "SELECT pg_terminate_backend(pg_stat_activity.pid) FROM pg_stat_activity WHERE pg_stat_activity.datname = 'baraja' AND pid <> pg_backend_pid();"
"C:\Program Files\PostgreSQL\14\bin\psql" -p 5432 -h odoosh-bar-aws.csqvxaloczsm.ap-southeast-2.rds.amazonaws.com  -U baraja -d baraja_new -c "SELECT pg_terminate_backend(pg_stat_activity.pid) FROM pg_stat_activity WHERE pg_stat_activity.datname = 'baraja_new' AND pid <> pg_backend_pid();"
"C:\Program Files\PostgreSQL\14\bin\psql" -p 5432 -h odoosh-bar-aws.csqvxaloczsm.ap-southeast-2.rds.amazonaws.com  -U baraja -d baraja_new -c "ALTER DATABASE baraja RENAME TO baraja_old;"
"C:\Program Files\PostgreSQL\14\bin\psql" -p 5432 -h odoosh-bar-aws.csqvxaloczsm.ap-southeast-2.rds.amazonaws.com  -U baraja -d baraja_old -c "ALTER DATABASE baraja_new RENAME TO baraja;"

rm ./$sqlfile

