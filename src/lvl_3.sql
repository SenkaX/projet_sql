-- Fonctions lvl_3  

-- Fonction pour ajouter un service à l'entreprise
CREATE OR REPLACE FUNCTION add_service(
    name VARCHAR(32),
    discount INT
)
RETURNS BOOLEAN AS $$
BEGIN
    IF discount < 0 OR discount > 100 THEN
        RETURN FALSE;
    END IF;

    IF EXISTS (SELECT 1 FROM contrats_services WHERE name_service = name) THEN
        RETURN FALSE;
    END IF;

    -- Insérer le nouveau service
    INSERT INTO contrats_services (name_service, reduction_pourcent)
    VALUES (name, discount);

    RETURN TRUE;
END;
$$ LANGUAGE plpgsql;

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

-- Fonction pour mettre fin à un contrat de travail
CREATE OR REPLACE FUNCTION end_contract(
    user_email VARCHAR(128),
    date_end DATE
)
RETURNS BOOLEAN AS $$
DECLARE
    user_id INT;
    current_contract_id INT;
BEGIN
    SELECT v.id INTO user_id FROM voyageurs v WHERE v.email = user_email;
    IF NOT FOUND THEN
        RETURN FALSE;
    END IF;

    SELECT c.id INTO current_contract_id FROM contrats c WHERE c.employe_id = user_id AND c.date_depart IS NULL;
    IF NOT FOUND THEN
        RETURN FALSE;
    END IF;

    -- Mettre à jour la date de fin du contrat
    UPDATE contrats
    SET date_depart = date_end
    WHERE id = current_contract_id;

    RETURN TRUE;
END;
$$ LANGUAGE plpgsql;

-- Fonction pour mettre à jour la remise pour un service donné
CREATE OR REPLACE FUNCTION update_service(
    name VARCHAR(32),
    discount INT
)
RETURNS BOOLEAN AS $$
BEGIN
    IF discount < 0 OR discount > 100 THEN
        RETURN FALSE;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM contrats_services WHERE name_service = name) THEN
        RETURN FALSE;
    END IF;

    -- Mettre à jour la remise du service
    UPDATE contrats_services
    SET reduction_pourcent = discount
    WHERE name_service = name;

    RETURN TRUE;
END;
$$ LANGUAGE plpgsql;

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

-- Vues lvl_3

-- Procédures lvl_3

-- Fin lvl_3