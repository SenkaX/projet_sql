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