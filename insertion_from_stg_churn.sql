-- DIMENSION : dim_customer
INSERT INTO dim_customer (customerID, gender, SeniorCitizen, Partner, Dependents)
SELECT DISTINCT
    customerID,
    gender,
    SeniorCitizen,
    Partner,
    Dependents
FROM stg_churn;

-- DIMENSION : dim_service
INSERT INTO dim_service (PhoneService, MultipleLines, InternetService, OnlineSecurity,
                         OnlineBackup, DeviceProtection, TechSupport, StreamingTV, StreamingMovies)
SELECT DISTINCT
    PhoneService,
    MultipleLines,
    InternetService,
    OnlineSecurity,
    OnlineBackup,
    DeviceProtection,
    TechSupport,
    StreamingTV,
    StreamingMovies
FROM stg_churn;

-- DIMENSION : dim_contract
INSERT INTO dim_contract (Contract, PaperlessBilling, PaymentMethod)
SELECT DISTINCT
    Contract,
    PaperlessBilling,
    PaymentMethod
FROM stg_churn;

-- TABLE DE FAITS : fact_subscription
INSERT INTO fact_subscription (
    customerID_fk,
    service_id_fk,
    contract_id_fk,
    tenure,
    MonthlyCharges,
    TotalCharges,
    Churn
)
SELECT
    dc.id AS customerID_fk,
    ds.id AS service_id_fk,
    dco.id AS contract_id_fk,
    sc.tenure,
    sc.MonthlyCharges,
    NULLIF(TRIM(sc.TotalCharges), '')::FLOAT,
    sc.Churn
FROM stg_churn sc
JOIN dim_customer dc ON sc.customerID = dc.customerID
JOIN dim_service ds ON sc.PhoneService = ds.PhoneService
                    AND sc.MultipleLines = ds.MultipleLines
                    AND sc.InternetService = ds.InternetService
                    AND sc.OnlineSecurity = ds.OnlineSecurity
                    AND sc.OnlineBackup = ds.OnlineBackup
                    AND sc.DeviceProtection = ds.DeviceProtection
                    AND sc.TechSupport = ds.TechSupport
                    AND sc.StreamingTV = ds.StreamingTV
                    AND sc.StreamingMovies = ds.StreamingMovies
JOIN dim_contract dco ON sc.Contract = dco.Contract
                      AND sc.PaperlessBilling = dco.PaperlessBilling
                      AND sc.PaymentMethod = dco.PaymentMethod;
