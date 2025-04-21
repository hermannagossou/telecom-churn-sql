-- 1. Nettoyage de la table dim_customer
-- Vérifier l'unicité de customerid
SELECT
	customerid,
	COUNT(*) AS nbre_doublons
FROM dim_customer
GROUP BY 1
HAVING COUNT(*) > 1; -- Pas de doublons

-- Détection des valeurs manquantes
SELECT
	*
FROM dim_customer
WHERE customerid IS NULL
	OR gender IS NULL
	OR seniorcitizen IS NULL
	OR partner IS NULL
	OR dependents IS NULL; -- Pas de valeurs manquantes dans la table dim_customer

-- Vérification du typage général

SELECT
	column_name,
	data_type
FROM information_schema.columns
WHERE table_name = 'dim_customer'
ORDER BY ordinal_position; -- Les types de données sont bien respectées

-- Vérification des champs de type Text et de leur orthographe

SELECT
	DISTINCT gender
FROM dim_customer; -- OK

SELECT
	DISTINCT partner
FROM dim_customer; -- OK

SELECT
	DISTINCT dependents
FROM dim_customer; -- OK

-- Vérification des champs de type integer et de leur orthographe

SELECT
	DISTINCT seniorcitizen
FROM dim_customer; -- OK

-- 2. Nettoyage de la table dim_service

SELECT * FROM dim_service;

-- Vérifier qu'il y a pas de doublon au niveau du service
SELECT
	phoneservice,
	multiplelines,
	internetservice,
	onlinesecurity,
	onlinebackup,
	deviceprotection,
	techsupport,
	streamingtv,
	streamingmovies,
	COUNT(*) AS nbre_doublons
FROM dim_service
GROUP BY 1, 2, 3, 4, 5, 6, 7, 8, 9
HAVING COUNT(*) > 1; -- Pas de doublons

-- Détection des valeurs manquantes
SELECT
	*
FROM dim_service
WHERE phoneservice IS NULL
	OR multiplelines IS NULL
	OR internetservice IS NULL
	OR onlinesecurity IS NULL
	OR onlinebackup IS NULL
	OR deviceprotection IS NULL
	OR techsupport IS NULL
	OR streamingtv IS NULL
	OR streamingmovies IS NULL; -- Pas de valeurs manquantes dans la table dim_service

-- Vérification du typage général

SELECT
	column_name,
	data_type
FROM information_schema.columns
WHERE table_name = 'dim_service'
ORDER BY ordinal_position; -- Les types de données sont bien respectées

-- Vérification des champs de type Text et de leur orthographe

SELECT
	DISTINCT phoneservice
FROM dim_service; -- OK

SELECT
	DISTINCT multiplelines
FROM dim_service; -- OK

SELECT
	DISTINCT internetservice
FROM dim_service; -- OK

SELECT
	DISTINCT onlinesecurity
FROM dim_service; -- OK

SELECT
	DISTINCT onlinebackup
FROM dim_service; -- OK

SELECT
	DISTINCT deviceprotection
FROM dim_service; -- OK

SELECT
	DISTINCT techsupport
FROM dim_service; -- OK

SELECT
	DISTINCT streamingtv
FROM dim_service; -- OK

SELECT
	DISTINCT streamingmovies
FROM dim_service; -- OK

-- 3. Nettoyage de la table dim_contract

SELECT * FROM dim_contract;

-- Vérifier qu'il y a pas de doublon au niveau du contrat
SELECT
	contract,
	paperlessbilling,
	paymentmethod,
	COUNT(*) AS nbre_doublons
FROM dim_contract
GROUP BY 1, 2, 3
HAVING COUNT(*) > 1; -- Pas de doublons

-- Détection des valeurs manquantes
SELECT
	*
FROM dim_contract
WHERE contract IS NULL
	OR paperlessbilling IS NULL
	OR paymentmethod IS NULL; -- Pas de valeurs manquantes dans la table dim_contract

-- Vérification du typage général

SELECT
	column_name,
	data_type
FROM information_schema.columns
WHERE table_name = 'dim_contract'
ORDER BY ordinal_position; -- Les types de données sont bien respectées

-- Vérification des champs de type Text et de leur orthographe

SELECT
	DISTINCT contract
FROM dim_contract; -- OK

SELECT
	DISTINCT paperlessbilling
FROM dim_contract; -- OK

SELECT
	DISTINCT paymentmethod
FROM dim_contract; -- OK

-- 4. Nettoyage de la table fact_subscription

