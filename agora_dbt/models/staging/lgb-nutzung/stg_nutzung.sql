{{ config(
    alias='stg_nutzung',
    materialized='view'

) }}

SELECT 
    "oid_1",
    -- There is different values for same classs within nutzart column. we need to clean it up
    -- We remove space and make it lower case to make it unique.
    regexp_replace(lower("nutzart"), '\s+', '', 'g') AS clean_nutzart,
    "geom"
FROM 
    {{ source(target.schema, "Nutzung_Flurstuecke") }}
WHERE 
    "nutzart" IS NOT NULL