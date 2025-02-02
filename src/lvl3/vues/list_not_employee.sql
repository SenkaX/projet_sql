-- Fonction pour lister les utilisateurs qui ne sont pas des employés à une date donnée
CREATE OR REPLACE FUNCTION list_not_employee(
    date_service DATE
)
RETURNS TABLE(
    lastname VARCHAR(32),
    firstname VARCHAR(32),
    has_worked TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        v.nom AS lastname,
        v.prenom AS firstname,
        CASE 
            WHEN EXISTS (
                SELECT 1 
                FROM contrats c 
                WHERE c.employe_id = v.id
            ) THEN 'YES'
            ELSE 'NO'
        END AS has_worked
    FROM 
        voyageurs v
    WHERE 
        NOT EXISTS (
            SELECT 1 
            FROM employes e
            JOIN contrats c ON e.utilisateur_id = c.employe_id
            WHERE e.utilisateur_id = v.id
            AND c.date_embauche <= date_service
            AND (c.date_depart IS NULL OR c.date_depart >= date_service)
        )
    ORDER BY 
        lastname ASC, 
        firstname ASC;
END;
$$ LANGUAGE plpgsql;