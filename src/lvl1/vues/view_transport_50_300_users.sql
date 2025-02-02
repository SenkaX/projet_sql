-- Création de la vue view_transport_50_300_users
CREATE OR REPLACE VIEW view_transport_50_300_users AS
SELECT nom
FROM transport
WHERE
    capacite_max BETWEEN 50 AND 300
ORDER BY nom ASC;