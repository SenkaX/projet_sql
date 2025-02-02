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