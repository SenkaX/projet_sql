-- Fonction pour ajouter une nouvelle station
CREATE OR REPLACE FUNCTION add_station(
    s_id INT,
    s_name VARCHAR(64),
    s_town VARCHAR(32),
    s_zone INT,
    s_type VARCHAR(3)
)
RETURNS BOOLEAN AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM zones_tarifaires WHERE id = s_zone) THEN
        RETURN FALSE;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM transport WHERE id = s_type) THEN
        RETURN FALSE;
    END IF;

    IF EXISTS (SELECT 1 FROM stations WHERE id = s_id) THEN
        RETURN FALSE;
    END IF;

    -- Insérer la nouvelle station
    INSERT INTO stations (id, nom, commune, zone_id)
    VALUES (s_id, s_name, s_town, s_zone);
    RETURN TRUE;
END;
$$ LANGUAGE plpgsql;