

-- 
-- Partie 3 :requêtes : Partie Micro-niveaux (impact individuel)
-- 
--    et estimation de la perte de bénéfices par heure--
--cela permet par la suite d'identifier les min/max ...etc ! 
--cette partie permet d'évaluer plus l'impact macroéconomique --
--ainsi, cela sera plus le chiffre d'affaire gagné qui est calculé automatiquement par l'application--
--pour le calculer elle fait GAINSpersonne>7h-Gains/pertespersonnes<7h--
--évaluer grâce au temps effectif de travail ! et l' impact PIB/heure moyen --

--Pourquoi pas le bénéfice pour le PIB? Car le PIB est basée uniquement sur "la valeur ajoutée de l'entreprise"--
--ainsi est pris en compte la chaîne de production; et uniquement l'intervention de l'entreprise sur sa partie du Prix.absenteisme_avec_sport
--cela permet d'éviter de compter en double certains gains/pertes  

--ce calcul est automatique par l'application 2et3--

-- 1. Moyenne de minutes d’activité physique par employé
SELECT 
  s.id_individu, 
  AVG(s.minutes_activite) AS moyenne_minutes_activite
FROM SPORT_SANTE s
GROUP BY s.id_individu;

-- 2. Médiane de minutes d’activité physique par employé
--permet d'identifier la durée médiane d'activité physique par employé--
--le "par employé", qui agit comme une condition sur les valeurs demande donc d'utiliser un "groupby"--
--cela permet donc d'agréger lorsque le même ID se répète et présenter une statistique dessus--
SELECT 
  id_individu,
  AVG(minutes_activite) AS mediane_minutes_activite
FROM (
  SELECT 
    id_individu,
    minutes_activite,
    ROW_NUMBER() OVER (
      PARTITION BY id_individu 
      ORDER BY minutes_activite
    ) AS rn,
    COUNT(*) OVER (PARTITION BY id_individu) AS cnt
  FROM SPORT_SANTE
)
WHERE rn IN ((cnt+1)/2, (cnt+2)/2)
GROUP BY id_individu;

--cette vision par individu reste assez anecdotique , il est surtout intéressant de voire les stats globales--

-- 1) Moyenne, minimum et maximum
SELECT
  ROUND(AVG(minutes_activite), 2) AS moyenne_minutes,
  MIN(minutes_activite)           AS min_minutes,
  MAX(minutes_activite)           AS max_minutes
FROM SPORT_SANTE;


-- 2) Médiane, 1er quartile et 3ème quartile
WITH ord AS (
  SELECT
    minutes_activite,
    ROW_NUMBER() OVER (ORDER BY minutes_activite) AS rn,
    COUNT(*)       OVER ()                AS cnt
  FROM SPORT_SANTE
)
SELECT
  -- Médiane (pour n pair, moyenne des deux valeurs centrales)
  ROUND(
    AVG(CASE 
      WHEN rn IN (CAST(cnt/2.0 AS INTEGER),
                  CAST(cnt/2.0 AS INTEGER) + 1)
      THEN minutes_activite
    END)
  , 2) AS mediane_minutes,

  -- 1er quartile à la position floor((n+1)/4)
  MIN(CASE WHEN rn = CAST((cnt+1)/4.0 AS INTEGER)
           THEN minutes_activite END)
    AS q1_minutes,

  -- 3ème quartile à la position floor(3*(n+1)/4)
  MIN(CASE WHEN rn = CAST(3*(cnt+1)/4.0 AS INTEGER)
           THEN minutes_activite END)
    AS q3_minutes
FROM ord;
--ces statistiques permettent d'évaluer l'engagement sportif de manière globale des individus--
--cela permet donc d'avoir une vision plus globale, et de comparer par rapport aux 
--objectifs de l'OMS--

-- 3) Écart-type et variance (via user-defined fonctions si disponible)
-- SQLite ne fournit pas nativement STDDEV/VARIANCE, 
-- mais si vous avez chargé une extension, ça pourrait ressembler à :
-- SELECT STDDEV_POP(minutes_activite), VAR_POP(minutes_activite) FROM SPORT_SANTE;
--ainsi ici la moyenne_minutes est supérieure à la recommandation de l'OMS de 140 minutes par semaine--
--soit 20 minutes/jour--

-- 
-- STATISTIQUES DESCRIPTIVES SUR LA PRODUCTIVITÉ LIÉE AU SPORT
--le but est d'identifier déjà les outliers : pourquoi certaines entreprises auraient des individus qui seraient plus productifs après une séance de sport ? --
--cela permettra d'améliorer la véracité de nos propos !--
-- 1) Moyenne, minimum et maximum de gain_productivite (toutes séances)
SELECT
  ROUND(AVG(f.gain_productivite), 2) AS moyenne_gain,
  MIN(f.gain_productivite)            AS min_gain,
  MAX(f.gain_productivite)            AS max_gain
FROM EFFETS_SPORT f;


-- 2) Médiane, 1er et 3ème quartiles de gain_productivite--
--requête longue à lancer d'un bloc ! sinon l'indentation posera souci.--

WITH ord AS (
  SELECT
    f.gain_productivite,
    ROW_NUMBER() OVER (ORDER BY f.gain_productivite) AS rn,
    COUNT(*)           OVER ()                AS cnt
  FROM EFFETS_SPORT f
)
SELECT
  -- Médiane (moyenne des deux valeurs centrales si n pair)
  ROUND(
    AVG(CASE
      WHEN rn IN (
        CAST(cnt/2.0 AS INTEGER),
        CAST(cnt/2.0 AS INTEGER) + 1
      ) THEN gain_productivite
    END)
  , 2) AS mediane_gainsport,

  -- 1er quartile en position floor((n+1)/4)
  MIN(CASE
    WHEN rn = CAST((cnt+1)/4.0 AS INTEGER)
    THEN gain_productivite
  END) AS q1_gainsport,

  -- 3ème quartile en position floor(3*(n+1)/4)
  MIN(CASE
    WHEN rn = CAST(3*(cnt+1)/4.0 AS INTEGER)
    THEN gain_productivite
  END) AS q3_gainsport
FROM ord;

--Ici on observe que la médiane des gains est de 5 euros/heures : ce qui est assez important !--
--ces résultats peuvent être modifiées à chaque simulation !!--
--cela signifie que 50% des entreprises ont pu avoir des gains supérieurs à 5 euros/heures par employé 
--faisant une séance de sport

--50% ont pu observer des gains inférieurs à la valeur de la médiane, donc 5.0 euros de 
--bénéfices/heures de gagner!
--cela permet d'avoir une mesure plus proche de la réalité
--Pourquoi ? la moyenne est trop influencée par les valeurs aberrantes ! 

--1/3e quartile : pourquoi ? Car cela va notamment permettre d'observer s'il existe une
--grande dispersion entre les mesures prises : ici on voit tout de même un écart de 2,5 euros
--avec la médiane

-- 3) Moyenne de gain_productivite par entreprise
--    et identification de l’entreprise max / min--
--le gain de productivité est calcul par l'algorithme de l'application directement!--
-- a) Moyenne de gain par entreprise (toutes) permettant donc d'en tirer des minimum et des maximum
SELECT
  em.id_entreprise,
  em.nom             AS nom_entreprise,
  ROUND(AVG(f.gain_productivite),2) AS moyenne_gain_sport--arrondir à 2 chiffres suffira--
FROM SPORT_SANTE s
JOIN EFFETS_SPORT   f ON s.id_sport = f.id_sport --comme vu en cours--
JOIN EMPLOYEUR      em ON s.id_entreprise = em.id_entreprise
GROUP BY em.id_entreprise, em.nom
ORDER BY moyenne_gain_sport DESC;

-- b) Top 1 entreprise la plus performante avec sa moyenne de gain de productivité !
SELECT id_entreprise, nom_entreprise, moyenne_gain_sport
FROM (
  SELECT
    em.id_entreprise,
    em.nom            AS nom_entreprise,
    ROUND(AVG(f.gain_productivite),2) AS moyenne_gain_sport
  FROM SPORT_SANTE s
  JOIN EFFETS_SPORT f ON s.id_sport = f.id_sport
  JOIN EMPLOYEUR em ON s.id_entreprise = em.id_entreprise
  GROUP BY em.id_entreprise, em.nom
)
ORDER BY moyenne_gain_sport DESC
LIMIT 1;

-- c) Top 1 entreprise la moins performante
SELECT id_entreprise, nom_entreprise, moyenne_gain_sport
FROM (
  SELECT
    em.id_entreprise,
    em.nom            AS nom_entreprise,
    ROUND(AVG(f.gain_productivite),2) AS moyenne_gain_sport
  FROM SPORT_SANTE s
  JOIN EFFETS_SPORT f ON s.id_sport = f.id_sport
  JOIN EMPLOYEUR em ON s.id_entreprise = em.id_entreprise
  GROUP BY em.id_entreprise, em.nom
)
ORDER BY moyenne_gain_sport ASC
LIMIT 1;



-- 3. Moyenne de verres d’alcool par employé : quel impact d'un verre précis d'alcool
--sur la productivité moyenne des individus ? médiane ? 
--l'ID sélectionné à gauche est celle de l'individu et permet donc de l'identifier--
-- Script : Évaluer les effets d’un nombre précis de verres en termes de productivité et d’impact PIB
-- 
-- STATISTIQUES DÉCRIPTIVES SUR gain_productivite de l'alcool 
-- 

-- 1) Moyenne, minimum et maximum : statistiques globales ! 
SELECT
  ROUND(AVG(f.gain_productivite),2) AS moyenne_gain_alcool,
  MIN(f.gain_productivite)           AS min_gain_alcool,
  MAX(f.gain_productivite)           AS max_gain_alcool
FROM EFFETS_SPORT f;


-- 2) Médiane (position(s) centrales)
SELECT
  AVG(x) AS mediane_gain_alcool
FROM (
  SELECT gain_productivite AS x
  FROM EFFETS_SPORT
  ORDER BY x
  -- si N impair : LIMIT 1   OFFSET (N-1)/2
  -- si N pair   : LIMIT 2   OFFSET (N/2 - 1)
  LIMIT 2 - ((SELECT COUNT(*) FROM EFFETS_SPORT) % 2)
  OFFSET (SELECT (COUNT(*)-1)/2 FROM EFFETS_SPORT)
);


-- 3) 1er quartile (valeur en ⌊(N+1)/4⌋ᵉ position)
SELECT
  q1_alcool AS q1_alcool
FROM (
  SELECT gain_productivite AS q1_alcool
  FROM EFFETS_SPORT
  ORDER BY gain_productivite
  LIMIT 1
  OFFSET ((SELECT (COUNT(*)+1)/4 FROM EFFETS_SPORT) - 1)
);


-- 4) 3ᵉ quartile (valeur en ⌊3·(N+1)/4⌋ᵉ position)
SELECT
  q3_alcool AS troisieme_quartile
