{{ config(
    materialized='table',
    alias='parcel_xplannug',
    post_hook=[
        'CREATE INDEX IF NOT EXISTS idx_xplannung_geom ON {{ source(target.schema, "xplannung") }} USING GIST(geom)',
        'CREATE INDEX IF NOT EXISTS idx_parcel_center_point ON {{ ref("parcel_center_points") }} USING GIST(center_point)'
    ]
) }}

with xplannung as (
    select *
    from {{ source(target.schema, 'xplannung') }}
),
parcel_xplannug as (
    select p.*, x.id as xplanung_id, x.grz as "X_GRZ"
    from {{ ref('parcel_center_points') }} p
    join xplannung x
    on ST_Contains(x.geom, p.center_point)
)

select *
from parcel_xplannug

-- burada xplannung icine dusen parcel noktalarini buldugumuz icin number of parcel otomatik olarak azaliyor
-- cunku tum sehirde x plannung yok