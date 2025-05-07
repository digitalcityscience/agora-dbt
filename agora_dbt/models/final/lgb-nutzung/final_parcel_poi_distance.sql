{{ config(
    materialized='table',
    alias='final_parcel_poi_distance',
    post_hook=[
        "CREATE INDEX IF NOT EXISTS idx_poi_parcel_uuid ON {{ this }} (\"UUID\")"
    ]
) }}

WITH parcels AS (
  SELECT 
    a.*,
    p.center_point
  FROM {{ ref('final_alkis_nutzung_result') }} a
  LEFT JOIN {{ ref('stg_parcel_center_points') }} p
    ON a."UUID" = p.parcel_uuid
),

airport_dist AS (
  SELECT 
    p."UUID",
    ROUND(ST_Distance(p.center_point, poi.geom_25832)::numeric, 3) AS dist_airport
  FROM parcels p
  LEFT JOIN LATERAL (
    SELECT geom_25832 FROM (
      SELECT geom_25832 FROM {{ ref('stg_poi_all') }} WHERE poi_type = 'airport' AND ST_DWithin(p.center_point, geom_25832, 5000)
      UNION ALL
      SELECT geom_25832 FROM {{ ref('stg_poi_all') }} WHERE poi_type = 'airport' AND ST_DWithin(p.center_point, geom_25832, 10000)
        AND NOT EXISTS (
          SELECT 1 FROM {{ ref('stg_poi_all') }} sub WHERE poi_type = 'airport' AND ST_DWithin(p.center_point, sub.geom_25832, 5000)
        )
      UNION ALL
      SELECT geom_25832 FROM {{ ref('stg_poi_all') }} WHERE poi_type = 'airport'
        AND NOT EXISTS (
          SELECT 1 FROM {{ ref('stg_poi_all') }} sub WHERE poi_type = 'airport' AND ST_DWithin(p.center_point, sub.geom_25832, 10000)
        )
    ) poi
    ORDER BY geom_25832 <-> p.center_point
    LIMIT 1
  ) poi ON TRUE
),

bus_stop_dist AS (
  SELECT 
    p."UUID",
    ROUND(ST_Distance(p.center_point, poi.geom_25832)::numeric, 3) AS dist_bus_stop
  FROM parcels p
  LEFT JOIN LATERAL (
    SELECT geom_25832 FROM (
      SELECT geom_25832 FROM {{ ref('stg_poi_all') }} WHERE poi_type = 'bus_stop' AND ST_DWithin(p.center_point, geom_25832, 5000)
      UNION ALL
      SELECT geom_25832 FROM {{ ref('stg_poi_all') }} WHERE poi_type = 'bus_stop' AND ST_DWithin(p.center_point, geom_25832, 10000)
        AND NOT EXISTS (
          SELECT 1 FROM {{ ref('stg_poi_all') }} sub WHERE poi_type = 'bus_stop' AND ST_DWithin(p.center_point, sub.geom_25832, 5000)
        )
      UNION ALL
      SELECT geom_25832 FROM {{ ref('stg_poi_all') }} WHERE poi_type = 'bus_stop'
        AND NOT EXISTS (
          SELECT 1 FROM {{ ref('stg_poi_all') }} sub WHERE poi_type = 'bus_stop' AND ST_DWithin(p.center_point, sub.geom_25832, 10000)
        )
    ) poi
    ORDER BY geom_25832 <-> p.center_point
    LIMIT 1
  ) poi ON TRUE
),

fire_dept_dist AS (
  SELECT 
    p."UUID",
    ROUND(ST_Distance(p.center_point, poi.geom_25832)::numeric, 3) AS dist_fire_departments
  FROM parcels p
  LEFT JOIN LATERAL (
    SELECT geom_25832 FROM (
      SELECT geom_25832 FROM {{ ref('stg_poi_all') }} WHERE poi_type = 'fire_dept' AND ST_DWithin(p.center_point, geom_25832, 5000)
      UNION ALL
      SELECT geom_25832 FROM {{ ref('stg_poi_all') }} WHERE poi_type = 'fire_dept' AND ST_DWithin(p.center_point, geom_25832, 10000)
        AND NOT EXISTS (
          SELECT 1 FROM {{ ref('stg_poi_all') }} sub WHERE poi_type = 'fire_dept' AND ST_DWithin(p.center_point, sub.geom_25832, 5000)
        )
      UNION ALL
      SELECT geom_25832 FROM {{ ref('stg_poi_all') }} WHERE poi_type = 'fire_dept'
        AND NOT EXISTS (
          SELECT 1 FROM {{ ref('stg_poi_all') }} sub WHERE poi_type = 'fire_dept' AND ST_DWithin(p.center_point, sub.geom_25832, 10000)
        )
    ) poi
    ORDER BY geom_25832 <-> p.center_point
    LIMIT 1
  ) poi ON TRUE
),

