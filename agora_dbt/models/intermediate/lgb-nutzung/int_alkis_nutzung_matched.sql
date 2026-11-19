{{ config(
    materialized='table',
    alias='int_alkis_nutzung_matched',
    post_hook=[
        "CREATE INDEX IF NOT EXISTS idx_nutzung_parcel_uuid ON {{ this }} (parcel_uuid)"
    ]
) }}

WITH 
alkis AS (
    SELECT * FROM {{ ref('stg_alkis') }}
),
nutzung AS (
    SELECT * FROM {{ ref('stg_nutzung') }}
),
intersection_table AS (
    SELECT 
        p."UUID" AS parcel_uuid, 
        STRING_AGG(n."clean_nutzart"::TEXT, ',') AS nutzart_values 
    FROM alkis p
    JOIN nutzung n 
      ON p.geom_valid && n.geom_valid AND ST_Intersects(p.geom_valid, n.geom_valid)
    WHERE ST_Area(ST_Intersection(p.geom_valid, n.geom_valid)) > 1
    GROUP BY p."UUID"
)

SELECT * FROM intersection_table
