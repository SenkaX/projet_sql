-- Fonction pour ajouter un contrat de travail
CREATE OR REPLACE FUNCTION add_contract(
    login VARCHAR(20),
    user_email VARCHAR(128),
    date_beginning DATE,
    service VARCHAR(32)
)
RETURNS BOOLEAN AS $$
DECLARE
    user_id INT;
    last_contract_end DATE;
BEGIN
    SELECT v.id INTO user_id FROM voyageurs v WHERE v.email = user_email;
    IF NOT FOUND THEN
        RETURN FALSE;
    END IF;

    IF EXISTS (SELECT 1 FROM employes e WHERE e.login = add_contract.login) THEN
        RETURN FALSE;
    END IF;

    SELECT MAX(c.date_depart) INTO last_contract_end FROM contrats c WHERE c.employe_id = user_id;
    IF last_contract_end IS NOT NULL AND date_beginning <= last_contract_end THEN
        RETURN FALSE;
    END IF;

    INSERT INTO employes (utilisateur_id, login)
    VALUES (user_id, login);

    -- Insérer le nouveau contrat
    INSERT INTO contrats (employe_id, date_embauche, service)
    VALUES (user_id, date_beginning, service);

    RETURN TRUE;
END;
$$ LANGUAGE plpgsql;