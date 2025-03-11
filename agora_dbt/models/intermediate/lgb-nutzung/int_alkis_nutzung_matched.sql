{{ config(
    materialized='table',
    alias='int_alkis_nutzung_matched',
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
        -- STRING_AGG(DISTINCT n."clean_nutzart") AS nutzart_values 
        STRING_AGG(n."clean_nutzart"::TEXT, ',') AS nutzart_values 
    FROM 
        alkis p
    JOIN 
        nutzung n 
    ON 
        ST_Intersects(p.geom, n.geom)
    WHERE
        ST_Area(ST_Intersection(ST_MakeValid(p.geom), ST_MakeValid(n.geom))) > 1
    GROUP BY 
        p."UUID"  -- Sadece UUID ile grupladık
)
SELECT * FROM intersection_table