# Explication du contexte et du but de cette réalisation 

Ce projet est réalisé dans le cadre d'un cours de SQL de **Kévin Michoud(FSEG).** et donc l'unique auteur est **Grégoire Fuchs**.

Il a pour but d'évaluer la façon dont des **décision de  santé** peuvent avoir un impact sur la productivité de **l'entreprise**, approximé par ses bénéfices ; et sur le PIB, qui est directement calculé par l'application de saisie en fonction des facteurs de santé. 

Ce dernier reposerait alors sur l'**évalution moyenne de l'impact sur le PIB**, en fonction donc de l'impact de la décision de santé sur le temps de travail ; et de la qualité du travail, grâce aux entrées données par sa hierarchie ou le manager. 

Ce projet est donc forcément ardu à mettre en place ; mais est  aussi **novateur** ; il repose donc sur la simulation aléatoire de nombres , afin de créer des données ; car elles seraient difficilement obtenues en France et en Europe en raison de la RGPD. 

# Pré-requis 
Notamment, ce fichier a été réalisé sous le gestionnaire Sqlite 3 , et fonctionne donc sous cette version. 
Il s'agit entièrement de SQL et ces fichiers de codes  comporte de nombreuses requêtes  utiles pour le projet et avancées; et donc certaines sont déjà expliquées lors du PDF;puis en commentaires du SQLite. 

# Schéma Mermaid
![Schéma Mermaid - logique projet](1.But%20du%20projet%20et%20logique%20algorithmique%20et%20%C3%A9conomique/Editor%20_%20Mermaid%20Chart-2025-05-09-195530.png)


# Installation et démarrage

# 📊 Projet SQL - Santé et Économie

Ce projet explore la relation entre les **habitudes de santé** des employés et leur **productivité économique**, via une modélisation complète en SQL et une simulation de données.

---

## 📄 PDF de Création de la Base de Données

Ce document présente la structure conceptuelle et logique du projet :

1. **Choix des variables et des clés étrangères :**  
   Chaque champ a été conçu pour refléter des comportements réels. Les **clés étrangères** garantissent la cohérence relationnelle entre les entités (employé·e, entreprise, applications, effets...).

2. **Division de la table `APPLICATION` en deux entités :**  
   - `APPLICATION_CAUSE` pour les événements déclencheurs.
   - `APPLICATION_EFFECT` pour les conséquences observées.  
   Cette séparation facilite les analyses "cause → effet" et renforce la clarté structurelle.

3. **Typologie des liens et codification relationnelle :**  
   - Relations 1:N, contraintes d’intégrité référentielle.
   - Utilisation de `CHECK` pour les valeurs booléennes (0/1).
   - Indexation des clés étrangères pour optimiser les performances.

---

## 🧭 Schéma Mermaid

Le schéma ci-dessous illustre toutes les relations entre les tables du projet.  
La division en applications de cause et d’effet rend la **structure plus lisible** malgré ses 20+ tables.

> 🔍 **Conseil :** Zoomez pour une meilleure lecture.

<p align="center">
  <img src="1.But%20du%20projet%20et%20logique%20algorithmique%20et%20%C3%A9conomique/Editor%20_%20Mermaid%20Chart-2025-05-09-195530.png" alt="Schéma Mermaid" width="800"/>
</p>

---

## 🚀 Installation et cémarrage
L’ensemble du **schéma relationnel** et de la **logique algorithmique** est détaillé dans le fichier PDF.

### 🧾 Étapes :

1. **Lancer le script de création de la base de données :**

   ```bash
   sqlite3 projet_sql_sante_economie.db < schema.sql


