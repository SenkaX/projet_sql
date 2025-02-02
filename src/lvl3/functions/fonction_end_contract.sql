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