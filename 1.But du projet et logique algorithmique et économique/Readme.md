#  PDF de création de la base de données et de l'analyse des requêtes.

Ce document présente la structure conceptuelle et logique du projet **SQL - Santé et Économie**, à travers plusieurs points clés :

1. **Choix des variables et des clés étrangères :**  
   Chaque table et chaque champ ont été sélectionnés pour représenter de façon réaliste des aspects concrets de la vie professionnelle et personnelle pouvant influencer la productivité. Les **clés étrangères** ont été intégrées avec soin pour assurer la **cohérence relationnelle** entre les entités (employé·e, entreprise, applications, effets, etc.).

2. **Division de la table `APPLICATION` en deux entités :**  
   Afin de renforcer la lisibilité et la logique relationnelle du modèle, la table `APPLICATION` a été divisée en deux :
   - `APPLICATION_CAUSE` : représente les actions ou contextes à l’origine d’un comportement ou d’une situation de santé.
   - `APPLICATION_EFFECT` : enregistre les conséquences ou les impacts mesurés de ces comportements.  
   Cette séparation permet une **modélisation en "cause → effet"** bien structurée, essentielle pour les analyses ultérieures.

3. **Typologie des liens et codification relationnelle :**  
   Le schéma repose sur une logique **entité-relation** :
   - Relations **1:N** entre les employeurs et employés, ou entre les employés et leurs applications.
   - Relations **N:1** entre les effets et leurs causes.
   - Contraintes d’intégrité référentielle assurées par l’utilisation systématique de **clés étrangères**.
   - Des **CHECK constraints** (par exemple, `IN (0,1)`) ont été ajoutées pour garantir la qualité des données booléennes simulées.

---

# 🧭 Schéma Mermaid

Le schéma ci-dessous met en évidence l'ensemble des relations **entre les 20+ tables** de la base de données.  
La division de la table d’applications en deux (`APPLICATION_CAUSE` et `APPLICATION_EFFECT`) a **grandement amélioré la lisibilité** de la structure, rendant chaque flux logique (cause → effet) plus facilement interprétable.

> 🔍 **Conseil :** N’hésitez pas à zoomer sur l’image ci-dessous, car elle regroupe un grand nombre de relations importantes pour comprendre l'architecture globale du projet.

<p align="center">
  <img src="1.But%20du%20projet%20et%20logique%20algorithmique%20et%20%C3%A9conomique/Editor%20_%20Mermaid%20Chart-2025-05-09-195530.png" alt="Schéma Mermaid" width="800"/>
</p>
