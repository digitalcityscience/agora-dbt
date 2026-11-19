{{ config(
    alias='stg_nutzung',
    materialized='table',
    post_hook=[
        "CREATE INDEX IF NOT EXISTS idx_nutzung_geom_valid ON {{ this }} USING GIST(geom_valid)"
    ]
) }}

SELECT 
    "oid_1",
    regexp_replace(lower("nutzart"), '\s+', '', 'g') AS clean_nutzart,
    geom,
    ST_MakeValid(geom) AS geom_valid
FROM {{ source(target.schema, var('nutzung_dataset_name',)) }}
WHERE "nutzart" IS NOT NULL
