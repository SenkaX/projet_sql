-- Fonction pour ajouter un nouveau forfait
CREATE OR REPLACE FUNCTION add_offer(
    code VARCHAR(5),
    name VARCHAR(32),
    price FLOAT,
    nb_month INT,
    zone_from INT,
    zone_to INT
)
RETURNS BOOLEAN AS $$
BEGIN
    IF nb_month <= 0 THEN
        RETURN FALSE;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM zones_tarifaires WHERE id = zone_from) OR
       NOT EXISTS (SELECT 1 FROM zones_tarifaires WHERE id = zone_to) THEN
        RETURN FALSE;
    END IF;

    -- Insérer le nouveau forfait
    INSERT INTO forfaits (id, nom, prix_mensuel, duree_mois, zone_min, zone_max)
    VALUES (code, name, price, nb_month, zone_from, zone_to);

    RETURN TRUE;
END;
$$ LANGUAGE plpgsql;