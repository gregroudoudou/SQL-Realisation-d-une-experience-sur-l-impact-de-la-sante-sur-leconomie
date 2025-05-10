--Partie 1:Création du Schéma

-- Je commence la définition du schéma SQLite de la base de données avec les clés étrangères activées
 .open projet_sql_sante_economie.db --c'est le nom de la base de donnée donnée!
PRAGMA foreign_keys = ON;
PRAGMA database_list;

-- Je crée la table des employeurs, sans relation externe
CREATE TABLE EMPLOYEUR (
    id_entreprise INTEGER PRIMARY KEY,
    nom TEXT NOT NULL,
    nom_manager TEXT,
    benefices REAL,
    heures REAL,
    benefices_par_heure REAL
);

-- Je crée la table des employés avec une clé étrangère vers EMPLOYEUR
CREATE TABLE EMPLOYE (
    id_individu INTEGER PRIMARY KEY,
    nom TEXT NOT NULL,
    prenom TEXT NOT NULL,
    id_entreprise INTEGER,
    salaire REAL,
    FOREIGN KEY (id_entreprise) REFERENCES EMPLOYEUR(id_entreprise)
);

-- Je crée la table des applications pour les mesures de cause, liée à EMPLOYE
CREATE TABLE APPLICATION_CAUSE (
    id_application_cause INTEGER PRIMARY KEY,
    id_individu INTEGER NOT NULL,
    nom TEXT NOT NULL,
    disponibilite TEXT,
    date_heure TEXT NOT NULL,
    but TEXT,
    acteur TEXT,
    smartphone TEXT,
    FOREIGN KEY (id_individu) REFERENCES EMPLOYE(id_individu)
);

-- Je crée la table des applications pour les mesures d'effet, liée à EMPLOYE
CREATE TABLE APPLICATION_EFFECT (
    id_application_effect INTEGER PRIMARY KEY,
    id_individu INTEGER NOT NULL,
    nom TEXT NOT NULL,
    disponibilite TEXT,
    date_heure TEXT NOT NULL,
    but TEXT,
    acteur TEXT,
    smartphone TEXT,
    FOREIGN KEY (id_individu) REFERENCES EMPLOYE(id_individu)
);

-- Je crée la table SPORT_SANTE pour les causes, liée à APPLICATION_CAUSE, EMPLOYE et EMPLOYEUR
CREATE TABLE SPORT_SANTE (
    id_sport INTEGER PRIMARY KEY,
    id_individu INTEGER NOT NULL,
    id_entreprise INTEGER NOT NULL,
    id_application_cause INTEGER NOT NULL,
    minutes_activite INTEGER,
    nb_jours_par_semaine INTEGER,
    nb_types_activite INTEGER,
    nb_escalier INTEGER,
    minutes_debout INTEGER,
    minutes_assis INTEGER,
    FOREIGN KEY (id_individu) REFERENCES EMPLOYE(id_individu),
    FOREIGN KEY (id_entreprise) REFERENCES EMPLOYEUR(id_entreprise),
    FOREIGN KEY (id_application_cause) REFERENCES APPLICATION_CAUSE(id_application_cause)
);

-- Je crée la table ALCOOL pour les causes, avec contrainte 0/1 pour le booléen, liée aux clés externes
CREATE TABLE ALCOOL (
    id_alcool INTEGER PRIMARY KEY,
    id_individu INTEGER NOT NULL,
    id_entreprise INTEGER NOT NULL,
    id_application_cause INTEGER NOT NULL,
    consomme INTEGER CHECK(consomme IN (0,1)),
    freq_par_semaine INTEGER,
    nb_verres_moyen REAL,
    FOREIGN KEY (id_individu) REFERENCES EMPLOYE(id_individu),
    FOREIGN KEY (id_entreprise) REFERENCES EMPLOYEUR(id_entreprise),
    FOREIGN KEY (id_application_cause) REFERENCES APPLICATION_CAUSE(id_application_cause)
);

