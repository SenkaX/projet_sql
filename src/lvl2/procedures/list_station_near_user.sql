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