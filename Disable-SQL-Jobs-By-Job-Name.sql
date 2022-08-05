--Disable SQL Jobs By Job Name on the machine.
USE MSDB;
GO

DECLARE @job_id uniqueidentifier

DECLARE job_cursor CURSOR READ_ONLY FOR  
SELECT job_id
FROM msdb.dbo.sysjobs
WHERE enabled = 1
  AND [name] like N'Sandbox%'

OPEN job_cursor   
FETCH NEXT FROM job_cursor INTO @job_id  

WHILE @@FETCH_STATUS = 0
BEGIN
   EXEC msdb.dbo.sp_update_job @job_id = @job_id, @enabled = 0
   FETCH NEXT FROM job_cursor INTO @job_id  
END

CLOSE job_cursor   
DEALLOCATE job_cursor


-- This portion of the script will return the list of the specified sql jobs so we can see if the jobs are indeed disabled.
SELECT 
 job_id
,name
,enabled
,date_created
,date_modified
FROM msdb.dbo.sysjobs
WHERE enabled = 0
  AND [name] like N'Sandbox%'
ORDER BY date_created