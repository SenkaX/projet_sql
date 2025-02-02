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