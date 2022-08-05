$ConnectionString = 'Server=SQLSERVER01;Database=msdb;Trusted_Connection=true'

Invoke-Sqlcmd -ConnectionString $ConnectionString -InputFile "C:\Temp\scripts\disable-enable-sql-jobs\Disable-SQL-Jobs-By-Job-Name.sql" | Export-Csv -Delimiter "," -Path "C:\Users\johndoe\Downloads\results.csv"
Import-Csv "C:\Users\johndoe\Downloads\results.csv" | Format-table
