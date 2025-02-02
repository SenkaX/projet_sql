-- Fonction pour mettre à jour le statut de l'abonnement
CREATE OR REPLACE FUNCTION update_status(
    num INT,
    new_status VARCHAR(32)
)
RETURNS BOOLEAN AS $$
BEGIN
    IF new_status NOT IN ('Registered', 'Pending', 'Incomplete') THEN
        RETURN FALSE;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM abonnements WHERE id = num) THEN
        RETURN FALSE;
    END IF;

    IF EXISTS (SELECT 1 FROM abonnements WHERE id = num AND statut = new_status) THEN
        RETURN TRUE;
    END IF;

    -- Mettre à jour le statut de l'abonnement
    UPDATE abonnements
    SET statut = new_status
    WHERE id = num;

    RETURN TRUE;
END;
$$ LANGUAGE plpgsql;