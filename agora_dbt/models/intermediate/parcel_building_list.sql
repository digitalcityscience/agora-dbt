{{ config(
    materialized='table',
    alias='parcel_building_list',
    post_hook=[
        'CREATE INDEX IF NOT EXISTS idx_parcel_geom ON {{ ref("parcel_xplannug") }} USING GIST(geom)',
        'CREATE INDEX IF NOT EXISTS idx_building_center_point ON {{ ref("building_center_points") }} USING GIST(center_point)'
    ]
) }}

with building_centers as (
    select id, center_point
    from {{ ref('building_center_points') }}
),
parcels_with_buildings as (
    select 
        p.id,
        array_agg(b.id) as building_list
    from {{ ref('parcel_xplannug') }} p
    join building_centers b
    on ST_Contains(p.geom, b.center_point)
    group by p.id
)

select 
    px.*,
    pb.building_list
from parcels_with_buildings as pb
join {{ ref('parcel_xplannug') }} as px 
on pb.id = px.id


-- parce_xplannung yani xplan olan parcellerin icine dusen binalari buluyoruz.
--