FROM (
  SELECT gain_productivite AS q3_alcool
  FROM EFFETS_SPORT
  ORDER BY gain_productivite
  LIMIT 1
  OFFSET ((SELECT (3*(COUNT(*)+1)/4) FROM EFFETS_SPORT) - 1)
);


-- 5) Entreprises : moyenne de gain_productivite
-- puis on repère la plus haute et la plus basse
SELECT
  em.id_entreprise,
  em.nom                              AS nom_entreprise,
  ROUND(AVG(f.gain_productivite),2)   AS moyenne_gain_sport
FROM SPORT_SANTE s
JOIN EFFETS_SPORT f ON s.id_sport = f.id_sport
JOIN EMPLOYEUR em  ON s.id_entreprise = em.id_entreprise
GROUP BY em.id_entreprise, em.nom
ORDER BY moyenne_gain_sport DESC;



-- 6a) Entreprise la plus performante
SELECT id_entreprise, nom_entreprise, moyenne_gain_sport
FROM (
  -- Réutilise la requête précédente comme sous-requête
  SELECT
    em.id_entreprise,
    em.nom            AS nom_entreprise,
    ROUND(AVG(f.gain_productivite),2) AS moyenne_gain_sport
  FROM SPORT_SANTE s
  JOIN EFFETS_SPORT f ON s.id_sport = f.id_sport
  JOIN EMPLOYEUR em  ON s.id_entreprise = em.id_entreprise
  GROUP BY em.id_entreprise, em.nom
)
ORDER BY moyenne_gain_sport DESC
LIMIT 1;


-- 6b) Entreprise la moins performante
SELECT id_entreprise, nom_entreprise, moyenne_gain_sport
FROM (
  -- Même sous-requête
  SELECT
    em.id_entreprise,
    em.nom            AS nom_entreprise,
    ROUND(AVG(f.gain_productivite),2) AS moyenne_gain_sport
  FROM SPORT_SANTE s
  JOIN EFFETS_SPORT f ON s.id_sport = f.id_sport
  JOIN EMPLOYEUR em  ON s.id_entreprise = em.id_entreprise
  GROUP BY em.id_entreprise, em.nom
)
ORDER BY moyenne_gain_sport ASC
LIMIT 1;


-- 4. Médiane de verres d’alcool par employé par aggrégation
--ex:l'employé 2 parmi toutes les mesures prisent et dont répétées
-- ok si le nombre de valeurs n est impair, alors la valeur est n+1/2--
--si le nombre de valeuers de n est pair, alors la valeur de la médiane après comptage  de n verres est la moyenne des positions n/2 et n/2+1
--cela correspond alors à une valeur déjà enregistrée de l'individu--
--elle est intéressante si beaucoup de mesures sont prises--
SELECT 
  id_individu,
  AVG(nb_verres_moyen) AS mediane_verres
FROM (
  SELECT 
    id_individu,
    nb_verres_moyen,
    ROW_NUMBER() OVER (
      PARTITION BY id_individu 
      ORDER BY nb_verres_moyen
    ) AS rn,
    COUNT(*) OVER (PARTITION BY id_individu) AS cnt
  FROM ALCOOL
)
WHERE rn IN (
  CAST(cnt/2 AS INTEGER),
  CAST(cnt/2 AS INTEGER) + 1
)
GROUP BY id_individu;


-- 
-- STATISTIQUES DESCRIPTIVES SUR L’IMPACT PIB LIÉ À L’ALCOOL
-- 

-- 1) Moyenne, minimum et maximum de impact_PIB_par_habitant
SELECT
  ROUND(AVG(ea.impact_PIB_par_habitant),2) AS moyenne_impact_PIB,
  MIN(ea.impact_PIB_par_habitant)           AS min_impact_PIB,
  MAX(ea.impact_PIB_par_habitant)           AS max_impact_PIB
FROM EFFETS_ALCOOL ea;


-- 2) Médiane de impact_PIB_par_habitant
SELECT
  AVG(x) AS mediane_impact_PIB
FROM (
  SELECT impact_PIB_par_habitant AS x
  FROM EFFETS_ALCOOL
  ORDER BY x
  LIMIT 2 - ((SELECT COUNT(*) FROM EFFETS_ALCOOL) % 2)
  OFFSET (SELECT (COUNT(*)-1)/2 FROM EFFETS_ALCOOL)
);


-- 3) 1er quartile de impact_PIB_par_habitant
SELECT
  q1 AS premier_quartile_PIB
FROM (
  SELECT impact_PIB_par_habitant AS q1
  FROM EFFETS_ALCOOL
  ORDER BY impact_PIB_par_habitant
  LIMIT 1
  OFFSET ((SELECT (COUNT(*)+1)/4 FROM EFFETS_ALCOOL) - 1)
);
--25% des entreprises connaissent un gain faible de PIB/heure/habitant
-- pour un verre d'alcool de moins--
--il est de 0,538 ici. 
--75% connaissent un gain inférieur. 


-- 4) 3ème quartile de impact_PIB_par_habitant
SELECT
  q3 AS troisieme_quartile_PIB
FROM (
  SELECT impact_PIB_par_habitant AS q3
  FROM EFFETS_ALCOOL
  ORDER BY impact_PIB_par_habitant
  LIMIT 1
  OFFSET ((SELECT (3*(COUNT(*)+1)/4) FROM EFFETS_ALCOOL) - 1)
);
--le 3eme quartile est beaucoup plus important (sûrement dû à l'aléatoire...)de 648 euros...absenteisme_avec_sport

-- 
-- STATISTIQUES  des différences de productivités liées à l'alcool : PAR FRÉQUENCE DE CONSOMMATION
-- (nb jours par semaine)
---
WITH base AS (
  SELECT
    a.freq_par_semaine,
    ea.nb_remarques_travail,
    ea.temps_travail_heure,
    ea.impact_PIB_par_habitant,
    ROW_NUMBER() OVER (
      PARTITION BY a.freq_par_semaine 
      ORDER BY ea.nb_remarques_travail
    ) AS rn_rt,
    COUNT(*) OVER (PARTITION BY a.freq_par_semaine) AS cnt_rt,
    ROW_NUMBER() OVER (
      PARTITION BY a.freq_par_semaine 
      ORDER BY ea.temps_travail_heure
    ) AS rn_tt,
    COUNT(*) OVER (PARTITION BY a.freq_par_semaine) AS cnt_tt,
    ROW_NUMBER() OVER (
      PARTITION BY a.freq_par_semaine 
      ORDER BY ea.impact_PIB_par_habitant
    ) AS rn_imp,
    COUNT(*) OVER (PARTITION BY a.freq_par_semaine) AS cnt_imp
  FROM ALCOOL a
  JOIN EFFETS_ALCOOL ea ON a.id_alcool = ea.id_alcool
)
SELECT
  freq_par_semaine                             AS jours_par_semaine,
  COUNT(*)                                     AS nb_individus,
  ROUND(AVG(nb_remarques_travail),2)           AS moy_remarques_travail,
  ROUND(
    AVG(CASE
      WHEN rn_rt IN (
           CAST(cnt_rt/2.0 AS INTEGER),
           CAST(cnt_rt/2.0 AS INTEGER) + 1
         )
      THEN nb_remarques_travail
    END)
  ,2)                                          AS mediane_remarques_travail,
  ROUND(AVG(temps_travail_heure),2)            AS moy_temps_travail_heure,
  ROUND(
    AVG(CASE
      WHEN rn_tt IN (
           CAST(cnt_tt/2.0 AS INTEGER),
           CAST(cnt_tt/2.0 AS INTEGER) + 1
         )
      THEN temps_travail_heure
    END)
  ,2)                                          AS mediane_temps_travail_heure,
  ROUND(AVG(impact_PIB_par_habitant),2)        AS moy_impact_PIB,
  ROUND(
    AVG(CASE
      WHEN rn_imp IN (
           CAST(cnt_imp/2.0 AS INTEGER),
           CAST(cnt_imp/2.0 AS INTEGER) + 1
         )
      THEN impact_PIB_par_habitant
    END)
  ,2)                                          AS mediane_impact_PIB
FROM base
GROUP BY freq_par_semaine
ORDER BY freq_par_semaine;



-- 
-- STATISTIQUES PAR NOMBRE DE VERRES MOYEN
-- Moyenne et médiane de nb_remarques_travail, temps_travail_heure, impact_PIB_par_habitant
-- 
WITH base2 AS (
  SELECT
    a.nb_verres_moyen,
    ea.nb_remarques_travail,
    ea.temps_travail_heure,
    ea.impact_PIB_par_habitant,
    ROW_NUMBER() OVER (
      PARTITION BY a.nb_verres_moyen 
      ORDER BY ea.nb_remarques_travail
    ) AS rn_rt,
    COUNT(*) OVER (PARTITION BY a.nb_verres_moyen) AS cnt_rt,
    ROW_NUMBER() OVER (
      PARTITION BY a.nb_verres_moyen 
      ORDER BY ea.temps_travail_heure
    ) AS rn_tt,
    COUNT(*) OVER (PARTITION BY a.nb_verres_moyen) AS cnt_tt,
    ROW_NUMBER() OVER (
      PARTITION BY a.nb_verres_moyen 
      ORDER BY ea.impact_PIB_par_habitant
    ) AS rn_imp,
    COUNT(*) OVER (PARTITION BY a.nb_verres_moyen) AS cnt_imp
  FROM ALCOOL a
  JOIN EFFETS_ALCOOL ea ON a.id_alcool = ea.id_alcool
)
SELECT
  nb_verres_moyen                             AS verres_moyens,
  COUNT(*)                                     AS nb_individus,
  ROUND(AVG(nb_remarques_travail),2)           AS moy_remarques_travail,
  ROUND(
    AVG(CASE
      WHEN rn_rt IN (
           CAST(cnt_rt/2.0 AS INTEGER),
           CAST(cnt_rt/2.0 AS INTEGER) + 1
         )
      THEN nb_remarques_travail
    END)
  ,2)                                          AS mediane_remarques_travail,
  ROUND(AVG(temps_travail_heure),2)            AS moy_temps_travail_heure,
  ROUND(
    AVG(CASE
      WHEN rn_tt IN (
           CAST(cnt_tt/2.0 AS INTEGER),
           CAST(cnt_tt/2.0 AS INTEGER) + 1
         )
      THEN temps_travail_heure
    END)
  ,2)                                          AS mediane_temps_travail_heure,
  ROUND(AVG(impact_PIB_par_habitant),2)        AS moy_impact_PIB,
  ROUND(
    AVG(CASE
      WHEN rn_imp IN (
           CAST(cnt_imp/2.0 AS INTEGER),
           CAST(cnt_imp/2.0 AS INTEGER) + 1
         )
      THEN impact_PIB_par_habitant
    END)
  ,2)                                          AS mediane_impact_PIB
FROM base2
GROUP BY nb_verres_moyen
ORDER BY nb_verres_moyen;

-- 
-- STATISTIQUES PAR NOMBRE DE VERRES MOYEN et remarques sur le travail ; sur le temps de 
--travail par time tracking....
-- 

SELECT
  a.nb_verres_moyen                             AS verres_moyens,
  COUNT(DISTINCT a.id_individu)                  AS nb_individus,
  ROUND(AVG(ea.nb_remarques_travail),2)          AS moy_remarques_travail,
  ROUND(AVG(ea.temps_travail_heure),2)           AS moy_temps_travail_heure,
  ROUND(AVG(ea.impact_PIB_par_habitant),2)       AS moy_impact_PIB,
  ROUND(SUM(ea.impact_PIB_par_habitant),2)       AS total_impact_PIB
FROM ALCOOL a
JOIN EFFETS_ALCOOL ea ON a.id_alcool = ea.id_alcool
GROUP BY a.nb_verres_moyen
ORDER BY a.nb_verres_moyen;


-- 
-- EFFETS POUR UN NOMBRE PRÉCIS DE VERRES
-- (modifiez la valeur dans la CTE params)
-- 

WITH params(nb_verres) AS (
  VALUES (5)  -- ← Remplacez 5 par le nombre de verres désiré
),
cible AS (
  SELECT
    a.id_individu,
    a.nb_verres_moyen,
    a.freq_par_semaine,
    ea.nb_remarques_travail,
    ea.temps_travail_heure,
    ea.impact_PIB_par_habitant
  FROM ALCOOL a
  JOIN EFFETS_ALCOOL ea
    ON a.id_alcool = ea.id_alcool
  JOIN params p
    ON a.nb_verres_moyen = p.nb_verres
)
SELECT
  p.nb_verres                        AS verres_consommés,
  COUNT(*)                           AS nb_individus,
  ROUND(AVG(c.nb_remarques_travail),2)    AS moyenne_remarques_travail,
  ROUND(AVG(c.temps_travail_heure),2)     AS moyenne_temps_travail_heure,
  ROUND(AVG(c.impact_PIB_par_habitant),2) AS moyenne_impact_PIB_par_habitant,
  ROUND(SUM(c.impact_PIB_par_habitant),2) AS impact_PIB_total
FROM cible c
JOIN params p ON c.nb_verres_moyen = p.nb_verres
GROUP BY p.nb_verres;





-- 9. Moyenne d’absentéisme lié à l’alcool
SELECT 
  a.id_individu, 
  AVG(ea.nb_remarques_travail) AS moyenne_remarques_travail
FROM ALCOOL a
JOIN EFFETS_ALCOOL ea ON a.id_alcool = ea.id_alcool
GROUP BY a.id_individu;

-- 10. Médiane des absences liées à l’alcool
SELECT 
  id_individu,
  AVG(nb_remarques_travail) AS mediane_remarques_travail
FROM (
  SELECT 
    a.id_individu,
    ea.nb_remarques_travail,
    ROW_NUMBER() OVER (
      PARTITION BY a.id_individu 
      ORDER BY ea.nb_remarques_travail
    ) AS rn,
    COUNT(*) OVER (PARTITION BY a.id_individu) AS cnt
  FROM ALCOOL a
  JOIN EFFETS_ALCOOL ea ON a.id_alcool = ea.id_alcool
)
WHERE rn IN ((cnt+1)/2, (cnt+2)/2)
GROUP BY id_individu;



--Sous partie 3:.Sport et productivité--






-- 5. Moyenne de jours d’absence pour fatigue par employé à cause d'un sommeil diminué ;
--juste pour voir techniquement--
SELECT 
  so.id_individu,
  AVG(es.jours_absence_fatigue) AS moyenne_absence_fatigue
FROM SOMMEIL so
JOIN EFFETS_SOMMEIL es ON so.id_sommeil = es.id_sommeil
GROUP BY so.id_individu;


--Et il est plus utile d'avoir le nom prénom de la personne directement !--
-- Ainsi, cette requête va afficher le nom et prénom de chaque employé avec sa moyenne de jours d'absence pour fatigue
SELECT
  so.id_individu,
  e.nom,
  e.prenom,
  ROUND(AVG(es.jours_absence_fatigue), 2) AS moyenne_absence_fatigue
FROM SOMMEIL so
JOIN EFFETS_SOMMEIL es
  ON so.id_sommeil = es.id_sommeil
JOIN EMPLOYE e
  ON so.id_individu = e.id_individu
GROUP BY
  so.id_individu,
  e.nom,
  e.prenom
ORDER BY
  moyenne_absence_fatigue DESC;

-- 6. Médiane de jours d’absence pour fatigue par employé
-- 
-- STATISTIQUES DESCRIPTIVES SUR LES EFFETS DU SOMMEIL
-- (bénéfices/heures et impact PIB par entreprise)
-- 


--1.Stats de productivité --


-- 1) Statistiques globales de réduction ou gain de productivité et d’impact PIB
SELECT
  ROUND(AVG(es.reduction_productivite_perc),2)     AS moyenne_reduc_prod,
  MIN(es.reduction_productivite_perc)              AS min_reduc_prod,
  MAX(es.reduction_productivite_perc)              AS max_reduc_prod,
  ROUND(AVG(es.impact_PIB_par_habitant),2)         AS moyenne_impact_PIB,
  MIN(es.impact_PIB_par_habitant)                  AS min_impact_PIB,
  MAX(es.impact_PIB_par_habitant)                  AS max_impact_PIB
