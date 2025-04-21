-- TABLE DE STAGING
DROP TABLE IF EXISTS stg_churn;
CREATE TABLE stg_churn (
    customerID TEXT,
    gender TEXT,
    SeniorCitizen INTEGER,
    Partner TEXT,
    Dependents TEXT,
    tenure INTEGER,
    PhoneService TEXT,
    MultipleLines TEXT,
    InternetService TEXT,
    OnlineSecurity TEXT,
    OnlineBackup TEXT,
    DeviceProtection TEXT,
    TechSupport TEXT,
    StreamingTV TEXT,
    StreamingMovies TEXT,
    Contract TEXT,
    PaperlessBilling TEXT,
    PaymentMethod TEXT,
    MonthlyCharges NUMERIC,
    TotalCharges TEXT,
    Churn TEXT
);

-- TABLE DE DIMENSION : dim_customer
DROP TABLE IF EXISTS dim_customer;
CREATE TABLE dim_customer (
    id SERIAL PRIMARY KEY,
    customerID TEXT UNIQUE,
    gender TEXT,
    SeniorCitizen INTEGER,
    Partner TEXT,
    Dependents TEXT
);

-- TABLE DE DIMENSION : dim_service
DROP TABLE IF EXISTS dim_service;
CREATE TABLE dim_service (
    id SERIAL PRIMARY KEY,
    PhoneService TEXT,
    MultipleLines TEXT,
    InternetService TEXT,
    OnlineSecurity TEXT,
    OnlineBackup TEXT,
    DeviceProtection TEXT,
    TechSupport TEXT,
    StreamingTV TEXT,
    StreamingMovies TEXT
);

-- TABLE DE DIMENSION : dim_contract
DROP TABLE IF EXISTS dim_contract;
CREATE TABLE dim_contract (
    id SERIAL PRIMARY KEY,
    Contract TEXT,
    PaperlessBilling TEXT,
    PaymentMethod TEXT
);

-- TABLE DE FAITS : fact_subscription
DROP TABLE IF EXISTS fact_subscription;
CREATE TABLE fact_subscription (
    id SERIAL PRIMARY KEY,
    customerID_fk INTEGER REFERENCES dim_customer(id),
    service_id_fk INTEGER REFERENCES dim_service(id),
    contract_id_fk INTEGER REFERENCES dim_contract(id),
    tenure INTEGER,
    MonthlyCharges NUMERIC,
    TotalCharges NUMERIC,
    Churn TEXT
);
