-- ============================================
-- 1. Detail level:
--    Total attendance per Department,
--    Employee, and Month
-- ============================================

SELECT 
    E.Department, 
    E.EmpNumber, 
    A.AttendanceMonth AS AttendanceMonth,

    -- total attendance for this employee in this month
    SUM(A.NumberAttendance) AS NumberAttendance

FROM tblEmployee AS E
JOIN tblAttendance AS A
    ON E.EmpNumber = A.EmpNumber

-- group by Department + Employee + Month
GROUP BY 
    E.Department, 
    E.EmpNumber, 
    A.AttendanceMonth


UNION


-- ============================================
-- 2. Employee totals:
--    Total attendance per Employee
--    across ALL months
-- ============================================

SELECT 
    E.Department, 
    E.EmpNumber,

    -- no specific month anymore
    NULL AS AttendanceMonth,

    -- total attendance for the employee
    SUM(A.NumberAttendance) AS TotalAttendance

FROM tblEmployee AS E
JOIN tblAttendance AS A
    ON E.EmpNumber = A.EmpNumber

-- grouped only by Department + Employee
GROUP BY 
    E.Department, 
    E.EmpNumber


UNION


-- ============================================
-- 3. Department totals:
--    Total attendance for the whole department
-- ============================================

SELECT 
    E.Department,

    -- no specific employee
    NULL,

    -- no specific month
    NULL AS AttendanceMonth,

    -- total attendance for the department
    SUM(A.NumberAttendance) AS TotalAttendance

FROM tblEmployee AS E
JOIN tblAttendance AS A
    ON E.EmpNumber = A.EmpNumber

-- grouped only by Department
GROUP BY 
    E.Department


UNION


-- ============================================
-- 4. Grand total:
--    Total attendance for ALL departments,
--    employees, and months
-- ============================================

SELECT 
    NULL,    -- no department
    NULL,    -- no employee
    NULL AS AttendanceMonth,

    -- overall total attendance
    SUM(A.NumberAttendance) AS TotalAttendance

FROM tblEmployee AS E
JOIN tblAttendance AS A
    ON E.EmpNumber = A.EmpNumber


-- ============================================
-- Final sorting of the combined results
-- ============================================

ORDER BY 
    Department, 
    EmpNumber, 
    AttendanceMonth;