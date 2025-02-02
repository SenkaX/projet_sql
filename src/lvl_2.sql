-- Fonctions lvl_2

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


-- Vues lvl_2

-- Création de la vue view_old_subscription
CREATE OR REPLACE VIEW view_old_subscription AS
SELECT
    v.nom || ' ' || v.prenom AS full_name,
    f.nom AS offer_name,
    a.statut AS status
FROM
    abonnements a
    JOIN voyageurs v ON a.utilisateur_id = v.id
    JOIN forfaits f ON a.forfait_id = f.id
WHERE
    a.statut IN ('Incomplete', 'Pending')
    AND a.date_abonnement <= CURRENT_DATE - INTERVAL '1 year'
ORDER BY full_name ASC, offer_name ASC;

-- Création de la vue view_pending_subscriptions
CREATE OR REPLACE VIEW view_pending_subscriptions AS
SELECT
    v.nom AS last_name,
    v.prenom AS first_name,
    v.email AS email,
    a.date_abonnement AS subscription_date
FROM abonnements a
    JOIN voyageurs v ON a.utilisateur_id = v.id
WHERE
    a.statut = 'Pending'
ORDER BY a.date_abonnement ASC;

-- Création de la vue view_unloved_offers
CREATE OR REPLACE VIEW view_unloved_offers AS
SELECT f.nom AS offer_name
FROM forfaits f
    LEFT JOIN abonnements a ON f.id = a.forfait_id
WHERE
    a.forfait_id IS NULL
ORDER BY f.nom ASC;

-- Création de la vue view_user_small_name voyageurs composé de 4 caractères ou moins
CREATE OR REPLACE VIEW view_user_small_name AS
SELECT
    nom AS last_name,
    prenom AS first_name,
    nom || ' ' || prenom AS full_name
FROM voyageurs
WHERE
    LENGTH(nom) <= 4
ORDER BY nom ASC, prenom ASC;

-- Création de la vue view_user_subscription
CREATE OR REPLACE VIEW view_user_subscription AS
SELECT v.nom || ' ' || v.prenom AS user, f.nom AS offer
FROM
    abonnements a
    JOIN voyageurs v ON a.utilisateur_id = v.id
    JOIN forfaits f ON a.forfait_id = f.id
ORDER BY user ASC, offer ASC;


-- Procédures lvl_2

-- Fonction pour lister les stations situées dans la même ville que l'utilisateur
CREATE OR REPLACE FUNCTION list_station_near_user(
    user_email VARCHAR(128)
)
RETURNS TABLE(station_name VARCHAR(64)) AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT LOWER(s.nom)::VARCHAR(64) AS station_name
    FROM stations s
    JOIN voyageurs v ON s.commune = v.commune
    WHERE v.email = user_email
    ORDER BY station_name ASC;
END;
$$ LANGUAGE plpgsql;

-- Fonction pour lister les utilisateurs qui ont souscrit au forfait indiqué
CREATE OR REPLACE FUNCTION list_subscribers(
    code_offer VARCHAR(5)
)
RETURNS SETOF VARCHAR(65) AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT (v.nom || ' ' || v.prenom)::VARCHAR(65) AS full_name
    FROM abonnements a
    JOIN voyageurs v ON a.utilisateur_id = v.id
    WHERE a.forfait_id = code_offer
    ORDER BY full_name ASC;
END;
$$ LANGUAGE plpgsql;

-- Fonction pour lister les codes de forfaits des abonnements en statut "Enregistré" pour un utilisateur donné à une date donnée
CREATE OR REPLACE FUNCTION list_subscription(
    user_email VARCHAR(128),
    sub_date DATE
)
RETURNS TABLE(forfait_code CHAR(5)) AS $$
BEGIN
    RETURN QUERY
    SELECT a.forfait_id AS forfait_code
    FROM abonnements a
    JOIN voyageurs v ON a.utilisateur_id = v.id
    WHERE v.email = user_email
      AND a.statut = 'Registered'
      AND a.date_abonnement = sub_date
    ORDER BY a.forfait_id ASC;
END;
$$ LANGUAGE plpgsql;

-- Fin lvl_2