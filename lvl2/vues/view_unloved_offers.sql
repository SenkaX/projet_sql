-- Création de la vue view_unloved_offers
CREATE OR REPLACE VIEW view_unloved_offers AS
SELECT f.nom AS offer_name
FROM forfaits f
    LEFT JOIN abonnements a ON f.id = a.forfait_id
WHERE
    a.forfait_id IS NULL
ORDER BY f.nom ASC;