SELECT * FROM fact_subscription;

-- Vérifier qu'il y a pas de doublon au niveau de la table fact_subscription
SELECT
	customerid_fk,
	service_id_fk,
	contract_id_fk,
	tenure,
	monthlyCharges,
	totalCharges,
	churn,
	COUNT(*) AS nbre_doublons
FROM fact_subscription
GROUP BY 1, 2, 3, 4, 5, 6, 7
HAVING COUNT(*) > 1; -- Pas de doublons

-- Détection des valeurs manquantes
SELECT
	*
FROM fact_subscription
WHERE customerid_fk IS NULL
	OR service_id_fk IS NULL
	OR contract_id_fk IS NULL
	OR tenure IS NULL
	OR monthlyCharges IS NULL
	OR totalCharges IS NULL
	OR churn IS NULL; 
/*Il y a des valeurs manquantes pour le champ totalcharges, et il y a des client qui ont une ancienneté = 0.
Leur nombre est négligeable, je vais donc les supprimer*/

DELETE FROM fact_subscription
WHERE totalcharges IS NULL;

SELECT
	*
FROM fact_subscription
WHERE customerid_fk IS NULL
	OR service_id_fk IS NULL
	OR contract_id_fk IS NULL
	OR tenure IS NULL
	OR monthlyCharges IS NULL
	OR totalCharges IS NULL
	OR churn IS NULL; 

-- Plus de valeur manquantes dans la table fact_subscription

-- Vérification du typage général

SELECT
	column_name,
	data_type
FROM information_schema.columns
WHERE table_name = 'fact_subscription'
ORDER BY ordinal_position; -- Les types de données sont bien respectées

-- Vérification des champs de type Text et de leur orthographe

SELECT
	DISTINCT churn
FROM fact_subscription; -- OK

-- Vérification des relations référentielles

--customerID_fk → dim_customer(id)

SELECT fs.customerid_fk
FROM fact_subscription fs
LEFT JOIN dim_customer dc ON fs.customerid_fk = dc.id
WHERE dc.id IS NULL; --OK

-- contract_id_fk → dim_contract(id)

SELECT fs.contract_id_fk
FROM fact_subscription fs
LEFT JOIN dim_contract dc ON fs.contract_id_fk = dc.id
WHERE dc.id IS NULL; --OK

-- service_id_fk → dim_service(id)

SELECT fs.service_id_fk
FROM fact_subscription fs
LEFT JOIN dim_service ds ON fs.service_id_fk = ds.id
WHERE ds.id IS NULL; --OK

-- Transformation de la table dim_customer

UPDATE dim_customer
SET gender = 
    CASE 
        WHEN gender = 'Male' THEN 'Homme'
        WHEN gender = 'Female' THEN 'Femme'
        ELSE gender
    END;

UPDATE dim_customer
SET partner = 
    CASE 
        WHEN partner = 'Yes' THEN 'Oui'
        WHEN partner = 'No' THEN 'Non'
        ELSE partner
    END;

UPDATE dim_customer
SET dependents = 
    CASE 
        WHEN dependents = 'Yes' THEN 'Oui'
        WHEN dependents = 'No' THEN 'Non'
        ELSE dependents
    END;

ALTER TABLE dim_customer
RENAME COLUMN gender TO gendre;

ALTER TABLE dim_customer
RENAME COLUMN seniorcitizen TO seniorite;

ALTER TABLE dim_customer
RENAME COLUMN partner TO partenaire;

ALTER TABLE dim_customer
RENAME COLUMN dependents TO enfant_a_charge;

SELECT * FROM dim_customer;

-- Transformation de la table dim_contract

UPDATE dim_contract
SET contract = 
    CASE 
        WHEN contract = 'Month-to-month' THEN 'Mensuel'
        WHEN contract = 'One year' THEN 'Un an'
		WHEN contract = 'Two year' THEN 'Deux ans'
        ELSE contract
    END;

UPDATE dim_contract
SET paperlessbilling = 
    CASE 
        WHEN paperlessbilling = 'Yes' THEN 'Oui'
        WHEN paperlessbilling = 'No' THEN 'Non'
        ELSE paperlessbilling
    END;

UPDATE dim_contract
SET paymentmethod = 
    CASE 
        WHEN paymentmethod = 'Mailed check' THEN 'Chèque posté'
        WHEN paymentmethod = 'Credit card (automatic)' THEN 'Carte de crédit'
		WHEN paymentmethod = 'Electronic check' THEN 'Chèque électronique'
		WHEN paymentmethod = 'Bank transfer (automatic)' THEN 'Virement bancaire'
        ELSE paymentmethod
    END;

