BEGIN TRAN

-- ============================================
-- Create table to store spatial geometry objects
-- ============================================
CREATE TABLE tblGeom
(
    -- geometry column stores spatial shapes (lines, polygons, circles, etc.)
    GXY geometry,

    -- description of each shape
    Description varchar(20),

    -- primary key with identity starting at 5 (increments by 1)
    IDtblGeom int CONSTRAINT PK_tblGeom 
    PRIMARY KEY IDENTITY(5,1)
)

-- ============================================
-- Insert different geometry objects into table
-- ============================================

INSERT INTO tblGeom
VALUES 

-- Simple straight line
(geometry::STGeomFromText('LINESTRING (1 1, 5 5)', 0), 'First line'),

-- Complex line with multiple bends/points
(geometry::STGeomFromText('LINESTRING (5 1, 1 4, 2 5, 5 1)', 0), 'Second line'),

-- Multiple disconnected lines stored in one object
(geometry::STGeomFromText('MULTILINESTRING ((1 5, 2 6), (1 4, 2 5))', 0), 'Third line'),

-- First polygon shape
(geometry::STGeomFromText('POLYGON ((4 1, 6 3, 8 3, 6 1, 4 1))', 0), 'Polygon'),

-- Second polygon (used later for spatial comparisons)
(geometry::STGeomFromText('POLYGON ((5 2, 7 2, 7 4, 5 4, 5 2))', 0), 'Second Polygon'),

-- Circular geometry shape
(geometry::STGeomFromText('CIRCULARSTRING (1 0, 0 1, -1 0, 0 -1, 1 0)', 0), 'Circle')


-- View all inserted spatial objects
SELECT * FROM tblGeom



-- ============================================
-- SPATIAL FILTERING
-- ============================================
-- Filter checks which geometries intersect a given shape.
-- Returns:
--   1 = geometry intersects filter shape
--   0 = does NOT intersect

SELECT *  
FROM tblGeom
WHERE GXY.Filter(
    -- filter polygon (spatial area of interest)
    geometry::Parse('POLYGON((2 1, 1 4, 4 4, 4 1, 2 1))')
) = 1

-- Add the filter polygon itself into the result set for visualization
UNION ALL

SELECT 
    geometry::STGeomFromText(
        'POLYGON((2 1, 1 4, 4 4, 4 1, 2 1))', 0
    ),
    'Filter',
    0



-- ============================================
-- SPATIAL AGGREGATION: UNION AGGREGATE
-- ============================================
-- Combines ALL geometries into ONE single geometry object
-- Internal boundaries between shapes are removed

DECLARE @i AS geometry

SELECT @i = geometry::UnionAggregate(GXY)
FROM tblGeom

-- Shows the merged geometry result
SELECT @i AS CombinedShapes



-- ============================================
-- SPATIAL AGGREGATION: COLLECTION AGGREGATE
-- ============================================
-- Groups all geometries into ONE object
-- BUT keeps each geometry separate inside the collection

DECLARE @j AS geometry

SELECT @j = geometry::CollectionAggregate(GXY)
FROM tblGeom

-- Displays grouped (non-merged) geometries
SELECT @j



-- ============================================
-- SPATIAL AGGREGATES: BOUNDING SHAPES
-- ============================================

-- UNION result (from earlier) for comparison
SELECT @i AS CombinedShapes

-- ENVELOPE AGGREGATE:
-- Creates the smallest rectangle that contains ALL geometries
-- (axis-aligned bounding box)
SELECT geometry::EnvelopeAggregate(GXY) AS Envelope
FROM tblGeom

-- CONVEX HULL AGGREGATE:
-- Creates the tightest outer boundary wrapping around all points
-- Produces a smoother “rubber band” shape around data
SELECT geometry::ConvexHullAggregate(GXY) AS Envelope
FROM tblGeom



ROLLBACK TRAN