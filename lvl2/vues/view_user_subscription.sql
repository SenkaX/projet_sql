-- Création de la vue view_user_subscription
CREATE OR REPLACE VIEW view_user_subscription AS
SELECT v.nom || ' ' || v.prenom AS user, f.nom AS offer
FROM
    abonnements a
    JOIN voyageurs v ON a.utilisateur_id = v.id
    JOIN forfaits f ON a.forfait_id = f.id
ORDER BY user ASC, offer ASC;