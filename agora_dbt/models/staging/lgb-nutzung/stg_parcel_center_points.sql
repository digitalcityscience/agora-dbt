{{ config(
    materialized='table',
    alias='stg_parcel_center_points',
    post_hook=[
        "CREATE INDEX IF NOT EXISTS idx_center_point ON {{ this }} USING GIST(center_point)"
    ]
) }}


with parcel_center_point as (
    select p."UUID" AS parcel_uuid, 
           ST_Centroid(geom) AS center_point
    FROM {{ source(target.schema, var('alkis_dataset_name')) }} as p
)

select *
from parcel_center_point