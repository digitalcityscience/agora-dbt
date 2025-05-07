{{ config(
    materialized='table',
    alias='int_parcel_xplannung',
    post_hook=[
        "CREATE INDEX IF NOT EXISTS idx_xplan_center_point ON {{ this }} USING GIST(center_point)"
    ]
) }}

WITH xplannung AS (
    SELECT *
    FROM {{ source(target.schema, var('xplannung_dataset_name')) }}
    WHERE id IS NOT NULL
),

parcel_xplannung AS (
    SELECT 
        p.*,
        x.id AS xplanung_id,
        x."grz" AS x_grz
    FROM {{ ref('stg_parcel_center_points') }} p
    JOIN xplannung x
      ON x.geom && p.center_point AND ST_Contains(x.geom, p.center_point)
)

SELECT * FROM parcel_xplannung