hospitals_dist AS (
  SELECT 
    p."UUID",
    ROUND(ST_Distance(p.center_point, poi.geom_25832)::numeric, 3) AS dist_hospitals
  FROM parcels p
  LEFT JOIN LATERAL (
    SELECT geom_25832 FROM (
      SELECT geom_25832 FROM {{ ref('stg_poi_all') }} WHERE poi_type = 'hospitals' AND ST_DWithin(p.center_point, geom_25832, 5000)
      UNION ALL
      SELECT geom_25832 FROM {{ ref('stg_poi_all') }} WHERE poi_type = 'hospitals' AND ST_DWithin(p.center_point, geom_25832, 10000)
        AND NOT EXISTS (
          SELECT 1 FROM {{ ref('stg_poi_all') }} sub WHERE poi_type = 'hospitals' AND ST_DWithin(p.center_point, sub.geom_25832, 5000)
        )
      UNION ALL
      SELECT geom_25832 FROM {{ ref('stg_poi_all') }} WHERE poi_type = 'hospitals'
        AND NOT EXISTS (
          SELECT 1 FROM {{ ref('stg_poi_all') }} sub WHERE poi_type = 'hospitals' AND ST_DWithin(p.center_point, sub.geom_25832, 10000)
        )
    ) poi
    ORDER BY geom_25832 <-> p.center_point
    LIMIT 1
  ) poi ON TRUE
),

kindergarten_dist AS (
  SELECT 
    p."UUID",
    ROUND(ST_Distance(p.center_point, poi.geom_25832)::numeric, 3) AS dist_kindergarten
  FROM parcels p
  LEFT JOIN LATERAL (
    SELECT geom_25832 FROM (
      SELECT geom_25832 FROM {{ ref('stg_poi_all') }} WHERE poi_type = 'kindergarten' AND ST_DWithin(p.center_point, geom_25832, 5000)
      UNION ALL
      SELECT geom_25832 FROM {{ ref('stg_poi_all') }} WHERE poi_type = 'kindergarten' AND ST_DWithin(p.center_point, geom_25832, 10000)
        AND NOT EXISTS (
          SELECT 1 FROM {{ ref('stg_poi_all') }} sub WHERE poi_type = 'kindergarten' AND ST_DWithin(p.center_point, sub.geom_25832, 5000)
        )
      UNION ALL
      SELECT geom_25832 FROM {{ ref('stg_poi_all') }} WHERE poi_type = 'kindergarten'
        AND NOT EXISTS (
          SELECT 1 FROM {{ ref('stg_poi_all') }} sub WHERE poi_type = 'kindergarten' AND ST_DWithin(p.center_point, sub.geom_25832, 10000)
        )
    ) poi
    ORDER BY geom_25832 <-> p.center_point
    LIMIT 1
  ) poi ON TRUE
),

pharmacies_dist AS (
  SELECT 
    p."UUID",
    ROUND(ST_Distance(p.center_point, poi.geom_25832)::numeric, 3) AS dist_pharmacies
  FROM parcels p
  LEFT JOIN LATERAL (
    SELECT geom_25832 FROM (
      SELECT geom_25832 FROM {{ ref('stg_poi_all') }} WHERE poi_type = 'pharmacies' AND ST_DWithin(p.center_point, geom_25832, 5000)
      UNION ALL
      SELECT geom_25832 FROM {{ ref('stg_poi_all') }} WHERE poi_type = 'pharmacies' AND ST_DWithin(p.center_point, geom_25832, 10000)
        AND NOT EXISTS (
          SELECT 1 FROM {{ ref('stg_poi_all') }} sub WHERE poi_type = 'pharmacies' AND ST_DWithin(p.center_point, sub.geom_25832, 5000)
        )
      UNION ALL
      SELECT geom_25832 FROM {{ ref('stg_poi_all') }} WHERE poi_type = 'pharmacies'
        AND NOT EXISTS (
          SELECT 1 FROM {{ ref('stg_poi_all') }} sub WHERE poi_type = 'pharmacies' AND ST_DWithin(p.center_point, sub.geom_25832, 10000)
        )
    ) poi
    ORDER BY geom_25832 <-> p.center_point
    LIMIT 1
  ) poi ON TRUE
),

