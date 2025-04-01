{{ config(
    materialized='view',
    alias='int_alkis_lgb_matched',
) }}

WITH 
alkis AS (
    SELECT * FROM {{ ref('stg_alkis') }}
),
lgb AS (
    SELECT * FROM {{ ref('stg_lgb_union') }} 
),
intersected_data AS (
    SELECT 
        a.id AS alkis_id,  
        a."ZAE" AS alkis_zae_id,  
        b.art, 
        b.typ  
    FROM 
        alkis a
    JOIN 
        lgb b 
    ON 
        a."ZAE" = b.flurst
    WHERE 
        ST_Intersects(ST_MakeValid(a.geom), ST_MakeValid(b.geom))
        AND ABS(ST_Area(ST_Intersection(ST_MakeValid(a.geom), ST_MakeValid(b.geom))) - a."Shape_Area") <= 20
),
distinct_values AS (
    -- Her bir alkis_id için benzersiz art ve typ değerlerini ayıkla
    SELECT DISTINCT 
        alkis_id,  
        alkis_zae_id,  
        art,  
        typ  
    FROM 
        intersected_data
),
matched_parcels AS (
    SELECT 
        alkis_id,  
        alkis_zae_id,  
        -- Benzersiz art ve typ değerlerini birleştir
        STRING_AGG(art::TEXT, ',') AS lgb_art,  
        STRING_AGG(typ::TEXT, ',') AS lgb_typ    
    FROM 
        distinct_values
    GROUP BY 
        alkis_id, alkis_zae_id
)
SELECT * FROM matched_parcels