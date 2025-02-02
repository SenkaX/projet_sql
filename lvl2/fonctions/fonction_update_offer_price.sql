-- Fonction pour mettre à jour le prix d'un forfait
CREATE OR REPLACE FUNCTION update_offer_price(
    offer_code VARCHAR(5),
    price FLOAT
)
RETURNS BOOLEAN AS $$
BEGIN

    IF price <= 0 THEN
        RETURN FALSE;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM forfaits WHERE id = offer_code) THEN
        RETURN FALSE;
    END IF;

    -- Mettre à jour le prix du forfait
    UPDATE forfaits
    SET prix_mensuel = price
    WHERE id = offer_code;

    RETURN TRUE;
END;
$$ LANGUAGE plpgsql;