BEGIN TRAN

-- ============================================
-- Create a table to store spatial geometry data
-- ============================================

CREATE TABLE tblGeom
(
    -- geometry column that stores shapes/objects
    GXY geometry,

    -- description of the shape
    Description varchar(20),

    -- primary key starting at 5 and increasing by 1
    IDtblGeom int CONSTRAINT PK_tblGeom 
    PRIMARY KEY IDENTITY(5,1)
)

-- ============================================
-- Insert different geometry types into the table
-- ============================================

INSERT INTO tblGeom
VALUES 

-- Simple line from point (1,1) to point (5,5)
(
    geometry::STGeomFromText(
        'LINESTRING (1 1, 5 5)', 0
    ),
    'First line'
),

-- A more complex line with multiple connected points
(
    geometry::STGeomFromText(
        'LINESTRING (5 1, 1 4, 2 5, 5 1)', 0
    ),
    'Second line'
),

-- Multiple separate lines stored in one geometry object
(
    geometry::STGeomFromText(
        'MULTILINESTRING ((1 5, 2 6), (1 4, 2 5))', 0
    ),
    'Third line'
),

-- Polygon shape (last point repeats first point to close shape)
(
    geometry::STGeomFromText(
        'POLYGON ((4 1, 6 3, 8 3, 6 1, 4 1))', 0
    ),
    'Polygon'
),

-- Circular shape using curved geometry
(
    geometry::STGeomFromText(
        'CIRCULARSTRING (1 0, 0 1, -1 0, 0 -1, 1 0)', 0
    ),
    'Circle'
)

-- View all inserted geometries
SELECT * FROM tblGeom



-- ============================================
-- Query information about each geometry
-- ============================================

SELECT 
    IDtblGeom,

    -- Returns the geometry type
    -- Example: LINESTRING, POLYGON, MULTILINESTRING
    GXY.STGeometryType() AS MyType,

    -- Returns the first point of the geometry
    GXY.STStartPoint().ToString() AS StartingPoint,

    -- Returns the last point of the geometry
    GXY.STEndPoint().ToString() AS EndingPoint,

    -- Returns point number 1 in the geometry
    GXY.STPointN(1).ToString() AS FirstPoint,

    -- Returns point number 2 in the geometry
    GXY.STPointN(2).ToString() AS SecondPoint,

    -- Returns X coordinate of first point
    GXY.STPointN(1).STX AS FirstPointX,

    -- Returns Y coordinate of first point
    GXY.STPointN(1).STY AS FirstPointY,

    -- Returns the outer boundary of the geometry
    -- Some geometry types may return empty results
    GXY.STBoundary().ToString() AS Boundary,

    -- Returns total length of the geometry
    -- Useful for lines and boundaries
    GXY.STLength() AS MyLength,

    -- Calculates and returns total number of points used in the geometry
    GXY.STNumPoints() AS NumberPoints

FROM tblGeom



-- ============================================
-- Store one geometry in a variable
-- ============================================

DECLARE @g AS geometry

-- Select geometry with ID 5 (First line)
SELECT @g = GXY 
FROM tblGeom 
WHERE IDtblGeom = 5



-- ============================================
-- Compare all geometries against @g
-- using spatial operations
-- ============================================

SELECT 
    IDtblGeom,

    -- Returns the overlapping/intersecting part
    -- between the current geometry and @g
    -- Returns empty if they do not intersect
    GXY.STIntersection(@g).ToString() AS Intersection,

    -- Returns shortest distance between shapes
    -- Returns 0 if shapes touch/intersect
    GXY.STDistance(@g) AS DistanceFromFirstLine

FROM tblGeom



-- ============================================
-- Combine two geometries into one result
-- ============================================

SELECT 

    -- Combines geometry from row ID 8
    -- with the geometry stored in @g
    -- Both shapes remain inside one geometry object
    GXY.STUnion(@g),

    -- Keep description from the original row
    Description

FROM tblGeom

-- Use only the polygon row
WHERE IDtblGeom = 8 



-- ============================================
-- Undo all changes made in this transaction
-- (table + inserted data will not be permanently saved)
-- ============================================

ROLLBACK TRAN