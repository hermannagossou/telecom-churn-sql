-- EDA Structure for Telecom Churn Analysis

-- 1. Vue d’ensemble du churn
-- - Nombre total de clients

SELECT
	COUNT(id) AS nombre_total_de_client
FROM dim_customer;

-- - Taux de churn global
CREATE OR REPLACE VIEW taux_churn_global AS
SELECT
	ROUND(1.0*COUNT(*) FILTER(WHERE churn = 'Yes')/COUNT(*),2) AS taux_global_churn
FROM fact_subscription;

-- - Répartition des clients churnés vs non churnés
CREATE OR REPLACE VIEW churn_distribution AS
SELECT
	churn,
	COUNT(*) AS repartiton_clients
FROM fact_subscription
GROUP BY churn;

-- 2. Ancienneté (tenure)

-- - Distribution de la durée d’abonnement

SELECT 
	CASE 
		WHEN tenure BETWEEN 0 AND 6 THEN '0-6 mois'
		WHEN tenure BETWEEN 7 AND 12 THEN '1 an'
		WHEN tenure BETWEEN 13 AND 24 THEN '2 ans'
		WHEN tenure BETWEEN 25 AND 36 THEN '3 ans'
		WHEN tenure BETWEEN 37 AND 48 THEN '4 ans'
		WHEN tenure BETWEEN 49 AND 60 THEN '5 ans'
		WHEN tenure BETWEEN 61 AND 72 THEN '6 ans'
		ELSE NULL
	END AS tranche_anciennete,
	COUNT(*) AS distribution_duree_abonnement
FROM fact_subscription
GROUP BY tranche_anciennete
ORDER BY distribution_duree_abonnement DESC;

SELECT * FROM fact_subscription ORDER BY tenure DESC;

-- - Churn en fonction de l'ancienneté et Seuils critiques de tenure
CREATE OR REPLACE VIEW churn_par_anciennete AS
SELECT
	tenure,
	COUNT(*) FILTER(WHERE churn = 'Yes') AS nombre_clients_churn,
	COUNT(*) AS nombre_total_clients,
	ROUND(1.0*COUNT(*) FILTER(WHERE churn = 'Yes')/COUNT(*),2) AS taux_churn
FROM fact_subscription
GROUP BY tenure
ORDER BY tenure;

-- 3. Profil du client
-- - Répartition par genre et taux de churn
CREATE OR REPLACE VIEW repartion_par_genre AS
SELECT
	gender,
	COUNT(*) AS repartition
FROM dim_customer
GROUP BY gender;

CREATE OR REPLACE VIEW churn_par_genre AS
SELECT
	cs.gender,
	ROUND(1.0*COUNT(fas.customerid_fk) FILTER(WHERE fas.churn = 'Yes')/COUNT(fas.customerid_fk),2) AS taux_churn
FROM fact_subscription fas
	LEFT JOIN dim_customer cs
		ON fas.customerid_fk = cs.id
GROUP BY cs.gender;

-- Le genre n'a pas vraiment d'influence sur le taux de churn

-- - Statut de seniorité et lien avec le churn
CREATE OR REPLACE VIEW churn_par_seniorite AS
SELECT
	cs.seniorcitizen,
	ROUND(1.0*COUNT(fas.customerid_fk) FILTER(WHERE fas.churn = 'Yes')/COUNT(fas.customerid_fk),2) AS taux_churn
FROM fact_subscription fas
	LEFT JOIN dim_customer cs
		ON fas.customerid_fk = cs.id
GROUP BY cs.seniorcitizen
ORDER BY taux_churn DESC;

-- Le taux de churn est plus élevé pour les clients Senior. Le profil Senior est un profil potentiellement à risque.

-- - Influence du partenaire et des enfants sur le churn
CREATE OR REPLACE VIEW churn_par_partenaire AS
SELECT
	cs.partner,
	ROUND(1.0*COUNT(fas.customerid_fk) FILTER(WHERE fas.churn = 'Yes')/COUNT(fas.customerid_fk),2) AS taux_churn