-- Je crée la table TABAC pour les causes, avec contrainte 0/1, liée aux clés externes
CREATE TABLE TABAC (
    id_tabac INTEGER PRIMARY KEY,
    id_individu INTEGER NOT NULL,
    id_entreprise INTEGER NOT NULL,
    id_application_cause INTEGER NOT NULL,
    consomme_tabac INTEGER CHECK(consomme_tabac IN (0,1)),
    cigarettes_par_jour INTEGER,
    consommation_drogues TEXT,
    freq_drogues_jour INTEGER,
    FOREIGN KEY (id_individu) REFERENCES EMPLOYE(id_individu),
    FOREIGN KEY (id_entreprise) REFERENCES EMPLOYEUR(id_entreprise),
    FOREIGN KEY (id_application_cause) REFERENCES APPLICATION_CAUSE(id_application_cause)
);

-- Je crée la table SOMMEIL pour les causes, liée aux clés externes
CREATE TABLE SOMMEIL (
    id_sommeil INTEGER PRIMARY KEY,
    id_individu INTEGER NOT NULL,
    id_entreprise INTEGER NOT NULL,
    id_application_cause INTEGER NOT NULL,
    heure_debut TEXT,
    heure_fin TEXT,
    heures_moyennes REAL,
    qualite_echelle INTEGER,
    duree_reveil REAL,
    FOREIGN KEY (id_individu) REFERENCES EMPLOYE(id_individu),
    FOREIGN KEY (id_entreprise) REFERENCES EMPLOYEUR(id_entreprise),
    FOREIGN KEY (id_application_cause) REFERENCES APPLICATION_CAUSE(id_application_cause)
);

-- Je crée la table ALIMENTATION pour les causes, liée aux clés externes
CREATE TABLE ALIMENTATION (
    id_alim INTEGER PRIMARY KEY,
    id_individu INTEGER NOT NULL,
    id_entreprise INTEGER NOT NULL,
    id_application_cause INTEGER NOT NULL,
    nb_portions_fruits INTEGER,
    nb_fast_food INTEGER,
    litres_eau REAL,
    type_repas TEXT,
    degre_fatigue INTEGER,
    FOREIGN KEY (id_individu) REFERENCES EMPLOYE(id_individu),
    FOREIGN KEY (id_entreprise) REFERENCES EMPLOYEUR(id_entreprise),
    FOREIGN KEY (id_application_cause) REFERENCES APPLICATION_CAUSE(id_application_cause)
);

-- Je crée la table RISQUE pour les causes, liée aux clés externes
CREATE TABLE RISQUE (
    id_risque INTEGER PRIMARY KEY,
    id_individu INTEGER NOT NULL,
    id_entreprise INTEGER NOT NULL,
    id_application_cause INTEGER NOT NULL,
    ceinture_pourcentage REAL,
    infractions_vitesse INTEGER,
    nb_pauses INTEGER,
    comportement_sante TEXT,
    FOREIGN KEY (id_individu) REFERENCES EMPLOYE(id_individu),
    FOREIGN KEY (id_entreprise) REFERENCES EMPLOYEUR(id_entreprise),
    FOREIGN KEY (id_application_cause) REFERENCES APPLICATION_CAUSE(id_application_cause)
);

-- Je crée la table TROUBLE_MENTAL pour les causes, avec contrainte 0/1, liée aux clés externes
CREATE TABLE TROUBLE_MENTAL (
    id_trouble INTEGER PRIMARY KEY,
    id_individu INTEGER NOT NULL,
    id_entreprise INTEGER NOT NULL,
    id_application_cause INTEGER NOT NULL,
    diagnostic TEXT,
    nb_migraines INTEGER,
    depression INTEGER CHECK(depression IN (0,1)),
    nb_psychologues INTEGER,
    nb_jours_medication INTEGER,
    FOREIGN KEY (id_individu) REFERENCES EMPLOYE(id_individu),
    FOREIGN KEY (id_entreprise) REFERENCES EMPLOYEUR(id_entreprise),
    FOREIGN KEY (id_application_cause) REFERENCES APPLICATION_CAUSE(id_application_cause)
);

