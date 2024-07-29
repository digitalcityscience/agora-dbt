-- we can give another name to table with alias
{{ config(materialized='table',alias='parcel_xplannug') }}

with xplannung as (
    select *
    from {{ source('public', 'xplannung')  }}
),
parcel_xplannug as (
    select p.*, x.id as xplanung_id,x."GRZ" as "X_GRZ"
    from {{ ref('parcel_center_points') }} p

    join xplannung x
    on ST_Contains(x.geom, p.center_point)
)

select *
from parcel_xplannug
