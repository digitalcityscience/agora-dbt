{{ config(
    materialized='table',
    alias='final_alkis_nutzung_result',
) }}

WITH 
alkis AS (
    SELECT * FROM {{ ref('final_alkis_parcels_lgb_result') }}
),

nutzung_matched AS (
    SELECT * FROM {{ ref('int_alkis_nutzung_matched') }}
)


SELECT 
    a.*,  -- ALKIS’in tüm kolonlarını koru
    n.nutzart_values AS nutzart_list_final  -- Nutzung verilerini sakla
FROM 
    alkis a
LEFT JOIN 
    nutzung_matched n
ON 
    a."UUID" = n.parcel_uuid
