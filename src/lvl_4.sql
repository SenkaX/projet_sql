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
    -- Vérifier que l'utilisateur existe et obtenir son ID
    SELECT v.id INTO user_id FROM voyageurs v WHERE v.email = user_email;
    IF NOT FOUND THEN
        RAISE NOTICE 'Utilisateur non trouvé';
        RETURN FALSE;
    END IF;

    -- Vérifier que le mois est terminé
    IF date_trunc('month', CURRENT_DATE) <= make_date(year, month, 1) THEN
        RAISE NOTICE 'Le mois n''est pas terminé';
        RETURN FALSE;
    END IF;

    -- Vérifier qu'il n'y a pas de doublons de factures pour le même mois, la même année et le même utilisateur
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

    -- Calculer le coût total des trajets pour le mois et l'année spécifiés
    SELECT COALESCE(SUM(f.prix_mensuel), 0) INTO trajets_cost
    FROM trajets t
    JOIN abonnements a ON t.utilisateur_id = a.utilisateur_id
    JOIN forfaits f ON a.forfait_id = f.id
    WHERE t.utilisateur_id = user_id
      AND EXTRACT(YEAR FROM t.date_entree) = year
      AND EXTRACT(MONTH FROM t.date_entree) = month;

    RAISE NOTICE 'Coût des trajets: %', trajets_cost;

    -- Ajouter le coût des abonnements en cours
    SELECT COALESCE(SUM(f.prix_mensuel), 0) INTO abonnements_cost
    FROM abonnements a
    JOIN forfaits f ON a.forfait_id = f.id
    WHERE a.utilisateur_id = user_id
      AND a.statut = 'Registered'
      AND EXTRACT(YEAR FROM a.date_abonnement) = year
      AND EXTRACT(MONTH FROM a.date_abonnement) = month;

    RAISE NOTICE 'Coût des abonnements: %', abonnements_cost;

    -- Calculer le coût total
    total_cost := trajets_cost + abonnements_cost;

    RAISE NOTICE 'Coût total avant réduction: %', total_cost;

    -- Vérifier si l'utilisateur est salarié et appliquer la réduction
    SELECT COALESCE(MAX(cs.reduction_pourcent), 0) INTO reduction
    FROM employes e
    JOIN contrats c ON e.utilisateur_id = c.employe_id
    JOIN contrats_services cs ON c.service = cs.name_service
    WHERE e.utilisateur_id = user_id
      AND c.date_depart IS NULL;

    RAISE NOTICE 'Réduction: %', reduction;

    -- Appliquer la réduction
    total_cost := total_cost * (1 - reduction / 100);

    -- Arrondir le total à 2 décimales
    total_cost := ROUND(total_cost, 2);

    RAISE NOTICE 'Coût total après réduction: %', total_cost;

    -- Si le montant total de la facture est nul, retourner true
    IF total_cost = 0 THEN
        RAISE NOTICE 'Montant total de la facture est nul';
        RETURN TRUE;
    END IF;

    -- Insérer la nouvelle facture
    INSERT INTO factures (utilisateur_id, annee, mois, montant)
    VALUES (user_id, year, month, total_cost);

    RETURN TRUE;
END;
$$ LANGUAGE plpgsql;