FROM fact_subscription fas
	LEFT JOIN dim_customer cs
		ON fas.customerid_fk = cs.id
GROUP BY cs.partner;

-- Les clients n'ayant pas de partenanire churnent plus. Ils sont donc des potentiels à risque.
CREATE OR REPLACE VIEW churn_par_dependant AS
SELECT
	cs.dependents,
	ROUND(1.0*COUNT(fas.customerid_fk) FILTER(WHERE fas.churn = 'Yes')/COUNT(fas.customerid_fk),2) AS taux_churn
FROM fact_subscription fas
	LEFT JOIN dim_customer cs
		ON fas.customerid_fk = cs.id
GROUP BY cs.dependents;

-- Les clients n'ayant pas d'enfants churnent plus. Ils sont donc des potentiels à risque.

-- - Identification des profils à risque
CREATE OR REPLACE VIEW churn_par_profil_client AS
SELECT
	cs.gender,
	cs.seniorcitizen,
	cs.partner,
	cs.dependents,
	ROUND(1.0*COUNT(fas.customerid_fk) FILTER(WHERE fas.churn = 'Yes')/COUNT(fas.customerid_fk),2) AS taux_churn
FROM fact_subscription fas
	LEFT JOIN dim_customer cs
		ON fas.customerid_fk = cs.id
GROUP BY 1, 2, 3, 4
ORDER BY taux_churn DESC;

-- Les profils à risque sont les femmes Seniors, n'ayant ni partenaire ni enfant.

-- 4. Services souscrits
-- - Popularité des services

CREATE OR REPLACE VIEW popularite_de_service AS
SELECT
	'Phone Service' AS Type_Service,
	ROUND(1.0*COUNT(*) FILTER (WHERE ds.phoneservice = 'Yes')/COUNT(*),2) AS Pourcentage_Clients
FROM fact_subscription fs
JOIN dim_service ds ON fs.service_id_fk = ds.id
UNION ALL
SELECT
	'Multiple Line' AS Type_Service,
	ROUND(1.0*COUNT(*) FILTER (WHERE ds.multiplelines = 'Yes')/COUNT(*),2) AS Pourcentage_Clients
FROM fact_subscription fs
JOIN dim_service ds ON fs.service_id_fk = ds.id
UNION ALL
SELECT
	'Online Security' AS Type_Service,
	ROUND(1.0*COUNT(*) FILTER (WHERE ds.onlinesecurity = 'Yes')/COUNT(*),2) AS Pourcentage_Clients
FROM fact_subscription fs
JOIN dim_service ds ON fs.service_id_fk = ds.id
UNION ALL
SELECT
	'Online Backup' AS Type_Service,
	ROUND(1.0*COUNT(*) FILTER (WHERE ds.onlinebackup = 'Yes')/COUNT(*),2) AS Pourcentage_Clients
FROM fact_subscription fs
JOIN dim_service ds ON fs.service_id_fk = ds.id
UNION ALL
SELECT
	'Device Protection' AS Type_Service,
	ROUND(1.0*COUNT(*) FILTER (WHERE ds.deviceprotection = 'Yes')/COUNT(*),2) AS Pourcentage_Clients
FROM fact_subscription fs
JOIN dim_service ds ON fs.service_id_fk = ds.id
UNION ALL
SELECT
	'Tech Support' AS Type_Service,
	ROUND(1.0*COUNT(*) FILTER (WHERE ds.techsupport = 'Yes')/COUNT(*),2) AS Pourcentage_Clients
FROM fact_subscription fs
JOIN dim_service ds ON fs.service_id_fk = ds.id
UNION ALL
SELECT
	'Streaming TV' AS Type_Service,
	ROUND(1.0*COUNT(*) FILTER (WHERE ds.streamingtv = 'Yes')/COUNT(*),2) AS Pourcentage_Clients
