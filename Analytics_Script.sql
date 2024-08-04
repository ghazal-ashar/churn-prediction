SELECT count(*) FROM public.billing WHERE monthlycharges > 100 group by contract;

SELECT * FROM public.billing WHERE paymentmethod = 'Electronic check';

SELECT * FROM public.customers WHERE tenure > 60;

SELECT seniorcitizen, COUNT(*) AS count FROM public.customers GROUP BY seniorcitizen;

SELECT paperlessbilling, COUNT(*) AS count FROM public.billing GROUP BY paperlessbilling;

SELECT churnprediction, COUNT(*) AS count FROM public.predictions GROUP BY churnprediction;

SELECT internetservice, COUNT(*) AS count FROM public.services GROUP BY internetservice;

SELECT techsupport, COUNT(*) AS count FROM public.services GROUP BY techsupport;

SELECT streamingmovies, COUNT(*) AS count FROM public.services GROUP BY streamingmovies;

SELECT contract, AVG(monthlycharges) AS avg_monthly_charges FROM public.billing GROUP BY contract;



WITH churn_summary AS (
    SELECT 
        COUNT(*) AS total_customers,
        AVG(c.tenure) AS avg_tenure,
        SUM(b.totalcharges) AS total_revenue,
        AVG(b.monthlycharges) AS avg_monthly_charges,
        SUM(CASE WHEN p.churnprediction = true THEN 1 ELSE 0 END)::decimal / COUNT(*) AS churn_rate
    FROM 
        public.customers c
    JOIN 
        public.billing b ON c.customerid = b.customerid
    LEFT JOIN 
        public.predictions p ON c.customerid = p.customerid
),
contract_distribution AS (
    SELECT 
        contract,
        COUNT(*) AS count
    FROM 
        public.billing
    GROUP BY 
        contract
),
internet_service_distribution AS (
    SELECT 
        internetservice,
        COUNT(*) AS count
    FROM 
        public.services
    GROUP BY 
        internetservice
),
paperless_billing AS (
    SELECT 
        COUNT(*) AS paperless_billing_customers
    FROM 
        public.billing
    WHERE 
        paperlessbilling = 'Yes'
)
SELECT 
    cs.total_customers,
    cs.avg_tenure,
    cs.total_revenue,
    cs.avg_monthly_charges,
    cs.churn_rate,
    cd.contract,
    cd.count AS contract_count,
    isd.internetservice,
    isd.count AS internetservice_count,
    pb.paperless_billing_customers
FROM 
    churn_summary cs
JOIN 
    contract_distribution cd ON TRUE
JOIN 
    internet_service_distribution isd ON TRUE
JOIN 
    paperless_billing pb ON TRUE;



WITH churn_rate_by_contract AS (
    SELECT 
        b.contract,
        SUM(CASE WHEN p.churnprediction = true THEN 1 ELSE 0 END)::decimal / COUNT(*) AS churn_rate
    FROM 
        public.billing b
    JOIN 
        public.predictions p ON b.customerid = p.customerid
    GROUP BY 
        b.contract
)
SELECT * FROM churn_rate_by_contract;


WITH running_total AS (
    SELECT
        customerid,
        totalcharges,
        SUM(totalcharges) OVER (ORDER BY customerid) AS running_total_charges
    FROM
        public.billing
)
SELECT * FROM running_total;


WITH moving_avg AS (
    SELECT
        customerid,
        monthlycharges,
        AVG(monthlycharges) OVER (ORDER BY customerid ROWS BETWEEN 5 PRECEDING AND CURRENT ROW) AS moving_avg_monthly_charges
    FROM
        public.billing
)
SELECT * FROM moving_avg;


WITH churn_rate_by_contract AS (
	SELECT 
	b.contract, 
		SUM(CASE WHEN p.churnprediction = true THEN 1 ELSE 0 END)::decimal / COUNT(*) AS churn_rate
			FROM public.billing b
	JOIN public.predictions p ON b.customerid = p.customerid
	 GROUP BY b.contract
   )
SELECT * FROM churn_rate_by_contract;


WITH churn_rate_by_internet AS (
   SELECT s.internetservice,
		SUM(CASE WHEN p.churnprediction = true THEN 1 ELSE 0 END)::decimal / COUNT(*) AS churn_rate
            FROM public.services s
        JOIN public.predictions p ON s.customerid = p.customerid
         GROUP BY s.internetservice
  )
	SELECT * FROM churn_rate_by_internet;

WITH avg_monthly_charges_by_churn AS (
            SELECT 
                p.churnprediction,
                AVG(b.monthlycharges) AS avg_monthly_charges
            FROM 
                public.billing b
            JOIN 
                public.predictions p ON b.customerid = p.customerid
            GROUP BY 
                p.churnprediction
        )
        SELECT * FROM avg_monthly_charges_by_churn;


    
 WITH avg_tenure_by_churn AS (
            SELECT 
                p.churnprediction,
                AVG(c.tenure) AS avg_tenure
            FROM 
                public.customers c
            JOIN 
                public.predictions p ON c.customerid = p.customerid
            GROUP BY 
                p.churnprediction
        )
        SELECT * FROM avg_tenure_by_churn;
    

WITH churn_rate_by_senior AS (
	SELECT 
	c.seniorcitizen,
	SUM(CASE WHEN p.churnprediction = true THEN 1 ELSE 0 END)::decimal / COUNT(*) AS churn_rate
	FROM public.customers c
            JOIN public.predictions p ON c.customerid = p.customerid
            GROUP BY c.seniorcitizen
    )
SELECT * FROM churn_rate_by_senior;

