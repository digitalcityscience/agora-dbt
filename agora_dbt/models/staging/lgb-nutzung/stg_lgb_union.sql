{{ config(
    materialized='table',
    alias='stg_lgb_union',
    post_hook=[
        "CREATE INDEX IF NOT EXISTS idx_lgb_geom_valid ON {{ this }} USING GIST(geom_valid)"
    ]
) }}

WITH lgb_union AS (
    {% set lgb_tables = [
        'landesbetriebe_gem_paragraph_26_lho', 
        'sonderverm_schulimmobilien', 
        'agv_ohne_erbbaurecht', 
        'agv_belastet_mit_erbbaurecht', 
        'landesbetriebe_gem_paragraph_26_lho_erbbaurecht', 
        'sonderverm_stadt_und_hafen_hafencity', 
        'sonderverm_fuer_naturschutz_und_landschaftspflege_svnl', 
        'sonderverm_stadt_und_hafen_hafencity_belastet_mit_erbbaurecht', 
        'verwaltungsvermoegen_sonstiges', 
        'verwaltungsvermoegen_erbbaurecht',
        'verw_vermoegen_str_plaetze_wege_deiche',
        'verwaltungsvermoegen_gewaesser', 
        'grundstuecksgleiche_rechte'
    ] %}
    {% for lgb_table in lgb_tables %}
    SELECT *, ST_MakeValid(geom) AS geom_valid FROM {{ source(target.schema, lgb_table) }}
    {% if not loop.last %} UNION ALL {% endif %}
    {% endfor %}
)

SELECT * FROM lgb_union
