-- Fonctions lvl_4

-- Fonction pour ajouter un trajet pour un utilisateur
CREATE OR REPLACE FUNCTION add_journey(
    email VARCHAR(128),
    time_start TIMESTAMP,
    time_end TIMESTAMP,
    station_start INT,
    station_end INT
)
RETURNS BOOLEAN AS $$
DECLARE
    user_id INT;
BEGIN
    IF time_end - time_start > INTERVAL '24 hours' THEN
        RETURN FALSE;
    END IF;

    SELECT v.id INTO user_id FROM voyageurs v WHERE v.email = add_journey.email;
    IF NOT FOUND THEN
        RETURN FALSE;
    END IF;

    IF EXISTS (
        SELECT 1
        FROM trajets t
        WHERE t.utilisateur_id = user_id
          AND (t.date_entree, t.date_sortie) OVERLAPS (time_start, time_end)
    ) THEN
        RETURN FALSE;
    END IF;

    -- Insérer le nouveau trajet
    INSERT INTO trajets (utilisateur_id, station_entree_id, station_sortie_id, date_entree, date_sortie)
    VALUES (user_id, station_start, station_end, time_start, time_end);

    RETURN TRUE;
END;
$$ LANGUAGE plpgsql;

-- Fonction pour créer une facture pour un utilisateur donné et un mois donné d'une année donnée
CREATE OR REPLACE FUNCTION add_bill(
    user_email VARCHAR(128),
    year INT,
    month INT
)
RETURNS BOOLEAN AS $$
DECLARE
    user_id INT;
    total_cost NUMERIC := 0;
    reduction NUMERIC := 0;
    trajets_cost NUMERIC := 0;
    abonnements_cost NUMERIC := 0;
BEGIN
    SELECT v.id INTO user_id FROM voyageurs v WHERE v.email = user_email;
    IF NOT FOUND THEN
        RAISE NOTICE 'Utilisateur non trouvé';
        RETURN FALSE;
    END IF;

    IF date_trunc('month', CURRENT_DATE) <= make_date(year, month, 1) THEN
        RAISE NOTICE 'Le mois n''est pas terminé';
        RETURN FALSE;
    END IF;

    IF EXISTS (
        SELECT 1
        FROM factures f
        WHERE f.utilisateur_id = user_id
          AND f.annee = year
          AND f.mois = month
    ) THEN
        RAISE NOTICE 'Doublon de facture';
        RETURN FALSE;
    END IF;

    SELECT COALESCE(SUM(f.prix_mensuel), 0) INTO trajets_cost
    FROM trajets t
    JOIN abonnements a ON t.utilisateur_id = a.utilisateur_id
    JOIN forfaits f ON a.forfait_id = f.id
    WHERE t.utilisateur_id = user_id
      AND EXTRACT(YEAR FROM t.date_entree) = year
      AND EXTRACT(MONTH FROM t.date_entree) = month;

    RAISE NOTICE 'Coût des trajets: %', trajets_cost;

    SELECT COALESCE(SUM(f.prix_mensuel), 0) INTO abonnements_cost
    FROM abonnements a
    JOIN forfaits f ON a.forfait_id = f.id
    WHERE a.utilisateur_id = user_id
      AND a.statut = 'Registered'
      AND EXTRACT(YEAR FROM a.date_abonnement) = year
      AND EXTRACT(MONTH FROM a.date_abonnement) = month;

    RAISE NOTICE 'Coût des abonnements: %', abonnements_cost;

    total_cost := trajets_cost + abonnements_cost;

    RAISE NOTICE 'Coût total avant réduction: %', total_cost;

    SELECT COALESCE(MAX(cs.reduction_pourcent), 0) INTO reduction
    FROM employes e
    JOIN contrats c ON e.utilisateur_id = c.employe_id
    JOIN contrats_services cs ON c.service = cs.name_service
    WHERE e.utilisateur_id = user_id
      AND c.date_depart IS NULL;

    RAISE NOTICE 'Réduction: %', reduction;

    total_cost := total_cost * (1 - reduction / 100);

    total_cost := TRUNC(total_cost, 2);

    RAISE NOTICE 'Coût total après réduction: %', total_cost;

    IF total_cost = 0 THEN
        RAISE NOTICE 'Montant total de la facture est nul';
        RETURN TRUE;
    END IF;

 
    INSERT INTO factures (utilisateur_id, annee, mois, montant)
    VALUES (user_id, year, month, total_cost);

    RETURN TRUE;
END;
$$ LANGUAGE plpgsql;

