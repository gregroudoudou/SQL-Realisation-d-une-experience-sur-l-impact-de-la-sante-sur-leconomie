# Explication du contexte et du but de cette réalisation 

Ce projet est réalisé dans le cadre d'un cours de SQL de **Kévin Michoud(FSEG).** et donc l'unique auteur est **Grégoire Fuchs**.

# But du projet

Il a pour but d'évaluer la façon dont des **décision de  santé** peuvent avoir un impact sur la productivité de **l'entreprise**, approximé par ses bénéfices ; et sur le PIB, qui est directement calculé par l'application de saisie en fonction des facteurs de santé. 

Ce dernier reposerait alors sur l'**évalution moyenne de l'impact sur le PIB**, en fonction donc de l'impact de la décision de santé sur le temps de travail ; et de la qualité du travail, grâce aux entrées données par sa hierarchie ou le manager. 

Ce projet est donc forcément ardu à mettre en place ; mais est  aussi **novateur** ; il repose donc sur la simulation aléatoire de nombres , afin de créer des données ; car elles seraient difficilement obtenues en France et en Europe en raison de la RGPD. 


# Pré-requis 
Notamment, ce fichier a été réalisé sous le gestionnaire Sqlite 3 , et fonctionne donc sous **cette version**. 
Il s'agit entièrement de SQL et ces fichiers de codes  comporte de **nombreuses requêtes**  utiles pour le projet et avancées; et donc certaines sont déjà expliquées lors du PDF;puis en commentaires du SQLite. 



## 🏗️ Structure du Projet et donc des tables

- **Fichier SQLite créé** : `projet_sql_sante_economie.db`
- **Schéma relationnel** :
  - `EMPLOYEUR`, `EMPLOYE` : entreprises et employés
  - `APPLICATION_CAUSE`, `APPLICATION_EFFECT` : mesures de causes/effets
  - Tables de **causes** : `SPORT_SANTE`, `ALCOOL`, `SOMMEIL`, `TABAC`, `TROUBLE_MENTAL`, `ALIMENTATION`, `RISQUE`
  - Tables d'**effets** : `EFFETS_*` pour chaque cause
  - Vues et index pour faciliter l’analyse

# Arborescence : 
/projet-sante-economie/
│
├── projet_sql_sante_economie.db         # Base SQLite
├── creation_schema.sql                 # Partie 1 : création des tables
├── simulation_donnees.sql              # Partie 2 : données de simulation
├── requetes_individuelles.sql          # Partie 3 : requêtes (micro)
├── requetes_macro.sql
├── correlations.sql
├── requetes_finales.sql
└── README.md

# Schéma final de base de données comme Mermaid

![Schéma Mermaid - logique projet](1.But%20du%20projet%20et%20logique%20algorithmique%20et%20%C3%A9conomique/Editor%20_%20Mermaid%20Chart-2025-05-09-195530.png)



