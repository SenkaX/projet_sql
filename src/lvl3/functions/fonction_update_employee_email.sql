-- Fonction pour mettre à jour l'adresse électronique d'un employé
CREATE OR REPLACE FUNCTION update_employee_email(
    login VARCHAR(20),
    new_email VARCHAR(128)
)
RETURNS BOOLEAN AS $$
DECLARE
    user_id INT;
    current_email VARCHAR(128);
BEGIN
    SELECT v.id, v.email INTO user_id, current_email
    FROM employes e
    JOIN voyageurs v ON e.utilisateur_id = v.id
    WHERE e.login = update_employee_email.login;
    
    IF NOT FOUND THEN
        RETURN FALSE;
    END IF;

    IF current_email = new_email THEN
        RETURN TRUE;
    END IF;

    IF EXISTS (SELECT 1 FROM voyageurs WHERE email = new_email) THEN
        RETURN FALSE;
    END IF;

    -- Mettre à jour l'adresse e-mail de l'utilisateur
    UPDATE voyageurs
    SET email = new_email
    WHERE id = user_id;

    RETURN TRUE;
END;
$$ LANGUAGE plpgsql;