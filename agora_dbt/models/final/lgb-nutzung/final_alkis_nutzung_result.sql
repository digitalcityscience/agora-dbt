{{ config(
    materialized='table',
    alias='final_alkis_nutzung_result',
    post_hook=[
        "CREATE INDEX IF NOT EXISTS idx_final_nutzung_uuid ON {{ this }} (parcel_uuid)"
    ]
) }}

WITH 
alkis AS (
    SELECT *, "UUID" AS parcel_uuid FROM {{ ref('final_alkis_parcels_lgb_result') }}
),

nutzung_matched AS (
    SELECT * FROM {{ ref('int_alkis_nutzung_matched') }}
)

SELECT 
    a.*,  -- ALKIS + LGB verilerinin tüm kolonlarını taşı
    n.nutzart_values AS nutzart_list_final  -- Nutzung bilgisi
FROM 
    alkis a
LEFT JOIN 
    nutzung_matched n
ON 
    a.parcel_uuid = n.parcel_uuid
