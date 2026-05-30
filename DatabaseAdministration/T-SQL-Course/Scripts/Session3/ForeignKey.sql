BEGIN TRAN
ALTER TABLE tblTransaction ALTER COLUMN EmpNumber INT NULL 
ALTER TABLE tblTransaction ADD CONSTRAINT DF_tblTransaction DEFAULT 124 FOR EmpNumber
ALTER TABLE tblTransaction WITH NOCHECK
ADD CONSTRAINT FK_tblTransaction_EmpNumber FOREIGN KEY (EmpNumber)
REFERENCES tblEmployee(EmpNumber)
ON UPDATE CASCADE
ON DELETE set default
--UPDATE tblEmployee SET EmpNumber = 9123 Where EmpNumber = 123
DELETE tblEmployee Where EmpNumber = 123

SELECT E.EmpNumber, T.*
FROM tblEmployee as E
RIGHT JOIN tblTransaction as T
on E.EmpNumber = T.EmpNumber
where T.Amount IN (-179.47, 786.22, -967.36, 957.03)

ROLLBACK TRAN