-- Je crée les tables d'effets, liées à APPLICATION_EFFECT et aux tables de cause
CREATE TABLE EFFETS_SPORT (
    id_effet_sport INTEGER PRIMARY KEY,
    id_sport INTEGER NOT NULL,
    id_application_effect INTEGER NOT NULL,
    gain_productivite REAL,
    absenteisme_sans_sport INTEGER,
    absenteisme_avec_sport INTEGER,
    impact_PIB_par_habitant REAL,
    FOREIGN KEY (id_sport) REFERENCES SPORT_SANTE(id_sport),
    FOREIGN KEY (id_application_effect) REFERENCES APPLICATION_EFFECT(id_application_effect)
);

-- Je crée la table EFFETS_ALCOOL, avec contrainte 0/1 pour le booléen, liée aux clés externes
CREATE TABLE EFFETS_ALCOOL (
    id_effet_alcool INTEGER PRIMARY KEY,
    id_alcool INTEGER NOT NULL,
    id_application_effect INTEGER NOT NULL,
    maladie_hepatique INTEGER CHECK(maladie_hepatique IN (0,1)),
    stade_hepatique INTEGER,
    hypertension INTEGER CHECK(hypertension IN (0,1)),
    battements_cardiaques INTEGER,
    troubles_mentaux INTEGER CHECK(troubles_mentaux IN (0,1)),
    nb_remarques_travail INTEGER,
    nb_mauvaises_remarques INTEGER,
    temps_travail_heure REAL,
    impact_PIB_par_habitant REAL,
    FOREIGN KEY (id_alcool) REFERENCES ALCOOL(id_alcool),
    FOREIGN KEY (id_application_effect) REFERENCES APPLICATION_EFFECT(id_application_effect)
);

-- Je crée la table EFFETS_TABAC, liée aux clés externes
CREATE TABLE EFFETS_TABAC (
    id_effet_tabac INTEGER PRIMARY KEY,
    id_tabac INTEGER NOT NULL,
    id_application_effect INTEGER NOT NULL,
    respirations_par_minute INTEGER,
    etat_peau TEXT,
    type_test TEXT,
    valeur_co_ppm REAL,
    capacite_vitale_forcee REAL,
    volume_expiratoire_max REAL,
    frequence_respiratoire INTEGER,
    score_coherence INTEGER,
    duree_test INTEGER,
    commentaire TEXT,
    impact_PIB_par_habitant REAL,
    FOREIGN KEY (id_tabac) REFERENCES TABAC(id_tabac),
    FOREIGN KEY (id_application_effect) REFERENCES APPLICATION_EFFECT(id_application_effect)
);

-- Je crée la table EFFETS_SOMMEIL, liée aux clés externes
CREATE TABLE EFFETS_SOMMEIL (
    id_effet_sommeil INTEGER PRIMARY KEY,
    id_sommeil INTEGER NOT NULL,
    id_application_effect INTEGER NOT NULL,
    nb_erreurs_par_mois INTEGER,
    jours_absence_fatigue INTEGER,
    reduction_productivite_perc REAL,
    impact_PIB_par_habitant REAL,
    FOREIGN KEY (id_sommeil) REFERENCES SOMMEIL(id_sommeil),
    FOREIGN KEY (id_application_effect) REFERENCES APPLICATION_EFFECT(id_application_effect)
);

-- Je crée la table EFFETS_ALIMENTATION, liée aux clés externes
CREATE TABLE EFFETS_ALIMENTATION (
    id_effet_alim INTEGER PRIMARY KEY,
    id_alim INTEGER NOT NULL,
    id_application_effect INTEGER NOT NULL,
    impact_vitesse_execution REAL,
    impact_absenteisme INTEGER,
    impact_erreurs INTEGER,
    perte_argent_heure REAL,
    impact_PIB_par_habitant REAL,
    FOREIGN KEY (id_alim) REFERENCES ALIMENTATION(id_alim),
    FOREIGN KEY (id_application_effect) REFERENCES APPLICATION_EFFECT(id_application_effect)
);

-- Je crée la table EFFETS_RISQUE, liée aux clés externes
CREATE TABLE EFFETS_RISQUE (
    id_effet_risque INTEGER PRIMARY KEY,
    id_risque INTEGER NOT NULL,
    id_application_effect INTEGER NOT NULL,
    temps_horaire_moyenne REAL,
    taches_par_heure REAL,
    nb_erreurs INTEGER,
    perte_economique REAL,
    representativite_echelle REAL,
    impact_PIB_par_habitant REAL,
    FOREIGN KEY (id_risque) REFERENCES RISQUE(id_risque),
    FOREIGN KEY (id_application_effect) REFERENCES APPLICATION_EFFECT(id_application_effect)
);

