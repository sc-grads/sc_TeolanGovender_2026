CREATE TABLE SQLBackupRestoreTest (
ID INT NOT NULL PRIMARY KEY,
loginname VARCHAR(100) NOT NULL,
logindate DATETIME NOT NULL DEFAULT getdate()
)
GO

select * from SQLBackupRestoreTest

--full backup 5 rows
insert into SQLBackupRestoreTest (ID,loginname) values (1,'test1')
insert into SQLBackupRestoreTest (ID,loginname) values (2,'test2')
insert into SQLBackupRestoreTest (ID,loginname) values (3,'test3')
insert into SQLBackupRestoreTest (ID,loginname) values (4,'test4')
insert into SQLBackupRestoreTest (ID,loginname) values (5,'test5')

--diff backup 10 rows
insert into SQLBackupRestoreTest (ID,loginname) values (6,'test6')
insert into SQLBackupRestoreTest (ID,loginname) values (7,'test7')
insert into SQLBackupRestoreTest (ID,loginname) values (8,'test8')
insert into SQLBackupRestoreTest (ID,loginname) values (9,'test9')
insert into SQLBackupRestoreTest (ID,loginname) values (10,'test10')

--transactional log backup 1 - 13 rows
insert into SQLBackupRestoreTest (ID,loginname) values (11,'test11')
insert into SQLBackupRestoreTest (ID,loginname) values (12,'test12')
insert into SQLBackupRestoreTest (ID,loginname) values (13,'test13')

--transactional log backup 2 - 17 rows
-- May 19 2026 12:22pm
insert into SQLBackupRestoreTest (ID,loginname) values (14,'test14')
insert into SQLBackupRestoreTest (ID,loginname) values (15,'test15')
insert into SQLBackupRestoreTest (ID,loginname) values (16,'test16')
insert into SQLBackupRestoreTest (ID,loginname) values (17,'test17')


--May 19 2026  1:46PM
insert into SQLBackupRestoreTest (ID,loginname) values (18,'test18')

--May 19 2026  1:49PM
insert into SQLBackupRestoreTest (ID,loginname) values (19,'test19')

--May 19 2026  1:54PM
insert into SQLBackupRestoreTest (ID,loginname) values (20,'test20')

--May 19 2026  1:58PM
insert into SQLBackupRestoreTest (ID,loginname) values (21,'test21')

print getdate()