FROM fact_subscription fs
JOIN dim_service ds ON fs.service_id_fk = ds.id
UNION ALL
SELECT
	'Streaming Movies' AS Type_Service,
	ROUND(1.0*COUNT(*) FILTER (WHERE ds.streamingmovies = 'Yes')/COUNT(*),2) AS Pourcentage_Clients
FROM fact_subscription fs
JOIN dim_service ds ON fs.service_id_fk = ds.id
UNION ALL
SELECT
	'Internet Service DSL' AS Type_Service,
	ROUND(1.0*COUNT(*) FILTER (WHERE ds.internetservice = 'DSL')/COUNT(*),2) AS Pourcentage_Clients
FROM fact_subscription fs
JOIN dim_service ds ON fs.service_id_fk = ds.id
UNION ALL
SELECT
	'Internet Service Fiber Optic' AS Type_Service,
	ROUND(1.0*COUNT(*) FILTER (WHERE ds.internetservice = 'Fiber optic')/COUNT(*),2) AS Pourcentage_Clients
FROM fact_subscription fs
JOIN dim_service ds ON fs.service_id_fk = ds.id;

-- Le service téléphonique semble être le service le plus populaire

-- - Taux de churn par type de service
CREATE OR REPLACE VIEW churn_par_phone AS
SELECT
	ds.phoneservice,
	ROUND(1.0*COUNT(*) FILTER (WHERE fs.churn = 'Yes')/COUNT(*),2) AS taux_churn
FROM fact_subscription fs
	LEFT JOIN dim_service ds
		ON fs.service_id_fk = ds.id
GROUP BY ds.phoneservice;

-- Le service téléphonique n'a pas vraiment d'impact sur le taux de churn.
CREATE OR REPLACE VIEW churn_par_multiplelines AS
SELECT
	ds.multiplelines,
	ROUND(1.0*COUNT(*) FILTER (WHERE fs.churn = 'Yes')/COUNT(*),2) AS taux_churn
FROM fact_subscription fs
	LEFT JOIN dim_service ds
		ON fs.service_id_fk = ds.id
GROUP BY ds.multiplelines;

-- Le fait d'avoir plusieurs lignes non plus n'a pas vraiment d'impact sur le taux de churn.
CREATE OR REPLACE VIEW churn_par_onlinesecurity AS
SELECT
	ds.onlinesecurity,
	ROUND(1.0*COUNT(*) FILTER (WHERE fs.churn = 'Yes')/COUNT(*),2) AS taux_churn
FROM fact_subscription fs
	LEFT JOIN dim_service ds
		ON fs.service_id_fk = ds.id
GROUP BY ds.onlinesecurity
ORDER BY taux_churn DESC;

-- On constate que le taux de churn est vraiment important pour les clients sans ligne sécurisé.
CREATE OR REPLACE VIEW churn_par_onlinebackup AS
SELECT
	ds.onlinebackup,
	ROUND(1.0*COUNT(*) FILTER (WHERE fs.churn = 'Yes')/COUNT(*),2) AS taux_churn
FROM fact_subscription fs
	LEFT JOIN dim_service ds
		ON fs.service_id_fk = ds.id
GROUP BY ds.onlinebackup
ORDER BY taux_churn DESC;

-- On constate que le taux de churn est vraiment important pour les clients sans système de sauvegarde.
CREATE OR REPLACE VIEW churn_par_deviceprotection AS
SELECT
	ds.deviceprotection,
	ROUND(1.0*COUNT(*) FILTER (WHERE fs.churn = 'Yes')/COUNT(*),2) AS taux_churn
FROM fact_subscription fs
	LEFT JOIN dim_service ds
		ON fs.service_id_fk = ds.id
GROUP BY ds.deviceprotection
ORDER BY taux_churn DESC;

-- On constate que le taux de churn est vraiment important pour les clients sans système de protection pour leur équipement.
CREATE OR REPLACE VIEW churn_par_techsupport AS
SELECT
	ds.techsupport,
	ROUND(1.0*COUNT(*) FILTER (WHERE fs.churn = 'Yes')/COUNT(*),2) AS taux_churn
