{{ config(
    alias='stg_alkis',
    materialized='view'
) }}

{% set today_date = var('today_date', modules.datetime.datetime.today().strftime('%Y%m%d')) %}
-- {% set alkis_dataset_name = "ALKIS_2023_Flurstuecke_Flaechen_parcels" %}

WITH alkis_latest AS (
    SELECT 
        *, 
        ST_MakeValid(geom) AS geom_valid,
        '{{ today_date }}' AS data_version
    -- FROM {{ source(target.schema, alkis_dataset_name) }}
    FROM {{ source(target.schema, var('alkis_dataset_name')) }}


)

SELECT * FROM alkis_latest