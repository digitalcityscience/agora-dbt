{{ config(materialized='table',alias='building_center_points') }}

with buildings as (
    select *,
           ST_Centroid(geom) as center_point
    from {{ source('public', 'alkis_buildings') }}
)

select *
from buildings