FROM fact_subscription fs
	LEFT JOIN dim_service ds
		ON fs.service_id_fk = ds.id
GROUP BY ds.techsupport
ORDER BY taux_churn DESC;

-- On constate que le taux de churn est vraiment important pour les clients sans support technique.
CREATE OR REPLACE VIEW churn_par_streamingtv AS
SELECT
	ds.streamingtv,
	ROUND(1.0*COUNT(*) FILTER (WHERE fs.churn = 'Yes')/COUNT(*),2) AS taux_churn
FROM fact_subscription fs
	LEFT JOIN dim_service ds
		ON fs.service_id_fk = ds.id
GROUP BY ds.streamingtv
ORDER BY taux_churn DESC;

-- On constate que le churn est vraiment important pour les clients avec ou sans le service streaming TV.
CREATE OR REPLACE VIEW churn_par_streamingmovies AS
SELECT
	ds.streamingmovies,
	ROUND(1.0*COUNT(*) FILTER (WHERE fs.churn = 'Yes')/COUNT(*),2) AS taux_churn
FROM fact_subscription fs
	LEFT JOIN dim_service ds
		ON fs.service_id_fk = ds.id
GROUP BY ds.streamingmovies
ORDER BY taux_churn DESC;

-- On constate que le churn est vraiment important pour les clients avec ou sans le service streaming Movies.
CREATE OR REPLACE VIEW churn_par_internetservice AS
SELECT
	ds.internetservice,
	ROUND(1.0*COUNT(*) FILTER (WHERE fs.churn = 'Yes')/COUNT(*),2) AS taux_churn
FROM fact_subscription fs
	LEFT JOIN dim_service ds
		ON fs.service_id_fk = ds.id
GROUP BY ds.internetservice
ORDER BY taux_churn DESC;

-- On constate que le churn est vraiment important pour les clients ayant souscrit à la Fibre Optique.

-- - Effet de la multi-souscription
CREATE OR REPLACE VIEW churn_par_multisouscription AS
SELECT
	ds.phoneservice,
	ds.multiplelines,
	ds.internetservice,
	ds.onlinesecurity,
	ds.onlinebackup,
	ds.deviceprotection,
	ds.techsupport,
	ds.streamingtv,
	ds.streamingmovies,
	COUNT(*) FILTER (WHERE fs.churn = 'Yes') AS nbre_clients_churn,
	COUNT(*) AS nb_total_clients,
	ROUND(1.0*COUNT(*) FILTER (WHERE fs.churn = 'Yes')/COUNT(*),2) AS taux_churn
FROM fact_subscription fs
	LEFT JOIN dim_service ds
		ON fs.service_id_fk = ds.id
GROUP BY 1, 2, 3, 4, 5, 6, 7, 8, 9
ORDER BY taux_churn;

-- - Services critiques influençant le churn
/*Les service critiques impactant vraiment le churn sont : 
	Les clients avec le service Internet Fibre Optique
	Disposant d'une ligne sécurisé, système de protection pour leur équipement, avec un support technique, le service streaming TV.*/

-- 5. Analyse des contrats

-- Répartition des types de contrat

SELECT
	dc.contract,
	COUNT(*) AS repartition_contrat
FROM fact_subscription fs
	LEFT JOIN dim_contract dc
		ON fs.contract_id_fk = dc.id
GROUP BY 1
ORDER BY COUNT(*) DESC;

-- Taux de churn par type de contrat
CREATE OR REPLACE VIEW churn_par_contrat AS
SELECT
	dc.contract,
	ROUND(1.0*COUNT(*) FILTER (WHERE fs.churn = 'Yes')/COUNT(*),2) AS taux_churn
FROM fact_subscription fs
	LEFT JOIN dim_contract dc
		ON fs.contract_id_fk = dc.id
GROUP BY 1
ORDER BY taux_churn DESC;

