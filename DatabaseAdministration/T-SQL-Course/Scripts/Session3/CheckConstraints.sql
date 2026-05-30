-- Add a CHECK constraint to tblTransaction
-- Ensures Amount must be between -1000 and 1000 (exclusive)
alter table tblTransaction
add constraint chkAmount check (Amount > -1000 and Amount < 1000);

-- Insert a test row into tblTransaction
-- This will only succeed if Amount is within the allowed range
insert into tblTransaction
values (1010, '2014-01-01', 1);

------------------------------------------------------------

-- Add a CHECK constraint to tblEmployee (without validating existing data)
-- WITH NOCHECK means existing rows are NOT validated, only new inserts/updates
alter table tblEmployee with nocheck
add constraint chkMiddleName check
(REPLACE(EmpMiddleName, '.', '') = EmpMiddleName or EmpMiddleName is null);

------------------------------------------------------------

-- Remove the chkMiddleName constraint from tblEmployee
alter table tblEmployee
drop constraint chkMiddleName;

------------------------------------------------------------

-- Start a transaction block
begin tran

    -- Insert a row with a middle name containing a dot
    -- This is testing the check constraint logic (if it exists)
    insert into tblEmployee
    values (2003, 'A', 'B.', 'C', 'D', '2014-01-01', 'Accounts');

    -- View the inserted row within the transaction
    select * 
    from tblEmployee 
    where EmpNumber = 2003;

-- Undo the transaction (removes inserted row)
rollback tran;

------------------------------------------------------------

-- Add a CHECK constraint on DateOfBirth
-- Ensures employees are born between 1900-01-01 and today
alter table tblEmployee with nocheck
add constraint chkDateOfBirth 
check (DateOfBirth between '1900-01-01' and getdate());

------------------------------------------------------------

-- Start another transaction to test invalid data
begin tran

    -- Attempt to insert a future birth date (invalid under constraint)
    insert into tblEmployee
    values (2003, 'A', 'B', 'C', 'D', '2115-01-01', 'Accounts');

    -- Check if the row was inserted
    select * 
    from tblEmployee 
    where EmpNumber = 2003;

-- Roll back changes so table remains unchanged
rollback tran;

------------------------------------------------------------

-- Create a new table with a CHECK constraint on EmpMiddleName
create table tblEmployee2
(
    EmpMiddleName varchar(50) null,
    constraint EmpMiddleName check
    (
        REPLACE(EmpMiddleName, '.', '') = EmpMiddleName 
        or EmpMiddleName is null
    )
);

------------------------------------------------------------

-- Drop the test table
drop table tblEmployee2;

------------------------------------------------------------

-- Remove constraints from tblEmployee and tblTransaction

alter table tblEmployee
drop constraint chkDateOfBirth;

alter table tblEmployee
drop constraint chkMiddleName;

alter table tblTransaction
drop constraint chkAmount;