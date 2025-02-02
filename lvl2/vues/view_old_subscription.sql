-- Création de la vue view_old_subscription
CREATE OR REPLACE VIEW view_old_subscription AS
SELECT
    v.nom || ' ' || v.prenom AS full_name,
    f.nom AS offer_name,
    a.statut AS status
FROM
    abonnements a
    JOIN voyageurs v ON a.utilisateur_id = v.id
    JOIN forfaits f ON a.forfait_id = f.id
WHERE
    a.statut IN ('Incomplete', 'Pending')
    AND a.date_abonnement <= CURRENT_DATE - INTERVAL '1 year'
ORDER BY full_name ASC, offer_name ASC;