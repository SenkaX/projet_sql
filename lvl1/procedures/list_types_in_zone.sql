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