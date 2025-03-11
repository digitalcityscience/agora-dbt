{{ config(
    materialized='table',
    alias='final_alkis_parcels_lgb_result',
) }}

WITH 
alkis AS (
    SELECT * FROM {{ ref('stg_alkis') }}
),
lgb_matched AS (
    SELECT * FROM {{ ref('int_alkis_lgb_matched') }}
)
SELECT 
    a.*, -- ALKIS+LGB all columns
    m.lgb_art AS lgb_art_values,  
    m.lgb_typ AS lgb_typ_values   
FROM 
    alkis a
LEFT JOIN 
    lgb_matched m
ON 
    a.id = m.alkis_id