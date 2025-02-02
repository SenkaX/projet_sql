-- Fonction pour ajouter une nouvelle ligne
CREATE OR REPLACE FUNCTION add_line(
    id VARCHAR(3),
    l_type VARCHAR(3),
    l_code VARCHAR(32)
)
RETURNS BOOLEAN AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM transport t WHERE t.id = l_type) THEN
        RETURN FALSE;
    END IF;

    IF EXISTS (SELECT 1 FROM lignes l WHERE l.id = add_line.id) THEN
        RETURN FALSE;
    END IF;

    -- Insérer la nouvelle ligne
    INSERT INTO lignes (id, moyen_transport_id, nom)
    VALUES (id, l_type, l_code);

    RETURN TRUE;
END;
$$ LANGUAGE plpgsql;
