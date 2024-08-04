CREATE TABLE IF NOT EXISTS public.billing
(
    customerid integer,
    contract character varying(255) COLLATE pg_catalog."default",
    paperlessbilling character varying(255) COLLATE pg_catalog."default",
    paymentmethod character varying(255) COLLATE pg_catalog."default",
    monthlycharges double precision,
    totalcharges double precision,
    CONSTRAINT billing_customerid_fkey FOREIGN KEY (customerid)
        REFERENCES public.customers (customerid) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
)

CREATE TABLE IF NOT EXISTS public.customers
(
    customerid integer NOT NULL,
    seniorcitizen integer,
    tenure integer,
    CONSTRAINT customers_pkey PRIMARY KEY (customerid)
)

CREATE TABLE IF NOT EXISTS public.predictions
(
    customerid integer,
    churnprediction boolean,
    CONSTRAINT predictions_customerid_fkey FOREIGN KEY (customerid)
        REFERENCES public.customers (customerid) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
)

CREATE TABLE IF NOT EXISTS public.services
(
    customerid integer,
    multiplelines character varying(255) COLLATE pg_catalog."default",
    internetservice character varying(255) COLLATE pg_catalog."default",
    onlinesecurity character varying(255) COLLATE pg_catalog."default",
    onlinebackup character varying(255) COLLATE pg_catalog."default",
    techsupport character varying(255) COLLATE pg_catalog."default",
    streamingmovies character varying(255) COLLATE pg_catalog."default",
    CONSTRAINT services_customerid_fkey FOREIGN KEY (customerid)
        REFERENCES public.customers (customerid) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
)