-- Je crée la table EFFETS_TROUBLE, liée aux clés externes
CREATE TABLE EFFETS_TROUBLE (
    id_effet_trouble INTEGER PRIMARY KEY,
    id_trouble INTEGER NOT NULL,
    id_application_effect INTEGER NOT NULL,
    jours_absence INTEGER,
    nb_erreurs INTEGER,
    productivite_horaire_base REAL,
    productivite_horaire_avec_trouble REAL,
    reduction_productivite_perc REAL,
    evolution_productivite REAL,
    impact_PIB_par_habitant REAL,
    FOREIGN KEY (id_trouble) REFERENCES TROUBLE_MENTAL(id_trouble),
    FOREIGN KEY (id_application_effect) REFERENCES APPLICATION_EFFECT(id_application_effect)
);

-- Je crée des index sur les clés étrangères pour optimiser les jointures
CREATE INDEX idx_sport_individu ON SPORT_SANTE(id_individu);
CREATE INDEX idx_alcool_individu ON ALCOOL(id_individu);
CREATE INDEX idx_tabac_individu ON TABAC(id_individu);
CREATE INDEX idx_sommeil_individu ON SOMMEIL(id_individu);
CREATE INDEX idx_alimentation_individu ON ALIMENTATION(id_individu);
CREATE INDEX idx_risque_individu ON RISQUE(id_individu);
CREATE INDEX idx_trouble_individu ON TROUBLE_MENTAL(id_individu);

-- Je définis une vue simplifiée pour illustrer la liaison entre une cause et son effet direct
CREATE VIEW vue_effets_complets AS
SELECT
    s.id_individu,
    s.id_application_cause,
    f.id_application_effect,
    f.gain_productivite,
    f.impact_PIB_par_habitant
FROM SPORT_SANTE s
JOIN EFFETS_SPORT f ON s.id_sport = f.id_sport;

.schema
.tables


------------------------------------
---PARTIE 2: simulation ------------
------------------------------------



--il faut alors charger la base de donnée nommée au début de ce fichier ! Utilisez alors "projetsante.sql"!--


BEGIN;
PRAGMA foreign_keys = OFF;

-- 1) Table temporaire aidant à simuler aléatoirement.   
CREATE TEMPORARY TABLE temp_ids(id INTEGER PRIMARY KEY);
WITH RECURSIVE seq(x) AS (
    SELECT 1
    UNION ALL
    SELECT x+1 FROM seq WHERE x < 300
)
INSERT INTO temp_ids(id) SELECT x FROM seq;

-- 2) Employeurs 
INSERT INTO EMPLOYEUR(nom, nom_manager, benefices, heures, benefices_par_heure)
SELECT
  'Entreprise_' || id,
  'Manager_'    || id,
  ROUND(ABS(RANDOM()) % 5000000 + 500000, 2),
  ROUND(ABS(RANDOM()) % 2000   + 500,    2),
  ROUND((ABS(RANDOM()) % 5000) + 50,     2)
FROM temp_ids;

-- 3) Employés 
INSERT INTO EMPLOYE(nom, prenom, id_entreprise, salaire)
SELECT
  'Nom_'    || id,
  'Prenom_' || id,
  (ABS(RANDOM()) % 300) + 1,
  ROUND(ABS(RANDOM()) % 80000 + 25000, 2)
FROM temp_ids;

-- 4) Applications de cause (300 enregistrements)
INSERT INTO APPLICATION_CAUSE(id_individu, nom, disponibilite, date_heure, but, acteur, smartphone)
SELECT
  id,
  'Cause_' || ((ABS(RANDOM()) % 10) + 1),
  CASE (ABS(RANDOM()) % 3)
    WHEN 0 THEN 'Toujours'
    WHEN 1 THEN 'Périodiquement'
    ELSE 'Jamais'
  END,
  DATETIME('2024-01-01',
           '+' || (ABS(RANDOM()) % 400) || ' days',
           '+' || (ABS(RANDOM()) % 1440) || ' minutes'),
  'Objectif_' || ((ABS(RANDOM()) % 5) + 1),
  CASE (ABS(RANDOM()) % 2) WHEN 0 THEN 'Employé' ELSE 'Employeur' END,
  CASE (ABS(RANDOM()) % 2) WHEN 0 THEN 'Oui' ELSE 'Non' END
