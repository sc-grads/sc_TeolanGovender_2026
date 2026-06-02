select E.Department, E.EmpNumber, A.AttendanceMonth as AttendanceMonth, sum(A.NumberAttendance) as NumberAttendance,
GROUPING(E.EmpNumber) AS EmpNumberGroupedBy,
GROUPING_ID(E.Department, E.EmpNumber, A.AttendanceMonth) AS EmpNumberGroupedID
from tblEmployee as E join tblAttendance as A
on E.EmpNumber = A.EmpNumber
group by GROUPING SETS ((E.Department, E.EmpNumber, A.AttendanceMonth), (E.Department), ())
order by coalesce(Department, 'zzzzzzz'), coalesce(E.EmpNumber, 99999), coalesce(AttendanceMonth,'2100-01-01')

select E.Department, E.EmpNumber, A.AttendanceMonth as AttendanceMonth, sum(A.NumberAttendance) as NumberAttendance,
GROUPING(E.EmpNumber) AS EmpNumberGroupedBy,
GROUPING_ID(E.Department, E.EmpNumber, A.AttendanceMonth) AS EmpNumberGroupedID
from tblEmployee as E join tblAttendance as A
on E.EmpNumber = A.EmpNumber
group by GROUPING SETS ((E.Department, E.EmpNumber, A.AttendanceMonth), (E.Department), ())
order by CASE WHEN Department       IS NULL THEN 1 ELSE 0 END, Department, 
         CASE WHEN E.EmpNumber IS NULL THEN 1 ELSE 0 END, E.EmpNumber, 
         CASE WHEN AttendanceMonth  IS NULL THEN 1 ELSE 0 END, AttendanceMonth
