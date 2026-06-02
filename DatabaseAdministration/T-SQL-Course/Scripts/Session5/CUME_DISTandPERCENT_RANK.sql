select A.EmpNumber, A.AttendanceMonth, 
A.NumberAttendance, 
CUME_DIST()    over(partition by E.EmpNumber 
               order by A.AttendanceMonth) as MyCume_Dist,
PERCENT_RANK() over(partition by E.EmpNumber 
                order by A.AttendanceMonth) as MyPercent_Rank,
cast(row_number() over(partition by E.EmpNumber order by A.AttendanceMonth) as decimal(9,5))
/ count(*) over(partition by E.EmpNumber) as CalcCume_Dist,
cast(row_number() over(partition by E.EmpNumber order by A.AttendanceMonth) - 1 as decimal(9,5))
/ (count(*) over(partition by E.EmpNumber) - 1) as CalcPercent_Rank
from tblEmployee as E join tblAttendance as A
on E.EmpNumber = A.EmpNumber
