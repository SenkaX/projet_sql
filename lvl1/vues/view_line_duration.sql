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