FROM temp_ids;

-- 5) Applications d’effet (300 enregistrements)
INSERT INTO APPLICATION_EFFECT(id_individu, nom, disponibilite, date_heure, but, acteur, smartphone)
SELECT
  id,
  'Effet_' || ((ABS(RANDOM()) % 10) + 1),
  CASE (ABS(RANDOM()) % 3)
    WHEN 0 THEN 'Toujours'
    WHEN 1 THEN 'Périodiquement'
    ELSE 'Jamais'
  END,
  DATETIME('2024-01-01',
           '+' || (ABS(RANDOM()) % 400) || ' days',
           '+' || (ABS(RANDOM()) % 1440) || ' minutes'),
  'Résultat_' || ((ABS(RANDOM()) % 5) + 1),
  CASE (ABS(RANDOM()) % 2) WHEN 0 THEN 'Employé' ELSE 'Employeur' END,
  CASE (ABS(RANDOM()) % 2) WHEN 0 THEN 'Oui' ELSE 'Non' END
FROM temp_ids;

-- 6) SPORT_SANTE (300 enregistrements)
INSERT INTO SPORT_SANTE(
  id_individu, id_entreprise, id_application_cause,
  minutes_activite, nb_jours_par_semaine, nb_types_activite,
  nb_escalier, minutes_debout, minutes_assis
)
SELECT
  id,
  (ABS(RANDOM()) % 300) + 1,
  id,
  (ABS(RANDOM()) % 120) + 10,
  (ABS(RANDOM()) % 7)   + 1,
  (ABS(RANDOM()) % 4)   + 1,
  (ABS(RANDOM()) % 30),
  (ABS(RANDOM()) % 240) + 30,
  (ABS(RANDOM()) % 480) + 60
FROM temp_ids;

-- 7) ALCOOL (300 enregistrements)
INSERT INTO ALCOOL(
  id_individu, id_entreprise, id_application_cause,
  consomme, freq_par_semaine, nb_verres_moyen
)
SELECT
  id,
  (ABS(RANDOM()) % 300) + 1,
  id,
  ABS(RANDOM()) % 2,
  ABS(RANDOM()) % 8,
  ROUND((ABS(RANDOM()) % 10) / 2.0, 1)
FROM temp_ids;

-- 8) TABAC (300 enregistrements)
INSERT INTO TABAC(
  id_individu, id_entreprise, id_application_cause,
  consomme_tabac, cigarettes_par_jour, consommation_drogues, freq_drogues_jour
)
SELECT
  id,
  (ABS(RANDOM()) % 300) + 1,
  id,
  ABS(RANDOM()) % 2,
  CASE WHEN (ABS(RANDOM()) % 2)=1 THEN (ABS(RANDOM()) % 30) + 1 ELSE 0 END,
  CASE (ABS(RANDOM()) % 3)
    WHEN 0 THEN ''
    WHEN 1 THEN 'Cannabis'
    ELSE 'Cocaine'
  END,
  ABS(RANDOM()) % 6
FROM temp_ids;

-- 9) SOMMEIL (300 enregistrements)
INSERT INTO SOMMEIL(
  id_individu, id_entreprise, id_application_cause,
  heure_debut, heure_fin, heures_moyennes, qualite_echelle, duree_reveil
)
SELECT
  id,
  (ABS(RANDOM()) % 300) + 1,
  id,
  PRINTF('%02d:%02d:00', 21 + (ABS(RANDOM()) % 4), ABS(RANDOM()) % 60),
  PRINTF('%02d:%02d:00',  5 + (ABS(RANDOM()) % 4), ABS(RANDOM()) % 60),
  ROUND(((ABS(RANDOM()) % 240) + 300) / 60.0, 1),
  (ABS(RANDOM()) % 5) + 1,
  ROUND((ABS(RANDOM()) % 60), 1)