-- Impact de Paperless Billing
CREATE OR REPLACE VIEW churn_par_paperlessbilling AS
SELECT
	dc.paperlessbilling,
	ROUND(1.0*COUNT(*) FILTER (WHERE fs.churn = 'Yes')/COUNT(*),2) AS taux_churn
FROM fact_subscription fs
	LEFT JOIN dim_contract dc
		ON fs.contract_id_fk = dc.id
GROUP BY 1
ORDER BY taux_churn DESC;

-- Impact de la méthode de paiement
CREATE OR REPLACE VIEW churn_par_paymentmethod AS
SELECT
	dc.paymentmethod,
	ROUND(1.0*COUNT(*) FILTER (WHERE fs.churn = 'Yes')/COUNT(*),2) AS taux_churn
FROM fact_subscription fs
	LEFT JOIN dim_contract dc
		ON fs.contract_id_fk = dc.id
GROUP BY 1
ORDER BY taux_churn DESC;

-- Profilage du type de contrat à risque
CREATE OR REPLACE VIEW churn_par_contrat_a_risque AS
SELECT
	dc.contract,
	dc.paperlessbilling,
	dc.paymentmethod,
	ROUND(1.0*COUNT(*) FILTER (WHERE fs.churn = 'Yes')/COUNT(*),2) AS taux_churn
FROM fact_subscription fs
	LEFT JOIN dim_contract dc
		ON fs.contract_id_fk = dc.id
GROUP BY 1, 2, 3
ORDER BY taux_churn DESC;

-- 5. Analyse financière

-- - Distribution des charges mensuelles

SELECT
	CASE 
		WHEN monthlycharges BETWEEN 0 AND 10 THEN 'month_0_10'
		WHEN monthlycharges BETWEEN 10 AND 20 THEN 'month_10_20'
		WHEN monthlycharges BETWEEN 20 AND 30 THEN 'month_20_30'
		WHEN monthlycharges BETWEEN 30 AND 40 THEN 'month_30_40'
		WHEN monthlycharges BETWEEN 40 AND 50 THEN 'month_40_50'
		WHEN monthlycharges BETWEEN 50 AND 60 THEN 'month_50_60'
		WHEN monthlycharges BETWEEN 60 AND 70 THEN 'month_60_70'
		WHEN monthlycharges BETWEEN 70 AND 80 THEN 'month_70_80'
		WHEN monthlycharges BETWEEN 80 AND 90 THEN 'month_80_90'
		WHEN monthlycharges BETWEEN 90 AND 100 THEN 'month_90_100'
		WHEN monthlycharges BETWEEN 100 AND 110 THEN 'month_100_110'
		WHEN monthlycharges BETWEEN 110 AND 120 THEN 'month_110_120'
		ELSE NULL
	END AS monthlychargebin,
	COUNT(*) AS ditribution
FROM fact_subscription
GROUP BY 1
ORDER BY 2 DESC;

-- - Total des charges payées

SELECT
	CASE 
		WHEN totalcharges BETWEEN 0 AND 1000 THEN 'total_0_1000'
		WHEN totalcharges BETWEEN 1000 AND 2000 THEN 'month_1000_2000'
		WHEN totalcharges BETWEEN 2000 AND 3000 THEN 'month_2000_3000'
		WHEN totalcharges BETWEEN 3000 AND 4000 THEN 'month_3000_4000'
		WHEN totalcharges BETWEEN 4000 AND 5000 THEN 'month_4000_5000'
		WHEN totalcharges BETWEEN 5000 AND 6000 THEN 'month_5000_6000'
		WHEN totalcharges BETWEEN 6000 AND 7000 THEN 'month_6000_7000'
		WHEN totalcharges BETWEEN 7000 AND 8000 THEN 'month_7000_8000'
		WHEN totalcharges BETWEEN 8000 AND 9000 THEN 'month_8000_9000'
		ELSE NULL
	END AS totalchargebin,
	COUNT(*) AS ditribution
FROM fact_subscription
GROUP BY 1
ORDER BY 2 DESC;

