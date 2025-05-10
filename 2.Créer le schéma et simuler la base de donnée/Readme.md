# 📊 Projet SQL - Santé et Économie

Ce projet utilise **SQLite** pour modéliser et simuler une base de données liée à la **santé des employés** et à leur **productivité économique**, en suivant un modèle de causes/effets.

## 🧩 Objectifs

- Créer un schéma relationnel cohérent basé sur des facteurs de santé (sport, alimentation, sommeil, etc.).
- Étudier leur impact sur des indicateurs économiques (absentéisme, productivité, PIB...).
- Simuler des données réalistes pour 300 individus.

---

## 🛠 Partie 1 : Création du Schéma

- Activation des **clés étrangères**.
- Création des tables :
  - **Employeurs** (`EMPLOYEUR`)
  - **Employés** (`EMPLOYE`)
  - **Applications causes/effets** (`APPLICATION_CAUSE`, `APPLICATION_EFFECT`)
  - **Facteurs de santé (causes)** : `SPORT_SANTE`, `ALCOOL`, `TABAC`, `SOMMEIL`, `ALIMENTATION`, `RISQUE`, `TROUBLE_MENTAL`
  - **Effets économiques** : `EFFETS_SPORT`, `EFFETS_ALCOOL`, `EFFETS_TABAC`, `EFFETS_SOMMEIL`, `EFFETS_ALIMENTATION`, `EFFETS_RISQUE`, `EFFETS_TROUBLE`
- Création d'**index** pour améliorer les performances de requêtes.
- Définition d'une **vue** (`vue_effets_complets`) liant causes et effets.

---

## 🎲 Partie 2 : Simulation de Données

Simulation aléatoire de 300 enregistrements pour chaque table à l’aide de `RANDOM()` :

- Utilisation d'une **table temporaire** pour générer des identifiants.
- Insertion de données synthétiques avec des champs réalistes :
  - Noms, salaires, dates, disponibilités, comportements, diagnostics, mesures physiologiques, etc.

---

## 💾 Fichier SQLite

Le fichier principal est :

projet_sql_sante_economie.db
