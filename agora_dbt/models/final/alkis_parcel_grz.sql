{{ config(
    materialized='table', 
    alias='alkis_parcel_grz')
 }}

with building_centers as (
    select id, "GRF" as Grundflaeche  -- Ensure case-sensitivity
    from {{ ref('building_center_points') }}
),
parcels as (
    select *,
           "AFL" as AmtlicheFlaeche
    from {{ ref('parcel_building_list') }}
),
parcel_building_areas as (
    select p.id as parcel_id,
           sum(b.Grundflaeche) as total_building_area,
           p.AmtlicheFlaeche as parcel_area
    from parcels p,
         lateral unnest(p.building_list) as building_id
    join building_centers b
    on b.id = building_id
    group by p.id, p.AmtlicheFlaeche
),
parcel_grz as (
    select parcel_id,
           total_building_area,
           parcel_area,
           total_building_area / parcel_area as grz_value
    from parcel_building_areas
)

select p.*,
       g.total_building_area,   -- Include total_building_area from parcel_grz
       g.parcel_area,           -- Include parcel_area from parcel_grz
       g.grz_value,              -- Include grz_value from parcel_grz
       CASE 
            WHEN p."X_GRZ" IS NOT NULL THEN (p."X_GRZ" / g.grz_value)
            ELSE NULL
        END as "potential_grz"
from parcels p
left join parcel_grz g on p.id = g.parcel_id
