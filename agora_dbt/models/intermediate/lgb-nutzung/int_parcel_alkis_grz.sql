{{ config(
    materialized='table',
    alias='int_parcel_alkis_grz',
    post_hook=[
        "CREATE INDEX IF NOT EXISTS idx_grz_parcel_uuid ON {{ this }} (parcel_uuid)"
    ]
) }}

WITH building_parts AS (
  SELECT 
    p."UUID" AS parcel_uuid,
    b.id AS building_id,
    b."GRF" AS building_grf,
    ST_Area(ST_Intersection(p.geom, b.geom)) AS intersect_area,
    ST_Area(b.geom) AS building_area,
    ST_Area(p.geom) AS parcel_area
  FROM {{ source(target.schema, var('alkis_dataset_name' )) }} p
  JOIN {{ source(target.schema, var('building_dataset_name')) }} AS b
    ON p.geom && b.geom AND ST_Intersects(p.geom, b.geom)
  WHERE b."GFK" NOT IN (2463, 2465, 1313, 2462, 2460)
),

building_ratios AS (
  SELECT
    parcel_uuid,
    building_id,
    building_grf,
    parcel_area,
    ROUND((intersect_area / building_area)::numeric, 4) AS area_ratio
  FROM building_parts
  WHERE intersect_area > 1 AND (intersect_area / building_area) > 0
),

grz_by_parcel AS (
  SELECT
    parcel_uuid,
    ROUND((SUM(building_grf * area_ratio) / MAX(parcel_area))::numeric, 4) AS grz_alkis
  FROM building_ratios
  GROUP BY parcel_uuid
),

building_ids AS (
  SELECT 
    parcel_uuid,
    STRING_AGG(building_id::text, ',' ORDER BY building_id) AS buildings
  FROM building_ratios
  GROUP BY parcel_uuid
)

SELECT
  g.parcel_uuid,
  g.grz_alkis,
  b.buildings
FROM grz_by_parcel g
LEFT JOIN building_ids b ON g.parcel_uuid = b.parcel_uuid