FROM EFFETS_SOMMEIL es;


-- 2) Médiane de réduction de productivité
SELECT
  AVG(x) AS mediane_reduc_prod
FROM (
  SELECT reduction_productivite_perc AS x
  FROM EFFETS_SOMMEIL
  ORDER BY x
  LIMIT 2 - ( (SELECT COUNT(*) FROM EFFETS_SOMMEIL) % 2 )
  OFFSET (SELECT (COUNT(*)-1)/2 FROM EFFETS_SOMMEIL)
);
--ici la médiane de gain de prodcutivité globale 
--liée à une heure de plus de sommeil(calculé par l'application)
--est de 25 euros/bénéfices/heures. 


-- 3) Quartiles de réduction de productivité
-- 1er quartile
SELECT
  q1 AS q1_reduc_prod
FROM (
  SELECT reduction_productivite_perc AS q1
  FROM EFFETS_SOMMEIL
  ORDER BY reduction_productivite_perc
  LIMIT 1
  OFFSET ((SELECT (COUNT(*)+1)/4 FROM EFFETS_SOMMEIL) - 1)
);
--comme auparavant,25% des entreprises ont eu plus de 12 euros de bénéfices!--

-- 3ème quartile
SELECT
  q3 AS q3_reduc_prod
FROM (
  SELECT reduction_productivite_perc AS q3
  FROM EFFETS_SOMMEIL
  ORDER BY reduction_productivite_perc
  LIMIT 1
  OFFSET ((SELECT (3*(COUNT(*)+1)/4) FROM EFFETS_SOMMEIL) - 1)
);
--comme avant, il y a 38 euros de réduction du 3eme quartile !--



-- 4) Moyenne, min et max d’impact PIB (mêmes principes)
SELECT
  ROUND(AVG(es.impact_PIB_par_habitant),2) AS moyenne_impact_PIB,
  MIN(es.impact_PIB_par_habitant)          AS min_impact_PIB,
  MAX(es.impact_PIB_par_habitant)          AS max_impact_PIB
FROM EFFETS_SOMMEIL es;



--2.Impact sur le PIB moyen --

-- 5) Par entreprise : calcul de la réduction moyenne, de l’impact PIB moyen,
--    et estimation de la perte de bénéfices par heure--
--cela permet par la suite d'identifier les min/max ...etc ! 
--cette partie permet d'évaluer plus l'impact macroéconomique --
--ainsi, cela sera plus le chiffre d'affaire gagné qui est calculé automatiquement par l'application--
--pour le calculer elle fait GAINSpersonne>7h-Gains/pertespersonnes<7h--
--évaluer grâce au temps effectif de travail ! et l' impact PIB/heure moyen --

--Pourquoi pas le bénéfice pour le PIB? Car le PIB est basée uniquement sur "la valeur ajoutée de l'entreprise"--
--ainsi est pris en compte la chaîne de production; et uniquement l'intervention de l'entreprise sur sa partie du Prix.absenteisme_avec_sport
--cela permet d'éviter de compter en double certains gains/pertes  

--ce calcul est automatique par l'application 2et3--
WITH stats_sommeil AS (
  SELECT
    em.id_entreprise,
    em.nom                           AS nom_entreprise,
    em.benefices_par_heure           AS benefices_par_heure,
    AVG(es.reduction_productivite_perc)    AS moyenne_reduc_prod,
    AVG(es.impact_PIB_par_habitant)        AS moyenne_impact_PIB
  FROM EMPLOYEUR em
  JOIN EMPLOYE    e  ON em.id_entreprise = e.id_entreprise
  JOIN SOMMEIL    so ON e.id_individu   = so.id_individu
  JOIN EFFETS_SOMMEIL es ON so.id_sommeil = es.id_sommeil
  GROUP BY
    em.id_entreprise,
    em.nom,
    em.benefices_par_heure
)
SELECT
  id_entreprise,
  nom_entreprise,
  ROUND(benefices_par_heure,2)                    AS benefices_par_heure,
  ROUND(moyenne_reduc_prod,2)                     AS moyenne_reduction_perc,
  ROUND(benefices_par_heure * (moyenne_reduc_prod/100),2)
    AS perte_benefices_par_heure,
  ROUND(moyenne_impact_PIB,2)                     AS impact_PIB_moyen
FROM stats_sommeil
ORDER BY perte_benefices_par_heure DESC;


-- 6a) Entreprise la plus pénalisée (perte de bénéfices/h la plus élevée)
WITH stats_sommeil AS (  -- même CTE que ci-dessus
  SELECT
    em.id_entreprise,
    em.nom                           AS nom_entreprise,
    em.benefices_par_heure           AS benefices_par_heure,
    AVG(es.reduction_productivite_perc)    AS moyenne_reduc_prod,
    AVG(es.impact_PIB_par_habitant)        AS moyenne_impact_PIB
  FROM EMPLOYEUR em
  JOIN EMPLOYE    e  ON em.id_entreprise = e.id_entreprise
  JOIN SOMMEIL    so ON e.id_individu   = so.id_individu
  JOIN EFFETS_SOMMEIL es ON so.id_sommeil = es.id_sommeil
  GROUP BY
    em.id_entreprise,
    em.nom,
    em.benefices_par_heure
)
SELECT
  id_entreprise,
  nom_entreprise,
  ROUND(benefices_par_heure * (moyenne_reduc_prod/100),2) AS perte_benefices_par_heure
FROM stats_sommeil
ORDER BY perte_benefices_par_heure DESC
LIMIT 1;


