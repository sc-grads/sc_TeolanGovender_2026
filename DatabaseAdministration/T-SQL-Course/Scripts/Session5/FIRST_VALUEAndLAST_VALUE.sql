SELECT 
    A.EmpNumber, 
    A.AttendanceMonth,
    A.NumberAttendance,

    -- FIRST_VALUE returns the first NumberAttendance value
    -- for each employee when ordered by AttendanceMonth
    FIRST_VALUE(NumberAttendance) OVER (
        PARTITION BY E.EmpNumber              -- split data per employee
        ORDER BY A.AttendanceMonth           -- order months from first to last
    ) AS FirstMonth,

    -- LAST_VALUE returns the last NumberAttendance value
    -- BUT we must define the full window explicitly,
    -- otherwise SQL only looks up to the current row
    LAST_VALUE(NumberAttendance) OVER (
        PARTITION BY E.EmpNumber              -- each employee separately
        ORDER BY A.AttendanceMonth           -- chronological order of months

        -- this expands the window to include ALL rows in the partition
        -- (from first month to last month)
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) AS LastMonth

FROM tblEmployee AS E 
JOIN tblAttendance AS A
    ON E.EmpNumber = A.EmpNumber;