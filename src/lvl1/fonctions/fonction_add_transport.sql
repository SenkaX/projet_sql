-- Création de la fonction add_transport_type
CREATE OR REPLACE FUNCTION add_transport_type(
    code VARCHAR(3),
    name VARCHAR(32),
    capacity INT,
    avg_interval INT
)
RETURNS BOOLEAN AS $$
BEGIN
    IF capacity <= 0 OR avg_interval <= 0 THEN
        RETURN FALSE;
    END IF;

    IF EXISTS (SELECT 1 FROM transport WHERE id = code OR nom = name) THEN
        RETURN FALSE;
    END IF;

    -- Insérer le nouveau moyen de transport
    INSERT INTO transport (id, nom, capacite_max, duree_moyenne_trajet)
    VALUES (code, name, capacity, avg_interval);

    RETURN TRUE;
END;
$$ LANGUAGE plpgsql;