-- 6b) Entreprise la moins pénalisée (perte de bénéfices/h la plus faible)
WITH stats_sommeil AS (
  SELECT
    em.id_entreprise,
    em.nom                           AS nom_entreprise,
    em.benefices_par_heure           AS benefices_par_heure,
    AVG(es.reduction_productivite_perc)    AS moyenne_reduc_prod,
    AVG(es.impact_PIB_par_habitant)        AS moyenne_impact_PIB
  FROM EMPLOYEUR em
  JOIN EMPLOYE    e  ON em.id_entreprise = e.id_entreprise
  JOIN SOMMEIL    so ON e.id_individu   = so.id_individu
  JOIN EFFETS_SOMMEIL es ON so.id_sommeil = es.id_sommeil
  GROUP BY
    em.id_entreprise,
    em.nom,
    em.benefices_par_heure
)
SELECT
  id_entreprise,
  nom_entreprise,
  ROUND(benefices_par_heure * (moyenne_reduc_prod/100),2) AS perte_benefices_par_heure
FROM stats_sommeil
ORDER BY perte_benefices_par_heure ASC
LIMIT 1;

---3. Impact sur la CROISSANCE ECONOMIQUE PIB/Moyen --
-- 7a) Entreprise avec l’impact PIB moyen le plus élevé
WITH stats_sommeil AS (
  SELECT
    em.id_entreprise,
    em.nom                           AS nom_entreprise,
    AVG(es.impact_PIB_par_habitant)        AS moyenne_impact_PIB
  FROM EMPLOYEUR em
  JOIN EMPLOYE    e  ON em.id_entreprise = e.id_entreprise
  JOIN SOMMEIL    so ON e.id_individu   = so.id_individu
  JOIN EFFETS_SOMMEIL es ON so.id_sommeil = es.id_sommeil
  GROUP BY
    em.id_entreprise,
    em.nom
)
SELECT
  id_entreprise,
  nom_entreprise,
  ROUND(moyenne_impact_PIB,2) AS impact_PIB_moyen
FROM stats_sommeil
ORDER BY impact_PIB_moyen DESC
LIMIT 1;
--On voit qu'il s'agit de l'entreprise_35 qui a un gain de 786 dollars, au bénéfice donc de l'entreprise totale !--
--A noter:

-- 7b) Entreprise avec l’impact PIB moyen le plus faible
WITH stats_sommeil AS (
  SELECT
    em.id_entreprise,
    em.nom                           AS nom_entreprise,
    AVG(es.impact_PIB_par_habitant)        AS moyenne_impact_PIB
  FROM EMPLOYEUR em
  JOIN EMPLOYE    e  ON em.id_entreprise = e.id_entreprise
  JOIN SOMMEIL    so ON e.id_individu   = so.id_individu
  JOIN EFFETS_SOMMEIL es ON so.id_sommeil = es.id_sommeil
  GROUP BY
    em.id_entreprise,
    em.nom
)
SELECT
  id_entreprise,
  nom_entreprise,
  ROUND(moyenne_impact_PIB,2) AS impact_PIB_moyen
FROM stats_sommeil
ORDER BY impact_PIB_moyen ASC
LIMIT 1;


--4.Impacts sur le temps de travail (qui cause ces pertes et aide à créer l'indicateur)--
-- 
-- IMPACT DU SOMMEIL SUR LE TEMPS DE TRAVAIL
-- 

-- 1) Impact sur les heures effectives de travail par employé  : heures de travail « théoriques » vs heures effectives après réduction de productivité liée au sommeil
--heures de travail censée être effectuées-heure de travail effectives--
--les heures de travail effectives sont liées à une application de tracking, 
--qui permet de détecter les pertes de concentration --
--dans les faits seul le %de perte avait été mis, mais en inversant le calcul, on peut avoir les heures effectives

SELECT
  e.id_individu,
  e.nom,
  e.prenom,
  em.id_entreprise,
  em.nom                            AS nom_entreprise,
  em.heures                         AS heures_reference,               -- heures de travail « référence » (entreprise)
  ROUND(AVG(es.reduction_productivite_perc),2)   AS reduction_prod_perc,       -- réduction moyenne de productivité due au sommeil
  ROUND(em.heures * (1 - AVG(es.reduction_productivite_perc)/100),2) 
                                                 AS heures_effectives_moyennes -- heures effectives moyennes
FROM EMPLOYE e
JOIN SOMMEIL so    ON e.id_individu   = so.id_individu
JOIN EFFETS_SOMMEIL es ON so.id_sommeil = es.id_sommeil
JOIN EMPLOYEUR   em ON e.id_entreprise = em.id_entreprise
GROUP BY
  e.id_individu,
  e.nom,
  e.prenom,
  em.id_entreprise,
  em.nom,
  em.heures
ORDER BY reduction_prod_perc DESC;


-- 2) Impact agrégé par entreprise : perte d’heures cumulée
WITH per_emp AS (
  SELECT
    e.id_individu,
    em.id_entreprise,
    em.heures                         AS heures_reference,
    AVG(es.reduction_productivite_perc) AS red_prod_indiv_perc
  FROM EMPLOYE      e
  JOIN SOMMEIL     so ON e.id_individu   = so.id_individu
  JOIN EFFETS_SOMMEIL es ON so.id_sommeil = es.id_sommeil
  JOIN EMPLOYEUR   em ON e.id_entreprise = em.id_entreprise
  GROUP BY
    e.id_individu,
    em.id_entreprise,
    em.heures
)
SELECT
  em.id_entreprise,
  em.nom                              AS nom_entreprise,
  ROUND(AVG(pe.red_prod_indiv_perc),2) AS moyenne_reduc_prod_perc,       -- moyenne de la réduction de productivité
  COUNT(pe.id_individu)               AS nb_employes,
  ROUND(em.heures * AVG(pe.red_prod_indiv_perc)/100 * COUNT(pe.id_individu),2)
                                       AS perte_heures_cumulees          -- heures perdues totales
FROM per_emp pe
JOIN EMPLOYEUR em ON pe.id_entreprise = em.id_entreprise
GROUP BY
  em.id_entreprise,
  em.nom,
  em.heures
ORDER BY perte_heures_cumulees DESC;



-- 8. Efficacité du sport : gain_productivite par minute_activite
SELECT 
  s.id_individu,
  ROUND(
    SUM(f.gain_productivite)
    / NULLIF(SUM(s.minutes_activite),0),
    4
  ) AS efficacite_sport
FROM SPORT_SANTE s
JOIN EFFETS_SPORT f ON s.id_sport = f.id_sport
GROUP BY s.id_individu;




---Partie 3: troubles mentaux :--

-- 1) Statistiques globales sur les migraines
-- Moyenne, min, max, médiane, 1er et 3ème quartile de nb_migraines
WITH migraines_ord AS (
  SELECT
    nb_migraines,
    ROW_NUMBER() OVER (ORDER BY nb_migraines) AS rn,
    COUNT(*)       OVER ()                AS cnt
  FROM TROUBLE_MENTAL
)
SELECT
  ROUND(AVG(nb_migraines),2)                             AS moyenne_migraines,
  MIN(nb_migraines)                                      AS min_migraines,
  MAX(nb_migraines)                                      AS max_migraines,
  ROUND(AVG(CASE WHEN rn IN (CAST(cnt/2.0 AS INTEGER),
                              CAST(cnt/2.0 AS INTEGER)+1)
         THEN nb_migraines END),2)                      AS mediane_migraines,
  MIN(CASE WHEN rn = CAST((cnt+1)/4.0 AS INTEGER) THEN nb_migraines END)
                                                         AS q1_migraines,
  MIN(CASE WHEN rn = CAST(3*(cnt+1)/4.0 AS INTEGER) THEN nb_migraines END)
                                                         AS q3_migraines
FROM migraines_ord;


-- 2) Prévalence de la dépression
-- Pourcentage d’individus diagnostiqués dépressifs (depression=1)

SELECT
  ROUND(100.0 * SUM(depression) / COUNT(*),2) AS pct_depression
FROM TROUBLE_MENTAL;


-- 3) Moyenne de psychologues et jours de médication
-- Par statut de dépression
SELECT
  depression                              AS statut_depression,
  COUNT(*)                                AS nb_individus,
  ROUND(AVG(nb_psychologues),2)           AS moy_psychologues,
  ROUND(AVG(nb_jours_medication),2)       AS moy_jours_medication
FROM TROUBLE_MENTAL
GROUP BY depression
ORDER BY depression DESC;


-- 4) Impact du trouble mental sur absences et erreurs
-- Moyenne de jours_absence et nb_erreurs par individu
SELECT
  tm.id_individu,
  ROUND(AVG(et.jours_absence),2)         AS moy_jours_absence,
  ROUND(AVG(et.nb_erreurs),2)            AS moy_nb_erreurs
FROM TROUBLE_MENTAL tm
JOIN EFFETS_TROUBLE et ON tm.id_trouble = et.id_trouble
GROUP BY tm.id_individu
ORDER BY moy_jours_absence DESC;



-- 
-- 6) Productivité : base vs avec trouble
-- Moyennes et ratio global
-- 
SELECT
  ROUND(AVG(et.productivite_horaire_base),2)        AS moy_base,
  ROUND(AVG(et.productivite_horaire_avec_trouble),2)AS moy_avec_trouble,
  ROUND(AVG(et.productivite_horaire_base) /
        NULLIF(AVG(et.productivite_horaire_avec_trouble),0),4)
                                                    AS ratio_base_sur_trouble
FROM EFFETS_TROUBLE et;


-- 
-- 7) Quartiles de réduction de productivité (%) 
-- 
WITH red_ord AS (
  SELECT
    reduction_productivite_perc,
    ROW_NUMBER() OVER (ORDER BY reduction_productivite_perc) AS rn,
    COUNT(*)               OVER ()                      AS cnt
  FROM EFFETS_TROUBLE
)
SELECT
  MIN(CASE WHEN rn = CAST((cnt+1)/4.0 AS INTEGER) THEN reduction_productivite_perc END)
                                                     AS q1_reduc_prod,
  MIN(CASE WHEN rn = CAST(3*(cnt+1)/4.0 AS INTEGER) THEN reduction_productivite_perc END)
                                                     AS q3_reduc_prod
FROM red_ord;


-- 
-- 8) Impact PIB par diagnostic
-- Moyenne et total d’impact_PIB_par_habitant pour chaque diagnostic
-- 
SELECT
  tm.diagnostic,
  COUNT(*)                                 AS nb_individus,
  ROUND(AVG(et.impact_PIB_par_habitant),2) AS moy_impact_PIB,
  ROUND(SUM(et.impact_PIB_par_habitant),2) AS total_impact_PIB
FROM TROUBLE_MENTAL tm
JOIN EFFETS_TROUBLE et ON tm.id_trouble = et.id_trouble
GROUP BY tm.diagnostic
ORDER BY total_impact_PIB DESC;


