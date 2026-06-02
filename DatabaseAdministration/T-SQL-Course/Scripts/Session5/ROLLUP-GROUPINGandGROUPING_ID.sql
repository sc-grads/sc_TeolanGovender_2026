select E.Department, E.EmpNumber, A.AttendanceMonth as AttendanceMonth, sum(A.NumberAttendance) as NumberAttendance,
GROUPING(E.EmpNumber) AS EmpNumberGroupedBy,
GROUPING_ID(E.Department, E.EmpNumber, A.AttendanceMonth) AS EmpNumberGroupedID
from tblEmployee as E join tblAttendance as A
on E.EmpNumber = A.EmpNumber
group by ROLLUP (E.Department, E.EmpNumber, A.AttendanceMonth)
order by Department, EmpNumber, AttendanceMonth