-- Fonction pour indiquer qu'une facture a été payée
CREATE OR REPLACE FUNCTION pay_bill(
    email VARCHAR(128),
    year INT,
    month INT
)
RETURNS BOOLEAN AS $$
DECLARE
    user_id INT;
    facture_id INT;
    total_cost NUMERIC;
BEGIN
    
    SELECT v.id INTO user_id FROM voyageurs v WHERE v.email = email;
    IF NOT FOUND THEN
        RAISE NOTICE 'Utilisateur non trouvé';
        RETURN FALSE;
    END IF;

   
    SELECT f.id, f.montant INTO facture_id, total_cost
    FROM factures f
    WHERE f.utilisateur_id = user_id
      AND f.annee = year
      AND f.mois = month;

   
    IF NOT FOUND THEN
        PERFORM add_bill(email, year, month);
        SELECT f.id, f.montant INTO facture_id, total_cost
        FROM factures f
        WHERE f.utilisateur_id = user_id
          AND f.annee = year
          AND f.mois = month;
    END IF;

   
    IF total_cost = 0 THEN
        RAISE NOTICE 'Montant total de la facture est nul';
        RETURN FALSE;
    END IF;

    
    IF EXISTS (
        SELECT 1
        FROM paiements p
        WHERE p.facture_id = facture_id
    ) THEN
        RAISE NOTICE 'Facture déjà payée';
        RETURN TRUE;
    END IF;

    -- Insérer le paiement
    INSERT INTO paiements (facture_id, date_paiement)
    VALUES (facture_id, CURRENT_DATE);

    RETURN TRUE;
END;
$$ LANGUAGE plpgsql;

-- Fonction pour générer des factures pour tous les utilisateurs
CREATE OR REPLACE FUNCTION generate_bill(
    year INT,
    month INT
)
RETURNS BOOLEAN AS $$
DECLARE
    user_email VARCHAR(128);
    bill_success BOOLEAN;
BEGIN
    
    IF date_trunc('month', CURRENT_DATE) <= make_date(year, month, 1) THEN
        RAISE NOTICE 'Le mois n''est pas terminé';
        RETURN FALSE;
    END IF;

    
    FOR user_email IN
        SELECT email FROM voyageurs
    LOOP
        
        bill_success := add_bill(user_email, year, month);
        IF NOT bill_success THEN
            RAISE NOTICE 'Échec de la génération de la facture pour %', user_email;
        END IF;
    END LOOP;

    RETURN TRUE;
END;
$$ LANGUAGE plpgsql;

-- Vues lvl_4

-- Création de la vue view_all_bilss
CREATE OR REPLACE VIEW view_all_bills AS
SELECT 
    v.nom AS lastname,
    v.prenom AS firstname,
    f.id AS bill_number,
    f.montant AS bill_amount
FROM 
    factures f
JOIN 
    voyageurs v ON f.utilisateur_id = v.id
ORDER BY 
    f.id;

-- Création de la vue view_bill_per_month
CREATE OR REPLACE VIEW view_bill_per_month AS
SELECT 
    annee AS year,
    mois AS month,
    COUNT(*) AS bills,
    SUM(montant) AS total
FROM 
    factures
GROUP BY 
    annee, mois
HAVING 
    COUNT(*) > 0
ORDER BY 
    annee, mois;

-- Création de la vue view_average_entries_station
CREATE OR REPLACE VIEW view_average_entries_station AS
SELECT 
    t.nom AS type,
    s.nom AS station,
    TRUNC(AVG(entries.count), 2) AS entries
FROM 
    (SELECT 
        station_entree_id, 
        COUNT(*) AS count
     FROM 
        trajets
     GROUP BY 
        station_entree_id, date_trunc('day', date_entree)
    ) AS entries
JOIN 
    stations s ON entries.station_entree_id = s.id
JOIN 
    stations_lignes sl ON s.id = sl.station_id
JOIN 
    lignes l ON sl.ligne_id = l.id
JOIN 
    transport t ON l.moyen_transport_id = t.id
GROUP BY 
    t.nom, s.nom
ORDER BY 
    t.nom, s.nom;

-- Création de la vue view_current_non_paid_bills
CREATE OR REPLACE VIEW view_current_non_paid_bills AS
SELECT 
    v.nom AS lastname,
    v.prenom AS firstname,
    f.id AS bill_number,
    f.montant AS bill_amount
FROM 
    factures f
JOIN 
    voyageurs v ON f.utilisateur_id = v.id
WHERE 
    NOT EXISTS (
        SELECT 1 
        FROM paiements p 
        WHERE p.facture_id = f.id
    )
ORDER BY 
    v.nom, v.prenom, f.id;



