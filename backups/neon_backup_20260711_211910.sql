--
-- PostgreSQL database dump
--

\restrict gVfu7fOYt3TbHa7l2K1E2ZRRC4cgTU8pIAw3HTR8LPbwW9DWUKGmD2NUgI8ixW5

-- Dumped from database version 15.18 (5d0505b)
-- Dumped by pg_dump version 18.4

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

ALTER TABLE IF EXISTS ONLY public.user_roles DROP CONSTRAINT IF EXISTS user_roles_user_id_fkey;
ALTER TABLE IF EXISTS ONLY public.user_roles DROP CONSTRAINT IF EXISTS user_roles_role_id_fkey;
ALTER TABLE IF EXISTS ONLY public.transactions_demo DROP CONSTRAINT IF EXISTS transactions_demo_debt_id_fkey;
ALTER TABLE IF EXISTS ONLY public.transactions_demo DROP CONSTRAINT IF EXISTS transactions_demo_category_id_fkey;
ALTER TABLE IF EXISTS ONLY public.transactions DROP CONSTRAINT IF EXISTS transactions_category_id_fkey;
ALTER TABLE IF EXISTS ONLY public.role_permissions DROP CONSTRAINT IF EXISTS role_permissions_role_id_fkey;
ALTER TABLE IF EXISTS ONLY public.role_permissions DROP CONSTRAINT IF EXISTS role_permissions_permission_id_fkey;
ALTER TABLE IF EXISTS ONLY public.monthly_period_snapshots DROP CONSTRAINT IF EXISTS monthly_period_snapshots_monthly_period_id_fkey;
ALTER TABLE IF EXISTS ONLY public.monthly_period_events DROP CONSTRAINT IF EXISTS monthly_period_events_monthly_period_id_fkey;
ALTER TABLE IF EXISTS ONLY public.month_closings DROP CONSTRAINT IF EXISTS month_closings_user_id_fkey;
ALTER TABLE IF EXISTS ONLY public.month_closings DROP CONSTRAINT IF EXISTS month_closings_carry_over_transaction_id_fkey;
ALTER TABLE IF EXISTS ONLY public.installment_schedule DROP CONSTRAINT IF EXISTS installment_schedule_plan_id_fkey;
ALTER TABLE IF EXISTS ONLY public.installment_schedule DROP CONSTRAINT IF EXISTS installment_schedule_payment_transaction_id_fkey;
ALTER TABLE IF EXISTS ONLY public.installment_plans DROP CONSTRAINT IF EXISTS installment_plans_purchase_id_fkey;
ALTER TABLE IF EXISTS ONLY public.installment_plans DROP CONSTRAINT IF EXISTS installment_plans_debt_id_fkey;
ALTER TABLE IF EXISTS ONLY public.debt_payments DROP CONSTRAINT IF EXISTS debt_payments_transaction_id_fkey;
ALTER TABLE IF EXISTS ONLY public.debt_payments DROP CONSTRAINT IF EXISTS debt_payments_debt_record_id_fkey;
ALTER TABLE IF EXISTS ONLY public.credit_card_statements DROP CONSTRAINT IF EXISTS credit_card_statements_card_id_fkey;
ALTER TABLE IF EXISTS ONLY public.credit_card_purchases DROP CONSTRAINT IF EXISTS credit_card_purchases_transaction_id_fkey;
ALTER TABLE IF EXISTS ONLY public.credit_card_purchases DROP CONSTRAINT IF EXISTS credit_card_purchases_card_id_fkey;
ALTER TABLE IF EXISTS ONLY public.credit_card_period_configs DROP CONSTRAINT IF EXISTS credit_card_period_configs_card_id_fkey;
ALTER TABLE IF EXISTS ONLY public.credit_card_payments DROP CONSTRAINT IF EXISTS credit_card_payments_transaction_id_fkey;
ALTER TABLE IF EXISTS ONLY public.credit_card_payments DROP CONSTRAINT IF EXISTS credit_card_payments_statement_id_fkey;
ALTER TABLE IF EXISTS ONLY public.credit_card_payments DROP CONSTRAINT IF EXISTS credit_card_payments_card_id_fkey;
ALTER TABLE IF EXISTS ONLY public.bank_accounts DROP CONSTRAINT IF EXISTS bank_accounts_user_id_fkey;
DROP INDEX IF EXISTS public.ix_users_username;
DROP INDEX IF EXISTS public.ix_users_id;
DROP INDEX IF EXISTS public.ix_users_email;
DROP INDEX IF EXISTS public.ix_transactions_user_id;
DROP INDEX IF EXISTS public.ix_transactions_id;
DROP INDEX IF EXISTS public.ix_transactions_demo_id;
DROP INDEX IF EXISTS public.ix_roles_name;
DROP INDEX IF EXISTS public.ix_roles_id;
DROP INDEX IF EXISTS public.ix_refresh_tokens_token_hash;
DROP INDEX IF EXISTS public.ix_refresh_tokens_id;
DROP INDEX IF EXISTS public.ix_permissions_id;
DROP INDEX IF EXISTS public.ix_permissions_code;
DROP INDEX IF EXISTS public.ix_monthly_periods_year_month;
DROP INDEX IF EXISTS public.ix_monthly_periods_user_id;
DROP INDEX IF EXISTS public.ix_monthly_periods_id;
DROP INDEX IF EXISTS public.ix_monthly_period_snapshots_id;
DROP INDEX IF EXISTS public.ix_monthly_period_events_monthly_period_id;
DROP INDEX IF EXISTS public.ix_monthly_period_events_id;
DROP INDEX IF EXISTS public.ix_monthly_balances_user_id;
DROP INDEX IF EXISTS public.ix_monthly_balances_id;
DROP INDEX IF EXISTS public.ix_month_closings_user_id;
DROP INDEX IF EXISTS public.ix_month_closings_id;
DROP INDEX IF EXISTS public.ix_installment_schedule_id;
DROP INDEX IF EXISTS public.ix_installment_plans_id;
DROP INDEX IF EXISTS public.ix_debts_id;
DROP INDEX IF EXISTS public.ix_debt_records_user_id;
DROP INDEX IF EXISTS public.ix_debt_records_id;
DROP INDEX IF EXISTS public.ix_debt_payments_id;
DROP INDEX IF EXISTS public.ix_debt_payments_debt_record_id;
DROP INDEX IF EXISTS public.ix_credit_cards_id;
DROP INDEX IF EXISTS public.ix_credit_card_statements_id;
DROP INDEX IF EXISTS public.ix_credit_card_purchases_id;
DROP INDEX IF EXISTS public.ix_credit_card_period_configs_id;
DROP INDEX IF EXISTS public.ix_credit_card_payments_id;
DROP INDEX IF EXISTS public.ix_categories_id;
DROP INDEX IF EXISTS public.ix_budget_items_user_id;
DROP INDEX IF EXISTS public.ix_budget_items_id;
DROP INDEX IF EXISTS public.ix_bank_accounts_user_id;
DROP INDEX IF EXISTS public.ix_bank_accounts_id;
DROP INDEX IF EXISTS public.ix_audit_logs_id;
DROP INDEX IF EXISTS public.ix_audit_logs_created_at;
DROP INDEX IF EXISTS public.ix_audit_logs_action;
DROP INDEX IF EXISTS public.ix_app_settings_key;
DROP INDEX IF EXISTS public.ix_app_settings_id;
ALTER TABLE IF EXISTS ONLY public.users DROP CONSTRAINT IF EXISTS users_pkey;
ALTER TABLE IF EXISTS ONLY public.user_roles DROP CONSTRAINT IF EXISTS user_roles_pkey;
ALTER TABLE IF EXISTS ONLY public.monthly_periods DROP CONSTRAINT IF EXISTS uq_monthly_periods_year_month_user;
ALTER TABLE IF EXISTS ONLY public.month_closings DROP CONSTRAINT IF EXISTS uq_month_closings_year_month_user;
ALTER TABLE IF EXISTS ONLY public.credit_cards DROP CONSTRAINT IF EXISTS uq_credit_cards_user_card_name;
ALTER TABLE IF EXISTS ONLY public.credit_card_period_configs DROP CONSTRAINT IF EXISTS uq_card_period_config;
ALTER TABLE IF EXISTS ONLY public.transactions DROP CONSTRAINT IF EXISTS transactions_pkey;
ALTER TABLE IF EXISTS ONLY public.transactions_demo DROP CONSTRAINT IF EXISTS transactions_demo_pkey;
ALTER TABLE IF EXISTS ONLY public.roles DROP CONSTRAINT IF EXISTS roles_pkey;
ALTER TABLE IF EXISTS ONLY public.role_permissions DROP CONSTRAINT IF EXISTS role_permissions_pkey;
ALTER TABLE IF EXISTS ONLY public.refresh_tokens DROP CONSTRAINT IF EXISTS refresh_tokens_pkey;
ALTER TABLE IF EXISTS ONLY public.permissions DROP CONSTRAINT IF EXISTS permissions_pkey;
ALTER TABLE IF EXISTS ONLY public.monthly_periods DROP CONSTRAINT IF EXISTS monthly_periods_pkey;
ALTER TABLE IF EXISTS ONLY public.monthly_period_snapshots DROP CONSTRAINT IF EXISTS monthly_period_snapshots_pkey;
ALTER TABLE IF EXISTS ONLY public.monthly_period_events DROP CONSTRAINT IF EXISTS monthly_period_events_pkey;
ALTER TABLE IF EXISTS ONLY public.monthly_balances DROP CONSTRAINT IF EXISTS monthly_balances_pkey;
ALTER TABLE IF EXISTS ONLY public.month_closings DROP CONSTRAINT IF EXISTS month_closings_pkey;
ALTER TABLE IF EXISTS ONLY public.installment_schedule DROP CONSTRAINT IF EXISTS installment_schedule_pkey;
ALTER TABLE IF EXISTS ONLY public.installment_plans DROP CONSTRAINT IF EXISTS installment_plans_purchase_id_key;
ALTER TABLE IF EXISTS ONLY public.installment_plans DROP CONSTRAINT IF EXISTS installment_plans_pkey;
ALTER TABLE IF EXISTS ONLY public.budget_items DROP CONSTRAINT IF EXISTS debts_pkey;
ALTER TABLE IF EXISTS ONLY public.debt_records DROP CONSTRAINT IF EXISTS debt_records_pkey;
ALTER TABLE IF EXISTS ONLY public.debt_payments DROP CONSTRAINT IF EXISTS debt_payments_pkey;
ALTER TABLE IF EXISTS ONLY public.credit_cards DROP CONSTRAINT IF EXISTS credit_cards_pkey;
ALTER TABLE IF EXISTS ONLY public.credit_card_statements DROP CONSTRAINT IF EXISTS credit_card_statements_pkey;
ALTER TABLE IF EXISTS ONLY public.credit_card_purchases DROP CONSTRAINT IF EXISTS credit_card_purchases_pkey;
ALTER TABLE IF EXISTS ONLY public.credit_card_period_configs DROP CONSTRAINT IF EXISTS credit_card_period_configs_pkey;
ALTER TABLE IF EXISTS ONLY public.credit_card_payments DROP CONSTRAINT IF EXISTS credit_card_payments_pkey;
ALTER TABLE IF EXISTS ONLY public.categories DROP CONSTRAINT IF EXISTS categories_pkey;
ALTER TABLE IF EXISTS ONLY public.categories DROP CONSTRAINT IF EXISTS categories_name_key;
ALTER TABLE IF EXISTS ONLY public.bank_accounts DROP CONSTRAINT IF EXISTS bank_accounts_pkey;
ALTER TABLE IF EXISTS ONLY public.audit_logs DROP CONSTRAINT IF EXISTS audit_logs_pkey;
ALTER TABLE IF EXISTS ONLY public.app_settings DROP CONSTRAINT IF EXISTS app_settings_pkey;
ALTER TABLE IF EXISTS ONLY public.alembic_version DROP CONSTRAINT IF EXISTS alembic_version_pkc;
ALTER TABLE IF EXISTS public.users ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.transactions ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.roles ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.refresh_tokens ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.permissions ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.monthly_periods ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.monthly_period_snapshots ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.monthly_period_events ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.monthly_balances ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.month_closings ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.installment_schedule ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.installment_plans ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.debt_records ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.debt_payments ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.credit_cards ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.credit_card_statements ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.credit_card_purchases ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.credit_card_period_configs ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.credit_card_payments ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.categories ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.budget_items ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.bank_accounts ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.audit_logs ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.app_settings ALTER COLUMN id DROP DEFAULT;
DROP SEQUENCE IF EXISTS public.users_id_seq;
DROP TABLE IF EXISTS public.users;
DROP TABLE IF EXISTS public.user_roles;
DROP TABLE IF EXISTS public.transactions_demo;
DROP SEQUENCE IF EXISTS public.transactions_id_seq;
DROP TABLE IF EXISTS public.transactions;
DROP TABLE IF EXISTS public.test_123;
DROP SEQUENCE IF EXISTS public.roles_id_seq;
DROP TABLE IF EXISTS public.roles;
DROP TABLE IF EXISTS public.role_permissions;
DROP SEQUENCE IF EXISTS public.refresh_tokens_id_seq;
DROP TABLE IF EXISTS public.refresh_tokens;
DROP SEQUENCE IF EXISTS public.permissions_id_seq;
DROP TABLE IF EXISTS public.permissions;
DROP SEQUENCE IF EXISTS public.monthly_periods_id_seq;
DROP TABLE IF EXISTS public.monthly_periods;
DROP SEQUENCE IF EXISTS public.monthly_period_snapshots_id_seq;
DROP TABLE IF EXISTS public.monthly_period_snapshots;
DROP SEQUENCE IF EXISTS public.monthly_period_events_id_seq;
DROP TABLE IF EXISTS public.monthly_period_events;
DROP SEQUENCE IF EXISTS public.monthly_balances_id_seq;
DROP TABLE IF EXISTS public.monthly_balances;
DROP SEQUENCE IF EXISTS public.month_closings_id_seq;
DROP TABLE IF EXISTS public.month_closings;
DROP SEQUENCE IF EXISTS public.installment_schedule_id_seq;
DROP TABLE IF EXISTS public.installment_schedule;
DROP SEQUENCE IF EXISTS public.installment_plans_id_seq;
DROP TABLE IF EXISTS public.installment_plans;
DROP SEQUENCE IF EXISTS public.debt_records_id_seq;
DROP TABLE IF EXISTS public.debt_records;
DROP SEQUENCE IF EXISTS public.debt_payments_id_seq;
DROP TABLE IF EXISTS public.debt_payments;
DROP SEQUENCE IF EXISTS public.credit_cards_id_seq;
DROP TABLE IF EXISTS public.credit_cards;
DROP SEQUENCE IF EXISTS public.credit_card_statements_id_seq;
DROP TABLE IF EXISTS public.credit_card_statements;
DROP SEQUENCE IF EXISTS public.credit_card_purchases_id_seq;
DROP TABLE IF EXISTS public.credit_card_purchases;
DROP SEQUENCE IF EXISTS public.credit_card_period_configs_id_seq;
DROP TABLE IF EXISTS public.credit_card_period_configs;
DROP SEQUENCE IF EXISTS public.credit_card_payments_id_seq;
DROP TABLE IF EXISTS public.credit_card_payments;
DROP SEQUENCE IF EXISTS public.categories_id_seq;
DROP TABLE IF EXISTS public.categories;
DROP SEQUENCE IF EXISTS public.budget_items_id_seq;
DROP TABLE IF EXISTS public.budget_items;
DROP SEQUENCE IF EXISTS public.bank_accounts_id_seq;
DROP TABLE IF EXISTS public.bank_accounts;
DROP SEQUENCE IF EXISTS public.audit_logs_id_seq;
DROP TABLE IF EXISTS public.audit_logs;
DROP SEQUENCE IF EXISTS public.app_settings_id_seq26;
DROP TABLE IF EXISTS public.app_settings;
DROP TABLE IF EXISTS public.alembic_version;
DROP TYPE IF EXISTS public.transactiontype;
DROP TYPE IF EXISTS public.statementstatus;
DROP TYPE IF EXISTS public.necessitytype;
DROP TYPE IF EXISTS public.monthperiodstatus;
DROP TYPE IF EXISTS public.monthperiodeventtype;
DROP TYPE IF EXISTS public.installmentstatus;
DROP TYPE IF EXISTS public.installmentplantype;
DROP TYPE IF EXISTS public.flowtype;
DROP TYPE IF EXISTS public.flow_type;
DROP TYPE IF EXISTS public.expensetype;
DROP TYPE IF EXISTS public.debttype;
DROP TYPE IF EXISTS public.debtstatus;
DROP TYPE IF EXISTS public.debtrecordstatus;
DROP TYPE IF EXISTS public.debt_status;
DROP TYPE IF EXISTS public.budgettype;
DROP TYPE IF EXISTS public.budget_type;
DROP TYPE IF EXISTS public.assignmentstatus;
DROP TYPE IF EXISTS public.accounttype;
--
-- Name: accounttype; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.accounttype AS ENUM (
    'CUENTA_CORRIENTE',
    'CAJA_AHORRO',
    'BILLETERA_VIRTUAL',
    'INVERSION',
    'OTRO'
);


--
-- Name: assignmentstatus; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.assignmentstatus AS ENUM (
    'ASIGNADA_MANUAL',
    'ASIGNADA_AUTOMATICA',
    'NO_PLANIFICADA',
    'REASIGNADA_AUTOMATICA'
);


--
-- Name: budget_type; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.budget_type AS ENUM (
    'OBLIGATION',
    'VARIABLE'
);


--
-- Name: budgettype; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.budgettype AS ENUM (
    'OBLIGATION',
    'VARIABLE'
);


--
-- Name: debt_status; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.debt_status AS ENUM (
    'Pendiente',
    'Pagada',
    'Vencida'
);


--
-- Name: debtrecordstatus; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.debtrecordstatus AS ENUM (
    'ACTIVA',
    'CANCELADA',
    'VENCIDA'
);


--
-- Name: debtstatus; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.debtstatus AS ENUM (
    'PENDIENTE',
    'PAGADA',
    'VENCIDA',
    'Pago parcial'
);


--
-- Name: debttype; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.debttype AS ENUM (
    'TARJETA',
    'PRESTAMO',
    'HIPOTECA',
    'PERSONAL',
    'OTRO'
);


--
-- Name: expensetype; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.expensetype AS ENUM (
    'FIJO',
    'VARIABLE'
);


--
-- Name: flow_type; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.flow_type AS ENUM (
    'Gasto',
    'Ingreso'
);


--
-- Name: flowtype; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.flowtype AS ENUM (
    'Gasto',
    'Ingreso'
);


--
-- Name: installmentplantype; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.installmentplantype AS ENUM (
    'REGULAR',
    'PROMOTIONAL',
    'ZERO_INTEREST'
);


--
-- Name: installmentstatus; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.installmentstatus AS ENUM (
    'PENDING',
    'PAID'
);


--
-- Name: monthperiodeventtype; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.monthperiodeventtype AS ENUM (
    'OPEN',
    'CLOSE',
    'REOPEN'
);


--
-- Name: monthperiodstatus; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.monthperiodstatus AS ENUM (
    'OPEN',
    'CLOSED',
    'REOPENED'
);


--
-- Name: necessitytype; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.necessitytype AS ENUM (
    'NECESARIO',
    'SUPERFLUO',
    'IMPORTANTE_NO_URGENTE'
);


--
-- Name: statementstatus; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.statementstatus AS ENUM (
    'PENDING',
    'PARTIALLY_PAID',
    'PAID',
    'OVERDUE'
);


--
-- Name: transactiontype; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.transactiontype AS ENUM (
    'GASTO',
    'INGRESO'
);


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: alembic_version; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.alembic_version (
    version_num character varying(32) NOT NULL
);


--
-- Name: app_settings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.app_settings (
    id integer NOT NULL,
    key character varying(100) NOT NULL,
    value character varying(500) NOT NULL,
    description character varying(255),
    updated_at timestamp without time zone
);


--
-- Name: app_settings_id_seq26; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.app_settings_id_seq26
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: app_settings_id_seq26; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.app_settings_id_seq26 OWNED BY public.app_settings.id;


--
-- Name: audit_logs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.audit_logs (
    id integer NOT NULL,
    user_id integer,
    username character varying(50),
    action character varying(50) NOT NULL,
    entity character varying(50),
    entity_id integer,
    details text,
    ip_address character varying(45),
    user_agent character varying(500),
    created_at timestamp without time zone
);


--
-- Name: audit_logs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.audit_logs_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: audit_logs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.audit_logs_id_seq OWNED BY public.audit_logs.id;


--
-- Name: bank_accounts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.bank_accounts (
    id integer NOT NULL,
    user_id integer NOT NULL,
    account_name character varying(100) NOT NULL,
    institution_name character varying(100) NOT NULL,
    account_type public.accounttype NOT NULL,
    currency character varying(3) DEFAULT 'ARS'::character varying NOT NULL,
    balance double precision DEFAULT '0'::double precision NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    cbu_cvu character varying(22),
    alias character varying(50),
    notes text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: bank_accounts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.bank_accounts_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: bank_accounts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.bank_accounts_id_seq OWNED BY public.bank_accounts.id;


--
-- Name: budget_items; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.budget_items (
    id integer NOT NULL,
    fecha character varying NOT NULL,
    tipo character varying NOT NULL,
    categoria character varying NOT NULL,
    monto_total double precision NOT NULL,
    monto_pagado double precision NOT NULL,
    detalle character varying,
    fecha_vencimiento character varying NOT NULL,
    status public.debtstatus NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    tipo_presupuesto public.budgettype DEFAULT 'OBLIGATION'::public.budgettype,
    tipo_flujo public.flowtype DEFAULT 'Gasto'::public.flowtype,
    monto_ejecutado double precision DEFAULT 0.0 NOT NULL,
    estimated_payment double precision,
    user_id integer
);


--
-- Name: budget_items_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.budget_items_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: budget_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.budget_items_id_seq OWNED BY public.budget_items.id;


--
-- Name: categories; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.categories (
    id integer NOT NULL,
    name character varying NOT NULL,
    created_at timestamp without time zone
);


--
-- Name: categories_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.categories_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: categories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.categories_id_seq OWNED BY public.categories.id;


--
-- Name: credit_card_payments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.credit_card_payments (
    id integer NOT NULL,
    transaction_id integer,
    statement_id integer,
    card_id integer NOT NULL,
    payment_date date NOT NULL,
    amount_paid double precision NOT NULL,
    payment_method character varying(50),
    notes text,
    created_at timestamp without time zone
);


--
-- Name: credit_card_payments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.credit_card_payments_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: credit_card_payments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.credit_card_payments_id_seq OWNED BY public.credit_card_payments.id;


--
-- Name: credit_card_period_configs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.credit_card_period_configs (
    id integer NOT NULL,
    card_id integer NOT NULL,
    year integer NOT NULL,
    month integer NOT NULL,
    closing_day integer NOT NULL,
    due_day integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: credit_card_period_configs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.credit_card_period_configs_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: credit_card_period_configs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.credit_card_period_configs_id_seq OWNED BY public.credit_card_period_configs.id;


--
-- Name: credit_card_purchases; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.credit_card_purchases (
    id integer NOT NULL,
    card_id integer NOT NULL,
    transaction_id integer,
    purchase_date date NOT NULL,
    total_amount double precision NOT NULL,
    category character varying(100) NOT NULL,
    description text,
    installments integer,
    has_financing boolean,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    currency character varying(3) DEFAULT 'ARS'::character varying,
    exchange_rate double precision,
    amount_in_pesos double precision,
    billing_date date,
    movement_type character varying(20) NOT NULL,
    cash_advance_fee double precision NOT NULL,
    derived_debt_id integer,
    CONSTRAINT ck_cc_purchase_cash_advance_fee_non_negative CHECK ((cash_advance_fee >= (0)::double precision)),
    CONSTRAINT ck_cc_purchase_movement_type CHECK (((movement_type)::text = ANY (ARRAY[('normal'::character varying)::text, ('cash_advance'::character varying)::text])))
);


--
-- Name: credit_card_purchases_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.credit_card_purchases_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: credit_card_purchases_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.credit_card_purchases_id_seq OWNED BY public.credit_card_purchases.id;


--
-- Name: credit_card_statements; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.credit_card_statements (
    id integer NOT NULL,
    card_id integer NOT NULL,
    period_start date NOT NULL,
    period_end date NOT NULL,
    statement_date date NOT NULL,
    due_date date NOT NULL,
    previous_balance double precision,
    total_purchases double precision,
    total_installments double precision,
    total_interest double precision,
    total_fees double precision,
    total_taxes double precision,
    total_credits double precision,
    total_amount double precision NOT NULL,
    minimum_payment double precision,
    paid_amount double precision,
    status public.statementstatus,
    payment_date date,
    notes text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: credit_card_statements_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.credit_card_statements_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: credit_card_statements_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.credit_card_statements_id_seq OWNED BY public.credit_card_statements.id;


--
-- Name: credit_cards; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.credit_cards (
    id integer NOT NULL,
    user_id integer,
    card_name character varying(100) NOT NULL,
    bank_name character varying(100) NOT NULL,
    closing_day integer NOT NULL,
    due_day integer NOT NULL,
    currency character varying(3),
    credit_limit double precision,
    is_active boolean,
    notes text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: credit_cards_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.credit_cards_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: credit_cards_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.credit_cards_id_seq OWNED BY public.credit_cards.id;


--
-- Name: debt_payments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.debt_payments (
    id integer NOT NULL,
    debt_record_id integer NOT NULL,
    transaction_id integer,
    payment_date date NOT NULL,
    amount double precision NOT NULL,
    notes text,
    created_at timestamp without time zone
);


--
-- Name: debt_payments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.debt_payments_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: debt_payments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.debt_payments_id_seq OWNED BY public.debt_payments.id;


--
-- Name: debt_records; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.debt_records (
    id integer NOT NULL,
    user_id integer NOT NULL,
    debt_name character varying(120) NOT NULL,
    debt_type public.debttype NOT NULL,
    creditor character varying(120),
    currency character varying(3) DEFAULT 'ARS'::character varying NOT NULL,
    principal_amount double precision NOT NULL,
    outstanding_amount double precision NOT NULL,
    annual_interest_rate double precision,
    start_date date,
    due_date date,
    status public.debtrecordstatus DEFAULT 'ACTIVA'::public.debtrecordstatus NOT NULL,
    notes text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    debt_source character varying(50),
    total_installments double precision,
    current_installment double precision,
    pending_installments double precision,
    installment_mode character varying(20) DEFAULT 'FIXED'::character varying NOT NULL,
    base_salary double precision,
    installment_salary_percent double precision,
    salary_increase_percent double precision,
    salary_increase_interval_months integer
);


--
-- Name: debt_records_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.debt_records_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: debt_records_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.debt_records_id_seq OWNED BY public.debt_records.id;


--
-- Name: installment_plans; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.installment_plans (
    id integer NOT NULL,
    purchase_id integer NOT NULL,
    budget_item_id integer,
    total_amount double precision NOT NULL,
    number_of_installments integer NOT NULL,
    interest_rate double precision,
    start_date date NOT NULL,
    plan_type public.installmentplantype,
    notes text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: installment_plans_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.installment_plans_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: installment_plans_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.installment_plans_id_seq OWNED BY public.installment_plans.id;


--
-- Name: installment_schedule; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.installment_schedule (
    id integer NOT NULL,
    plan_id integer NOT NULL,
    installment_number integer NOT NULL,
    due_date date NOT NULL,
    principal_amount double precision NOT NULL,
    interest_amount double precision,
    total_installment_amount double precision NOT NULL,
    status public.installmentstatus,
    paid_date date,
    payment_transaction_id integer,
    notes text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: installment_schedule_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.installment_schedule_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: installment_schedule_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.installment_schedule_id_seq OWNED BY public.installment_schedule.id;


--
-- Name: month_closings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.month_closings (
    id integer NOT NULL,
    year integer NOT NULL,
    month integer NOT NULL,
    total_ingresos double precision NOT NULL,
    total_gastos double precision NOT NULL,
    balance double precision NOT NULL,
    carry_over_transaction_id integer,
    closed_by character varying(100),
    closed_at timestamp without time zone,
    user_id integer
);


--
-- Name: month_closings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.month_closings_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: month_closings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.month_closings_id_seq OWNED BY public.month_closings.id;


--
-- Name: monthly_balances; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.monthly_balances (
    id integer NOT NULL,
    user_id integer NOT NULL,
    source_month character varying(7) NOT NULL,
    target_month character varying(7) NOT NULL,
    balance_amount double precision NOT NULL,
    balance_type character varying(20) NOT NULL,
    carryover_date timestamp without time zone NOT NULL,
    transaction_id integer,
    created_at timestamp without time zone
);


--
-- Name: monthly_balances_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.monthly_balances_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: monthly_balances_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.monthly_balances_id_seq OWNED BY public.monthly_balances.id;


--
-- Name: monthly_period_events; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.monthly_period_events (
    id integer NOT NULL,
    monthly_period_id integer NOT NULL,
    user_id integer,
    username character varying(100),
    event_type public.monthperiodeventtype NOT NULL,
    occurred_at timestamp without time zone NOT NULL,
    reason text,
    created_at timestamp without time zone
);


--
-- Name: monthly_period_events_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.monthly_period_events_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: monthly_period_events_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.monthly_period_events_id_seq OWNED BY public.monthly_period_events.id;


--
-- Name: monthly_period_snapshots; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.monthly_period_snapshots (
    id integer NOT NULL,
    monthly_period_id integer NOT NULL,
    snapshot_at timestamp without time zone NOT NULL,
    total_expenses double precision NOT NULL,
    total_income double precision NOT NULL,
    net_balance double precision NOT NULL,
    transaction_count integer NOT NULL,
    created_by integer,
    created_at timestamp without time zone
);


--
-- Name: monthly_period_snapshots_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.monthly_period_snapshots_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: monthly_period_snapshots_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.monthly_period_snapshots_id_seq OWNED BY public.monthly_period_snapshots.id;


--
-- Name: monthly_periods; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.monthly_periods (
    id integer NOT NULL,
    year_month character varying(7) NOT NULL,
    status public.monthperiodstatus NOT NULL,
    closed_at timestamp without time zone,
    closed_by integer,
    reopened_at timestamp without time zone,
    reopened_by integer,
    reopen_reason text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    user_id integer
);


--
-- Name: monthly_periods_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.monthly_periods_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: monthly_periods_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.monthly_periods_id_seq OWNED BY public.monthly_periods.id;


--
-- Name: permissions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.permissions (
    id integer NOT NULL,
    code character varying(50) NOT NULL,
    description character varying(255),
    module character varying(50) NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: permissions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.permissions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: permissions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.permissions_id_seq OWNED BY public.permissions.id;


--
-- Name: refresh_tokens; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.refresh_tokens (
    id integer NOT NULL,
    user_id integer NOT NULL,
    token_hash character varying(255) NOT NULL,
    expires_at timestamp without time zone NOT NULL,
    revoked_at timestamp without time zone,
    created_at timestamp without time zone,
    ip_address character varying(45),
    user_agent character varying(500)
);


--
-- Name: refresh_tokens_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.refresh_tokens_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: refresh_tokens_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.refresh_tokens_id_seq OWNED BY public.refresh_tokens.id;


--
-- Name: role_permissions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.role_permissions (
    role_id integer NOT NULL,
    permission_id integer NOT NULL
);


--
-- Name: roles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.roles (
    id integer NOT NULL,
    name character varying(50) NOT NULL,
    description character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: roles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.roles_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: roles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.roles_id_seq OWNED BY public.roles.id;


--
-- Name: test_123; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.test_123 (
    id integer
);


--
-- Name: transactions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.transactions (
    id integer NOT NULL,
    "timestamp" timestamp without time zone,
    date character varying NOT NULL,
    type public.transactiontype NOT NULL,
    amount double precision NOT NULL,
    necessity public.necessitytype NOT NULL,
    payment_method character varying NOT NULL,
    detail text,
    created_at timestamp without time zone,
    debt_id integer,
    assignment_status public.assignmentstatus DEFAULT 'ASIGNADA_MANUAL'::public.assignmentstatus,
    category_id integer NOT NULL,
    user_id integer
);


--
-- Name: transactions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.transactions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: transactions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.transactions_id_seq OWNED BY public.transactions.id;


--
-- Name: transactions_demo; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.transactions_demo (
    id integer DEFAULT nextval('public.transactions_id_seq'::regclass) NOT NULL,
    "timestamp" timestamp without time zone,
    date character varying NOT NULL,
    type public.transactiontype NOT NULL,
    amount double precision NOT NULL,
    necessity public.necessitytype NOT NULL,
    payment_method character varying NOT NULL,
    detail character varying(50),
    created_at timestamp without time zone,
    debt_id integer,
    assignment_status public.assignmentstatus DEFAULT 'ASIGNADA_MANUAL'::public.assignmentstatus,
    category_id integer NOT NULL
);


--
-- Name: user_roles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_roles (
    user_id integer NOT NULL,
    role_id integer NOT NULL
);


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id integer NOT NULL,
    username character varying NOT NULL,
    hashed_password character varying NOT NULL,
    created_at timestamp without time zone,
    email character varying(255) NOT NULL,
    first_name character varying(100),
    last_name character varying(100),
    is_active boolean DEFAULT true NOT NULL,
    is_locked boolean DEFAULT false NOT NULL,
    failed_login_attempts integer DEFAULT 0 NOT NULL,
    force_password_change boolean DEFAULT false NOT NULL,
    last_login_at timestamp without time zone,
    password_changed_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: app_settings id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.app_settings ALTER COLUMN id SET DEFAULT nextval('public.app_settings_id_seq26'::regclass);


--
-- Name: audit_logs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.audit_logs ALTER COLUMN id SET DEFAULT nextval('public.audit_logs_id_seq'::regclass);


--
-- Name: bank_accounts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bank_accounts ALTER COLUMN id SET DEFAULT nextval('public.bank_accounts_id_seq'::regclass);


--
-- Name: budget_items id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.budget_items ALTER COLUMN id SET DEFAULT nextval('public.budget_items_id_seq'::regclass);


--
-- Name: categories id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.categories ALTER COLUMN id SET DEFAULT nextval('public.categories_id_seq'::regclass);


--
-- Name: credit_card_payments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.credit_card_payments ALTER COLUMN id SET DEFAULT nextval('public.credit_card_payments_id_seq'::regclass);


--
-- Name: credit_card_period_configs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.credit_card_period_configs ALTER COLUMN id SET DEFAULT nextval('public.credit_card_period_configs_id_seq'::regclass);


--
-- Name: credit_card_purchases id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.credit_card_purchases ALTER COLUMN id SET DEFAULT nextval('public.credit_card_purchases_id_seq'::regclass);


--
-- Name: credit_card_statements id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.credit_card_statements ALTER COLUMN id SET DEFAULT nextval('public.credit_card_statements_id_seq'::regclass);


--
-- Name: credit_cards id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.credit_cards ALTER COLUMN id SET DEFAULT nextval('public.credit_cards_id_seq'::regclass);


--
-- Name: debt_payments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.debt_payments ALTER COLUMN id SET DEFAULT nextval('public.debt_payments_id_seq'::regclass);


--
-- Name: debt_records id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.debt_records ALTER COLUMN id SET DEFAULT nextval('public.debt_records_id_seq'::regclass);


--
-- Name: installment_plans id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.installment_plans ALTER COLUMN id SET DEFAULT nextval('public.installment_plans_id_seq'::regclass);


--
-- Name: installment_schedule id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.installment_schedule ALTER COLUMN id SET DEFAULT nextval('public.installment_schedule_id_seq'::regclass);


--
-- Name: month_closings id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.month_closings ALTER COLUMN id SET DEFAULT nextval('public.month_closings_id_seq'::regclass);


--
-- Name: monthly_balances id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.monthly_balances ALTER COLUMN id SET DEFAULT nextval('public.monthly_balances_id_seq'::regclass);


--
-- Name: monthly_period_events id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.monthly_period_events ALTER COLUMN id SET DEFAULT nextval('public.monthly_period_events_id_seq'::regclass);


--
-- Name: monthly_period_snapshots id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.monthly_period_snapshots ALTER COLUMN id SET DEFAULT nextval('public.monthly_period_snapshots_id_seq'::regclass);


--
-- Name: monthly_periods id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.monthly_periods ALTER COLUMN id SET DEFAULT nextval('public.monthly_periods_id_seq'::regclass);


--
-- Name: permissions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.permissions ALTER COLUMN id SET DEFAULT nextval('public.permissions_id_seq'::regclass);


--
-- Name: refresh_tokens id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.refresh_tokens ALTER COLUMN id SET DEFAULT nextval('public.refresh_tokens_id_seq'::regclass);


--
-- Name: roles id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.roles ALTER COLUMN id SET DEFAULT nextval('public.roles_id_seq'::regclass);


--
-- Name: transactions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transactions ALTER COLUMN id SET DEFAULT nextval('public.transactions_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Data for Name: alembic_version; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.alembic_version (version_num) FROM stdin;
b2c3d4e5f6a7
\.


--
-- Data for Name: app_settings; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.app_settings (id, key, value, description, updated_at) FROM stdin;
1	dollar_exchange_rate	1400	Cotizacion del dolar (ARS por 1 USD)	2026-03-30 14:01:55.446995
\.


--
-- Data for Name: audit_logs; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.audit_logs (id, user_id, username, action, entity, entity_id, details, ip_address, user_agent, created_at) FROM stdin;
1	1	admin	LOGIN_SUCCESS	\N	\N	\N	127.0.0.1	test	2026-04-08 17:27:00.385884
2	1	admin	LOGIN_SUCCESS	\N	\N	\N	127.0.0.1	curl/8.18.0	2026-04-08 19:31:30.060397
3	1	admin	LOGIN_SUCCESS	\N	\N	\N	127.0.0.1	curl/8.18.0	2026-04-08 19:32:02.166293
4	1	admin	LOGIN_SUCCESS	\N	\N	\N	127.0.0.1	python-requests/2.32.5	2026-04-08 19:32:49.320761
5	1	admin	LOGIN_SUCCESS	\N	\N	\N	127.0.0.1	python-requests/2.32.5	2026-04-08 19:36:21.558369
6	1	admin	LOGIN_SUCCESS	\N	\N	\N	127.0.0.1	python-requests/2.32.5	2026-04-08 19:36:37.47282
7	1	admin	LOGIN_SUCCESS	\N	\N	\N	127.0.0.1	python-requests/2.32.5	2026-04-08 19:37:19.354847
8	1	admin	LOGIN_SUCCESS	\N	\N	\N	127.0.0.1	python-requests/2.32.5	2026-04-08 19:37:36.05572
9	1	admin	LOGIN_FAIL	\N	\N	Bad password (attempt 1)	127.0.0.1	python-requests/2.32.5	2026-04-08 19:37:42.071004
10	1	admin	LOGIN_SUCCESS	\N	\N	\N	127.0.0.1	python-requests/2.32.5	2026-04-08 19:46:31.125404
11	1	admin	LOGIN_SUCCESS	\N	\N	\N	127.0.0.1	python-requests/2.32.5	2026-04-08 19:47:26.817337
12	1	admin	LOGIN_SUCCESS	\N	\N	\N	127.0.0.1	python-requests/2.32.5	2026-04-08 20:08:48.098724
13	1	admin	USER_CREATED	User	2	Created user testuser	127.0.0.1	python-requests/2.32.5	2026-04-08 20:09:04.983833
14	1	admin	LOGIN_FAIL	\N	\N	Bad password (attempt 1)	127.0.0.1	python-requests/2.32.5	2026-04-08 20:09:13.946874
15	1	admin	LOGOUT	\N	\N	\N	127.0.0.1	python-requests/2.32.5	2026-04-08 20:09:15.993907
16	1	admin	LOGIN_SUCCESS	\N	\N	\N	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36	2026-04-09 15:34:21.049561
17	1	admin	LOGIN_SUCCESS	\N	\N	\N	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36	2026-04-09 19:36:25.004458
18	2	testuser	LOGIN_FAIL	\N	\N	Bad password (attempt 1)	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36	2026-04-09 19:37:17.652383
19	1	admin	LOGIN_SUCCESS	\N	\N	\N	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36	2026-04-09 19:37:23.519217
20	1	admin	LOGIN_SUCCESS	\N	\N	\N	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36	2026-04-09 19:50:23.027086
21	1	admin	USER_CREATED	User	3	Created user sergio	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36	2026-04-09 19:51:06.775535
22	3	sergio	LOGIN_SUCCESS	\N	\N	\N	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36	2026-04-09 19:51:23.825695
23	1	admin	LOGIN_FAIL	\N	\N	Bad password (attempt 1)	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-GB) PowerShell/7.5.5	2026-04-10 18:36:23.482947
24	1	admin	LOGIN_SUCCESS	\N	\N	\N	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-GB) PowerShell/7.5.5	2026-04-10 18:37:05.597154
25	1	admin	LOGIN_SUCCESS	\N	\N	\N	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-GB) PowerShell/7.5.5	2026-04-10 18:38:06.365969
26	2	testuser	LOGIN_FAIL	\N	\N	Bad password (attempt 2)	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-GB) PowerShell/7.5.5	2026-04-10 18:38:10.913788
27	1	admin	LOGIN_SUCCESS	\N	\N	\N	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-GB) PowerShell/7.5.5	2026-04-10 18:38:50.289898
28	1	admin	LOGIN_SUCCESS	\N	\N	\N	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-GB) PowerShell/7.5.5	2026-04-10 18:39:27.139354
29	1	admin	LOGIN_SUCCESS	\N	\N	\N	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-GB) PowerShell/7.5.5	2026-04-10 18:40:11.956419
30	1	admin	LOGIN_SUCCESS	\N	\N	\N	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-GB) PowerShell/7.5.5	2026-04-10 18:40:40.028523
31	1	admin	LOGIN_SUCCESS	\N	\N	\N	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-GB) PowerShell/7.5.5	2026-04-10 18:41:11.343838
32	1	admin	LOGIN_SUCCESS	\N	\N	\N	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-GB) PowerShell/7.5.5	2026-04-10 18:43:40.232762
33	1	admin	USER_CREATED	User	4	Created user testuser2	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-GB) PowerShell/7.5.5	2026-04-10 18:43:42.555814
34	4	testuser2	LOGIN_SUCCESS	\N	\N	\N	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-GB) PowerShell/7.5.5	2026-04-10 18:43:59.732915
35	3	sergio	LOGIN_SUCCESS	\N	\N	\N	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36	2026-04-10 18:49:02.318061
36	3	sergio	LOGIN_SUCCESS	\N	\N	\N	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36	2026-04-10 18:49:12.114515
37	1	admin	LOGIN_SUCCESS	\N	\N	\N	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-GB) PowerShell/7.5.5	2026-04-10 19:21:41.713594
38	1	admin	LOGIN_SUCCESS	\N	\N	\N	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-GB) PowerShell/7.5.5	2026-04-10 19:22:23.119247
39	1	admin	LOGIN_SUCCESS	\N	\N	\N	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-GB) PowerShell/7.5.5	2026-04-10 19:26:59.236528
40	4	testuser2	LOGIN_SUCCESS	\N	\N	\N	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-GB) PowerShell/7.5.5	2026-04-10 19:27:13.572842
41	1	admin	LOGIN_SUCCESS	\N	\N	\N	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-GB) PowerShell/7.5.5	2026-04-10 19:27:56.570187
42	3	sergio	LOGIN_SUCCESS	\N	\N	\N	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36	2026-04-13 15:35:58.443478
43	1	admin	LOGIN_SUCCESS	\N	\N	\N	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36	2026-04-13 15:52:56.577305
44	1	admin	LOGIN_SUCCESS	\N	\N	\N	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-GB) PowerShell/7.5.5	2026-04-13 18:42:27.075186
45	3	sergio	LOGIN_FAIL	\N	\N	Bad password (attempt 1)	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36	2026-04-13 22:37:57.443947
46	3	sergio	LOGIN_SUCCESS	\N	\N	\N	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36	2026-04-13 22:38:08.178782
47	1	admin	LOGIN_SUCCESS	\N	\N	\N	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36	2026-04-14 01:43:28.699713
48	3	sergio	LOGIN_SUCCESS	\N	\N	\N	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	2026-04-16 13:44:43.572556
49	3	sergio	LOGIN_SUCCESS	\N	\N	\N	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-GB) PowerShell/7.5.5	2026-04-16 13:58:12.955257
50	3	sergio	LOGIN_SUCCESS	\N	\N	\N	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-GB) PowerShell/7.5.5	2026-04-16 14:07:26.829528
51	3	sergio	LOGIN_SUCCESS	\N	\N	\N	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-GB) PowerShell/7.5.5	2026-04-16 14:08:37.617012
52	3	sergio	LOGIN_SUCCESS	\N	\N	\N	127.0.0.1	python-requests/2.32.3	2026-04-16 15:04:17.52142
53	3	sergio	LOGIN_SUCCESS	\N	\N	\N	127.0.0.1	python-requests/2.32.3	2026-04-16 15:04:52.208391
54	3	sergio	LOGIN_SUCCESS	\N	\N	\N	127.0.0.1	python-requests/2.32.3	2026-04-16 17:47:11.415762
55	3	sergio	LOGIN_SUCCESS	\N	\N	\N	127.0.0.1	python-requests/2.32.3	2026-04-16 17:47:22.572391
56	3	sergio	LOGIN_SUCCESS	\N	\N	\N	127.0.0.1	python-requests/2.32.3	2026-04-16 17:48:03.955736
57	3	sergio	LOGIN_SUCCESS	\N	\N	\N	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	2026-04-20 15:24:20.311267
58	1	admin	LOGIN_SUCCESS	\N	\N	\N	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	2026-04-26 23:15:34.803612
59	3	sergio	LOGIN_SUCCESS	\N	\N	\N	172.22.0.1	python-requests/2.32.5	2026-04-27 13:38:31.39148
60	3	sergio	LOGIN_SUCCESS	\N	\N	\N	172.22.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	2026-04-27 13:38:57.710217
61	3	sergio	LOGIN_SUCCESS	\N	\N	\N	172.22.0.1	python-requests/2.32.5	2026-04-27 14:15:26.089543
62	3	sergio	LOGIN_SUCCESS	\N	\N	\N	172.22.0.1	python-requests/2.32.5	2026-05-01 20:36:21.33807
63	3	sergio	LOGIN_SUCCESS	\N	\N	\N	172.22.0.1	python-requests/2.32.5	2026-05-01 20:36:39.602336
64	3	sergio	LOGIN_SUCCESS	\N	\N	\N	172.22.0.1	python-requests/2.32.5	2026-05-01 20:46:22.630825
65	3	sergio	LOGIN_SUCCESS	\N	\N	\N	172.22.0.1	python-requests/2.32.5	2026-05-02 00:09:29.759396
66	3	sergio	LOGIN_SUCCESS	\N	\N	\N	172.22.0.1	python-requests/2.32.5	2026-05-02 00:19:45.34909
67	3	sergio	MONTH_CLOSED	monthly_period	1	Mes 2026-04 cerrado. Snapshot: ingresos=22788762.24, egresos=22510985.38999999, balance=277776.85000000894, transacciones=208	\N	\N	2026-05-02 22:02:31.541474
68	3	sergio	LOGOUT	\N	\N	\N	172.22.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	2026-05-02 22:19:49.365735
69	1	admin	LOGIN_SUCCESS	\N	\N	\N	172.22.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	2026-05-02 22:20:01.486983
70	1	admin	LOGOUT	\N	\N	\N	172.22.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	2026-05-03 19:23:49.562383
71	3	sergio	LOGIN_SUCCESS	\N	\N	\N	172.22.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	2026-05-03 19:24:07.310759
72	3	sergio	MONTH_CLOSED	monthly_period	2	Mes 2026-04 cerrado. Snapshot: ingresos=9791646.24, egresos=9772652.010000002, balance=18994.229999998584, transacciones=110	\N	\N	2026-05-03 19:24:50.924872
73	1	admin	LOGIN_SUCCESS	\N	\N	\N	172.22.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	2026-05-04 00:10:27.752128
74	3	sergio	LOGOUT	\N	\N	\N	172.22.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	2026-05-04 21:27:04.391038
75	1	admin	LOGIN_SUCCESS	\N	\N	\N	172.22.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	2026-05-04 21:31:47.553757
76	1	admin	LOGOUT	\N	\N	\N	172.22.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	2026-05-04 22:37:19.67867
77	3	sergio	LOGIN_FAIL	\N	\N	Bad password (attempt 1)	172.22.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	2026-05-04 22:37:33.837534
78	3	sergio	LOGIN_SUCCESS	\N	\N	\N	172.22.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	2026-05-04 22:37:48.917053
79	1	admin	LOGIN_SUCCESS	\N	\N	\N	172.26.0.1	Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-GB) PowerShell/7.5.5	2026-05-06 17:37:06.126934
80	3	sergio	LOGIN_FAIL	\N	\N	Bad password (attempt 1)	172.26.0.1	Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-GB) PowerShell/7.5.5	2026-05-06 17:37:06.423155
81	1	admin	LOGIN_SUCCESS	\N	\N	\N	172.26.0.1	Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-GB) PowerShell/7.5.5	2026-05-06 17:37:21.048987
82	1	admin	PASSWORD_RESET	User	3	\N	172.26.0.1	Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-GB) PowerShell/7.5.5	2026-05-06 17:37:21.389828
83	3	sergio	LOGIN_SUCCESS	\N	\N	\N	172.26.0.1	Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-GB) PowerShell/7.5.5	2026-05-06 17:37:21.811259
84	3	sergio	LOGIN_SUCCESS	\N	\N	\N	172.26.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	2026-05-06 17:37:59.062532
85	3	sergio	LOGIN_SUCCESS	\N	\N	\N	172.26.0.1	Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-GB) PowerShell/7.5.5	2026-05-06 18:56:40.729973
86	3	sergio	LOGIN_SUCCESS	\N	\N	\N	172.26.0.1	Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-GB) PowerShell/7.5.5	2026-05-06 19:32:10.183529
87	3	sergio	MONTH_OPENED	monthly_period	3	Mes 2026-05 abierto. Carryover: None. ├ìtems clonados: 0	\N	\N	2026-05-06 19:32:10.443779
88	3	sergio	LOGIN_SUCCESS	\N	\N	\N	172.26.0.1	Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-GB) PowerShell/7.5.5	2026-05-06 20:27:12.409544
89	3	sergio	LOGIN_SUCCESS	\N	\N	\N	172.26.0.1	Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-GB) PowerShell/7.5.5	2026-05-06 20:30:02.21746
90	3	sergio	LOGIN_SUCCESS	\N	\N	\N	172.26.0.1	Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-GB) PowerShell/7.5.5	2026-05-06 20:48:44.143286
91	3	sergio	LOGIN_SUCCESS	\N	\N	\N	172.26.0.1	Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-GB) PowerShell/7.5.5	2026-05-06 21:00:09.097375
92	3	sergio	LOGOUT	\N	\N	\N	172.26.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	2026-05-06 21:04:53.615032
93	3	sergio	LOGIN_SUCCESS	\N	\N	\N	172.26.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	2026-05-06 21:04:55.533103
94	3	sergio	LOGIN_SUCCESS	\N	\N	\N	172.26.0.1	Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-GB) PowerShell/7.5.5	2026-05-06 21:08:39.891392
95	3	sergio	LOGIN_SUCCESS	\N	\N	\N	172.26.0.1	Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-GB) PowerShell/7.5.5	2026-05-06 21:08:50.033678
96	3	sergio	LOGIN_SUCCESS	\N	\N	\N	172.26.0.1	Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-GB) PowerShell/7.5.5	2026-05-06 21:08:57.138684
97	3	sergio	MONTH_CLOSED	monthly_period	3	Mes 2026-05 cerrado. Snapshot: ingresos=0.0, egresos=0.0, balance=0.0, transacciones=0	\N	\N	2026-05-06 21:17:25.604057
98	3	sergio	MONTH_REOPENED	monthly_period	3	Mes 2026-05 reabierto. Motivo: Reapertura desde panel principal	\N	\N	2026-05-06 21:17:38.401112
100	3	sergio	MONTH_REOPENED	monthly_period	3	Mes 2026-05 reabierto. Motivo: Prueba de reapertura.	\N	\N	2026-05-06 21:19:09.719231
99	3	sergio	MONTH_CLOSED	monthly_period	3	Mes 2026-05 cerrado. Snapshot: ingresos=0.0, egresos=0.0, balance=0.0, transacciones=0	\N	\N	2026-05-06 21:18:45.464908
101	3	sergio	MONTH_OPENED	monthly_period	4	Mes 2026-06 abierto. Carryover: None. ├ìtems clonados: 0	\N	\N	2026-05-06 22:20:18.361814
102	3	sergio	MONTH_OPENED	monthly_period	5	Mes 2026-06 abierto. Carryover: None. ├ìtems clonados: 0	\N	\N	2026-05-06 23:07:33.424669
103	3	sergio	MONTH_CLOSED	monthly_period	5	Mes 2026-06 cerrado. Snapshot: ingresos=0.0, egresos=0.0, balance=0.0, transacciones=0	\N	\N	2026-05-06 23:13:51.931614
104	3	sergio	MONTH_REOPENED	monthly_period	5	Mes 2026-06 reabierto. Motivo: Reapertura desde panel principal	\N	\N	2026-05-06 23:13:57.321416
105	3	sergio	MONTH_CLOSED	monthly_period	3	Mes 2026-05 cerrado. Snapshot: ingresos=18994.229999998584, egresos=0.0, balance=18994.229999998584, transacciones=1	\N	\N	2026-05-06 23:26:19.628418
106	3	sergio	MONTH_OPENED	monthly_period	6	Mes 2026-06 abierto. Carryover: {'source_month': '2026-05', 'net_balance': 18994.229999998584, 'total_income': 18994.229999998584, 'total_expenses': 0.0, 'transaction_id': 1696}. ├ìtems clonados: 0	\N	\N	2026-05-06 23:26:25.338881
107	3	sergio	MONTH_CLOSED	monthly_period	6	Mes 2026-06 cerrado. Snapshot: ingresos=18994.229999998584, egresos=0.0, balance=18994.229999998584, transacciones=1	\N	\N	2026-05-06 23:26:35.625531
108	3	sergio	MONTH_REOPENED	monthly_period	3	Mes 2026-05 reabierto. Motivo: reapertura de prueba.	\N	\N	2026-05-06 23:27:18.260021
109	3	sergio	MONTH_CLOSED	monthly_period	3	Mes 2026-05 cerrado. Snapshot: ingresos=18994.229999998584, egresos=0.0, balance=18994.229999998584, transacciones=1	\N	\N	2026-05-06 23:27:31.384582
110	3	sergio	MONTH_REOPENED	monthly_period	3	Mes 2026-05 reabierto. Motivo: Mes en curso	\N	\N	2026-05-06 23:27:55.912071
111	1	admin	LOGIN_SUCCESS	\N	\N	\N	172.26.0.1	Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-GB) PowerShell/7.5.5	2026-05-07 14:08:41.104091
112	1	admin	LOGIN_SUCCESS	\N	\N	\N	172.26.0.1	Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-GB) PowerShell/7.5.5	2026-05-07 14:22:32.704436
113	1	admin	LOGIN_SUCCESS	\N	\N	\N	172.26.0.1	Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-GB) PowerShell/7.5.5	2026-05-07 15:06:25.703517
114	1	admin	LOGIN_SUCCESS	\N	\N	\N	172.26.0.1	Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-GB) PowerShell/7.5.5	2026-05-07 15:06:54.450672
115	1	admin	LOGIN_SUCCESS	\N	\N	\N	172.26.0.1	Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-GB) PowerShell/7.5.5	2026-05-07 15:13:10.237491
116	1	admin	LOGIN_SUCCESS	\N	\N	\N	172.26.0.1	Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-GB) PowerShell/7.5.5	2026-05-07 15:13:59.319868
117	3	sergio	LOGIN_FAIL	\N	\N	Bad password (attempt 1)	172.26.0.1	Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-GB) PowerShell/7.5.5	2026-05-07 15:16:18.487223
118	1	admin	LOGIN_SUCCESS	\N	\N	\N	172.26.0.1	Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-GB) PowerShell/7.5.5	2026-05-07 15:16:18.96134
119	1	admin	LOGIN_SUCCESS	\N	\N	\N	172.26.0.1	Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-GB) PowerShell/7.5.5	2026-05-07 15:20:19.723758
120	1	admin	LOGIN_SUCCESS	\N	\N	\N	172.26.0.1	Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-GB) PowerShell/7.5.5	2026-05-07 17:54:05.546302
121	3	sergio	LOGIN_SUCCESS	\N	\N	\N	172.26.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	2026-05-08 20:34:01.129834
122	3	sergio	LOGIN_FAIL	\N	\N	Bad password (attempt 1)	172.26.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	2026-05-11 00:13:53.903281
123	3	sergio	LOGIN_FAIL	\N	\N	Bad password (attempt 2)	172.26.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	2026-05-11 00:14:00.234267
124	3	sergio	LOGIN_FAIL	\N	\N	Bad password (attempt 3)	172.26.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	2026-05-11 00:14:07.173939
125	3	sergio	LOGIN_FAIL	\N	\N	Bad password (attempt 4)	172.26.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	2026-05-11 00:14:16.648513
126	3	sergio	LOGIN_FAIL	\N	\N	Bad password (attempt 5)	172.26.0.1	Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-GB) PowerShell/7.5.5	2026-05-11 00:15:30.255136
127	1	admin	LOGIN_SUCCESS	\N	\N	\N	172.26.0.1	Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-GB) PowerShell/7.5.5	2026-05-11 00:15:30.882885
128	1	admin	LOGIN_SUCCESS	\N	\N	\N	172.26.0.1	Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-GB) PowerShell/7.5.5	2026-05-11 00:16:07.544704
129	1	admin	USER_UNLOCKED	User	3	\N	172.26.0.1	Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-GB) PowerShell/7.5.5	2026-05-11 00:16:07.587689
130	3	sergio	LOGIN_FAIL	\N	\N	Bad password (attempt 1)	172.26.0.1	Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-GB) PowerShell/7.5.5	2026-05-11 00:16:07.960271
131	1	admin	LOGIN_SUCCESS	\N	\N	\N	172.26.0.1	Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-GB) PowerShell/7.5.5	2026-05-11 00:16:16.473604
132	1	admin	PASSWORD_RESET	User	3	\N	172.26.0.1	Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-GB) PowerShell/7.5.5	2026-05-11 00:16:16.683208
133	3	sergio	LOGIN_SUCCESS	\N	\N	\N	172.26.0.1	Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-GB) PowerShell/7.5.5	2026-05-11 00:16:17.063644
134	3	sergio	LOGIN_SUCCESS	\N	\N	\N	172.26.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	2026-05-11 00:18:01.208712
135	3	sergio	LOGIN_FAIL	\N	\N	Bad password (attempt 1)	172.26.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	2026-05-11 00:30:22.589142
136	3	sergio	LOGIN_SUCCESS	\N	\N	\N	172.26.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	2026-05-11 00:30:33.206163
137	1	admin	LOGIN_SUCCESS	\N	\N	\N	172.26.0.1	Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-GB) PowerShell/7.5.5	2026-05-11 13:38:49.308416
138	1	admin	MONTH_OPENED	monthly_period	7	Mes 2026-05 abierto. Carryover: None. ├ìtems clonados: 0	\N	\N	2026-05-11 13:38:49.92377
139	1	admin	LOGIN_SUCCESS	\N	\N	\N	172.26.0.1	Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-GB) PowerShell/7.5.5	2026-05-11 13:39:33.02597
140	3	sergio	LOGOUT	\N	\N	\N	172.26.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	2026-05-11 19:05:30.994834
141	1	admin	LOGIN_SUCCESS	\N	\N	\N	172.26.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	2026-05-11 19:05:43.434581
142	1	admin	USER_DEACTIVATED	User	4	\N	172.26.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	2026-05-11 19:06:03.629328
143	1	admin	USER_CREATED	User	5	Created user qa_tester	172.26.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	2026-05-11 19:13:31.640874
150	5	qa_tester	MONTH_OPENED	monthly_period	8	Mes 2026-04 abierto. Carryover: None. ├ìtems clonados: 0	\N	\N	2026-05-11 19:14:54.031266
154	5	qa_tester	LOGIN_SUCCESS	\N	\N	\N	172.26.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	2026-05-11 19:40:01.082346
144	1	admin	USER_UPDATED	User	5	\N	172.26.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	2026-05-11 19:13:52.890575
145	1	admin	USER_UPDATED	User	1	\N	172.26.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	2026-05-11 19:14:04.005486
146	1	admin	USER_UPDATED	User	2	\N	172.26.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	2026-05-11 19:14:12.816526
147	1	admin	USER_UPDATED	User	4	\N	172.26.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	2026-05-11 19:14:22.204402
148	1	admin	LOGOUT	\N	\N	\N	172.26.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	2026-05-11 19:14:25.836632
149	5	qa_tester	LOGIN_SUCCESS	\N	\N	\N	172.26.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	2026-05-11 19:14:29.93673
151	5	qa_tester	LOGIN_SUCCESS	\N	\N	\N	172.26.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	2026-05-11 19:36:14.636096
152	5	qa_tester	LOGIN_FAIL	\N	\N	Bad password (attempt 1)	172.26.0.1	Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-GB) PowerShell/7.5.5	2026-05-11 19:39:07.933686
153	5	qa_tester	LOGOUT	\N	\N	\N	172.26.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	2026-05-11 19:39:59.242273
155	5	qa_tester	MONTH_CLOSED	monthly_period	8	Mes 2026-04 cerrado. Snapshot: ingresos=0.0, egresos=0.0, balance=0.0, transacciones=0	\N	\N	2026-05-11 19:42:19.684135
156	5	qa_tester	MONTH_OPENED	monthly_period	9	Mes 2026-05 abierto. Carryover: {'source_month': '2026-04', 'net_balance': 0.0, 'total_income': 0.0, 'total_expenses': 0.0, 'transaction_id': 1699}. ├ìtems clonados: 2	\N	\N	2026-05-11 19:42:41.89432
157	1	admin	LOGIN_SUCCESS	\N	\N	\N	172.26.0.1	Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-GB) PowerShell/7.5.5	2026-05-11 19:45:08.955945
158	5	qa_tester	LOGIN_FAIL	\N	\N	Bad password (attempt 1)	172.26.0.1	Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-GB) PowerShell/7.5.5	2026-05-11 19:45:09.173742
159	1	admin	LOGIN_SUCCESS	\N	\N	\N	172.26.0.1	Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-GB) PowerShell/7.5.5	2026-05-11 19:46:01.549631
160	1	admin	LOGIN_SUCCESS	\N	\N	\N	172.26.0.1	Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-GB) PowerShell/7.5.5	2026-05-11 19:46:09.426756
161	5	qa_tester	MONTH_REOPENED	monthly_period	8	Mes 2026-04 reabierto. Motivo: para probar	\N	\N	2026-05-12 18:38:34.225654
162	5	qa_tester	LOGOUT	\N	\N	\N	172.26.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	2026-05-12 18:47:15.205651
163	3	sergio	LOGIN_SUCCESS	\N	\N	\N	172.26.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	2026-05-12 18:47:22.887774
164	1	admin	LOGIN_SUCCESS	\N	\N	\N	172.26.0.1	Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-GB) PowerShell/7.5.5	2026-05-13 15:32:52.487015
165	1	admin	LOGIN_SUCCESS	\N	\N	\N	172.26.0.1	Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-GB) PowerShell/7.5.5	2026-05-13 15:32:56.965882
166	1	admin	LOGIN_SUCCESS	\N	\N	\N	172.26.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Code/1.119.0 Chrome/142.0.7444.265 Electron/39.8.8 Safari/537.36	2026-05-13 15:34:21.581048
167	1	admin	LOGIN_SUCCESS	\N	\N	\N	172.26.0.1	Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-GB) PowerShell/7.5.5	2026-05-13 15:35:38.872844
168	1	admin	LOGIN_SUCCESS	\N	\N	\N	172.26.0.1	Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-GB) PowerShell/7.5.5	2026-05-13 15:38:21.823489
169	1	admin	LOGIN_SUCCESS	\N	\N	\N	172.26.0.1	Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-GB) PowerShell/7.5.5	2026-05-13 15:38:51.416575
170	1	admin	LOGIN_SUCCESS	\N	\N	\N	172.26.0.1	Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-GB) PowerShell/7.5.5	2026-05-13 15:38:56.686314
171	3	sergio	LOGIN_FAIL	\N	\N	Bad password (attempt 1)	172.26.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	2026-05-13 17:55:41.089323
172	3	sergio	LOGIN_FAIL	\N	\N	Bad password (attempt 2)	172.26.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	2026-05-13 17:55:56.359088
173	3	sergio	LOGIN_SUCCESS	\N	\N	\N	172.26.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	2026-05-13 17:56:08.364946
174	3	sergio	LOGIN_SUCCESS	\N	\N	\N	172.25.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	2026-05-22 16:47:07.892118
175	3	sergio	LOGIN_SUCCESS	\N	\N	\N	172.25.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	2026-05-26 21:31:09.511348
176	1	admin	LOGIN_SUCCESS	\N	\N	\N	172.25.0.1	python-requests/2.32.3	2026-05-27 00:40:33.833473
177	1	admin	LOGIN_SUCCESS	\N	\N	\N	172.25.0.1	python-requests/2.32.3	2026-05-27 15:04:07.395076
178	1	admin	LOGIN_SUCCESS	\N	\N	\N	172.25.0.1	python-requests/2.32.3	2026-05-28 01:19:51.934716
179	1	admin	LOGIN_SUCCESS	\N	\N	\N	172.25.0.1	python-requests/2.32.3	2026-05-28 01:26:23.702427
180	1	admin	LOGIN_SUCCESS	\N	\N	\N	127.0.0.1	python-requests/2.32.3	2026-05-28 01:34:24.177298
181	1	admin	LOGIN_SUCCESS	\N	\N	\N	127.0.0.1	python-requests/2.32.3	2026-05-28 01:35:24.024259
182	3	sergio	LOGOUT	\N	\N	\N	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	2026-05-28 13:40:57.031902
183	3	sergio	LOGIN_SUCCESS	\N	\N	\N	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	2026-05-28 13:40:58.701302
184	3	sergio	LOGIN_FAIL	\N	\N	Bad password (attempt 1)	127.0.0.1	python-requests/2.32.3	2026-05-28 13:46:26.652845
185	1	admin	LOGIN_SUCCESS	\N	\N	\N	127.0.0.1	python-requests/2.32.3	2026-05-28 13:50:23.690715
186	1	admin	LOGIN_SUCCESS	\N	\N	\N	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-GB) PowerShell/7.5.5	2026-05-28 15:24:13.958825
187	3	sergio	LOGIN_SUCCESS	\N	\N	\N	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	2026-05-28 15:27:17.365761
188	1	admin	LOGIN_SUCCESS	\N	\N	\N	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-GB) PowerShell/7.5.5	2026-05-28 15:30:33.24079
189	1	admin	LOGIN_SUCCESS	\N	\N	\N	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-GB) PowerShell/7.5.5	2026-05-28 15:30:51.83113
190	1	admin	LOGIN_SUCCESS	\N	\N	\N	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-GB) PowerShell/7.5.5	2026-05-28 15:45:55.805536
191	1	admin	LOGIN_SUCCESS	\N	\N	\N	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-GB) PowerShell/7.5.5	2026-05-28 15:48:34.272895
192	1	admin	LOGIN_SUCCESS	\N	\N	\N	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-GB) PowerShell/7.5.5	2026-05-28 15:57:32.765679
193	1	admin	LOGIN_SUCCESS	\N	\N	\N	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-GB) PowerShell/7.5.5	2026-05-28 16:03:37.05076
194	3	sergio	LOGOUT	\N	\N	\N	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	2026-06-01 14:24:27.168035
195	3	sergio	LOGIN_SUCCESS	\N	\N	\N	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	2026-06-01 14:24:28.907647
196	1	admin	LOGIN_SUCCESS	\N	\N	\N	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-GB) PowerShell/7.5.5	2026-06-01 14:55:39.465714
197	1	admin	LOGIN_SUCCESS	\N	\N	\N	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-GB) PowerShell/7.5.5	2026-06-01 14:55:55.703505
198	1	admin	LOGIN_SUCCESS	\N	\N	\N	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-GB) PowerShell/7.5.5	2026-06-01 15:11:41.500009
199	3	sergio	LOGIN_SUCCESS	\N	\N	\N	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	2026-06-01 16:06:45.114996
200	1	admin	LOGIN_SUCCESS	\N	\N	\N	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-GB) PowerShell/7.5.5	2026-06-01 16:31:59.894224
201	1	admin	LOGIN_SUCCESS	\N	\N	\N	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-GB) PowerShell/7.5.5	2026-06-01 16:49:19.202376
202	3	sergio	LOGIN_SUCCESS	\N	\N	\N	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	2026-06-01 17:07:14.08721
203	3	sergio	LOGOUT	\N	\N	\N	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	2026-06-01 18:32:16.37418
204	1	admin	LOGIN_SUCCESS	\N	\N	\N	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	2026-06-01 18:32:21.857729
205	1	admin	LOGOUT	\N	\N	\N	172.25.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	2026-06-01 20:10:09.084329
206	2	testuser	LOGIN_SUCCESS	\N	\N	\N	172.25.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	2026-06-01 20:10:24.344487
207	3	sergio	LOGIN_SUCCESS	\N	\N	\N	172.25.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	2026-06-02 20:46:46.032477
208	3	sergio	LOGOUT	\N	\N	\N	172.25.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	2026-06-08 14:10:08.160866
209	1	admin	LOGIN_SUCCESS	\N	\N	\N	172.25.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	2026-06-08 14:10:18.902287
210	1	admin	LOGOUT	\N	\N	\N	172.25.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	2026-06-08 14:10:47.418055
211	3	sergio	LOGIN_SUCCESS	\N	\N	\N	172.25.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	2026-06-08 14:10:53.968702
212	1	admin	LOGIN_SUCCESS	\N	\N	\N	172.25.0.1	python-requests/2.32.3	2026-06-10 12:39:34.150905
213	3	sergio	LOGIN_SUCCESS	\N	\N	\N	172.25.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	2026-06-13 14:39:36.621805
214	3	sergio	LOGIN_SUCCESS	\N	\N	\N	172.25.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	2026-06-29 16:50:58.901988
215	3	sergio	LOGOUT	\N	\N	\N	172.25.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	2026-06-29 16:55:44.171472
216	2	testuser	LOGIN_SUCCESS	\N	\N	\N	172.25.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	2026-06-29 16:55:52.147601
217	2	testuser	LOGOUT	\N	\N	\N	172.25.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	2026-06-29 16:56:30.125884
218	3	sergio	LOGIN_SUCCESS	\N	\N	\N	172.25.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	2026-06-29 16:56:37.012189
219	3	sergio	LOGOUT	\N	\N	\N	172.25.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	2026-06-30 14:37:11.915196
220	3	sergio	LOGIN_SUCCESS	\N	\N	\N	172.25.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	2026-06-30 14:37:17.208649
221	3	sergio	LOGOUT	\N	\N	\N	172.25.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	2026-06-30 14:37:19.845848
222	2	testuser	LOGIN_SUCCESS	\N	\N	\N	172.25.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	2026-06-30 14:37:25.115319
223	2	testuser	LOGIN_FAIL	\N	\N	Bad password (attempt 1)	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-GB) PowerShell/7.5.5	2026-07-01 14:40:48.314605
224	2	testuser	LOGIN_SUCCESS	\N	\N	\N	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	2026-07-01 15:02:46.87972
225	3	sergio	LOGIN_SUCCESS	\N	\N	\N	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	2026-07-06 17:57:24.566927
226	3	sergio	LOGIN_SUCCESS	\N	\N	\N	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	2026-07-10 20:30:57.723709
\.


--
-- Data for Name: bank_accounts; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.bank_accounts (id, user_id, account_name, institution_name, account_type, currency, balance, is_active, cbu_cvu, alias, notes, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: budget_items; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.budget_items (id, fecha, tipo, categoria, monto_total, monto_pagado, detalle, fecha_vencimiento, status, created_at, updated_at, tipo_presupuesto, tipo_flujo, monto_ejecutado, estimated_payment, user_id) FROM stdin;
176	2026-04-01	Ingresos	Ingresos	2561024	0	Sueldo Sergio	2026-04-01	PENDIENTE	2026-04-10 19:27:01.467821	2026-04-10 19:27:01.467821	OBLIGATION	Ingreso	0	2561024	4
177	2026-04-10	Otro	Ingresos	2000000	0	Extracci├│n Dinero Tarj	2026-04-10	PENDIENTE	2026-04-10 19:27:01.477099	2026-04-10 19:27:01.477099	OBLIGATION	Ingreso	0	2000000	4
178	2026-04-30	Gastos	Cuidado Personal	30000	0	Cuidado Personal Presupuesto Mensual - VARIABLE	2026-04-30	PENDIENTE	2026-04-10 19:27:01.479105	2026-04-10 19:27:01.479105	VARIABLE	Gasto	0	30000	4
179	2026-04-10	Otro	Salud	600000	0	Facturas SWISS Alicia	2026-04-10	PENDIENTE	2026-04-10 19:27:01.482211	2026-04-10 19:27:01.482211	OBLIGATION	Ingreso	0	600000	4
180	2026-04-01	Gastos	Ropa	12000	0	Ropa Presupuesto mensual - VARIABLE	2026-04-01	PENDIENTE	2026-04-10 19:27:01.483841	2026-04-10 19:27:01.483841	OBLIGATION	Gasto	0	12000	4
181	2026-04-30	Pr├®stamo	Hogar	800000	0	Hogar Presupuesto mensual - VARIABLE	2026-04-30	PENDIENTE	2026-04-10 19:27:01.485424	2026-04-10 19:27:01.485424	VARIABLE	Gasto	0	800000	4
182	2026-04-04	Impuestos	Impuestos	40000	0	Gastos Impuestos Presupuesto mensual.	2026-04-30	PENDIENTE	2026-04-10 19:27:01.486747	2026-04-10 19:27:01.486747	OBLIGATION	Gasto	0	40000	4
183	2026-04-03	Alquileres	Ingresos	480000	0	Alquiler Monte	2026-04-03	PENDIENTE	2026-04-10 19:27:01.487762	2026-04-10 19:27:01.487762	OBLIGATION	Ingreso	0	480000	4
184	2026-04-04	Reintegros	Ingresos	1050000	0	Devoluci├│n Impuestos Presupuesto mensual.	2026-04-04	PENDIENTE	2026-04-10 19:27:01.489279	2026-04-10 19:27:01.489279	OBLIGATION	Ingreso	0	1050000	4
185	2026-04-12	Sueldos	Ingresos	950000	0	Adelanto Sueldo Sergio	2026-04-12	PENDIENTE	2026-04-10 19:27:01.490297	2026-04-10 19:27:01.490297	OBLIGATION	Ingreso	0	950000	4
186	2026-04-02	Sueldos	Ingresos	2150000	0	Sueldo Chicha	2026-04-02	PENDIENTE	2026-04-10 19:27:01.491951	2026-04-10 19:27:01.491951	OBLIGATION	Ingreso	0	2150000	4
187	2026-04-05	Tarjeta de Cr├®dito	Tarjeta de Cr├®dito	1450000	0	Pago Tarjeta VISA - Ciudad (abr 2026) - Pago M├¡nimo: $1,450,000 [tc:1:2026-04]	2026-04-05	PENDIENTE	2026-04-10 19:27:01.492985	2026-04-10 19:27:01.492985	OBLIGATION	Gasto	0	4343996.95	4
188	2026-04-01	Gastos	Salud	1100000	0	Servicios Profesionales Presupuesto mensual - VARIABLE	2026-04-01	PENDIENTE	2026-04-10 19:27:01.494001	2026-04-10 19:27:01.494001	VARIABLE	Gasto	0	1100000	4
189	2026-04-08	Gastos	Educaci├│n	1400000	0	Educaci├│n Presupuesto mensual - VARIABLE	2026-04-08	PENDIENTE	2026-04-10 19:27:01.496567	2026-04-10 19:27:01.496567	VARIABLE	Gasto	0	1400000	4
190	2026-04-07	Otro	Ingresos	900000	0	Ingresos Extras Previstos Abril 2024	2026-04-30	PENDIENTE	2026-04-10 19:27:01.497915	2026-04-10 19:27:01.497915	OBLIGATION	Ingreso	0	900000	4
191	2026-04-25	Pr├®stamo	Servicios	220000	0	Servicios Presupuesto Mensual	2026-04-25	PENDIENTE	2026-04-10 19:27:01.499077	2026-04-10 19:27:01.499077	OBLIGATION	Gasto	0	220000	4
192	2026-04-30	Otro	Comida	1400000	0	Alimento Presupuesto mensual - VARIABLE	2026-04-30	PENDIENTE	2026-04-10 19:27:01.5006	2026-04-10 19:27:01.5006	VARIABLE	Gasto	0	1400000	4
193	2026-04-01	Vivienda	Alquiler	730000	0	Alquiler Tonelero Presupuesto Mensual	2026-04-10	PENDIENTE	2026-04-10 19:27:01.502673	2026-04-10 19:27:01.502673	OBLIGATION	Gasto	0	730000	4
194	2026-04-07	Impuestos	Impuestos	100000	0	Impuestos Presupuesto Mensual	2026-04-10	PENDIENTE	2026-04-10 19:27:01.503666	2026-04-10 19:27:01.503666	OBLIGATION	Gasto	0	100000	4
195	2026-04-01	Gastos	Pr├®stamos	1900000	0	Pr├®stamos Presupuesto mensual	2026-04-01	PENDIENTE	2026-04-10 19:27:01.506782	2026-04-10 19:27:01.506782	OBLIGATION	Gasto	0	1900000	4
196	2026-04-10	Otro	Seguros	370000	0	Seguros Presupuesto mensual	2026-04-10	PENDIENTE	2026-04-10 19:27:01.507886	2026-04-10 19:27:01.507886	OBLIGATION	Gasto	0	370000	4
197	2026-04-30	Gastos	Transporte	300000	0	Transporte (SUBE+Nafta+Auto) Presupuesto mensual - VARIABLE	2026-04-30	PENDIENTE	2026-04-10 19:27:01.510676	2026-04-10 19:27:01.510676	VARIABLE	Gasto	0	300000	4
198	2026-04-20	Gastos	Salud	350000	0	Salud Presupuesto mensual - VARIABLE 	2026-04-20	PENDIENTE	2026-04-10 19:27:01.512821	2026-04-10 19:27:01.512821	VARIABLE	Gasto	0	350000	4
131	2026-03-19	Ingresos	Ingresos	2561024	0	Sueldo Sergio	2026-03-01	VENCIDA	2026-03-19 19:40:02.514081	2026-03-25 00:57:31.60339	OBLIGATION	Ingreso	2561000	2561024	1
134	2026-03-01	Alquileres	Ingresos	480000	0	Alquiler Monte	2026-03-03	VENCIDA	2026-03-23 19:33:35.118462	2026-03-25 00:57:31.6044	OBLIGATION	Ingreso	478000	480000	1
130	2026-03-19	Pr├®stamo	Personal	600000	0	Ahorro Presupuesto mensual	2026-03-31	Pago parcial	2026-03-19 01:28:53.352828	2026-03-19 01:29:47.780291	OBLIGATION	Gasto	570000	600000	1
110	2026-03-17	Gastos	Salud	1100000	0	Servicios Profesionales Presupuesto mensual - VARIABLE	2026-03-01	PAGADA	2026-03-17 19:54:56.185355	2026-03-19 19:31:07.819723	VARIABLE	Gasto	1174080	1100000	1
136	2026-03-01	Otro	Ingresos	2000000	0	Extracci├│n Dinero Tarj	2026-03-10	VENCIDA	2026-03-23 19:38:16.647408	2026-03-24 21:10:34.250216	OBLIGATION	Ingreso	2000000	2000000	1
108	2026-03-17	Gastos	Cuidado Personal	30000	0	Cuidado Personal Presupuesto Mensual - VARIABLE	2026-03-31	PENDIENTE	2026-03-17 19:54:56.175847	2026-03-18 17:57:29.784874	VARIABLE	Gasto	0	30000	1
120	2026-03-17	Gastos	Educaci├│n	1400000	0	Educaci├│n Presupuesto mensual - VARIABLE	2026-03-08	Pago parcial	2026-03-17 19:54:56.240081	2026-03-25 18:23:54.229316	VARIABLE	Gasto	1373643.5	1400000	1
135	2026-03-10	Sueldos	Ingresos	1981000	0	Adelanto Sueldo Sergio	2026-03-12	VENCIDA	2026-03-23 19:34:30.883554	2026-03-24 23:07:27.184152	OBLIGATION	Ingreso	1970000	1981000	1
119	2026-03-17	Gastos	Transporte	120000	83870	SUBE Presupuesto mensual - VARIABLE	2026-03-01	Pago parcial	2026-03-17 19:54:56.234269	2026-03-19 19:31:13.043563	VARIABLE	Gasto	86377	120000	1
97	2026-03-17	Gastos	Salud	350000	0	Salud Presupuesto mensual - VARIABLE 	2026-03-20	PAGADA	2026-03-17 19:54:56.114316	2026-03-30 19:29:25.206505	VARIABLE	Gasto	353880.64	350000	1
132	2026-03-22	Otro	Seguros	370000	0	Seguros Presupuesto mensual	2026-03-10	Pago parcial	2026-03-22 16:59:52.960956	2026-04-03 02:15:53.250608	OBLIGATION	Gasto	288000	370000	1
122	2026-03-18	Pr├®stamo	Servicios	220000	0	Servicios Presupuesto Mensual	2026-03-25	PAGADA	2026-03-18 00:34:14.548707	2026-03-30 14:31:31.727534	OBLIGATION	Gasto	329784.4	220000	1
149	2026-04-01	Ingresos	Ingresos	2561024	0	Sueldo Sergio	2026-04-01	VENCIDA	2026-04-03 02:20:00.878468	2026-04-04 00:28:55.412092	OBLIGATION	Ingreso	2535558	2561024	1
114	2026-03-17	Gastos	Ropa	12000	0	Ropa Presupuesto mensual - VARIABLE	2026-03-01	PAGADA	2026-03-17 19:54:56.205133	2026-03-30 20:03:15.791613	OBLIGATION	Gasto	76492	12000	1
137	2026-03-23	Otro	Salud	396000	0	Facturas SWISS	2026-03-10	PAGADA	2026-03-23 19:46:17.087448	2026-04-03 02:19:45.069684	OBLIGATION	Ingreso	396000	396000	1
153	2026-04-10	Otro	Ingresos	2000000	0	Extracci├│n Dinero Tarj	2026-04-10	PENDIENTE	2026-04-03 02:20:00.910343	2026-04-03 02:20:00.910343	OBLIGATION	Ingreso	0	2000000	1
154	2026-04-30	Gastos	Cuidado Personal	30000	0	Cuidado Personal Presupuesto Mensual - VARIABLE	2026-04-30	PENDIENTE	2026-04-03 02:20:00.917247	2026-04-03 02:20:00.917247	VARIABLE	Gasto	0	30000	1
93	2026-03-17	Gastos	Transporte	120000	50000	Transporte Presupuesto mensual - VARIABLE	2026-03-31	PAGADA	2026-03-17 19:54:56.088756	2026-04-04 02:10:54.53678	VARIABLE	Gasto	290363	120000	1
164	2026-04-10	Otro	Salud	600000	0	Facturas SWISS Alicia	2026-04-10	PENDIENTE	2026-04-03 02:20:00.98183	2026-04-04 00:31:09.159304	OBLIGATION	Ingreso	0	600000	1
95	2026-03-17	Gastos	Pr├®stamos	1900000	0	Pr├®stamos Presupuesto mensual	2026-03-01	Pago parcial	2026-03-17 19:54:56.101932	2026-04-02 20:47:45.010857	OBLIGATION	Gasto	1135186.83	1900000	1
125	2026-03-18	Pr├®stamo	Hogar	800000	0	Hogar Presupuesto mensual - VARIABLE	2026-03-31	PAGADA	2026-03-18 14:48:49.926287	2026-04-03 01:27:49.714833	VARIABLE	Gasto	1469899.81	800000	1
163	2026-04-01	Gastos	Ropa	12000	0	Ropa Presupuesto mensual - VARIABLE	2026-04-01	VENCIDA	2026-04-03 02:20:00.975306	2026-04-03 02:20:00.975306	OBLIGATION	Gasto	0	12000	1
170	2026-04-30	Pr├®stamo	Hogar	800000	0	Hogar Presupuesto mensual - VARIABLE	2026-04-30	PENDIENTE	2026-04-03 02:20:01.023447	2026-04-03 02:20:01.023447	VARIABLE	Gasto	0	800000	1
171	2026-04-04	Impuestos	Impuestos	40000	0	Gastos Impuestos Presupuesto mensual.	2026-04-30	PENDIENTE	2026-04-04 00:42:09.460001	2026-04-04 00:42:09.460001	OBLIGATION	Gasto	0	40000	1
150	2026-04-03	Alquileres	Ingresos	480000	0	Alquiler Monte	2026-04-03	Pago parcial	2026-04-03 02:20:00.888318	2026-04-03 02:21:51.707352	OBLIGATION	Ingreso	478000	480000	1
168	2026-04-04	Reintegros	Ingresos	1050000	0	Devoluci├│n Impuestos Presupuesto mensual.	2026-04-04	PAGADA	2026-04-03 02:20:01.009859	2026-04-04 00:40:45.603769	OBLIGATION	Ingreso	1050000	1050000	1
133	2026-03-01	Sueldos	Ingresos	1820000	0	Sueldo Chicha	2026-03-02	PAGADA	2026-03-23 19:33:12.836008	2026-04-03 23:53:45.370213	OBLIGATION	Ingreso	1820000	1820000	1
91	2026-03-17	Otro	Comida	800000	0	Alimento Presupuesto mensual - VARIABLE	2026-03-31	PAGADA	2026-03-17 19:54:56.076331	2026-04-04 00:29:07.057639	VARIABLE	Gasto	887374	800000	1
156	2026-04-12	Sueldos	Ingresos	950000	0	Adelanto Sueldo Sergio	2026-04-12	PENDIENTE	2026-04-03 02:20:00.931808	2026-04-04 00:30:07.142626	OBLIGATION	Ingreso	0	950000	1
167	2026-04-02	Sueldos	Ingresos	2150000	0	Sueldo Chicha	2026-04-02	PAGADA	2026-04-03 02:20:01.002907	2026-04-04 00:33:55.441469	OBLIGATION	Ingreso	2150000	2150000	1
124	2026-03-18	Pr├®stamo	Impuestos	110000	0	Impuestos Presupuesto mensual.	2026-03-04	PAGADA	2026-03-18 14:45:24.473285	2026-04-04 02:10:54.539059	OBLIGATION	Gasto	493370.65	110000	1
145	2026-03-01	Tarjeta de Cr├®dito	Tarjeta de Cr├®dito	1405372	2005372	Pago Tarjeta VISA - Ciudad (mar 2026) - Pago M├¡nimo: $1,405,372 [tc:1:2026-03]	2026-03-05	PAGADA	2026-03-30 20:47:47.397216	2026-04-08 12:57:21.446414	OBLIGATION	Gasto	2005372	4343996.95	1
121	2026-03-18	Otro	Comida	300000	0	Comida Mica Presupuesto mensual - VARIABLE	2026-03-31	Pago parcial	2026-03-18 00:28:42.857801	2026-04-05 23:40:04.170829	VARIABLE	Gasto	274000	300000	1
162	2026-04-05	Tarjeta de Cr├®dito	Tarjeta de Cr├®dito	1450000	600000	Pago Tarjeta VISA - Ciudad (abr 2026) - Pago M├¡nimo: $1,450,000 [tc:1:2026-04]	2026-04-05	PENDIENTE	2026-04-03 02:20:00.969795	2026-04-07 19:29:23.429051	OBLIGATION	Gasto	0	4343996.95	1
152	2026-04-01	Gastos	Salud	1100000	0	Servicios Profesionales Presupuesto mensual - VARIABLE	2026-04-01	Pago parcial	2026-04-03 02:20:00.903336	2026-04-09 19:07:12.608663	VARIABLE	Gasto	1084080	1100000	1
155	2026-04-08	Gastos	Educaci├│n	1400000	0	Educaci├│n Presupuesto mensual - VARIABLE	2026-04-08	Pago parcial	2026-04-03 02:20:00.925108	2026-04-09 19:04:49.013088	VARIABLE	Gasto	1062203.5	1400000	1
172	2026-04-07	Otro	Ingresos	900000	0	Ingresos Extras Previstos Abril 2024	2026-04-30	PENDIENTE	2026-04-07 00:23:01.190204	2026-04-07 00:23:13.911179	OBLIGATION	Ingreso	285000	900000	1
160	2026-04-25	Pr├®stamo	Servicios	220000	0	Servicios Presupuesto Mensual	2026-04-25	Pago parcial	2026-04-03 02:20:00.956598	2026-04-07 00:40:19.944699	OBLIGATION	Gasto	32390.03	220000	1
161	2026-04-30	Otro	Comida	1400000	0	Alimento Presupuesto mensual - VARIABLE	2026-04-30	Pago parcial	2026-04-03 02:20:00.963259	2026-04-09 19:06:23.328792	VARIABLE	Gasto	491950	1400000	1
173	2026-04-01	Vivienda	Alquiler	730000	0	Alquiler Tonelero Presupuesto Mensual	2026-04-10	Pago parcial	2026-04-07 00:39:23.676427	2026-04-07 00:40:26.514336	OBLIGATION	Gasto	716399.81	730000	1
174	2026-04-07	Impuestos	Impuestos	100000	0	Impuestos Presupuesto Mensual	2026-04-10	Pago parcial	2026-04-07 00:43:42.261836	2026-04-08 01:02:25.562324	OBLIGATION	Gasto	46675	100000	1
169	2026-04-01	Gastos	Pr├®stamos	1900000	0	Pr├®stamos Presupuesto mensual	2026-04-01	Pago parcial	2026-04-03 02:20:01.017677	2026-04-07 00:44:07.419723	OBLIGATION	Gasto	192499.71000000002	1900000	1
159	2026-04-10	Otro	Seguros	370000	0	Seguros Presupuesto mensual	2026-04-10	Pago parcial	2026-04-03 02:20:00.950694	2026-04-09 19:04:20.258414	OBLIGATION	Gasto	301562.18000000005	370000	1
147	2026-02-01	Tarjeta de Cr├®dito	Tarjeta de Cr├®dito	97744	100000	Pago Tarjeta VISA ICBC - ICBC (feb 2026) - Pago M├¡nimo: $97,744 [tc:9:2026-02]	2026-02-07	PAGADA	2026-03-31 19:45:28.07901	2026-04-07 15:31:38.46433	OBLIGATION	Gasto	100000	317000	1
175	2026-03-01	Tarjeta de Cr├®dito	Tarjeta de Cr├®dito	301034.46	301034.46	Pago Tarjeta VISA ICBC - ICBC (mar 2026) (M├¡n: $81,035) [tc:9:2026-03]	2026-03-07	PAGADA	2026-04-07 19:57:33.171001	2026-04-07 19:59:30.606914	OBLIGATION	Gasto	301034.46	\N	1
165	2026-04-30	Gastos	Transporte	300000	0	Transporte (SUBE+Nafta+Auto) Presupuesto mensual - VARIABLE	2026-04-30	Pago parcial	2026-04-03 02:20:00.990355	2026-04-08 01:01:17.858746	VARIABLE	Gasto	35000	300000	1
158	2026-04-20	Gastos	Salud	350000	0	Salud Presupuesto mensual - VARIABLE 	2026-04-20	Pago parcial	2026-04-03 02:20:00.943837	2026-04-09 19:05:47.705662	VARIABLE	Gasto	100000	350000	1
340	2026-03-19	Ingresos	Ingresos	2561024	0	Sueldo Sergio	2026-03-01	PENDIENTE	2026-04-13 22:37:29.907409	2026-04-13 22:37:29.907409	OBLIGATION	Ingreso	0	2561024	3
341	2026-03-01	Alquileres	Ingresos	480000	0	Alquiler Monte	2026-03-03	PENDIENTE	2026-04-13 22:37:29.929757	2026-04-13 22:37:29.929757	OBLIGATION	Ingreso	0	480000	3
342	2026-03-19	Pr├®stamo	Personal	600000	0	Ahorro Presupuesto mensual	2026-03-31	PENDIENTE	2026-04-13 22:37:29.932	2026-04-13 22:37:29.932	OBLIGATION	Gasto	0	600000	3
343	2026-03-17	Gastos	Salud	1100000	0	Servicios Profesionales Presupuesto mensual - VARIABLE	2026-03-01	PENDIENTE	2026-04-13 22:37:29.93337	2026-04-13 22:37:29.93337	VARIABLE	Gasto	0	1100000	3
344	2026-03-01	Otro	Ingresos	2000000	0	Extracci├│n Dinero Tarj	2026-03-10	PENDIENTE	2026-04-13 22:37:29.934369	2026-04-13 22:37:29.934369	OBLIGATION	Ingreso	0	2000000	3
345	2026-03-17	Gastos	Cuidado Personal	30000	0	Cuidado Personal Presupuesto Mensual - VARIABLE	2026-03-31	PENDIENTE	2026-04-13 22:37:29.936687	2026-04-13 22:37:29.936687	VARIABLE	Gasto	0	30000	3
346	2026-03-17	Gastos	Educaci├│n	1400000	0	Educaci├│n Presupuesto mensual - VARIABLE	2026-03-08	PENDIENTE	2026-04-13 22:37:29.938669	2026-04-13 22:37:29.938669	VARIABLE	Gasto	0	1400000	3
347	2026-03-10	Sueldos	Ingresos	1981000	0	Adelanto Sueldo Sergio	2026-03-12	PENDIENTE	2026-04-13 22:37:29.939832	2026-04-13 22:37:29.939832	OBLIGATION	Ingreso	0	1981000	3
348	2026-03-17	Gastos	Transporte	120000	0	SUBE Presupuesto mensual - VARIABLE	2026-03-01	PENDIENTE	2026-04-13 22:37:29.942341	2026-04-13 22:37:29.942341	VARIABLE	Gasto	0	120000	3
349	2026-03-17	Gastos	Salud	350000	0	Salud Presupuesto mensual - VARIABLE 	2026-03-20	PENDIENTE	2026-04-13 22:37:29.943349	2026-04-13 22:37:29.943349	VARIABLE	Gasto	0	350000	3
350	2026-03-22	Otro	Seguros	370000	0	Seguros Presupuesto mensual	2026-03-10	PENDIENTE	2026-04-13 22:37:29.94435	2026-04-13 22:37:29.94435	OBLIGATION	Gasto	0	370000	3
351	2026-03-18	Pr├®stamo	Servicios	220000	0	Servicios Presupuesto Mensual	2026-03-25	PENDIENTE	2026-04-13 22:37:29.945719	2026-04-13 22:37:29.945719	OBLIGATION	Gasto	0	220000	3
352	2026-04-01	Ingresos	Ingresos	2561024	0	Sueldo Sergio	2026-04-01	PENDIENTE	2026-04-13 22:37:29.9469	2026-04-13 22:37:29.9469	OBLIGATION	Ingreso	0	2561024	3
353	2026-03-17	Gastos	Ropa	12000	0	Ropa Presupuesto mensual - VARIABLE	2026-03-01	PENDIENTE	2026-04-13 22:37:29.94911	2026-04-13 22:37:29.94911	OBLIGATION	Gasto	0	12000	3
354	2026-03-23	Otro	Salud	396000	0	Facturas SWISS	2026-03-10	PENDIENTE	2026-04-13 22:37:29.950108	2026-04-13 22:37:29.950108	OBLIGATION	Ingreso	0	396000	3
355	2026-04-10	Otro	Ingresos	2000000	0	Extracci├│n Dinero Tarj	2026-04-10	PENDIENTE	2026-04-13 22:37:29.951374	2026-04-13 22:37:29.951374	OBLIGATION	Ingreso	0	2000000	3
356	2026-04-30	Gastos	Cuidado Personal	30000	0	Cuidado Personal Presupuesto Mensual - VARIABLE	2026-04-30	PENDIENTE	2026-04-13 22:37:29.952882	2026-04-13 22:37:29.952882	VARIABLE	Gasto	0	30000	3
357	2026-03-17	Gastos	Transporte	120000	0	Transporte Presupuesto mensual - VARIABLE	2026-03-31	PENDIENTE	2026-04-13 22:37:29.954982	2026-04-13 22:37:29.954982	VARIABLE	Gasto	0	120000	3
358	2026-04-10	Otro	Salud	600000	0	Facturas SWISS Alicia	2026-04-10	PENDIENTE	2026-04-13 22:37:29.95659	2026-04-13 22:37:29.95659	OBLIGATION	Ingreso	0	600000	3
359	2026-03-17	Gastos	Pr├®stamos	1900000	0	Pr├®stamos Presupuesto mensual	2026-03-01	PENDIENTE	2026-04-13 22:37:29.95875	2026-04-13 22:37:29.95875	OBLIGATION	Gasto	0	1900000	3
360	2026-03-18	Pr├®stamo	Hogar	800000	0	Hogar Presupuesto mensual - VARIABLE	2026-03-31	PENDIENTE	2026-04-13 22:37:29.960891	2026-04-13 22:37:29.960891	VARIABLE	Gasto	0	800000	3
361	2026-04-01	Gastos	Ropa	12000	0	Ropa Presupuesto mensual - VARIABLE	2026-04-01	PENDIENTE	2026-04-13 22:37:29.962494	2026-04-13 22:37:29.962494	OBLIGATION	Gasto	0	12000	3
363	2026-04-04	Impuestos	Impuestos	40000	0	Gastos Impuestos Presupuesto mensual.	2026-04-30	PENDIENTE	2026-04-13 22:37:29.966191	2026-04-13 22:37:29.966191	OBLIGATION	Gasto	0	40000	3
364	2026-04-03	Alquileres	Ingresos	480000	0	Alquiler Monte	2026-04-03	PENDIENTE	2026-04-13 22:37:29.96829	2026-04-13 22:37:29.96829	OBLIGATION	Ingreso	0	480000	3
365	2026-04-04	Reintegros	Ingresos	1050000	0	Devoluci├│n Impuestos Presupuesto mensual.	2026-04-04	PENDIENTE	2026-04-13 22:37:29.97028	2026-04-13 22:37:29.97028	OBLIGATION	Ingreso	0	1050000	3
366	2026-03-01	Sueldos	Ingresos	1820000	0	Sueldo Chicha	2026-03-02	PENDIENTE	2026-04-13 22:37:29.971779	2026-04-13 22:37:29.971779	OBLIGATION	Ingreso	0	1820000	3
367	2026-03-17	Otro	Comida	800000	0	Alimento Presupuesto mensual - VARIABLE	2026-03-31	PENDIENTE	2026-04-13 22:37:29.974517	2026-04-13 22:37:29.974517	VARIABLE	Gasto	0	800000	3
368	2026-04-12	Sueldos	Ingresos	950000	0	Adelanto Sueldo Sergio	2026-04-12	PENDIENTE	2026-04-13 22:37:29.975514	2026-04-13 22:37:29.975514	OBLIGATION	Ingreso	0	950000	3
369	2026-04-02	Sueldos	Ingresos	2150000	0	Sueldo Chicha	2026-04-02	PENDIENTE	2026-04-13 22:37:29.978434	2026-04-13 22:37:29.978434	OBLIGATION	Ingreso	0	2150000	3
370	2026-03-18	Pr├®stamo	Impuestos	110000	0	Impuestos Presupuesto mensual.	2026-03-04	PENDIENTE	2026-04-13 22:37:29.979434	2026-04-13 22:37:29.979434	OBLIGATION	Gasto	0	110000	3
371	2026-03-01	Tarjeta de Cr├®dito	Tarjeta de Cr├®dito	1405372	0	Pago Tarjeta VISA - Ciudad (mar 2026) - Pago M├¡nimo: $1,405,372 [tc:1:2026-03]	2026-03-05	PENDIENTE	2026-04-13 22:37:29.980842	2026-04-13 22:37:29.980842	OBLIGATION	Gasto	0	4343996.95	3
372	2026-03-18	Otro	Comida	300000	0	Comida Mica Presupuesto mensual - VARIABLE	2026-03-31	PENDIENTE	2026-04-13 22:37:29.983663	2026-04-13 22:37:29.983663	VARIABLE	Gasto	0	300000	3
373	2026-04-05	Tarjeta de Cr├®dito	Tarjeta de Cr├®dito	1450000	0	Pago Tarjeta VISA - Ciudad (abr 2026) - Pago M├¡nimo: $1,450,000 [tc:1:2026-04]	2026-04-05	PENDIENTE	2026-04-13 22:37:29.985371	2026-04-13 22:37:29.985371	OBLIGATION	Gasto	0	4343996.95	3
379	2026-04-01	Vivienda	Alquiler	730000	0	Alquiler Tonelero Presupuesto Mensual	2026-04-10	PENDIENTE	2026-04-13 22:37:29.997498	2026-04-13 22:37:29.997498	OBLIGATION	Gasto	0	730000	3
380	2026-04-07	Impuestos	Impuestos	100000	0	Impuestos Presupuesto Mensual	2026-04-10	PENDIENTE	2026-04-13 22:37:29.998498	2026-04-13 22:37:29.998498	OBLIGATION	Gasto	0	100000	3
381	2026-04-01	Gastos	Pr├®stamos	1900000	0	Pr├®stamos Presupuesto mensual	2026-04-01	PENDIENTE	2026-04-13 22:37:30.002071	2026-04-13 22:37:30.002071	OBLIGATION	Gasto	0	1900000	3
382	2026-04-10	Otro	Seguros	370000	0	Seguros Presupuesto mensual	2026-04-10	PENDIENTE	2026-04-13 22:37:30.004583	2026-04-13 22:37:30.004583	OBLIGATION	Gasto	0	370000	3
383	2026-02-01	Tarjeta de Cr├®dito	Tarjeta de Cr├®dito	97744	0	Pago Tarjeta VISA ICBC - ICBC (feb 2026) - Pago M├¡nimo: $97,744 [tc:9:2026-02]	2026-02-07	PENDIENTE	2026-04-13 22:37:30.006595	2026-04-13 22:37:30.006595	OBLIGATION	Gasto	0	317000	3
384	2026-03-01	Tarjeta de Cr├®dito	Tarjeta de Cr├®dito	301034.46	0	Pago Tarjeta VISA ICBC - ICBC (mar 2026) (M├¡n: $81,035) [tc:9:2026-03]	2026-03-07	PENDIENTE	2026-04-13 22:37:30.0089	2026-04-13 22:37:30.0089	OBLIGATION	Gasto	0	301034.46	3
386	2026-04-20	Gastos	Salud	350000	0	Salud Presupuesto mensual - VARIABLE 	2026-04-20	PENDIENTE	2026-04-13 22:37:30.012688	2026-04-13 22:37:30.012688	VARIABLE	Gasto	0	350000	3
374	2026-04-01	Gastos	Salud	1100000	0	Servicios Profesionales Presupuesto mensual - VARIABLE	2026-04-01	Pago parcial	2026-04-13 22:37:29.986776	2026-04-17 16:11:50.421323	VARIABLE	Gasto	9539.4	1100000	3
378	2026-04-30	Otro	Comida	1400000	0	Alimento Presupuesto mensual - VARIABLE	2026-04-30	Pago parcial	2026-04-13 22:37:29.995135	2026-04-17 16:12:05.876344	VARIABLE	Gasto	207320	1400000	3
376	2026-04-07	Otro	Ingresos	900000	0	Ingresos Extras Previstos Abril 2024	2026-04-30	PENDIENTE	2026-04-13 22:37:29.991186	2026-04-17 16:10:03.487086	OBLIGATION	Ingreso	1413567.24	900000	3
362	2026-04-30	Pr├®stamo	Hogar	800000	0	Hogar Presupuesto mensual - VARIABLE	2026-04-30	Pago parcial	2026-04-13 22:37:29.964105	2026-04-17 16:11:12.609135	VARIABLE	Gasto	29998	800000	3
375	2026-04-08	Gastos	Educaci├│n	1400000	0	Educaci├│n Presupuesto mensual - VARIABLE	2026-04-08	Pago parcial	2026-04-13 22:37:29.988285	2026-04-17 16:10:59.89589	VARIABLE	Gasto	514200	1400000	3
377	2026-04-25	Pr├®stamo	Servicios	220000	0	Servicios Presupuesto Mensual	2026-04-25	Pago parcial	2026-04-13 22:37:29.99334	2026-04-17 16:11:46.930824	OBLIGATION	Gasto	90385.43999999999	220000	3
385	2026-04-30	Gastos	Transporte	300000	0	Transporte (SUBE+Nafta+Auto) Presupuesto mensual - VARIABLE	2026-04-30	Pago parcial	2026-04-13 22:37:30.010267	2026-04-17 16:12:00.875049	VARIABLE	Gasto	41300	300000	3
\.


--
-- Data for Name: categories; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.categories (id, name, created_at) FROM stdin;
13	Comida	2026-04-03 00:34:14.978679
14	Transporte	2026-04-03 00:34:14.978679
15	Ingresos	2026-04-03 00:34:14.978679
16	Hogar	2026-04-03 00:34:14.978679
17	Pr├®stamos	2026-04-03 00:34:14.978679
18	Ahorro	2026-04-03 00:34:14.978679
19	Alquiler	2026-04-03 00:34:14.978679
20	Impuestos	2026-04-03 00:34:14.978679
21	Educaci├│n	2026-04-03 00:34:14.978679
22	Salud	2026-04-03 00:34:14.978679
23	Ropa	2026-04-03 00:34:14.978679
24	Servicios	2026-04-03 00:34:14.978679
25	Cuidado Personal	2026-04-03 00:34:14.978679
26	Tarjeta VISA	2026-04-03 00:34:14.978679
27	Ocio	2026-04-03 00:34:14.978679
28	Seguros	2026-04-03 00:34:14.978679
29	Tr├ímites	2026-04-03 00:34:14.978679
31	Sin Clasificar	2026-04-04 00:43:04.883761
32	Saldo mes anterior	2026-04-04 01:26:18.674297
33	Test CSV	2026-04-06 01:29:39.533334
34	Supermercado	2026-04-06 01:34:49.675526
35	Sueldo	2026-04-06 01:54:39.073989
36	Tarjeta de Cr├®dito	2026-04-07 00:17:25.213198
37	00	2026-04-09 19:03:45.644666
38	Comid	2026-04-13 22:38:38.302925
\.


--
-- Data for Name: credit_card_payments; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.credit_card_payments (id, transaction_id, statement_id, card_id, payment_date, amount_paid, payment_method, notes, created_at) FROM stdin;
\.


--
-- Data for Name: credit_card_period_configs; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.credit_card_period_configs (id, card_id, year, month, closing_day, due_day, created_at, updated_at) FROM stdin;
1	9	2026	2	26	10	2026-04-07 20:47:02.775121	2026-04-08 01:04:31.681676
2	1	2026	3	19	6	2026-04-08 13:05:49.4654	2026-04-08 13:05:52.398723
3	1	2026	4	23	7	2026-04-08 13:07:11.234467	2026-04-08 13:07:12.887311
4	10	2026	4	23	7	2026-04-10 19:27:58.780989	2026-04-10 19:27:58.780989
5	17	2026	3	19	6	2026-04-13 22:37:30.231087	2026-04-13 22:37:30.231087
6	17	2026	4	23	7	2026-04-13 22:37:30.231087	2026-04-13 22:37:30.231087
7	20	2026	2	26	10	2026-04-13 22:37:30.511983	2026-04-13 22:37:30.511983
\.


--
-- Data for Name: credit_card_purchases; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.credit_card_purchases (id, card_id, transaction_id, purchase_date, total_amount, category, description, installments, has_financing, created_at, updated_at, currency, exchange_rate, amount_in_pesos, billing_date, movement_type, cash_advance_fee, derived_debt_id) FROM stdin;
315	19	\N	2026-05-28	2000	General	Extracci├│n tarjeta 	1	f	2026-05-28 18:00:36.956908	2026-05-28 18:00:36.967111	ARS	\N	\N	2026-05-28	cash_advance	6.9	504
313	19	\N	2026-05-28	1000	General	Extracci├│n tarjeta  TEST	1	f	2026-05-28 17:30:25.052657	2026-05-28 17:30:25.072589	ARS	\N	\N	2026-05-28	cash_advance	6.9	502
227	17	\N	2026-03-27	30000	General	HAVANNA	1	f	2026-04-27 17:27:02.571938	2026-04-27 17:27:02.57194	ARS	\N	\N	2026-03-27	normal	0	\N
2	1	\N	2026-02-14	23581.66	General	MERPAGO BELLEZAPERFECTA	1	f	2026-03-26 17:29:56.93183	2026-03-26 17:29:56.93183	ARS	\N	\N	2026-02-14	normal	0	\N
62	1	\N	2026-03-19	5337.19	General	COM.ADM.Y LIQ.DE CUENTA	1	f	2026-03-30 22:15:20.53555	2026-03-30 22:15:20.53555	ARS	\N	\N	2026-03-19	normal	0	\N
4	1	\N	2026-02-14	2381.66	General	MERPAGO BELLEZAPERFECTA	1	f	2026-03-27 22:29:50.82539	2026-03-27 22:29:50.82539	ARS	\N	\N	2026-02-14	normal	0	\N
5	1	\N	2026-02-01	3200	General	GRIMOLDI	1	f	2026-03-27 22:29:50.831475	2026-03-27 22:29:50.831475	ARS	\N	\N	2026-02-01	normal	0	\N
6	1	\N	2026-02-19	10000	General	LIBRERIA LA MILAGROSA	1	f	2026-03-27 22:29:50.839214	2026-03-27 22:29:50.839214	ARS	\N	\N	2026-02-19	normal	0	\N
7	1	\N	2026-02-20	1677.86	General	AUTOPISTA DEL OESTE	1	f	2026-03-27 22:29:50.848443	2026-03-27 22:29:50.848443	ARS	\N	\N	2026-02-20	normal	0	\N
8	1	\N	2026-02-14	23581.66	General	MERPAGO BELLEZAPERFECTA	1	f	2026-03-27 22:40:49.139879	2026-03-27 22:40:49.139879	ARS	\N	\N	2026-02-14	normal	0	\N
9	1	\N	2026-02-15	32500	General	GRIMOLDI	1	f	2026-03-27 22:40:49.153154	2026-03-27 22:40:49.153154	ARS	\N	\N	2026-02-15	normal	0	\N
10	1	\N	2026-02-19	10000	General	LIBRERIA LA MILAGROSA	1	f	2026-03-27 22:40:49.166132	2026-03-27 22:40:49.166132	ARS	\N	\N	2026-02-19	normal	0	\N
79	1	\N	2026-03-09	22648.49	General	DLOCAL*NETFLIX C	1	f	2026-03-30 23:13:40.003884	2026-03-30 23:13:40.003884	ARS	\N	\N	2026-03-09	normal	0	\N
81	1	\N	2026-03-13	3300	General	TUSCLASES	1	f	2026-03-30 23:13:40.024082	2026-03-30 23:13:40.024082	ARS	\N	\N	2026-03-13	normal	0	\N
83	1	\N	2026-03-16	3200	General	LA FAMILIAS	1	f	2026-03-30 23:13:40.044715	2026-03-30 23:13:40.044715	ARS	\N	\N	2026-03-16	normal	0	\N
85	1	\N	2026-03-18	1925.82	General	MERPAGO*GUOBINWEI	1	f	2026-03-30 23:13:40.065192	2026-03-30 23:13:40.065192	ARS	\N	\N	2026-03-18	normal	0	\N
87	1	\N	2026-03-18	4700	General	LA FAMILIAS	1	f	2026-03-30 23:13:40.084851	2026-03-30 23:13:40.084851	ARS	\N	\N	2026-03-18	normal	0	\N
78	1	\N	2026-03-09	96291	General	MERPAGO*SERGIOGUSTAVOSALA	1	f	2026-03-30 23:13:39.988319	2026-03-30 23:13:39.988319	ARS	\N	\N	2026-03-09	normal	0	\N
80	1	\N	2026-03-11	15000	General	MERPAGO*FEDERICO	1	f	2026-03-30 23:13:40.0143	2026-03-30 23:13:40.0143	ARS	\N	\N	2026-03-11	normal	0	\N
82	1	\N	2026-03-16	2875	General	MERPAGO*MAXIKIOSCO	1	f	2026-03-30 23:13:40.03363	2026-03-30 23:13:40.03363	ARS	\N	\N	2026-03-16	normal	0	\N
84	1	\N	2026-03-18	38516.4	General	MERPAGO*PRISCILASOFIASANC	1	f	2026-03-30 23:13:40.054313	2026-03-30 23:13:40.054313	ARS	\N	\N	2026-03-18	normal	0	\N
86	1	\N	2026-03-18	38516.4	General	MERPAGO*ALEJANDRAVANES	1	f	2026-03-30 23:13:40.075719	2026-03-30 23:13:40.075719	ARS	\N	\N	2026-03-18	normal	0	\N
92	9	\N	2026-02-17	12976.32	General	DIA TIENDA 608	1	f	2026-03-31 14:40:14.289036	2026-03-31 14:40:14.289036	ARS	\N	\N	2026-02-17	normal	0	\N
94	9	\N	2026-02-26	10802.86	General	INTERESES FINANCIACION $	1	f	2026-03-31 14:40:14.304812	2026-03-31 14:40:14.304812	ARS	\N	\N	2026-02-26	normal	0	\N
95	9	\N	2026-02-26	943.3	General	PUNIT. PAG.MIN.ANT.ANTER. $	1	f	2026-03-31 14:40:14.31288	2026-03-31 14:40:14.31288	ARS	\N	\N	2026-02-26	normal	0	\N
112	17	\N	2026-02-14	70744.98	General	MERPAGO BELLEZAPERFECTA	3	f	2026-04-13 22:37:30.235132	2026-04-27 19:30:50.122893	ARS	\N	\N	2026-02-14	normal	0	\N
90	9	\N	2026-02-10	15990	General	ASISTENCIA HOG0000000328000-000-000	1	f	2026-03-31 14:40:14.266326	2026-04-07 15:32:48.257802	ARS	\N	\N	2026-02-10	normal	0	\N
99	9	\N	2026-01-31	37190.08	General	COMISION PAQUETE	1	f	2026-04-07 15:36:52.716971	2026-04-07 15:36:52.716971	ARS	\N	\N	2026-01-31	normal	0	\N
100	9	\N	2026-01-21	9996.66	General	LUARDO S A C.03/03	1	f	2026-04-07 15:41:01.201787	2026-04-07 15:41:01.201787	ARS	\N	\N	2026-01-21	normal	0	\N
101	9	\N	2026-02-04	202215.65	General	Saldo Anterior	1	f	2026-04-07 19:42:00.620427	2026-04-07 19:43:20.786827	ARS	\N	\N	2026-02-04	normal	0	\N
102	9	\N	2026-02-26	10276.61	General	DB IVA $21%	1	f	2026-04-07 19:44:41.913008	2026-04-07 19:44:41.913008	ARS	\N	\N	2026-02-26	normal	0	\N
89	9	\N	2026-02-06	17351.4	General	ADOBE	1	f	2026-03-31 14:40:14.181344	2026-04-07 19:45:39.900525	ARS	\N	\N	2026-02-06	normal	0	\N
103	9	\N	2026-02-21	9996.66	General	LUARDO S A C.03/03	1	f	2026-04-07 19:46:26.992768	2026-04-07 19:46:26.992768	ARS	\N	\N	2026-02-21	normal	0	\N
104	9	\N	2026-03-10	17399.9	General	ASISTENCIA HOG0000000328000-000-000	1	f	2026-04-07 19:49:53.407926	2026-04-07 19:49:53.407926	ARS	\N	\N	2026-03-10	normal	0	\N
108	9	\N	2026-03-26	11435.59	General	DB_IVA $21%	1	f	2026-04-07 19:49:53.42997	2026-04-07 19:49:53.42997	ARS	\N	\N	2026-03-26	normal	0	\N
195	20	\N	2026-03-26	11435.59	General	DB_IVA $21%	1	f	2026-04-13 22:37:30.554409	2026-04-13 22:37:30.554409	ARS	\N	\N	2026-03-26	normal	0	\N
138	17	\N	2026-03-05	56809.55	General	MERPAGO MARTELAINESAGUSTI	1	f	2026-04-13 22:37:30.298645	2026-04-13 22:37:30.298645	ARS	\N	\N	2026-03-05	normal	0	\N
238	17	\N	2026-04-06	33380.88	General	MERPAGO*GUSTAVOADOLFOPERE (REVISAR)	1	f	2026-04-27 17:27:02.597878	2026-04-29 10:16:54.41054	ARS	\N	\N	2026-04-06	normal	0	\N
248	17	\N	2026-04-11	15000	General	MERPAGO*FEDERICO (REVISAR)	1	f	2026-04-27 17:27:02.62173	2026-04-29 10:17:09.99514	ARS	\N	\N	2026-04-11	normal	0	\N
203	17	\N	2026-02-09	543946.21	General	VISA PLAN V 3-12 (TNA 84.00)	1	f	2026-04-27 17:27:02.508185	2026-04-27 17:27:02.508186	ARS	\N	\N	2026-02-09	normal	0	\N
208	17	\N	2026-03-07	33433.33	General	COMO QUIERES QUE TE QU Cuota 02/03	1	f	2026-04-27 17:27:02.523708	2026-04-27 17:27:02.523709	ARS	\N	\N	2026-03-07	normal	0	\N
213	17	\N	2026-03-20	2.99	General	JobLeads.com Membershi USD 2.99	1	f	2026-04-27 17:27:02.536333	2026-04-27 17:27:02.536335	ARS	\N	\N	2026-03-20	normal	0	\N
218	17	\N	2026-03-25	17351.4	General	Adobe.com	1	f	2026-04-27 17:27:02.549188	2026-04-27 17:27:02.54919	ARS	\N	\N	2026-03-25	normal	0	\N
223	17	\N	2026-03-27	21398	General	MERPAGO*PRISCILASOFIASANC	1	f	2026-04-27 17:27:02.560318	2026-04-27 17:27:02.560319	ARS	\N	\N	2026-03-27	normal	0	\N
228	17	\N	2026-03-28	21398	General	MERPAGO*MICAELABELENSALAN	1	f	2026-04-27 17:27:02.574125	2026-04-27 17:27:02.574126	ARS	\N	\N	2026-03-28	normal	0	\N
233	17	\N	2026-04-02	26747.5	General	MERPAGO*JUNQUERAMARIAANGE	1	f	2026-04-27 17:27:02.586417	2026-04-27 17:27:02.586418	ARS	\N	\N	2026-04-02	normal	0	\N
243	17	\N	2026-04-09	14999	General	NETFLIX.COM 62215896651793530	1	f	2026-04-27 17:27:02.608799	2026-04-27 17:27:02.6088	ARS	\N	\N	2026-04-09	normal	0	\N
253	17	\N	2026-04-13	3300	General	TUSCLASES	1	f	2026-04-27 17:27:02.633106	2026-04-27 17:27:02.633108	ARS	\N	\N	2026-04-13	normal	0	\N
258	17	\N	2026-04-14	3209.7	General	MERPAGO*PRISCILASOFIASANC	1	f	2026-04-27 17:27:02.644364	2026-04-27 17:27:02.644366	ARS	\N	\N	2026-04-14	normal	0	\N
263	17	\N	2026-04-16	10699	General	MERPAGO*PANEROMARIALAUR	1	f	2026-04-27 17:27:02.656013	2026-04-27 17:27:02.656015	ARS	\N	\N	2026-04-16	normal	0	\N
273	17	\N	2026-04-19	11500	General	3SM*SUPER WANG MEIQI	1	f	2026-04-27 17:27:02.678417	2026-04-27 17:27:02.678418	ARS	\N	\N	2026-04-19	normal	0	\N
278	17	\N	2026-04-22	1988.3	General	AUTOPISTAS DEL S 960002347045501	1	f	2026-04-27 17:27:02.691772	2026-04-27 17:27:02.691774	ARS	\N	\N	2026-04-22	normal	0	\N
283	17	\N	2026-04-23	1005.01	General	IIBB PERCEP-CABA 2.00%( 50250.62)	1	f	2026-04-27 17:27:02.703943	2026-04-27 17:27:02.703944	ARS	\N	\N	2026-04-23	normal	0	\N
268	17	\N	2026-04-16	63.74	General	AMAZON MKTPL*BS6E46T62 USD 63.74	1	f	2026-04-27 17:27:02.667493	2026-04-27 19:00:48.751642	ARS	\N	\N	2026-04-16	normal	0	\N
269	17	\N	2026-04-17	65999	General	MERPAGO*TIENDAMAGICUS (REVISAR)	1	f	2026-04-27 17:27:02.669626	2026-04-29 10:17:28.843877	ARS	\N	\N	2026-04-17	normal	0	\N
204	17	\N	2026-02-14	23581.66	General	MERPAGO*BELLEZAPERFECTA Cuota 03/06	1	f	2026-04-27 17:27:02.512054	2026-04-27 17:27:02.512058	ARS	\N	\N	2026-02-14	normal	0	\N
209	17	\N	2026-03-07	13333	General	47 STREET Cuota 02/03	1	f	2026-04-27 17:27:02.525873	2026-04-27 17:27:02.525874	ARS	\N	\N	2026-03-07	normal	0	\N
214	17	\N	2026-03-21	5.99	General	INTCH INC in1TDS5YC USD 5.99	1	f	2026-04-27 17:27:02.538535	2026-04-27 17:27:02.538537	ARS	\N	\N	2026-03-21	normal	0	\N
219	17	\N	2026-03-25	4700	General	LA FAMILIAS	1	f	2026-04-27 17:27:02.551446	2026-04-27 17:27:02.551447	ARS	\N	\N	2026-03-25	normal	0	\N
229	17	\N	2026-03-28	10	General	GITHUB  INC. P87026340USD USD 10.00	1	f	2026-04-27 17:27:02.576191	2026-04-27 17:27:02.576192	ARS	\N	\N	2026-03-28	normal	0	\N
234	17	\N	2026-04-02	68109.9	General	PROETICA FCIA GES	1	f	2026-04-27 17:27:02.58854	2026-04-27 17:27:02.588541	ARS	\N	\N	2026-04-02	normal	0	\N
239	17	\N	2026-04-07	20200	General	3SM*SUPER WANG MEIQI	1	f	2026-04-27 17:27:02.600364	2026-04-27 17:27:02.600365	ARS	\N	\N	2026-04-07	normal	0	\N
244	17	\N	2026-04-09	1069900	General	MERPAGO*SERGIOGUSTAVOSALA	1	f	2026-04-27 17:27:02.611454	2026-04-27 17:27:02.611457	ARS	\N	\N	2026-04-09	normal	0	\N
249	17	\N	2026-04-12	108066	General	MERPAGO*AXIONENERGY	1	f	2026-04-27 17:27:02.623739	2026-04-27 17:27:02.62374	ARS	\N	\N	2026-04-12	normal	0	\N
254	17	\N	2026-04-13	15300	General	3SM*SUPER WANG MEIQI	1	f	2026-04-27 17:27:02.635264	2026-04-27 17:27:02.635265	ARS	\N	\N	2026-04-13	normal	0	\N
259	17	\N	2026-04-14	53495	General	MERPAGO*JUNQUERAMARIAANGE	1	f	2026-04-27 17:27:02.646796	2026-04-27 17:27:02.646798	ARS	\N	\N	2026-04-14	normal	0	\N
264	17	\N	2026-04-16	4279.6	General	MERPAGO*JUANPEDROESPETXE	1	f	2026-04-27 17:27:02.658162	2026-04-27 17:27:02.658167	ARS	\N	\N	2026-04-16	normal	0	\N
274	17	\N	2026-04-19	2.49	General	GOOGLE *YouTube P1kvn4Se USD 2.49	1	f	2026-04-27 17:27:02.681203	2026-04-27 17:27:02.681206	ARS	\N	\N	2026-04-19	normal	0	\N
284	17	\N	2026-04-23	68.62	General	IIBB PERCEP-CABA 2.00%( 3431.22)	1	f	2026-04-27 17:27:02.706339	2026-04-27 17:27:02.70634	ARS	\N	\N	2026-04-23	normal	0	\N
224	17	\N	2026-03-27	21398	General	MERPAGO*MICAELABELENSALAN	1	f	2026-04-27 17:27:02.563953	2026-04-27 19:05:31.718409	ARS	\N	\N	2026-03-27	normal	0	\N
279	17	\N	2026-03-19	59421.44	General	DB IVA $ PLAN V	1	f	2026-04-27 17:27:02.69428	2026-04-27 19:15:07.59785	ARS	\N	\N	2026-03-19	normal	0	\N
255	17	\N	2026-04-13	3697.57	General	MERPAGO*SCABBIOLODAMIANLU (REVISAR)	1	f	2026-04-27 17:27:02.637403	2026-04-29 10:20:58.291465	ARS	\N	\N	2026-04-13	normal	0	\N
205	17	\N	2026-02-15	32500	General	GRIMOLDI Cuota 03/06	1	f	2026-04-27 17:27:02.515392	2026-04-27 17:27:02.515395	ARS	\N	\N	2026-02-15	normal	0	\N
215	17	\N	2026-03-22	9841	General	DIA TIENDA 608	1	f	2026-04-27 17:27:02.541287	2026-04-27 17:27:02.541288	ARS	\N	\N	2026-03-22	normal	0	\N
220	17	\N	2026-03-25	20	General	OPENAI *CHATGPT in1TEyNiC USD 20.00	1	f	2026-04-27 17:27:02.553612	2026-04-27 17:27:02.553613	ARS	\N	\N	2026-03-25	normal	0	\N
225	17	\N	2026-03-27	29957.2	General	MERPAGO*JOSEMARIASILVA	1	f	2026-04-27 17:27:02.567202	2026-04-27 17:27:02.567204	ARS	\N	\N	2026-03-27	normal	0	\N
230	17	\N	2026-03-30	53495	General	MERPAGO*MICAELABELENSALAN	1	f	2026-04-27 17:27:02.578462	2026-04-27 17:27:02.578463	ARS	\N	\N	2026-03-30	normal	0	\N
240	17	\N	2026-04-07	33510.25	General	PROETICA FCIA GES	1	f	2026-04-27 17:27:02.602518	2026-04-27 17:27:02.60252	ARS	\N	\N	2026-04-07	normal	0	\N
245	17	\N	2026-04-11	33300	General	3SM*SUPER WANG MEIQI	1	f	2026-04-27 17:27:02.614477	2026-04-27 17:27:02.614479	ARS	\N	\N	2026-04-11	normal	0	\N
250	17	\N	2026-04-12	8110	General	DIA TIENDA 608	1	f	2026-04-27 17:27:02.625766	2026-04-27 17:27:02.625767	ARS	\N	\N	2026-04-12	normal	0	\N
260	17	\N	2026-04-15	28887.3	General	MERPAGO*RAMONEDUARDOVILLA REMIS	1	f	2026-04-27 17:27:02.649346	2026-04-27 17:27:02.649347	ARS	\N	\N	2026-04-15	normal	0	\N
265	17	\N	2026-04-16	53495	General	MERPAGO*MICAELABELENSALAN	1	f	2026-04-27 17:27:02.660426	2026-04-27 17:27:02.660427	ARS	\N	\N	2026-04-16	normal	0	\N
270	17	\N	2026-04-18	78102.7	General	MERPAGO*JOSEMARIASILVA	1	f	2026-04-27 17:27:02.671793	2026-04-27 17:27:02.671794	ARS	\N	\N	2026-04-18	normal	0	\N
275	17	\N	2026-04-20	53495	General	MERPAGO*MICAELABELENSALAN	1	f	2026-04-27 17:27:02.68456	2026-04-27 17:27:02.684565	ARS	\N	\N	2026-04-20	normal	0	\N
280	17	\N	2026-04-23	174170.06	General	INTERESES FINANCIACION $	1	f	2026-04-27 17:27:02.696806	2026-04-27 17:27:02.696808	ARS	\N	\N	2026-04-23	normal	0	\N
285	17	\N	2026-04-23	10552.63	General	IVA RG 4240 21%( 50250.62)	1	f	2026-04-27 17:27:02.708466	2026-04-27 17:27:02.708468	ARS	\N	\N	2026-04-23	normal	0	\N
235	17	\N	2026-04-03	49.9	General	JobLeads.com Mem USD 49.90	1	f	2026-04-27 17:27:02.590712	2026-04-27 17:54:06.234841	USD	1400	69860	2026-05-03	normal	0	\N
206	17	\N	2026-02-27	10266.66	General	MERPAGO*BELLEZAPERFECTA Cuota 02/03	1	f	2026-04-27 17:27:02.518198	2026-04-27 17:27:02.518201	ARS	\N	\N	2026-02-27	normal	0	\N
216	17	\N	2026-03-24	102710.4	General	MERPAGO*JOSEMARIASILVA	1	f	2026-04-27 17:27:02.543392	2026-04-27 17:27:02.543394	ARS	\N	\N	2026-03-24	normal	0	\N
221	17	\N	2026-03-26	3144.38	General	DIA TIENDA 608	1	f	2026-04-27 17:27:02.555726	2026-04-27 17:27:02.555727	ARS	\N	\N	2026-03-26	normal	0	\N
231	17	\N	2026-03-30	4500	General	LA FAMILIAS	1	f	2026-04-27 17:27:02.58122	2026-04-27 17:27:02.581222	ARS	\N	\N	2026-03-30	normal	0	\N
236	17	\N	2026-04-04	58500	General	3SM*SUPER WANG MEIQI	1	f	2026-04-27 17:27:02.59273	2026-04-27 17:27:02.592731	ARS	\N	\N	2026-04-04	normal	0	\N
241	17	\N	2026-04-07	11287.56	General	AUTOPISTAS URBAN 000000003891363	1	f	2026-04-27 17:27:02.604702	2026-04-27 17:27:02.604703	ARS	\N	\N	2026-04-07	normal	0	\N
246	17	\N	2026-04-11	128388	General	MERPAGO*SCHENONEANDREA	1	f	2026-04-27 17:27:02.617024	2026-04-27 17:27:02.617026	ARS	\N	\N	2026-04-11	normal	0	\N
251	17	\N	2026-04-12	10699	General	MERPAGO*JUANPEDROESPET	1	f	2026-04-27 17:27:02.627971	2026-04-27 17:27:02.627973	ARS	\N	\N	2026-04-12	normal	0	\N
256	17	\N	2026-04-13	53495	General	MERPAGO*MICAELABELENSA	1	f	2026-04-27 17:27:02.639442	2026-04-27 17:27:02.639443	ARS	\N	\N	2026-04-13	normal	0	\N
261	17	\N	2026-04-15	40656.2	General	MERPAGO*PATRICIASILVANALO FONO	1	f	2026-04-27 17:27:02.651467	2026-04-27 17:27:02.651469	ARS	\N	\N	2026-04-15	normal	0	\N
266	17	\N	2026-04-16	106990	General	MERPAGO*FORTEHERNANNAHUEL	1	f	2026-04-27 17:27:02.66275	2026-04-27 17:27:02.662753	ARS	\N	\N	2026-04-16	normal	0	\N
271	17	\N	2026-04-18	21398	General	MERPAGO*JOSEMARIASILVA	1	f	2026-04-27 17:27:02.674032	2026-04-27 17:27:02.674033	ARS	\N	\N	2026-04-18	normal	0	\N
276	17	\N	2026-04-20	28459.34	General	MERPAGO*RAMONEDUARDOVILLA	1	f	2026-04-27 17:27:02.687056	2026-04-27 17:27:02.687058	ARS	\N	\N	2026-04-20	normal	0	\N
281	17	\N	2026-04-23	37696.52	General	DB IVA $ 21% 179.507.25	1	f	2026-04-27 17:27:02.699348	2026-04-27 17:27:02.69935	ARS	\N	\N	2026-04-23	normal	0	\N
286	17	\N	2026-04-23	720.55	General	IVA RG 4240 21%( 3431.22)	1	f	2026-04-27 17:27:02.710703	2026-04-27 17:27:02.710704	ARS	\N	\N	2026-04-23	normal	0	\N
226	17	\N	2026-03-27	12270	General	SUCU 405	1	f	2026-04-27 17:27:02.569614	2026-04-27 19:04:26.190807	ARS	\N	\N	2026-03-27	normal	0	\N
207	17	\N	2026-03-04	25666.66	General	MERPAGO*VASSALLOCABALLITO Cuota 02/06	1	f	2026-04-27 17:27:02.521324	2026-04-27 17:27:02.521326	ARS	\N	\N	2026-03-04	normal	0	\N
217	17	\N	2026-03-24	10699	General	MERPAGO*JUANPEDROESPETXE	1	f	2026-04-27 17:27:02.546338	2026-04-27 17:27:02.546341	ARS	\N	\N	2026-03-24	normal	0	\N
222	17	\N	2026-03-26	20000	General	SERVICENTRO ALMAFUERTE	1	f	2026-04-27 17:27:02.557839	2026-04-27 17:27:02.55784	ARS	\N	\N	2026-03-26	normal	0	\N
11	1	\N	2026-02-20	3000	General	DIONE LINIERS	1	f	2026-03-27 22:40:49.171351	2026-03-27 22:40:49.171351	ARS	\N	\N	2026-02-20	normal	0	\N
12	1	\N	2026-02-20	1677.86	General	AUTOPISTA DEL OESTE	1	f	2026-03-27 22:40:49.177732	2026-03-27 22:40:49.177732	ARS	\N	\N	2026-02-20	normal	0	\N
13	1	\N	2026-02-20	1250	General	KASHUKO	1	f	2026-03-27 22:40:49.181727	2026-03-27 22:40:49.181727	ARS	\N	\N	2026-02-20	normal	0	\N
14	1	\N	2026-02-20	21000	General	AVANNA LINIERS	1	f	2026-03-27 22:40:49.190986	2026-03-27 22:40:49.190986	ARS	\N	\N	2026-02-20	normal	0	\N
15	1	\N	2026-02-20	15000	General	LA CASA DE LAS MEDIAS	1	f	2026-03-27 22:40:49.19788	2026-03-27 22:40:49.19788	ARS	\N	\N	2026-02-20	normal	0	\N
16	1	\N	2026-02-24	15000	General	47 STREET	1	f	2026-03-27 22:40:49.204045	2026-03-27 22:40:49.204045	ARS	\N	\N	2026-02-24	normal	0	\N
17	1	\N	2026-02-24	7245.09	General	AUTOPISTAS URBANAS	1	f	2026-03-27 22:40:49.211779	2026-03-27 22:40:49.211779	ARS	\N	\N	2026-02-24	normal	0	\N
18	1	\N	2026-02-25	17381.4	General	ADOBE.COM	1	f	2026-03-27 22:40:49.220344	2026-03-27 22:40:49.220344	ARS	\N	\N	2026-02-25	normal	0	\N
19	1	\N	2026-02-25	17351.4	General	OPENAI CHATGPT	1	f	2026-03-27 22:40:49.22605	2026-03-27 22:40:49.22605	ARS	\N	\N	2026-02-25	normal	0	\N
20	1	\N	2026-02-27	10266.68	General	MERPAGO BELLEZAPERFECTA	1	f	2026-03-27 22:40:49.231565	2026-03-27 22:40:49.231565	ARS	\N	\N	2026-02-27	normal	0	\N
21	1	\N	2026-03-01	64900	General	3M SUPER WANG MEIQI	1	f	2026-03-27 22:40:49.238736	2026-03-27 22:40:49.238736	ARS	\N	\N	2026-03-01	normal	0	\N
22	1	\N	2026-03-01	30500	General	LIBRERIA ABC LINIERS	1	f	2026-03-27 22:40:49.247232	2026-03-27 22:40:49.247232	ARS	\N	\N	2026-03-01	normal	0	\N
25	1	\N	2026-03-02	2890	General	TUSCLASES	1	f	2026-03-27 22:40:49.269179	2026-03-27 22:40:49.269179	ARS	\N	\N	2026-03-02	normal	0	\N
26	1	\N	2026-03-02	2670	General	TUSCLASES	1	f	2026-03-27 22:40:49.275615	2026-03-27 22:40:49.275615	ARS	\N	\N	2026-03-02	normal	0	\N
27	1	\N	2026-03-03	27000	General	3M SUPER WANG MEIQI	1	f	2026-03-27 22:40:49.282012	2026-03-27 22:40:49.282012	ARS	\N	\N	2026-03-03	normal	0	\N
28	1	\N	2026-03-04	25666.7	General	MERPAGO VASSALLOCABALLITO	1	f	2026-03-27 22:40:49.288318	2026-03-27 22:40:49.288318	ARS	\N	\N	2026-03-04	normal	0	\N
29	1	\N	2026-03-04	1976.43	General	AUTOPISTAS URBANAS	1	f	2026-03-27 22:40:49.294357	2026-03-27 22:40:49.294357	ARS	\N	\N	2026-03-04	normal	0	\N
30	1	\N	2026-03-05	56809.55	General	MERPAGO MARTELAINESAGUSTI	1	f	2026-03-27 22:40:49.300226	2026-03-27 22:40:49.300226	ARS	\N	\N	2026-03-05	normal	0	\N
31	1	\N	2026-03-05	84227	General	SERVICENTRO ALMAFUERTE	1	f	2026-03-27 22:40:49.307892	2026-03-27 22:40:49.307892	ARS	\N	\N	2026-03-05	normal	0	\N
32	1	\N	2026-03-05	12982.19	General	DIA TIENDA 930	1	f	2026-03-27 22:40:49.312902	2026-03-27 22:40:49.312902	ARS	\N	\N	2026-03-05	normal	0	\N
33	1	\N	2026-03-06	53495.1	General	MERPAGO MICAELABELENSALAN	1	f	2026-03-27 22:40:49.31892	2026-03-27 22:40:49.31892	ARS	\N	\N	2026-03-06	normal	0	\N
34	1	\N	2026-03-06	3700	General	MERPAGO MUZARELLA	1	f	2026-03-27 22:40:49.326177	2026-03-27 22:40:49.326177	ARS	\N	\N	2026-03-06	normal	0	\N
35	1	\N	2026-03-07	33299.99	General	3M ECOMAX MARKET	1	f	2026-03-27 22:40:49.333724	2026-03-27 22:40:49.333724	ARS	\N	\N	2026-03-07	normal	0	\N
36	1	\N	2026-03-07	6199.99	General	3M ECOMAX MARKET	1	f	2026-03-27 22:40:49.341088	2026-03-27 22:40:49.341088	ARS	\N	\N	2026-03-07	normal	0	\N
37	1	\N	2026-03-07	2139800	General	MERPAGO SERGIOGUSTAVOSALA	1	f	2026-03-27 22:40:49.34608	2026-03-27 22:40:49.34608	ARS	\N	\N	2026-03-07	normal	0	\N
38	1	\N	2026-03-07	106990	General	MERPAGO FORTEHERNANNAHUEL	1	f	2026-03-27 22:40:49.351733	2026-03-27 22:40:49.351733	ARS	\N	\N	2026-03-07	normal	0	\N
39	1	\N	2026-03-07	219329.5	General	MERPAGO MICAELABELENSALAN	1	f	2026-03-27 22:40:49.357269	2026-03-27 22:40:49.357269	ARS	\N	\N	2026-03-07	normal	0	\N
40	1	\N	2026-03-08	33433.34	General	COMO QUIERES QUE TE QU	1	f	2026-03-27 22:40:49.363284	2026-03-27 22:40:49.363284	ARS	\N	\N	2026-03-08	normal	0	\N
41	1	\N	2026-03-08	13333	General	47 STREET	1	f	2026-03-27 22:40:49.36873	2026-03-27 22:40:49.36873	ARS	\N	\N	2026-03-08	normal	0	\N
42	1	\N	2026-03-08	44700	General	3M SUPER WANG MEIQI	1	f	2026-03-27 22:40:49.374749	2026-03-27 22:40:49.374749	ARS	\N	\N	2026-03-08	normal	0	\N
43	1	\N	2026-03-08	64194	General	MERPAGO PAULAGABRIELATABO	1	f	2026-03-27 22:40:49.380834	2026-03-27 22:40:49.380834	ARS	\N	\N	2026-03-08	normal	0	\N
44	1	\N	2026-03-08	67403.7	General	MERPAGO JOSEMARIASILVA	1	f	2026-03-27 22:40:49.386863	2026-03-27 22:40:49.386863	ARS	\N	\N	2026-03-08	normal	0	\N
45	1	\N	2026-03-08	9792	General	DIA TIENDA 608	1	f	2026-03-27 22:40:49.392526	2026-03-27 22:40:49.392526	ARS	\N	\N	2026-03-08	normal	0	\N
232	17	\N	2026-03-31	25666.7	General	MERPAGO*VASSALLOCABALLITO Cuota 01/06	1	f	2026-04-27 17:27:02.583713	2026-04-27 17:27:02.583715	ARS	\N	\N	2026-03-31	normal	0	\N
237	17	\N	2026-04-06	54999	General	MERPAGO*MERCADOLIBRE	1	f	2026-04-27 17:27:02.595147	2026-04-27 17:27:02.595149	ARS	\N	\N	2026-04-06	normal	0	\N
247	17	\N	2026-04-11	2674.75	General	MERPAGO*IVANPOLO	1	f	2026-04-27 17:27:02.619251	2026-04-27 17:27:02.619253	ARS	\N	\N	2026-04-11	normal	0	\N
252	17	\N	2026-04-12	51355.2	General	MERPAGO*JOSEMARIASILVA	1	f	2026-04-27 17:27:02.630624	2026-04-27 17:27:02.630626	ARS	\N	\N	2026-04-12	normal	0	\N
46	1	\N	2026-03-08	9792	General	DIA TIENDA 608	1	f	2026-03-27 22:40:49.400065	2026-03-27 22:40:49.400065	ARS	\N	\N	2026-03-08	normal	0	\N
47	1	\N	2026-03-09	11845.4	General	GOOGLE	1	f	2026-03-27 22:40:49.405626	2026-03-27 22:40:49.405626	ARS	\N	\N	2026-03-09	normal	0	\N
48	1	\N	2026-03-09	55634.8	General	MERPAGO JULIOCESARGOMEZ	1	f	2026-03-27 22:40:49.412598	2026-03-27 22:40:49.412598	ARS	\N	\N	2026-03-09	normal	0	\N
49	1	\N	2026-03-09	53495.1	General	MERPAGO MICAELABELENSALAN	1	f	2026-03-27 22:40:49.419441	2026-03-27 22:40:49.419441	ARS	\N	\N	2026-03-09	normal	0	\N
63	1	\N	2026-03-19	834.09	General	IIBB PERCEP-CABA 2,00%( 41704,58)	1	f	2026-03-30 22:15:58.198235	2026-03-30 22:15:58.198235	ARS	\N	\N	2026-03-19	normal	0	\N
64	1	\N	2026-03-19	8757.96	General	IVA RG 4240 21%( 41704,58)	1	f	2026-03-30 22:16:38.496253	2026-03-30 22:16:38.496253	ARS	\N	\N	2026-03-19	normal	0	\N
1	1	\N	2026-01-09	4320393.95	General	VISA PLAN V	12	t	2026-03-26 17:28:38.895372	2026-03-30 19:05:12.101146	ARS	\N	\N	2026-01-09	normal	0	\N
54	1	\N	2025-07-03	700000	General	MERPAGO*BEDTIME   	12	t	2026-03-30 21:42:58.444751	2026-03-30 21:42:58.444751	ARS	\N	\N	2025-07-03	normal	0	\N
24	1	\N	2026-03-01	4.32	General	GITHUB	1	f	2026-03-27 22:40:49.261894	2026-03-30 14:38:36.713995	USD	1400	6048	2026-04-01	normal	0	\N
23	1	\N	2026-03-01	10.16	General	GITHUB	1	f	2026-03-27 22:40:49.254236	2026-03-30 14:40:00.014071	USD	1400	14224	2026-04-01	normal	0	\N
55	1	\N	2026-03-05	54135.75	General	TRANSFERENCIA DEUDA  	1	f	2026-03-30 21:45:09.976528	2026-03-30 21:45:09.976528	ARS	\N	\N	2026-03-05	normal	0	\N
56	1	\N	2025-10-04	120516.96	General	MERPAGO*VASSALLOCABALL	6	t	2026-03-30 21:47:30.751378	2026-03-30 21:47:30.751378	ARS	\N	\N	2025-10-04	normal	0	\N
65	1	\N	2026-03-19	23533.37	General	DB.RG 5617 30% ( 78444,58 )	1	f	2026-03-30 22:17:27.806829	2026-03-30 22:17:27.806829	ARS	\N	\N	2026-03-19	normal	0	\N
58	1	\N	2025-11-11	804000	General	OSBA	6	t	2026-03-30 21:58:50.125364	2026-03-30 21:59:03.709234	ARS	\N	\N	2025-11-11	normal	0	\N
59	1	\N	2026-02-13	59421.44	General	DB IVA $ PLAN V 834023282959,27	1	f	2026-03-30 22:12:27.113857	2026-03-30 22:12:27.113857	ARS	\N	\N	2026-02-13	normal	0	\N
60	1	\N	2026-03-19	2961.72	General	DB IVA $ 21% 14.103,48	1	f	2026-03-30 22:14:03.718791	2026-03-30 22:14:03.718791	ARS	\N	\N	2026-03-19	normal	0	\N
61	1	\N	2026-03-19	8766.29	General	INTERESES FINANCIACION $	1	f	2026-03-30 22:14:44.25832	2026-03-30 22:14:44.25832	ARS	\N	\N	2026-03-19	normal	0	\N
106	9	\N	2026-03-26	15724.22	General	INTERESES FINANCIACION	1	f	2026-04-07 19:49:53.418949	2026-04-07 19:49:53.418949	ARS	\N	\N	2026-03-26	normal	0	\N
107	9	\N	2026-03-26	1540.89	General	PUNIT. PAG.MIN.ANTERIOR	1	f	2026-04-07 19:49:53.424972	2026-04-07 19:49:53.424972	ARS	\N	\N	2026-03-26	normal	0	\N
109	9	\N	2026-03-01	37190.08	General	COMISION PAQUETE	1	f	2026-04-07 19:53:29.334168	2026-04-07 19:53:29.334168	ARS	\N	\N	2026-03-01	normal	0	\N
110	9	\N	2026-03-07	217743.78	General	Saldo Anterior	1	f	2026-04-07 19:55:36.441461	2026-04-07 19:55:36.441461	ARS	\N	\N	2026-03-07	normal	0	\N
111	1	\N	2026-03-03	77430.75	General	SALDO ANTERIOR	1	f	2026-04-08 12:59:26.041272	2026-04-08 12:59:26.041272	ARS	\N	\N	2026-03-03	normal	0	\N
113	17	\N	2026-03-19	5337.19	General	COM.ADM.Y LIQ.DE CUENTA	1	f	2026-04-13 22:37:30.241355	2026-04-13 22:37:30.241355	ARS	\N	\N	2026-03-19	normal	0	\N
114	17	\N	2026-02-14	2381.66	General	MERPAGO BELLEZAPERFECTA	1	f	2026-04-13 22:37:30.243381	2026-04-13 22:37:30.243381	ARS	\N	\N	2026-02-14	normal	0	\N
115	17	\N	2026-02-01	3200	General	GRIMOLDI	1	f	2026-04-13 22:37:30.245381	2026-04-13 22:37:30.245381	ARS	\N	\N	2026-02-01	normal	0	\N
116	17	\N	2026-02-19	10000	General	LIBRERIA LA MILAGROSA	1	f	2026-04-13 22:37:30.246381	2026-04-13 22:37:30.246381	ARS	\N	\N	2026-02-19	normal	0	\N
117	17	\N	2026-02-20	1677.86	General	AUTOPISTA DEL OESTE	1	f	2026-04-13 22:37:30.248381	2026-04-13 22:37:30.248381	ARS	\N	\N	2026-02-20	normal	0	\N
118	17	\N	2026-02-14	23581.66	General	MERPAGO BELLEZAPERFECTA	1	f	2026-04-13 22:37:30.250381	2026-04-13 22:37:30.250381	ARS	\N	\N	2026-02-14	normal	0	\N
119	17	\N	2026-02-15	32500	General	GRIMOLDI	1	f	2026-04-13 22:37:30.253009	2026-04-13 22:37:30.253009	ARS	\N	\N	2026-02-15	normal	0	\N
120	17	\N	2026-02-19	10000	General	LIBRERIA LA MILAGROSA	1	f	2026-04-13 22:37:30.255014	2026-04-13 22:37:30.255014	ARS	\N	\N	2026-02-19	normal	0	\N
121	17	\N	2026-02-20	3000	General	DIONE LINIERS	1	f	2026-04-13 22:37:30.257014	2026-04-13 22:37:30.257014	ARS	\N	\N	2026-02-20	normal	0	\N
122	17	\N	2026-02-20	1677.86	General	AUTOPISTA DEL OESTE	1	f	2026-04-13 22:37:30.259015	2026-04-13 22:37:30.259015	ARS	\N	\N	2026-02-20	normal	0	\N
123	17	\N	2026-02-20	1250	General	KASHUKO	1	f	2026-04-13 22:37:30.261014	2026-04-13 22:37:30.261014	ARS	\N	\N	2026-02-20	normal	0	\N
124	17	\N	2026-02-20	21000	General	AVANNA LINIERS	1	f	2026-04-13 22:37:30.262522	2026-04-13 22:37:30.262522	ARS	\N	\N	2026-02-20	normal	0	\N
125	17	\N	2026-02-20	15000	General	LA CASA DE LAS MEDIAS	1	f	2026-04-13 22:37:30.264524	2026-04-13 22:37:30.264524	ARS	\N	\N	2026-02-20	normal	0	\N
126	17	\N	2026-02-24	15000	General	47 STREET	1	f	2026-04-13 22:37:30.26693	2026-04-13 22:37:30.26693	ARS	\N	\N	2026-02-24	normal	0	\N
127	17	\N	2026-02-24	7245.09	General	AUTOPISTAS URBANAS	1	f	2026-04-13 22:37:30.269443	2026-04-13 22:37:30.269443	ARS	\N	\N	2026-02-24	normal	0	\N
128	17	\N	2026-02-25	17381.4	General	ADOBE.COM	1	f	2026-04-13 22:37:30.271444	2026-04-13 22:37:30.271444	ARS	\N	\N	2026-02-25	normal	0	\N
129	17	\N	2026-02-25	17351.4	General	OPENAI CHATGPT	1	f	2026-04-13 22:37:30.273753	2026-04-13 22:37:30.273753	ARS	\N	\N	2026-02-25	normal	0	\N
130	17	\N	2026-02-27	10266.68	General	MERPAGO BELLEZAPERFECTA	1	f	2026-04-13 22:37:30.276537	2026-04-13 22:37:30.276537	ARS	\N	\N	2026-02-27	normal	0	\N
131	17	\N	2026-03-01	64900	General	3M SUPER WANG MEIQI	1	f	2026-04-13 22:37:30.279041	2026-04-13 22:37:30.279041	ARS	\N	\N	2026-03-01	normal	0	\N
132	17	\N	2026-03-01	30500	General	LIBRERIA ABC LINIERS	1	f	2026-04-13 22:37:30.281469	2026-04-13 22:37:30.281469	ARS	\N	\N	2026-03-01	normal	0	\N
133	17	\N	2026-03-02	2890	General	TUSCLASES	1	f	2026-04-13 22:37:30.285165	2026-04-13 22:37:30.285165	ARS	\N	\N	2026-03-02	normal	0	\N
134	17	\N	2026-03-02	2670	General	TUSCLASES	1	f	2026-04-13 22:37:30.286681	2026-04-13 22:37:30.286681	ARS	\N	\N	2026-03-02	normal	0	\N
135	17	\N	2026-03-03	27000	General	3M SUPER WANG MEIQI	1	f	2026-04-13 22:37:30.290701	2026-04-13 22:37:30.290701	ARS	\N	\N	2026-03-03	normal	0	\N
136	17	\N	2026-03-04	25666.7	General	MERPAGO VASSALLOCABALLITO	1	f	2026-04-13 22:37:30.293146	2026-04-13 22:37:30.293146	ARS	\N	\N	2026-03-04	normal	0	\N
137	17	\N	2026-03-04	1976.43	General	AUTOPISTAS URBANAS	1	f	2026-04-13 22:37:30.29576	2026-04-13 22:37:30.29576	ARS	\N	\N	2026-03-04	normal	0	\N
139	17	\N	2026-03-05	84227	General	SERVICENTRO ALMAFUERTE	1	f	2026-04-13 22:37:30.30409	2026-04-13 22:37:30.30409	ARS	\N	\N	2026-03-05	normal	0	\N
140	17	\N	2026-03-05	12982.19	General	DIA TIENDA 930	1	f	2026-04-13 22:37:30.307123	2026-04-13 22:37:30.307123	ARS	\N	\N	2026-03-05	normal	0	\N
141	17	\N	2026-03-06	53495.1	General	MERPAGO MICAELABELENSALAN	1	f	2026-04-13 22:37:30.31013	2026-04-13 22:37:30.31013	ARS	\N	\N	2026-03-06	normal	0	\N
142	17	\N	2026-03-06	3700	General	MERPAGO MUZARELLA	1	f	2026-04-13 22:37:30.312622	2026-04-13 22:37:30.312622	ARS	\N	\N	2026-03-06	normal	0	\N
143	17	\N	2026-03-07	33299.99	General	3M ECOMAX MARKET	1	f	2026-04-13 22:37:30.316318	2026-04-13 22:37:30.316318	ARS	\N	\N	2026-03-07	normal	0	\N
144	17	\N	2026-03-07	6199.99	General	3M ECOMAX MARKET	1	f	2026-04-13 22:37:30.318763	2026-04-13 22:37:30.318763	ARS	\N	\N	2026-03-07	normal	0	\N
145	17	\N	2026-03-07	2139800	General	MERPAGO SERGIOGUSTAVOSALA	1	f	2026-04-13 22:37:30.322234	2026-04-13 22:37:30.322234	ARS	\N	\N	2026-03-07	normal	0	\N
146	17	\N	2026-03-07	106990	General	MERPAGO FORTEHERNANNAHUEL	1	f	2026-04-13 22:37:30.32533	2026-04-13 22:37:30.32533	ARS	\N	\N	2026-03-07	normal	0	\N
147	17	\N	2026-03-07	219329.5	General	MERPAGO MICAELABELENSALAN	1	f	2026-04-13 22:37:30.328074	2026-04-13 22:37:30.328074	ARS	\N	\N	2026-03-07	normal	0	\N
148	17	\N	2026-03-08	33433.34	General	COMO QUIERES QUE TE QU	1	f	2026-04-13 22:37:30.331905	2026-04-13 22:37:30.331905	ARS	\N	\N	2026-03-08	normal	0	\N
149	17	\N	2026-03-08	13333	General	47 STREET	1	f	2026-04-13 22:37:30.334433	2026-04-13 22:37:30.334433	ARS	\N	\N	2026-03-08	normal	0	\N
150	17	\N	2026-03-08	44700	General	3M SUPER WANG MEIQI	1	f	2026-04-13 22:37:30.3374	2026-04-13 22:37:30.3374	ARS	\N	\N	2026-03-08	normal	0	\N
151	17	\N	2026-03-08	64194	General	MERPAGO PAULAGABRIELATABO	1	f	2026-04-13 22:37:30.34003	2026-04-13 22:37:30.34003	ARS	\N	\N	2026-03-08	normal	0	\N
152	17	\N	2026-03-08	67403.7	General	MERPAGO JOSEMARIASILVA	1	f	2026-04-13 22:37:30.34319	2026-04-13 22:37:30.34319	ARS	\N	\N	2026-03-08	normal	0	\N
153	17	\N	2026-03-08	9792	General	DIA TIENDA 608	1	f	2026-04-13 22:37:30.346982	2026-04-13 22:37:30.346982	ARS	\N	\N	2026-03-08	normal	0	\N
154	17	\N	2026-03-08	9792	General	DIA TIENDA 608	1	f	2026-04-13 22:37:30.349638	2026-04-13 22:37:30.349638	ARS	\N	\N	2026-03-08	normal	0	\N
155	17	\N	2026-03-09	11845.4	General	GOOGLE	1	f	2026-04-13 22:37:30.352817	2026-04-13 22:37:30.352817	ARS	\N	\N	2026-03-09	normal	0	\N
156	17	\N	2026-03-09	55634.8	General	MERPAGO JULIOCESARGOMEZ	1	f	2026-04-13 22:37:30.355606	2026-04-13 22:37:30.355606	ARS	\N	\N	2026-03-09	normal	0	\N
157	17	\N	2026-03-09	53495.1	General	MERPAGO MICAELABELENSALAN	1	f	2026-04-13 22:37:30.358248	2026-04-13 22:37:30.358248	ARS	\N	\N	2026-03-09	normal	0	\N
158	17	\N	2026-03-19	834.09	General	IIBB PERCEP-CABA 2,00%( 41704,58)	1	f	2026-04-13 22:37:30.361486	2026-04-13 22:37:30.361486	ARS	\N	\N	2026-03-19	normal	0	\N
159	17	\N	2026-03-19	8757.96	General	IVA RG 4240 21%( 41704,58)	1	f	2026-04-13 22:37:30.364638	2026-04-13 22:37:30.364638	ARS	\N	\N	2026-03-19	normal	0	\N
160	17	\N	2026-01-09	4320393.95	General	VISA PLAN V	12	t	2026-04-13 22:37:30.367161	2026-04-13 22:37:30.367161	ARS	\N	\N	2026-01-09	normal	0	\N
161	17	\N	2025-07-03	700000	General	MERPAGO*BEDTIME   	12	t	2026-04-13 22:37:30.384939	2026-04-13 22:37:30.38545	ARS	\N	\N	2025-07-03	normal	0	\N
164	17	\N	2026-03-05	54135.75	General	TRANSFERENCIA DEUDA  	1	f	2026-04-13 22:37:30.418899	2026-04-13 22:37:30.418899	ARS	\N	\N	2026-03-05	normal	0	\N
165	17	\N	2025-10-04	120516.96	General	MERPAGO*VASSALLOCABALL	6	t	2026-04-13 22:37:30.422746	2026-04-13 22:37:30.422746	ARS	\N	\N	2025-10-04	normal	0	\N
166	17	\N	2026-03-19	23533.37	General	DB.RG 5617 30% ( 78444,58 )	1	f	2026-04-13 22:37:30.430635	2026-04-13 22:37:30.430635	ARS	\N	\N	2026-03-19	normal	0	\N
168	17	\N	2026-02-13	59421.44	General	DB IVA $ PLAN V 834023282959,27	1	f	2026-04-13 22:37:30.444664	2026-04-13 22:37:30.444664	ARS	\N	\N	2026-02-13	normal	0	\N
169	17	\N	2026-03-19	2961.72	General	DB IVA $ 21% 14.103,48	1	f	2026-04-13 22:37:30.449173	2026-04-13 22:37:30.449173	ARS	\N	\N	2026-03-19	normal	0	\N
170	17	\N	2026-03-19	8766.29	General	INTERESES FINANCIACION $	1	f	2026-04-13 22:37:30.452173	2026-04-13 22:37:30.452173	ARS	\N	\N	2026-03-19	normal	0	\N
171	17	\N	2026-03-09	22648.49	General	DLOCAL*NETFLIX C	1	f	2026-04-13 22:37:30.455194	2026-04-13 22:37:30.455194	ARS	\N	\N	2026-03-09	normal	0	\N
172	17	\N	2026-03-13	3300	General	TUSCLASES	1	f	2026-04-13 22:37:30.457703	2026-04-13 22:37:30.457703	ARS	\N	\N	2026-03-13	normal	0	\N
173	17	\N	2026-03-16	3200	General	LA FAMILIAS	1	f	2026-04-13 22:37:30.460734	2026-04-13 22:37:30.460734	ARS	\N	\N	2026-03-16	normal	0	\N
174	17	\N	2026-03-18	1925.82	General	MERPAGO*GUOBINWEI	1	f	2026-04-13 22:37:30.463724	2026-04-13 22:37:30.463724	ARS	\N	\N	2026-03-18	normal	0	\N
175	17	\N	2026-03-18	4700	General	LA FAMILIAS	1	f	2026-04-13 22:37:30.465723	2026-04-13 22:37:30.465723	ARS	\N	\N	2026-03-18	normal	0	\N
176	17	\N	2026-03-09	96291	General	MERPAGO*SERGIOGUSTAVOSALA	1	f	2026-04-13 22:37:30.468768	2026-04-13 22:37:30.468768	ARS	\N	\N	2026-03-09	normal	0	\N
178	17	\N	2026-03-16	2875	General	MERPAGO*MAXIKIOSCO	1	f	2026-04-13 22:37:30.475799	2026-04-13 22:37:30.475799	ARS	\N	\N	2026-03-16	normal	0	\N
179	17	\N	2026-03-18	38516.4	General	MERPAGO*PRISCILASOFIASANC	1	f	2026-04-13 22:37:30.478306	2026-04-13 22:37:30.478306	ARS	\N	\N	2026-03-18	normal	0	\N
180	17	\N	2026-03-18	38516.4	General	MERPAGO*ALEJANDRAVANES	1	f	2026-04-13 22:37:30.481308	2026-04-13 22:37:30.481308	ARS	\N	\N	2026-03-18	normal	0	\N
181	17	\N	2026-03-03	77430.75	General	SALDO ANTERIOR	1	f	2026-04-13 22:37:30.483913	2026-04-13 22:37:30.483913	ARS	\N	\N	2026-03-03	normal	0	\N
182	20	\N	2026-02-17	12976.32	General	DIA TIENDA 608	1	f	2026-04-13 22:37:30.51298	2026-04-13 22:37:30.51298	ARS	\N	\N	2026-02-17	normal	0	\N
183	20	\N	2026-02-26	10802.86	General	INTERESES FINANCIACION $	1	f	2026-04-13 22:37:30.516709	2026-04-13 22:37:30.516709	ARS	\N	\N	2026-02-26	normal	0	\N
184	20	\N	2026-02-26	943.3	General	PUNIT. PAG.MIN.ANT.ANTER. $	1	f	2026-04-13 22:37:30.519276	2026-04-13 22:37:30.519276	ARS	\N	\N	2026-02-26	normal	0	\N
185	20	\N	2026-02-10	15990	General	ASISTENCIA HOG0000000328000-000-000	1	f	2026-04-13 22:37:30.523028	2026-04-13 22:37:30.523028	ARS	\N	\N	2026-02-10	normal	0	\N
186	20	\N	2026-01-31	37190.08	General	COMISION PAQUETE	1	f	2026-04-13 22:37:30.525434	2026-04-13 22:37:30.525434	ARS	\N	\N	2026-01-31	normal	0	\N
187	20	\N	2026-01-21	9996.66	General	LUARDO S A C.03/03	1	f	2026-04-13 22:37:30.52779	2026-04-13 22:37:30.52779	ARS	\N	\N	2026-01-21	normal	0	\N
188	20	\N	2026-02-04	202215.65	General	Saldo Anterior	1	f	2026-04-13 22:37:30.531315	2026-04-13 22:37:30.531315	ARS	\N	\N	2026-02-04	normal	0	\N
189	20	\N	2026-02-26	10276.61	General	DB IVA $21%	1	f	2026-04-13 22:37:30.533755	2026-04-13 22:37:30.533755	ARS	\N	\N	2026-02-26	normal	0	\N
190	20	\N	2026-02-06	17351.4	General	ADOBE	1	f	2026-04-13 22:37:30.536966	2026-04-13 22:37:30.536966	ARS	\N	\N	2026-02-06	normal	0	\N
191	20	\N	2026-02-21	9996.66	General	LUARDO S A C.03/03	1	f	2026-04-13 22:37:30.53997	2026-04-13 22:37:30.53997	ARS	\N	\N	2026-02-21	normal	0	\N
192	20	\N	2026-03-10	17399.9	General	ASISTENCIA HOG0000000328000-000-000	1	f	2026-04-13 22:37:30.542549	2026-04-13 22:37:30.542549	ARS	\N	\N	2026-03-10	normal	0	\N
193	20	\N	2026-03-26	15724.22	General	INTERESES FINANCIACION	1	f	2026-04-13 22:37:30.545663	2026-04-13 22:37:30.545663	ARS	\N	\N	2026-03-26	normal	0	\N
194	20	\N	2026-03-26	1540.89	General	PUNIT. PAG.MIN.ANTERIOR	1	f	2026-04-13 22:37:30.550459	2026-04-13 22:37:30.550459	ARS	\N	\N	2026-03-26	normal	0	\N
196	20	\N	2026-03-01	37190.08	General	COMISION PAQUETE	1	f	2026-04-13 22:37:30.557935	2026-04-13 22:37:30.557935	ARS	\N	\N	2026-03-01	normal	0	\N
197	20	\N	2026-03-07	217743.78	General	Saldo Anterior	1	f	2026-04-13 22:37:30.562347	2026-04-13 22:37:30.562347	ARS	\N	\N	2026-03-07	normal	0	\N
198	21	\N	2026-04-12	274024.76	General	Compra Mensual Disco	1	f	2026-04-13 22:43:41.943504	2026-04-13 22:43:41.943504	ARS	\N	\N	2026-04-12	normal	0	\N
199	17	\N	2026-04-06	53020	General	TRANSFERENCIA DEUDA 37.47 TC1415	1	f	2026-04-27 17:27:02.476115	2026-04-27 17:27:02.476117	ARS	\N	\N	2026-04-06	normal	0	\N
200	17	\N	2025-07-06	58333.33	General	MERPAGO*BEDTIME Cuota 10/12	1	f	2026-04-27 17:27:02.493808	2026-04-27 17:27:02.493812	ARS	\N	\N	2025-07-06	normal	0	\N
201	17	\N	2025-11-11	134000	General	OSBA Cuota 06/06	1	f	2026-04-27 17:27:02.499627	2026-04-27 17:27:02.49963	ARS	\N	\N	2025-11-11	normal	0	\N
202	17	\N	2025-12-05	30131.66	General	DEVOTO SHOPPING LOCA Cuota 05/06	1	f	2026-04-27 17:27:02.504254	2026-04-27 17:27:02.504257	ARS	\N	\N	2025-12-05	normal	0	\N
162	17	\N	2026-03-01	4.32	General	GITHUB	1	f	2026-04-13 22:37:30.406739	2026-04-27 18:59:24.895567	ARS	\N	\N	2026-03-01	normal	0	\N
163	17	\N	2026-03-01	10.16	General	GITHUB	1	f	2026-04-13 22:37:30.415194	2026-04-27 18:59:30.35549	ARS	\N	\N	2026-03-01	normal	0	\N
257	17	\N	2026-04-14	21398	General	MERPAGO*JOSEMARIASILVA	1	f	2026-04-27 17:27:02.641645	2026-04-27 17:27:02.641646	ARS	\N	\N	2026-04-14	normal	0	\N
262	17	\N	2026-04-16	42796	General	MERPAGO*PANEROMARIALAUR	1	f	2026-04-27 17:27:02.653617	2026-04-27 17:27:02.653619	ARS	\N	\N	2026-04-16	normal	0	\N
267	17	\N	2026-04-16	59	General	Kindle Svcs*BS8KX1TX2 USD 59.00	1	f	2026-04-27 17:27:02.665164	2026-04-27 17:27:02.665165	ARS	\N	\N	2026-04-16	normal	0	\N
277	17	\N	2026-04-21	102008.01	General	AXION EMILIO CASTRO	1	f	2026-04-27 17:27:02.689493	2026-04-27 17:27:02.689495	ARS	\N	\N	2026-04-21	normal	0	\N
282	17	\N	2026-04-23	5337.19	General	COM.ADM.Y LIQ.DE CUENTA	1	f	2026-04-27 17:27:02.701691	2026-04-27 17:27:02.701693	ARS	\N	\N	2026-04-23	normal	0	\N
287	17	\N	2026-04-23	100444.26	General	DB.RG 5617 30% ( 334814.20 )	1	f	2026-04-27 17:27:02.713318	2026-04-27 17:27:02.71332	ARS	\N	\N	2026-04-23	normal	0	\N
288	17	\N	2026-04-06	4686634.69	General	SALDO ANTERIOR	1	f	2026-04-27 18:26:46.005652	2026-04-27 18:26:46.005655	ARS	\N	\N	2026-04-06	normal	0	\N
289	17	\N	2026-03-20	4279.6	General	MERPAGO*JUANPEDROESPETXE	1	f	2026-04-27 18:26:46.014658	2026-04-27 18:26:46.014661	ARS	\N	\N	2026-03-20	normal	0	\N
290	17	\N	2026-03-20	80242.5	General	MERPAGO*PRISCILASOFIASANC	1	f	2026-04-27 18:26:46.019425	2026-04-27 18:26:46.019428	ARS	\N	\N	2026-03-20	normal	0	\N
291	17	\N	2026-03-20	21118.1	General	MERPAGO*SUPERDIA	1	f	2026-04-27 18:26:46.023772	2026-04-27 18:26:46.023774	ARS	\N	\N	2026-03-20	normal	0	\N
292	17	\N	2026-03-11	15000	General	MERPAGO*FEDERICO	1	f	2026-04-27 18:50:59.829124	2026-04-27 18:50:59.829131	ARS	\N	\N	2026-03-11	normal	0	\N
242	17	\N	2026-04-08	2.99	General	GOOGLE *Google O P1kacozK USD 2.99	1	f	2026-04-27 17:27:02.606712	2026-04-27 19:01:03.270553	ARS	\N	\N	2026-04-08	normal	0	\N
293	17	\N	2026-03-19	55637.47	General	DB IVA $ PLAN V 	1	f	2026-04-27 19:16:54.454058	2026-04-27 19:16:54.454061	ARS	\N	\N	2026-03-19	normal	0	\N
294	17	\N	2026-04-27	70744.98	General	MERPAGO*BELLEZAPERFECTA	3	t	2026-04-27 19:27:55.978225	2026-04-27 19:27:55.978227	ARS	\N	\N	2026-04-27	normal	0	\N
272	17	\N	2026-04-18	52116.64	General	MERPAGO*ZIPHORA (REVISAR)	1	f	2026-04-27 17:27:02.676085	2026-04-29 10:22:06.17707	ARS	\N	\N	2026-04-18	normal	0	\N
167	17	\N	2025-12-11	804000	General	OSBA	6	t	2026-04-13 22:37:30.437641	2026-04-29 10:32:18.176373	ARS	\N	\N	2025-12-11	normal	0	\N
314	19	\N	2026-05-28	1000	General	Extracci├│n tarjeta 	1	f	2026-05-28 17:59:44.089373	2026-05-28 17:59:44.107574	ARS	\N	\N	2026-05-28	cash_advance	6.9	503
\.


--
-- Data for Name: credit_card_statements; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.credit_card_statements (id, card_id, period_start, period_end, statement_date, due_date, previous_balance, total_purchases, total_installments, total_interest, total_fees, total_taxes, total_credits, total_amount, minimum_payment, paid_amount, status, payment_date, notes, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: credit_cards; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.credit_cards (id, user_id, card_name, bank_name, closing_day, due_day, currency, credit_limit, is_active, notes, created_at, updated_at) FROM stdin;
1	1	VISA	Ciudad	20	5	ARS	6000000	t		2026-03-26 17:05:31.794745	2026-03-26 17:07:07.860231
3	1	Test Bug8	Banco Test	15	5	ARS	\N	f	\N	2026-03-30 23:43:27.437728	2026-03-30 23:44:53.340419
5	1	Mastercard Test	Galicia	20	10	USD	\N	f	\N	2026-03-31 01:04:50.21828	2026-03-31 01:04:52.282516
9	1	VISA ICBC	ICBC	29	7	ARS	275000	t	Muchas comisi├│n - cerrar!!!	2026-03-31 12:56:01.252521	2026-04-06 19:50:46.420033
10	4	VISA (clon)	Ciudad	20	5	ARS	6000000	t		2026-04-10 19:27:58.749117	2026-04-10 19:27:58.749117
11	4	Test Bug8 (clon)	Banco Test	15	5	ARS	\N	f	\N	2026-04-10 19:27:58.77739	2026-04-10 19:27:58.77739
12	4	Mastercard Test (clon)	Galicia	20	10	USD	\N	f	\N	2026-04-10 19:27:58.787476	2026-04-10 19:27:58.787476
13	4	VISA ICBC (clon)	ICBC	29	7	ARS	275000	t	Muchas comisi├│n - cerrar!!!	2026-04-10 19:27:58.79465	2026-04-10 19:27:58.79465
17	3	VISA	Ciudad	20	5	ARS	6000000	t		2026-04-13 22:37:30.214627	2026-04-13 22:37:30.214627
20	3	VISA ICBC	ICBC	29	7	ARS	275000	t	Muchas comisi├│n - cerrar!!!	2026-04-13 22:37:30.506988	2026-04-13 22:37:30.506988
21	3	CENCOPAY MASTERCARD	Cencopay	15	25	ARS	320000	t	ex tarjeta Cencosud.	2026-04-13 22:41:49.041581	2026-04-13 22:41:49.041581
18	3	Test Bug8	Banco Test	15	5	ARS	\N	f	\N	2026-04-13 22:37:30.495459	2026-04-13 22:44:56.549212
19	3	TARJETA TEST	Galicia	20	10	USD	\N	t		2026-04-13 22:37:30.501741	2026-05-22 18:55:50.439399
\.


--
-- Data for Name: debt_payments; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.debt_payments (id, debt_record_id, transaction_id, payment_date, amount, notes, created_at) FROM stdin;
1	29	\N	2026-02-01	250000	\N	2026-06-10 12:39:42.538289
2	30	\N	2026-03-10	500000	\N	2026-06-10 12:39:42.641872
\.


--
-- Data for Name: debt_records; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.debt_records (id, user_id, debt_name, debt_type, creditor, currency, principal_amount, outstanding_amount, annual_interest_rate, start_date, due_date, status, notes, created_at, updated_at, debt_source, total_installments, current_installment, pending_installments, installment_mode, base_salary, installment_salary_percent, salary_increase_percent, salary_increase_interval_months) FROM stdin;
2	3	Prestamo 1	PERSONAL	Galicia	ARS	1000	1000	84	2026-06-01	2027-05-01	ACTIVA	Prestamo para saldar tarjeta.	2026-06-01 17:12:09.723808	2026-06-01 17:12:09.723808	BANCO	12	1	12	FIXED	\N	\N	\N	\N
3	3	Prestamo 1	PERSONAL	Galicia	ARS	1000000	1000000	68	2026-06-01	2027-05-01	ACTIVA	\N	2026-06-01 17:29:21.769428	2026-06-01 17:30:01.491228	Galicia	12	1	12	FIXED	\N	\N	\N	\N
4	2	Prestamo 1	PRESTAMO	Galicia	ARS	1000000	1000000	68	2026-06-01	2027-05-01	ACTIVA	\N	2026-06-01 20:11:35.15959	2026-06-01 20:11:35.15961	BANCO	12	1	12	FIXED	\N	\N	\N	\N
5	2	Prestamo 1	PRESTAMO	Galicia	ARS	100000	100000	\N	2026-06-01	2026-06-01	ACTIVA	\N	2026-06-01 20:54:56.627901	2026-06-01 20:54:56.627906	BANCO	12	1	12	FIXED	\N	\N	\N	\N
6	2	Prestamo 2	PRESTAMO	Galicia 	ARS	1000000	1000000	68	2026-06-01	2026-06-01	ACTIVA	\N	2026-06-01 20:58:35.617679	2026-06-01 20:58:35.617681	BANCO	12	1	12	FIXED	\N	\N	\N	\N
7	2	Prestamo 3	PERSONAL	El Transa del barrio	ARS	1000000	1000000	84	2026-06-01	2026-07-01	ACTIVA	\N	2026-06-01 21:33:43.258465	2026-06-01 22:51:16.006494	BANCO	12	1	12	FIXED	\N	\N	\N	\N
9	2	Personal 4	PRESTAMO	Banco Ciudad	ARS	10000000	10000000	65	2026-06-02	\N	ACTIVA	\N	2026-06-02 13:59:26.703307	2026-06-02 13:59:26.703354	BANCO	24	1	24	FIXED	\N	\N	\N	\N
10	2	Personal 5	PERSONAL	El Transa del barrio	ARS	1200000	1200000	120	2026-06-02	\N	ACTIVA	\N	2026-06-02 18:03:18.319504	2026-06-02 18:03:18.319557	BANCO	18	1	18	FIXED	\N	\N	\N	\N
11	2	Personal 6	PERSONAL	PEPE	ARS	5000000	5000000	90	2026-06-02	\N	ACTIVA	\N	2026-06-02 18:12:12.955484	2026-06-02 18:12:12.955487	BANCO	12	1	12	FIXED	\N	\N	\N	\N
12	2	Personal 7	PERSONAL	\N	ARS	1500000	1500000	68	2026-06-02	\N	ACTIVA	\N	2026-06-02 18:20:02.496186	2026-06-02 18:20:02.49619	BANCO	12	1	12	FIXED	\N	\N	\N	\N
13	2	Personal 8	PERSONAL	CACHO	ARS	3000000	3000000	68	2026-06-02	2027-06-02	ACTIVA	\N	2026-06-02 18:21:22.44587	2026-06-02 18:21:22.445872	BANCO	12	1	12	FIXED	\N	\N	\N	\N
14	2	Personal 9	PERSONAL	CACHO	ARS	7800000	7800000	66	2026-06-02	2026-07-02	ACTIVA	\N	2026-06-02 18:23:54.923497	2026-06-02 18:31:47.606625	BANCO	12	1	12	FIXED	\N	\N	\N	\N
16	2	Personal 10	PERSONAL	COSO	ARS	8800000	8800000	45	2026-06-02	2026-07-02	ACTIVA	\N	2026-06-02 18:47:35.568354	2026-06-02 20:42:22.824221	BANCO	12	1	12	FIXED	\N	\N	\N	\N
18	2	Personal 11	PERSONAL	MANDRAQUE	ARS	4000000	4000000	56	2026-06-02	\N	ACTIVA	\N	2026-06-02 23:34:52.215258	2026-06-02 23:34:52.215314	BANCO	12	1	12	FIXED	\N	\N	\N	\N
20	2	Test Galicia	PRESTAMO	Galicia	ARS	5000000	5000000	88	2026-02-04	2026-03-03	ACTIVA	\N	2026-06-04 20:31:40.635925	2026-06-04 20:31:40.635927	BANCO	12	4	9	FIXED	\N	\N	\N	\N
21	2	Prestamo Galicia 1	PRESTAMO	Galicia	ARS	5000000	5000000	88	2026-02-04	2026-03-04	ACTIVA	\N	2026-06-04 20:42:12.161309	2026-06-04 20:42:12.161315	BANCO	12	4	9	FIXED	\N	\N	\N	\N
22	2	Prestamo Galicia Test	PRESTAMO	Galicia	ARS	5000000	5000000	88	2026-02-04	2026-03-04	ACTIVA	\N	2026-06-04 20:43:21.539969	2026-06-04 20:43:21.539973	BANCO	12	4	9	FIXED	\N	\N	\N	\N
23	2	Test Galicia Again	PRESTAMO	Galicia	ARS	5000000	5000000	88	2026-02-04	2026-03-04	ACTIVA	\N	2026-06-04 20:48:40.040991	2026-06-04 20:48:40.040995	BANCO	12	4	9	FIXED	\N	\N	\N	\N
19	3	Prestamo Galicia 1	PRESTAMO	Banco Galicia	ARS	5000000	5000000	88	2026-06-03	2026-06-03	ACTIVA	N├║mero del Pr├®stamo 808124429651\nTipo de financiaci├│n Personal\nTasa 88%\nSistema de Amortizaci├│n Franc├®s\nMonto solicitado $5.000.000	2026-06-04 20:22:08.007002	2026-06-04 20:57:05.201118	BANCO	12	4	8	FIXED	\N	\N	\N	\N
24	2	Prestamo Galicia Test N	PRESTAMO	Galicia	ARS	5000000	5000000	88	2026-02-04	2026-03-04	ACTIVA	\N	2026-06-04 21:04:24.502121	2026-06-04 21:04:24.502125	BANCO	12	4	9	FIXED	\N	\N	\N	\N
25	6	TEST_12	PERSONAL	\N	ARS	1200000	1200000	\N	2026-06-02	2026-07-02	ACTIVA	\N	2026-06-10 12:39:41.963219	2026-06-10 12:39:41.963219	\N	12	1	12	FIXED	\N	\N	\N	\N
26	7	TEST_REMAINING	PERSONAL	\N	ARS	600000	600000	\N	2026-01-10	2026-02-10	ACTIVA	\N	2026-06-10 12:39:42.179109	2026-06-10 12:39:42.179109	\N	6	3	4	FIXED	\N	\N	\N	\N
27	8	TEST_RECONCILE	PERSONAL	\N	ARS	300000	300000	\N	2026-03-01	2026-04-01	ACTIVA	\N	2026-06-10 12:39:42.262746	2026-06-10 12:39:42.262746	\N	6	1	6	FIXED	\N	\N	\N	\N
28	9	TEST_INTEREST_ANNUITY	PERSONAL	\N	ARS	5000000	5000000	88	2026-06-01	2026-07-01	ACTIVA	\N	2026-06-10 12:39:42.40116	2026-06-10 12:39:42.40116	\N	12	1	12	FIXED	\N	\N	\N	\N
29	10	TEST_PAYMENT_PARTIAL	PERSONAL	\N	ARS	1200000	950000	\N	2026-01-01	2026-02-01	ACTIVA	\N	2026-06-10 12:39:42.468489	2026-06-10 12:39:42.506147	\N	12	3.5	9.5	FIXED	\N	\N	\N	\N
30	11	TEST_PAYMENT_FULL	PERSONAL	\N	ARS	500000	0	\N	2026-03-01	2026-04-01	CANCELADA	\N	2026-06-10 12:39:42.609082	2026-06-10 12:39:42.633516	\N	5	6	0	FIXED	\N	\N	\N	\N
33	3	Extraccion dinero Tarj Credito	TARJETA	Banco Galicia	ARS	3500000	0	6.9	2026-06-08	2026-07-08	CANCELADA	\N	2026-06-29 17:02:36.625991	2026-06-29 17:47:05.672582	BANCO	1	1	1	FIXED	\N	\N	\N	\N
31	3	Extraccion dinero Tarj Credito	TARJETA	Banco Ciudad	ARS	1500000	0	6.9	2026-06-08	2026-07-08	CANCELADA	\N	2026-06-15 20:16:51.046478	2026-06-29 17:47:35.958633	BANCO	1	1	1	FIXED	\N	\N	\N	\N
34	3	Extraccion dinero Tarj Credito	TARJETA	Banco Ciudad	ARS	3000000	3000000	6.9	2026-05-08	2026-06-08	ACTIVA	\N	2026-06-29 17:48:38.937768	2026-06-29 17:48:38.937771	BANCO	1	1	1	FIXED	\N	\N	\N	\N
36	2	Prestamos Trabajo	PERSONAL	EMPRESA X	ARS	15000000	15000000	\N	2026-07-01	2026-08-01	ACTIVA	Mutuo	2026-06-30 14:39:18.952566	2026-06-30 14:39:18.95261	EMPRESA	24	1	24	FIXED	\N	\N	\N	\N
37	2	[TEST-DELETE] Prestamo personal Monto testuser	PERSONAL	Banco Test	ARS	15000000	15000000	\N	2025-07-01	2025-08-01	ACTIVA	Prueba cuota variable: z=20%, sueldo=4600000, x=9% cada 3 meses	2026-06-30 14:44:10.481707	2026-06-30 14:44:10.481707	BANCO	24	1	24	SALARY_PERCENT	4600000	20	9	3
\.


--
-- Data for Name: installment_plans; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.installment_plans (id, purchase_id, budget_item_id, total_amount, number_of_installments, interest_rate, start_date, plan_type, notes, created_at, updated_at) FROM stdin;
6	54	\N	700000	12	0	2025-08-03	ZERO_INTEREST	\N	2026-03-30 21:42:58.453234	2026-03-30 21:42:58.453234
8	56	\N	120516.96	6	0	2025-11-04	ZERO_INTEREST	\N	2026-03-30 21:47:30.756194	2026-03-30 21:47:30.756194
10	58	\N	804000	6	0	2025-12-11	ZERO_INTEREST	\N	2026-03-30 21:58:50.128366	2026-03-30 21:59:03.71058
1	1	\N	6527354.280937426	12	84	2026-03-09	REGULAR	\N	2026-03-26 17:28:38.914848	2026-03-30 19:05:12.10374
40	160	\N	6527354.280937426	12	84	2026-03-09	REGULAR	\N	2026-04-13 22:37:30.371691	2026-04-13 22:37:30.371691
41	161	\N	700000	12	0	2025-08-03	ZERO_INTEREST	\N	2026-04-13 22:37:30.40161	2026-04-13 22:37:30.40161
42	165	\N	120516.96	6	0	2025-11-04	ZERO_INTEREST	\N	2026-04-13 22:37:30.42702	2026-04-13 22:37:30.42702
44	294	\N	70744.98	3	0	2026-05-27	ZERO_INTEREST	\N	2026-04-27 19:27:55.986394	2026-04-27 19:27:55.986397
45	112	\N	70744.98	3	0	2026-03-14	ZERO_INTEREST	\N	2026-04-27 20:23:17.952593	2026-04-27 20:23:17.952596
43	167	\N	804000	6	0	2025-12-11	ZERO_INTEREST	\N	2026-04-13 22:37:30.441641	2026-04-29 10:32:18.17691
\.


--
-- Data for Name: installment_schedule; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.installment_schedule (id, plan_id, installment_number, due_date, principal_amount, interest_amount, total_installment_amount, status, paid_date, payment_transaction_id, notes, created_at, updated_at) FROM stdin;
225	40	4	2026-05-09	360032.83	183913.36	543946.19	PENDING	\N	\N	\N	2026-04-13 22:37:30.388635	2026-04-13 22:37:30.388635
226	40	5	2026-06-09	360032.83	183913.36	543946.19	PENDING	\N	\N	\N	2026-04-13 22:37:30.388635	2026-04-13 22:37:30.388635
227	40	6	2026-07-09	360032.83	183913.36	543946.19	PENDING	\N	\N	\N	2026-04-13 22:37:30.388635	2026-04-13 22:37:30.388635
228	40	7	2026-08-09	360032.83	183913.36	543946.19	PENDING	\N	\N	\N	2026-04-13 22:37:30.388635	2026-04-13 22:37:30.388635
229	40	8	2026-09-09	360032.83	183913.36	543946.19	PENDING	\N	\N	\N	2026-04-13 22:37:30.388635	2026-04-13 22:37:30.388635
230	40	9	2026-10-09	360032.83	183913.36	543946.19	PENDING	\N	\N	\N	2026-04-13 22:37:30.388635	2026-04-13 22:37:30.388635
231	40	10	2026-11-09	360032.83	183913.36	543946.19	PENDING	\N	\N	\N	2026-04-13 22:37:30.388635	2026-04-13 22:37:30.388635
232	40	11	2026-12-09	360032.83	183913.36	543946.19	PENDING	\N	\N	\N	2026-04-13 22:37:30.388635	2026-04-13 22:37:30.388635
233	40	12	2027-01-09	360032.83	183913.36	543946.19	PENDING	\N	\N	\N	2026-04-13 22:37:30.388635	2026-04-13 22:37:30.388635
147	1	3	2026-04-09	360032.83	183913.36	543946.19	PENDING	\N	\N	\N	2026-03-30 19:05:12.16103	2026-03-30 19:05:12.16103
148	1	4	2026-05-09	360032.83	183913.36	543946.19	PENDING	\N	\N	\N	2026-03-30 19:05:12.16103	2026-03-30 19:05:12.16103
149	1	5	2026-06-09	360032.83	183913.36	543946.19	PENDING	\N	\N	\N	2026-03-30 19:05:12.16103	2026-03-30 19:05:12.16103
150	1	6	2026-07-09	360032.83	183913.36	543946.19	PENDING	\N	\N	\N	2026-03-30 19:05:12.16103	2026-03-30 19:05:12.16103
151	1	7	2026-08-09	360032.83	183913.36	543946.19	PENDING	\N	\N	\N	2026-03-30 19:05:12.16103	2026-03-30 19:05:12.16103
152	1	8	2026-09-09	360032.83	183913.36	543946.19	PENDING	\N	\N	\N	2026-03-30 19:05:12.16103	2026-03-30 19:05:12.16103
153	1	9	2026-10-09	360032.83	183913.36	543946.19	PENDING	\N	\N	\N	2026-03-30 19:05:12.16103	2026-03-30 19:05:12.16103
154	1	10	2026-11-09	360032.83	183913.36	543946.19	PENDING	\N	\N	\N	2026-03-30 19:05:12.16103	2026-03-30 19:05:12.16103
155	1	11	2026-12-09	360032.83	183913.36	543946.19	PENDING	\N	\N	\N	2026-03-30 19:05:12.16103	2026-03-30 19:05:12.16103
156	1	12	2027-01-09	360032.83	183913.36	543946.19	PENDING	\N	\N	\N	2026-03-30 19:05:12.16103	2026-03-30 19:05:12.16103
145	1	1	2026-02-09	360032.83	183913.36	543946.19	PAID	2026-03-30	\N	Pago cuota 1	2026-03-30 19:05:12.16103	2026-03-30 19:05:32.256002
146	1	2	2026-03-09	360032.83	183913.36	543946.19	PAID	2026-03-30	\N	Pago cuota 2	2026-03-30 19:05:12.16103	2026-03-30 19:05:33.10343
165	6	9	2026-04-03	58333.33	0	58333.33	PENDING	\N	\N	\N	2026-03-30 21:42:58.459028	2026-03-30 21:42:58.459028
166	6	10	2026-05-03	58333.33	0	58333.33	PENDING	\N	\N	\N	2026-03-30 21:42:58.459028	2026-03-30 21:42:58.459028
167	6	11	2026-06-03	58333.33	0	58333.33	PENDING	\N	\N	\N	2026-03-30 21:42:58.459028	2026-03-30 21:42:58.459028
168	6	12	2026-07-03	58333.33	0	58333.33	PENDING	\N	\N	\N	2026-03-30 21:42:58.459028	2026-03-30 21:42:58.459028
157	6	1	2025-08-03	58333.33	0	58333.33	PAID	2026-03-30	\N	Pago cuota 1	2026-03-30 21:42:58.459028	2026-03-30 21:43:53.913645
158	6	2	2025-09-03	58333.33	0	58333.33	PAID	2026-03-30	\N	Pago cuota 2	2026-03-30 21:42:58.459028	2026-03-30 21:43:54.266318
159	6	3	2025-10-03	58333.33	0	58333.33	PAID	2026-03-30	\N	Pago cuota 3	2026-03-30 21:42:58.459028	2026-03-30 21:43:54.908195
160	6	4	2025-11-03	58333.33	0	58333.33	PAID	2026-03-30	\N	Pago cuota 4	2026-03-30 21:42:58.459028	2026-03-30 21:43:55.676921
161	6	5	2025-12-03	58333.33	0	58333.33	PAID	2026-03-30	\N	Pago cuota 5	2026-03-30 21:42:58.459028	2026-03-30 21:43:56.339771
162	6	6	2026-01-03	58333.33	0	58333.33	PAID	2026-03-30	\N	Pago cuota 6	2026-03-30 21:42:58.459028	2026-03-30 21:43:56.868737
163	6	7	2026-02-03	58333.33	0	58333.33	PAID	2026-03-30	\N	Pago cuota 7	2026-03-30 21:42:58.459028	2026-03-30 21:43:57.372919
164	6	8	2026-03-03	58333.33	0	58333.33	PAID	2026-03-30	\N	Pago cuota 8	2026-03-30 21:42:58.459028	2026-03-30 21:43:57.875711
170	8	1	2025-11-04	20086.16	0	20086.16	PENDING	\N	\N	\N	2026-03-30 21:47:30.756194	2026-03-30 21:47:30.756194
171	8	2	2025-12-04	20086.16	0	20086.16	PENDING	\N	\N	\N	2026-03-30 21:47:30.756194	2026-03-30 21:47:30.756194
172	8	3	2026-01-04	20086.16	0	20086.16	PENDING	\N	\N	\N	2026-03-30 21:47:30.756194	2026-03-30 21:47:30.756194
237	41	10	2026-05-03	58333.33	0	58333.33	PENDING	\N	\N	\N	2026-04-13 22:37:30.408759	2026-04-13 22:37:30.408759
238	41	11	2026-06-03	58333.33	0	58333.33	PENDING	\N	\N	\N	2026-04-13 22:37:30.408759	2026-04-13 22:37:30.408759
173	8	4	2026-02-04	20086.16	0	20086.16	PENDING	\N	\N	\N	2026-03-30 21:47:30.756194	2026-03-30 21:47:30.756194
174	8	5	2026-03-04	20086.16	0	20086.16	PENDING	\N	\N	\N	2026-03-30 21:47:30.756194	2026-03-30 21:47:30.756194
175	8	6	2026-04-04	20086.16	0	20086.16	PENDING	\N	\N	\N	2026-03-30 21:47:30.756194	2026-03-30 21:47:30.756194
239	41	12	2026-07-03	58333.33	0	58333.33	PENDING	\N	\N	\N	2026-04-13 22:37:30.408759	2026-04-13 22:37:30.408759
248	42	1	2025-11-04	20086.16	0	20086.16	PENDING	\N	\N	\N	2026-04-13 22:37:30.432632	2026-04-13 22:37:30.432632
249	42	2	2025-12-04	20086.16	0	20086.16	PENDING	\N	\N	\N	2026-04-13 22:37:30.432632	2026-04-13 22:37:30.432632
250	42	3	2026-01-04	20086.16	0	20086.16	PENDING	\N	\N	\N	2026-04-13 22:37:30.432632	2026-04-13 22:37:30.432632
251	42	4	2026-02-04	20086.16	0	20086.16	PENDING	\N	\N	\N	2026-04-13 22:37:30.432632	2026-04-13 22:37:30.432632
252	42	5	2026-03-04	20086.16	0	20086.16	PENDING	\N	\N	\N	2026-04-13 22:37:30.432632	2026-04-13 22:37:30.432632
253	42	6	2026-04-04	20086.16	0	20086.16	PENDING	\N	\N	\N	2026-04-13 22:37:30.432632	2026-04-13 22:37:30.432632
234	40	1	2026-02-09	360032.83	183913.36	543946.19	PAID	2026-04-27	\N	Pago cuota 1	2026-04-13 22:37:30.388635	2026-04-27 18:59:52.120729
235	40	2	2026-03-09	360032.83	183913.36	543946.19	PAID	2026-04-27	\N	Pago cuota 2	2026-04-13 22:37:30.388635	2026-04-27 18:59:53.788358
189	10	1	2025-12-11	134000	0	134000	PENDING	\N	\N	\N	2026-03-30 21:59:03.729649	2026-03-30 21:59:03.729649
190	10	2	2026-01-11	134000	0	134000	PENDING	\N	\N	\N	2026-03-30 21:59:03.729649	2026-03-30 21:59:03.729649
191	10	3	2026-02-11	134000	0	134000	PENDING	\N	\N	\N	2026-03-30 21:59:03.729649	2026-03-30 21:59:03.729649
192	10	4	2026-03-11	134000	0	134000	PENDING	\N	\N	\N	2026-03-30 21:59:03.729649	2026-03-30 21:59:03.729649
193	10	5	2026-04-11	134000	0	134000	PENDING	\N	\N	\N	2026-03-30 21:59:03.729649	2026-03-30 21:59:03.729649
194	10	6	2026-05-11	134000	0	134000	PENDING	\N	\N	\N	2026-03-30 21:59:03.729649	2026-03-30 21:59:03.729649
224	40	3	2026-04-09	360032.83	183913.36	543946.19	PAID	2026-05-01	\N	Pago cuota 3	2026-04-13 22:37:30.388635	2026-05-01 19:09:33.691498
240	41	1	2025-08-03	58333.33	0	58333.33	PAID	2026-04-27	\N	Pago cuota 1	2026-04-13 22:37:30.408759	2026-04-27 19:20:26.656151
241	41	2	2025-09-03	58333.33	0	58333.33	PAID	2026-04-27	\N	Pago cuota 2	2026-04-13 22:37:30.408759	2026-04-27 19:20:27.291256
242	41	3	2025-10-03	58333.33	0	58333.33	PAID	2026-04-27	\N	Pago cuota 3	2026-04-13 22:37:30.408759	2026-04-27 19:20:27.834905
243	41	4	2025-11-03	58333.33	0	58333.33	PAID	2026-04-27	\N	Pago cuota 4	2026-04-13 22:37:30.408759	2026-04-27 19:20:28.324713
244	41	5	2025-12-03	58333.33	0	58333.33	PAID	2026-04-27	\N	Pago cuota 5	2026-04-13 22:37:30.408759	2026-04-27 19:20:28.828985
245	41	6	2026-01-03	58333.33	0	58333.33	PAID	2026-04-27	\N	Pago cuota 6	2026-04-13 22:37:30.408759	2026-04-27 19:20:29.307663
246	41	7	2026-02-03	58333.33	0	58333.33	PAID	2026-04-27	\N	Pago cuota 7	2026-04-13 22:37:30.408759	2026-04-27 19:20:29.843917
247	41	8	2026-03-03	58333.33	0	58333.33	PAID	2026-04-27	\N	Pago cuota 8	2026-04-13 22:37:30.408759	2026-04-27 19:20:32.996592
236	41	9	2026-04-03	58333.33	0	58333.33	PAID	2026-04-27	\N	Pago cuota 9	2026-04-13 22:37:30.408759	2026-04-27 19:20:33.402639
260	44	1	2026-05-27	23581.66	0	23581.66	PENDING	\N	\N	\N	2026-04-27 19:27:56.002684	2026-04-27 19:27:56.002687
261	44	2	2026-06-27	23581.66	0	23581.66	PENDING	\N	\N	\N	2026-04-27 19:27:56.002688	2026-04-27 19:27:56.002689
262	44	3	2026-07-27	23581.66	0	23581.66	PENDING	\N	\N	\N	2026-04-27 19:27:56.002689	2026-04-27 19:27:56.00269
263	45	1	2026-03-14	23581.66	0	23581.66	PENDING	\N	\N	\N	2026-04-27 20:23:17.962337	2026-04-27 20:23:17.962341
264	45	2	2026-04-14	23581.66	0	23581.66	PENDING	\N	\N	\N	2026-04-27 20:23:17.962344	2026-04-27 20:23:17.962344
265	45	3	2026-05-14	23581.66	0	23581.66	PENDING	\N	\N	\N	2026-04-27 20:23:17.962345	2026-04-27 20:23:17.962345
282	43	5	2026-05-11	134000	0	134000	PENDING	\N	\N	\N	2026-04-29 10:32:18.188533	2026-04-29 10:32:18.188533
283	43	6	2026-06-11	134000	0	134000	PENDING	\N	\N	\N	2026-04-29 10:32:18.188534	2026-04-29 10:32:18.188534
278	43	1	2026-01-11	134000	0	134000	PAID	2026-04-29	\N	Pago cuota 1	2026-04-29 10:32:18.188527	2026-04-29 10:33:11.479644
279	43	2	2026-02-11	134000	0	134000	PAID	2026-04-29	\N	Pago cuota 2	2026-04-29 10:32:18.18853	2026-04-29 10:33:12.134941
280	43	3	2026-03-11	134000	0	134000	PAID	2026-04-29	\N	Pago cuota 3	2026-04-29 10:32:18.188531	2026-04-29 10:33:17.198939
281	43	4	2026-04-11	134000	0	134000	PAID	2026-04-29	\N	Pago cuota 4	2026-04-29 10:32:18.188532	2026-04-29 10:33:17.930814
\.


--
-- Data for Name: month_closings; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.month_closings (id, year, month, total_ingresos, total_gastos, balance, carry_over_transaction_id, closed_by, closed_at, user_id) FROM stdin;
\.


--
-- Data for Name: monthly_balances; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.monthly_balances (id, user_id, source_month, target_month, balance_amount, balance_type, carryover_date, transaction_id, created_at) FROM stdin;
2	3	2026-05	2026-06	18994.229999998584	NET	2026-05-06 23:26:25.331121	1696	2026-05-06 23:26:25.332819
3	3	2026-04	2026-05	18994.229999998584	NET	2026-05-06 23:27:18.245273	\N	2026-05-06 23:27:18.256651
1	3	2026-04	2026-05	18994.229999998584	NET	2026-05-06 22:02:42.244313	\N	2026-05-06 22:02:42.245376
4	3	2026-04	2026-05	18994.229999998584	NET	2026-05-06 23:27:55.899788	\N	2026-05-06 23:27:55.909117
5	5	2026-04	2026-05	0	NET	2026-05-11 19:42:41.881596	1699	2026-05-11 19:42:41.885091
\.


--
-- Data for Name: monthly_period_events; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.monthly_period_events (id, monthly_period_id, user_id, username, event_type, occurred_at, reason, created_at) FROM stdin;
1	2	3	sergio	CLOSE	2026-05-03 19:24:50.91304	\N	2026-05-03 19:24:50.91399
2	3	3	sergio	OPEN	2026-05-06 19:32:10.429941	\N	2026-05-06 19:32:10.432667
3	3	3	sergio	CLOSE	2026-05-06 21:17:25.595069	\N	2026-05-06 21:17:25.595857
4	3	3	sergio	REOPEN	2026-05-06 21:17:38.389331	Reapertura desde panel principal	2026-05-06 21:17:38.393016
5	3	3	sergio	CLOSE	2026-05-06 21:18:45.457538	\N	2026-05-06 21:18:45.457986
6	3	3	sergio	REOPEN	2026-05-06 21:19:09.71461	Prueba de reapertura.	2026-05-06 21:19:09.716223
11	3	3	sergio	CLOSE	2026-05-06 23:26:19.616938	\N	2026-05-06 23:26:19.617949
12	6	3	sergio	OPEN	2026-05-06 23:26:25.33136	\N	2026-05-06 23:26:25.334955
13	6	3	sergio	CLOSE	2026-05-06 23:26:35.620744	\N	2026-05-06 23:26:35.620991
14	3	3	sergio	REOPEN	2026-05-06 23:27:18.245302	reapertura de prueba.	2026-05-06 23:27:18.246513
15	3	3	sergio	CLOSE	2026-05-06 23:27:31.373405	\N	2026-05-06 23:27:31.373969
16	3	3	sergio	REOPEN	2026-05-06 23:27:55.899814	Mes en curso	2026-05-06 23:27:55.900952
17	7	1	admin	OPEN	2026-05-11 13:38:49.903142	\N	2026-05-11 13:38:49.909505
18	8	5	qa_tester	OPEN	2026-05-11 19:14:54.024612	\N	2026-05-11 19:14:54.025715
19	8	5	qa_tester	CLOSE	2026-05-11 19:42:19.673587	\N	2026-05-11 19:42:19.674422
20	9	5	qa_tester	OPEN	2026-05-11 19:42:41.883195	\N	2026-05-11 19:42:41.888533
21	8	5	qa_tester	REOPEN	2026-05-12 18:38:34.180882	para probar	2026-05-12 18:38:34.209147
\.


--
-- Data for Name: monthly_period_snapshots; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.monthly_period_snapshots (id, monthly_period_id, snapshot_at, total_expenses, total_income, net_balance, transaction_count, created_by, created_at) FROM stdin;
1	1	2026-05-02 22:02:31.514837	22510985.38999999	22788762.24	277776.85000000894	208	3	2026-05-02 22:02:31.524795
2	2	2026-05-03 19:24:50.906723	9772652.010000002	9791646.24	18994.229999998584	110	3	2026-05-03 19:24:50.909806
3	3	2026-05-06 21:17:25.581964	0	0	0	0	3	2026-05-06 21:17:25.591438
4	3	2026-05-06 21:18:45.452467	0	0	0	0	3	2026-05-06 21:18:45.455064
6	3	2026-05-06 23:26:19.610069	0	18994.229999998584	18994.229999998584	1	3	2026-05-06 23:26:19.614259
7	6	2026-05-06 23:26:35.618554	0	18994.229999998584	18994.229999998584	1	3	2026-05-06 23:26:35.619911
8	3	2026-05-06 23:27:31.369866	0	18994.229999998584	18994.229999998584	1	3	2026-05-06 23:27:31.371308
9	8	2026-05-11 19:42:19.652414	0	0	0	0	5	2026-05-11 19:42:19.667862
\.


--
-- Data for Name: monthly_periods; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.monthly_periods (id, year_month, status, closed_at, closed_by, reopened_at, reopened_by, reopen_reason, created_at, updated_at, user_id) FROM stdin;
1	2026-04	CLOSED	2026-05-02 22:02:31.507829	3	\N	\N	\N	2026-05-02 22:02:31.484629	2026-05-02 22:02:31.507829	\N
2	2026-04	CLOSED	2026-05-03 19:24:50.901703	3	\N	\N	\N	2026-05-03 19:24:50.895939	2026-05-03 19:24:50.901703	3
6	2026-06	CLOSED	2026-05-06 23:26:35.61772	3	\N	\N	\N	2026-05-06 23:26:25.32963	2026-05-06 23:26:35.61772	3
3	2026-05	REOPENED	2026-05-06 23:27:31.368414	3	2026-05-06 23:27:55.899788	3	Mes en curso	2026-05-06 19:32:10.423917	2026-05-06 23:27:55.899788	3
7	2026-05	OPEN	\N	\N	\N	\N	\N	2026-05-11 13:38:49.888442	2026-05-11 13:38:49.879804	1
9	2026-05	OPEN	\N	\N	\N	\N	\N	2026-05-11 19:42:41.880067	2026-05-11 19:42:41.879822	5
8	2026-04	REOPENED	2026-05-11 19:42:19.646822	5	2026-05-12 18:38:34.180347	5	para probar	2026-05-11 19:14:54.020417	2026-05-12 18:38:34.180347	5
\.


--
-- Data for Name: permissions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.permissions (id, code, description, module, created_at, updated_at) FROM stdin;
1	transactions.read	Ver transacciones	Transacciones	2026-04-08 17:11:08.020784	2026-04-08 17:11:08.020784
2	transactions.write	Crear/editar transacciones	Transacciones	2026-04-08 17:11:08.020784	2026-04-08 17:11:08.020784
3	transactions.delete	Eliminar transacciones	Transacciones	2026-04-08 17:11:08.020784	2026-04-08 17:11:08.020784
4	debts.read	Ver presupuesto/deudas	Presupuesto	2026-04-08 17:11:08.020784	2026-04-08 17:11:08.020784
5	debts.write	Crear/editar presupuesto	Presupuesto	2026-04-08 17:11:08.020784	2026-04-08 17:11:08.020784
6	debts.delete	Eliminar presupuesto	Presupuesto	2026-04-08 17:11:08.020784	2026-04-08 17:11:08.020784
7	creditcards.read	Ver tarjetas de cr├®dito	Tarjetas	2026-04-08 17:11:08.020784	2026-04-08 17:11:08.020784
8	creditcards.write	Crear/editar tarjetas	Tarjetas	2026-04-08 17:11:08.020784	2026-04-08 17:11:08.020784
9	creditcards.delete	Eliminar tarjetas	Tarjetas	2026-04-08 17:11:08.020784	2026-04-08 17:11:08.020784
10	categories.read	Ver categor├¡as	Categor├¡as	2026-04-08 17:11:08.020784	2026-04-08 17:11:08.020784
11	categories.write	Crear/editar categor├¡as	Categor├¡as	2026-04-08 17:11:08.020784	2026-04-08 17:11:08.020784
12	categories.delete	Eliminar categor├¡as	Categor├¡as	2026-04-08 17:11:08.020784	2026-04-08 17:11:08.020784
13	users.read	Ver usuarios	Admin	2026-04-08 17:11:08.020784	2026-04-08 17:11:08.020784
14	users.write	Crear/editar usuarios	Admin	2026-04-08 17:11:08.020784	2026-04-08 17:11:08.020784
15	users.delete	Eliminar usuarios	Admin	2026-04-08 17:11:08.020784	2026-04-08 17:11:08.020784
16	roles.read	Ver roles	Admin	2026-04-08 17:11:08.020784	2026-04-08 17:11:08.020784
17	roles.write	Crear/editar roles	Admin	2026-04-08 17:11:08.020784	2026-04-08 17:11:08.020784
18	roles.delete	Eliminar roles	Admin	2026-04-08 17:11:08.020784	2026-04-08 17:11:08.020784
19	settings.read	Ver configuraci├│n	Configuraci├│n	2026-04-08 17:11:08.020784	2026-04-08 17:11:08.020784
20	settings.write	Editar configuraci├│n	Configuraci├│n	2026-04-08 17:11:08.020784	2026-04-08 17:11:08.020784
21	accounts.read	Ver cuentas bancarias	Cuentas	2026-04-27 13:32:20.314688	2026-04-27 13:32:20.314693
22	accounts.write	Crear/editar cuentas bancarias	Cuentas	2026-04-27 13:32:20.314694	2026-04-27 13:32:20.314694
23	accounts.delete	Eliminar cuentas bancarias	Cuentas	2026-04-27 13:32:20.314695	2026-04-27 13:32:20.314697
24	debt_records.read	Ver registros de deuda	Deudas	2026-04-27 13:32:20.314698	2026-04-27 13:32:20.314699
25	debt_records.write	Crear/editar registros de deuda	Deudas	2026-04-27 13:32:20.3147	2026-04-27 13:32:20.3147
26	debt_records.delete	Eliminar registros de deuda	Deudas	2026-04-27 13:32:20.314701	2026-04-27 13:32:20.314702
\.


--
-- Data for Name: refresh_tokens; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.refresh_tokens (id, user_id, token_hash, expires_at, revoked_at, created_at, ip_address, user_agent) FROM stdin;
1	1	$2b$12$UdbjyRLrZ1krG0g0wJ3Orup9KXUhWIUUI8NPRHa3GpIuPVQx5uem6	2026-04-15 17:27:00.371111	2026-04-08 20:09:15.985386	2026-04-08 17:27:00.372607	127.0.0.1	test
2	1	$2b$12$YcvUjx0whZrZNu4P85wv.OuyQkLPrZmMCV4OowLYDlmedFb7yNQVW	2026-04-15 19:31:30.034995	2026-04-08 20:09:15.985386	2026-04-08 19:31:30.039685	127.0.0.1	curl/8.18.0
3	1	$2b$12$.SWMc1OSraWnDSRJIiCjtuOLVWkXpSm3PGEzKmAkjdz8wQdJokuT6	2026-04-15 19:32:02.154372	2026-04-08 20:09:15.985386	2026-04-08 19:32:02.154372	127.0.0.1	curl/8.18.0
4	1	$2b$12$cN/Nu0eHcJ.Hz2NWMWMXq.zYDyq1eI5XX/DeL6YYcwAyowsLPN/32	2026-04-15 19:32:49.318738	2026-04-08 20:09:15.985386	2026-04-08 19:32:49.320761	127.0.0.1	python-requests/2.32.5
5	1	$2b$12$k0lW7Oy.gg27uJ9gU0JDceRNzqjXcJL1AKos/UnGjLnfFsWK37rve	2026-04-15 19:36:21.550988	2026-04-08 20:09:15.985386	2026-04-08 19:36:21.5515	127.0.0.1	python-requests/2.32.5
6	1	$2b$12$/ADFs4CLyjlXrlvANUaeVODZzWOIzSznWwoxq70a58pv4f3b0DWym	2026-04-15 19:36:37.464325	2026-04-08 20:09:15.985386	2026-04-08 19:36:37.464325	127.0.0.1	python-requests/2.32.5
7	1	$2b$12$.8u.HdOpznmUC2L25Vrpyu63kqivrnVgEd9wUTJKoqeZ9ul6h4fpS	2026-04-15 19:37:19.344122	2026-04-08 20:09:15.985386	2026-04-08 19:37:19.344122	127.0.0.1	python-requests/2.32.5
8	1	$2b$12$9xpe9z6G.0hOquWc3BcupOh1Fz9emLKzPY3IiNpwiPL874FW.LDhG	2026-04-15 19:37:36.048408	2026-04-08 20:09:15.985386	2026-04-08 19:37:36.048932	127.0.0.1	python-requests/2.32.5
9	1	$2b$12$2z5/NHhcdIArlXrPWTN2NOnNNh8Yo1f5R11PxC4qI4Fok26wcNjIa	2026-04-15 19:46:31.113812	2026-04-08 20:09:15.985386	2026-04-08 19:46:31.115812	127.0.0.1	python-requests/2.32.5
10	1	$2b$12$QV7OUF8.9A7j3XRsh5.nYuuVAxwuLBDQriDD91gSTpP5qYuVqhQ.2	2026-04-15 19:47:26.809693	2026-04-08 20:09:15.985386	2026-04-08 19:47:26.809693	127.0.0.1	python-requests/2.32.5
11	1	$2b$12$Wk3PqXiVRdhzcD1KiVUGCu001KJIZJGgz69iNseRuinNp9k4Ylesq	2026-04-15 20:08:48.083932	2026-04-08 20:09:15.985386	2026-04-08 20:08:48.085943	127.0.0.1	python-requests/2.32.5
25	4	$2b$12$z8qLYKYFiBx2hHqvJt30vOq0vW96Kpry/T6m2jzxOutpyYaeKFBm6	2026-04-17 18:43:59.723389	\N	2026-04-10 18:43:59.723922	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-GB) PowerShell/7.5.5
31	4	$2b$12$iww7Y3XC5BLOCCwXMXLGC.d93mZxhChZ6.5wZtqtmxiWEfaHeNi7O	2026-04-17 19:27:13.561153	\N	2026-04-10 19:27:13.562309	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-GB) PowerShell/7.5.5
12	1	$2b$12$eRzhFm7.RZl0PC94vYLUT.BRcyPsgFLCcv4OSo5dN1dyVus/FV4wm	2026-04-16 15:34:21.019054	2026-05-03 19:23:49.541941	2026-04-09 15:34:21.020055	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36
13	1	$2b$12$bjEd2L1B6UaxsSE2cJM5cuySlFr7l91G9Tky1p64Ro8aLnP49EqMC	2026-04-16 19:36:24.974912	2026-05-03 19:23:49.541941	2026-04-09 19:36:24.978206	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36
14	1	$2b$12$2ahHWqhrZgjthhfRTDk20e48J2f/POnNogkKnG9T3Z48/uH8enrVK	2026-04-16 19:37:23.508043	2026-05-03 19:23:49.541941	2026-04-09 19:37:23.509051	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36
15	1	$2b$12$X8mCmtZUWUH/.SjRK8jYLOZu.F32S2JpXiNCM3kMM1N8Zqg8sm6P2	2026-04-16 19:50:23.009239	2026-05-03 19:23:49.541941	2026-04-09 19:50:23.009239	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36
17	1	$2b$12$XMj9cmAOB/ca0F7UXcYxpu9rEv5rpjAfzCqRlRkTnjfqVwTd76Soy	2026-04-17 18:37:05.582922	2026-05-03 19:23:49.541941	2026-04-10 18:37:05.584776	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-GB) PowerShell/7.5.5
18	1	$2b$12$u46oD.kwGCCKkTatmE/GBeWy7j6G9DDJhx7/cpVj.s7ihfdrplEHa	2026-04-17 18:38:06.354308	2026-05-03 19:23:49.541941	2026-04-10 18:38:06.354308	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-GB) PowerShell/7.5.5
19	1	$2b$12$LQj/FKuPe1AJ5N7PytsYIeYGcKKKcPm3Zj5cIikErtqk0jUFNPfJW	2026-04-17 18:38:50.279694	2026-05-03 19:23:49.541941	2026-04-10 18:38:50.280744	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-GB) PowerShell/7.5.5
16	3	$2b$12$oFBLb14TwRCXB3NpC/r69OfvEdql5LEy1bME.uSdlVFjX/t0c0mxq	2026-04-16 19:51:23.812495	2026-05-02 22:19:49.343029	2026-04-09 19:51:23.812495	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36
26	3	$2b$12$T/ZmJwwYjmgM96aZYSL.Cek.dCi1QV9Gh2KypTmHxIQ95tt2cNbQ2	2026-04-17 18:49:02.305538	2026-05-02 22:19:49.343029	2026-04-10 18:49:02.305538	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36
27	3	$2b$12$EZ7Kl4qC2D0waY/wow1druMEk/A8eqIhlz23WR2DkXz9gW00oAd/m	2026-04-17 18:49:12.104515	2026-05-02 22:19:49.343029	2026-04-10 18:49:12.104515	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36
33	3	$2b$12$4DiR4EzsotRBJfFiQ1ODg.kH3ebNJqB//n6vVMX2Dw1IuPCQErLpa	2026-04-20 15:35:58.426416	2026-05-02 22:19:49.343029	2026-04-13 15:35:58.428937	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36
36	3	$2b$12$.Rhk32kSjMLQz000KYtGFu7IznuLUyt1Fay62LCz9U4oT9EN2bMfa	2026-04-20 22:38:08.164867	2026-05-02 22:19:49.343029	2026-04-13 22:38:08.167028	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36
38	3	$2b$12$.cj0MOT.IKkxSXlVSSPvL.x8qOP2dRdT4bAORNB7vW0l/bUsi4/66	2026-04-23 13:44:43.557796	2026-05-02 22:19:49.343029	2026-04-16 13:44:43.560911	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36
39	3	$2b$12$mq8it9DptMj9jjN8Y6JYXO7ha.m1yliHaQ/zLHLNe8liqZ5NqXayi	2026-04-23 13:58:12.945456	2026-05-02 22:19:49.343029	2026-04-16 13:58:12.945456	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-GB) PowerShell/7.5.5
40	3	$2b$12$iZgbvSLicSpSsmLlTE89kelWVZwkm8wdY481UAYLw4A3guC1Svze2	2026-04-23 14:07:26.813826	2026-05-02 22:19:49.343029	2026-04-16 14:07:26.813826	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-GB) PowerShell/7.5.5
41	3	$2b$12$aRywck0p7OBji9V6beHSpuyvZ1Q7utJAYlPOSP3W6Ud77HBuDHa9u	2026-04-23 14:08:37.610084	2026-05-02 22:19:49.343029	2026-04-16 14:08:37.610084	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-GB) PowerShell/7.5.5
42	3	$2b$12$mMiS3i9TUqucmmQOPGCoAu2OBjIh/c5mTCg79DWbF6tpePCsD7dRa	2026-04-23 15:04:17.512231	2026-05-02 22:19:49.343029	2026-04-16 15:04:17.512763	127.0.0.1	python-requests/2.32.3
43	3	$2b$12$jFOnb/SxkeLaSC/d6XCfTOh2n7jl95ErIXbOT3ZtuOTO66z3Fg1nm	2026-04-23 15:04:52.201877	2026-05-02 22:19:49.343029	2026-04-16 15:04:52.202883	127.0.0.1	python-requests/2.32.3
44	3	$2b$12$xcSvjxEI3uqYuiQUVGy6Qu3A1r0fL3ZPN/3K07YXfNeOhqqftUdQ6	2026-04-23 17:47:11.401502	2026-05-02 22:19:49.343029	2026-04-16 17:47:11.403591	127.0.0.1	python-requests/2.32.3
45	3	$2b$12$vFCeK9OiVRmVkM/2xVSMZOhyFvRLwdru8J6kxQHjDgOdie0cdMtvK	2026-04-23 17:47:22.56294	2026-05-02 22:19:49.343029	2026-04-16 17:47:22.564445	127.0.0.1	python-requests/2.32.3
46	3	$2b$12$2jDwmsbzfBIIr3AYLEYIeuGHw63P4FbHxNPFAEq8vgrvSZuBFbPMW	2026-04-23 17:48:03.948929	2026-05-02 22:19:49.343029	2026-04-16 17:48:03.949534	127.0.0.1	python-requests/2.32.3
47	3	$2b$12$KYXxBT0iZCcPakgxF0Ct9uE/IC670mlC54y6y028anU0QErtJiiLK	2026-04-27 15:24:20.29863	2026-05-02 22:19:49.343029	2026-04-20 15:24:20.30063	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36
49	3	$2b$12$YrBNvg/aaftSrNAsUoIRCuQxE/FpJahc1rf3QqbIT9pY7fgwzRSVG	2026-05-04 13:38:31.37771	2026-05-02 22:19:49.343029	2026-04-27 13:38:31.379542	172.22.0.1	python-requests/2.32.5
50	3	$2b$12$BTWMqVLwGp8EtNf.1ghB7.DKSy8glW9.RdWv9TLsR860AErVJG7Vq	2026-05-04 13:38:57.705276	2026-05-02 22:19:49.343029	2026-04-27 13:38:57.705811	172.22.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36
51	3	$2b$12$QsWJ0ZjppDlmkLb9Zgud4uCo/mrqawJNYuefXUtLMuBMroplgLpvu	2026-05-04 14:15:26.078794	2026-05-02 22:19:49.343029	2026-04-27 14:15:26.08064	172.22.0.1	python-requests/2.32.5
52	3	$2b$12$EfZ/N5FVCvfHYHibIih2p.h2PO4Y5jSwLlOCrsvhiOT5CujTTvg7q	2026-05-08 20:36:21.30166	2026-05-02 22:19:49.343029	2026-05-01 20:36:21.310522	172.22.0.1	python-requests/2.32.5
53	3	$2b$12$JNJTnA6YSVQ3RSJzUU2E7.PBMqN7ZCgTwnmbXOHy2mcti5WUhOc26	2026-05-08 20:36:39.590244	2026-05-02 22:19:49.343029	2026-05-01 20:36:39.590754	172.22.0.1	python-requests/2.32.5
54	3	$2b$12$LWsYyUid9zvxPLpwsgZQWu8vAtGs98N6Qt3s9SSzfOPi/3tJrFnpm	2026-05-08 20:46:22.620067	2026-05-02 22:19:49.343029	2026-05-01 20:46:22.620986	172.22.0.1	python-requests/2.32.5
55	3	$2b$12$3SD1KbskB.fASNyZyi2UnO.UbTraBAYNe69/F1ijU.r.GLW2vfEvO	2026-05-09 00:09:29.727155	2026-05-02 22:19:49.343029	2026-05-02 00:09:29.736084	172.22.0.1	python-requests/2.32.5
56	3	$2b$12$MfsQPaEBTHzDPRH.Se/qZ.dsYbdkaHFR89FpZyIr9AIhAUlwtQLcq	2026-05-09 00:19:45.334204	2026-05-02 22:19:49.343029	2026-05-02 00:19:45.338106	172.22.0.1	python-requests/2.32.5
20	1	$2b$12$F4OApElnjZrcPPELwgNKvuEMVezz2HospRZAxKX35C04/gIhdIpGe	2026-04-17 18:39:27.132687	2026-05-03 19:23:49.541941	2026-04-10 18:39:27.132687	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-GB) PowerShell/7.5.5
21	1	$2b$12$snVeMXRcPLmiSNb4OdgvFuLgWMG.v2WGnJ.1Mnu6RTH7YFMY1xgta	2026-04-17 18:40:11.947192	2026-05-03 19:23:49.541941	2026-04-10 18:40:11.947192	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-GB) PowerShell/7.5.5
22	1	$2b$12$DMABTttqxXaSB./2weJy.O.t9dB6NAqYrw5RlOpe0k8NUvYAYHiXe	2026-04-17 18:40:40.02149	2026-05-03 19:23:49.541941	2026-04-10 18:40:40.02149	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-GB) PowerShell/7.5.5
23	1	$2b$12$wHGFfNjQmw2Rv0dSWauNo.KrLkoXIdrRM5Y4rI0gyhm9UoqsFLvo.	2026-04-17 18:41:11.335387	2026-05-03 19:23:49.541941	2026-04-10 18:41:11.335961	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-GB) PowerShell/7.5.5
24	1	$2b$12$m766WIV5wFxsw40hPdEPMOnwatOkytFny0xADhQp0VSkaBxPsse6S	2026-04-17 18:43:40.215527	2026-05-03 19:23:49.541941	2026-04-10 18:43:40.215527	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-GB) PowerShell/7.5.5
28	1	$2b$12$4QfMeSC1zG3K4tSGl40yzeSN1sW3dZ6Yt6KdCIg4uldk0ioWNCpR.	2026-04-17 19:21:41.679161	2026-05-03 19:23:49.541941	2026-04-10 19:21:41.681844	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-GB) PowerShell/7.5.5
29	1	$2b$12$oadhks3vWU8RXZp90tQ60.bqoi7jET/bmaLbG0n.px3LFq4CbQ0/O	2026-04-17 19:22:23.109102	2026-05-03 19:23:49.541941	2026-04-10 19:22:23.110104	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-GB) PowerShell/7.5.5
30	1	$2b$12$QxlD8lD1Ptj5jrNBUQp9.ebJ7nyk1Bv0qVrpuhfV8UkkM1oC3Pjr.	2026-04-17 19:26:59.222368	2026-05-03 19:23:49.541941	2026-04-10 19:26:59.224372	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-GB) PowerShell/7.5.5
32	1	$2b$12$24mpFgRbRw7Z5kd4/hHcE.Nd51nmOXOf1zyAMOswgppaahtf8D9sy	2026-04-17 19:27:56.556731	2026-05-03 19:23:49.541941	2026-04-10 19:27:56.556731	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-GB) PowerShell/7.5.5
34	1	$2b$12$SPegnXKdiZUMDtN/wnrNf.GF6q0Oga/ZxwZbr0Jb8OHGtGFGwnipO	2026-04-20 15:52:56.565173	2026-05-03 19:23:49.541941	2026-04-13 15:52:56.565173	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36
35	1	$2b$12$fPwYRU1VNuz49XmzF2Xtd.t3DMD6thoflb9veZx3jNRe3LwvhKxF6	2026-04-20 18:42:27.060067	2026-05-03 19:23:49.541941	2026-04-13 18:42:27.062066	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-GB) PowerShell/7.5.5
37	1	$2b$12$lIEEbL9qfamIua88kgFPje/tvnJBCBkJD4xFZ3nHLXIbgu8rNtuom	2026-04-21 01:43:28.673598	2026-05-03 19:23:49.541941	2026-04-14 01:43:28.675597	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36
48	1	$2b$12$6VryiRqL7Y8vmyhyQtSy/OuIpNBFjh3LFVK3hmybbbyneKu5GcFjW	2026-05-03 23:15:34.739713	2026-05-03 19:23:49.541941	2026-04-26 23:15:34.742902	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36
57	1	$2b$12$ALflOSJ2cwcjeOWwQ8R/cuclnd1ojltfOvNfC.P1LkFRc0krqvsV.	2026-05-09 22:20:01.478023	2026-05-03 19:23:49.541941	2026-05-02 22:20:01.479519	172.22.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36
58	3	$2b$12$neOH0jXnU0LkIjk.6hORNezJTeO3roNcvO/JdwdYB9w25g9qz8S4y	2026-05-10 19:24:07.302066	2026-05-04 21:27:04.313044	2026-05-03 19:24:07.303893	172.22.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36
59	1	$2b$12$nU6ijjYyHFoa3IdkUNqgfOwRABVPSvBtYysld86.fnArAclKqi2v.	2026-05-11 00:10:27.726044	2026-05-04 22:37:19.615857	2026-05-04 00:10:27.730813	172.22.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36
60	1	$2b$12$50bJvVtyUzqFMRkp0f.xGeAgdCnIHZ0ei17wYGU7yAlMJ5yo0Cz/m	2026-05-11 21:31:47.537868	2026-05-04 22:37:19.615857	2026-05-04 21:31:47.542261	172.22.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36
61	3	$2b$12$GHtL0yFCkKX0GCju10l9B.mb/m0BLwi/bjs.hPpzJqBjdFr4DMmtG	2026-05-11 22:37:48.901899	2026-05-06 17:37:21.379071	2026-05-04 22:37:48.904781	172.22.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36
64	3	$2b$12$uQO8diMhFJp2adwU367eceF2fbQ4r7y4.8dUn4pRt6Xe1NDjCQbF6	2026-05-13 17:37:21.806148	2026-05-06 21:04:53.59957	2026-05-06 17:37:21.806876	172.26.0.1	Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-GB) PowerShell/7.5.5
65	3	$2b$12$TQ8VFq448mkJNG5X6yqc5et7zGUdVTJkAvP6xTI0V89gRurjnO77e	2026-05-13 17:37:59.056331	2026-05-06 21:04:53.59957	2026-05-06 17:37:59.056946	172.26.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36
66	3	$2b$12$6MF2sq.Uj.Xaxn7r.XIwHumEBSTiSyFhXmu4e67fG7fpZsya6t8S6	2026-05-13 18:56:40.707631	2026-05-06 21:04:53.59957	2026-05-06 18:56:40.712339	172.26.0.1	Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-GB) PowerShell/7.5.5
67	3	$2b$12$wQgUkrSoue1MpFkG4VUhqec.7rtKpu5iSSniCskR.ZX9aae7bz36W	2026-05-13 19:32:10.169657	2026-05-06 21:04:53.59957	2026-05-06 19:32:10.172969	172.26.0.1	Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-GB) PowerShell/7.5.5
68	3	$2b$12$uhg9eSTwpQwDzTtK8ObGpub3byDcyXGrxjfVb08AwnRBJWiaemG5i	2026-05-13 20:27:12.391933	2026-05-06 21:04:53.59957	2026-05-06 20:27:12.396855	172.26.0.1	Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-GB) PowerShell/7.5.5
62	1	$2b$12$BvF1jhn3NyAO2DlaKhOxuubKftWousvDdt2kHKcDxkqBmFpVzIN1u	2026-05-13 17:37:06.117652	2026-05-11 19:14:25.827373	2026-05-06 17:37:06.119451	172.26.0.1	Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-GB) PowerShell/7.5.5
63	1	$2b$12$8XkIIClgs3Zg0FpETx39FeVuduL5inetI950IF4K.pPOist8iYXIe	2026-05-13 17:37:21.039582	2026-05-11 19:14:25.827373	2026-05-06 17:37:21.040258	172.26.0.1	Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-GB) PowerShell/7.5.5
69	3	$2b$12$lu2UfSodhXy1NEpmnxaFiefJCax1wtsjB8RWVR8ituE4aerEOp3bC	2026-05-13 20:30:02.21095	2026-05-06 21:04:53.59957	2026-05-06 20:30:02.211696	172.26.0.1	Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-GB) PowerShell/7.5.5
70	3	$2b$12$3hbYUoOJ9ECEpuWUm4psUOqA/Aps3M4PhL7aSZ26sJC2T0UC/eHZ6	2026-05-13 20:48:44.116289	2026-05-06 21:04:53.59957	2026-05-06 20:48:44.119083	172.26.0.1	Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-GB) PowerShell/7.5.5
71	3	$2b$12$vU0LUOWWye5cBOf9WqUtHu.nUmpliIoeEAbGpisxdb99tPh/9p1L6	2026-05-13 21:00:09.088501	2026-05-06 21:04:53.59957	2026-05-06 21:00:09.089152	172.26.0.1	Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-GB) PowerShell/7.5.5
72	3	$2b$12$2mwa7iE5Z5e0405cWB0OMOXQLf/mhRPaSgdVlb38VoyjNFgEA1y7m	2026-05-13 21:04:55.525805	2026-05-11 00:16:16.674698	2026-05-06 21:04:55.526333	172.26.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36
75	3	$2b$12$DhLdbmVSh2WGhnRYfZFEq.v87t8sH1/3uRCWUDkdEubRTyBIr6WBi	2026-05-13 21:08:57.132813	2026-05-11 00:16:16.674698	2026-05-06 21:08:57.133409	172.26.0.1	Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-GB) PowerShell/7.5.5
73	3	$2b$12$LHLzZ9jUbFAu3ftwRON/ZOckS5lWeWECZvuvjvrPfmpB3YcDK6cYS	2026-05-13 21:08:39.885226	2026-05-11 00:16:16.674698	2026-05-06 21:08:39.885757	172.26.0.1	Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-GB) PowerShell/7.5.5
74	3	$2b$12$GPAUfBpOxcgTyQMxrauHDu8DFTNHqEOHjnxl47ZH5pmLttQYK8biS	2026-05-13 21:08:50.028461	2026-05-11 00:16:16.674698	2026-05-06 21:08:50.028934	172.26.0.1	Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-GB) PowerShell/7.5.5
85	3	$2b$12$gFeuSNqO6WLKqF6Fc.RZjefZx9Y4sQauUzbxsrkx2YVCvh7N1Rvc6	2026-05-15 20:34:01.098924	2026-05-11 00:16:16.674698	2026-05-08 20:34:01.106913	172.26.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36
89	3	$2b$12$g81zZonNr4O3xpsGc2qAze6F8UwqHgwO0wdOBVq3vMdSXgCyByoVC	2026-05-18 00:16:17.058429	2026-05-11 19:05:30.940237	2026-05-11 00:16:17.059001	172.26.0.1	Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-GB) PowerShell/7.5.5
90	3	$2b$12$TwPxOfnE7W5ScHcgURRrGefX3d25lriGn0JxtPTA.TFE3DXHmW8Tu	2026-05-18 00:18:01.203023	2026-05-11 19:05:30.940237	2026-05-11 00:18:01.203571	172.26.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36
91	3	$2b$12$aC8UWOmljHLHebgFtXKQ1eflid52J6LN6BTT9/jXNdOIeszoNgaqu	2026-05-18 00:30:33.197725	2026-05-11 19:05:30.940237	2026-05-11 00:30:33.198244	172.26.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36
76	1	$2b$12$aLDmhDf6QmyTNx1Lp57bPun3Zwq3Zzrjx1OUpYCrOQ4.mFiko93l6	2026-05-14 14:08:41.080623	2026-05-11 19:14:25.827373	2026-05-07 14:08:41.087982	172.26.0.1	Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-GB) PowerShell/7.5.5
77	1	$2b$12$tzBc/8XoGgKaSUF0U/qvE.Byhr5X6.I8MF6GsOjb3JtNH8XukMPUm	2026-05-14 14:22:32.690934	2026-05-11 19:14:25.827373	2026-05-07 14:22:32.691845	172.26.0.1	Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-GB) PowerShell/7.5.5
78	1	$2b$12$L1Fj/UV8XQ0X1uSltz8EP.4Ruc7Zx/9xRN2L9HgXl9lB8q3kR9hUm	2026-05-14 15:06:25.66572	2026-05-11 19:14:25.827373	2026-05-07 15:06:25.673219	172.26.0.1	Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-GB) PowerShell/7.5.5
79	1	$2b$12$DOcYMOOIcW74gm7TMroe1erwBUeYSMNgMcmxdbWO/npIe/sQgLnSy	2026-05-14 15:06:54.442832	2026-05-11 19:14:25.827373	2026-05-07 15:06:54.443695	172.26.0.1	Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-GB) PowerShell/7.5.5
80	1	$2b$12$j77fUX1zz1A/jEiDZiNSyeLysj7rD0e3qMRn0nD2AmS/6sOc.rysq	2026-05-14 15:13:10.223827	2026-05-11 19:14:25.827373	2026-05-07 15:13:10.224573	172.26.0.1	Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-GB) PowerShell/7.5.5
81	1	$2b$12$su4Yl0vYexp2sTU9sHtIdOvFSnugHr4RJcuG9LroGbuzB64sq1TZy	2026-05-14 15:13:59.313529	2026-05-11 19:14:25.827373	2026-05-07 15:13:59.31403	172.26.0.1	Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-GB) PowerShell/7.5.5
82	1	$2b$12$6uuzZJnBkRqczeUGkSw5Pu1YseRgMf8/IG03.XJMR.0K7CqUxGiNm	2026-05-14 15:16:18.951613	2026-05-11 19:14:25.827373	2026-05-07 15:16:18.952189	172.26.0.1	Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-GB) PowerShell/7.5.5
83	1	$2b$12$hsUseKbqjr0CrflUNLol9eBBsowUOVFgEjQ3gPqPh28MDhm7IPM2q	2026-05-14 15:20:19.716603	2026-05-11 19:14:25.827373	2026-05-07 15:20:19.717088	172.26.0.1	Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-GB) PowerShell/7.5.5
84	1	$2b$12$xuLxsXFOjiAFPN.x7l8BHen6R0rp71wSSjmrKvzvopu2hssdNpY3u	2026-05-14 17:54:05.523082	2026-05-11 19:14:25.827373	2026-05-07 17:54:05.527152	172.26.0.1	Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-GB) PowerShell/7.5.5
86	1	$2b$12$ONEFFjOziYhsUW6.RL5eZOrq62eZDoeTc9KUWhyLyvbAIVNFSUph.	2026-05-18 00:15:30.871247	2026-05-11 19:14:25.827373	2026-05-11 00:15:30.873017	172.26.0.1	Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-GB) PowerShell/7.5.5
87	1	$2b$12$heeaxGpkfYMcpBQewYz9Wu4Zd1ngo6UEByGSCBm4eP54D2XFY9tK2	2026-05-18 00:16:07.530433	2026-05-11 19:14:25.827373	2026-05-11 00:16:07.531301	172.26.0.1	Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-GB) PowerShell/7.5.5
96	5	$2b$12$o3U6he2QIbvnMZZhBI5T5OqGGtsoMWWym3Tdi9X50hk2UxYYTfBW6	2026-05-18 19:36:14.627082	2026-05-11 19:39:59.229711	2026-05-11 19:36:14.62897	172.26.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36
88	1	$2b$12$hCxkrGZ/7WaOxUSRs8.st.LLdOroaVoccB8dLpRkf17c/b6luEFPm	2026-05-18 00:16:16.468802	2026-05-11 19:14:25.827373	2026-05-11 00:16:16.469262	172.26.0.1	Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-GB) PowerShell/7.5.5
92	1	$2b$12$J5Vqf9IsJTyWGyL2PH40j.BkfRmQKr/I07mw6wo6nebXWJOJsXI5m	2026-05-18 13:38:49.288706	2026-05-11 19:14:25.827373	2026-05-11 13:38:49.292085	172.26.0.1	Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-GB) PowerShell/7.5.5
93	1	$2b$12$Lqipce61pizPeUpKY.wTXe0gRCXJ4MZmSs9ERsxVvM3ZSBrpwx6IS	2026-05-18 13:39:33.015502	2026-05-11 19:14:25.827373	2026-05-11 13:39:33.016003	172.26.0.1	Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-GB) PowerShell/7.5.5
94	1	$2b$12$nBhubhjRWqqCM.fQNzPWnu6XjL3XKTxCNkNsvI3/qXviYFfhXAqEK	2026-05-18 19:05:43.424922	2026-05-11 19:14:25.827373	2026-05-11 19:05:43.426784	172.26.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36
95	5	$2b$12$q65vPwRgAGpG5PtNGLTbQOOybKrSYdnNCWocB9efDUMCo1CgaRMFq	2026-05-18 19:14:29.929448	2026-05-11 19:39:59.229711	2026-05-11 19:14:29.930017	172.26.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36
97	5	$2b$12$2hAyKZbwnhsxyBWR1i.f4OYF7QsGbKbpcq5rKkWqdgnY/RgRQKzee	2026-05-18 19:40:01.074836	2026-05-12 18:47:15.196577	2026-05-11 19:40:01.075736	172.26.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36
101	3	$2b$12$/dSEbC9fHNB5cXTlEWxAre0BrJG.WTGqu1KGvJY4CICdh/xOpuQzq	2026-05-19 18:47:22.879417	2026-05-28 13:40:56.993873	2026-05-12 18:47:22.880935	172.26.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36
109	3	$2b$12$eoWFCBY4rdw1LMdZ157cf.N3SrnxBPkrpKlfB7nlj49xlebTlCO3i	2026-05-20 17:56:08.349023	2026-05-28 13:40:56.993873	2026-05-13 17:56:08.35251	172.26.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36
110	3	$2b$12$VNOcCZQfMMS41ImTTlcx9.FY9yVXwFY5HeEv3E9zlQl6s/jH2tVXi	2026-05-29 16:47:07.859255	2026-05-28 13:40:56.993873	2026-05-22 16:47:07.864847	172.25.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36
111	3	$2b$12$YHlGLUPkuZ6AFVumzxiQhOe8smJUp33txOJI.dyivTqt6lH.6tjui	2026-06-02 21:31:09.446844	2026-05-28 13:40:56.993873	2026-05-26 21:31:09.474622	172.25.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36
118	3	$2b$12$31tDyZYOvd7ebFEck.2gGOtpryDINseCq3mem.Q03PLLUZT3NpIjm	2026-06-04 13:40:58.691036	2026-06-01 14:24:27.101298	2026-05-28 13:40:58.691036	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36
121	3	$2b$12$5qEM7iH/quJGD9ZufZzFXOozDL0an6WhxgU6FYTFfy3OKfSf1NAKm	2026-06-04 15:27:17.354747	2026-06-01 14:24:27.101298	2026-05-28 15:27:17.354747	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36
98	1	$2b$12$mgtk8VOn4qZ.DaYuIYVJAe5godqEoKuEJOp9AuDA5ACnL27NJQUaS	2026-05-18 19:45:08.950422	2026-06-01 20:10:09.068007	2026-05-11 19:45:08.950958	172.26.0.1	Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-GB) PowerShell/7.5.5
99	1	$2b$12$QvIUss2X0SeEiWa9i7qr1ObYePmVZKS3pRauWT28PSyV.NF7PkNGa	2026-05-18 19:46:01.543968	2026-06-01 20:10:09.068007	2026-05-11 19:46:01.544436	172.26.0.1	Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-GB) PowerShell/7.5.5
100	1	$2b$12$kKNvNqzu2k6IRE1FwcPxU.9hm1rsMb.R1fPqL2es2X9wdvBEImMvq	2026-05-18 19:46:09.421186	2026-06-01 20:10:09.068007	2026-05-11 19:46:09.421669	172.26.0.1	Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-GB) PowerShell/7.5.5
102	1	$2b$12$QCA4U7lkTG3Sp2xOK4/25uFmMCe261o5lE8QAuvpAOwdtWSiT.UQm	2026-05-20 15:32:52.451031	2026-06-01 20:10:09.068007	2026-05-13 15:32:52.457821	172.26.0.1	Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-GB) PowerShell/7.5.5
128	3	$2b$12$HDAt8ROjdyNFuN6Gne0AXuxG4C2qb4szjo6wI/D7EqxCIQxSKoDI2	2026-06-08 14:24:28.893644	2026-06-01 18:32:16.358589	2026-06-01 14:24:28.89474	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36
132	3	$2b$12$i13Auapo370T2nmD0LB2oeMaMaMy/Gm4P5r1W7imvAQapmp/iXidu	2026-06-08 16:06:45.10146	2026-06-01 18:32:16.358589	2026-06-01 16:06:45.102465	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36
135	3	$2b$12$h7MPhdP3ftjojyMjMLuXRe9hl6vIRtceLUPHSaTW7jAPW2/20tL62	2026-06-08 17:07:14.07731	2026-06-01 18:32:16.358589	2026-06-01 17:07:14.07731	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36
103	1	$2b$12$7CKfs/W4GynQEliyd5MIwOcvpb8nad4OBqJwrLKoF6VLxsD.BdaNC	2026-05-20 15:32:56.952116	2026-06-01 20:10:09.068007	2026-05-13 15:32:56.952633	172.26.0.1	Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-GB) PowerShell/7.5.5
104	1	$2b$12$zmCROx5lvaWtZ7FQBSLot.y9akSgJTKUFL6t/Fwa3lL7XGzedvQzO	2026-05-20 15:34:21.565233	2026-06-01 20:10:09.068007	2026-05-13 15:34:21.566981	172.26.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Code/1.119.0 Chrome/142.0.7444.265 Electron/39.8.8 Safari/537.36
105	1	$2b$12$2PpyRdiXVoDvxQDel3FxvOvCIlwkqZeYiRF.T/PqRx1uokOk93rD2	2026-05-20 15:35:38.865605	2026-06-01 20:10:09.068007	2026-05-13 15:35:38.866212	172.26.0.1	Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-GB) PowerShell/7.5.5
106	1	$2b$12$RAlXcMnIgyaaRv0HgmKDXOmDM6tXsOtMF2yNcvsDTBK/Joe/S3z12	2026-05-20 15:38:21.810602	2026-06-01 20:10:09.068007	2026-05-13 15:38:21.811662	172.26.0.1	Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-GB) PowerShell/7.5.5
107	1	$2b$12$dKo5dK/zg0eFYMmy1DdsYu6n3VFlAzF1STrUV1Hk.GNJtBlaZsESi	2026-05-20 15:38:51.405419	2026-06-01 20:10:09.068007	2026-05-13 15:38:51.40595	172.26.0.1	Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-GB) PowerShell/7.5.5
108	1	$2b$12$m3FD1xmviElhpyrgGvc3SesVBi0DBwsbc7uZfMTNgqa9sgq.sZ0ru	2026-05-20 15:38:56.680582	2026-06-01 20:10:09.068007	2026-05-13 15:38:56.681125	172.26.0.1	Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-GB) PowerShell/7.5.5
112	1	$2b$12$ZTboHDZm5cmaFuu/p/vZJ.ia8mS5lUu4V0vCU3mjuUEsUQdrR/6bO	2026-06-03 00:40:33.819446	2026-06-01 20:10:09.068007	2026-05-27 00:40:33.822495	172.25.0.1	python-requests/2.32.3
113	1	$2b$12$/YNAseFbaSK5SlXuwtB4mOHFGgMcqsICXXsrRBGOPO70m.rAPfkVS	2026-06-03 15:04:07.370828	2026-06-01 20:10:09.068007	2026-05-27 15:04:07.374225	172.25.0.1	python-requests/2.32.3
114	1	$2b$12$Ht1Zzz8jdniORZxeohrVVOaYrDf3ZnqZp.SERxlwq296TaKNKxtdO	2026-06-04 01:19:51.918285	2026-06-01 20:10:09.068007	2026-05-28 01:19:51.920575	172.25.0.1	python-requests/2.32.3
115	1	$2b$12$gm9HFV16iF1zdOh6/A0nc.7vuNDpU/zXd8ZY9QfARd7qDgbznNSDC	2026-06-04 01:26:23.688018	2026-06-01 20:10:09.068007	2026-05-28 01:26:23.68943	172.25.0.1	python-requests/2.32.3
116	1	$2b$12$hGmlveqLLpz.0NTINnEE5.iq0eVqEUE0DhisI0ER7icp69AgLrhr2	2026-06-04 01:34:24.165717	2026-06-01 20:10:09.068007	2026-05-28 01:34:24.167229	127.0.0.1	python-requests/2.32.3
117	1	$2b$12$uHLpmfEr9gPy.PpXIVUzNOAGdYtSFgAc78tZrvpk86l/DAyLEy522	2026-06-04 01:35:24.011854	2026-06-01 20:10:09.068007	2026-05-28 01:35:24.012374	127.0.0.1	python-requests/2.32.3
119	1	$2b$12$cyyfMAg/uNaMKCgOz5IoFuvvPlSSnBUTKji3kY/tUOAaNe3M/tqGu	2026-06-04 13:50:23.671697	2026-06-01 20:10:09.068007	2026-05-28 13:50:23.671697	127.0.0.1	python-requests/2.32.3
120	1	$2b$12$7d6kU0IqBF5JAk6Km8QnXugmqTgzgBSbUSXAgP29JvWDdn5tay3g6	2026-06-04 15:24:13.943152	2026-06-01 20:10:09.068007	2026-05-28 15:24:13.94517	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-GB) PowerShell/7.5.5
122	1	$2b$12$Drgqklrp9K/dmWgVHDOU9u6IvQT7apiIyBJYt8JHneoDoPy7bZ2XW	2026-06-04 15:30:33.224872	2026-06-01 20:10:09.068007	2026-05-28 15:30:33.224872	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-GB) PowerShell/7.5.5
123	1	$2b$12$m.Y85XZ0hmMSkWu.bQmep.A3DZetoPK.jstNB/ABhOcjb93RsOPmu	2026-06-04 15:30:51.821213	2026-06-01 20:10:09.068007	2026-05-28 15:30:51.821213	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-GB) PowerShell/7.5.5
124	1	$2b$12$udg4gaJ9RpdrsuGjG4lLEOkAIQinxASCQz.W429b8g6Fh1jMM9M4y	2026-06-04 15:45:55.793628	2026-06-01 20:10:09.068007	2026-05-28 15:45:55.79415	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-GB) PowerShell/7.5.5
125	1	$2b$12$oxD96VsXZU1wCKdqhs6Hg.s7EP8awFAeKbjp6rPJgkjYebc2Xjt9G	2026-06-04 15:48:34.263281	2026-06-01 20:10:09.068007	2026-05-28 15:48:34.26429	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-GB) PowerShell/7.5.5
126	1	$2b$12$0DtGQu7fWkpDvZT24yhz/.A3CRiTlHuyQ08wie3oR4TKnYLJXOcHq	2026-06-04 15:57:32.74939	2026-06-01 20:10:09.068007	2026-05-28 15:57:32.74939	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-GB) PowerShell/7.5.5
127	1	$2b$12$Jm6qdEN46Mzpp0uTdjjqZusRlmus6Wrv3gE8cwR94o/9vrPg5VAQS	2026-06-04 16:03:37.037115	2026-06-01 20:10:09.068007	2026-05-28 16:03:37.041305	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-GB) PowerShell/7.5.5
129	1	$2b$12$KeDZ355ulIWH0KQ5DtyqNOe2VysevPmOQ7llHdtEfzrH15MQQCRam	2026-06-08 14:55:39.451747	2026-06-01 20:10:09.068007	2026-06-01 14:55:39.452753	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-GB) PowerShell/7.5.5
130	1	$2b$12$RpvnYyW9zbol05zzVH2kEeXdvNnW1.c4Dg0Tly7nM3lqPKpxVqYnG	2026-06-08 14:55:55.691304	2026-06-01 20:10:09.068007	2026-06-01 14:55:55.69232	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-GB) PowerShell/7.5.5
131	1	$2b$12$NPE6sDZ4xrFM4f6ryfR99u0C1oETXmVDiPS09KuLVpoXNwED8uoGC	2026-06-08 15:11:41.485934	2026-06-01 20:10:09.068007	2026-06-01 15:11:41.48793	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-GB) PowerShell/7.5.5
133	1	$2b$12$usLhaLmEtH287/9Toi0lz.Qj0egMJtgnacZ.oCSHwKjRLHypeBLKa	2026-06-08 16:31:59.874831	2026-06-01 20:10:09.068007	2026-06-01 16:31:59.875831	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-GB) PowerShell/7.5.5
134	1	$2b$12$tUU8ldlB29pZ1NBsQ0vrheTwQ1NMJJ5jjp0a7ywK93mgqOwl2T/nG	2026-06-08 16:49:19.188264	2026-06-01 20:10:09.068007	2026-06-01 16:49:19.189266	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-GB) PowerShell/7.5.5
136	1	$2b$12$6aaiBAhUvhdtneCzYE16sO5ZZS9EqVd3IIdN01sOnBvrnjnSBlV2a	2026-06-08 18:32:21.844703	2026-06-01 20:10:09.068007	2026-06-01 18:32:21.845707	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36
138	3	$2b$12$she2tKOaXl7gYXI8z8btDOElJ0X01D7LMqLYqvT.VdXee.sYDMNPu	2026-06-09 20:46:45.97746	2026-06-08 14:10:08.123182	2026-06-02 20:46:45.989461	172.25.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36
139	1	$2b$12$vcd1yk/ta77DuNqXuvhRU.333woHGZfD8.XdNPNV3PYX/.pnqBrzq	2026-06-15 14:10:18.889571	2026-06-08 14:10:47.408631	2026-06-08 14:10:18.891222	172.25.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36
141	1	$2b$12$Kk.xHm7oiEMfOPZHKVdPueqNpJRXaGEO/A.bro1e/e63DFxQDLVB6	2026-06-17 12:39:34.107264	\N	2026-06-10 12:39:34.11251	172.25.0.1	python-requests/2.32.3
140	3	$2b$12$Up04U50N8AvyudGFOqk1KO3hjIdaMc0/NBZwKlF5PtmRVDaQ6Vjiu	2026-06-15 14:10:53.96115	2026-06-29 16:55:44.161129	2026-06-08 14:10:53.961698	172.25.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36
142	3	$2b$12$KvO9cuLVkljWCqU.GPVD4.RnKjGHPZna74CQGesXrIxeNc3sWei2m	2026-06-20 14:39:36.590033	2026-06-29 16:55:44.161129	2026-06-13 14:39:36.599836	172.25.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36
143	3	$2b$12$yD04/cckhe9cm9rexIBiQeoRaK02qbTbnhKPBMcHjlU8yzRuBLvEq	2026-07-06 16:50:58.879615	2026-06-29 16:55:44.161129	2026-06-29 16:50:58.887885	172.25.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36
137	2	$2b$12$gQxFto7LSqTXsskYvFfn5ePFYtjfOmL25tHYtj40mzLDCb6PsyzE2	2026-06-08 20:10:24.337695	2026-06-29 16:56:30.116639	2026-06-01 20:10:24.339066	172.25.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36
144	2	$2b$12$gy8ZRVFiEJxtFqLSnX4qTOG8DDoC1J9NJ6TxeiJMOO6v.PIkqsjYu	2026-07-06 16:55:52.140939	2026-06-29 16:56:30.116639	2026-06-29 16:55:52.141564	172.25.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36
145	3	$2b$12$sT9Lb0jYG0sFXklNy/8OHehynst2CBFGMhfVLP0B6pgKxvZlATYua	2026-07-06 16:56:37.005828	2026-06-30 14:37:11.80422	2026-06-29 16:56:37.006375	172.25.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36
146	3	$2b$12$3tp0pkmQoIbtgKyzBHzEjOlNUkeW4cPTCJeTKARFBmjxsYmiCov.m	2026-07-07 14:37:17.183592	2026-06-30 14:37:19.836194	2026-06-30 14:37:17.18651	172.25.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36
147	2	$2b$12$D1tSYSvCo52zF2dnEsWfneK.9lOsMqKe2/Y3oDQdwLJbHC3obf29S	2026-07-07 14:37:25.103903	\N	2026-06-30 14:37:25.104661	172.25.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36
148	2	$2b$12$REhG1ajvgp6J4PbHsU5fMucksio3jsGDbRcURqgpnuVaBt8TuCaI.	2026-07-08 15:02:46.862671	\N	2026-07-01 15:02:46.863678	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36
149	3	$2b$12$oFwRUOs1vbMIV5tPjWX3SOTQkwHeqgpdbaySSBI0asy1i0ZQY8gba	2026-07-13 17:57:24.547867	\N	2026-07-06 17:57:24.550302	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36
150	3	$2b$12$jXaZGDEFtOD8xqfZ9Ff.ru.qhjvzaq8JJMNjdbiQ743N4LflGyfoS	2026-07-17 20:30:57.688009	\N	2026-07-10 20:30:57.691487	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36
\.


--
-- Data for Name: role_permissions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.role_permissions (role_id, permission_id) FROM stdin;
1	1
1	2
1	3
1	4
1	5
1	6
1	7
1	8
1	9
1	10
1	11
1	12
1	13
1	14
1	15
1	16
1	17
1	18
1	19
1	20
2	1
2	7
2	2
2	8
2	19
2	4
2	10
2	5
3	1
3	7
3	19
3	4
3	10
1	24
2	24
3	24
1	26
1	21
2	21
3	21
1	22
2	22
1	23
1	25
2	25
2	26
\.


--
-- Data for Name: roles; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.roles (id, name, description, created_at, updated_at) FROM stdin;
1	ADMIN	Administrador con acceso total	2026-04-08 17:11:08.039356	2026-04-08 17:11:08.039356
2	WRITER	Editor ÔÇö puede leer y escribir datos	2026-04-08 17:11:08.050974	2026-04-08 17:11:08.050974
3	READER	Lector ÔÇö solo lectura	2026-04-08 17:11:08.062507	2026-04-08 17:11:08.062507
4	WRITER_PROJ_f233dcb9	Writer for projection tests	2026-06-10 12:39:41.883369	2026-06-10 12:39:41.883369
5	WRITER_PROJ_8a115a8c	Writer for projection tests	2026-06-10 12:39:42.147994	2026-06-10 12:39:42.147994
6	WRITER_PROJ_615d0bcf	Writer for projection tests	2026-06-10 12:39:42.225292	2026-06-10 12:39:42.225292
7	WRITER_PROJ_1b2e3164	Writer for projection tests	2026-06-10 12:39:42.372811	2026-06-10 12:39:42.372811
8	WRITER_PROJ_1070a784	Writer for projection tests	2026-06-10 12:39:42.443061	2026-06-10 12:39:42.443061
9	WRITER_PROJ_ef927f38	Writer for projection tests	2026-06-10 12:39:42.585975	2026-06-10 12:39:42.585975
\.


--
-- Data for Name: test_123; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.test_123 (id) FROM stdin;
\.


--
-- Data for Name: transactions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.transactions (id, "timestamp", date, type, amount, necessity, payment_method, detail, created_at, debt_id, assignment_status, category_id, user_id) FROM stdin;
981	2026-04-10 19:27:58.670092	2026-04-05	GASTO	600000	NECESARIO	Transferencia	Pago Ciudad - VISA (03/2026)	2026-04-10 19:27:58.670092	\N	ASIGNADA_MANUAL	36	4
982	2026-04-10 19:27:58.678013	2026-04-08	GASTO	253695.94	NECESARIO	D├®bito	DEB. AUTOM. DE SERV. ZURICH ARGENTINA DEBZURICH 242213054 242213054	2026-04-10 19:27:58.678013	\N	ASIGNADA_MANUAL	28	4
983	2026-04-10 19:27:58.680087	2026-04-08	GASTO	22530.02	NECESARIO	D├®bito	DEB. AUTOM. DE SERV. ZURICH ARGENTINA DEBZURICH 242474598 242474598	2026-04-10 19:27:58.680087	\N	ASIGNADA_MANUAL	28	4
984	2026-04-10 19:27:58.681641	2026-04-09	GASTO	3000	NECESARIO	D├®bito	Fotocopias	2026-04-10 19:27:58.681641	\N	ASIGNADA_MANUAL	21	4
985	2026-04-10 19:27:58.682656	2026-04-09	GASTO	16800	NECESARIO	D├®bito	Chino	2026-04-10 19:27:58.682656	\N	ASIGNADA_MANUAL	13	4
986	2026-04-10 19:27:58.683869	2026-04-08	GASTO	8000	NECESARIO	D├®bito	COMPRA DEBITO MAXIKIOSCO FARID 4517XXXXXXXXXX73 A728	2026-04-10 19:27:58.683869	\N	ASIGNADA_MANUAL	13	4
987	2026-04-10 19:27:58.685389	2026-04-03	INGRESO	1050000	NECESARIO	D├®bito	Devoluci├│n Ganancias 4ta Cat	2026-04-10 19:27:58.685389	\N	ASIGNADA_MANUAL	20	4
988	2026-04-10 19:27:58.686477	2026-04-03	INGRESO	2150000	NECESARIO	D├®bito	Sueldo Chicha	2026-04-10 19:27:58.686477	\N	ASIGNADA_MANUAL	15	4
989	2026-04-10 19:27:58.687582	2026-04-03	INGRESO	478000	NECESARIO	D├®bito	Alquiler Monte	2026-04-10 19:27:58.687582	\N	ASIGNADA_MANUAL	19	4
990	2026-04-10 19:27:58.689094	2026-04-09	GASTO	9100	NECESARIO	D├®bito	Pr├®stamos a Priscila	2026-04-10 19:27:58.689094	\N	ASIGNADA_MANUAL	21	4
991	2026-04-10 19:27:58.690116	2026-04-09	GASTO	18200	NECESARIO	D├®bito	Chino	2026-04-10 19:27:58.690116	\N	ASIGNADA_MANUAL	13	4
992	2026-04-10 19:27:58.691215	2026-04-09	GASTO	2400	NECESARIO	D├®bito	Chino	2026-04-10 19:27:58.691215	\N	ASIGNADA_MANUAL	13	4
993	2026-04-10 19:27:58.692513	2026-04-09	GASTO	1084080	NECESARIO	D├®bito	Sueldo C├®sar Marzo	2026-04-10 19:27:58.692513	\N	ASIGNADA_MANUAL	22	4
994	2026-04-10 19:27:58.694339	2026-04-07	GASTO	27800	NECESARIO	D├®bito	Chino	2026-04-10 19:27:58.694339	\N	ASIGNADA_MANUAL	13	4
995	2026-04-10 19:27:58.694339	2026-04-07	GASTO	100000	NECESARIO	D├®bito	Psicologa Chicha	2026-04-10 19:27:58.694339	\N	ASIGNADA_MANUAL	22	4
996	2026-04-10 19:27:58.697079	2026-04-06	GASTO	10000	NECESARIO	D├®bito	SUBE	2026-04-10 19:27:58.697079	\N	ASIGNADA_MANUAL	14	4
997	2026-04-10 19:27:58.699077	2026-04-05	GASTO	1031203.5	NECESARIO	D├®bito	ITBA	2026-04-10 19:27:58.699077	\N	ASIGNADA_MANUAL	21	4
998	2026-04-10 19:27:58.700719	2026-04-01	INGRESO	2535558	NECESARIO	D├®bito	Sueldo Sergio	2026-04-10 19:27:58.700719	\N	ASIGNADA_MANUAL	15	4
999	2026-04-10 19:27:58.702733	2026-04-04	GASTO	147000	NECESARIO	D├®bito	Pr├®stamo MP Chicha	2026-04-10 19:27:58.702733	\N	ASIGNADA_MANUAL	17	4
1000	2026-04-10 19:27:58.70373	2026-04-04	GASTO	16900	NECESARIO	D├®bito	Chino	2026-04-10 19:27:58.70373	\N	ASIGNADA_MANUAL	13	4
1001	2026-04-10 19:27:58.705243	2026-04-04	GASTO	30000	NECESARIO	D├®bito	Huevitos de pascua	2026-04-10 19:27:58.705243	\N	ASIGNADA_MANUAL	13	4
954	2026-04-07 00:53:13.527	2026-04-05	GASTO	600000	NECESARIO	Transferencia	Pago Ciudad - VISA (03/2026)	2026-04-07 00:53:13.854162	145	ASIGNADA_MANUAL	36	1
977	2026-04-09 19:03:41.01	2026-04-08	GASTO	253695.94	NECESARIO	D├®bito	DEB. AUTOM. DE SERV. ZURICH ARGENTINA DEBZURICH 242213054 242213054	2026-04-09 19:03:45.619303	159	ASIGNADA_MANUAL	28	1
979	2026-04-09 19:03:41.01	2026-04-08	GASTO	22530.02	NECESARIO	D├®bito	DEB. AUTOM. DE SERV. ZURICH ARGENTINA DEBZURICH 242474598 242474598	2026-04-09 19:03:45.634468	159	ASIGNADA_MANUAL	28	1
971	2026-04-09 19:03:41.01	2026-04-09	GASTO	3000	NECESARIO	D├®bito	Fotocopias	2026-04-09 19:03:45.5604	155	ASIGNADA_MANUAL	21	1
1002	2026-04-10 19:27:58.705754	2026-04-04	GASTO	25000	NECESARIO	D├®bito	Lavado Auto	2026-04-10 19:27:58.705754	\N	ASIGNADA_MANUAL	14	4
973	2026-04-09 19:03:41.01	2026-04-09	GASTO	16800	NECESARIO	D├®bito	Chino	2026-04-09 19:03:45.590602	161	ASIGNADA_MANUAL	13	1
1003	2026-04-10 19:27:58.707071	2026-04-04	GASTO	4300	NECESARIO	D├®bito	Chino	2026-04-10 19:27:58.707071	\N	ASIGNADA_MANUAL	13	4
975	2026-04-09 19:03:41.01	2026-04-08	GASTO	8000	NECESARIO	D├®bito	COMPRA DEBITO MAXIKIOSCO FARID 4517XXXXXXXXXX73 A728	2026-04-09 19:03:45.604927	161	ASIGNADA_MANUAL	13	1
835	2026-04-03 02:14:35.468	2026-03-31	GASTO	243000	NECESARIO	D├®bito	Seguro Auto	2026-04-03 02:14:35.786801	132	ASIGNADA_MANUAL	28	1
837	2026-04-03 02:15:30.757	2026-03-10	GASTO	22500	NECESARIO	D├®bito	Seguro Tone	2026-04-03 02:15:30.769305	132	ASIGNADA_MANUAL	28	1
836	2026-04-03 02:14:54.236	2026-03-10	GASTO	22500	NECESARIO	D├®bito	Seguro Monte	2026-04-03 02:14:54.246171	132	ASIGNADA_MANUAL	28	1
838	2026-04-03 02:21:02.742	2026-04-03	INGRESO	1050000	NECESARIO	D├®bito	Devoluci├│n Ganancias 4ta Cat	2026-04-03 02:21:02.752471	168	ASIGNADA_MANUAL	20	1
840	2026-04-03 02:23:05.321	2026-04-03	INGRESO	2150000	NECESARIO	D├®bito	Sueldo Chicha	2026-04-03 02:23:05.639888	167	ASIGNADA_MANUAL	15	1
839	2026-04-03 02:21:51.679	2026-04-03	INGRESO	478000	NECESARIO	D├®bito	Alquiler Monte	2026-04-03 02:21:51.696001	150	ASIGNADA_MANUAL	19	1
857	2026-04-04 02:06:51.019	2026-03-05	GASTO	300000	NECESARIO	D├®bito	Multas 2/2	2026-04-04 02:06:51.041038	124	ASIGNADA_MANUAL	29	1
296	2026-03-18 21:44:08.391	2026-03-18	GASTO	20000	NECESARIO	D├®bito	Auris Mica	2026-03-18 21:44:08.457129	125	ASIGNADA_MANUAL	13	1
970	2026-04-09 19:03:41.01	2026-04-09	GASTO	9100	NECESARIO	D├®bito	Pr├®stamos a Priscila	2026-04-09 19:03:45.504929	155	ASIGNADA_MANUAL	21	1
795	2026-03-31 01:28:12.112	2026-03-30	GASTO	150000	NECESARIO	D├®bito	Nafta + Aceite + Refrigerante	2026-03-31 01:28:17.492773	93	ASIGNADA_MANUAL	14	1
974	2026-04-09 19:03:41.01	2026-04-09	GASTO	18200	NECESARIO	D├®bito	Chino	2026-04-09 19:03:45.597318	161	ASIGNADA_MANUAL	13	1
972	2026-04-09 19:03:41.01	2026-04-09	GASTO	2400	NECESARIO	D├®bito	Chino	2026-04-09 19:03:45.57965	161	ASIGNADA_MANUAL	13	1
980	2026-04-09 19:03:41.01	2026-04-09	GASTO	1084080	NECESARIO	D├®bito	Sueldo C├®sar Marzo	2026-04-09 19:03:45.646996	152	ASIGNADA_MANUAL	22	1
1004	2026-04-10 19:27:58.709089	2026-04-04	GASTO	12100	NECESARIO	D├®bito	Chino	2026-04-10 19:27:58.709089	\N	ASIGNADA_MANUAL	13	4
1005	2026-04-10 19:27:58.709716	2026-04-01	GASTO	46675	NECESARIO	D├®bito	Multas 2/12	2026-04-10 19:27:58.709716	\N	ASIGNADA_MANUAL	20	4
1006	2026-04-10 19:27:58.711238	2026-04-01	GASTO	130000	NECESARIO	D├®bito	Deuda Carnicer├¡a	2026-04-10 19:27:58.711238	\N	ASIGNADA_MANUAL	13	4
1007	2026-04-10 19:27:58.713494	2026-04-05	GASTO	301034.46	NECESARIO	Transferencia	Pago ICBC - VISA ICBC (03/2026)	2026-04-10 19:27:58.713494	\N	ASIGNADA_MANUAL	36	4
1008	2026-04-10 19:27:58.715085	2026-04-07	GASTO	1405372	NECESARIO	Transferencia	Pago Ciudad - VISA (03/2026)	2026-04-10 19:27:58.715085	\N	ASIGNADA_MANUAL	36	4
1009	2026-04-10 19:27:58.716477	2026-04-08	GASTO	8145	NECESARIO	D├®bito	COMPRA DEBITO MERPAGO*SUPERDIA 4517XXXXXXXXXX73 A894	2026-04-10 19:27:58.716477	\N	ASIGNADA_MANUAL	13	4
1010	2026-04-10 19:27:58.71796	2026-04-06	GASTO	11400	NECESARIO	D├®bito	Carnicer├¡a	2026-04-10 19:27:58.71796	\N	ASIGNADA_MANUAL	13	4
1011	2026-04-10 19:27:58.719007	2026-04-06	GASTO	5178.26	NECESARIO	D├®bito	Pr├®stamo MP Sergio	2026-04-10 19:27:58.719007	\N	ASIGNADA_MANUAL	17	4
1012	2026-04-10 19:27:58.72002	2026-04-06	GASTO	18900	NECESARIO	D├®bito	Librer├¡a Experimento Mica	2026-04-10 19:27:58.72002	\N	ASIGNADA_MANUAL	21	4
1013	2026-04-10 19:27:58.721535	2026-04-05	GASTO	683399.81	NECESARIO	D├®bito	Alquiler Tone	2026-04-10 19:27:58.721535	\N	ASIGNADA_MANUAL	19	4
1014	2026-04-10 19:27:58.723146	2026-04-05	GASTO	32390.03	NECESARIO	D├®bito	Movistar Mica Feb y Marzo	2026-04-10 19:27:58.723146	\N	ASIGNADA_MANUAL	24	4
1015	2026-04-10 19:27:58.72417	2026-04-05	GASTO	33000	NECESARIO	D├®bito	Honorarios Alquiler Tone	2026-04-10 19:27:58.72417	\N	ASIGNADA_MANUAL	19	4
1016	2026-04-10 19:27:58.725773	2026-04-05	GASTO	20000	NECESARIO	D├®bito	Comida y Art limpieza DIA	2026-04-10 19:27:58.725773	\N	ASIGNADA_MANUAL	13	4
1017	2026-04-10 19:27:58.726792	2026-04-04	GASTO	1000	NECESARIO	D├®bito	Sancor Seguros	2026-04-10 19:27:58.726792	\N	ASIGNADA_MANUAL	28	4
1018	2026-04-10 19:27:58.727804	2026-04-01	GASTO	32000	NECESARIO	D├®bito	Rotiser├¡a	2026-04-10 19:27:58.727804	\N	ASIGNADA_MANUAL	13	4
1019	2026-04-10 19:27:58.727804	2026-04-01	GASTO	4980	NECESARIO	D├®bito	DIA	2026-04-10 19:27:58.727804	\N	ASIGNADA_MANUAL	13	4
1020	2026-04-10 19:27:58.730259	2026-04-01	GASTO	20800	NECESARIO	D├®bito	Chino	2026-04-10 19:27:58.730259	\N	ASIGNADA_MANUAL	13	4
1021	2026-04-10 19:27:58.730259	2026-04-01	GASTO	39000	NECESARIO	D├®bito	Verduler├¡a	2026-04-10 19:27:58.730259	\N	ASIGNADA_MANUAL	13	4
1022	2026-04-10 19:27:58.731764	2026-04-01	GASTO	10000	NECESARIO	D├®bito	Panader├¡a	2026-04-10 19:27:58.731764	\N	ASIGNADA_MANUAL	13	4
1023	2026-04-10 19:27:58.733268	2026-04-01	GASTO	40321.45	NECESARIO	D├®bito	CUOTA DE PRESTAMO CUOTA 5/6	2026-04-10 19:27:58.733268	\N	ASIGNADA_MANUAL	17	4
1024	2026-04-10 19:27:58.734446	2026-04-01	GASTO	5700	NECESARIO	D├®bito	Verduler├¡a	2026-04-10 19:27:58.734446	\N	ASIGNADA_MANUAL	13	4
1025	2026-04-10 19:27:58.735839	2026-04-01	GASTO	50000	NECESARIO	D├®bito	Comida Mica	2026-04-10 19:27:58.735839	\N	ASIGNADA_MANUAL	13	4
1026	2026-04-10 19:27:58.736905	2026-04-01	GASTO	13425	NECESARIO	D├®bito	DIA	2026-04-10 19:27:58.736905	\N	ASIGNADA_MANUAL	13	4
1027	2026-04-10 19:27:58.737996	2026-04-06	INGRESO	285000	NECESARIO	D├®bito	Garantia Fed Devol 1/2	2026-04-10 19:27:58.737996	\N	ASIGNADA_MANUAL	15	4
1028	2026-04-10 19:27:58.738994	2026-04-07	GASTO	10000	NECESARIO	D├®bito	Panderia	2026-04-10 19:27:58.738994	\N	ASIGNADA_MANUAL	13	4
841	2026-04-04 00:09:24.946	2026-03-21	GASTO	404000	NECESARIO	D├®bito	Comida Mica	2026-04-04 00:09:24.959738	91	ASIGNADA_MANUAL	13	1
955	2026-04-07 14:59:33.844	2026-03-07	GASTO	100000	NECESARIO	Transferencia	Pago ICBC - VISA ICBC (02/2026)	2026-04-07 14:59:33.879424	147	ASIGNADA_MANUAL	36	1
292	2026-03-17 20:33:16.124	2026-03-06	GASTO	21500	NECESARIO	D├®bito	Papel Higienico	2026-03-17 20:33:17.977361	125	ASIGNADA_MANUAL	16	1
284	2026-03-17 20:33:16.124	2026-03-01	GASTO	723000	NECESARIO	D├®bito	Alquiler Tone	2026-03-17 20:33:17.910387	125	ASIGNADA_MANUAL	16	1
289	2026-03-17 20:33:16.124	2026-03-03	GASTO	36000	NECESARIO	D├®bito	Taller Teatro	2026-03-17 20:33:17.955086	120	ASIGNADA_MANUAL	21	1
206	2026-03-08 00:11:35.057	2026-03-08	INGRESO	2000000	NECESARIO	D├®bito	Extracci├│n Dinero Tarj	2026-03-11 23:45:30.765909	136	ASIGNADA_MANUAL	15	1
269	2026-03-17 18:02:49.574	2026-03-16	GASTO	155960	NECESARIO	D├®bito	Proetica fcia ges	2026-03-17 18:02:53.91915	97	ASIGNADA_MANUAL	22	1
288	2026-03-17 20:33:16.124	2026-03-03	GASTO	45000	NECESARIO	D├®bito	Curso Chicha Feb	2026-03-17 20:33:17.946314	120	ASIGNADA_MANUAL	21	1
963	2026-04-08 01:00:38.009	31-03-2026	GASTO	7800	NECESARIO	D├®bito	DEB.AUTOM - PAGO SERVICIO DB AUTOMATICO	2026-04-08 01:00:40.103109	\N	ASIGNADA_MANUAL	31	1
964	2026-04-08 01:00:38.009	31-03-2026	GASTO	7800	NECESARIO	D├®bito	DEB.AUTOM - PAGO SERVICIO DB AUTOMATICO	2026-04-08 01:00:40.111131	\N	ASIGNADA_MANUAL	31	1
966	2026-04-08 01:00:38.009	2026-04-07	GASTO	27800	NECESARIO	D├®bito	Chino	2026-04-08 01:00:40.128289	161	ASIGNADA_MANUAL	13	1
967	2026-04-08 01:00:38.009	2026-04-07	GASTO	100000	NECESARIO	D├®bito	Psicologa Chicha	2026-04-08 01:00:40.136109	158	ASIGNADA_MANUAL	22	1
968	2026-04-08 01:00:38.009	2026-04-06	GASTO	10000	NECESARIO	D├®bito	SUBE	2026-04-08 01:00:40.144266	165	ASIGNADA_MANUAL	14	1
297	2026-03-18 22:28:00.319	2026-03-18	GASTO	50000	NECESARIO	D├®bito	Nafta	2026-03-18 22:28:00.654225	93	ASIGNADA_MANUAL	14	1
191	2026-03-07 23:44:02.651	2026-03-03	INGRESO	478000	NECESARIO	D├®bito	Alquiler Monte	2026-03-11 23:45:30.730948	134	ASIGNADA_MANUAL	19	1
193	2026-03-07 23:44:02.651	2026-03-03	GASTO	55448	NECESARIO	D├®bito	Movistar 1 Feb	2026-03-11 23:45:30.735636	122	ASIGNADA_MANUAL	24	1
194	2026-03-07 23:44:02.651	2026-03-03	GASTO	46880	NECESARIO	D├®bito	Movistar 2 Feb	2026-03-11 23:45:30.737901	122	ASIGNADA_MANUAL	24	1
399	2026-03-25 15:19:48.335	2026-03-25	GASTO	49325.56	NECESARIO	D├®bito	Movistar Chicha Marzo	2026-03-25 15:19:48.686986	122	ASIGNADA_MANUAL	24	1
286	2026-03-17 20:33:16.124	2026-03-02	GASTO	90000	NECESARIO	D├®bito	Adriana Psico	2026-03-17 20:33:17.927433	110	ASIGNADA_MANUAL	22	1
196	2026-03-07 23:44:02.651	2026-03-03	GASTO	14756	NECESARIO	D├®bito	Metrogas Tone	2026-03-11 23:45:30.741925	122	ASIGNADA_MANUAL	24	1
183	2026-03-07 23:44:02.651	2026-03-02	GASTO	9000	NECESARIO	D├®bito	Ferreteria	2026-03-11 23:45:30.71114	125	ASIGNADA_MANUAL	16	1
197	2026-03-07 23:44:02.651	2026-03-03	GASTO	570000	NECESARIO	D├®bito	Garantia Fede	2026-03-11 23:45:30.743991	130	ASIGNADA_MANUAL	18	1
283	2026-03-17 20:33:16.124	2026-03-01	GASTO	1031203.5	NECESARIO	D├®bito	ITBA Febrero	2026-03-17 20:33:17.902359	120	ASIGNADA_MANUAL	21	1
190	2026-03-07 23:44:02.651	2026-03-02	GASTO	66734	NECESARIO	D├®bito	Cr├®dito ANSES	2026-03-11 23:45:30.727736	95	ASIGNADA_MANUAL	17	1
184	2026-03-07 23:44:02.651	2026-03-02	GASTO	100000	NECESARIO	D├®bito	Protesis 2/2	2026-03-11 23:45:30.713901	97	ASIGNADA_MANUAL	22	1
282	2026-03-17 20:33:16.124	2026-03-01	GASTO	1084080	NECESARIO	D├®bito	Sueldo C├®sar	2026-03-17 20:33:17.886921	110	ASIGNADA_MANUAL	22	1
181	2026-03-07 23:44:02.651	2026-03-01	GASTO	2507	NECESARIO	D├®bito	SUBE	2026-03-11 23:45:30.706942	119	ASIGNADA_MANUAL	14	1
210	2026-03-11 16:35:11.463	2026-03-10	INGRESO	396000	NECESARIO	D├®bito	Fac Vivian	2026-03-11 23:45:30.774082	137	ASIGNADA_MANUAL	15	1
195	2026-03-07 23:44:02.651	2026-03-03	GASTO	104550	NECESARIO	D├®bito	Edesur	2026-03-11 23:45:30.73983	122	ASIGNADA_MANUAL	24	1
180	2026-03-07 23:44:02.651	2026-03-01	INGRESO	2561000	NECESARIO	D├®bito	Sueldo Sergio	2026-03-11 23:45:30.704868	131	ASIGNADA_MANUAL	15	1
216	2026-03-14 16:44:39.195	2026-03-14	INGRESO	1970000	NECESARIO	D├®bito	Adelanto Sueldo Sergio	2026-03-14 16:44:39.3044	135	ASIGNADA_MANUAL	15	1
270	2026-03-17 18:02:49.574	2026-03-16	GASTO	20000	NECESARIO	D├®bito	Comida Chicha	2026-03-17 18:02:53.91915	91	ASIGNADA_MANUAL	13	1
218	2026-03-14 16:46:06.417	2026-03-14	GASTO	15750	NECESARIO	D├®bito	DIA	2026-03-14 16:46:06.430475	91	ASIGNADA_MANUAL	13	1
214	2026-03-11 23:53:30.463	2026-03-11	GASTO	7100	NECESARIO	D├®bito	Chino	2026-03-11 23:53:30.483371	91	ASIGNADA_MANUAL	13	1
271	2026-03-17 18:02:49.574	2026-03-16	GASTO	34844	NECESARIO	D├®bito	Pr├®stamos MP	2026-03-17 18:02:53.91915	95	ASIGNADA_MANUAL	17	1
199	2026-03-07 23:44:02.651	2026-03-15	GASTO	3701	NECESARIO	D├®bito	Comida Chicha	2026-03-11 23:45:30.749335	91	ASIGNADA_MANUAL	13	1
274	2026-03-17 18:02:49.574	2026-03-14	GASTO	50000	NECESARIO	D├®bito	Comida Mica	2026-03-17 18:02:53.91915	121	ASIGNADA_MANUAL	13	1
222	2026-03-14 22:04:22.528	2026-03-14	GASTO	10812	NECESARIO	D├®bito	DIA Merienda	2026-03-14 22:04:22.568418	91	ASIGNADA_MANUAL	13	1
217	2026-03-14 16:45:23.769	2026-03-14	GASTO	1363	NECESARIO	D├®bito	SUBE	2026-03-14 16:45:23.781125	119	ASIGNADA_MANUAL	14	1
215	2026-03-11 23:53:43.862	2026-03-11	GASTO	9400	NECESARIO	D├®bito	Panchos	2026-03-11 23:53:43.867909	91	ASIGNADA_MANUAL	13	1
207	2026-03-08 00:26:47.746	2026-03-05	GASTO	10000	NECESARIO	D├®bito	Almuerzo Sergio	2026-03-11 23:45:30.767985	91	ASIGNADA_MANUAL	13	1
209	2026-03-11 16:35:11.463	2026-03-09	GASTO	30000	NECESARIO	D├®bito	SUBE	2026-03-11 23:45:30.772099	119	ASIGNADA_MANUAL	14	1
268	2026-03-17 18:02:49.574	2026-03-16	GASTO	37300	NECESARIO	D├®bito	Chino	2026-03-17 18:02:53.91915	91	ASIGNADA_MANUAL	13	1
272	2026-03-17 18:02:49.574	2026-03-15	GASTO	87000	NECESARIO	D├®bito	Rotiseria	2026-03-17 18:02:53.91915	91	ASIGNADA_MANUAL	13	1
276	2026-03-17 18:02:49.574	2026-03-14	GASTO	6800	NECESARIO	D├®bito	Panaderia	2026-03-17 18:02:53.91915	91	ASIGNADA_MANUAL	13	1
275	2026-03-17 18:02:49.574	2026-03-14	GASTO	14000	NECESARIO	D├®bito	Comida Gato	2026-03-17 18:02:53.91915	91	ASIGNADA_MANUAL	13	1
201	2026-03-07 23:44:02.651	2026-03-06	GASTO	3700	NECESARIO	D├®bito	Comida Chicha	2026-03-11 23:45:30.753607	91	ASIGNADA_MANUAL	13	1
202	2026-03-07 23:44:02.651	2026-03-06	GASTO	50000	NECESARIO	D├®bito	Comida Mica	2026-03-11 23:45:30.755857	91	ASIGNADA_MANUAL	13	1
186	2026-03-07 23:44:02.651	2026-03-03	GASTO	2000	NECESARIO	D├®bito	Coquita	2026-03-11 23:45:30.718607	91	ASIGNADA_MANUAL	13	1
187	2026-03-07 23:44:02.651	2026-03-03	GASTO	5900	NECESARIO	D├®bito	DIA	2026-03-11 23:45:30.721409	91	ASIGNADA_MANUAL	13	1
188	2026-03-07 23:44:02.651	2026-03-03	GASTO	22930	NECESARIO	D├®bito	Comida DIA	2026-03-11 23:45:30.723702	91	ASIGNADA_MANUAL	13	1
189	2026-03-07 23:44:02.651	2026-03-03	GASTO	22000	NECESARIO	D├®bito	Rotiseria	2026-03-11 23:45:30.725734	91	ASIGNADA_MANUAL	13	1
192	2026-03-07 23:44:02.651	2026-03-03	GASTO	64000	NECESARIO	D├®bito	Chino	2026-03-11 23:45:30.733551	91	ASIGNADA_MANUAL	13	1
1029	2026-04-10 19:27:58.740445	2026-04-08	GASTO	24336.22	NECESARIO	D├®bito	DEB. AUTOM. DE SERV. ZURICH ARG CS SA CUOTAS P 082364811000401 00000000000178014	2026-04-10 19:27:58.740445	\N	ASIGNADA_MANUAL	28	4
1474	2026-04-13 22:37:30.025582	2026-04-05	GASTO	600000	NECESARIO	Transferencia	Pago Ciudad - VISA (03/2026)	2026-04-13 22:37:30.025582	371	ASIGNADA_MANUAL	36	3
1506	2026-04-13 22:37:30.088299	2026-03-18	GASTO	50000	NECESARIO	D├®bito	Nafta	2026-04-13 22:37:30.088299	357	ASIGNADA_MANUAL	14	3
1475	2026-04-13 22:37:30.035939	2026-04-08	GASTO	253695.94	NECESARIO	D├®bito	DEB. AUTOM. DE SERV. ZURICH ARGENTINA DEBZURICH 242213054 242213054	2026-04-13 22:37:30.035939	382	ASIGNADA_MANUAL	28	3
1476	2026-04-13 22:37:30.038305	2026-04-08	GASTO	22530.02	NECESARIO	D├®bito	DEB. AUTOM. DE SERV. ZURICH ARGENTINA DEBZURICH 242474598 242474598	2026-04-13 22:37:30.038305	382	ASIGNADA_MANUAL	28	3
1477	2026-04-13 22:37:30.039721	2026-04-09	GASTO	3000	NECESARIO	D├®bito	Fotocopias	2026-04-13 22:37:30.039721	375	ASIGNADA_MANUAL	21	3
1478	2026-04-13 22:37:30.042224	2026-04-09	GASTO	16800	NECESARIO	D├®bito	Chino	2026-04-13 22:37:30.042224	378	ASIGNADA_MANUAL	13	3
1479	2026-04-13 22:37:30.043224	2026-04-08	GASTO	8000	NECESARIO	D├®bito	COMPRA DEBITO MAXIKIOSCO FARID 4517XXXXXXXXXX73 A728	2026-04-13 22:37:30.043224	378	ASIGNADA_MANUAL	13	3
1480	2026-04-13 22:37:30.045197	2026-03-31	GASTO	243000	NECESARIO	D├®bito	Seguro Auto	2026-04-13 22:37:30.045197	350	ASIGNADA_MANUAL	28	3
1481	2026-04-13 22:37:30.046205	2026-03-10	GASTO	22500	NECESARIO	D├®bito	Seguro Tone	2026-04-13 22:37:30.046205	350	ASIGNADA_MANUAL	28	3
1482	2026-04-13 22:37:30.04814	2026-03-10	GASTO	22500	NECESARIO	D├®bito	Seguro Monte	2026-04-13 22:37:30.04814	350	ASIGNADA_MANUAL	28	3
1483	2026-04-13 22:37:30.050637	2026-04-03	INGRESO	1050000	NECESARIO	D├®bito	Devoluci├│n Ganancias 4ta Cat	2026-04-13 22:37:30.050637	365	ASIGNADA_MANUAL	20	3
1484	2026-04-13 22:37:30.052639	2026-04-03	INGRESO	2150000	NECESARIO	D├®bito	Sueldo Chicha	2026-04-13 22:37:30.052639	369	ASIGNADA_MANUAL	15	3
1485	2026-04-13 22:37:30.054639	2026-04-03	INGRESO	478000	NECESARIO	D├®bito	Alquiler Monte	2026-04-13 22:37:30.054639	364	ASIGNADA_MANUAL	19	3
1486	2026-04-13 22:37:30.055636	2026-03-05	GASTO	300000	NECESARIO	D├®bito	Multas 2/2	2026-04-13 22:37:30.055636	370	ASIGNADA_MANUAL	29	3
1487	2026-04-13 22:37:30.057241	2026-03-18	GASTO	20000	NECESARIO	D├®bito	Auris Mica	2026-04-13 22:37:30.057241	360	ASIGNADA_MANUAL	13	3
1488	2026-04-13 22:37:30.059656	2026-04-09	GASTO	9100	NECESARIO	D├®bito	Pr├®stamos a Priscila	2026-04-13 22:37:30.059656	375	ASIGNADA_MANUAL	21	3
1489	2026-04-13 22:37:30.060656	2026-03-30	GASTO	150000	NECESARIO	D├®bito	Nafta + Aceite + Refrigerante	2026-04-13 22:37:30.060656	357	ASIGNADA_MANUAL	14	3
1490	2026-04-13 22:37:30.061975	2026-04-09	GASTO	18200	NECESARIO	D├®bito	Chino	2026-04-13 22:37:30.061975	378	ASIGNADA_MANUAL	13	3
1491	2026-04-13 22:37:30.064839	2026-04-09	GASTO	2400	NECESARIO	D├®bito	Chino	2026-04-13 22:37:30.064839	378	ASIGNADA_MANUAL	13	3
1492	2026-04-13 22:37:30.066913	2026-04-09	GASTO	1084080	NECESARIO	D├®bito	Sueldo C├®sar Marzo	2026-04-13 22:37:30.066913	374	ASIGNADA_MANUAL	22	3
1493	2026-04-13 22:37:30.068243	2026-03-21	GASTO	404000	NECESARIO	D├®bito	Comida Mica	2026-04-13 22:37:30.068243	367	ASIGNADA_MANUAL	13	3
1494	2026-04-13 22:37:30.070499	2026-03-07	GASTO	100000	NECESARIO	Transferencia	Pago ICBC - VISA ICBC (02/2026)	2026-04-13 22:37:30.070499	383	ASIGNADA_MANUAL	36	3
1495	2026-04-13 22:37:30.071995	2026-03-06	GASTO	21500	NECESARIO	D├®bito	Papel Higienico	2026-04-13 22:37:30.071995	360	ASIGNADA_MANUAL	16	3
1496	2026-04-13 22:37:30.073233	2026-03-01	GASTO	723000	NECESARIO	D├®bito	Alquiler Tone	2026-04-13 22:37:30.073233	360	ASIGNADA_MANUAL	16	3
1497	2026-04-13 22:37:30.075587	2026-03-03	GASTO	36000	NECESARIO	D├®bito	Taller Teatro	2026-04-13 22:37:30.075587	346	ASIGNADA_MANUAL	21	3
1498	2026-04-13 22:37:30.076095	2026-03-08	INGRESO	2000000	NECESARIO	D├®bito	Extracci├│n Dinero Tarj	2026-04-13 22:37:30.076095	344	ASIGNADA_MANUAL	15	3
1499	2026-04-13 22:37:30.0774	2026-03-16	GASTO	155960	NECESARIO	D├®bito	Proetica fcia ges	2026-04-13 22:37:30.0774	349	ASIGNADA_MANUAL	22	3
1500	2026-04-13 22:37:30.079455	2026-03-03	GASTO	45000	NECESARIO	D├®bito	Curso Chicha Feb	2026-04-13 22:37:30.079455	346	ASIGNADA_MANUAL	21	3
1501	2026-04-13 22:37:30.080572	31-03-2026	GASTO	7800	NECESARIO	D├®bito	DEB.AUTOM - PAGO SERVICIO DB AUTOMATICO	2026-04-13 22:37:30.080572	\N	ASIGNADA_MANUAL	31	3
1502	2026-04-13 22:37:30.083127	31-03-2026	GASTO	7800	NECESARIO	D├®bito	DEB.AUTOM - PAGO SERVICIO DB AUTOMATICO	2026-04-13 22:37:30.083127	\N	ASIGNADA_MANUAL	31	3
861	2026-04-06 01:15:52.318	2026-04-05	GASTO	1031203.5	NECESARIO	D├®bito	ITBA	2026-04-06 01:15:54.937889	155	ASIGNADA_MANUAL	21	1
794	2026-03-31 01:28:12.112	2026-04-01	INGRESO	2535558	NECESARIO	D├®bito	Sueldo Sergio	2026-03-31 01:28:17.482047	149	ASIGNADA_MANUAL	15	1
869	2026-04-06 01:15:52.318	2026-04-04	GASTO	147000	NECESARIO	D├®bito	Pr├®stamo MP Chicha	2026-04-06 01:15:55.002943	169	ASIGNADA_MANUAL	17	1
864	2026-04-06 01:15:52.318	2026-04-04	GASTO	16900	NECESARIO	D├®bito	Chino	2026-04-06 01:15:54.96581	161	ASIGNADA_MANUAL	13	1
870	2026-04-06 01:15:52.318	2026-04-04	GASTO	30000	NECESARIO	D├®bito	Huevitos de pascua	2026-04-06 01:15:55.019317	161	ASIGNADA_MANUAL	13	1
867	2026-04-06 01:15:52.318	2026-04-04	GASTO	25000	NECESARIO	D├®bito	Lavado Auto	2026-04-06 01:15:54.987655	165	ASIGNADA_MANUAL	14	1
842	2026-04-04 00:43:41.565	2026-03-31	GASTO	490000	NECESARIO	D├®bito	Gastos Sin clasificar de Marzo (CLASIFICAR!!!!)	2026-04-04 00:43:41.577691	\N	ASIGNADA_MANUAL	31	1
866	2026-04-06 01:15:52.318	2026-04-04	GASTO	4300	NECESARIO	D├®bito	Chino	2026-04-06 01:15:54.981023	161	ASIGNADA_MANUAL	13	1
865	2026-04-06 01:15:52.318	2026-04-04	GASTO	12100	NECESARIO	D├®bito	Chino	2026-04-06 01:15:54.973656	161	ASIGNADA_MANUAL	13	1
877	2026-04-06 01:15:52.318	2026-04-01	GASTO	46675	NECESARIO	D├®bito	Multas 2/12	2026-04-06 01:15:55.066867	174	ASIGNADA_MANUAL	20	1
883	2026-04-06 01:15:52.318	2026-04-01	GASTO	130000	NECESARIO	D├®bito	Deuda Carnicer├¡a	2026-04-06 01:15:55.103919	161	ASIGNADA_MANUAL	13	1
956	2026-04-07 19:57:58.823	2026-04-05	GASTO	301034.46	NECESARIO	Transferencia	Pago ICBC - VISA ICBC (03/2026)	2026-04-07 19:57:58.842356	175	ASIGNADA_MANUAL	36	1
178	2026-03-07 23:44:02.651	2026-03-01	GASTO	12981	NECESARIO	D├®bito	Carrefour Express	2026-03-11 23:45:30.699448	91	ASIGNADA_MANUAL	13	1
177	2026-03-07 23:44:02.651	2026-03-01	GASTO	18500	NECESARIO	D├®bito	DIA	2026-03-11 23:45:30.68898	91	ASIGNADA_MANUAL	13	1
182	2026-03-07 23:44:02.651	2026-03-01	GASTO	15000	NECESARIO	D├®bito	Carniceria	2026-03-11 23:45:30.709026	91	ASIGNADA_MANUAL	13	1
221	2026-03-14 22:04:06.48	2026-03-14	GASTO	50000	NECESARIO	D├®bito	Comida Mica	2026-03-14 22:04:06.529962	121	ASIGNADA_MANUAL	13	1
266	2026-03-17 18:02:49.574	2026-03-16	GASTO	8920.64	NECESARIO	D├®bito	Farmacia	2026-03-17 18:02:53.91915	97	ASIGNADA_MANUAL	22	1
204	2026-03-07 23:44:02.651	2026-03-06	GASTO	89000	NECESARIO	D├®bito	Nafta	2026-03-11 23:45:30.760023	93	ASIGNADA_MANUAL	14	1
203	2026-03-07 23:44:02.651	2026-03-06	GASTO	25000	NECESARIO	D├®bito	Remedio Eze 1/6	2026-03-11 23:45:30.758015	97	ASIGNADA_MANUAL	22	1
200	2026-03-07 23:44:02.651	2026-03-06	GASTO	37095	NECESARIO	D├®bito	ARCA C├®sar Feb	2026-03-11 23:45:30.75156	124	ASIGNADA_MANUAL	20	1
294	2026-03-17 20:33:16.124	2026-03-02	GASTO	100440	NECESARIO	D├®bito	Escuela Eze	2026-03-17 20:33:17.991462	120	ASIGNADA_MANUAL	21	1
185	2026-03-07 23:44:02.651	2026-03-03	GASTO	27000	NECESARIO	D├®bito	Patys	2026-03-11 23:45:30.716679	91	ASIGNADA_MANUAL	13	1
279	2026-03-17 18:02:49.574	2026-03-17	GASTO	41809	NECESARIO	D├®bito	Movistar Sergio Marzo	2026-03-17 18:02:53.91915	122	ASIGNADA_MANUAL	24	1
293	2026-03-17 20:33:16.124	2026-03-07	GASTO	30000	NECESARIO	D├®bito	SUBE	2026-03-17 20:33:17.984539	119	ASIGNADA_MANUAL	14	1
327	2026-03-24 21:01:28.429	2026-03-19	GASTO	1363	NECESARIO	D├®bito	SUBE	2026-03-24 21:01:32.329788	93	ASIGNADA_MANUAL	14	1
179	2026-03-07 23:44:02.651	2026-03-01	GASTO	150000	NECESARIO	D├®bito	Gastos Mica	2026-03-11 23:45:30.702264	121	ASIGNADA_MANUAL	13	1
323	2026-03-24 21:01:28.429	2026-03-25	GASTO	24000	NECESARIO	D├®bito	Comida Mica	2026-03-24 21:01:32.228976	121	ASIGNADA_MANUAL	13	1
205	2026-03-08 00:10:43.055	2026-03-02	INGRESO	1820000	NECESARIO	D├®bito	Sueldo Chicha	2026-03-11 23:45:30.762957	133	ASIGNADA_MANUAL	15	1
969	2026-04-08 02:15:05.746	2026-04-07	GASTO	1405372	NECESARIO	Transferencia	Pago Ciudad - VISA (03/2026)	2026-04-08 02:15:06.082796	145	ASIGNADA_MANUAL	36	1
285	2026-03-17 20:33:16.124	2026-03-01	GASTO	147000	NECESARIO	D├®bito	Pr├®stamos MP Chicha	2026-03-17 20:33:17.91838	95	ASIGNADA_MANUAL	17	1
976	2026-04-09 19:03:41.01	2026-04-08	GASTO	8145	NECESARIO	D├®bito	COMPRA DEBITO MERPAGO*SUPERDIA 4517XXXXXXXXXX73 A894	2026-04-09 19:03:45.611285	161	ASIGNADA_MANUAL	13	1
1503	2026-04-13 22:37:30.084126	2026-04-07	GASTO	27800	NECESARIO	D├®bito	Chino	2026-04-13 22:37:30.084126	378	ASIGNADA_MANUAL	13	3
1504	2026-04-13 22:37:30.086214	2026-04-07	GASTO	100000	NECESARIO	D├®bito	Psicologa Chicha	2026-04-13 22:37:30.086214	386	ASIGNADA_MANUAL	22	3
1505	2026-04-13 22:37:30.086214	2026-04-06	GASTO	10000	NECESARIO	D├®bito	SUBE	2026-04-13 22:37:30.086214	385	ASIGNADA_MANUAL	14	3
1507	2026-04-13 22:37:30.0895	2026-03-03	INGRESO	478000	NECESARIO	D├®bito	Alquiler Monte	2026-04-13 22:37:30.0895	341	ASIGNADA_MANUAL	19	3
1508	2026-04-13 22:37:30.090911	2026-03-03	GASTO	55448	NECESARIO	D├®bito	Movistar 1 Feb	2026-04-13 22:37:30.090911	351	ASIGNADA_MANUAL	24	3
1509	2026-04-13 22:37:30.093267	2026-03-03	GASTO	46880	NECESARIO	D├®bito	Movistar 2 Feb	2026-04-13 22:37:30.093267	351	ASIGNADA_MANUAL	24	3
1510	2026-04-13 22:37:30.094818	2026-03-25	GASTO	49325.56	NECESARIO	D├®bito	Movistar Chicha Marzo	2026-04-13 22:37:30.094818	351	ASIGNADA_MANUAL	24	3
1511	2026-04-13 22:37:30.094818	2026-03-02	GASTO	90000	NECESARIO	D├®bito	Adriana Psico	2026-04-13 22:37:30.094818	343	ASIGNADA_MANUAL	22	3
1512	2026-04-13 22:37:30.096655	2026-03-03	GASTO	14756	NECESARIO	D├®bito	Metrogas Tone	2026-04-13 22:37:30.096655	351	ASIGNADA_MANUAL	24	3
1513	2026-04-13 22:37:30.098217	2026-03-02	GASTO	9000	NECESARIO	D├®bito	Ferreteria	2026-04-13 22:37:30.098217	360	ASIGNADA_MANUAL	16	3
1514	2026-04-13 22:37:30.100226	2026-03-03	GASTO	570000	NECESARIO	D├®bito	Garantia Fede	2026-04-13 22:37:30.100226	342	ASIGNADA_MANUAL	18	3
1515	2026-04-13 22:37:30.10143	2026-03-01	GASTO	1031203.5	NECESARIO	D├®bito	ITBA Febrero	2026-04-13 22:37:30.10143	346	ASIGNADA_MANUAL	21	3
1516	2026-04-13 22:37:30.102428	2026-03-02	GASTO	66734	NECESARIO	D├®bito	Cr├®dito ANSES	2026-04-13 22:37:30.102428	359	ASIGNADA_MANUAL	17	3
1517	2026-04-13 22:37:30.103834	2026-03-02	GASTO	100000	NECESARIO	D├®bito	Protesis 2/2	2026-04-13 22:37:30.103834	349	ASIGNADA_MANUAL	22	3
1518	2026-04-13 22:37:30.106188	2026-03-01	GASTO	1084080	NECESARIO	D├®bito	Sueldo C├®sar	2026-04-13 22:37:30.106188	343	ASIGNADA_MANUAL	22	3
1519	2026-04-13 22:37:30.107189	2026-03-01	GASTO	2507	NECESARIO	D├®bito	SUBE	2026-04-13 22:37:30.107189	348	ASIGNADA_MANUAL	14	3
1520	2026-04-13 22:37:30.107189	2026-03-10	INGRESO	396000	NECESARIO	D├®bito	Fac Vivian	2026-04-13 22:37:30.107189	354	ASIGNADA_MANUAL	15	3
1521	2026-04-13 22:37:30.108766	2026-03-03	GASTO	104550	NECESARIO	D├®bito	Edesur	2026-04-13 22:37:30.108766	351	ASIGNADA_MANUAL	24	3
1522	2026-04-13 22:37:30.11035	2026-03-01	INGRESO	2561000	NECESARIO	D├®bito	Sueldo Sergio	2026-04-13 22:37:30.11035	340	ASIGNADA_MANUAL	15	3
1523	2026-04-13 22:37:30.111368	2026-03-14	INGRESO	1970000	NECESARIO	D├®bito	Adelanto Sueldo Sergio	2026-04-13 22:37:30.111368	347	ASIGNADA_MANUAL	15	3
1524	2026-04-13 22:37:30.112377	2026-03-16	GASTO	20000	NECESARIO	D├®bito	Comida Chicha	2026-04-13 22:37:30.112377	367	ASIGNADA_MANUAL	13	3
1525	2026-04-13 22:37:30.113376	2026-03-14	GASTO	15750	NECESARIO	D├®bito	DIA	2026-04-13 22:37:30.113376	367	ASIGNADA_MANUAL	13	3
1526	2026-04-13 22:37:30.114376	2026-03-11	GASTO	7100	NECESARIO	D├®bito	Chino	2026-04-13 22:37:30.114376	367	ASIGNADA_MANUAL	13	3
1527	2026-04-13 22:37:30.115375	2026-03-16	GASTO	34844	NECESARIO	D├®bito	Pr├®stamos MP	2026-04-13 22:37:30.115375	359	ASIGNADA_MANUAL	17	3
1528	2026-04-13 22:37:30.116378	2026-03-15	GASTO	3701	NECESARIO	D├®bito	Comida Chicha	2026-04-13 22:37:30.116378	367	ASIGNADA_MANUAL	13	3
1529	2026-04-13 22:37:30.117375	2026-03-14	GASTO	50000	NECESARIO	D├®bito	Comida Mica	2026-04-13 22:37:30.117375	372	ASIGNADA_MANUAL	13	3
1530	2026-04-13 22:37:30.117375	2026-03-14	GASTO	10812	NECESARIO	D├®bito	DIA Merienda	2026-04-13 22:37:30.117375	367	ASIGNADA_MANUAL	13	3
1531	2026-04-13 22:37:30.119131	2026-03-14	GASTO	1363	NECESARIO	D├®bito	SUBE	2026-04-13 22:37:30.119131	348	ASIGNADA_MANUAL	14	3
1532	2026-04-13 22:37:30.120137	2026-03-11	GASTO	9400	NECESARIO	D├®bito	Panchos	2026-04-13 22:37:30.120137	367	ASIGNADA_MANUAL	13	3
1533	2026-04-13 22:37:30.121145	2026-03-05	GASTO	10000	NECESARIO	D├®bito	Almuerzo Sergio	2026-04-13 22:37:30.121145	367	ASIGNADA_MANUAL	13	3
1534	2026-04-13 22:37:30.122144	2026-03-09	GASTO	30000	NECESARIO	D├®bito	SUBE	2026-04-13 22:37:30.122144	348	ASIGNADA_MANUAL	14	3
1535	2026-04-13 22:37:30.123145	2026-03-16	GASTO	37300	NECESARIO	D├®bito	Chino	2026-04-13 22:37:30.123145	367	ASIGNADA_MANUAL	13	3
1536	2026-04-13 22:37:30.124144	2026-03-15	GASTO	87000	NECESARIO	D├®bito	Rotiseria	2026-04-13 22:37:30.124144	367	ASIGNADA_MANUAL	13	3
1537	2026-04-13 22:37:30.124144	2026-03-14	GASTO	6800	NECESARIO	D├®bito	Panaderia	2026-04-13 22:37:30.124144	367	ASIGNADA_MANUAL	13	3
926	2026-04-06 01:16:39.918	2026-04-06	GASTO	11400	NECESARIO	D├®bito	Carnicer├¡a	2026-04-06 01:17:41.833717	161	ASIGNADA_MANUAL	13	1
927	2026-04-06 01:16:39.918	2026-04-06	GASTO	5178.26	NECESARIO	D├®bito	Pr├®stamo MP Sergio	2026-04-06 01:17:41.841973	169	ASIGNADA_MANUAL	17	1
898	2026-04-06 01:15:52.318	2026-04-06	GASTO	18900	NECESARIO	D├®bito	Librer├¡a Experimento Mica	2026-04-06 01:17:41.288958	155	ASIGNADA_MANUAL	21	1
886	2026-04-06 01:15:52.318	2026-04-05	GASTO	683399.81	NECESARIO	D├®bito	Alquiler Tone	2026-04-06 01:17:41.173734	173	ASIGNADA_MANUAL	19	1
890	2026-04-06 01:15:52.318	2026-04-05	GASTO	32390.03	NECESARIO	D├®bito	Movistar Mica Feb y Marzo	2026-04-06 01:17:41.21002	160	ASIGNADA_MANUAL	24	1
887	2026-04-06 01:15:52.318	2026-04-05	GASTO	33000	NECESARIO	D├®bito	Honorarios Alquiler Tone	2026-04-06 01:17:41.189453	173	ASIGNADA_MANUAL	19	1
939	2026-04-06 01:16:39.918	2026-04-05	GASTO	20000	NECESARIO	D├®bito	Comida y Art limpieza DIA	2026-04-06 01:17:41.935356	161	ASIGNADA_MANUAL	13	1
922	2026-04-06 01:16:39.918	2026-04-04	GASTO	1000	NECESARIO	D├®bito	Sancor Seguros	2026-04-06 01:17:41.807675	159	ASIGNADA_MANUAL	28	1
911	2026-04-06 01:15:52.318	2026-04-01	GASTO	32000	NECESARIO	D├®bito	Rotiser├¡a	2026-04-06 01:17:41.381859	161	ASIGNADA_MANUAL	13	1
928	2026-04-06 01:16:39.918	2026-04-01	GASTO	4980	NECESARIO	D├®bito	DIA	2026-04-06 01:17:41.84894	161	ASIGNADA_MANUAL	13	1
907	2026-04-06 01:15:52.318	2026-04-01	GASTO	20800	NECESARIO	D├®bito	Chino	2026-04-06 01:17:41.354585	161	ASIGNADA_MANUAL	13	1
908	2026-04-06 01:15:52.318	2026-04-01	GASTO	39000	NECESARIO	D├®bito	Verduler├¡a	2026-04-06 01:17:41.361153	161	ASIGNADA_MANUAL	13	1
909	2026-04-06 01:15:52.318	2026-04-01	GASTO	10000	NECESARIO	D├®bito	Panader├¡a	2026-04-06 01:17:41.367969	161	ASIGNADA_MANUAL	13	1
930	2026-04-06 01:16:39.918	2026-04-01	GASTO	40321.45	NECESARIO	D├®bito	CUOTA DE PRESTAMO CUOTA 5/6	2026-04-06 01:17:41.874862	169	ASIGNADA_MANUAL	17	1
933	2026-04-06 01:16:39.918	2026-04-01	GASTO	5700	NECESARIO	D├®bito	Verduler├¡a	2026-04-06 01:17:41.894102	161	ASIGNADA_MANUAL	13	1
902	2026-04-06 01:15:52.318	2026-04-01	GASTO	50000	NECESARIO	D├®bito	Comida Mica	2026-04-06 01:17:41.316457	161	ASIGNADA_MANUAL	13	1
932	2026-04-06 01:16:39.918	2026-04-01	GASTO	13425	NECESARIO	D├®bito	DIA	2026-04-06 01:17:41.887183	161	ASIGNADA_MANUAL	13	1
953	2026-04-07 00:21:29.21	2026-04-06	INGRESO	285000	NECESARIO	D├®bito	Garantia Fed Devol 1/2	2026-04-07 00:21:29.221489	172	ASIGNADA_MANUAL	15	1
957	2026-04-08 01:00:38.008	06-04-2026	GASTO	59000	NECESARIO	D├®bito	DEBIN     - 30703088534-3220001805000054570077-VAR	2026-04-08 01:00:40.035851	\N	ASIGNADA_MANUAL	31	1
958	2026-04-08 01:00:38.008	06-04-2026	GASTO	35000	NECESARIO	D├®bito	DEBIN     - 30703088534-3220001805000054570077-VAR	2026-04-08 01:00:40.065516	\N	ASIGNADA_MANUAL	31	1
959	2026-04-08 01:00:38.008	06-04-2026	GASTO	24000	NECESARIO	D├®bito	DEBIN     - 30703088534-3220001805000054570077-VAR	2026-04-08 01:00:40.073116	\N	ASIGNADA_MANUAL	31	1
960	2026-04-08 01:00:38.008	06-04-2026	GASTO	20600	NECESARIO	D├®bito	DEBIN     - 30703088534-3220001805000054570077-VAR	2026-04-08 01:00:40.080156	\N	ASIGNADA_MANUAL	31	1
961	2026-04-08 01:00:38.008	06-04-2026	GASTO	20000	NECESARIO	D├®bito	DEBIN     - 30703088534-3220001805000054570077-VAR	2026-04-08 01:00:40.087574	\N	ASIGNADA_MANUAL	31	1
962	2026-04-08 01:00:38.009	06-04-2026	GASTO	6900	NECESARIO	D├®bito	DEBIN     - 30703088534-3220001805000054570077-VAR	2026-04-08 01:00:40.095105	\N	ASIGNADA_MANUAL	31	1
965	2026-04-08 01:00:38.009	2026-04-07	GASTO	10000	NECESARIO	D├®bito	Panderia	2026-04-08 01:00:40.120401	161	ASIGNADA_MANUAL	13	1
1538	2026-04-13 22:37:30.126195	2026-03-14	GASTO	14000	NECESARIO	D├®bito	Comida Gato	2026-04-13 22:37:30.126195	367	ASIGNADA_MANUAL	13	3
1539	2026-04-13 22:37:30.127716	2026-03-06	GASTO	3700	NECESARIO	D├®bito	Comida Chicha	2026-04-13 22:37:30.127716	367	ASIGNADA_MANUAL	13	3
1540	2026-04-13 22:37:30.127716	2026-03-06	GASTO	50000	NECESARIO	D├®bito	Comida Mica	2026-04-13 22:37:30.127716	367	ASIGNADA_MANUAL	13	3
1541	2026-04-13 22:37:30.129098	2026-03-03	GASTO	2000	NECESARIO	D├®bito	Coquita	2026-04-13 22:37:30.129098	367	ASIGNADA_MANUAL	13	3
1542	2026-04-13 22:37:30.130098	2026-03-03	GASTO	5900	NECESARIO	D├®bito	DIA	2026-04-13 22:37:30.130098	367	ASIGNADA_MANUAL	13	3
1543	2026-04-13 22:37:30.131132	2026-03-03	GASTO	22930	NECESARIO	D├®bito	Comida DIA	2026-04-13 22:37:30.131132	367	ASIGNADA_MANUAL	13	3
1544	2026-04-13 22:37:30.132133	2026-03-03	GASTO	22000	NECESARIO	D├®bito	Rotiseria	2026-04-13 22:37:30.132133	367	ASIGNADA_MANUAL	13	3
1545	2026-04-13 22:37:30.133132	2026-03-03	GASTO	64000	NECESARIO	D├®bito	Chino	2026-04-13 22:37:30.133132	367	ASIGNADA_MANUAL	13	3
1546	2026-04-13 22:37:30.134133	2026-04-05	GASTO	1031203.5	NECESARIO	D├®bito	ITBA	2026-04-13 22:37:30.134133	375	ASIGNADA_MANUAL	21	3
1547	2026-04-13 22:37:30.13513	2026-04-01	INGRESO	2535558	NECESARIO	D├®bito	Sueldo Sergio	2026-04-13 22:37:30.13513	352	ASIGNADA_MANUAL	15	3
1548	2026-04-13 22:37:30.136141	2026-04-04	GASTO	147000	NECESARIO	D├®bito	Pr├®stamo MP Chicha	2026-04-13 22:37:30.136141	381	ASIGNADA_MANUAL	17	3
1549	2026-04-13 22:37:30.136141	2026-04-04	GASTO	16900	NECESARIO	D├®bito	Chino	2026-04-13 22:37:30.136141	378	ASIGNADA_MANUAL	13	3
1550	2026-04-13 22:37:30.138592	2026-04-04	GASTO	30000	NECESARIO	D├®bito	Huevitos de pascua	2026-04-13 22:37:30.138592	378	ASIGNADA_MANUAL	13	3
1551	2026-04-13 22:37:30.139866	2026-04-04	GASTO	25000	NECESARIO	D├®bito	Lavado Auto	2026-04-13 22:37:30.139866	385	ASIGNADA_MANUAL	14	3
1552	2026-04-13 22:37:30.14092	2026-03-31	GASTO	490000	NECESARIO	D├®bito	Gastos Sin clasificar de Marzo (CLASIFICAR!!!!)	2026-04-13 22:37:30.14092	\N	ASIGNADA_MANUAL	31	3
1553	2026-04-13 22:37:30.141488	2026-04-04	GASTO	4300	NECESARIO	D├®bito	Chino	2026-04-13 22:37:30.141488	378	ASIGNADA_MANUAL	13	3
1554	2026-04-13 22:37:30.143676	2026-04-04	GASTO	12100	NECESARIO	D├®bito	Chino	2026-04-13 22:37:30.143676	378	ASIGNADA_MANUAL	13	3
1555	2026-04-13 22:37:30.143676	2026-04-01	GASTO	46675	NECESARIO	D├®bito	Multas 2/12	2026-04-13 22:37:30.143676	380	ASIGNADA_MANUAL	20	3
1556	2026-04-13 22:37:30.144967	2026-04-01	GASTO	130000	NECESARIO	D├®bito	Deuda Carnicer├¡a	2026-04-13 22:37:30.144967	378	ASIGNADA_MANUAL	13	3
1557	2026-04-13 22:37:30.14603	2026-04-05	GASTO	301034.46	NECESARIO	Transferencia	Pago ICBC - VISA ICBC (03/2026)	2026-04-13 22:37:30.14603	384	ASIGNADA_MANUAL	36	3
1558	2026-04-13 22:37:30.147262	2026-03-01	GASTO	12981	NECESARIO	D├®bito	Carrefour Express	2026-04-13 22:37:30.147262	367	ASIGNADA_MANUAL	13	3
1559	2026-04-13 22:37:30.148273	2026-03-01	GASTO	18500	NECESARIO	D├®bito	DIA	2026-04-13 22:37:30.148273	367	ASIGNADA_MANUAL	13	3
1560	2026-04-13 22:37:30.148273	2026-03-01	GASTO	15000	NECESARIO	D├®bito	Carniceria	2026-04-13 22:37:30.148273	367	ASIGNADA_MANUAL	13	3
1561	2026-04-13 22:37:30.149696	2026-03-14	GASTO	50000	NECESARIO	D├®bito	Comida Mica	2026-04-13 22:37:30.149696	372	ASIGNADA_MANUAL	13	3
1562	2026-04-13 22:37:30.150883	2026-03-16	GASTO	8920.64	NECESARIO	D├®bito	Farmacia	2026-04-13 22:37:30.150883	349	ASIGNADA_MANUAL	22	3
1563	2026-04-13 22:37:30.150883	2026-03-06	GASTO	89000	NECESARIO	D├®bito	Nafta	2026-04-13 22:37:30.150883	357	ASIGNADA_MANUAL	14	3
1564	2026-04-13 22:37:30.15225	2026-03-06	GASTO	25000	NECESARIO	D├®bito	Remedio Eze 1/6	2026-04-13 22:37:30.15225	349	ASIGNADA_MANUAL	22	3
1565	2026-04-13 22:37:30.153347	2026-03-06	GASTO	37095	NECESARIO	D├®bito	ARCA C├®sar Feb	2026-04-13 22:37:30.153347	370	ASIGNADA_MANUAL	20	3
1566	2026-04-13 22:37:30.154462	2026-03-02	GASTO	100440	NECESARIO	D├®bito	Escuela Eze	2026-04-13 22:37:30.154462	346	ASIGNADA_MANUAL	21	3
1567	2026-04-13 22:37:30.155474	2026-03-03	GASTO	27000	NECESARIO	D├®bito	Patys	2026-04-13 22:37:30.155474	367	ASIGNADA_MANUAL	13	3
1568	2026-04-13 22:37:30.156473	2026-03-17	GASTO	41809	NECESARIO	D├®bito	Movistar Sergio Marzo	2026-04-13 22:37:30.156473	351	ASIGNADA_MANUAL	24	3
1569	2026-04-13 22:37:30.157072	2026-03-07	GASTO	30000	NECESARIO	D├®bito	SUBE	2026-04-13 22:37:30.157072	348	ASIGNADA_MANUAL	14	3
1570	2026-04-13 22:37:30.158767	2026-03-19	GASTO	1363	NECESARIO	D├®bito	SUBE	2026-04-13 22:37:30.158767	357	ASIGNADA_MANUAL	14	3
1571	2026-04-13 22:37:30.158767	2026-03-01	GASTO	150000	NECESARIO	D├®bito	Gastos Mica	2026-04-13 22:37:30.158767	372	ASIGNADA_MANUAL	13	3
1572	2026-04-13 22:37:30.160256	2026-03-25	GASTO	24000	NECESARIO	D├®bito	Comida Mica	2026-04-13 22:37:30.160256	372	ASIGNADA_MANUAL	13	3
1573	2026-04-13 22:37:30.16145	2026-03-02	INGRESO	1820000	NECESARIO	D├®bito	Sueldo Chicha	2026-04-13 22:37:30.16145	366	ASIGNADA_MANUAL	15	3
1574	2026-04-13 22:37:30.162529	2026-04-07	GASTO	1405372	NECESARIO	Transferencia	Pago Ciudad - VISA (03/2026)	2026-04-13 22:37:30.162529	371	ASIGNADA_MANUAL	36	3
1575	2026-04-13 22:37:30.162529	2026-03-01	GASTO	147000	NECESARIO	D├®bito	Pr├®stamos MP Chicha	2026-04-13 22:37:30.162529	359	ASIGNADA_MANUAL	17	3
1576	2026-04-13 22:37:30.163874	2026-04-08	GASTO	8145	NECESARIO	D├®bito	COMPRA DEBITO MERPAGO*SUPERDIA 4517XXXXXXXXXX73 A894	2026-04-13 22:37:30.163874	378	ASIGNADA_MANUAL	13	3
1577	2026-04-13 22:37:30.165121	2026-04-06	GASTO	11400	NECESARIO	D├®bito	Carnicer├¡a	2026-04-13 22:37:30.165121	378	ASIGNADA_MANUAL	13	3
1578	2026-04-13 22:37:30.165121	2026-04-06	GASTO	5178.26	NECESARIO	D├®bito	Pr├®stamo MP Sergio	2026-04-13 22:37:30.165121	381	ASIGNADA_MANUAL	17	3
1579	2026-04-13 22:37:30.166514	2026-04-06	GASTO	18900	NECESARIO	D├®bito	Librer├¡a Experimento Mica	2026-04-13 22:37:30.166514	375	ASIGNADA_MANUAL	21	3
1580	2026-04-13 22:37:30.167809	2026-04-05	GASTO	683399.81	NECESARIO	D├®bito	Alquiler Tone	2026-04-13 22:37:30.167809	379	ASIGNADA_MANUAL	19	3
1581	2026-04-13 22:37:30.167809	2026-04-05	GASTO	32390.03	NECESARIO	D├®bito	Movistar Mica Feb y Marzo	2026-04-13 22:37:30.167809	377	ASIGNADA_MANUAL	24	3
1582	2026-04-13 22:37:30.169317	2026-04-05	GASTO	33000	NECESARIO	D├®bito	Honorarios Alquiler Tone	2026-04-13 22:37:30.169317	379	ASIGNADA_MANUAL	19	3
1583	2026-04-13 22:37:30.169317	2026-04-05	GASTO	20000	NECESARIO	D├®bito	Comida y Art limpieza DIA	2026-04-13 22:37:30.169317	378	ASIGNADA_MANUAL	13	3
1584	2026-04-13 22:37:30.170864	2026-04-04	GASTO	1000	NECESARIO	D├®bito	Sancor Seguros	2026-04-13 22:37:30.170864	382	ASIGNADA_MANUAL	28	3
1585	2026-04-13 22:37:30.172068	2026-04-01	GASTO	32000	NECESARIO	D├®bito	Rotiser├¡a	2026-04-13 22:37:30.172068	378	ASIGNADA_MANUAL	13	3
1586	2026-04-13 22:37:30.172606	2026-04-01	GASTO	4980	NECESARIO	D├®bito	DIA	2026-04-13 22:37:30.172606	378	ASIGNADA_MANUAL	13	3
1587	2026-04-13 22:37:30.173883	2026-04-01	GASTO	20800	NECESARIO	D├®bito	Chino	2026-04-13 22:37:30.173883	378	ASIGNADA_MANUAL	13	3
1588	2026-04-13 22:37:30.174973	2026-04-01	GASTO	39000	NECESARIO	D├®bito	Verduler├¡a	2026-04-13 22:37:30.174973	378	ASIGNADA_MANUAL	13	3
1589	2026-04-13 22:37:30.176149	2026-04-01	GASTO	10000	NECESARIO	D├®bito	Panader├¡a	2026-04-13 22:37:30.176149	378	ASIGNADA_MANUAL	13	3
1590	2026-04-13 22:37:30.177146	2026-04-01	GASTO	40321.45	NECESARIO	D├®bito	CUOTA DE PRESTAMO CUOTA 5/6	2026-04-13 22:37:30.177146	381	ASIGNADA_MANUAL	17	3
1591	2026-04-13 22:37:30.178177	2026-04-01	GASTO	5700	NECESARIO	D├®bito	Verduler├¡a	2026-04-13 22:37:30.178177	378	ASIGNADA_MANUAL	13	3
1592	2026-04-13 22:37:30.178177	2026-04-01	GASTO	50000	NECESARIO	D├®bito	Comida Mica	2026-04-13 22:37:30.178177	378	ASIGNADA_MANUAL	13	3
1593	2026-04-13 22:37:30.17969	2026-04-01	GASTO	13425	NECESARIO	D├®bito	DIA	2026-04-13 22:37:30.17969	378	ASIGNADA_MANUAL	13	3
1594	2026-04-13 22:37:30.180734	2026-04-06	INGRESO	285000	NECESARIO	D├®bito	Garantia Fed Devol 1/2	2026-04-13 22:37:30.180734	376	ASIGNADA_MANUAL	15	3
1595	2026-04-13 22:37:30.181741	06-04-2026	GASTO	59000	NECESARIO	D├®bito	DEBIN     - 30703088534-3220001805000054570077-VAR	2026-04-13 22:37:30.181741	\N	ASIGNADA_MANUAL	31	3
1596	2026-04-13 22:37:30.18375	06-04-2026	GASTO	35000	NECESARIO	D├®bito	DEBIN     - 30703088534-3220001805000054570077-VAR	2026-04-13 22:37:30.18375	\N	ASIGNADA_MANUAL	31	3
1597	2026-04-13 22:37:30.18375	06-04-2026	GASTO	24000	NECESARIO	D├®bito	DEBIN     - 30703088534-3220001805000054570077-VAR	2026-04-13 22:37:30.18375	\N	ASIGNADA_MANUAL	31	3
1598	2026-04-13 22:37:30.185173	06-04-2026	GASTO	20600	NECESARIO	D├®bito	DEBIN     - 30703088534-3220001805000054570077-VAR	2026-04-13 22:37:30.185173	\N	ASIGNADA_MANUAL	31	3
1599	2026-04-13 22:37:30.186428	06-04-2026	GASTO	20000	NECESARIO	D├®bito	DEBIN     - 30703088534-3220001805000054570077-VAR	2026-04-13 22:37:30.186428	\N	ASIGNADA_MANUAL	31	3
1600	2026-04-13 22:37:30.188033	06-04-2026	GASTO	6900	NECESARIO	D├®bito	DEBIN     - 30703088534-3220001805000054570077-VAR	2026-04-13 22:37:30.188033	\N	ASIGNADA_MANUAL	31	3
1602	2026-04-13 22:37:30.188544	2026-03-06	GASTO	22507	NECESARIO	D├®bito	SUBE	2026-04-13 22:37:30.188544	348	ASIGNADA_MANUAL	14	3
1603	2026-04-13 22:37:30.19006	2026-03-02	GASTO	45000	NECESARIO	D├®bito	Curso Chicha Marzo	2026-04-13 22:37:30.19006	346	ASIGNADA_MANUAL	21	3
1604	2026-04-13 22:37:30.191154	2026-03-25	GASTO	5100	NECESARIO	D├®bito	COMPRA DEBITO\n ANTOJA2\n 4517XXXXXXXXXX73\n A003	2026-04-13 22:37:30.191154	367	ASIGNADA_MANUAL	13	3
1605	2026-04-13 22:37:30.192157	2026-03-26	GASTO	73239.98	NECESARIO	D├®bito	ARCA C├®sar Nov y Dic	2026-04-13 22:37:30.192157	370	ASIGNADA_MANUAL	20	3
1606	2026-04-13 22:37:30.193372	2026-03-02	GASTO	17015.84	NECESARIO	D├®bito	Movistar Mica	2026-04-13 22:37:30.193372	351	ASIGNADA_MANUAL	24	3
1607	2026-04-13 22:37:30.193372	2026-03-06	GASTO	13000	NECESARIO	D├®bito	Honorarios Ana	2026-04-13 22:37:30.193372	360	ASIGNADA_MANUAL	19	3
1608	2026-04-13 22:37:30.194841	2026-03-22	GASTO	8400	NECESARIO	D├®bito	Desayuno Central	2026-04-13 22:37:30.194841	367	ASIGNADA_MANUAL	13	3
1609	2026-04-13 22:37:30.196106	2026-03-25	GASTO	76492	NECESARIO	D├®bito	COMPRA DEBITO\n SAMSONITE\n 4517XXXXXXXXXX73\n A327	2026-04-13 22:37:30.196106	353	ASIGNADA_MANUAL	23	3
1610	2026-04-13 22:37:30.197106	2026-03-25	GASTO	4000	SUPERFLUO	D├®bito	COMPRA DEBITO\n ANTOJA2\n 4517XXXXXXXXXX73\n A003	2026-04-13 22:37:30.197106	367	ASIGNADA_MANUAL	13	3
1611	2026-04-13 22:37:30.197106	2026-03-25	GASTO	64000	NECESARIO	D├®bito	CDB Eze	2026-04-13 22:37:30.197106	349	ASIGNADA_MANUAL	22	3
1612	2026-04-13 22:37:30.198381	2026-03-25	GASTO	12097.35	NECESARIO	D├®bito	PERCEPCION RG 5617/24	2026-04-13 22:37:30.198381	370	ASIGNADA_MANUAL	20	3
1613	2026-04-13 22:37:30.19941	2026-03-06	GASTO	683399.81	NECESARIO	D├®bito	Alquiler Tone	2026-04-13 22:37:30.19941	360	ASIGNADA_MANUAL	19	3
1614	2026-04-13 22:37:30.20041	2026-03-02	GASTO	40661.27	NECESARIO	D├®bito	CUOTA DE PRESTAMO\n 808118798055\n CUOTA         4	2026-04-13 22:37:30.20041	359	ASIGNADA_MANUAL	17	3
1615	2026-04-13 22:37:30.20041	2026-03-02	GASTO	685947.56	NECESARIO	D├®bito	CUOTA DE PRESTAMO\n 808124429651\n CUOTA         1	2026-04-13 22:37:30.20041	359	ASIGNADA_MANUAL	17	3
1616	2026-04-13 22:37:30.201965	2026-03-25	INGRESO	22.97	NECESARIO	D├®bito	INTERES CAPITALIZADO\n Marzo 2026	2026-04-13 22:37:30.201965	370	ASIGNADA_MANUAL	15	3
1617	2026-04-13 22:37:30.203207	2026-03-27	INGRESO	33820.35	NECESARIO	D├®bito	DEV.COMPRA GALICIA 24-ELECTRON	2026-04-13 22:37:30.203207	370	ASIGNADA_MANUAL	15	3
1618	2026-04-13 22:37:30.203774	2026-03-19	GASTO	116000	NECESARIO	D├®bito	Curso CUI 1/4	2026-04-13 22:37:30.203774	346	ASIGNADA_MANUAL	21	3
1619	2026-04-13 22:37:30.204788	2026-03-26	GASTO	37095	NECESARIO	D├®bito	ARCA C├®sar Marzo	2026-04-13 22:37:30.204788	370	ASIGNADA_MANUAL	20	3
1620	2026-04-13 22:37:30.205847	2026-03-09	GASTO	160000	NECESARIO	D├®bito	Deuda MP Chicha Feb	2026-04-13 22:37:30.205847	359	ASIGNADA_MANUAL	17	3
1621	2026-04-13 22:37:30.206878	2026-04-08	GASTO	24336.22	NECESARIO	D├®bito	DEB. AUTOM. DE SERV. ZURICH ARG CS SA CUOTAS P 082364811000401 00000000000178014	2026-04-13 22:37:30.206878	382	ASIGNADA_MANUAL	28	3
1626	2026-04-13 22:38:36.176	2026-04-10	GASTO	31152.02	NECESARIO	D├®bito	Personal Internet	2026-04-13 22:38:38.275845	377	ASIGNADA_MANUAL	24	3
290	2026-03-17 20:33:16.124	2026-03-06	GASTO	22507	NECESARIO	D├®bito	SUBE	2026-03-17 20:33:17.962589	119	ASIGNADA_MANUAL	14	1
287	2026-03-17 20:33:16.124	2026-03-02	GASTO	45000	NECESARIO	D├®bito	Curso Chicha Marzo	2026-03-17 20:33:17.937725	120	ASIGNADA_MANUAL	21	1
321	2026-03-24 21:01:28.429	2026-03-25	GASTO	5100	NECESARIO	D├®bito	COMPRA DEBITO\n ANTOJA2\n 4517XXXXXXXXXX73\n A003	2026-03-24 21:01:32.17832	91	ASIGNADA_MANUAL	13	1
401	2026-03-26 17:12:29.619	2026-03-26	GASTO	73239.98	NECESARIO	D├®bito	ARCA C├®sar Nov y Dic	2026-03-26 17:12:29.661219	124	ASIGNADA_MANUAL	20	1
329	2026-03-24 21:46:59.053	2026-03-02	GASTO	17015.84	NECESARIO	D├®bito	Movistar Mica	2026-03-24 21:47:05.855649	122	ASIGNADA_MANUAL	24	1
328	2026-03-24 21:46:59.053	2026-03-06	GASTO	13000	NECESARIO	D├®bito	Honorarios Ana	2026-03-24 21:47:05.780965	125	ASIGNADA_MANUAL	19	1
318	2026-03-22 16:57:20.536	2026-03-22	GASTO	8400	NECESARIO	D├®bito	Desayuno Central	2026-03-22 16:57:20.5591	91	ASIGNADA_MANUAL	13	1
324	2026-03-24 21:01:28.429	2026-03-25	GASTO	76492	NECESARIO	D├®bito	COMPRA DEBITO\n SAMSONITE\n 4517XXXXXXXXXX73\n A327	2026-03-24 21:01:32.258831	114	ASIGNADA_MANUAL	23	1
320	2026-03-24 21:01:28.429	2026-03-25	GASTO	4000	SUPERFLUO	D├®bito	COMPRA DEBITO\n ANTOJA2\n 4517XXXXXXXXXX73\n A003	2026-03-24 21:01:32.160173	91	ASIGNADA_MANUAL	13	1
338	2026-03-24 22:25:03.008	2026-03-25	GASTO	64000	NECESARIO	D├®bito	CDB Eze	2026-03-24 22:25:10.756885	97	ASIGNADA_MANUAL	22	1
337	2026-03-24 22:25:03.008	2026-03-25	GASTO	12097.35	NECESARIO	D├®bito	PERCEPCION RG 5617/24	2026-03-24 22:25:10.724079	124	ASIGNADA_MANUAL	20	1
341	2026-03-24 22:25:03.008	2026-03-06	GASTO	683399.81	NECESARIO	D├®bito	Alquiler Tone	2026-03-24 22:25:10.922287	125	ASIGNADA_MANUAL	19	1
343	2026-03-24 22:25:03.008	2026-03-02	GASTO	40661.27	NECESARIO	D├®bito	CUOTA DE PRESTAMO\n 808118798055\n CUOTA         4	2026-03-24 22:25:10.998938	95	ASIGNADA_MANUAL	17	1
342	2026-03-24 22:25:03.008	2026-03-02	GASTO	685947.56	NECESARIO	D├®bito	CUOTA DE PRESTAMO\n 808124429651\n CUOTA         1	2026-03-24 22:25:10.9905	95	ASIGNADA_MANUAL	17	1
798	2026-03-31 01:28:12.112	2026-03-25	INGRESO	22.97	NECESARIO	D├®bito	INTERES CAPITALIZADO\n Marzo 2026	2026-03-31 01:28:17.662299	124	ASIGNADA_MANUAL	15	1
797	2026-03-31 01:28:12.112	2026-03-27	INGRESO	33820.35	NECESARIO	D├®bito	DEV.COMPRA GALICIA 24-ELECTRON	2026-03-31 01:28:17.617369	124	ASIGNADA_MANUAL	15	1
317	2026-03-19 19:26:52.584	2026-03-19	GASTO	116000	NECESARIO	D├®bito	Curso CUI 1/4	2026-03-19 19:26:52.891218	120	ASIGNADA_MANUAL	21	1
402	2026-03-30 19:36:06.313	2026-03-26	GASTO	37095	NECESARIO	D├®bito	ARCA C├®sar Marzo	2026-03-30 19:36:45.188191	124	ASIGNADA_MANUAL	20	1
339	2026-03-24 22:25:03.008	2026-03-09	GASTO	160000	NECESARIO	D├®bito	Deuda MP Chicha Feb	2026-03-24 22:25:10.906258	95	ASIGNADA_MANUAL	17	1
978	2026-04-09 19:03:41.01	2026-04-08	GASTO	24336.22	NECESARIO	D├®bito	DEB. AUTOM. DE SERV. ZURICH ARG CS SA CUOTAS P 082364811000401 00000000000178014	2026-04-09 19:03:45.627962	159	ASIGNADA_MANUAL	28	1
1627	2026-04-13 22:38:36.176	2026-04-09	GASTO	50000	NECESARIO	D├®bito	Comida Chicha	2026-04-13 22:38:38.28636	378	ASIGNADA_MANUAL	13	3
1601	2026-04-13 22:37:30.188544	2026-04-07	GASTO	10000	NECESARIO	D├®bito	Panaderia	2026-04-13 22:37:30.188544	378	ASIGNADA_MANUAL	13	3
1625	2026-04-13 22:38:36.176	2026-04-10	GASTO	98200	NECESARIO	D├®bito	Colegio Eze	2026-04-13 22:38:38.265623	375	ASIGNADA_MANUAL	21	3
1622	2026-04-13 22:38:36.176	2026-04-13	GASTO	70000	NECESARIO	D├®bito	Taller Teatro	2026-04-13 22:38:38.229005	375	ASIGNADA_MANUAL	21	3
1629	2026-04-13 22:38:36.176	2026-04-09	GASTO	54000	NECESARIO	D├®bito	Rotiseria	2026-04-13 22:38:38.307104	378	ASIGNADA_MANUAL	38	3
1635	2026-04-16 14:50:59.33	2026-04-14	GASTO	50000	NECESARIO	D├®bito	Comida Chicha	2026-04-16 14:51:07.983284	378	ASIGNADA_MANUAL	13	3
1623	2026-04-13 22:38:36.176	2026-04-10	GASTO	46000	NECESARIO	D├®bito	CURSO PDS	2026-04-13 22:38:38.243617	375	ASIGNADA_MANUAL	21	3
1633	2026-04-16 14:50:59.33	2026-04-15	GASTO	10000	NECESARIO	D├®bito	SUBE	2026-04-16 14:51:07.967031	385	ASIGNADA_MANUAL	14	3
1624	2026-04-13 22:38:36.176	2026-04-10	GASTO	9539.4	NECESARIO	D├®bito	Metrogas (otra vez por error)	2026-04-13 22:38:38.256448	377	ASIGNADA_MANUAL	24	3
1628	2026-04-13 22:38:36.176	2026-04-09	GASTO	9539.4	NECESARIO	D├®bito	Metrogas	2026-04-13 22:38:38.295617	374	ASIGNADA_MANUAL	24	3
1634	2026-04-16 14:50:59.33	2026-04-14	GASTO	6100	NECESARIO	D├®bito	Chino	2026-04-16 14:51:07.975159	378	ASIGNADA_MANUAL	13	3
1631	2026-04-16 14:50:59.33	2026-04-16	GASTO	5000	NECESARIO	D├®bito	SUBE	2026-04-16 14:51:07.934964	385	ASIGNADA_MANUAL	14	3
1649	2026-04-16 14:50:59.33	2026-04-14	GASTO	29998	NECESARIO	D├®bito	Papel Higienico	2026-04-16 14:51:15.547648	362	ASIGNADA_MANUAL	16	3
1643	2026-04-16 14:50:59.33	2026-04-16	GASTO	26300	NECESARIO	D├®bito	Remis	2026-04-16 14:51:15.477966	385	ASIGNADA_MANUAL	14	3
1647	2026-04-16 14:50:59.33	2026-04-14	GASTO	19400	NECESARIO	D├®bito	Chino	2026-04-16 14:51:15.524787	378	ASIGNADA_MANUAL	13	3
1641	2026-04-16 14:50:59.33	2026-04-16	GASTO	3000	NECESARIO	D├®bito	Chipa	2026-04-16 14:51:15.444714	378	ASIGNADA_MANUAL	13	3
1648	2026-04-16 14:50:59.33	2026-04-14	GASTO	300000	NECESARIO	D├®bito	Plus Mel	2026-04-16 14:51:15.537054	375	ASIGNADA_MANUAL	21	3
1651	2026-04-16 14:50:59.33	2026-04-13	INGRESO	1313567.24	NECESARIO	D├®bito	TRANSFERENCIA DE TERCEROS ALICIA BEATRIZ REINOSO 27132603680 VARIOS	2026-04-16 14:51:15.574287	376	ASIGNADA_MANUAL	15	3
1639	2026-04-16 14:50:59.33	2026-04-14	INGRESO	100000	NECESARIO	D├®bito	TRANSFERENCIA DE TERCEROS SALANITRI, NORA GABRIE 27207543786	2026-04-16 14:51:08.018203	376	ASIGNADA_MANUAL	15	3
1652	2026-04-17 16:07:49.998	2026-04-16	GASTO	49694.02	NECESARIO	D├®bito	EDESUR	2026-04-17 16:07:51.753983	377	ASIGNADA_MANUAL	24	3
1654	2026-04-17 16:07:49.998	2026-04-16	GASTO	13400	NECESARIO	D├®bito	ALMACEN	2026-04-17 16:07:51.776071	378	ASIGNADA_MANUAL	13	3
1653	2026-04-17 16:07:49.998	2026-04-16	GASTO	11420	NECESARIO	D├®bito	DIA	2026-04-17 16:07:51.769434	378	ASIGNADA_MANUAL	13	3
\.


--
-- Data for Name: transactions_demo; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.transactions_demo (id, "timestamp", date, type, amount, necessity, payment_method, detail, created_at, debt_id, assignment_status, category_id) FROM stdin;
296	2026-03-18 21:44:08.391	2026-03-18	GASTO	20000	NECESARIO	D├®bito	Auris Mica	2026-03-18 21:44:08.457129	125	ASIGNADA_MANUAL	13
292	2026-03-17 20:33:16.124	2026-03-06	GASTO	21500	NECESARIO	D├®bito	Papel Higienico	2026-03-17 20:33:17.977361	125	ASIGNADA_MANUAL	16
284	2026-03-17 20:33:16.124	2026-03-01	GASTO	723000	NECESARIO	D├®bito	Alquiler Tone	2026-03-17 20:33:17.910387	125	ASIGNADA_MANUAL	16
289	2026-03-17 20:33:16.124	2026-03-03	GASTO	36000	NECESARIO	D├®bito	Taller Teatro	2026-03-17 20:33:17.955086	120	ASIGNADA_MANUAL	21
206	2026-03-08 00:11:35.057	2026-03-08	INGRESO	2000000	NECESARIO	D├®bito	Extracci├│n Dinero Tarj	2026-03-11 23:45:30.765909	136	ASIGNADA_MANUAL	15
269	2026-03-17 18:02:49.574	2026-03-16	GASTO	155960	NECESARIO	D├®bito	Proetica fcia ges	2026-03-17 18:02:53.91915	97	ASIGNADA_MANUAL	22
288	2026-03-17 20:33:16.124	2026-03-03	GASTO	45000	NECESARIO	D├®bito	Curso Chicha Feb	2026-03-17 20:33:17.946314	120	ASIGNADA_MANUAL	21
820	2026-03-31 23:41:45.766	2026-04-01	GASTO	13300	NECESARIO	D├®bito		2026-03-31 23:41:46.104041	91	ASIGNADA_MANUAL	13
297	2026-03-18 22:28:00.319	2026-03-18	GASTO	50000	NECESARIO	D├®bito	Nafta	2026-03-18 22:28:00.654225	93	ASIGNADA_MANUAL	14
191	2026-03-07 23:44:02.651	2026-03-03	INGRESO	478000	NECESARIO	D├®bito	Alquiler Monte	2026-03-11 23:45:30.730948	134	ASIGNADA_MANUAL	19
193	2026-03-07 23:44:02.651	2026-03-03	GASTO	55448	NECESARIO	D├®bito	Movistar 1 Feb	2026-03-11 23:45:30.735636	122	ASIGNADA_MANUAL	24
194	2026-03-07 23:44:02.651	2026-03-03	GASTO	46880	NECESARIO	D├®bito	Movistar 2 Feb	2026-03-11 23:45:30.737901	122	ASIGNADA_MANUAL	24
399	2026-03-25 15:19:48.335	2026-03-25	GASTO	49325.56	NECESARIO	D├®bito	Movistar Chicha Marzo	2026-03-25 15:19:48.686986	122	ASIGNADA_MANUAL	24
286	2026-03-17 20:33:16.124	2026-03-02	GASTO	90000	NECESARIO	D├®bito	Adriana Psico	2026-03-17 20:33:17.927433	110	ASIGNADA_MANUAL	22
196	2026-03-07 23:44:02.651	2026-03-03	GASTO	14756	NECESARIO	D├®bito	Metrogas Tone	2026-03-11 23:45:30.741925	122	ASIGNADA_MANUAL	24
183	2026-03-07 23:44:02.651	2026-03-02	GASTO	9000	NECESARIO	D├®bito	Ferreteria	2026-03-11 23:45:30.71114	125	ASIGNADA_MANUAL	16
197	2026-03-07 23:44:02.651	2026-03-03	GASTO	570000	NECESARIO	D├®bito	Garantia Fede	2026-03-11 23:45:30.743991	130	ASIGNADA_MANUAL	18
283	2026-03-17 20:33:16.124	2026-03-01	GASTO	1031203.5	NECESARIO	D├®bito	ITBA Febrero	2026-03-17 20:33:17.902359	120	ASIGNADA_MANUAL	21
190	2026-03-07 23:44:02.651	2026-03-02	GASTO	66734	NECESARIO	D├®bito	Cr├®dito ANSES	2026-03-11 23:45:30.727736	95	ASIGNADA_MANUAL	17
184	2026-03-07 23:44:02.651	2026-03-02	GASTO	100000	NECESARIO	D├®bito	Protesis 2/2	2026-03-11 23:45:30.713901	97	ASIGNADA_MANUAL	22
282	2026-03-17 20:33:16.124	2026-03-01	GASTO	1084080	NECESARIO	D├®bito	Sueldo C├®sar	2026-03-17 20:33:17.886921	110	ASIGNADA_MANUAL	22
181	2026-03-07 23:44:02.651	2026-03-01	GASTO	2507	NECESARIO	D├®bito	SUBE	2026-03-11 23:45:30.706942	119	ASIGNADA_MANUAL	14
210	2026-03-11 16:35:11.463	2026-03-10	INGRESO	396000	NECESARIO	D├®bito	Fac Vivian	2026-03-11 23:45:30.774082	137	ASIGNADA_MANUAL	15
195	2026-03-07 23:44:02.651	2026-03-03	GASTO	104550	NECESARIO	D├®bito	Edesur	2026-03-11 23:45:30.73983	122	ASIGNADA_MANUAL	24
180	2026-03-07 23:44:02.651	2026-03-01	INGRESO	2561000	NECESARIO	D├®bito	Sueldo Sergio	2026-03-11 23:45:30.704868	131	ASIGNADA_MANUAL	15
216	2026-03-14 16:44:39.195	2026-03-14	INGRESO	1970000	NECESARIO	D├®bito	Adelanto Sueldo Sergio	2026-03-14 16:44:39.3044	135	ASIGNADA_MANUAL	15
270	2026-03-17 18:02:49.574	2026-03-16	GASTO	20000	NECESARIO	D├®bito	Comida Chicha	2026-03-17 18:02:53.91915	91	ASIGNADA_MANUAL	13
218	2026-03-14 16:46:06.417	2026-03-14	GASTO	15750	NECESARIO	D├®bito	DIA	2026-03-14 16:46:06.430475	91	ASIGNADA_MANUAL	13
214	2026-03-11 23:53:30.463	2026-03-11	GASTO	7100	NECESARIO	D├®bito	Chino	2026-03-11 23:53:30.483371	91	ASIGNADA_MANUAL	13
271	2026-03-17 18:02:49.574	2026-03-16	GASTO	34844	NECESARIO	D├®bito	Pr├®stamos MP	2026-03-17 18:02:53.91915	95	ASIGNADA_MANUAL	17
199	2026-03-07 23:44:02.651	2026-03-15	GASTO	3701	NECESARIO	D├®bito	Comida Chicha	2026-03-11 23:45:30.749335	91	ASIGNADA_MANUAL	13
274	2026-03-17 18:02:49.574	2026-03-14	GASTO	50000	NECESARIO	D├®bito	Comida Mica	2026-03-17 18:02:53.91915	121	ASIGNADA_MANUAL	13
222	2026-03-14 22:04:22.528	2026-03-14	GASTO	10812	NECESARIO	D├®bito	DIA Merienda	2026-03-14 22:04:22.568418	91	ASIGNADA_MANUAL	13
217	2026-03-14 16:45:23.769	2026-03-14	GASTO	1363	NECESARIO	D├®bito	SUBE	2026-03-14 16:45:23.781125	119	ASIGNADA_MANUAL	14
215	2026-03-11 23:53:43.862	2026-03-11	GASTO	9400	NECESARIO	D├®bito	Panchos	2026-03-11 23:53:43.867909	91	ASIGNADA_MANUAL	13
207	2026-03-08 00:26:47.746	2026-03-05	GASTO	10000	NECESARIO	D├®bito	Almuerzo Sergio	2026-03-11 23:45:30.767985	91	ASIGNADA_MANUAL	13
209	2026-03-11 16:35:11.463	2026-03-09	GASTO	30000	NECESARIO	D├®bito	SUBE	2026-03-11 23:45:30.772099	119	ASIGNADA_MANUAL	14
268	2026-03-17 18:02:49.574	2026-03-16	GASTO	37300	NECESARIO	D├®bito	Chino	2026-03-17 18:02:53.91915	91	ASIGNADA_MANUAL	13
272	2026-03-17 18:02:49.574	2026-03-15	GASTO	87000	NECESARIO	D├®bito	Rotiseria	2026-03-17 18:02:53.91915	91	ASIGNADA_MANUAL	13
276	2026-03-17 18:02:49.574	2026-03-14	GASTO	6800	NECESARIO	D├®bito	Panaderia	2026-03-17 18:02:53.91915	91	ASIGNADA_MANUAL	13
275	2026-03-17 18:02:49.574	2026-03-14	GASTO	14000	NECESARIO	D├®bito	Comida Gato	2026-03-17 18:02:53.91915	91	ASIGNADA_MANUAL	13
201	2026-03-07 23:44:02.651	2026-03-06	GASTO	3700	NECESARIO	D├®bito	Comida Chicha	2026-03-11 23:45:30.753607	91	ASIGNADA_MANUAL	13
202	2026-03-07 23:44:02.651	2026-03-06	GASTO	50000	NECESARIO	D├®bito	Comida Mica	2026-03-11 23:45:30.755857	91	ASIGNADA_MANUAL	13
186	2026-03-07 23:44:02.651	2026-03-03	GASTO	2000	NECESARIO	D├®bito	Coquita	2026-03-11 23:45:30.718607	91	ASIGNADA_MANUAL	13
187	2026-03-07 23:44:02.651	2026-03-03	GASTO	5900	NECESARIO	D├®bito	DIA	2026-03-11 23:45:30.721409	91	ASIGNADA_MANUAL	13
188	2026-03-07 23:44:02.651	2026-03-03	GASTO	22930	NECESARIO	D├®bito	Comida DIA	2026-03-11 23:45:30.723702	91	ASIGNADA_MANUAL	13
189	2026-03-07 23:44:02.651	2026-03-03	GASTO	22000	NECESARIO	D├®bito	Rotiseria	2026-03-11 23:45:30.725734	91	ASIGNADA_MANUAL	13
192	2026-03-07 23:44:02.651	2026-03-03	GASTO	64000	NECESARIO	D├®bito	Chino	2026-03-11 23:45:30.733551	91	ASIGNADA_MANUAL	13
178	2026-03-07 23:44:02.651	2026-03-01	GASTO	12981	NECESARIO	D├®bito	Carrefour Express	2026-03-11 23:45:30.699448	91	ASIGNADA_MANUAL	13
177	2026-03-07 23:44:02.651	2026-03-01	GASTO	18500	NECESARIO	D├®bito	DIA	2026-03-11 23:45:30.68898	91	ASIGNADA_MANUAL	13
182	2026-03-07 23:44:02.651	2026-03-01	GASTO	15000	NECESARIO	D├®bito	Carniceria	2026-03-11 23:45:30.709026	91	ASIGNADA_MANUAL	13
221	2026-03-14 22:04:06.48	2026-03-14	GASTO	50000	NECESARIO	D├®bito	Comida Mica	2026-03-14 22:04:06.529962	121	ASIGNADA_MANUAL	13
266	2026-03-17 18:02:49.574	2026-03-16	GASTO	8920.64	NECESARIO	D├®bito	Farmacia	2026-03-17 18:02:53.91915	97	ASIGNADA_MANUAL	22
204	2026-03-07 23:44:02.651	2026-03-06	GASTO	89000	NECESARIO	D├®bito	Nafta	2026-03-11 23:45:30.760023	93	ASIGNADA_MANUAL	14
203	2026-03-07 23:44:02.651	2026-03-06	GASTO	25000	NECESARIO	D├®bito	Remedio Eze 1/6	2026-03-11 23:45:30.758015	97	ASIGNADA_MANUAL	22
200	2026-03-07 23:44:02.651	2026-03-06	GASTO	37095	NECESARIO	D├®bito	ARCA C├®sar Feb	2026-03-11 23:45:30.75156	124	ASIGNADA_MANUAL	20
294	2026-03-17 20:33:16.124	2026-03-02	GASTO	100440	NECESARIO	D├®bito	Escuela Eze	2026-03-17 20:33:17.991462	120	ASIGNADA_MANUAL	21
185	2026-03-07 23:44:02.651	2026-03-03	GASTO	27000	NECESARIO	D├®bito	Patys	2026-03-11 23:45:30.716679	91	ASIGNADA_MANUAL	13
279	2026-03-17 18:02:49.574	2026-03-17	GASTO	41809	NECESARIO	D├®bito	Movistar Sergio Marzo	2026-03-17 18:02:53.91915	122	ASIGNADA_MANUAL	24
293	2026-03-17 20:33:16.124	2026-03-07	GASTO	30000	NECESARIO	D├®bito	SUBE	2026-03-17 20:33:17.984539	119	ASIGNADA_MANUAL	14
327	2026-03-24 21:01:28.429	2026-03-19	GASTO	1363	NECESARIO	D├®bito	SUBE	2026-03-24 21:01:32.329788	93	ASIGNADA_MANUAL	14
179	2026-03-07 23:44:02.651	2026-03-01	GASTO	150000	NECESARIO	D├®bito	Gastos Mica	2026-03-11 23:45:30.702264	121	ASIGNADA_MANUAL	13
323	2026-03-24 21:01:28.429	2026-03-25	GASTO	24000	NECESARIO	D├®bito	Comida Mica	2026-03-24 21:01:32.228976	121	ASIGNADA_MANUAL	13
205	2026-03-08 00:10:43.055	2026-03-02	INGRESO	1820000	NECESARIO	D├®bito	Sueldo Chicha	2026-03-11 23:45:30.762957	133	ASIGNADA_MANUAL	15
794	2026-03-31 01:28:12.112	2026-04-01	INGRESO	3585558	NECESARIO	D├®bito	Sueldo Sergio	2026-03-31 01:28:17.482047	\N	ASIGNADA_MANUAL	15
285	2026-03-17 20:33:16.124	2026-03-01	GASTO	147000	NECESARIO	D├®bito	Pr├®stamos MP Chicha	2026-03-17 20:33:17.91838	95	ASIGNADA_MANUAL	17
290	2026-03-17 20:33:16.124	2026-03-06	GASTO	22507	NECESARIO	D├®bito	SUBE	2026-03-17 20:33:17.962589	119	ASIGNADA_MANUAL	14
792	2026-03-31 01:28:12.112	2026-04-01	GASTO	130000	NECESARIO	D├®bito	Deuda Carniceria	2026-03-31 01:28:17.437049	121	ASIGNADA_MANUAL	13
287	2026-03-17 20:33:16.124	2026-03-02	GASTO	45000	NECESARIO	D├®bito	Curso Chicha Marzo	2026-03-17 20:33:17.937725	120	ASIGNADA_MANUAL	21
321	2026-03-24 21:01:28.429	2026-03-25	GASTO	5100	NECESARIO	D├®bito	COMPRA DEBITO\n ANTOJA2\n 4517XXXXXXXXXX73\n A003	2026-03-24 21:01:32.17832	91	ASIGNADA_MANUAL	13
401	2026-03-26 17:12:29.619	2026-03-26	GASTO	73239.98	NECESARIO	D├®bito	ARCA C├®sar Nov y Dic	2026-03-26 17:12:29.661219	124	ASIGNADA_MANUAL	20
329	2026-03-24 21:46:59.053	2026-03-02	GASTO	17015.84	NECESARIO	D├®bito	Movistar Mica	2026-03-24 21:47:05.855649	122	ASIGNADA_MANUAL	24
328	2026-03-24 21:46:59.053	2026-03-06	GASTO	13000	NECESARIO	D├®bito	Honorarios Ana	2026-03-24 21:47:05.780965	125	ASIGNADA_MANUAL	19
318	2026-03-22 16:57:20.536	2026-03-22	GASTO	8400	NECESARIO	D├®bito	Desayuno Central	2026-03-22 16:57:20.5591	91	ASIGNADA_MANUAL	13
324	2026-03-24 21:01:28.429	2026-03-25	GASTO	76492	NECESARIO	D├®bito	COMPRA DEBITO\n SAMSONITE\n 4517XXXXXXXXXX73\n A327	2026-03-24 21:01:32.258831	114	ASIGNADA_MANUAL	23
320	2026-03-24 21:01:28.429	2026-03-25	GASTO	4000	SUPERFLUO	D├®bito	COMPRA DEBITO\n ANTOJA2\n 4517XXXXXXXXXX73\n A003	2026-03-24 21:01:32.160173	91	ASIGNADA_MANUAL	13
338	2026-03-24 22:25:03.008	2026-03-25	GASTO	64000	NECESARIO	D├®bito	CDB Eze	2026-03-24 22:25:10.756885	97	ASIGNADA_MANUAL	22
337	2026-03-24 22:25:03.008	2026-03-25	GASTO	12097.35	NECESARIO	D├®bito	PERCEPCION RG 5617/24	2026-03-24 22:25:10.724079	124	ASIGNADA_MANUAL	20
341	2026-03-24 22:25:03.008	2026-03-06	GASTO	683399.81	NECESARIO	D├®bito	Alquiler Tone	2026-03-24 22:25:10.922287	125	ASIGNADA_MANUAL	19
343	2026-03-24 22:25:03.008	2026-03-02	GASTO	40661.27	NECESARIO	D├®bito	CUOTA DE PRESTAMO\n 808118798055\n CUOTA         4	2026-03-24 22:25:10.998938	95	ASIGNADA_MANUAL	17
342	2026-03-24 22:25:03.008	2026-03-02	GASTO	685947.56	NECESARIO	D├®bito	CUOTA DE PRESTAMO\n 808124429651\n CUOTA         1	2026-03-24 22:25:10.9905	95	ASIGNADA_MANUAL	17
793	2026-03-31 01:28:12.112	2026-04-01	GASTO	32000	NECESARIO	D├®bito	Rotiseria	2026-03-31 01:28:17.471384	\N	ASIGNADA_MANUAL	13
796	2026-03-31 01:28:12.112	2026-04-01	GASTO	90000	NECESARIO	D├®bito	Taller	2026-03-31 01:28:17.503661	\N	ASIGNADA_MANUAL	14
795	2026-03-31 01:28:12.112	2026-03-30	GASTO	150000	NECESARIO	D├®bito	Nafta	2026-03-31 01:28:17.492773	93	ASIGNADA_MANUAL	14
798	2026-03-31 01:28:12.112	2026-03-25	INGRESO	22.97	NECESARIO	D├®bito	INTERES CAPITALIZADO\n Marzo 2026	2026-03-31 01:28:17.662299	124	ASIGNADA_MANUAL	15
797	2026-03-31 01:28:12.112	2026-03-27	INGRESO	33820.35	NECESARIO	D├®bito	DEV.COMPRA GALICIA 24-ELECTRON	2026-03-31 01:28:17.617369	124	ASIGNADA_MANUAL	15
317	2026-03-19 19:26:52.584	2026-03-19	GASTO	116000	NECESARIO	D├®bito	Curso CUI 1/4	2026-03-19 19:26:52.891218	120	ASIGNADA_MANUAL	21
402	2026-03-30 19:36:06.313	2026-03-26	GASTO	37095	NECESARIO	D├®bito	ARCA C├®sar Marzo	2026-03-30 19:36:45.188191	124	ASIGNADA_MANUAL	20
339	2026-03-24 22:25:03.008	2026-03-09	GASTO	160000	NECESARIO	D├®bito	Deuda MP Chicha Feb	2026-03-24 22:25:10.906258	95	ASIGNADA_MANUAL	17
\.


--
-- Data for Name: user_roles; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.user_roles (user_id, role_id) FROM stdin;
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.users (id, username, hashed_password, created_at, email, first_name, last_name, is_active, is_locked, failed_login_attempts, force_password_change, last_login_at, password_changed_at, updated_at) FROM stdin;
\.


--
-- Name: app_settings_id_seq26; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.app_settings_id_seq26', 1, false);


--
-- Name: audit_logs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.audit_logs_id_seq', 226, true);


--
-- Name: bank_accounts_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.bank_accounts_id_seq', 1, false);


--
-- Name: budget_items_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.budget_items_id_seq', 1012, true);


--
-- Name: categories_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.categories_id_seq', 44, true);


--
-- Name: credit_card_payments_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.credit_card_payments_id_seq', 1, false);


--
-- Name: credit_card_period_configs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.credit_card_period_configs_id_seq', 7, true);


--
-- Name: credit_card_purchases_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.credit_card_purchases_id_seq', 315, true);


--
-- Name: credit_card_statements_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.credit_card_statements_id_seq', 1, false);


--
-- Name: credit_cards_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.credit_cards_id_seq', 21, true);


--
-- Name: debt_payments_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.debt_payments_id_seq', 2, true);


--
-- Name: debt_records_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.debt_records_id_seq', 37, true);


--
-- Name: installment_plans_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.installment_plans_id_seq', 46, true);


--
-- Name: installment_schedule_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.installment_schedule_id_seq', 283, true);


--
-- Name: month_closings_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.month_closings_id_seq', 1, true);


--
-- Name: monthly_balances_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.monthly_balances_id_seq', 5, true);


--
-- Name: monthly_period_events_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.monthly_period_events_id_seq', 21, true);


--
-- Name: monthly_period_snapshots_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.monthly_period_snapshots_id_seq', 9, true);


--
-- Name: monthly_periods_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.monthly_periods_id_seq', 9, true);


--
-- Name: permissions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.permissions_id_seq', 26, true);


--
-- Name: refresh_tokens_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.refresh_tokens_id_seq', 150, true);


--
-- Name: roles_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.roles_id_seq', 9, true);


--
-- Name: transactions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.transactions_id_seq', 1869, true);


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.users_id_seq', 11, true);


--
-- Name: alembic_version alembic_version_pkc; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.alembic_version
    ADD CONSTRAINT alembic_version_pkc PRIMARY KEY (version_num);


--
-- Name: app_settings app_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.app_settings
    ADD CONSTRAINT app_settings_pkey PRIMARY KEY (id);


--
-- Name: audit_logs audit_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.audit_logs
    ADD CONSTRAINT audit_logs_pkey PRIMARY KEY (id);


--
-- Name: bank_accounts bank_accounts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bank_accounts
    ADD CONSTRAINT bank_accounts_pkey PRIMARY KEY (id);


--
-- Name: categories categories_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT categories_name_key UNIQUE (name);


--
-- Name: categories categories_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT categories_pkey PRIMARY KEY (id);


--
-- Name: credit_card_payments credit_card_payments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.credit_card_payments
    ADD CONSTRAINT credit_card_payments_pkey PRIMARY KEY (id);


--
-- Name: credit_card_period_configs credit_card_period_configs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.credit_card_period_configs
    ADD CONSTRAINT credit_card_period_configs_pkey PRIMARY KEY (id);


--
-- Name: credit_card_purchases credit_card_purchases_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.credit_card_purchases
    ADD CONSTRAINT credit_card_purchases_pkey PRIMARY KEY (id);


--
-- Name: credit_card_statements credit_card_statements_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.credit_card_statements
    ADD CONSTRAINT credit_card_statements_pkey PRIMARY KEY (id);


--
-- Name: credit_cards credit_cards_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.credit_cards
    ADD CONSTRAINT credit_cards_pkey PRIMARY KEY (id);


--
-- Name: debt_payments debt_payments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.debt_payments
    ADD CONSTRAINT debt_payments_pkey PRIMARY KEY (id);


--
-- Name: debt_records debt_records_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.debt_records
    ADD CONSTRAINT debt_records_pkey PRIMARY KEY (id);


--
-- Name: budget_items debts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.budget_items
    ADD CONSTRAINT debts_pkey PRIMARY KEY (id);


--
-- Name: installment_plans installment_plans_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.installment_plans
    ADD CONSTRAINT installment_plans_pkey PRIMARY KEY (id);


--
-- Name: installment_plans installment_plans_purchase_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.installment_plans
    ADD CONSTRAINT installment_plans_purchase_id_key UNIQUE (purchase_id);


--
-- Name: installment_schedule installment_schedule_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.installment_schedule
    ADD CONSTRAINT installment_schedule_pkey PRIMARY KEY (id);


--
-- Name: month_closings month_closings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.month_closings
    ADD CONSTRAINT month_closings_pkey PRIMARY KEY (id);


--
-- Name: monthly_balances monthly_balances_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.monthly_balances
    ADD CONSTRAINT monthly_balances_pkey PRIMARY KEY (id);


--
-- Name: monthly_period_events monthly_period_events_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.monthly_period_events
    ADD CONSTRAINT monthly_period_events_pkey PRIMARY KEY (id);


--
-- Name: monthly_period_snapshots monthly_period_snapshots_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.monthly_period_snapshots
    ADD CONSTRAINT monthly_period_snapshots_pkey PRIMARY KEY (id);


--
-- Name: monthly_periods monthly_periods_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.monthly_periods
    ADD CONSTRAINT monthly_periods_pkey PRIMARY KEY (id);


--
-- Name: permissions permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.permissions
    ADD CONSTRAINT permissions_pkey PRIMARY KEY (id);


--
-- Name: refresh_tokens refresh_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.refresh_tokens
    ADD CONSTRAINT refresh_tokens_pkey PRIMARY KEY (id);


--
-- Name: role_permissions role_permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.role_permissions
    ADD CONSTRAINT role_permissions_pkey PRIMARY KEY (role_id, permission_id);


--
-- Name: roles roles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (id);


--
-- Name: transactions_demo transactions_demo_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transactions_demo
    ADD CONSTRAINT transactions_demo_pkey PRIMARY KEY (id);


--
-- Name: transactions transactions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transactions
    ADD CONSTRAINT transactions_pkey PRIMARY KEY (id);


--
-- Name: credit_card_period_configs uq_card_period_config; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.credit_card_period_configs
    ADD CONSTRAINT uq_card_period_config UNIQUE (card_id, year, month);


--
-- Name: credit_cards uq_credit_cards_user_card_name; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.credit_cards
    ADD CONSTRAINT uq_credit_cards_user_card_name UNIQUE (user_id, card_name);


--
-- Name: month_closings uq_month_closings_year_month_user; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.month_closings
    ADD CONSTRAINT uq_month_closings_year_month_user UNIQUE (year, month, user_id);


--
-- Name: monthly_periods uq_monthly_periods_year_month_user; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.monthly_periods
    ADD CONSTRAINT uq_monthly_periods_year_month_user UNIQUE (year_month, user_id);


--
-- Name: user_roles user_roles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_roles
    ADD CONSTRAINT user_roles_pkey PRIMARY KEY (user_id, role_id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: ix_app_settings_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_app_settings_id ON public.app_settings USING btree (id);


--
-- Name: ix_app_settings_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX ix_app_settings_key ON public.app_settings USING btree (key);


--
-- Name: ix_audit_logs_action; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_audit_logs_action ON public.audit_logs USING btree (action);


--
-- Name: ix_audit_logs_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_audit_logs_created_at ON public.audit_logs USING btree (created_at);


--
-- Name: ix_audit_logs_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_audit_logs_id ON public.audit_logs USING btree (id);


--
-- Name: ix_bank_accounts_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_bank_accounts_id ON public.bank_accounts USING btree (id);


--
-- Name: ix_bank_accounts_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_bank_accounts_user_id ON public.bank_accounts USING btree (user_id);


--
-- Name: ix_budget_items_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_budget_items_id ON public.budget_items USING btree (id);


--
-- Name: ix_budget_items_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_budget_items_user_id ON public.budget_items USING btree (user_id);


--
-- Name: ix_categories_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_categories_id ON public.categories USING btree (id);


--
-- Name: ix_credit_card_payments_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_credit_card_payments_id ON public.credit_card_payments USING btree (id);


--
-- Name: ix_credit_card_period_configs_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_credit_card_period_configs_id ON public.credit_card_period_configs USING btree (id);


--
-- Name: ix_credit_card_purchases_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_credit_card_purchases_id ON public.credit_card_purchases USING btree (id);


--
-- Name: ix_credit_card_statements_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_credit_card_statements_id ON public.credit_card_statements USING btree (id);


--
-- Name: ix_credit_cards_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_credit_cards_id ON public.credit_cards USING btree (id);


--
-- Name: ix_debt_payments_debt_record_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_debt_payments_debt_record_id ON public.debt_payments USING btree (debt_record_id);


--
-- Name: ix_debt_payments_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_debt_payments_id ON public.debt_payments USING btree (id);


--
-- Name: ix_debt_records_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_debt_records_id ON public.debt_records USING btree (id);


--
-- Name: ix_debt_records_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_debt_records_user_id ON public.debt_records USING btree (user_id);


--
-- Name: ix_debts_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_debts_id ON public.budget_items USING btree (id);


--
-- Name: ix_installment_plans_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_installment_plans_id ON public.installment_plans USING btree (id);


--
-- Name: ix_installment_schedule_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_installment_schedule_id ON public.installment_schedule USING btree (id);


--
-- Name: ix_month_closings_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_month_closings_id ON public.month_closings USING btree (id);


--
-- Name: ix_month_closings_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_month_closings_user_id ON public.month_closings USING btree (user_id);


--
-- Name: ix_monthly_balances_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_monthly_balances_id ON public.monthly_balances USING btree (id);


--
-- Name: ix_monthly_balances_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_monthly_balances_user_id ON public.monthly_balances USING btree (user_id);


--
-- Name: ix_monthly_period_events_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_monthly_period_events_id ON public.monthly_period_events USING btree (id);


--
-- Name: ix_monthly_period_events_monthly_period_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_monthly_period_events_monthly_period_id ON public.monthly_period_events USING btree (monthly_period_id);


--
-- Name: ix_monthly_period_snapshots_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_monthly_period_snapshots_id ON public.monthly_period_snapshots USING btree (id);


--
-- Name: ix_monthly_periods_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_monthly_periods_id ON public.monthly_periods USING btree (id);


--
-- Name: ix_monthly_periods_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_monthly_periods_user_id ON public.monthly_periods USING btree (user_id);


--
-- Name: ix_monthly_periods_year_month; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_monthly_periods_year_month ON public.monthly_periods USING btree (year_month);


--
-- Name: ix_permissions_code; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX ix_permissions_code ON public.permissions USING btree (code);


--
-- Name: ix_permissions_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_permissions_id ON public.permissions USING btree (id);


--
-- Name: ix_refresh_tokens_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_refresh_tokens_id ON public.refresh_tokens USING btree (id);


--
-- Name: ix_refresh_tokens_token_hash; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_refresh_tokens_token_hash ON public.refresh_tokens USING btree (token_hash);


--
-- Name: ix_roles_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_roles_id ON public.roles USING btree (id);


--
-- Name: ix_roles_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX ix_roles_name ON public.roles USING btree (name);


--
-- Name: ix_transactions_demo_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_transactions_demo_id ON public.transactions_demo USING btree (id) WITH (fillfactor='100', deduplicate_items='true');


--
-- Name: ix_transactions_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_transactions_id ON public.transactions USING btree (id);


--
-- Name: ix_transactions_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_transactions_user_id ON public.transactions USING btree (user_id);


--
-- Name: ix_users_email; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX ix_users_email ON public.users USING btree (email);


--
-- Name: ix_users_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_users_id ON public.users USING btree (id);


--
-- Name: ix_users_username; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX ix_users_username ON public.users USING btree (username);


--
-- Name: bank_accounts bank_accounts_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bank_accounts
    ADD CONSTRAINT bank_accounts_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: credit_card_payments credit_card_payments_card_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.credit_card_payments
    ADD CONSTRAINT credit_card_payments_card_id_fkey FOREIGN KEY (card_id) REFERENCES public.credit_cards(id) ON DELETE CASCADE;


--
-- Name: credit_card_payments credit_card_payments_statement_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.credit_card_payments
    ADD CONSTRAINT credit_card_payments_statement_id_fkey FOREIGN KEY (statement_id) REFERENCES public.credit_card_statements(id) ON DELETE SET NULL;


--
-- Name: credit_card_payments credit_card_payments_transaction_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.credit_card_payments
    ADD CONSTRAINT credit_card_payments_transaction_id_fkey FOREIGN KEY (transaction_id) REFERENCES public.transactions(id) ON DELETE SET NULL;


--
-- Name: credit_card_period_configs credit_card_period_configs_card_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.credit_card_period_configs
    ADD CONSTRAINT credit_card_period_configs_card_id_fkey FOREIGN KEY (card_id) REFERENCES public.credit_cards(id) ON DELETE CASCADE;


--
-- Name: credit_card_purchases credit_card_purchases_card_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.credit_card_purchases
    ADD CONSTRAINT credit_card_purchases_card_id_fkey FOREIGN KEY (card_id) REFERENCES public.credit_cards(id) ON DELETE CASCADE;


--
-- Name: credit_card_purchases credit_card_purchases_transaction_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.credit_card_purchases
    ADD CONSTRAINT credit_card_purchases_transaction_id_fkey FOREIGN KEY (transaction_id) REFERENCES public.transactions(id) ON DELETE SET NULL;


--
-- Name: credit_card_statements credit_card_statements_card_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.credit_card_statements
    ADD CONSTRAINT credit_card_statements_card_id_fkey FOREIGN KEY (card_id) REFERENCES public.credit_cards(id) ON DELETE CASCADE;


--
-- Name: debt_payments debt_payments_debt_record_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.debt_payments
    ADD CONSTRAINT debt_payments_debt_record_id_fkey FOREIGN KEY (debt_record_id) REFERENCES public.debt_records(id) ON DELETE CASCADE;


--
-- Name: debt_payments debt_payments_transaction_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.debt_payments
    ADD CONSTRAINT debt_payments_transaction_id_fkey FOREIGN KEY (transaction_id) REFERENCES public.transactions(id) ON DELETE SET NULL;


--
-- Name: installment_plans installment_plans_debt_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.installment_plans
    ADD CONSTRAINT installment_plans_debt_id_fkey FOREIGN KEY (budget_item_id) REFERENCES public.budget_items(id) ON DELETE SET NULL;


--
-- Name: installment_plans installment_plans_purchase_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.installment_plans
    ADD CONSTRAINT installment_plans_purchase_id_fkey FOREIGN KEY (purchase_id) REFERENCES public.credit_card_purchases(id) ON DELETE CASCADE;


--
-- Name: installment_schedule installment_schedule_payment_transaction_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.installment_schedule
    ADD CONSTRAINT installment_schedule_payment_transaction_id_fkey FOREIGN KEY (payment_transaction_id) REFERENCES public.transactions(id) ON DELETE SET NULL;


--
-- Name: installment_schedule installment_schedule_plan_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.installment_schedule
    ADD CONSTRAINT installment_schedule_plan_id_fkey FOREIGN KEY (plan_id) REFERENCES public.installment_plans(id) ON DELETE CASCADE;


--
-- Name: month_closings month_closings_carry_over_transaction_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.month_closings
    ADD CONSTRAINT month_closings_carry_over_transaction_id_fkey FOREIGN KEY (carry_over_transaction_id) REFERENCES public.transactions(id) ON DELETE SET NULL;


--
-- Name: month_closings month_closings_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.month_closings
    ADD CONSTRAINT month_closings_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: monthly_period_events monthly_period_events_monthly_period_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.monthly_period_events
    ADD CONSTRAINT monthly_period_events_monthly_period_id_fkey FOREIGN KEY (monthly_period_id) REFERENCES public.monthly_periods(id) ON DELETE CASCADE;


--
-- Name: monthly_period_snapshots monthly_period_snapshots_monthly_period_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.monthly_period_snapshots
    ADD CONSTRAINT monthly_period_snapshots_monthly_period_id_fkey FOREIGN KEY (monthly_period_id) REFERENCES public.monthly_periods(id) ON DELETE CASCADE;


--
-- Name: role_permissions role_permissions_permission_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.role_permissions
    ADD CONSTRAINT role_permissions_permission_id_fkey FOREIGN KEY (permission_id) REFERENCES public.permissions(id) ON DELETE CASCADE;


--
-- Name: role_permissions role_permissions_role_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.role_permissions
    ADD CONSTRAINT role_permissions_role_id_fkey FOREIGN KEY (role_id) REFERENCES public.roles(id) ON DELETE CASCADE;


--
-- Name: transactions transactions_category_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transactions
    ADD CONSTRAINT transactions_category_id_fkey FOREIGN KEY (category_id) REFERENCES public.categories(id);


--
-- Name: transactions_demo transactions_demo_category_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transactions_demo
    ADD CONSTRAINT transactions_demo_category_id_fkey FOREIGN KEY (category_id) REFERENCES public.categories(id);


--
-- Name: transactions_demo transactions_demo_debt_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transactions_demo
    ADD CONSTRAINT transactions_demo_debt_id_fkey FOREIGN KEY (debt_id) REFERENCES public.budget_items(id);


--
-- Name: user_roles user_roles_role_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_roles
    ADD CONSTRAINT user_roles_role_id_fkey FOREIGN KEY (role_id) REFERENCES public.roles(id) ON DELETE CASCADE;


--
-- Name: user_roles user_roles_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_roles
    ADD CONSTRAINT user_roles_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

\unrestrict gVfu7fOYt3TbHa7l2K1E2ZRRC4cgTU8pIAw3HTR8LPbwW9DWUKGmD2NUgI8ixW5

