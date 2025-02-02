-- Fonctions lvl_1

-- Fonction pour ajouter une nouvelle ligne
CREATE OR REPLACE FUNCTION add_line(
    id VARCHAR(3),
    l_type VARCHAR(3),
    l_code VARCHAR(32)
)
RETURNS BOOLEAN AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM transport t WHERE t.id = l_type) THEN
        RETURN FALSE;
    END IF;

    IF EXISTS (SELECT 1 FROM lignes l WHERE l.id = add_line.id) THEN
        RETURN FALSE;
    END IF;

    -- Insérer la nouvelle ligne
    INSERT INTO lignes (id, moyen_transport_id, nom)
    VALUES (id, l_type, l_code);

    RETURN TRUE;
END;
$$ LANGUAGE plpgsql;

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

-- Création de la fonction add_transport_type
CREATE OR REPLACE FUNCTION add_transport_type(
    code VARCHAR(3),
    name VARCHAR(32),
    capacity INT,
    avg_interval INT
)
RETURNS BOOLEAN AS $$
BEGIN
    IF capacity <= 0 OR avg_interval <= 0 THEN
        RETURN FALSE;

END IF;

IF EXISTS (
    SELECT 1
    FROM transport
    WHERE
        id = code
        OR nom = name
) THEN
RETURN FALSE;

END IF;

-- Insérer le nouveau moyen de transport
INSERT INTO
    transport (
        id,
        nom,
        capacite_max,
        duree_moyenne_trajet
    )
VALUES (
        code,
        name,
        capacity,
        avg_interval
    );

RETURN TRUE;

END;

$$ LANGUAGE plpgsql;

-- Fonction pour ajouter une nouvelle zone tarifaire
CREATE OR REPLACE FUNCTION add_zone(
    name VARCHAR(32),
    price FLOAT
)
RETURNS BOOLEAN AS $$
BEGIN
    IF price <= 0.001 THEN
        RETURN FALSE;
    END IF;

    IF EXISTS (SELECT 1 FROM zones_tarifaires WHERE nom = name) THEN
        RETURN FALSE;
    END IF;

    -- Insérer la nouvelle zone tarifaire
    INSERT INTO zones_tarifaires (nom, prix)
    VALUES (name, price);

    RETURN TRUE;
END;
$$ LANGUAGE plpgsql;

-- Vues lvl_1

-- Création de la vue view_line_duration
CREATE OR REPLACE VIEW view_line_duration AS
SELECT t.nom AS type, l.id AS line, SUM(t.duree_moyenne_trajet) AS minutes
FROM
    transport t
    JOIN lignes l ON t.id = l.moyen_transport_id
    JOIN stations_lignes sl ON l.id = sl.ligne_id
GROUP BY
    t.nom,
    l.id
ORDER BY t.nom ASC, l.id ASC;

-- Création de la vue view_nb_station_type
CREATE OR REPLACE VIEW view_nb_station_type AS
SELECT t.nom AS transport_nom, COUNT(s.id) AS nb_stations
FROM
    transport t
    JOIN lignes l ON t.id = l.moyen_transport_id
    JOIN stations_lignes sl ON l.id = sl.ligne_id
    JOIN stations s ON sl.station_id = s.id
GROUP BY
    t.nom
ORDER BY nb_stations DESC, t.nom ASC;

-- Création de la vue view_station_capacity
CREATE OR REPLACE VIEW view_station_capacity AS
SELECT s.nom AS station, t.capacite_max AS capacity
FROM
    stations s
    JOIN stations_lignes sl ON s.id = sl.station_id
    JOIN lignes l ON sl.ligne_id = l.id
    JOIN transport t ON l.moyen_transport_id = t.id
WHERE
    LOWER(s.nom) LIKE 'a%'
ORDER BY s.nom ASC, t.capacite_max ASC;

-- Création de la vue view_stations_from_paris
CREATE OR REPLACE VIEW view_stations_from_paris AS
SELECT nom
FROM stations
WHERE (commune) = 'Paris'
ORDER BY nom ASC;

-- Création de la vue view_stations_zones
CREATE OR REPLACE VIEW view_stations_zones AS
SELECT s.nom AS station_nom, z.nom AS zone_nom
FROM
    stations s
    JOIN zones_tarifaires z ON s.zone_id = z.id
ORDER BY z.id ASC, s.nom ASC;

-- Création de la vue view_transport_50_300_users
CREATE OR REPLACE VIEW view_transport_50_300_users AS
SELECT nom
FROM transport
WHERE
    capacite_max BETWEEN 50 AND 300
ORDER BY nom ASC;

-- Procédures lvl_1

-- Fonction pour obtenir le coût d'un voyage entre deux stations
CREATE OR REPLACE FUNCTION get_cost_travel(
    station_start INT,
    station_end INT
)
RETURNS FLOAT AS $$
DECLARE
    start_zone INT;
    end_zone INT;
    total_cost FLOAT := 0;
BEGIN
    -- Vérifier que les stations existent
    IF NOT EXISTS (SELECT 1 FROM stations WHERE id = station_start) OR
       NOT EXISTS (SELECT 1 FROM stations WHERE id = station_end) THEN
        RETURN 0;
    END IF;

    -- Obtenir les zones des stations de départ et d'arrivée
    SELECT zone_id INTO start_zone FROM stations WHERE id = station_start;
    SELECT zone_id INTO end_zone FROM stations WHERE id = station_end;

    -- Calculer le coût total
    IF start_zone <= end_zone THEN
        FOR zone_id IN start_zone..end_zone LOOP
            SELECT prix INTO total_cost FROM zones_tarifaires WHERE id = zone_id;
        END LOOP;
    ELSE
        FOR zone_id IN end_zone..start_zone LOOP
            SELECT prix INTO total_cost FROM zones_tarifaires WHERE id = zone_id;
        END LOOP;
    END IF;

    RETURN total_cost;
END;
$$ LANGUAGE plpgsql;

-- Fonction pour lister les stations sur une ligne donnée
CREATE OR REPLACE FUNCTION list_station_in_line(
    line_id CHAR(3)
)
RETURNS TABLE(station_name VARCHAR(64)) AS $$
BEGIN
    RETURN QUERY
    SELECT s.nom
    FROM stations s
    JOIN stations_lignes sl ON s.id = sl.station_id
    WHERE sl.ligne_id = line_id
    ORDER BY sl.position ASC;
END;
$$ LANGUAGE plpgsql;

-- Fonction pour lister les types de transport dans une zone donnée
CREATE OR REPLACE FUNCTION list_types_in_zone(
    zone INT
)
RETURNS SETOF VARCHAR(32) AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT t.nom
    FROM transport t
    JOIN lignes l ON t.id = l.moyen_transport_id
    JOIN stations_lignes sl ON l.id = sl.ligne_id
    JOIN stations s ON sl.station_id = s.id
    WHERE s.zone_id = zone
    ORDER BY t.nom ASC;
END;
$$ LANGUAGE plpgsql;

-- Fin lvl_1