ALTER TABLE dim_contract
RENAME COLUMN contract TO contrat;

ALTER TABLE dim_contract
RENAME COLUMN paperlessbilling TO facturation_sans_papier;

ALTER TABLE dim_contract
RENAME COLUMN paymentmethod TO moyen_de_paiement;

-- Transformation de la table dim_service

UPDATE dim_service
SET phoneservice = 
    CASE 
        WHEN phoneservice = 'Yes' THEN 'Oui'
        WHEN phoneservice = 'No' THEN 'Non'
        ELSE phoneservice
    END;

UPDATE dim_service
SET multiplelines = 
    CASE 
        WHEN multiplelines = 'Yes' THEN 'Oui'
        WHEN multiplelines = 'No' THEN 'Non'
		WHEN multiplelines = 'No phone service' THEN 'Pas de service téléphonique'
        ELSE multiplelines
    END;

UPDATE dim_service
SET internetservice = 
    CASE 
        WHEN internetservice = 'No' THEN 'Non'
		WHEN internetservice = 'Fiber optic' THEN 'Fibre Optique'
        ELSE internetservice
    END;

UPDATE dim_service
SET onlinesecurity = 
    CASE 
        WHEN onlinesecurity = 'Yes' THEN 'Oui'
        WHEN onlinesecurity = 'No' THEN 'Non'
		WHEN onlinesecurity = 'No internet service' THEN 'Pas de service internet'
        ELSE onlinesecurity
    END;

UPDATE dim_service
SET onlinebackup = 
    CASE 
        WHEN onlinebackup = 'Yes' THEN 'Oui'
        WHEN onlinebackup = 'No' THEN 'Non'
		WHEN onlinebackup = 'No internet service' THEN 'Pas de service internet'
        ELSE onlinebackup
    END;

UPDATE dim_service
SET deviceprotection = 
    CASE 
        WHEN deviceprotection = 'Yes' THEN 'Oui'
        WHEN deviceprotection = 'No' THEN 'Non'
		WHEN deviceprotection = 'No internet service' THEN 'Pas de service internet'
        ELSE deviceprotection
    END;

UPDATE dim_service
SET techsupport = 
    CASE 
        WHEN techsupport = 'Yes' THEN 'Oui'
        WHEN techsupport = 'No' THEN 'Non'
		WHEN techsupport = 'No internet service' THEN 'Pas de service internet'
        ELSE techsupport
    END;

UPDATE dim_service
SET streamingtv = 
    CASE 
        WHEN streamingtv = 'Yes' THEN 'Oui'
        WHEN streamingtv = 'No' THEN 'Non'
		WHEN streamingtv = 'No internet service' THEN 'Pas de service internet'
        ELSE streamingtv
    END;

UPDATE dim_service
SET streamingmovies = 
    CASE 
        WHEN streamingmovies = 'Yes' THEN 'Oui'
        WHEN streamingmovies = 'No' THEN 'Non'
		WHEN streamingmovies = 'No internet service' THEN 'Pas de service internet'
        ELSE streamingmovies
    END;

ALTER TABLE dim_service
RENAME COLUMN phoneservice TO service_telephonique;

ALTER TABLE dim_service
RENAME COLUMN multiplelines TO lignes_multiples;

ALTER TABLE dim_service
RENAME COLUMN internetservice TO service_internet;

ALTER TABLE dim_service
RENAME COLUMN onlinesecurity TO ligne_securisee;

ALTER TABLE dim_service
RENAME COLUMN onlinebackup TO ligne_sauvegardee;

ALTER TABLE dim_service
RENAME COLUMN deviceprotection TO protection_equipement;

ALTER TABLE dim_service
RENAME COLUMN techsupport TO support_technique;

SELECT * FROM dim_service;

-- Transformation de la table fact_subscription

UPDATE fact_subscription
SET churn = 
    CASE 
        WHEN churn = 'Yes' THEN 'Oui'
        WHEN churn = 'No' THEN 'Non'
        ELSE churn
    END;

ALTER TABLE fact_subscription
RENAME COLUMN tenure TO anciennete;

ALTER TABLE fact_subscription
RENAME COLUMN monthlycharges TO depenses_mensuelles;

ALTER TABLE fact_subscription
RENAME COLUMN totalcharges TO depenses_totales;