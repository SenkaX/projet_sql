-- Création de la vue view_stations_from_paris
CREATE OR REPLACE VIEW view_stations_from_paris AS
SELECT nom
FROM stations
WHERE (commune) = 'Paris'
ORDER BY nom ASC;