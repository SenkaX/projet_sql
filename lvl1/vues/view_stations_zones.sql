-- Création de la vue view_stations_zones
CREATE OR REPLACE VIEW view_stations_zones AS
SELECT s.nom AS station_nom, z.nom AS zone_nom
FROM
    stations s
    JOIN zones_tarifaires z ON s.zone_id = z.id
ORDER BY z.id ASC, s.nom ASC;