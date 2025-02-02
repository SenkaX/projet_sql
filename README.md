# Base de Données - Gestion des Transports

Ce projet consiste en une base de données permettant la gestion des transports, des voyageurs, des abonnements et des employés au sein d'un réseau de transport.

## Script SQL

Un script SQL est fourni pour créer la base de données et ses tables. Il inclut :
- La définition des tables avec les clés primaires et étrangères.
- L'ajout de contraintes d'intégrité pour assurer la cohérence des données.
- L'insertion de données de test pour faciliter les premiers essais.

Pour exécuter ce script, utilisez un client SQL compatible avec PostgreSQL et lancez les commandes dans l'ordre indiqué.

## Installation et Utilisation

### Prérequis
- PostgreSQL (ou tout autre SGBD compatible)
- Un client SQL (DBeaver, pgAdmin, etc.)

### Importation de la Base de Données

1. Exécutez le script SQL fourni pour créer les tables et insérer les données.
2. Configurez votre connexion à la base de données avec les informations adéquates.
3. Testez la base avec quelques requêtes SQL pour vérifier son bon fonctionnement.

## Résumé

Cette base de données permet une gestion efficace des transports en reliant les voyageurs, les lignes, les abonnements et les employés. Grâce à une structure relationnelle bien définie, elle assure une traçabilité optimale des trajets et des services proposés aux usagers.



## Diagramme de la Base de Données

Voici le diagramme de la base de données en utilisant **dbdiagram.io**.

![Diagramme DB](./Capture%20d'%C3%A9cran%202025-02-02%20191516.png)


## Schéma de la Base de Données

La base de données est composée des entités suivantes :

- **transport** : définit les moyens de transport avec leur capacité et durée moyenne de trajet.
- **zones_tarifaires** : définit les différentes zones tarifaires et leurs prix.
- **stations** : regroupe les stations et leurs communes associées.
- **lignes** : représente les lignes de transport et leur moyen de transport associé.
- **stations_lignes** : association entre les stations et les lignes avec une position spécifique.
- **voyageurs** : stocke les informations des voyageurs (nom, prénom, email, etc.).
- **employés** : liste les employés avec leurs identifiants d'utilisateur.
- **contrats** : détaille les contrats des employés avec leur date d'embauche et de départ.
- **contrats_services** : représente les services liés aux contrats et les réductions associées.
- **forfaits** : définit les différents forfaits disponibles avec leur prix et leur durée.
- **abonnements** : suit les abonnements des utilisateurs à des forfaits.
- **trajets** : enregistre les trajets effectués par les voyageurs avec les stations d'entrée et de sortie.



