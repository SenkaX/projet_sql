-- Fonction pour ajouter une nouvelle zone tarifaire
CREATE OR REPLACE FUNCTION add_zone(
    name VARCHAR(32),
    price FLOAT
)
RETURNS BOOLEAN AS $$
BEGIN
    IF price <= 0.001 THEN
        RETURN FALSE;
    END IF;

    IF EXISTS (SELECT 1 FROM zones_tarifaires WHERE nom = name) THEN
        RETURN FALSE;
    END IF;

    -- Insérer la nouvelle zone tarifaire
    INSERT INTO zones_tarifaires (nom, prix)
    VALUES (name, price);

    RETURN TRUE;
END;
$$ LANGUAGE plpgsql;