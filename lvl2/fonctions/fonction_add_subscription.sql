-- Fonction pour ajouter un nouvel abonnement
CREATE OR REPLACE FUNCTION add_subscription(
    num INT,
    email VARCHAR(128),
    code VARCHAR(5),
    date_sub DATE
)
RETURNS BOOLEAN AS $$
DECLARE
    user_id INT;
BEGIN
    SELECT v.id INTO user_id FROM voyageurs v WHERE v.email = add_subscription.email;
    IF NOT FOUND THEN
        RETURN FALSE;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM forfaits f WHERE f.id = add_subscription.code) THEN
        RETURN FALSE;
    END IF;

    IF EXISTS (SELECT 1 FROM abonnements a WHERE a.utilisateur_id = user_id AND a.statut IN ('Pending', 'Incomplete')) THEN
        RETURN FALSE;
    END IF;

    IF EXISTS (SELECT 1 FROM abonnements a WHERE a.id = add_subscription.num) THEN
        RETURN FALSE;
    END IF;

    -- Insérer le nouvel abonnement
    INSERT INTO abonnements (id, utilisateur_id, forfait_id, statut, date_abonnement)
    VALUES (num, user_id, code, 'Incomplete', date_sub);

    RETURN TRUE;
END;
$$ LANGUAGE plpgsql;