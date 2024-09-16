{{ config(
    materialized='table',
    alias='building_center_points',
    post_hook=[
        'CREATE INDEX IF NOT EXISTS idx_building_center_point ON {{ this }} USING GIST(center_point)'
    ]
) }}

with buildings as (
    select *,
           ST_Centroid(geom) as center_point
    from {{ source(target.schema, 'alkis_buildings') }}
)

select *
from buildings
