{{ config(
    materialized='table',
    alias='final_parcel_poi_distance'
) }}

WITH parcels AS (
  SELECT 
    *,
    "UUID" AS parcel_uuid,
    ST_Transform(ST_Centroid(geom), 25832) AS centroid
  FROM {{ ref('final_alkis_nutzung_result') }}
),

airport_dist AS (
  SELECT 
    p.parcel_uuid,
    ROUND(ST_Distance(p.centroid, ST_Transform(a.geom, 25832))::numeric, 3) AS dist_airport
  FROM parcels p
  LEFT JOIN LATERAL (
    SELECT geom
    FROM {{ source(target.schema, 'POI-Airport') }}
    ORDER BY p.centroid <-> ST_Transform(geom, 25832)
    LIMIT 1
  ) a ON true
),

busstop_dist AS (
  SELECT 
    p.parcel_uuid,
    ROUND(ST_Distance(p.centroid, ST_Transform(a.geom, 25832))::numeric, 3) AS dist_bus_stop
  FROM parcels p
  LEFT JOIN LATERAL (
    SELECT geom
    FROM {{ source(target.schema, 'POI-BusStop') }}
    ORDER BY p.centroid <-> ST_Transform(geom, 25832)
    LIMIT 1
  ) a ON true
),

firedept_dist AS (
  SELECT 
    p.parcel_uuid,
    ROUND(ST_Distance(p.centroid, ST_Transform(a.geom, 25832))::numeric, 3) AS dist_fire_departments
  FROM parcels p
  LEFT JOIN LATERAL (
    SELECT geom
    FROM {{ source(target.schema, 'POI-Fire_departments') }}
    ORDER BY p.centroid <-> ST_Transform(geom, 25832)
    LIMIT 1
  ) a ON true
),

hospitals_dist AS (
  SELECT 
    p.parcel_uuid,
    ROUND(ST_Distance(p.centroid, ST_Transform(a.geom, 25832))::numeric, 3) AS dist_hospitals
  FROM parcels p
  LEFT JOIN LATERAL (
    SELECT geom
    FROM {{ source(target.schema, 'POI-Hospitals') }}
    ORDER BY p.centroid <-> ST_Transform(geom, 25832)
    LIMIT 1
  ) a ON true
),

kindergarten_dist AS (
  SELECT 
    p.parcel_uuid,
    ROUND(ST_Distance(p.centroid, ST_Transform(a.geom, 25832))::numeric, 3) AS dist_kindergarten
  FROM parcels p
  LEFT JOIN LATERAL (
    SELECT geom
    FROM {{ source(target.schema, 'POI-Kindergarten') }}
    ORDER BY p.centroid <-> ST_Transform(geom, 25832)
    LIMIT 1
  ) a ON true
),

pharmacies_dist AS (
  SELECT 
    p.parcel_uuid,
    ROUND(ST_Distance(p.centroid, ST_Transform(a.geom, 25832))::numeric, 3) AS dist_pharmacies
  FROM parcels p
  LEFT JOIN LATERAL (
    SELECT geom
    FROM {{ source(target.schema, 'POI-Pharmacies') }}
    ORDER BY p.centroid <-> ST_Transform(geom, 25832)
    LIMIT 1
  ) a ON true
),

supermarket_dist AS (
  SELECT 
    p.parcel_uuid,
    ROUND(ST_Distance(p.centroid, ST_Transform(a.geom, 25832))::numeric, 3) AS dist_supermarket
  FROM parcels p
  LEFT JOIN LATERAL (
    SELECT geom
    FROM {{ source(target.schema, 'POI-Supermarket') }}
    ORDER BY p.centroid <-> ST_Transform(geom, 25832)
    LIMIT 1
  ) a ON true
),

trainstation_dist AS (
  SELECT 
    p.parcel_uuid,
    ROUND(ST_Distance(p.centroid, ST_Transform(a.geom, 25832))::numeric, 3) AS dist_train_station
  FROM parcels p
  LEFT JOIN LATERAL (
    SELECT geom
    FROM {{ source(target.schema, 'POI-TrainStation') }}
    ORDER BY p.centroid <-> ST_Transform(geom, 25832)
    LIMIT 1
  ) a ON true
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
LEFT JOIN airport_dist ad ON p.parcel_uuid = ad.parcel_uuid
LEFT JOIN busstop_dist bd ON p.parcel_uuid = bd.parcel_uuid
LEFT JOIN firedept_dist fd ON p.parcel_uuid = fd.parcel_uuid
LEFT JOIN hospitals_dist hd ON p.parcel_uuid = hd.parcel_uuid
LEFT JOIN kindergarten_dist kd ON p.parcel_uuid = kd.parcel_uuid
LEFT JOIN pharmacies_dist pd ON p.parcel_uuid = pd.parcel_uuid
LEFT JOIN supermarket_dist sd ON p.parcel_uuid = sd.parcel_uuid
LEFT JOIN trainstation_dist td ON p.parcel_uuid = td.parcel_uuid
