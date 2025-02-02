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