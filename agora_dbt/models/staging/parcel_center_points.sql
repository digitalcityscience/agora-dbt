{{ config(
    materialized='table',
    alias='parcel_center_points',
    post_hook=[
        'CREATE INDEX IF NOT EXISTS idx_parcel_center_point ON {{ this }} USING GIST(center_point)'
    ]
) }}

with buildings as (
    select *,
           ST_Centroid(geom) as center_point
    from {{ source(target.schema, 'alkis_parcels') }}
)

select *
from buildings
