-- Fonction pour obtenir le coût d'un voyage entre deux stations
CREATE OR REPLACE FUNCTION get_cost_travel(
    station_start INT,
    station_end INT
)
RETURNS FLOAT AS $$
DECLARE
    start_zone INT;
    end_zone INT;
    total_cost FLOAT := 0;
BEGIN
    -- Vérifier que les stations existent
    IF NOT EXISTS (SELECT 1 FROM stations WHERE id = station_start) OR
       NOT EXISTS (SELECT 1 FROM stations WHERE id = station_end) THEN
        RETURN 0;
    END IF;

    -- Obtenir les zones des stations de départ et d'arrivée
    SELECT zone_id INTO start_zone FROM stations WHERE id = station_start;
    SELECT zone_id INTO end_zone FROM stations WHERE id = station_end;

    -- Calculer le coût total
    IF start_zone <= end_zone THEN
        FOR zone_id IN start_zone..end_zone LOOP
            SELECT prix INTO total_cost FROM zones_tarifaires WHERE id = zone_id;
        END LOOP;
    ELSE
        FOR zone_id IN end_zone..start_zone LOOP
            SELECT prix INTO total_cost FROM zones_tarifaires WHERE id = zone_id;
        END LOOP;
    END IF;

    RETURN total_cost;
END;
$$ LANGUAGE plpgsql;