-- 
-- 9) Statistiques par entreprise
-- Réduction moyenne, nb_migraines moyen, nb_jours_medication moyen
-- 
SELECT
  em.id_entreprise,
  em.nom                              AS nom_entreprise,
  ROUND(AVG(tm.nb_migraines),2)       AS moy_migraines,
  ROUND(AVG(tm.nb_psychologues),2)     AS moy_psychologues,
  ROUND(AVG(tm.nb_jours_medication),2) AS moy_jours_medication,
  ROUND(AVG(et.reduction_productivite_perc),2) AS moy_reduc_prod,
  ROUND(AVG(et.impact_PIB_par_habitant),2)     AS moy_impact_PIB
FROM EMPLOYEUR em
JOIN EMPLOYE     e  ON em.id_entreprise = e.id_entreprise
JOIN TROUBLE_MENTAL tm ON e.id_individu   = tm.id_individu
JOIN EFFETS_TROUBLE et ON tm.id_trouble    = et.id_trouble
GROUP BY em.id_entreprise, em.nom
ORDER BY moy_reduc_prod DESC;


-- 10) Entreprises les plus et moins impactées
-- Selon réduction de productivité et impact PIB

-- a) Entreprise la plus impactée en productivité
WITH per_ent AS (
  SELECT
    em.id_entreprise,
    ROUND(AVG(et.reduction_productivite_perc),2) AS moy_reduc_prod,
    ROUND(AVG(et.impact_PIB_par_habitant),2)     AS moy_impact_PIB
  FROM EMPLOYEUR em
  JOIN EMPLOYE      e  ON em.id_entreprise = e.id_entreprise
  JOIN TROUBLE_MENTAL tm ON e.id_individu   = tm.id_individu
  JOIN EFFETS_TROUBLE   et ON tm.id_trouble    = et.id_trouble
  GROUP BY em.id_entreprise
)
SELECT
  id_entreprise,
  moy_reduc_prod
FROM per_ent
ORDER BY moy_reduc_prod DESC
LIMIT 1;


-- b) Entreprise la moins impactée en productivité --
WITH per_ent AS (
  SELECT
    em.id_entreprise,
    ROUND(AVG(et.reduction_productivite_perc),2) AS moy_reduc_prod,
    ROUND(AVG(et.impact_PIB_par_habitant),2)     AS moy_impact_PIB
  FROM EMPLOYEUR em
  JOIN EMPLOYE      e  ON em.id_entreprise = e.id_entreprise
  JOIN TROUBLE_MENTAL tm ON e.id_individu   = tm.id_individu
  JOIN EFFETS_TROUBLE   et ON tm.id_trouble    = et.id_trouble
  GROUP BY em.id_entreprise
)
SELECT
  id_entreprise,
  moy_reduc_prod
FROM per_ent
ORDER BY moy_reduc_prod ASC
LIMIT 1;


-- c) Entreprise la plus impactée en PIB
WITH per_ent AS (
  SELECT
    em.id_entreprise,
    ROUND(AVG(et.reduction_productivite_perc),2) AS moy_reduc_prod,
    ROUND(AVG(et.impact_PIB_par_habitant),2)     AS moy_impact_PIB
  FROM EMPLOYEUR em
  JOIN EMPLOYE      e  ON em.id_entreprise = e.id_entreprise
  JOIN TROUBLE_MENTAL tm ON e.id_individu   = tm.id_individu
  JOIN EFFETS_TROUBLE   et ON tm.id_trouble    = et.id_trouble
  GROUP BY em.id_entreprise
)
SELECT
  id_entreprise,
  moy_impact_PIB
FROM per_ent
ORDER BY moy_impact_PIB DESC
LIMIT 1;


-- 7. Ratio productivité brut vs avec trouble mental par employé
SELECT
  tm.id_individu,
  AVG(et.productivite_horaire_base)        AS moy_base,
  AVG(et.productivite_horaire_avec_trouble) AS moy_avec_trouble,
  ROUND(
    AVG(et.productivite_horaire_base)
    / NULLIF(AVG(et.productivite_horaire_avec_trouble),0),
    4
  ) AS ratio_base_sur_trouble
FROM EFFETS_TROUBLE et
JOIN TROUBLE_MENTAL tm ON et.id_trouble = tm.id_trouble
GROUP BY tm.id_individu;


-- PARTIE 5 : ALIMENTATION
--Le but va être de regarder l'impact de l'alimentation sur l'économie. 

-- 1. Statistiques globales : impact_vitesse_execution
SELECT
  ROUND(AVG(impact_vitesse_execution),2) AS moy_vitesse_exec,
  MIN(impact_vitesse_execution)           AS min_vitesse_exec,
  MAX(impact_vitesse_execution)           AS max_vitesse_exec
FROM EFFETS_ALIMENTATION;

-- 2) Médiane de impact_vitesse_execution
SELECT AVG(x) AS mediane_vitesse_exec
FROM (
  SELECT impact_vitesse_execution AS x
  FROM EFFETS_ALIMENTATION
  ORDER BY x
  LIMIT 2 - ((SELECT COUNT(*) FROM EFFETS_ALIMENTATION) % 2)
  OFFSET (SELECT (COUNT(*)-1)/2 FROM EFFETS_ALIMENTATION)
);


-- 4) Statistiques globales : impact_absenteisme
SELECT
  ROUND(AVG(impact_absenteisme),2) AS moy_absenteisme,
  MIN(impact_absenteisme)           AS min_absenteisme,
  MAX(impact_absenteisme)           AS max_absenteisme
FROM EFFETS_ALIMENTATION;


-- 6) Statistiques globales : impact_erreurs
SELECT
  ROUND(AVG(impact_erreurs),2) AS moy_erreurs,
  MIN(impact_erreurs)           AS min_erreurs,
  MAX(impact_erreurs)           AS max_erreurs
FROM EFFETS_ALIMENTATION;


-- 8) Statistiques globales : perte_argent_heure
SELECT
  ROUND(AVG(perte_argent_heure),2) AS moy_perte_euro_h,
  MIN(perte_argent_heure)           AS min_perte_euro_h,
  MAX(perte_argent_heure)           AS max_perte_euro_h
FROM EFFETS_ALIMENTATION;

-- 9) Corrélation fatigue ↔ perte_argent_heureSELECT

SELECT
  ROUND(
    SUM((a.degre_fatigue - stats.avg_d) * (ea.perte_argent_heure - stats.avg_p)) /
    (
      (SELECT SUM((a2.degre_fatigue - stats.avg_d) * (a2.degre_fatigue - stats.avg_d)) FROM ALIMENTATION a2) *
      (SELECT SUM((ea2.perte_argent_heure - stats.avg_p) * (ea2.perte_argent_heure - stats.avg_p)) FROM EFFETS_ALIMENTATION ea2)
    ),
    4
  ) AS corr_fatigue_perte
FROM ALIMENTATION a
JOIN EFFETS_ALIMENTATION ea ON a.id_alim = ea.id_alim
CROSS JOIN (
  SELECT
    AVG(a2.degre_fatigue) AS avg_d,
    AVG(ea2.perte_argent_heure) AS avg_p
  FROM ALIMENTATION a2
  JOIN EFFETS_ALIMENTATION ea2 ON a2.id_alim = ea2.id_alim
) stats;

-- 10) Impact PIB moyen par type_repas
SELECT
  type_repas,
  ROUND(AVG(impact_PIB_par_habitant),2) AS moy_impact_PIB
FROM ALIMENTATION a
JOIN EFFETS_ALIMENTATION ea ON a.id_alim = ea.id_alim
GROUP BY type_repas;

-- 11) Top 3 types de repas par impact PIB
SELECT type_repas, moy_impact_PIB
FROM (
  SELECT
    type_repas,
    ROUND(AVG(impact_PIB_par_habitant),2) AS moy_impact_PIB
  FROM ALIMENTATION a
  JOIN EFFETS_ALIMENTATION ea ON a.id_alim = ea.id_alim
  GROUP BY type_repas
)
ORDER BY moy_impact_PIB DESC
LIMIT 3;

-- 12) Répartition d’impact_absenteisme par quartile de nb_fast_food
WITH base AS (
  SELECT
    a.nb_fast_food,
    ea.impact_absenteisme,
    NTILE(4) OVER (ORDER BY a.nb_fast_food) AS quartile
  FROM ALIMENTATION a
  JOIN EFFETS_ALIMENTATION ea ON a.id_alim = ea.id_alim
)
SELECT
  quartile,
  ROUND(AVG(impact_absenteisme),2) AS moy_absenteisme
FROM base
GROUP BY quartile
ORDER BY quartile;

-- 13) Pourcentage d’individus ayant impact_erreurs>median
WITH med AS (
  SELECT AVG(x) AS m FROM (
    SELECT impact_erreurs AS x
    FROM EFFETS_ALIMENTATION
    ORDER BY x
    LIMIT 2 - ((SELECT COUNT(*) FROM EFFETS_ALIMENTATION)%2)
    OFFSET (SELECT (COUNT(*)-1)/2 FROM EFFETS_ALIMENTATION)
  )
)
SELECT
  ROUND(100.0*SUM(CASE WHEN ea.impact_erreurs>m THEN 1 END)/COUNT(*),2)
    AS pct_erreurs_sup_med
FROM EFFETS_ALIMENTATION ea
CROSS JOIN med;

-- 14) Impact PIB total par niveau de fatigue
SELECT
  a.degre_fatigue,
  ROUND(SUM(ea.impact_PIB_par_habitant),2) AS total_impact_PIB
FROM ALIMENTATION a
JOIN EFFETS_ALIMENTATION ea ON a.id_alim = ea.id_alim
GROUP BY a.degre_fatigue
ORDER BY a.degre_fatigue;

-- 15) Entreprise : impact PIB moyen lié à l’alimentation
SELECT
  em.id_entreprise,
  em.nom                           AS nom_entreprise,
  ROUND(AVG(ea.impact_PIB_par_habitant),2) AS moy_impact_PIB_alim
FROM EMPLOYEUR em
JOIN EMPLOYE    e   ON em.id_entreprise = e.id_entreprise
JOIN ALIMENTATION a   ON e.id_individu   = a.id_individu
JOIN EFFETS_ALIMENTATION ea ON a.id_alim = ea.id_alim
GROUP BY em.id_entreprise, em.nom;



-- PARTIE 6 : RISQUES

-- 1) Statistiques globales : perte_economique
SELECT
  ROUND(AVG(perte_economique),2) AS moy_perte_economique,
  MIN(perte_economique)           AS min_perte_economique,
  MAX(perte_economique)           AS max_perte_economique
FROM EFFETS_RISQUE;

