-- Fonction pour lister les codes de forfaits des abonnements en statut "Enregistré" pour un utilisateur donné à une date donnée
CREATE OR REPLACE FUNCTION list_subscription(
    user_email VARCHAR(128),
    sub_date DATE
)
RETURNS TABLE(forfait_code CHAR(5)) AS $$
BEGIN
    RETURN QUERY
    SELECT a.forfait_id AS forfait_code
    FROM abonnements a
    JOIN voyageurs v ON a.utilisateur_id = v.id
    WHERE v.email = user_email
      AND a.statut = 'Registered'
      AND a.date_abonnement = sub_date
    ORDER BY a.forfait_id ASC;
END;
$$ LANGUAGE plpgsql;