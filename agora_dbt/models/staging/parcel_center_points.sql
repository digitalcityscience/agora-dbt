{{ config(materialized='table',alias='parcel_center_points') }}

with buildings as (
    select *,
           ST_Centroid(geom) as center_point
    from {{ source('public', 'alkis_parcels') }}
)

select *
from buildings