-- 2) Médiane de perte_economique
SELECT AVG(x) AS mediane_perte_economique
FROM (
  SELECT perte_economique AS x
  FROM EFFETS_RISQUE
  ORDER BY x
  LIMIT 2 - ((SELECT COUNT(*) FROM EFFETS_RISQUE) % 2)
  OFFSET (SELECT (COUNT(*)-1)/2 FROM EFFETS_RISQUE)
);

3.Corrélation risque et temps horaire moyen ! 
SELECT
  ROUND(
    SUM((r.ceinture_pourcentage - stats.avg_c) * (er.temps_horaire_moyenne - stats.avg_t)) /
    (
      (SELECT SUM((r2.ceinture_pourcentage - stats.avg_c) * (r2.ceinture_pourcentage - stats.avg_c)) FROM RISQUE r2) *
      (SELECT SUM((er2.temps_horaire_moyenne - stats.avg_t) * (er2.temps_horaire_moyenne - stats.avg_t)) FROM EFFETS_RISQUE er2)
    ),
    4
  ) AS corr_ceinture_temps
FROM RISQUE r
JOIN EFFETS_RISQUE er ON r.id_risque = er.id_risque
CROSS JOIN (
  SELECT
    AVG(r2.ceinture_pourcentage) AS avg_c,
    AVG(er2.temps_horaire_moyenne) AS avg_t
  FROM RISQUE r2
  JOIN EFFETS_RISQUE er2 ON r2.id_risque = er2.id_risque
) stats;


-- 5) Statistiques globales : taches_par_heure
SELECT
  ROUND(AVG(taches_par_heure),2) AS moy_taches_heure,
  MIN(taches_par_heure)           AS min_taches_heure,
  MAX(taches_par_heure)           AS max_taches_heure
FROM EFFETS_RISQUE;

-- 6) Moyenne taches_par_heure par comportement_sante
--variable dédiée contrairement à d'autres tables --
--il est rempli avec le manager et s'appuie aussi sur le nombre de pauses de l'employé...-
SELECT
  r.comportement_sante,
  ROUND(AVG(er.taches_par_heure),2) AS moy_taches_par_heure
FROM RISQUE r
JOIN EFFETS_RISQUE er ON r.id_risque = er.id_risque
GROUP BY r.comportement_sante;

-- 7) Impact PIB moyen par comportement_sante
SELECT
  r.comportement_sante,
  ROUND(AVG(er.impact_PIB_par_habitant),2) AS moy_impact_PIB
FROM RISQUE r
JOIN EFFETS_RISQUE er ON r.id_risque = er.id_risque
GROUP BY r.comportement_sante;

-- 8) Répartition nb_erreurs par quartile de nb_pauses
WITH base AS (
  SELECT
    r.nb_pauses,
    er.nb_erreurs,
    NTILE(4) OVER (ORDER BY r.nb_pauses) AS quartile
  FROM RISQUE r
  JOIN EFFETS_RISQUE er ON r.id_risque = er.id_risque
)
SELECT
  quartile,
  ROUND(AVG(nb_erreurs),2) AS moy_erreurs
FROM base
GROUP BY quartile
ORDER BY quartile;

-- 9) % d’employés avec infractions_vitesse > 0
SELECT
  ROUND(100.0*SUM(CASE WHEN infractions_vitesse>0 THEN 1 END)/COUNT(*),2)
    AS pct_infractions
FROM RISQUE;

-- 10) Quartiles de representativite_echelle
WITH rep AS (
  SELECT
    er.representativite_echelle,
    ROW_NUMBER() OVER (ORDER BY er.representativite_echelle) AS rn,
    COUNT(*)              OVER ()                      AS cnt
  FROM EFFETS_RISQUE er
)
SELECT
  MIN(CASE WHEN rn = CAST((cnt+1)/4.0 AS INTEGER) THEN representativite_echelle END)
    AS q1_rep,
  MIN(CASE WHEN rn = CAST(3*(cnt+1)/4.0 AS INTEGER) THEN representativite_echelle END)
    AS q3_rep
FROM rep;


-- 12) Temps horaire moyen vs impact PIB (corrélation)
SELECT
  ROUND(CORR(er.temps_horaire_moyenne, er.impact_PIB_par_habitant),4)
    AS corr_temps_PIB
FROM EFFETS_RISQUE er;

-- 13) Entreprise : impact PIB moyen lié aux risques
SELECT
  em.id_entreprise,
  em.nom                           AS nom_entreprise,
  ROUND(AVG(er.impact_PIB_par_habitant),2) AS moy_impact_PIB_risque
FROM EMPLOYEUR em
JOIN EMPLOYE    e   ON em.id_entreprise = e.id_entreprise
JOIN RISQUE     r   ON e.id_individu   = r.id_individu
JOIN EFFETS_RISQUE er ON r.id_risque   = er.id_risque
GROUP BY em.id_entreprise, em.nom;

-- 14) Entreprise la plus impactée PIB (risques)
SELECT id_entreprise, moy_impact_PIB_risque
FROM (
  SELECT
    em.id_entreprise,
    ROUND(AVG(er.impact_PIB_par_habitant),2) AS moy_impact_PIB_risque
  FROM EMPLOYEUR em
  JOIN EMPLOYE    e   ON em.id_entreprise = e.id_entreprise
  JOIN RISQUE     r   ON e.id_individu   = r.id_individu
  JOIN EFFETS_RISQUE er ON r.id_risque   = er.id_risque
  GROUP BY em.id_entreprise
)
ORDER BY moy_impact_PIB_risque DESC
LIMIT 1;

-- 15) Entreprise la moins impactée PIB (risques)
SELECT id_entreprise, moy_impact_PIB_risque
FROM (
  SELECT
    em.id_entreprise,
    ROUND(AVG(er.impact_PIB_par_habitant),2) AS moy_impact_PIB_risque
  FROM EMPLOYEUR em
  JOIN EMPLOYE    e   ON em.id_entreprise = e.id_entreprise
  JOIN RISQUE     r   ON e.id_individu   = r.id_individu
  JOIN EFFETS_RISQUE er ON r.id_risque   = er.id_risque
  GROUP BY em.id_entreprise
)
ORDER BY moy_impact_PIB_risque ASC
LIMIT 1;


-- 12. Temps moyen de travail horaire enregistré (RISQUE)
SELECT 
  r.id_individu,
  AVG(er.temps_horaire_moyenne) AS moyenne_temps_horaire
FROM RISQUE r
JOIN EFFETS_RISQUE er ON r.id_risque = er.id_risque
GROUP BY r.id_individu;

-- 13. Médiane du temps de travail horaire
SELECT 
  id_individu,
  AVG(temps_horaire_moyenne) AS mediane_temps_horaire
FROM (
  SELECT 
    r.id_individu,
    er.temps_horaire_moyenne,
    ROW_NUMBER() OVER (
      PARTITION BY r.id_individu 
      ORDER BY er.temps_horaire_moyenne
    ) AS rn,
    COUNT(*) OVER (PARTITION BY r.id_individu) AS cnt
  FROM RISQUE r
  JOIN EFFETS_RISQUE er ON r.id_risque = er.id_risque
)
WHERE rn IN ((cnt+1)/2, (cnt+2)/2)
GROUP BY id_individu;

-- 14. Fréquence moyenne de consommation de drogues
SELECT 
  t.id_individu, 
  AVG(t.freq_drogues_jour) AS moyenne_freq_drogues
FROM TABAC t
GROUP BY t.id_individu;

-- 15. Médiane de fréquence de consommation de drogues
SELECT 
  id_individu,
  AVG(freq_drogues_jour) AS mediane_freq_drogues
FROM (
  SELECT 
    id_individu,
    freq_drogues_jour,
    ROW_NUMBER() OVER (
      PARTITION BY id_individu 
      ORDER BY freq_drogues_jour
    ) AS rn,
    COUNT(*) OVER (PARTITION BY id_individu) AS cnt
  FROM TABAC
)
WHERE rn IN ((cnt+1)/2, (cnt+2)/2)
GROUP BY id_individu;

---Partie 7 : applications temporelles --
-- 23. Nombre moyen d’applications d’effet par employé
SELECT 
  AVG(nb_apps) AS moyenne_apps_effect
FROM (
  SELECT COUNT(*) AS nb_apps
  FROM APPLICATION_EFFECT
  GROUP BY id_individu
);

-- 24. Répartition d’applications cause vs effet
SELECT 
  'cause'  AS type_app, COUNT(*) AS compte
FROM APPLICATION_CAUSE
UNION ALL
SELECT 
  'effect', COUNT(*) 
FROM APPLICATION_EFFECT;

-- 26. Top 5 des entreprises par minutes debout moyennes
SELECT 
  s.id_entreprise,
  AVG(s.minutes_debout) AS moyenne_debout
FROM SPORT_SANTE s
GROUP BY s.id_entreprise
ORDER BY moyenne_debout DESC
LIMIT 5;

-- 27. Médiane de jours de sport par entreprise
SELECT 
  id_entreprise,
  AVG(nb_jours_par_semaine) AS mediane_jours_sport
FROM (
  SELECT 
    s.id_entreprise,
    s.nb_jours_par_semaine,
    ROW_NUMBER() OVER (
      PARTITION BY s.id_entreprise 
      ORDER BY s.nb_jours_par_semaine
    ) AS rn,
    COUNT(*) OVER (PARTITION BY s.id_entreprise) AS cnt
  FROM SPORT_SANTE s
)
WHERE rn IN ((cnt+1)/2, (cnt+2)/2)
GROUP BY id_entreprise;

-- 28. Évolution mensuelle des heures de sommeil
SELECT 
  SUBSTR(ac.date_heure,1,7) AS mois,
  AVG(so.heures_moyennes)     AS moyenne_sommeil
FROM SOMMEIL so
JOIN APPLICATION_CAUSE ac 
  ON so.id_application_cause = ac.id_application_cause
GROUP BY mois
ORDER BY mois;

-- 29. Revenu moyen des employés fumeurs vs non-fumeurs
SELECT 
  t.consomme_tabac,
  AVG(e.salaire) AS salaire_moyen
FROM TABAC t
JOIN EMPLOYE e 
  ON t.id_individu = e.id_individu
GROUP BY t.consomme_tabac;

-- 30. Impact PIB trimestriel global
SELECT 
  SUBSTR(ae.date_heure,1,4) 
    || '-T' 
    || ((CAST(SUBSTR(ae.date_heure,6,2) AS INTEGER)-1)/3+1)
    AS trimestre,
  SUM(f.impact_PIB_par_habitant) AS total_impact
FROM APPLICATION_EFFECT ae
JOIN EFFETS_SPORT f 
  ON ae.id_application_effect = f.id_application_effect
GROUP BY trimestre
ORDER BY trimestre;


--Partie 8: corrélations --
.load ./stat
.load ./stat
--1.Corrélation ceintures pourcentages et temps horaire moyen--
--elle est au carré, il suffit alors de déterminer le r =corrélation par la racine!--

