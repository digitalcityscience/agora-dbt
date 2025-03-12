WITH intersecting_parcels AS (
    SELECT 
        a.id AS alkis_id,  
        a."ZAE" AS alkis_zae_id,  
        b.flurst AS lgb_flurst_id,
        ST_MakeValid(a.geom) AS alkis_geom,
        ST_MakeValid(b.geom) AS lgb_geom,
        ST_Area(ST_MakeValid(a.geom)) AS alkis_area,   
        ST_Area(ST_MakeValid(b.geom)) AS lgb_area,
        ST_Area(ST_Intersection(ST_MakeValid(a.geom), ST_MakeValid(b.geom))) AS intersection_area,
        b.art AS lgb_art,
		b.typ AS lgb_typ,
        b.flurst AS lgb_flurst
    FROM 
        parcel_test_west a
    JOIN 
        verw_vermoegen_str_plaetze_wege_deiche b ON a."ZAE" = b.flurst
    WHERE 
        ST_Intersects(ST_MakeValid(a.geom), ST_MakeValid(b.geom))
)

SELECT * FROM intersecting_parcels;

---------------------------------

WITH intersecting_parcels AS (
    SELECT 
        a.id AS alkis_id,  
        a."ZAE" AS alkis_zae_id,  
        b.flurst AS lgb_flurst_id,
        ST_MakeValid(a.geom) AS alkis_geom,
        ST_MakeValid(b.geom) AS lgb_geom,
        ST_Area(ST_MakeValid(a.geom)) AS alkis_area,   
        ST_Area(ST_MakeValid(b.geom)) AS lgb_area,
        ST_Area(ST_Intersection(ST_MakeValid(a.geom), ST_MakeValid(b.geom))) AS intersection_area,
        b.art AS lgb_art,
        b.typ AS lgb_typ,
        b.flurst AS lgb_flurst
    FROM 
        parcel_test_west a
    JOIN 
        verw_vermoegen_str_plaetze_wege_deiche b ON a."ZAE" = b.flurst
    WHERE 
        ST_Intersects(ST_MakeValid(a.geom), ST_MakeValid(b.geom))
),
filtered_results AS (
    SELECT 
        ip.alkis_id,
        ip.alkis_zae_id,
        ip.lgb_flurst_id,
        ip.alkis_geom,
        ip.lgb_geom,
        ip.alkis_area,
        ip.lgb_area,
        ip.intersection_area,
        ip.lgb_art,
        ip.lgb_typ,
        ip.lgb_flurst,
        ABS(ip.intersection_area - ip.alkis_area) AS area_difference
    FROM 
        intersecting_parcels ip
    WHERE 
        ABS(ip.intersection_area - ip.alkis_area) <= 20
)
-- Bu noktada sadece filtered_results'i seçiyoruz
SELECT * FROM filtered_results;

----11111--calisiyor asagisi
SELECT 
    a.id AS alkis_id,  
    a."ZAE" AS alkis_zae_id,  
    b.flurst AS lgb_flurst_id,
    ST_MakeValid(a.geom) AS alkis_geom,  
    ST_MakeValid(b.geom) AS lgb_geom,
    ST_Area(ST_MakeValid(a.geom)) AS alkis_area,   
    ST_Area(ST_MakeValid(b.geom)) AS lgb_area,
    COALESCE(ST_Area(ST_Intersection(ST_MakeValid(a.geom), ST_MakeValid(b.geom))), 0) AS intersection_area,  
    b.art AS lgb_art,
    b.typ AS lgb_typ,
    b.flurst AS lgb_flurst
FROM 
    parcel_test_west a
JOIN 
    verw_vermoegen_str_plaetze_wege_deiche b 
ON 
    a."ZAE" = b.flurst
WHERE 
    ST_Intersects(ST_MakeValid(a.geom), ST_MakeValid(b.geom));
	
	
	
----new
SELECT 
    a.id AS alkis_id,  
    a."ZAE" AS alkis_zae_id,  
    b.flurst AS lgb_flurst_id,
    ST_MakeValid(a.geom) AS alkis_geom,  
    ST_MakeValid(b.geom) AS lgb_geom,
    a."Shape_Area" AS alkis_area,  -- Hesaplama yerine Shape_Area kullanıldı
    ST_Area(ST_MakeValid(b.geom)) AS lgb_area,
    COALESCE(ST_Area(ST_Intersection(ST_MakeValid(a.geom), ST_MakeValid(b.geom))), 0) AS intersection_area,  
    b.art AS lgb_art,
    b.typ AS lgb_typ,
    b.flurst AS lgb_flurst
FROM 
    parcel_test_west a
