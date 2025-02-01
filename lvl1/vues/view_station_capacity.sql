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