-- - Comparaison des coûts churné vs non churné
CREATE OR REPLACE VIEW comparaison_cout_churn_vs_non_churn AS
SELECT
	churn,
	ROUND(AVG(totalcharges),2) AS Cout_moyen
FROM fact_subscription
GROUP BY 1;

-- La catégorie des churn rapporte moins que la catégorie des non churn

-- Taux de churn par tranche de prix
CREATE OR REPLACE VIEW churn_par_tranche_de_prix AS
WITH churn_prix AS(
	SELECT
		'10-20 euros' AS tranche_prix,
		ROUND(1.0*COUNT(*) FILTER(WHERE churn = 'Yes')/COUNT(*),2) AS taux_churn
	FROM fact_subscription
	WHERE monthlycharges BETWEEN 10 AND 20
	UNION ALL
	SELECT
		'20-30 euros' AS tranche_prix,
		ROUND(1.0*COUNT(*) FILTER(WHERE churn = 'Yes')/COUNT(*),2) AS taux_churn
	FROM fact_subscription
	WHERE monthlycharges BETWEEN 20 AND 30
	UNION ALL
	SELECT
		'30-40 euros' AS tranche_prix,
		ROUND(1.0*COUNT(*) FILTER(WHERE churn = 'Yes')/COUNT(*),2) AS taux_churn
	FROM fact_subscription
	WHERE monthlycharges BETWEEN 30 AND 40
	UNION ALL
	SELECT
		'40-50 euros' AS tranche_prix,
		ROUND(1.0*COUNT(*) FILTER(WHERE churn = 'Yes')/COUNT(*),2) AS taux_churn
	FROM fact_subscription
	WHERE monthlycharges BETWEEN 40 AND 50
	UNION ALL
	SELECT
		'50-60 euros' AS tranche_prix,
		ROUND(1.0*COUNT(*) FILTER(WHERE churn = 'Yes')/COUNT(*),2) AS taux_churn
	FROM fact_subscription
	WHERE monthlycharges BETWEEN 50 AND 60
	UNION ALL
	SELECT
		'60-70 euros' AS tranche_prix,
		ROUND(1.0*COUNT(*) FILTER(WHERE churn = 'Yes')/COUNT(*),2) AS taux_churn
	FROM fact_subscription
	WHERE monthlycharges BETWEEN 60 AND 70
	UNION ALL
	SELECT
		'70-80 euros' AS tranche_prix,
		ROUND(1.0*COUNT(*) FILTER(WHERE churn = 'Yes')/COUNT(*),2) AS taux_churn
	FROM fact_subscription
	WHERE monthlycharges BETWEEN 70 AND 80
	UNION ALL
	SELECT
		'80-90 euros' AS tranche_prix,
		ROUND(1.0*COUNT(*) FILTER(WHERE churn = 'Yes')/COUNT(*),2) AS taux_churn
	FROM fact_subscription
	WHERE monthlycharges BETWEEN 80 AND 90
	UNION ALL
	SELECT
		'90-100 euros' AS tranche_prix,
		ROUND(1.0*COUNT(*) FILTER(WHERE churn = 'Yes')/COUNT(*),2) AS taux_churn
	FROM fact_subscription
	WHERE monthlycharges BETWEEN 90 AND 100
	UNION ALL
	SELECT
		'100-110 euros' AS tranche_prix,
		ROUND(1.0*COUNT(*) FILTER(WHERE churn = 'Yes')/COUNT(*),2) AS taux_churn
	FROM fact_subscription
	WHERE monthlycharges BETWEEN 100 AND 110
	UNION ALL
	SELECT
		'110-120 euros' AS tranche_prix,
		ROUND(1.0*COUNT(*) FILTER(WHERE churn = 'Yes')/COUNT(*),2) AS taux_churn
	FROM fact_subscription
	WHERE monthlycharges BETWEEN 110 AND 120
)
SELECT
	*
FROM churn_prix
ORDER BY taux_churn DESC;
