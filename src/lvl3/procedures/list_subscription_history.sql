-- Fonction pour lister l'historique des abonnements et des contrats d'un utilisateur
CREATE OR REPLACE FUNCTION list_subscription_history(
    user_email VARCHAR(128)
)
RETURNS TABLE(
    type TEXT,
    name VARCHAR,
    start_date DATE,
    duration INTERVAL
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        'sub' AS type,
        f.nom AS name,
        a.date_abonnement AS start_date,
        (a.date_abonnement + INTERVAL '1 month' * f.duree_mois - a.date_abonnement) AS duration
    FROM 
        abonnements a
    JOIN 
        voyageurs v ON a.utilisateur_id = v.id
    JOIN 
        forfaits f ON a.forfait_id = f.id
    WHERE 
        v.email = user_email

    UNION ALL
    SELECT 
        'ctr' AS type,
        c.service AS name,
        c.date_embauche AS start_date,
        CASE 
            WHEN c.date_depart IS NOT NULL THEN (c.date_depart - c.date_embauche)::INTERVAL
            ELSE NULL
        END AS duration
    FROM 
        contrats c
    JOIN 
        employes e ON c.employe_id = e.utilisateur_id
    JOIN 
        voyageurs v ON e.utilisateur_id = v.id
    WHERE 
        v.email = user_email

    ORDER BY 
        start_date ASC;
END;
$$ LANGUAGE plpgsql;