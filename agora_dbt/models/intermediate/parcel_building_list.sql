-- we can give another name to table with alias
{{ config(materialized='table',alias='parcel_building_list') }}

with building_centers as (
    select id, center_point
    from {{ ref('building_center_points') }}
),
parcels_with_buildings as (
    select p.*,
           array_agg(b.id) as building_list
    from {{ source('public', 'alkis_parcels') }} p

    join building_centers b
    on ST_Contains(p.geom, b.center_point)
    group by p.id
)

select *
from parcels_with_buildings
