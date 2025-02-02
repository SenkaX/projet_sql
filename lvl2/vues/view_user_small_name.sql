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
