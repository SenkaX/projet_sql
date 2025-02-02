-- Fonction pour lister les logins des employés qui travaillent pour l'entreprise à une date donnée
CREATE OR REPLACE FUNCTION list_login_employee(
    date_service DATE
)
RETURNS SETOF VARCHAR(20) AS $$
BEGIN
    RETURN QUERY
    SELECT e.login
    FROM employes e
    JOIN contrats c ON e.utilisateur_id = c.employe_id
    WHERE c.date_embauche <= date_service
      AND (c.date_depart IS NULL OR c.date_depart >= date_service)
    ORDER BY e.login ASC;
END;
$$ LANGUAGE plpgsql;