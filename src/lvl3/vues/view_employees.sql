-- Création de la vue view_employees
CREATE OR REPLACE VIEW view_employees AS
SELECT
    v.nom AS lastname,
    v.prenom AS firstname,
    e.login AS login,
    c.service AS service
FROM
    employes e
    JOIN voyageurs v ON e.utilisateur_id = v.id
    JOIN contrats c ON e.utilisateur_id = c.employe_id
WHERE
    c.date_depart IS NULL
ORDER BY lastname ASC, firstname ASC, login ASC;