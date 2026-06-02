select A.EmpNumber, A.AttendanceMonth, A.NumberAttendance, 
SUM(A.NumberAttendance)
over(
	PARTITION BY E.EmpNumber
	ORDER BY A.AttendanceMonth
	ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
	) as RollingTotal
from tblEmployee as E join tblAttendance as A
on E.EmpNumber = A.EmpNumber

select A.EmpNumber, A.AttendanceMonth, 
A.NumberAttendance, 
SUM(A.NumberAttendance) over(PARTITION BY E.EmpNumber ORDER BY A.AttendanceMonth ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) as RollingTotal
from tblEmployee as E join tblAttendance as A
on E.EmpNumber = A.EmpNumber

select A.EmpNumber, A.AttendanceMonth, 
A.NumberAttendance, 
SUM(A.NumberAttendance) over(PARTITION BY E.EmpNumber ORDER BY A.AttendanceMonth ROWS BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING) as RollingTotal
from tblEmployee as E join tblAttendance as A
on E.EmpNumber = A.EmpNumber