JOIN 
    verw_vermoegen_str_plaetze_wege_deiche b 
ON 
    a."ZAE" = b.flurst
WHERE 
    ST_Intersects(ST_MakeValid(a.geom), ST_MakeValid(b.geom))
    AND ABS(ST_Area(ST_Intersection(ST_MakeValid(a.geom), ST_MakeValid(b.geom))) - a."Shape_Area") <= 20;
	
	
--ALTER TABLE parcel_test_west ADD COLUMN lgb_art VARCHAR;
--ALTER TABLE parcel_test_west ADD COLUMN lgb_typ VARCHAR;
ALTER TABLE parcel_test_west ADD COLUMN lgb_art TEXT[];
ALTER TABLE parcel_test_west ADD COLUMN lgb_typ TEXT[];
ALTER TABLE parcel_test_west ADD COLUMN lgb_flurst VARCHAR;
---
ALTER TABLE parcel_test_west DROP COLUMN lgb_art CASCADE;
ALTER TABLE parcel_test_west DROP COLUMN lgb_typ CASCADE;
ALTER TABLE parcel_test_west DROP COLUMN lgb_flurst CASCADE;----

select * from parcel_test_west
------------------------------
UPDATE parcel_test_west a
SET 
    lgb_art = COALESCE(a.lgb_art, '{}') || ARRAY[b.lgb_art::TEXT],  -- `VARCHAR` → `TEXT[]` dönüşümü
    lgb_typ = COALESCE(a.lgb_typ, '{}') || ARRAY[b.lgb_typ::TEXT]   -- `VARCHAR` → `TEXT[]` dönüşümü
FROM (
    SELECT 
        a.id AS alkis_id,  
        ARRAY_AGG(b.art::TEXT ORDER BY b.art) AS lgb_art,  -- `VARCHAR` → `TEXT`
        ARRAY_AGG(b.typ::TEXT ORDER BY b.typ) AS lgb_typ   -- `VARCHAR` → `TEXT`
    FROM 
        parcel_test_west a
    JOIN 
        verw_vermoegen_str_plaetze_wege_deiche b 
    ON 
        a."ZAE" = b.flurst
    WHERE 
        ST_Intersects(ST_MakeValid(a.geom), ST_MakeValid(b.geom))
        AND ABS(ST_Area(ST_Intersection(ST_MakeValid(a.geom), ST_MakeValid(b.geom))) - a."Shape_Area") <= 20
    GROUP BY a.id
) AS b
WHERE a.id = b.alkis_id;
--------------------------
DO $$ 
DECLARE 
    lgb_table TEXT;
BEGIN
    -- LGB tabloları listesi
    FOR lgb_table IN 
        SELECT unnest(ARRAY[
            'grundstuecksgleiche_rechte', 
            'verwaltungsvermoegen_gewaesser', 
            'landesbetriebe_gem_paragraph_26_lho', 
            'sonderverm_schulimmobilien', 
            'agv_ohne_erbbaurecht', 
            'agv_belastet_mit_erbbaurecht', 
            'landesbetriebe_gem_paragraph_26_lho_erbbaurecht', 
            'sonderverm_stadt_und_hafen_hafencity', 
            'sonderverm_fuer_naturschutz_und_landschaftspflege_svnl', 
            'sonderverm_stadt_und_hafen_hafencity_belastet_mit_erbbaurecht', 
            'verwaltungsvermoegen_sonstiges', 
            'verwaltungsvermoegen_erbbaurecht'
        ])
    LOOP
        -- Dinamik SQL ile UPDATE çalıştır
        EXECUTE format(
            'UPDATE parcel_test_west a
            SET 
                lgb_art = COALESCE(a.lgb_art, ''{}'') || b.lgb_art,  
                lgb_typ = COALESCE(a.lgb_typ, ''{}'') || b.lgb_typ
            FROM (
                SELECT 
                    a.id AS alkis_id,  
                    ARRAY_AGG(b.art::TEXT ORDER BY b.art, b.typ) AS lgb_art,  
                    ARRAY_AGG(b.typ::TEXT ORDER BY b.art, b.typ) AS lgb_typ   
                FROM 
                    parcel_test_west a
                JOIN 
                    %I b 
                ON 
                    a."ZAE" = b.flurst
                WHERE 
                    ST_Intersects(ST_MakeValid(a.geom), ST_MakeValid(b.geom))
                    AND ABS(ST_Area(ST_Intersection(ST_MakeValid(a.geom), ST_MakeValid(b.geom))) - a."Shape_Area") <= 20
                GROUP BY a.id
            ) AS b
            WHERE a.id = b.alkis_id;', lgb_table
        );
    END LOOP;
END $$;


