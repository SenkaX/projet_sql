-- Création de la vue view_pending_subscriptions
CREATE OR REPLACE VIEW view_pending_subscriptions AS
SELECT
    v.nom AS last_name,
    v.prenom AS first_name,
    v.email AS email,
    a.date_abonnement AS subscription_date
FROM abonnements a
    JOIN voyageurs v ON a.utilisateur_id = v.id
WHERE
    a.statut = 'Pending'
ORDER BY a.date_abonnement ASC;