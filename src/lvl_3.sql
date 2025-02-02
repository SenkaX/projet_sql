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









-- Vues lvl_3

-- Procédures lvl_3

-- Fin lvl_3