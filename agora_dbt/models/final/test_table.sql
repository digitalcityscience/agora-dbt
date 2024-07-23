{{ config(
    materialized='table'
) }}


with unnested_buildings as (
    select 
        apg.*, 
        building_id
    from 
        {{ ref('alkis_parcel_grz') }} apg,
        lateral unnest(apg.building_list) as building_id
),
building_counts as (
    select
        ub.*,
        count(ub.building_id) over (partition by ub.id) as count_grz_id
    from unnested_buildings ub
),
filtered_buildings as (
    select * 
    from building_counts
    where count_grz_id < 2
),
new_grz_table as (
    select 
        *,
        (total_building_area / parcel_area) as new_grz
    from filtered_buildings
),
comparison as (
    select 
        id, 
        new_grz, 
        grz_value
    from new_grz_table
    where new_grz != grz_value
)
select 
    *
from comparison