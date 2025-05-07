{{ config(
    materialized='table',
    alias='final_parcel_grz_analysis',
    post_hook=[ 
        "CREATE INDEX IF NOT EXISTS idx_grz_analysis_uuid ON {{ this }} (parcel_uuid)", 
        "CREATE INDEX IF NOT EXISTS idx_grz_analysis_geom ON {{ this }} USING GIST(geom)" 
    ] 
) }}

WITH grz_core AS (
    SELECT DISTINCT ON (g.parcel_uuid)
        g.parcel_uuid,
        g.grz_alkis,              -- Calculated GRZ from ALKIS building footprints
        g.buildings,              -- Aggregated building UUIDs
        x.xplanung_id,            -- Matching XPlanung polygon ID
        x.x_grz                   -- GRZ value from XPlanung
    FROM {{ ref('int_parcel_alkis_grz') }} g
    LEFT JOIN {{ ref('int_parcel_xplannung') }} x ON g.parcel_uuid = x.parcel_uuid
),

base AS (
    SELECT
        "id",                        -- Internal ID
        ST_Transform(geom_valid, 4326) AS geom,         -- Transforming geometry to EPSG:4326
        "fid",                      -- Feature ID
        "FSK", "FSKO", "FSKALB",    -- Parcel keys (various formats)
        "ZAE", "NEN",               -- Counters or flags
        "UUID",                     -- ALKIS UUID
        "FDV",                      -- Data version
        "LAN", "NAMLAN",            -- State code and name
        "RBZ", "NAMRBZ",            -- Planning region code and name
        "KRS", "NAMKRS",            -- County code and name
        "GEM", "NAMGEM",            -- Municipality code and name
        "GMT", "NAMGMT",            -- Sub-municipal district
        "GMK", "NAMGMK",            -- Parcel block info
        "FLN", "NAMFLN",            -- Flurstück number
        "GDZ", "AFL", "FSF", "ARZ", -- Area size, property flags
        "RBV", "ZFN", "ZDE",        -- Land use classification
        "SES", "DLAN", "DST",       -- Administrative attributes
        "REW", "HOW", "HHE",        -- Real estate valuation, housing
        "ISTGEBUCHT", "BAR", "BEZBAR",  -- Legal registration and buildability
        "LNR", "AZAE", "ANEN", "NRA",   -- Legal and registry fields
        "BSO", "BTX", "BUB", "ZDEBS",   -- Additional building/use info
        "DPRIO", "POS", "DVAR",         -- Development priority and flags
        "KENN", "BEZEICH",              -- Label and designation
        "BEG", "ENDE",                  -- Validity time range
        "MAT", "STM", "CRS",            -- Material, structure, coordinate ref
        "STATUS", "STATUSDAT",          -- Current status and date
        "Shape_Length", "Shape_Area",   -- Geometry stats
        data_version,                   -- Snapshot version
        lgb_art_values, lgb_typ_values, -- Classification values
        parcel_uuid,                    -- Internal UUID
        nutzart_list_final,             -- Aggregated usage type
        dist_airport,
        dist_bus_stop,
        dist_fire_departments,
        dist_hospitals,
        dist_kindergarten,
        dist_pharmacies,
        dist_supermarket,
        dist_train_station
    FROM {{ ref('final_parcel_poi_distance') }}
)

SELECT 
    b.*,
    g.grz_alkis,                              -- GRZ from actual building data
    g.buildings,                              -- List of building IDs on parcel
    g.xplanung_id,                            -- Matching planning unit
    g.x_grz AS grz_xplanung,                  -- GRZ from planning regulation
    CASE 
        WHEN g.x_grz IS NOT NULL THEN ROUND((g.x_grz - g.grz_alkis)::numeric, 4)
        ELSE NULL
    END AS grz_potential,                     -- Difference between planned and actual GRZ
    CASE 
        WHEN g.x_grz IS NOT NULL THEN ROUND((b."Shape_Area" * (g.x_grz - g.grz_alkis))::numeric, 4)
        ELSE NULL
    END AS grz_potential_area               -- Additional buildable area in m²
    
FROM base b
LEFT JOIN grz_core g ON b.parcel_uuid = g.parcel_uuid