supermarket_dist AS (
  SELECT 
    p."UUID",
    ROUND(ST_Distance(p.center_point, poi.geom_25832)::numeric, 3) AS dist_supermarket
  FROM parcels p
  LEFT JOIN LATERAL (
    SELECT geom_25832 FROM (
      SELECT geom_25832 FROM {{ ref('stg_poi_all') }} WHERE poi_type = 'supermarket' AND ST_DWithin(p.center_point, geom_25832, 5000)
      UNION ALL
      SELECT geom_25832 FROM {{ ref('stg_poi_all') }} WHERE poi_type = 'supermarket' AND ST_DWithin(p.center_point, geom_25832, 10000)
        AND NOT EXISTS (
          SELECT 1 FROM {{ ref('stg_poi_all') }} sub WHERE poi_type = 'supermarket' AND ST_DWithin(p.center_point, sub.geom_25832, 5000)
        )
      UNION ALL
      SELECT geom_25832 FROM {{ ref('stg_poi_all') }} WHERE poi_type = 'supermarket'
        AND NOT EXISTS (
          SELECT 1 FROM {{ ref('stg_poi_all') }} sub WHERE poi_type = 'supermarket' AND ST_DWithin(p.center_point, sub.geom_25832, 10000)
        )
    ) poi
    ORDER BY geom_25832 <-> p.center_point
    LIMIT 1
  ) poi ON TRUE
),

train_station_dist AS (
  SELECT 
    p."UUID",
    ROUND(ST_Distance(p.center_point, poi.geom_25832)::numeric, 3) AS dist_train_station
  FROM parcels p
  LEFT JOIN LATERAL (
    SELECT geom_25832 FROM (
      SELECT geom_25832 FROM {{ ref('stg_poi_all') }} WHERE poi_type = 'train_station' AND ST_DWithin(p.center_point, geom_25832, 5000)
      UNION ALL
      SELECT geom_25832 FROM {{ ref('stg_poi_all') }} WHERE poi_type = 'train_station' AND ST_DWithin(p.center_point, geom_25832, 10000)
        AND NOT EXISTS (
          SELECT 1 FROM {{ ref('stg_poi_all') }} sub WHERE poi_type = 'train_station' AND ST_DWithin(p.center_point, sub.geom_25832, 5000)
        )
      UNION ALL
      SELECT geom_25832 FROM {{ ref('stg_poi_all') }} WHERE poi_type = 'train_station'
        AND NOT EXISTS (
          SELECT 1 FROM {{ ref('stg_poi_all') }} sub WHERE poi_type = 'train_station' AND ST_DWithin(p.center_point, sub.geom_25832, 10000)
        )
    ) poi
    ORDER BY geom_25832 <-> p.center_point
    LIMIT 1
  ) poi ON TRUE
)

SELECT 
  p.*,
  ad.dist_airport,
  bd.dist_bus_stop,
  fd.dist_fire_departments,
  hd.dist_hospitals,
  kd.dist_kindergarten,
  pd.dist_pharmacies,
  sd.dist_supermarket,
  td.dist_train_station
FROM parcels p
LEFT JOIN airport_dist ad ON p."UUID" = ad."UUID"
LEFT JOIN bus_stop_dist bd ON p."UUID" = bd."UUID"
LEFT JOIN fire_dept_dist fd ON p."UUID" = fd."UUID"
LEFT JOIN hospitals_dist hd ON p."UUID" = hd."UUID"
LEFT JOIN kindergarten_dist kd ON p."UUID" = kd."UUID"
LEFT JOIN pharmacies_dist pd ON p."UUID" = pd."UUID"
LEFT JOIN supermarket_dist sd ON p."UUID" = sd."UUID"
LEFT JOIN train_station_dist td ON p."UUID" = td."UUID"