FROM temp_ids;

-- 10) ALIMENTATION (300 enregistrements)
INSERT INTO ALIMENTATION(
  id_individu, id_entreprise, id_application_cause,
  nb_portions_fruits, nb_fast_food, litres_eau, type_repas, degre_fatigue
)
SELECT
  id,
  (ABS(RANDOM()) % 300) + 1,
  id,
  ABS(RANDOM()) % 6,
  ABS(RANDOM()) % 4,
  ROUND(((ABS(RANDOM()) % 30) + 10) / 10.0, 1),
  CASE (ABS(RANDOM()) % 3)
    WHEN 0 THEN 'Équilibré'
    WHEN 1 THEN 'Rapide'
    ELSE 'Copieux'
  END,
  (ABS(RANDOM()) % 10) + 1
FROM temp_ids;

-- 11) RISQUE (300 enregistrements)
INSERT INTO RISQUE(
  id_individu, id_entreprise, id_application_cause,
  ceinture_pourcentage, infractions_vitesse, nb_pauses, comportement_sante
)
SELECT
  id,
  (ABS(RANDOM()) % 300) + 1,
  id,
  ROUND((ABS(RANDOM()) % 101), 1),
  ABS(RANDOM()) % 6,
  ABS(RANDOM()) % 6,
  CASE (ABS(RANDOM()) % 3)
    WHEN 0 THEN 'Prudent'
    WHEN 1 THEN 'Moyen'
    ELSE 'À risque'
  END
FROM temp_ids;

-- 12) TROUBLE_MENTAL (300 enregistrements)
INSERT INTO TROUBLE_MENTAL(
  id_individu, id_entreprise, id_application_cause,
  diagnostic, nb_migraines, depression, nb_psychologues, nb_jours_medication
)
SELECT
  id,
  (ABS(RANDOM()) % 300) + 1,
  id,
  CASE (ABS(RANDOM()) % 4)
    WHEN 0 THEN ''
    WHEN 1 THEN 'Anxiété'
    WHEN 2 THEN 'Dépression'
    ELSE 'Stress'
  END,
  ABS(RANDOM()) % 11,
  ABS(RANDOM()) % 2,
  ABS(RANDOM()) % 4,
  ABS(RANDOM()) % 31
FROM temp_ids;

-- 13) EFFETS_SPORT (300 enregistrements)
INSERT INTO EFFETS_SPORT(
  id_sport, id_application_effect,
  gain_productivite, absenteisme_sans_sport, absenteisme_avec_sport, impact_PIB_par_habitant
)
SELECT
  id, id,
  ROUND((ABS(RANDOM()) % 10) + 1, 1),
  ABS(RANDOM()) % 5,
  ABS(RANDOM()) % 5,
  ROUND((ABS(RANDOM()) % 1000) + 100, 2)
FROM temp_ids;

-- 14) EFFETS_ALCOOL (300 enregistrements)
INSERT INTO EFFETS_ALCOOL(
  id_alcool, id_application_effect,
  maladie_hepatique, stade_hepatique, hypertension,
  battements_cardiaques, troubles_mentaux,
  nb_remarques_travail, nb_mauvaises_remarques,
  temps_travail_heure, impact_PIB_par_habitant
)
SELECT
  id, id,
  ABS(RANDOM()) % 2,
  (ABS(RANDOM()) % 4) + 1,
  ABS(RANDOM()) % 2,
  (ABS(RANDOM()) % 41) + 60,
  ABS(RANDOM()) % 2,
  ABS(RANDOM()) % 11,
  ABS(RANDOM()) % 6,
  ROUND(((ABS(RANDOM()) % 360) + 120) / 60.0, 2),
  ROUND((ABS(RANDOM()) % 1000) + 50, 2)
FROM temp_ids;

