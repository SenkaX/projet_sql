-- Fonction pour ajouter une station à une ligne
CREATE OR REPLACE FUNCTION add_station_to_line(
    station INT,
    line VARCHAR(3),
    pos INT
)
RETURNS BOOLEAN AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM stations s WHERE s.id = station) THEN
        RETURN FALSE;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM lignes l WHERE l.id = line) THEN
        RETURN FALSE;
    END IF;

    IF EXISTS (SELECT 1 FROM stations_lignes sl WHERE sl.station_id = station AND sl.ligne_id = line) THEN
        RETURN FALSE;
    END IF;

    IF EXISTS (SELECT 1 FROM stations_lignes sl WHERE sl.ligne_id = line AND sl.position = pos) THEN
        RETURN FALSE;
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM stations s
        JOIN lignes l ON l.moyen_transport_id = (SELECT t.id FROM transport t WHERE t.id = l.moyen_transport_id)
        WHERE s.id = station AND l.id = line
    ) THEN
        RETURN FALSE;
    END IF;

    -- Insérer la station dans la ligne
    INSERT INTO stations_lignes (station_id, ligne_id, position)
    VALUES (station, line, pos);

    RETURN TRUE;
END;
$$ LANGUAGE plpgsql;