WITH
  pairs AS (
    SELECT
      r.ceinture_pourcentage AS x,
      er.temps_horaire_moyenne AS y
    FROM RISQUE r
    JOIN EFFETS_RISQUE er ON r.id_risque = er.id_risque
  ),
  stats AS (
    SELECT
      COUNT(*) AS n,
      AVG(x)   AS mean_x,
      AVG(y)   AS mean_y
    FROM pairs
  ),
  cov_var AS (
    SELECT
      SUM((x-mean_x)*(y-mean_y)) AS cov_xy,
      SUM((x-mean_x)*(x-mean_x)) AS var_x,
      SUM((y-mean_y)*(y-mean_y)) AS var_y
    FROM pairs
    CROSS JOIN stats
  )
SELECT
  ROUND((cov_xy*cov_xy) / NULLIF(var_x * var_y,0), 4) AS r_carre
FROM cov_var;
-- 1) r² : minutes d’activité physique vs gain_productivite
WITH
  pairs AS (
    SELECT s.minutes_activite AS x, f.gain_productivite AS y
    FROM SPORT_SANTE s
    JOIN EFFETS_SPORT f ON s.id_sport = f.id_sport
  ),
  stats AS (
    SELECT COUNT(*) AS n, AVG(x) AS mean_x, AVG(y) AS mean_y FROM pairs
  ),
  cov_var AS (
    SELECT
      SUM((x-mean_x)*(y-mean_y)) AS cov_xy,
      SUM((x-mean_x)*(x-mean_x)) AS var_x,
      SUM((y-mean_y)*(y-mean_y)) AS var_y
    FROM pairs CROSS JOIN stats
  )
SELECT ROUND((cov_xy*cov_xy)/(NULLIF(var_x*var_y,0)),4) AS r2_minutes_gain
FROM cov_var;


-- 2) r² : nb_jours_par_semaine vs gain_productivite
WITH
  pairs AS (
    SELECT s.nb_jours_par_semaine AS x, f.gain_productivite AS y
    FROM SPORT_SANTE s
    JOIN EFFETS_SPORT f ON s.id_sport = f.id_sport
  ),
  stats AS (SELECT COUNT(*) AS n, AVG(x) AS mean_x, AVG(y) AS mean_y FROM pairs),
  cov_var AS (
    SELECT
      SUM((x-mean_x)*(y-mean_y)) AS cov_xy,
      SUM((x-mean_x)*(x-mean_x)) AS var_x,
      SUM((y-mean_y)*(y-mean_y)) AS var_y
    FROM pairs CROSS JOIN stats
  )
SELECT ROUND((cov_xy*cov_xy)/(NULLIF(var_x*var_y,0)),4) AS r2_jours_gain
FROM cov_var;


-- 3) r² : nb_verres_moyen vs impact_PIB_par_habitant (alcool)
WITH
  pairs AS (
    SELECT a.nb_verres_moyen AS x, ea.impact_PIB_par_habitant AS y
    FROM ALCOOL a
    JOIN EFFETS_ALCOOL ea ON a.id_alcool = ea.id_alcool
  ),
  stats AS (SELECT COUNT(*) AS n, AVG(x) AS mean_x, AVG(y) AS mean_y FROM pairs),
  cov_var AS (
    SELECT
      SUM((x-mean_x)*(y-mean_y)) AS cov_xy,
      SUM((x-mean_x)*(x-mean_x)) AS var_x,
      SUM((y-mean_y)*(y-mean_y)) AS var_y
    FROM pairs CROSS JOIN stats
  )
SELECT ROUND((cov_xy*cov_xy)/(NULLIF(var_x*var_y,0)),4) AS r2_verres_PIB
FROM cov_var;


-- 4) r² : freq_par_semaine vs impact_PIB_par_habitant
WITH
  pairs AS (
    SELECT a.freq_par_semaine AS x, ea.impact_PIB_par_habitant AS y
    FROM ALCOOL a
    JOIN EFFETS_ALCOOL ea ON a.id_alcool = ea.id_alcool
  ),
  stats AS (SELECT COUNT(*) AS n, AVG(x) AS mean_x, AVG(y) AS mean_y FROM pairs),
  cov_var AS (
    SELECT
      SUM((x-mean_x)*(y-mean_y)) AS cov_xy,
      SUM((x-mean_x)*(x-mean_x)) AS var_x,
      SUM((y-mean_y)*(y-mean_y)) AS var_y
    FROM pairs CROSS JOIN stats
  )
SELECT ROUND((cov_xy*cov_xy)/(NULLIF(var_x*var_y,0)),4) AS r2_freq_PIB
FROM cov_var;


-- 5) r² : nb_portions_fruits vs impact_PIB_par_habitant (alimentation)
WITH
  pairs AS (
    SELECT a.nb_portions_fruits AS x, ea.impact_PIB_par_habitant AS y
    FROM ALIMENTATION a
    JOIN EFFETS_ALIMENTATION ea ON a.id_alim = ea.id_alim
  ),
  stats AS (SELECT COUNT(*) AS n, AVG(x) AS mean_x, AVG(y) AS mean_y FROM pairs),
  cov_var AS (
    SELECT
      SUM((x-mean_x)*(y-mean_y)) AS cov_xy,
      SUM((x-mean_x)*(x-mean_x)) AS var_x,
      SUM((y-mean_y)*(y-mean_y)) AS var_y
    FROM pairs CROSS JOIN stats
  )
SELECT ROUND((cov_xy*cov_xy)/(NULLIF(var_x*var_y,0)),4) AS r2_fruits_PIB
FROM cov_var;


-- 6) r² : litres_eau vs impact_PIB_par_habitant
WITH
  pairs AS (
    SELECT a.litres_eau AS x, ea.impact_PIB_par_habitant AS y
    FROM ALIMENTATION a
    JOIN EFFETS_ALIMENTATION ea ON a.id_alim = ea.id_alim
  ),
  stats AS (SELECT COUNT(*) AS n, AVG(x) AS mean_x, AVG(y) AS mean_y FROM pairs),
  cov_var AS (
    SELECT
      SUM((x-mean_x)*(y-mean_y)) AS cov_xy,
      SUM((x-mean_x)*(x-mean_x)) AS var_x,
      SUM((y-mean_y)*(y-mean_y)) AS var_y
    FROM pairs CROSS JOIN stats
  )
SELECT ROUND((cov_xy*cov_xy)/(NULLIF(var_x*var_y,0)),4) AS r2_eau_PIB
FROM cov_var;


-- 7) r² : heures_moyennes vs impact_PIB_par_habitant (sommeil)
WITH
  pairs AS (
    SELECT so.heures_moyennes AS x, es.impact_PIB_par_habitant AS y
    FROM SOMMEIL so
    JOIN EFFETS_SOMMEIL es ON so.id_sommeil = es.id_sommeil
  ),
  stats AS (SELECT COUNT(*) AS n, AVG(x) AS mean_x, AVG(y) AS mean_y FROM pairs),
  cov_var AS (
    SELECT
      SUM((x-mean_x)*(y-mean_y)) AS cov_xy,
      SUM((x-mean_x)*(x-mean_x)) AS var_x,
      SUM((y-mean_y)*(y-mean_y)) AS var_y
    FROM pairs CROSS JOIN stats
  )
SELECT ROUND((cov_xy*cov_xy)/(NULLIF(var_x*var_y,0)),4) AS r2_sleephours_PIB
FROM cov_var;


-- 8) r² : reduction_productivite_perc vs impact_PIB_par_habitant (sommeil)
WITH
  pairs AS (
    SELECT so.id_sommeil, es.reduction_productivite_perc AS x, es.impact_PIB_par_habitant AS y
    FROM SOMMEIL so
    JOIN EFFETS_SOMMEIL es ON so.id_sommeil = es.id_sommeil
  ),
  stats AS (SELECT COUNT(*) AS n, AVG(x) AS mean_x, AVG(y) AS mean_y FROM pairs),
  cov_var AS (
    SELECT
      SUM((x-mean_x)*(y-mean_y)) AS cov_xy,
      SUM((x-mean_x)*(x-mean_x)) AS var_x,
      SUM((y-mean_y)*(y-mean_y)) AS var_y
    FROM pairs CROSS JOIN stats
  )
SELECT ROUND((cov_xy*cov_xy)/(NULLIF(var_x*var_y,0)),4) AS r2_reduc_PIB
FROM cov_var;


-- 9) r² : nb_pauses vs perte_economique (risques)
WITH
  pairs AS (
    SELECT r.nb_pauses AS x, er.perte_economique AS y
    FROM RISQUE r
    JOIN EFFETS_RISQUE er ON r.id_risque = er.id_risque
  ),
  stats AS (SELECT COUNT(*) AS n, AVG(x) AS mean_x, AVG(y) AS mean_y FROM pairs),
  cov_var AS (
    SELECT
      SUM((x-mean_x)*(y-mean_y)) AS cov_xy,
      SUM((x-mean_x)*(x-mean_x)) AS var_x,
      SUM((y-mean_y)*(y-mean_y)) AS var_y
    FROM pairs CROSS JOIN stats
  )
SELECT ROUND((cov_xy*cov_xy)/(NULLIF(var_x*var_y,0)),4) AS r2_pauses_perte
FROM cov_var;


-- 10) r² : representativite_echelle vs impact_PIB_par_habitant (risques)
WITH
  pairs AS (
    SELECT er.representativite_echelle AS x, er.impact_PIB_par_habitant AS y
    FROM EFFETS_RISQUE er
  ),
  stats AS (SELECT COUNT(*) AS n, AVG(x) AS mean_x, AVG(y) AS mean_y FROM pairs),
  cov_var AS (
    SELECT
      SUM((x-mean_x)*(y-mean_y)) AS cov_xy,
      SUM((x-mean_x)*(x-mean_x)) AS var_x,
      SUM((y-mean_y)*(y-mean_y)) AS var_y
    FROM pairs CROSS JOIN stats
  )
SELECT ROUND((cov_xy*cov_xy)/(NULLIF(var_x*var_y,0)),4) AS r2_repr_PIB
FROM cov_var;





--Partie 8 : requêtes finale --

-- 
-- 1) Calcul manuel de r² entre sport et productivité
--    Objectif : quantifier la relation santé ↔ productivité
--    Note : SQLite ne propose pas CORR() sans extension externe ‘stat’; 
--           ici on calcule manuellement covariance & variances via CTE.
-- 
WITH
  pairs AS (
    SELECT
      s.minutes_activite AS x,     -- variable d’intérêt X (sport)
      f.gain_productivite AS y      -- variable d’intérêt Y (productivité)
    FROM SPORT_SANTE s
    JOIN EFFETS_SPORT f ON s.id_sport = f.id_sport
  ),
  stats AS (
    SELECT AVG(x) AS mean_x, AVG(y) AS mean_y FROM pairs
  ),
  covvar AS (
    SELECT
      SUM((x-mean_x)*(y-mean_y)) AS cov_xy,  -- covariance * n
      SUM((x-mean_x)*(x-mean_x)) AS var_x,   -- variance X * n
      SUM((y-mean_y)*(y-mean_y)) AS var_y    -- variance Y * n
    FROM pairs CROSS JOIN stats
  )