-- 15) EFFETS_TABAC (300 enregistrements)
INSERT INTO EFFETS_TABAC(
  id_tabac, id_application_effect,
  respirations_par_minute, etat_peau, type_test,
  valeur_co_ppm, capacite_vitale_forcee, volume_expiratoire_max,
  frequence_respiratoire, score_coherence, duree_test,
  commentaire, impact_PIB_par_habitant
)
SELECT
  id, id,
  (ABS(RANDOM()) % 19) + 12,
  CASE (ABS(RANDOM()) % 3)
    WHEN 0 THEN 'Normale'
    WHEN 1 THEN 'Sèche'
    ELSE 'Irritée'
  END,
  CASE (ABS(RANDOM()) % 2)
    WHEN 0 THEN 'Spirométrie'
    ELSE 'CO'
  END,
  ROUND(ABS(RANDOM()) % 21, 1),
  ROUND(((ABS(RANDOM()) % 500) + 200) / 100.0, 2),
  ROUND(((ABS(RANDOM()) % 500) + 200) / 100.0, 2),
  (ABS(RANDOM()) % 19) + 12,
  ABS(RANDOM()) % 101,
  (ABS(RANDOM()) % 56) + 5,
  CASE (ABS(RANDOM()) % 3)
    WHEN 0 THEN ''
    WHEN 1 THEN 'OK'
    ELSE 'À surveiller'
  END,
  ROUND((ABS(RANDOM()) % 1000) + 100, 2)
FROM temp_ids;

-- 16) EFFETS_SOMMEIL (300 enregistrements)
INSERT INTO EFFETS_SOMMEIL(
  id_sommeil, id_application_effect,
  nb_erreurs_par_mois, jours_absence_fatigue,
  reduction_productivite_perc, impact_PIB_par_habitant
)
SELECT
  id, id,
  ABS(RANDOM()) % 11,
  ABS(RANDOM()) % 6,
  ROUND((ABS(RANDOM()) % 51), 1),
  ROUND((ABS(RANDOM()) % 1000) + 50, 2)
FROM temp_ids;

-- 17) EFFETS_ALIMENTATION (300 enregistrements)
INSERT INTO EFFETS_ALIMENTATION(
  id_alim, id_application_effect,
  impact_vitesse_execution, impact_absenteisme,
  impact_erreurs, perte_argent_heure, impact_PIB_par_habitant
)
SELECT
  id, id,
  ROUND((ABS(RANDOM()) % 51) / 100.0, 2),
  ABS(RANDOM()) % 4,
  ABS(RANDOM()) % 6,
  ROUND((ABS(RANDOM()) % 501) / 10.0, 2),
  ROUND((ABS(RANDOM()) % 1000) + 50, 2)
FROM temp_ids;

-- 18) EFFETS_RISQUE (300 enregistrements)
INSERT INTO EFFETS_RISQUE(
  id_risque, id_application_effect,
  temps_horaire_moyenne, taches_par_heure,
  nb_erreurs, perte_economique, representativite_echelle, impact_PIB_par_habitant
)
SELECT
  id, id,
  ROUND(((ABS(RANDOM()) % 360) + 120) / 60.0, 2),
  ROUND((ABS(RANDOM()) % 901) / 100.0 + 1, 2),
  ABS(RANDOM()) % 6,
  ROUND((ABS(RANDOM()) % 2001), 2),
  ROUND((ABS(RANDOM()) % 101), 1),
  ROUND((ABS(RANDOM()) % 1000) + 100, 2)
FROM temp_ids;

-- 19) EFFETS_TROUBLE (300 enregistrements)
INSERT INTO EFFETS_TROUBLE(
  id_trouble, id_application_effect,
  jours_absence, nb_erreurs,
  productivite_horaire_base, productivite_horaire_avec_trouble,
  reduction_productivite_perc, evolution_productivite, impact_PIB_par_habitant
)
SELECT
  id, id,
  ABS(RANDOM()) % 11,
  ABS(RANDOM()) % 6,
  ROUND((ABS(RANDOM()) % 901) / 100.0 + 5, 2),
  ROUND((ABS(RANDOM()) % 901) / 100.0 + 3, 2),
  ROUND((ABS(RANDOM()) % 51), 1),
  ROUND((ABS(RANDOM()) % 201 - 100) / 100.0, 2),
  ROUND((ABS(RANDOM()) % 1000) + 50, 2)
FROM temp_ids;

-- 20) Nettoyage
DROP TABLE temp_ids;
PRAGMA foreign_keys = ON;
COMMIT;
