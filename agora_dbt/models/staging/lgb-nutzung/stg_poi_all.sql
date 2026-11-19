{{ config(
    materialized='table',
    alias='stg_poi_all',
    post_hook=[
        "CREATE INDEX IF NOT EXISTS idx_stg_poi_all_geom_25832 ON {{ this }} USING GIST(geom_25832)"
    ]
) }}

SELECT 
    'airport' AS poi_type,
    geom,
    ST_Transform(geom, 25832) AS geom_25832
FROM {{ source(target.schema, 'POI-Airport') }}

UNION ALL

SELECT 
    'bus_stop' AS poi_type,
    geom,
    ST_Transform(geom, 25832) AS geom_25832
FROM {{ source(target.schema, 'POI-BusStop') }}

UNION ALL

SELECT 
    'fire_dept' AS poi_type,
    geom,
    ST_Transform(geom, 25832) AS geom_25832
FROM {{ source(target.schema, 'POI-Fire_departments') }}

UNION ALL

SELECT 
    'hospitals' AS poi_type,
    geom,
    ST_Transform(geom, 25832) AS geom_25832
FROM {{ source(target.schema, 'POI-Hospitals') }}

UNION ALL

SELECT 
    'kindergarten' AS poi_type,
    geom,
    ST_Transform(geom, 25832) AS geom_25832
FROM {{ source(target.schema, 'POI-Kindergarten') }}

UNION ALL

SELECT 
    'pharmacies' AS poi_type,
    geom,
    ST_Transform(geom, 25832) AS geom_25832
FROM {{ source(target.schema, 'POI-Pharmacies') }}

UNION ALL

SELECT 
    'supermarket' AS poi_type,
    geom,
    ST_Transform(geom, 25832) AS geom_25832
FROM {{ source(target.schema, 'POI-Supermarket') }}

UNION ALL

SELECT 
    'train_station' AS poi_type,
    geom,
    ST_Transform(geom, 25832) AS geom_25832
FROM {{ source(target.schema, 'POI-TrainStation') }}