SELECT
  ROUND((cov_xy*cov_xy)/(NULLIF(var_x*var_y,0)),4) AS r2_sport_productivite
FROM covvar;


-- 
-- 2) Anomalies sommeil & alcool
--    Objectif : repérer les individus “mauvais élèves” santé
--    Technique : agrégation conditionnelle + HAVING
--    Pourquoi LEFT JOIN n’est pas utilisé ici : on veut uniquement ceux qui ont
--    à la fois des enregistrements sommeil ET alcool, d’où des JOIN simples.
-- 
SELECT
  e.nom,
  e.prenom,
  SUM(CASE WHEN so.qualite_echelle <= 2 THEN 1 ELSE 0 END)   AS mauvais_sommeil,
  SUM(CASE WHEN a.nb_verres_moyen  > 4 THEN 1 ELSE 0 END)   AS forte_alcoolisation
FROM EMPLOYE e
JOIN SOMMEIL so ON e.id_individu = so.id_individu
JOIN ALCOOL  a ON e.id_individu = a.id_individu
GROUP BY e.id_individu
HAVING mauvais_sommeil + forte_alcoolisation > 2;


-- 
-- 3) Évolution mensuelle de l’impact PIB
--    Objectif : suivre macro tendance économique
--    Technique : CTE récursive pour générer la série de mois
--    Pourquoi récursivité ici : génère dynamiquement chaque mois
--    sans table calendrier dédiée.
-- Créer un WITH ici en utilisant la variable date permet de pouvoir réutiliser efficacement
--par la suite cette aide temporaire ! permet donc de réaliser la requête finale ! 
WITH RECURSIVE months(dt) AS (
  SELECT DATE('2024-01-01')
  UNION ALL
  SELECT DATE(dt, '+1 month') FROM months WHERE dt < DATE('now','start of month')
)
SELECT
  strftime('%Y-%m', dt)                        AS mois,
  COALESCE(SUM(er.impact_PIB_par_habitant),0)  AS total_impact_PIB
FROM months
LEFT JOIN APPLICATION_EFFECT ae
  ON strftime('%Y-%m', ae.date_heure) = strftime('%Y-%m', months.dt)
LEFT JOIN EFFETS_SPORT er
  ON ae.id_application_effect = er.id_application_effect
GROUP BY mois
ORDER BY mois;


-- 
-- 4) Evaluer l'impact sur le pib causé par le Tabac vs l'impact du PIB causé par l' alcool  par entreprise
--    Objectif : comparer deux domaines de risque
--    Technique : LEFT JOIN pour inclure entreprises
--                même sans consommation d’un type
--    Pourquoi CASE WHEN : isoler et sommer seulement les contributions 
--                        pertinentes à chaque risque.
-- 
SELECT
  em.nom                                                     AS entreprise,
  SUM(CASE WHEN a.consomme = 1 THEN ea.impact_PIB_par_habitant ELSE 0 END) AS PIB_alcool,
  SUM(CASE WHEN t.consomme_tabac = 1 THEN et.impact_PIB_par_habitant ELSE 0 END) AS PIB_tabac
FROM EMPLOYEUR em
LEFT JOIN EMPLOYE e ON em.id_entreprise = e.id_entreprise
LEFT JOIN ALCOOL a ON e.id_individu = a.id_individu
LEFT JOIN EFFETS_ALCOOL ea ON a.id_alcool = ea.id_alcool
LEFT JOIN TABAC t ON e.id_individu = t.id_individu
LEFT JOIN EFFETS_TABAC et ON t.id_tabac = et.id_tabac
GROUP BY em.id_entreprise;


-- 
-- 5) Profil JSON (NoSQL) : tags & préférences
--    Objectif : stocker attributs flexibles sans changer le schéma
--    Technique : JSON1 (json_extract, json_each)
-- 
CREATE TABLE IF NOT EXISTS profiles(id INTEGER PRIMARY KEY, info JSON);
INSERT INTO profiles(info) VALUES
  ('{"id":42,"tags":["sportif","manager"],"prefs":{"email":true,"sms":false}}');

-- Extraire un tag
SELECT json_extract(info,'$.tags[0]') AS premier_tag FROM profiles WHERE id=1;

-- Filtrer sur une préférence
SELECT * FROM profiles WHERE json_extract(info,'$.prefs.email') = 1;

-- Parcourir tous les tags
SELECT value AS tag FROM profiles, json_each(info,'$.tags');



-- 6) Indicateur global de “mauvais élève” et impact sur productivité
--    Objectif : synthétiser un score santé → productivité sur TOUTES les tables
--    Technique : agrégation multi-tables + CASE WHEN pour score
-- 
WITH
  sport_score AS (
    SELECT id_individu,
           SUM(minutes_activite) AS total_minutes
    FROM SPORT_SANTE GROUP BY id_individu
  ),
  prod_score AS (
    SELECT tm.id_individu,
           AVG(et.productivite_horaire_avec_trouble - et.productivite_horaire_base) AS delta_prod
    FROM TROUBLE_MENTAL tm
    JOIN EFFETS_TROUBLE et ON tm.id_trouble = et.id_trouble
    GROUP BY tm.id_individu
  ),
  alcool_score AS (
    SELECT id_individu,
           AVG(ea.nb_remarques_travail) AS avg_remarques
    FROM ALCOOL a
    JOIN EFFETS_ALCOOL ea ON a.id_alcool = ea.id_alcool
    GROUP BY id_individu
  ),
  sommeil_score AS (
    SELECT id_individu,
           AVG(es.jours_absence_fatigue) AS avg_abs_fatigue
    FROM SOMMEIL so
    JOIN EFFETS_SOMMEIL es ON so.id_sommeil = es.id_sommeil
    GROUP BY id_individu
  )
SELECT
  e.nom, e.prenom,
  -- score “mauvais élève” : faible sport, forte perte prod, beaucoup de remarques & d’absence
  CASE 
    WHEN ss.total_minutes < 100 
      OR ps.delta_prod > 0 
      OR alc.avg_remarques > 5 
      OR som.avg_abs_fatigue > 2
    THEN 'Mauvais élève'
    ELSE 'OK'
  END AS statut,
  ROUND(ps.delta_prod,2)    AS impact_prod_horaire,
  ROUND(alc.avg_remarques,2) AS impact_remarques,
  ROUND(som.avg_abs_fatigue,2) AS impact_abs_fatigue
FROM EMPLOYE e
LEFT JOIN sport_score ss ON e.id_individu = ss.id_individu
LEFT JOIN prod_score ps ON e.id_individu = ps.id_individu
LEFT JOIN alcool_score alc ON e.id_individu = alc.id_individu
LEFT JOIN sommeil_score som ON e.id_individu = som.id_individu
ORDER BY statut DESC, impact_prod_horaire DESC;


-- Objectif 2:Calculer la proportion moyenne de “mauvais élèves”
-- Objectif : obtenir le % d’individus classés “Mauvais élève”
-- Technique : on réutilise la CTE précédente, on attribue un flag 1/0,
--             puis on calcule la moyenne de ce flag.
WITH
  sport_score AS (
    SELECT id_individu,
           SUM(minutes_activite) AS total_minutes
    FROM SPORT_SANTE
    GROUP BY id_individu
  ),
  prod_score AS (
    SELECT tm.id_individu,
           AVG(et.productivite_horaire_avec_trouble - et.productivite_horaire_base) AS delta_prod
    FROM TROUBLE_MENTAL tm
    JOIN EFFETS_TROUBLE et ON tm.id_trouble = et.id_trouble
    GROUP BY tm.id_individu
  ),
  alcool_score AS (
    SELECT id_individu,
           AVG(ea.nb_remarques_travail) AS avg_remarques
    FROM ALCOOL a
    JOIN EFFETS_ALCOOL ea ON a.id_alcool = ea.id_alcool
    GROUP BY id_individu
  ),
  sommeil_score AS (
    SELECT id_individu,
           AVG(es.jours_absence_fatigue) AS avg_abs_fatigue
    FROM SOMMEIL so
    JOIN EFFETS_SOMMEIL es ON so.id_sommeil = es.id_sommeil
    GROUP BY id_individu
  ),
  flags AS (
    SELECT
      e.id_individu,
      CASE 
        WHEN COALESCE(ss.total_minutes,0) < 100
          OR COALESCE(ps.delta_prod,0) > 0
          OR COALESCE(alc.avg_remarques,0) > 5
          OR COALESCE(som.avg_abs_fatigue,0) > 2
        THEN 1
        ELSE 0
      END AS mauvais_flag
    FROM EMPLOYE e
    LEFT JOIN sport_score ss ON e.id_individu = ss.id_individu
    LEFT JOIN prod_score ps ON e.id_individu = ps.id_individu
    LEFT JOIN alcool_score alc ON e.id_individu = alc.id_individu
    LEFT JOIN sommeil_score som ON e.id_individu = som.id_individu
  )
SELECT
  ROUND(AVG(mauvais_flag)*100,2) AS pct_mauvais_eleves
FROM flags;

--Partie 9 : autres (améliorations)

--1.Applications : fréquentation des applications par entreprises --
--But : repérer les entreprises qui ne collaborent pas suffisamment pour l'expérience--

WITH base AS (
  SELECT
    em.id_entreprise,
    date(a.date_heure) AS jour,
    CASE WHEN a.id_application_cause IS NOT NULL THEN 'cause' ELSE 'effect' END AS type_app
  FROM EMPLOYEUR em
  JOIN EMPLOYE e ON em.id_entreprise=e.id_entreprise
  LEFT JOIN APPLICATION_CAUSE a ON e.id_individu=a.id_individu
  LEFT JOIN APPLICATION_EFFECT b ON e.id_individu=b.id_individu
)
SELECT
  id_entreprise,
  jour,
  COUNT(CASE WHEN type_app='cause' THEN 1 END) OVER w AS cause_cumul,
  COUNT(CASE WHEN type_app='effect' THEN 1 END) OVER w AS effect_cumul
FROM base
WINDOW w AS (PARTITION BY id_entreprise ORDER BY jour ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
ORDER BY id_entreprise, jour;


--Analyse de cohorte : combien ont répondus par jour ?--
WITH RECURSIVE cohort(day, cnt) AS (
  SELECT DATE('2024-01-01'), 0
  UNION ALL
  SELECT DATE(day, '+1 day'),
         (SELECT COUNT(DISTINCT id_individu)
          FROM APPLICATION_CAUSE
          WHERE date_heure BETWEEN cohort.day AND DATE(cohort.day,'+6 days'))
  FROM cohort
  WHERE day < DATE('now','-6 days')
)
SELECT day, cnt FROM cohort ORDER BY day;
