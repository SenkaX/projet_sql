-- Fonction pour ajouter un nouvel utilisateur
CREATE OR REPLACE FUNCTION add_person(
    firstname VARCHAR(32),
    lastname VARCHAR(32),
    email VARCHAR(128),
    phone VARCHAR(10),
    address TEXT,
    town VARCHAR(32),
    zipcode VARCHAR(5)
)
RETURNS BOOLEAN AS $$
BEGIN
    IF EXISTS (SELECT 1 FROM voyageurs v WHERE v.email = add_person.email) THEN
        RETURN FALSE;
    END IF;

    -- Insérer le nouvel utilisateur
    INSERT INTO voyageurs (nom, prenom, email, telephone, courrier_postal, commune, code_postal)
    VALUES (lastname, firstname, email, phone, address, town, zipcode);

    RETURN TRUE;
END;
$$ LANGUAGE plpgsql;