use redgradon
truncate tablea 


RESTORE DATABASE theworld from disk ='mac//routine'
WITH 
MOVE'RedDragon_AFTER' TO '//its' physicalname//',
MOVE'RedDragon_AFTER_log' TO ''

RESTORE FILELISTONLY FROM DISK +'c:\sql\rda.bak'