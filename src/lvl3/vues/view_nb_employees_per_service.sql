-- Création de la vue view_nb_employees_per_service
CREATE OR REPLACE VIEW view_nb_employees_per_service AS
SELECT cs.name_service AS service, COUNT(e.utilisateur_id) AS nb
FROM
    contrats_services cs
    LEFT JOIN contrats c ON cs.name_service = c.service
    AND c.date_depart IS NULL
    LEFT JOIN employes e ON c.employe_id = e.utilisateur_id
GROUP BY
    cs.name_service
ORDER BY cs.name_service ASC;