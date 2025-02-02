-- Création base de donnée
CREATE DATABASE db_transport;

-- déplacer dans la base de donnée
\connect db_transport

-- Table Transport
CREATE TABLE transport (
    id CHAR(3) PRIMARY KEY,
    nom VARCHAR(32) NOT NULL,
    capacite_max INT NOT NULL,
    duree_moyenne_trajet INT NOT NULL
);

-- Table Zones Tarifaires
CREATE TABLE zones_tarifaires (
    id SERIAL PRIMARY KEY,
    nom VARCHAR(32) NOT NULL,
    prix NUMERIC(10, 2) NOT NULL
);

-- Table Stations
CREATE TABLE stations (
    id SERIAL PRIMARY KEY,
    nom VARCHAR(64) NOT NULL,
    commune VARCHAR(32) NOT NULL,
    zone_id INT NOT NULL,
    FOREIGN KEY (zone_id) REFERENCES zones_tarifaires(id)
);

-- Table Lignes
CREATE TABLE lignes (
    id CHAR(3) PRIMARY KEY,
    moyen_transport_id CHAR(3) NOT NULL, 
    FOREIGN KEY (moyen_transport_id) REFERENCES transport(id),
    nom VARCHAR(32) NOT NULL
);

-- Table pour lier les Stations aux Lignes
CREATE TABLE stations_lignes (
    id SERIAL PRIMARY KEY,
    ligne_id CHAR(3) NOT NULL, 
    FOREIGN KEY (ligne_id) REFERENCES lignes(id),
    station_id INT NOT NULL, 
    FOREIGN KEY (station_id) REFERENCES stations(id),
    position INT NOT NULL,
    CONSTRAINT unique_station_ligne UNIQUE (ligne_id, station_id)
);

-- Table Voyageurs
CREATE TABLE voyageurs (
    id SERIAL PRIMARY KEY,
    nom VARCHAR(32) NOT NULL,
    prenom VARCHAR(32) NOT NULL,
    email VARCHAR(128) NOT NULL,
    telephone CHAR(10),
    courrier_postal TEXT,
    code_postal CHAR(5),
    commune VARCHAR(32),
    iban VARCHAR(34) NULL,
    justificatif_domicile BOOLEAN NULL
);

-- Table Employés
CREATE TABLE employes (
    utilisateur_id INT PRIMARY KEY,
    FOREIGN KEY (utilisateur_id) REFERENCES voyageurs(id),
    login VARCHAR(20) NOT NULL UNIQUE
);

-- Table Contrats
CREATE TABLE contrats (
    id SERIAL PRIMARY KEY,
    employe_id INT NOT NULL,
    FOREIGN KEY (employe_id) REFERENCES employes(utilisateur_id),
    date_embauche DATE NOT NULL,
    date_depart DATE,
    service VARCHAR(32) NOT NULL
);

-- Table Contrats services
CREATE TABLE contrats_services (
    id SERIAL PRIMARY KEY,
    name_service VARCHAR(32) NOT NULL UNIQUE,
    reduction_pourcent NUMERIC(5, 2) NOT NULL
);

-- Table Trajets
CREATE TABLE trajets (
    id SERIAL PRIMARY KEY,
    utilisateur_id INT NOT NULL,
    FOREIGN KEY (utilisateur_id) REFERENCES voyageurs(id),
    station_entree_id INT NOT NULL, 
    FOREIGN KEY (station_entree_id) REFERENCES stations(id),
    station_sortie_id INT NOT NULL,
    FOREIGN KEY (station_sortie_id) REFERENCES stations(id),
    date_entree TIMESTAMP NOT NULL,
    date_sortie TIMESTAMP NOT NULL
);


-- Table Forfaits
CREATE TABLE forfaits (
    id CHAR(5) PRIMARY KEY,
    nom VARCHAR(32) NOT NULL,
    prix_mensuel NUMERIC(10, 2) NOT NULL,
    duree_mois INT NOT NULL CONSTRAINT mois_positif CHECK (duree_mois >= 1),
    zone_min INT NOT NULL, 
    FOREIGN KEY (zone_min) REFERENCES zones_tarifaires(id),
    zone_max INT NOT NULL, 
    FOREIGN KEY (zone_max) REFERENCES zones_tarifaires(id)
);

-- Table Abonnements
CREATE TABLE abonnements (
    id SERIAL PRIMARY KEY,
    utilisateur_id INT NOT NULL,
    FOREIGN KEY (utilisateur_id) REFERENCES voyageurs(id),
    forfait_id CHAR(5) NOT NULL, 
    FOREIGN KEY (forfait_id) REFERENCES forfaits(id),
    statut VARCHAR(15) CONSTRAINT statut_actif CHECK (statut IN ('Registered', 'Pending', 'Incomplete')),
    date_abonnement DATE NOT NULL
);

-- Table Factures
CREATE TABLE factures (
    id SERIAL PRIMARY KEY,
    utilisateur_id INT NOT NULL,
    FOREIGN KEY (utilisateur_id) REFERENCES voyageurs (id),
    annee INT NOT NULL,
    mois INT NOT NULL,
    montant NUMERIC(10, 2) NOT NULL,
    UNIQUE (utilisateur_id, annee, mois)
);
-- Table Paiements
CREATE TABLE paiements (
    id SERIAL PRIMARY KEY,
    facture_id INT NOT NULL,
    FOREIGN KEY (facture_id) REFERENCES factures (id),
    date_paiement DATE NOT NULL
);