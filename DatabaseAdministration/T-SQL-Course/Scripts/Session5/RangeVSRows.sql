--Objective: The objective of this query is to calculate cumulative (running) attendance totals per employee over time, using two different window frame methods to show how SQL Server behaves differently with ROWS vs RANGE.
select A.EmpNumber, A.AttendanceMonth, A.NumberAttendance

-- Running total using ROWS frame (physical row-based calculation)
,sum(A.NumberAttendance) 
over(
    partition by A.EmpNumber, year(A.AttendanceMonth) 
    order by A.AttendanceMonth 
    rows between current row and unbounded following   -- start at current row, include ALL rows after it
) as RowsTotal

-- Running total using RANGE frame (logical value-based calculation)
,sum(A.NumberAttendance) 
over(
    partition by A.EmpNumber, year(A.AttendanceMonth) 
    order by A.AttendanceMonth 
    range between current row and unbounded following   -- includes all rows with same ordering value and after
) as RangeTotal

from tblEmployee as E 
join (
    -- duplicate table using UNION ALL (keeps duplicates, doubles rows)
    select * from tblAttendance 
    union all 
    select * from tblAttendance
) as A  
on E.EmpNumber = A.EmpNumber

--where A.AttendanceMonth < '20150101'

order by A.EmpNumber, A.AttendanceMonth


-------------------------------------------------------
-- WINDOW FRAME EXPLANATION NOTES

-- UNBOUNDED PRECEDING  = start from the first row in the partition
-- CURRENT ROW          = the row currently being processed
-- UNBOUNDED FOLLOWING  = go all the way to the last row in the partition

-- ROWS BETWEEN current row AND unbounded following
-- → physical row-based window (each row treated individually)

-- RANGE BETWEEN current row AND unbounded following
-- → logical grouping (rows with same ORDER BY value are treated together)

-- FULL RANGE OPTIONS:
-- UNBOUNDED PRECEDING AND CURRENT ROW   → running total up to current row
-- CURRENT ROW AND UNBOUNDED FOLLOWING   → reverse running total (future accumulation)
-- UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING → total of entire partition