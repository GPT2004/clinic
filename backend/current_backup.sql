--
-- PostgreSQL database dump
--

-- Dumped from database version 17.5
-- Dumped by pg_dump version 17.5

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

--
-- Name: public; Type: SCHEMA; Schema: -; Owner: postgres
--

-- *not* creating schema, since initdb creates it


ALTER SCHEMA public OWNER TO postgres;

--
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON SCHEMA public IS '';


--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


--
-- Name: appointment_status; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.appointment_status AS ENUM (
    'PENDING',
    'CONFIRMED',
    'CHECKED_IN',
    'IN_PROGRESS',
    'COMPLETED',
    'CANCELLED',
    'NO_SHOW'
);


ALTER TYPE public.appointment_status OWNER TO postgres;

--
-- Name: invoice_status; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.invoice_status AS ENUM (
    'UNPAID',
    'PAID',
    'REFUNDED'
);


ALTER TYPE public.invoice_status OWNER TO postgres;

--
-- Name: prescription_status; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.prescription_status AS ENUM (
    'DRAFT',
    'APPROVED',
    'DISPENSED',
    'INVOICED',
    'READY_FOR_DISPENSE'
);


ALTER TYPE public.prescription_status OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: _prisma_migrations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public._prisma_migrations (
    id character varying(36) NOT NULL,
    checksum character varying(64) NOT NULL,
    finished_at timestamp with time zone,
    migration_name character varying(255) NOT NULL,
    logs text,
    rolled_back_at timestamp with time zone,
    started_at timestamp with time zone DEFAULT now() NOT NULL,
    applied_steps_count integer DEFAULT 0 NOT NULL
);


ALTER TABLE public._prisma_migrations OWNER TO postgres;

--
-- Name: appointments; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.appointments (
    id integer NOT NULL,
    patient_id integer NOT NULL,
    doctor_id integer NOT NULL,
    timeslot_id integer,
    appointment_date date NOT NULL,
    appointment_time time(6) without time zone,
    status public.appointment_status DEFAULT 'PENDING'::public.appointment_status NOT NULL,
    reason text,
    source character varying(50) DEFAULT 'web'::character varying,
    created_by integer,
    created_at timestamp(6) with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.appointments OWNER TO postgres;

--
-- Name: appointments_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.appointments_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.appointments_id_seq OWNER TO postgres;

--
-- Name: appointments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.appointments_id_seq OWNED BY public.appointments.id;


--
-- Name: audit_logs; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.audit_logs (
    id integer NOT NULL,
    user_id integer,
    action character varying(255) NOT NULL,
    meta jsonb,
    created_at timestamp(6) with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.audit_logs OWNER TO postgres;

--
-- Name: audit_logs_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.audit_logs_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.audit_logs_id_seq OWNER TO postgres;

--
-- Name: audit_logs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.audit_logs_id_seq OWNED BY public.audit_logs.id;


--
-- Name: doctor_reviews; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.doctor_reviews (
    id integer NOT NULL,
    doctor_id integer NOT NULL,
    patient_id integer NOT NULL,
    rating smallint NOT NULL,
    comment text,
    created_at timestamp(6) with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.doctor_reviews OWNER TO postgres;

--
-- Name: doctor_reviews_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.doctor_reviews_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.doctor_reviews_id_seq OWNER TO postgres;

--
-- Name: doctor_reviews_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.doctor_reviews_id_seq OWNED BY public.doctor_reviews.id;


--
-- Name: doctor_specialties; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.doctor_specialties (
    id integer NOT NULL,
    doctor_id integer NOT NULL,
    specialty_id integer NOT NULL,
    created_at timestamp(6) with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.doctor_specialties OWNER TO postgres;

--
-- Name: doctor_specialties_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.doctor_specialties_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.doctor_specialties_id_seq OWNER TO postgres;

--
-- Name: doctor_specialties_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.doctor_specialties_id_seq OWNED BY public.doctor_specialties.id;


--
-- Name: doctors; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.doctors (
    id integer NOT NULL,
    user_id integer NOT NULL,
    license_number character varying(100),
    specialties text[],
    bio text,
    consultation_fee integer,
    rating numeric(3,2) DEFAULT 0,
    created_at timestamp(6) with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    address text,
    gender character varying(20)
);


ALTER TABLE public.doctors OWNER TO postgres;

--
-- Name: doctors_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.doctors_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.doctors_id_seq OWNER TO postgres;

--
-- Name: doctors_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.doctors_id_seq OWNED BY public.doctors.id;


--
-- Name: invoices; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.invoices (
    id integer NOT NULL,
    appointment_id integer,
    patient_id integer NOT NULL,
    items jsonb NOT NULL,
    subtotal integer DEFAULT 0,
    tax integer DEFAULT 0,
    discount integer DEFAULT 0,
    total integer DEFAULT 0,
    status public.invoice_status DEFAULT 'UNPAID'::public.invoice_status NOT NULL,
    paid_at timestamp(6) with time zone,
    created_at timestamp(6) with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    prescription_id integer
);


ALTER TABLE public.invoices OWNER TO postgres;

--
-- Name: invoices_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.invoices_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.invoices_id_seq OWNER TO postgres;

--
-- Name: invoices_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.invoices_id_seq OWNED BY public.invoices.id;


--
-- Name: lab_orders; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.lab_orders (
    id integer NOT NULL,
    appointment_id integer,
    patient_id integer NOT NULL,
    doctor_id integer NOT NULL,
    tests jsonb NOT NULL,
    status character varying(50) DEFAULT 'PENDING'::character varying,
    results jsonb,
    created_at timestamp(6) with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.lab_orders OWNER TO postgres;

--
-- Name: lab_orders_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.lab_orders_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.lab_orders_id_seq OWNER TO postgres;

--
-- Name: lab_orders_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.lab_orders_id_seq OWNED BY public.lab_orders.id;


--
-- Name: medical_records; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.medical_records (
    id integer NOT NULL,
    appointment_id integer,
    patient_id integer NOT NULL,
    doctor_id integer NOT NULL,
    diagnosis text,
    notes text,
    attachments jsonb,
    created_at timestamp(6) with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.medical_records OWNER TO postgres;

--
-- Name: medical_records_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.medical_records_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.medical_records_id_seq OWNER TO postgres;

--
-- Name: medical_records_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.medical_records_id_seq OWNED BY public.medical_records.id;


--
-- Name: medicines; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.medicines (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    code character varying(100),
    description text,
    unit character varying(50),
    price integer DEFAULT 0,
    created_at timestamp(6) with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted_at timestamp(6) with time zone
);


ALTER TABLE public.medicines OWNER TO postgres;

--
-- Name: medicines_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.medicines_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.medicines_id_seq OWNER TO postgres;

--
-- Name: medicines_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.medicines_id_seq OWNED BY public.medicines.id;


--
-- Name: notifications; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.notifications (
    id integer NOT NULL,
    user_id integer,
    type character varying(100),
    payload jsonb,
    is_read boolean DEFAULT false,
    created_at timestamp(6) with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.notifications OWNER TO postgres;

--
-- Name: notifications_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.notifications_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.notifications_id_seq OWNER TO postgres;

--
-- Name: notifications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.notifications_id_seq OWNED BY public.notifications.id;


--
-- Name: patients; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.patients (
    id integer NOT NULL,
    user_id integer,
    gender character varying(20),
    blood_type character varying(10),
    allergies text,
    emergency_contact jsonb,
    created_at timestamp(6) with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    address text,
    owner_user_id integer,
    full_name character varying(255),
    phone character varying(50),
    email character varying(255),
    dob date,
    occupation character varying(255),
    id_type character varying(50),
    id_number character varying(100),
    nationality character varying(100),
    ethnicity character varying(100),
    id_issue_date date,
    id_issue_place character varying(255),
    zalo boolean DEFAULT false
);


ALTER TABLE public.patients OWNER TO postgres;

--
-- Name: patients_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.patients_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.patients_id_seq OWNER TO postgres;

--
-- Name: patients_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.patients_id_seq OWNED BY public.patients.id;


--
-- Name: prescriptions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.prescriptions (
    id integer NOT NULL,
    appointment_id integer,
    doctor_id integer NOT NULL,
    patient_id integer NOT NULL,
    items jsonb NOT NULL,
    total_amount integer DEFAULT 0,
    status public.prescription_status DEFAULT 'DRAFT'::public.prescription_status NOT NULL,
    created_at timestamp(6) with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    notified_at timestamp(6) with time zone,
    notified_by integer
);


ALTER TABLE public.prescriptions OWNER TO postgres;

--
-- Name: prescriptions_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.prescriptions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.prescriptions_id_seq OWNER TO postgres;

--
-- Name: prescriptions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.prescriptions_id_seq OWNED BY public.prescriptions.id;


--
-- Name: roles; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.roles (
    id integer NOT NULL,
    name character varying(50) NOT NULL,
    description text,
    created_at timestamp(6) with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.roles OWNER TO postgres;

--
-- Name: roles_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.roles_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.roles_id_seq OWNER TO postgres;

--
-- Name: roles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.roles_id_seq OWNED BY public.roles.id;


--
-- Name: rooms; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.rooms (
    id integer NOT NULL,
    name character varying(150) NOT NULL,
    type character varying(100),
    description text,
    capacity integer DEFAULT 1,
    created_at timestamp(6) with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    doctor_id integer,
    deleted_at timestamp(6) with time zone,
    updated_at timestamp(6) with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.rooms OWNER TO postgres;

--
-- Name: rooms_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.rooms_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.rooms_id_seq OWNER TO postgres;

--
-- Name: rooms_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.rooms_id_seq OWNED BY public.rooms.id;


--
-- Name: schedules; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.schedules (
    id integer NOT NULL,
    doctor_id integer NOT NULL,
    room_id integer,
    date date NOT NULL,
    start_time time(6) without time zone NOT NULL,
    end_time time(6) without time zone NOT NULL,
    recurrent_rule character varying(255),
    created_at timestamp(6) with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.schedules OWNER TO postgres;

--
-- Name: schedules_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.schedules_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.schedules_id_seq OWNER TO postgres;

--
-- Name: schedules_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.schedules_id_seq OWNED BY public.schedules.id;


--
-- Name: specialties; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.specialties (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    slug character varying(255),
    description text,
    image_url text,
    created_at timestamp(6) with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted_at timestamp(6) with time zone
);


ALTER TABLE public.specialties OWNER TO postgres;

--
-- Name: specialties_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.specialties_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.specialties_id_seq OWNER TO postgres;

--
-- Name: specialties_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.specialties_id_seq OWNED BY public.specialties.id;


--
-- Name: stocks; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.stocks (
    id integer NOT NULL,
    medicine_id integer NOT NULL,
    batch_number character varying(100),
    expiry_date date,
    quantity integer DEFAULT 0 NOT NULL,
    created_at timestamp(6) with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted_at timestamp(6) with time zone
);


ALTER TABLE public.stocks OWNER TO postgres;

--
-- Name: stocks_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.stocks_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.stocks_id_seq OWNER TO postgres;

--
-- Name: stocks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.stocks_id_seq OWNED BY public.stocks.id;


--
-- Name: suppliers; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.suppliers (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    contact_info jsonb,
    created_at timestamp(6) with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.suppliers OWNER TO postgres;

--
-- Name: suppliers_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.suppliers_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.suppliers_id_seq OWNER TO postgres;

--
-- Name: suppliers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.suppliers_id_seq OWNED BY public.suppliers.id;


--
-- Name: timeslots; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.timeslots (
    id integer NOT NULL,
    doctor_id integer NOT NULL,
    date date NOT NULL,
    start_time time(6) without time zone NOT NULL,
    end_time time(6) without time zone NOT NULL,
    max_patients integer DEFAULT 1,
    booked_count integer DEFAULT 0,
    is_active boolean DEFAULT true,
    created_at timestamp(6) with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.timeslots OWNER TO postgres;

--
-- Name: timeslots_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.timeslots_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.timeslots_id_seq OWNER TO postgres;

--
-- Name: timeslots_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.timeslots_id_seq OWNED BY public.timeslots.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    id integer NOT NULL,
    email character varying(255),
    password character varying(255),
    full_name character varying(255) NOT NULL,
    phone character varying(50),
    dob date,
    avatar_url text,
    is_active boolean DEFAULT true,
    role_id integer NOT NULL,
    created_at timestamp(6) with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted_at timestamp(6) with time zone
);


ALTER TABLE public.users OWNER TO postgres;

--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.users_id_seq OWNER TO postgres;

--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: appointments id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.appointments ALTER COLUMN id SET DEFAULT nextval('public.appointments_id_seq'::regclass);


--
-- Name: audit_logs id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.audit_logs ALTER COLUMN id SET DEFAULT nextval('public.audit_logs_id_seq'::regclass);


--
-- Name: doctor_reviews id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.doctor_reviews ALTER COLUMN id SET DEFAULT nextval('public.doctor_reviews_id_seq'::regclass);


--
-- Name: doctor_specialties id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.doctor_specialties ALTER COLUMN id SET DEFAULT nextval('public.doctor_specialties_id_seq'::regclass);


--
-- Name: doctors id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.doctors ALTER COLUMN id SET DEFAULT nextval('public.doctors_id_seq'::regclass);


--
-- Name: invoices id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.invoices ALTER COLUMN id SET DEFAULT nextval('public.invoices_id_seq'::regclass);


--
-- Name: lab_orders id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.lab_orders ALTER COLUMN id SET DEFAULT nextval('public.lab_orders_id_seq'::regclass);


--
-- Name: medical_records id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.medical_records ALTER COLUMN id SET DEFAULT nextval('public.medical_records_id_seq'::regclass);


--
-- Name: medicines id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.medicines ALTER COLUMN id SET DEFAULT nextval('public.medicines_id_seq'::regclass);


--
-- Name: notifications id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notifications ALTER COLUMN id SET DEFAULT nextval('public.notifications_id_seq'::regclass);


--
-- Name: patients id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patients ALTER COLUMN id SET DEFAULT nextval('public.patients_id_seq'::regclass);


--
-- Name: prescriptions id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.prescriptions ALTER COLUMN id SET DEFAULT nextval('public.prescriptions_id_seq'::regclass);


--
-- Name: roles id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roles ALTER COLUMN id SET DEFAULT nextval('public.roles_id_seq'::regclass);


--
-- Name: rooms id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rooms ALTER COLUMN id SET DEFAULT nextval('public.rooms_id_seq'::regclass);


--
-- Name: schedules id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.schedules ALTER COLUMN id SET DEFAULT nextval('public.schedules_id_seq'::regclass);


--
-- Name: specialties id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.specialties ALTER COLUMN id SET DEFAULT nextval('public.specialties_id_seq'::regclass);


--
-- Name: stocks id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.stocks ALTER COLUMN id SET DEFAULT nextval('public.stocks_id_seq'::regclass);


--
-- Name: suppliers id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.suppliers ALTER COLUMN id SET DEFAULT nextval('public.suppliers_id_seq'::regclass);


--
-- Name: timeslots id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.timeslots ALTER COLUMN id SET DEFAULT nextval('public.timeslots_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Data for Name: _prisma_migrations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public._prisma_migrations (id, checksum, finished_at, migration_name, logs, rolled_back_at, started_at, applied_steps_count) FROM stdin;
1cdfd393-30d5-4b74-a2d4-a5a7c58065f7	f48d736a857abd469a5b1d2241fe999eb3492f2faafb2bbe41986ede019b6026	2025-11-22 04:33:19.691382+07	20251114173212_add_specialties	\N	\N	2025-11-22 04:33:19.391408+07	1
34a3fb7b-6275-48bd-8a35-e25e72bbe6c9	b67c70c806b69318c9cfde9a352374dff816a5514df43fe8169310f8a481b017	2025-11-22 04:33:19.697786+07	20251116093203_add_room_doctorid	\N	\N	2025-11-22 04:33:19.693079+07	1
95498a9c-996c-4e70-95df-614f071d63f6	95e4f1e56352aac64ea09153cd63672caed4c68e624d1d8e53cd1dfd5a0a9c3a	2025-11-22 04:33:19.704593+07	20251116122639_add_doctor_fields	\N	\N	2025-11-22 04:33:19.698972+07	1
beea233e-c0a7-4816-bd64-15c1cd627a2a	61316cb37a9fb24e6d57426e9dfccbc64700a54b88d19d054150921543e2cc9c	2025-11-22 04:33:19.710515+07	20251116_add_address_to_patients	\N	\N	2025-11-22 04:33:19.706447+07	1
a30ea281-7f4a-4fd5-8a7c-14d7962f556c	731b2f001fc055d236f42b05a332eb205c7b2e2176c9ba1df9688a7f14fb11d8	2025-11-22 04:33:19.744556+07	20251118_add_doctor_reviews	\N	\N	2025-11-22 04:33:19.711706+07	1
097c6254-10a9-4fa4-8bfb-b89885eedff7	7ceaaed63f6f6faebe824610090430f73e5a29ad495f828629c536500326fd28	2025-11-22 04:33:19.784757+07	20251118_add_patient_owner_and_fields	\N	\N	2025-11-22 04:33:19.746023+07	1
9ed203db-ca6f-4e00-9baf-741b09906f88	d04852525fd017d784f9662bacaa8261d9ebb2a4b16aee591de00193065a3f03	2025-11-22 04:33:19.80205+07	20251118_add_patient_profile_fields	\N	\N	2025-11-22 04:33:19.786564+07	1
317a87d6-9d57-4f16-9488-e42aff92d1a6	09f52240b52ad909c314c9fa3db01462dbe3a057327e1dbb7f3faa5acddace24	2025-11-22 04:33:19.834293+07	20251120_add_prescription_id	\N	\N	2025-11-22 04:33:19.804115+07	1
967e3d63-1456-410f-b1bb-73147cdc599e	1bd512d58a60db2b1b7a37b37d101aae5f654c9c598e06a8ef592e104d484444	2025-11-22 04:33:19.843198+07	20251121_add_timeslot_unique_constraint	\N	\N	2025-11-22 04:33:19.836348+07	1
c68b783f-77f7-4e0c-abbc-9e5e523a2dc8	d1599454ffcb56306be5bd94eaeca22147c4c40e97c09d1d0c44853ec69bb9d8	2025-11-22 04:35:52.012767+07	20251121213526_add_deleted_at_fields	\N	\N	2025-11-22 04:35:51.9573+07	1
1e938e6b-addd-4195-a394-6763929d82b7	c70d31548dfe0493a92d62369a10c505cf3a84a7b85bce4874594de135aa5b85	2025-11-22 04:35:58.984689+07	20251121213558_	\N	\N	2025-11-22 04:35:58.978045+07	1
83c06f1b-3e2c-495b-81eb-50b71b085c93	f48d736a857abd469a5b1d2241fe999eb3492f2faafb2bbe41986ede019b6026	2025-11-16 16:32:02.03209+07	20251114173212_add_specialties	\N	\N	2025-11-16 16:32:01.931078+07	1
af2eb269-9b62-400c-87be-359cb56fa1d0	d04852525fd017d784f9662bacaa8261d9ebb2a4b16aee591de00193065a3f03	2025-11-18 09:43:21.823217+07	20251118_add_patient_profile_fields	\N	\N	2025-11-18 09:43:21.803905+07	1
462e1fa5-ba10-4ebf-af2e-9928baa7a5ea	b67c70c806b69318c9cfde9a352374dff816a5514df43fe8169310f8a481b017	2025-11-16 16:32:03.412615+07	20251116093203_add_room_doctorid	\N	\N	2025-11-16 16:32:03.409137+07	1
31cbee38-ea0b-4b67-ab49-34104bd02a4d	731b2f001fc055d236f42b05a332eb205c7b2e2176c9ba1df9688a7f14fb11d8	\N	20251118_add_doctor_reviews	A migration failed to apply. New migrations cannot be applied before the error is recovered from. Read more about how to resolve migration issues in a production database: https://pris.ly/d/migrate-resolve\n\nMigration name: 20251118_add_doctor_reviews\n\nDatabase error code: 42P07\n\nDatabase error:\nERROR: relation "doctor_reviews" already exists\n\nDbError { severity: "ERROR", parsed_severity: Some(Error), code: SqlState(E42P07), message: "relation \\"doctor_reviews\\" already exists", detail: None, hint: None, position: None, where_: None, schema: None, table: None, column: None, datatype: None, constraint: None, file: Some("heap.c"), line: Some(1162), routine: Some("heap_create_with_catalog") }\n\n   0: sql_schema_connector::apply_migration::apply_script\n           with migration_name="20251118_add_doctor_reviews"\n             at schema-engine\\connectors\\sql-schema-connector\\src\\apply_migration.rs:106\n   1: schema_core::commands::apply_migrations::Applying migration\n           with migration_name="20251118_add_doctor_reviews"\n             at schema-engine\\core\\src\\commands\\apply_migrations.rs:91\n   2: schema_core::state::ApplyMigrations\n             at schema-engine\\core\\src\\state.rs:226	2025-11-18 01:23:48.615812+07	2025-11-18 01:23:43.509151+07	0
07a1aecd-0694-461a-9327-f8279e805940	95e4f1e56352aac64ea09153cd63672caed4c68e624d1d8e53cd1dfd5a0a9c3a	2025-11-16 19:26:39.283727+07	20251116122639_add_doctor_fields	\N	\N	2025-11-16 19:26:39.277961+07	1
3af19181-786b-48c2-be11-bf7fe5282173	731b2f001fc055d236f42b05a332eb205c7b2e2176c9ba1df9688a7f14fb11d8	2025-11-18 01:23:48.617712+07	20251118_add_doctor_reviews		\N	2025-11-18 01:23:48.617712+07	0
579574b3-8326-485d-9d7b-686288f48154	61316cb37a9fb24e6d57426e9dfccbc64700a54b88d19d054150921543e2cc9c	\N	20251116_add_address_to_patients	A migration failed to apply. New migrations cannot be applied before the error is recovered from. Read more about how to resolve migration issues in a production database: https://pris.ly/d/migrate-resolve\n\nMigration name: 20251116_add_address_to_patients\n\nDatabase error code: 42701\n\nDatabase error:\nERROR: column "address" of relation "patients" already exists\n\nDbError { severity: "ERROR", parsed_severity: Some(Error), code: SqlState(E42701), message: "column \\"address\\" of relation \\"patients\\" already exists", detail: None, hint: None, position: None, where_: None, schema: None, table: None, column: None, datatype: None, constraint: None, file: Some("tablecmds.c"), line: Some(7481), routine: Some("check_for_column_name_collision") }\n\n   0: sql_schema_connector::apply_migration::apply_script\n           with migration_name="20251116_add_address_to_patients"\n             at schema-engine\\connectors\\sql-schema-connector\\src\\apply_migration.rs:106\n   1: schema_core::commands::apply_migrations::Applying migration\n           with migration_name="20251116_add_address_to_patients"\n             at schema-engine\\core\\src\\commands\\apply_migrations.rs:91\n   2: schema_core::state::ApplyMigrations\n             at schema-engine\\core\\src\\state.rs:226	2025-11-18 01:23:15.16992+07	2025-11-18 01:23:05.104359+07	0
364341bb-fe47-4955-a81c-1ded42e7ddc4	7ceaaed63f6f6faebe824610090430f73e5a29ad495f828629c536500326fd28	2025-11-18 08:51:40.741435+07	20251118_add_patient_owner_and_fields		\N	2025-11-18 08:51:40.741435+07	0
e1685a57-4a3e-474f-8eb5-ad1d74270ac5	61316cb37a9fb24e6d57426e9dfccbc64700a54b88d19d054150921543e2cc9c	\N	20251116_add_address_to_patients	A migration failed to apply. New migrations cannot be applied before the error is recovered from. Read more about how to resolve migration issues in a production database: https://pris.ly/d/migrate-resolve\n\nMigration name: 20251116_add_address_to_patients\n\nDatabase error code: 42701\n\nDatabase error:\nERROR: column "address" of relation "patients" already exists\n\nDbError { severity: "ERROR", parsed_severity: Some(Error), code: SqlState(E42701), message: "column \\"address\\" of relation \\"patients\\" already exists", detail: None, hint: None, position: None, where_: None, schema: None, table: None, column: None, datatype: None, constraint: None, file: Some("tablecmds.c"), line: Some(7481), routine: Some("check_for_column_name_collision") }\n\n   0: sql_schema_connector::apply_migration::apply_script\n           with migration_name="20251116_add_address_to_patients"\n             at schema-engine\\connectors\\sql-schema-connector\\src\\apply_migration.rs:106\n   1: schema_core::commands::apply_migrations::Applying migration\n           with migration_name="20251116_add_address_to_patients"\n             at schema-engine\\core\\src\\commands\\apply_migrations.rs:91\n   2: schema_core::state::ApplyMigrations\n             at schema-engine\\core\\src\\state.rs:226	2025-11-18 01:23:38.920176+07	2025-11-18 01:23:24.625615+07	0
005b0807-985f-4c54-9e2b-0a556520ddb3	61316cb37a9fb24e6d57426e9dfccbc64700a54b88d19d054150921543e2cc9c	2025-11-18 01:23:38.924223+07	20251116_add_address_to_patients		\N	2025-11-18 01:23:38.924223+07	0
be9a1792-4f9b-4723-bed5-00c871f62288	09f52240b52ad909c314c9fa3db01462dbe3a057327e1dbb7f3faa5acddace24	2025-11-21 17:47:00.412081+07	20251120_add_prescription_id	\N	\N	2025-11-21 17:47:00.360677+07	1
c5b87cad-d000-42e5-a8b9-23afca5dad8f	ff2a3b947e56da26fb84462e01c255b0b46e0bd6b80d6631f437c08cc5beb0d2	\N	20251121_add_timeslot_unique_constraint	A migration failed to apply. New migrations cannot be applied before the error is recovered from. Read more about how to resolve migration issues in a production database: https://pris.ly/d/migrate-resolve\n\nMigration name: 20251121_add_timeslot_unique_constraint\n\nDatabase error code: 42P07\n\nDatabase error:\nERROR: relation "timeslot_unique" already exists\n\nDbError { severity: "ERROR", parsed_severity: Some(Error), code: SqlState(E42P07), message: "relation \\"timeslot_unique\\" already exists", detail: None, hint: None, position: None, where_: None, schema: None, table: None, column: None, datatype: None, constraint: None, file: Some("index.c"), line: Some(900), routine: Some("index_create") }\n\n   0: sql_schema_connector::apply_migration::apply_script\n           with migration_name="20251121_add_timeslot_unique_constraint"\n             at schema-engine\\connectors\\sql-schema-connector\\src\\apply_migration.rs:106\n   1: schema_core::commands::apply_migrations::Applying migration\n           with migration_name="20251121_add_timeslot_unique_constraint"\n             at schema-engine\\core\\src\\commands\\apply_migrations.rs:91\n   2: schema_core::state::ApplyMigrations\n             at schema-engine\\core\\src\\state.rs:226	2025-11-21 17:47:15.116363+07	2025-11-21 17:47:00.421744+07	0
b1ae5b79-3517-4f12-9f68-6556edec64a2	1bd512d58a60db2b1b7a37b37d101aae5f654c9c598e06a8ef592e104d484444	2025-11-21 17:47:22.028913+07	20251121_add_timeslot_unique_constraint	\N	\N	2025-11-21 17:47:22.00726+07	1
\.


--
-- Data for Name: appointments; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.appointments (id, patient_id, doctor_id, timeslot_id, appointment_date, appointment_time, status, reason, source, created_by, created_at, updated_at) FROM stdin;
1	1	1	1	2025-11-21	01:00:00	COMPLETED	General checkup	web	9	2025-11-22 04:36:59.239+07	2025-11-22 04:36:59.239+07
2	2	1	2	2025-11-21	02:00:00	CONFIRMED	General checkup	web	10	2025-11-22 04:36:59.247+07	2025-11-22 04:36:59.247+07
3	3	1	3	2025-11-21	03:00:00	PENDING	General checkup	web	11	2025-11-22 04:36:59.252+07	2025-11-22 04:36:59.252+07
4	4	1	4	2025-11-21	04:00:00	COMPLETED	General checkup	web	12	2025-11-22 04:36:59.256+07	2025-11-22 04:36:59.256+07
5	5	5	230	2025-11-22	08:00:00	CONFIRMED	General checkup and consultation	web	2	2025-11-22 04:38:58.272392+07	2025-11-22 04:38:58.272392+07
6	5	5	228	2025-11-22	08:40:00	CONFIRMED	General checkup and consultation	web	2	2025-11-22 04:38:58.272392+07	2025-11-22 04:38:58.272392+07
7	5	5	226	2025-11-23	08:20:00	PENDING	General checkup and consultation	web	2	2025-11-22 04:38:58.272392+07	2025-11-22 04:38:58.272392+07
8	5	5	227	2025-11-23	08:00:00	PENDING	General checkup and consultation	web	2	2025-11-22 04:38:58.272392+07	2025-11-22 04:38:58.272392+07
9	5	5	225	2025-11-23	08:40:00	PENDING	General checkup and consultation	web	2	2025-11-22 04:38:58.272392+07	2025-11-22 04:38:58.272392+07
10	5	5	229	2025-11-22	08:20:00	CONFIRMED	General checkup and consultation	web	2	2025-11-22 04:38:58.272392+07	2025-11-22 04:38:58.272392+07
\.


--
-- Data for Name: audit_logs; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.audit_logs (id, user_id, action, meta, created_at) FROM stdin;
1	1	seed:created	{"source": "seed_all.js", "timestamp": "2025-11-21T21:36:59.402Z"}	2025-11-22 04:36:59.404+07
2	2	seed:created	{"source": "seed_all.js", "timestamp": "2025-11-21T21:36:59.406Z"}	2025-11-22 04:36:59.407+07
3	3	seed:created	{"source": "seed_all.js", "timestamp": "2025-11-21T21:36:59.408Z"}	2025-11-22 04:36:59.409+07
4	4	seed:created	{"source": "seed_all.js", "timestamp": "2025-11-21T21:36:59.410Z"}	2025-11-22 04:36:59.411+07
5	5	seed:created	{"source": "seed_all.js", "timestamp": "2025-11-21T21:36:59.411Z"}	2025-11-22 04:36:59.412+07
6	6	seed:created	{"source": "seed_all.js", "timestamp": "2025-11-21T21:36:59.413Z"}	2025-11-22 04:36:59.414+07
7	7	seed:created	{"source": "seed_all.js", "timestamp": "2025-11-21T21:36:59.414Z"}	2025-11-22 04:36:59.415+07
8	8	seed:created	{"source": "seed_all.js", "timestamp": "2025-11-21T21:36:59.416Z"}	2025-11-22 04:36:59.417+07
9	9	seed:created	{"source": "seed_all.js", "timestamp": "2025-11-21T21:36:59.419Z"}	2025-11-22 04:36:59.42+07
10	10	seed:created	{"source": "seed_all.js", "timestamp": "2025-11-21T21:36:59.421Z"}	2025-11-22 04:36:59.422+07
11	11	seed:created	{"source": "seed_all.js", "timestamp": "2025-11-21T21:36:59.423Z"}	2025-11-22 04:36:59.425+07
12	12	seed:created	{"source": "seed_all.js", "timestamp": "2025-11-21T21:36:59.426Z"}	2025-11-22 04:36:59.427+07
\.


--
-- Data for Name: doctor_reviews; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.doctor_reviews (id, doctor_id, patient_id, rating, comment, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: doctor_specialties; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.doctor_specialties (id, doctor_id, specialty_id, created_at) FROM stdin;
1	1	1	2025-11-22 04:36:58.632+07
2	2	2	2025-11-22 04:36:58.637+07
3	3	3	2025-11-22 04:36:58.639+07
4	4	4	2025-11-22 04:36:58.641+07
\.


--
-- Data for Name: doctors; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.doctors (id, user_id, license_number, specialties, bio, consultation_fee, rating, created_at, updated_at, address, gender) FROM stdin;
1	5	LIC-5	\N	\N	200000	4.50	2025-11-22 04:36:58.021+07	2025-11-22 04:36:58.021+07	\N	\N
2	6	LIC-6	\N	\N	200000	4.50	2025-11-22 04:36:58.103+07	2025-11-22 04:36:58.103+07	\N	\N
3	7	LIC-7	\N	\N	200000	4.50	2025-11-22 04:36:58.186+07	2025-11-22 04:36:58.186+07	\N	\N
4	8	LIC-8	\N	\N	200000	4.50	2025-11-22 04:36:58.265+07	2025-11-22 04:36:58.265+07	\N	\N
5	2	LIC-2024-001	{Cardiology,"Internal Medicine"}	Experienced cardiologist with 10+ years of practice	500000	4.80	2025-11-22 04:38:58.24998+07	2025-11-22 04:38:58.24998+07	\N	\N
6	13	LIC-GEN-001	{"General Medicine"}	Experienced specialist in General Medicine	500000	4.50	2025-11-22 04:38:58.365522+07	2025-11-22 04:38:58.365522+07	\N	\N
7	14	LIC-CARD-002	{Cardiology}	Experienced specialist in Cardiology	700000	4.50	2025-11-22 04:38:58.365522+07	2025-11-22 04:38:58.365522+07	\N	\N
8	15	LIC-GAST-003	{Gastroenterology}	Experienced specialist in Gastroenterology	500000	4.50	2025-11-22 04:38:58.365522+07	2025-11-22 04:38:58.365522+07	\N	\N
9	16	LIC-ENDO-004	{Endocrinology}	Experienced specialist in Endocrinology	500000	4.50	2025-11-22 04:38:58.365522+07	2025-11-22 04:38:58.365522+07	\N	\N
10	17	LIC-DERM-005	{Dermatology}	Experienced specialist in Dermatology	500000	4.50	2025-11-22 04:38:58.365522+07	2025-11-22 04:38:58.365522+07	\N	\N
11	18	LIC-ENT-006	{ENT}	Experienced specialist in ENT	500000	4.50	2025-11-22 04:38:58.365522+07	2025-11-22 04:38:58.365522+07	\N	\N
12	19	LIC-PULM-007	{Pulmonology}	Experienced specialist in Pulmonology	600000	4.50	2025-11-22 04:38:58.365522+07	2025-11-22 04:38:58.365522+07	\N	\N
\.


--
-- Data for Name: invoices; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.invoices (id, appointment_id, patient_id, items, subtotal, tax, discount, total, status, paid_at, created_at, updated_at, prescription_id) FROM stdin;
1	1	1	[{"desc": "Consultation", "amount": 200000}, {"desc": "Lab tests", "amount": 150000}, {"desc": "Medicines", "amount": 250000}]	350000	35000	0	660000	PAID	2025-11-22 04:36:59.349+07	2025-11-22 04:36:59.351+07	2025-11-22 04:36:59.351+07	\N
2	2	2	[{"desc": "Consultation", "amount": 200000}, {"desc": "Lab tests", "amount": 150000}, {"desc": "Medicines", "amount": 250000}]	350000	35000	0	660000	UNPAID	\N	2025-11-22 04:36:59.356+07	2025-11-22 04:36:59.356+07	\N
3	3	3	[{"desc": "Consultation", "amount": 200000}, {"desc": "Lab tests", "amount": 150000}, {"desc": "Medicines", "amount": 250000}]	350000	35000	0	660000	UNPAID	\N	2025-11-22 04:36:59.359+07	2025-11-22 04:36:59.359+07	\N
4	4	4	[{"desc": "Consultation", "amount": 200000}, {"desc": "Lab tests", "amount": 150000}, {"desc": "Medicines", "amount": 250000}]	350000	35000	0	660000	PAID	2025-11-22 04:36:59.361+07	2025-11-22 04:36:59.362+07	2025-11-22 04:36:59.362+07	\N
\.


--
-- Data for Name: lab_orders; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.lab_orders (id, appointment_id, patient_id, doctor_id, tests, status, results, created_at, updated_at) FROM stdin;
1	1	1	1	[{"name": "CBC", "status": "completed"}, {"name": "Blood Type", "status": "completed"}]	COMPLETED	{"CBC": "Normal", "BloodType": "O+"}	2025-11-22 04:36:59.335+07	2025-11-22 04:36:59.335+07
2	2	2	1	[{"name": "CBC", "status": "completed"}, {"name": "Blood Type", "status": "completed"}]	COMPLETED	{"CBC": "Normal", "BloodType": "O+"}	2025-11-22 04:36:59.34+07	2025-11-22 04:36:59.34+07
3	3	3	1	[{"name": "CBC", "status": "completed"}, {"name": "Blood Type", "status": "completed"}]	COMPLETED	{"CBC": "Normal", "BloodType": "O+"}	2025-11-22 04:36:59.343+07	2025-11-22 04:36:59.343+07
4	4	4	1	[{"name": "CBC", "status": "completed"}, {"name": "Blood Type", "status": "completed"}]	COMPLETED	{"CBC": "Normal", "BloodType": "O+"}	2025-11-22 04:36:59.346+07	2025-11-22 04:36:59.346+07
\.


--
-- Data for Name: medical_records; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.medical_records (id, appointment_id, patient_id, doctor_id, diagnosis, notes, attachments, created_at, updated_at) FROM stdin;
1	1	1	1	Good health condition	Routine checkup. All vitals normal.	\N	2025-11-22 04:36:59.298+07	2025-11-22 04:36:59.298+07
2	2	2	1	Good health condition	Routine checkup. All vitals normal.	\N	2025-11-22 04:36:59.304+07	2025-11-22 04:36:59.304+07
3	3	3	1	Good health condition	Routine checkup. All vitals normal.	\N	2025-11-22 04:36:59.306+07	2025-11-22 04:36:59.306+07
4	4	4	1	Good health condition	Routine checkup. All vitals normal.	\N	2025-11-22 04:36:59.31+07	2025-11-22 04:36:59.31+07
\.


--
-- Data for Name: medicines; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.medicines (id, name, code, description, unit, price, created_at, updated_at, deleted_at) FROM stdin;
1	Paracetamol	PARA-100	\N	tablet	10000	2025-11-22 04:36:59.261+07	2025-11-22 04:36:59.261+07	\N
2	Ibuprofen	IBU-200	\N	tablet	15000	2025-11-22 04:36:59.272+07	2025-11-22 04:36:59.272+07	\N
3	Amoxicillin	AMOX-500	\N	tablet	25000	2025-11-22 04:36:59.276+07	2025-11-22 04:36:59.276+07	\N
4	Aspirin	ASP-81	\N	tablet	12000	2025-11-22 04:36:59.281+07	2025-11-22 04:36:59.281+07	\N
\.


--
-- Data for Name: notifications; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.notifications (id, user_id, type, payload, is_read, created_at) FROM stdin;
1	1	welcome	{"seeded": true, "message": "Welcome to Clinic Management System"}	f	2025-11-22 04:36:59.369+07
2	2	welcome	{"seeded": true, "message": "Welcome to Clinic Management System"}	f	2025-11-22 04:36:59.373+07
3	3	welcome	{"seeded": true, "message": "Welcome to Clinic Management System"}	f	2025-11-22 04:36:59.377+07
4	4	welcome	{"seeded": true, "message": "Welcome to Clinic Management System"}	f	2025-11-22 04:36:59.379+07
5	5	welcome	{"seeded": true, "message": "Welcome to Clinic Management System"}	f	2025-11-22 04:36:59.382+07
6	6	welcome	{"seeded": true, "message": "Welcome to Clinic Management System"}	f	2025-11-22 04:36:59.385+07
7	7	welcome	{"seeded": true, "message": "Welcome to Clinic Management System"}	f	2025-11-22 04:36:59.388+07
8	8	welcome	{"seeded": true, "message": "Welcome to Clinic Management System"}	f	2025-11-22 04:36:59.39+07
9	9	welcome	{"seeded": true, "message": "Welcome to Clinic Management System"}	f	2025-11-22 04:36:59.393+07
10	10	welcome	{"seeded": true, "message": "Welcome to Clinic Management System"}	f	2025-11-22 04:36:59.395+07
11	11	welcome	{"seeded": true, "message": "Welcome to Clinic Management System"}	f	2025-11-22 04:36:59.397+07
12	12	welcome	{"seeded": true, "message": "Welcome to Clinic Management System"}	f	2025-11-22 04:36:59.399+07
\.


--
-- Data for Name: patients; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.patients (id, user_id, gender, blood_type, allergies, emergency_contact, created_at, updated_at, address, owner_user_id, full_name, phone, email, dob, occupation, id_type, id_number, nationality, ethnicity, id_issue_date, id_issue_place, zalo) FROM stdin;
1	9	M	O+	None	\N	2025-11-22 04:36:58.35+07	2025-11-22 04:36:58.35+07	123 Nguyen Van A, District 1, HCMC	\N	Patient One	0901234567	patient1@example.test	1990-01-15	\N	\N	\N	\N	\N	\N	\N	f
2	10	F	A+	None	\N	2025-11-22 04:36:58.438+07	2025-11-22 04:36:58.438+07	123 Nguyen Van A, District 1, HCMC	\N	Patient Two	0902234567	patient2@example.test	1992-05-20	\N	\N	\N	\N	\N	\N	\N	f
3	11	M	B+	None	\N	2025-11-22 04:36:58.523+07	2025-11-22 04:36:58.523+07	123 Nguyen Van A, District 1, HCMC	\N	Patient Three	0903234567	patient3@example.test	1988-03-10	\N	\N	\N	\N	\N	\N	\N	f
4	12	F	AB+	None	\N	2025-11-22 04:36:58.61+07	2025-11-22 04:36:58.61+07	123 Nguyen Van A, District 1, HCMC	\N	Patient Four	0904234567	patient4@example.test	1995-07-25	\N	\N	\N	\N	\N	\N	\N	f
5	4	Female	A+	Penicillin, Sulfonamides	\N	2025-11-22 04:38:58.268922+07	2025-11-22 04:38:58.268922+07	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	f
\.


--
-- Data for Name: prescriptions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.prescriptions (id, appointment_id, doctor_id, patient_id, items, total_amount, status, created_at, updated_at, notified_at, notified_by) FROM stdin;
1	1	1	1	[{"quantity": 10, "unit_price": 10000, "medicine_id": 1, "medicine_name": "Paracetamol"}, {"quantity": 5, "unit_price": 15000, "medicine_id": 2, "medicine_name": "Ibuprofen"}]	175000	APPROVED	2025-11-22 04:36:59.316+07	2025-11-22 04:36:59.316+07	\N	\N
2	2	1	2	[{"quantity": 10, "unit_price": 10000, "medicine_id": 1, "medicine_name": "Paracetamol"}, {"quantity": 5, "unit_price": 15000, "medicine_id": 2, "medicine_name": "Ibuprofen"}]	175000	APPROVED	2025-11-22 04:36:59.321+07	2025-11-22 04:36:59.321+07	\N	\N
3	3	1	3	[{"quantity": 10, "unit_price": 10000, "medicine_id": 1, "medicine_name": "Paracetamol"}, {"quantity": 5, "unit_price": 15000, "medicine_id": 2, "medicine_name": "Ibuprofen"}]	175000	APPROVED	2025-11-22 04:36:59.325+07	2025-11-22 04:36:59.325+07	\N	\N
4	4	1	4	[{"quantity": 10, "unit_price": 10000, "medicine_id": 1, "medicine_name": "Paracetamol"}, {"quantity": 5, "unit_price": 15000, "medicine_id": 2, "medicine_name": "Ibuprofen"}]	175000	APPROVED	2025-11-22 04:36:59.33+07	2025-11-22 04:36:59.33+07	\N	\N
\.


--
-- Data for Name: roles; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.roles (id, name, description, created_at) FROM stdin;
1	Admin	Administrator	2025-11-22 04:36:57.626+07
2	Doctor	Doctor role	2025-11-22 04:36:57.642+07
3	Receptionist	Reception staff	2025-11-22 04:36:57.644+07
4	Patient	Patient role	2025-11-22 04:36:57.645+07
\.


--
-- Data for Name: rooms; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.rooms (id, name, type, description, capacity, created_at, doctor_id, deleted_at, updated_at) FROM stdin;
1	Phòng bác sĩ 1 - Dr. Nguyen Van A	Doctor	\N	1	2025-11-22 04:36:58.645+07	1	\N	2025-11-22 04:36:58.645+07
2	Phòng bác sĩ 2 - Dr. Tran Thi B	Doctor	\N	1	2025-11-22 04:36:58.648+07	2	\N	2025-11-22 04:36:58.648+07
3	Phòng bác sĩ 3 - Dr. Le Van C	Doctor	\N	1	2025-11-22 04:36:58.652+07	3	\N	2025-11-22 04:36:58.652+07
4	Phòng bác sĩ 4 - Dr. Pham Thi D	Doctor	\N	1	2025-11-22 04:36:58.655+07	4	\N	2025-11-22 04:36:58.655+07
5	Phòng Lab 1	Lab	\N	5	2025-11-22 04:36:58.657+07	\N	\N	2025-11-22 04:36:58.657+07
6	Phòng Lab 2	Lab	\N	5	2025-11-22 04:36:58.659+07	\N	\N	2025-11-22 04:36:58.659+07
7	Quầy lễ tân 1	Reception	\N	10	2025-11-22 04:36:58.661+07	\N	\N	2025-11-22 04:36:58.661+07
8	Quầy lễ tân 2	Reception	\N	10	2025-11-22 04:36:58.662+07	\N	\N	2025-11-22 04:36:58.662+07
\.


--
-- Data for Name: schedules; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.schedules (id, doctor_id, room_id, date, start_time, end_time, recurrent_rule, created_at) FROM stdin;
1	1	1	2025-11-21	01:00:00	10:00:00	\N	2025-11-22 04:36:58.668+07
2	1	1	2025-11-22	01:00:00	10:00:00	\N	2025-11-22 04:36:58.695+07
3	1	1	2025-11-23	01:00:00	10:00:00	\N	2025-11-22 04:36:58.713+07
4	1	1	2025-11-24	01:00:00	10:00:00	\N	2025-11-22 04:36:58.731+07
5	1	1	2025-11-25	01:00:00	10:00:00	\N	2025-11-22 04:36:58.748+07
6	1	1	2025-11-26	01:00:00	10:00:00	\N	2025-11-22 04:36:58.763+07
7	1	1	2025-11-27	01:00:00	10:00:00	\N	2025-11-22 04:36:58.78+07
8	2	2	2025-11-21	01:00:00	10:00:00	\N	2025-11-22 04:36:58.799+07
9	2	2	2025-11-22	01:00:00	10:00:00	\N	2025-11-22 04:36:58.818+07
10	2	2	2025-11-23	01:00:00	10:00:00	\N	2025-11-22 04:36:58.838+07
11	2	2	2025-11-24	01:00:00	10:00:00	\N	2025-11-22 04:36:58.856+07
12	2	2	2025-11-25	01:00:00	10:00:00	\N	2025-11-22 04:36:58.874+07
13	2	2	2025-11-26	01:00:00	10:00:00	\N	2025-11-22 04:36:58.896+07
14	2	2	2025-11-27	01:00:00	10:00:00	\N	2025-11-22 04:36:58.917+07
15	3	3	2025-11-21	01:00:00	10:00:00	\N	2025-11-22 04:36:58.938+07
16	3	3	2025-11-22	01:00:00	10:00:00	\N	2025-11-22 04:36:58.961+07
17	3	3	2025-11-23	01:00:00	10:00:00	\N	2025-11-22 04:36:58.98+07
18	3	3	2025-11-24	01:00:00	10:00:00	\N	2025-11-22 04:36:58.999+07
19	3	3	2025-11-25	01:00:00	10:00:00	\N	2025-11-22 04:36:59.018+07
20	3	3	2025-11-26	01:00:00	10:00:00	\N	2025-11-22 04:36:59.037+07
21	3	3	2025-11-27	01:00:00	10:00:00	\N	2025-11-22 04:36:59.056+07
22	4	4	2025-11-21	01:00:00	10:00:00	\N	2025-11-22 04:36:59.076+07
23	4	4	2025-11-22	01:00:00	10:00:00	\N	2025-11-22 04:36:59.093+07
24	4	4	2025-11-23	01:00:00	10:00:00	\N	2025-11-22 04:36:59.112+07
25	4	4	2025-11-24	01:00:00	10:00:00	\N	2025-11-22 04:36:59.134+07
26	4	4	2025-11-25	01:00:00	10:00:00	\N	2025-11-22 04:36:59.159+07
27	4	4	2025-11-26	01:00:00	10:00:00	\N	2025-11-22 04:36:59.188+07
28	4	4	2025-11-27	01:00:00	10:00:00	\N	2025-11-22 04:36:59.21+07
29	5	1	2025-11-22	08:00:00	17:00:00	\N	2025-11-22 04:38:58.254804+07
30	5	1	2025-11-23	08:00:00	17:00:00	\N	2025-11-22 04:38:58.254804+07
31	5	1	2025-11-24	08:00:00	17:00:00	\N	2025-11-22 04:38:58.254804+07
32	5	1	2025-11-25	08:00:00	17:00:00	\N	2025-11-22 04:38:58.254804+07
33	5	1	2025-11-26	08:00:00	17:00:00	\N	2025-11-22 04:38:58.254804+07
34	6	1	2025-11-22	09:00:00	12:00:00	\N	2025-11-22 04:38:58.365522+07
35	7	1	2025-11-22	09:00:00	12:00:00	\N	2025-11-22 04:38:58.365522+07
36	8	1	2025-11-22	09:00:00	12:00:00	\N	2025-11-22 04:38:58.365522+07
37	9	1	2025-11-22	09:00:00	12:00:00	\N	2025-11-22 04:38:58.365522+07
38	10	1	2025-11-22	09:00:00	12:00:00	\N	2025-11-22 04:38:58.365522+07
39	11	1	2025-11-22	09:00:00	12:00:00	\N	2025-11-22 04:38:58.365522+07
40	12	1	2025-11-22	09:00:00	12:00:00	\N	2025-11-22 04:38:58.365522+07
\.


--
-- Data for Name: specialties; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.specialties (id, name, slug, description, image_url, created_at, updated_at, deleted_at) FROM stdin;
1	General	general	\N	\N	2025-11-22 04:36:58.615+07	2025-11-22 04:36:58.615+07	\N
2	Cardiology	cardiology	\N	\N	2025-11-22 04:36:58.619+07	2025-11-22 04:36:58.619+07	\N
3	Dermatology	dermatology	\N	\N	2025-11-22 04:36:58.622+07	2025-11-22 04:36:58.622+07	\N
4	Pediatrics	pediatrics	\N	\N	2025-11-22 04:36:58.624+07	2025-11-22 04:36:58.624+07	\N
5	Orthopedics	orthopedics	\N	\N	2025-11-22 04:36:58.626+07	2025-11-22 04:36:58.626+07	\N
\.


--
-- Data for Name: stocks; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.stocks (id, medicine_id, batch_number, expiry_date, quantity, created_at, updated_at, deleted_at) FROM stdin;
1	1	BATCH-001	2026-12-30	100	2025-11-22 04:36:59.267+07	2025-11-22 04:36:59.267+07	\N
2	2	BATCH-001	2026-12-30	100	2025-11-22 04:36:59.274+07	2025-11-22 04:36:59.274+07	\N
3	3	BATCH-001	2026-12-30	100	2025-11-22 04:36:59.279+07	2025-11-22 04:36:59.279+07	\N
4	4	BATCH-001	2026-12-30	100	2025-11-22 04:36:59.282+07	2025-11-22 04:36:59.282+07	\N
\.


--
-- Data for Name: suppliers; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.suppliers (id, name, contact_info, created_at) FROM stdin;
1	ABC Pharma	{"phone": "0123456789"}	2025-11-22 04:36:59.287+07
2	XYZ Medical Supply	{"phone": "0987654321"}	2025-11-22 04:36:59.291+07
3	Global Healthcare	{"phone": "0111222333"}	2025-11-22 04:36:59.293+07
\.


--
-- Data for Name: timeslots; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.timeslots (id, doctor_id, date, start_time, end_time, max_patients, booked_count, is_active, created_at, updated_at) FROM stdin;
5	1	2025-11-21	06:00:00	07:00:00	1	0	t	2025-11-22 04:36:58.686+07	2025-11-22 04:36:58.686+07
6	1	2025-11-21	07:00:00	08:00:00	1	0	t	2025-11-22 04:36:58.689+07	2025-11-22 04:36:58.689+07
7	1	2025-11-21	08:00:00	09:00:00	1	0	t	2025-11-22 04:36:58.691+07	2025-11-22 04:36:58.691+07
8	1	2025-11-21	09:00:00	10:00:00	1	0	t	2025-11-22 04:36:58.693+07	2025-11-22 04:36:58.693+07
9	1	2025-11-22	01:00:00	02:00:00	1	0	t	2025-11-22 04:36:58.697+07	2025-11-22 04:36:58.697+07
10	1	2025-11-22	02:00:00	03:00:00	1	0	t	2025-11-22 04:36:58.699+07	2025-11-22 04:36:58.699+07
11	1	2025-11-22	03:00:00	04:00:00	1	0	t	2025-11-22 04:36:58.701+07	2025-11-22 04:36:58.701+07
12	1	2025-11-22	04:00:00	05:00:00	1	0	t	2025-11-22 04:36:58.703+07	2025-11-22 04:36:58.703+07
13	1	2025-11-22	06:00:00	07:00:00	1	0	t	2025-11-22 04:36:58.705+07	2025-11-22 04:36:58.705+07
14	1	2025-11-22	07:00:00	08:00:00	1	0	t	2025-11-22 04:36:58.707+07	2025-11-22 04:36:58.707+07
15	1	2025-11-22	08:00:00	09:00:00	1	0	t	2025-11-22 04:36:58.709+07	2025-11-22 04:36:58.709+07
16	1	2025-11-22	09:00:00	10:00:00	1	0	t	2025-11-22 04:36:58.711+07	2025-11-22 04:36:58.711+07
17	1	2025-11-23	01:00:00	02:00:00	1	0	t	2025-11-22 04:36:58.715+07	2025-11-22 04:36:58.715+07
18	1	2025-11-23	02:00:00	03:00:00	1	0	t	2025-11-22 04:36:58.718+07	2025-11-22 04:36:58.718+07
19	1	2025-11-23	03:00:00	04:00:00	1	0	t	2025-11-22 04:36:58.72+07	2025-11-22 04:36:58.72+07
20	1	2025-11-23	04:00:00	05:00:00	1	0	t	2025-11-22 04:36:58.721+07	2025-11-22 04:36:58.721+07
21	1	2025-11-23	06:00:00	07:00:00	1	0	t	2025-11-22 04:36:58.722+07	2025-11-22 04:36:58.722+07
22	1	2025-11-23	07:00:00	08:00:00	1	0	t	2025-11-22 04:36:58.724+07	2025-11-22 04:36:58.724+07
23	1	2025-11-23	08:00:00	09:00:00	1	0	t	2025-11-22 04:36:58.727+07	2025-11-22 04:36:58.727+07
24	1	2025-11-23	09:00:00	10:00:00	1	0	t	2025-11-22 04:36:58.729+07	2025-11-22 04:36:58.729+07
25	1	2025-11-24	01:00:00	02:00:00	1	0	t	2025-11-22 04:36:58.733+07	2025-11-22 04:36:58.733+07
26	1	2025-11-24	02:00:00	03:00:00	1	0	t	2025-11-22 04:36:58.735+07	2025-11-22 04:36:58.735+07
27	1	2025-11-24	03:00:00	04:00:00	1	0	t	2025-11-22 04:36:58.737+07	2025-11-22 04:36:58.737+07
28	1	2025-11-24	04:00:00	05:00:00	1	0	t	2025-11-22 04:36:58.738+07	2025-11-22 04:36:58.738+07
29	1	2025-11-24	06:00:00	07:00:00	1	0	t	2025-11-22 04:36:58.74+07	2025-11-22 04:36:58.74+07
30	1	2025-11-24	07:00:00	08:00:00	1	0	t	2025-11-22 04:36:58.741+07	2025-11-22 04:36:58.741+07
31	1	2025-11-24	08:00:00	09:00:00	1	0	t	2025-11-22 04:36:58.743+07	2025-11-22 04:36:58.743+07
32	1	2025-11-24	09:00:00	10:00:00	1	0	t	2025-11-22 04:36:58.745+07	2025-11-22 04:36:58.745+07
33	1	2025-11-25	01:00:00	02:00:00	1	0	t	2025-11-22 04:36:58.75+07	2025-11-22 04:36:58.75+07
34	1	2025-11-25	02:00:00	03:00:00	1	0	t	2025-11-22 04:36:58.752+07	2025-11-22 04:36:58.752+07
35	1	2025-11-25	03:00:00	04:00:00	1	0	t	2025-11-22 04:36:58.753+07	2025-11-22 04:36:58.753+07
36	1	2025-11-25	04:00:00	05:00:00	1	0	t	2025-11-22 04:36:58.755+07	2025-11-22 04:36:58.755+07
37	1	2025-11-25	06:00:00	07:00:00	1	0	t	2025-11-22 04:36:58.756+07	2025-11-22 04:36:58.756+07
38	1	2025-11-25	07:00:00	08:00:00	1	0	t	2025-11-22 04:36:58.757+07	2025-11-22 04:36:58.757+07
39	1	2025-11-25	08:00:00	09:00:00	1	0	t	2025-11-22 04:36:58.76+07	2025-11-22 04:36:58.76+07
40	1	2025-11-25	09:00:00	10:00:00	1	0	t	2025-11-22 04:36:58.761+07	2025-11-22 04:36:58.761+07
41	1	2025-11-26	01:00:00	02:00:00	1	0	t	2025-11-22 04:36:58.765+07	2025-11-22 04:36:58.765+07
42	1	2025-11-26	02:00:00	03:00:00	1	0	t	2025-11-22 04:36:58.768+07	2025-11-22 04:36:58.768+07
43	1	2025-11-26	03:00:00	04:00:00	1	0	t	2025-11-22 04:36:58.77+07	2025-11-22 04:36:58.77+07
44	1	2025-11-26	04:00:00	05:00:00	1	0	t	2025-11-22 04:36:58.771+07	2025-11-22 04:36:58.771+07
45	1	2025-11-26	06:00:00	07:00:00	1	0	t	2025-11-22 04:36:58.773+07	2025-11-22 04:36:58.773+07
46	1	2025-11-26	07:00:00	08:00:00	1	0	t	2025-11-22 04:36:58.774+07	2025-11-22 04:36:58.774+07
47	1	2025-11-26	08:00:00	09:00:00	1	0	t	2025-11-22 04:36:58.777+07	2025-11-22 04:36:58.777+07
48	1	2025-11-26	09:00:00	10:00:00	1	0	t	2025-11-22 04:36:58.779+07	2025-11-22 04:36:58.779+07
49	1	2025-11-27	01:00:00	02:00:00	1	0	t	2025-11-22 04:36:58.782+07	2025-11-22 04:36:58.782+07
50	1	2025-11-27	02:00:00	03:00:00	1	0	t	2025-11-22 04:36:58.784+07	2025-11-22 04:36:58.784+07
51	1	2025-11-27	03:00:00	04:00:00	1	0	t	2025-11-22 04:36:58.787+07	2025-11-22 04:36:58.787+07
52	1	2025-11-27	04:00:00	05:00:00	1	0	t	2025-11-22 04:36:58.789+07	2025-11-22 04:36:58.789+07
53	1	2025-11-27	06:00:00	07:00:00	1	0	t	2025-11-22 04:36:58.79+07	2025-11-22 04:36:58.79+07
54	1	2025-11-27	07:00:00	08:00:00	1	0	t	2025-11-22 04:36:58.793+07	2025-11-22 04:36:58.793+07
55	1	2025-11-27	08:00:00	09:00:00	1	0	t	2025-11-22 04:36:58.794+07	2025-11-22 04:36:58.794+07
56	1	2025-11-27	09:00:00	10:00:00	1	0	t	2025-11-22 04:36:58.796+07	2025-11-22 04:36:58.796+07
57	2	2025-11-21	01:00:00	02:00:00	1	0	t	2025-11-22 04:36:58.802+07	2025-11-22 04:36:58.802+07
58	2	2025-11-21	02:00:00	03:00:00	1	0	t	2025-11-22 04:36:58.804+07	2025-11-22 04:36:58.804+07
59	2	2025-11-21	03:00:00	04:00:00	1	0	t	2025-11-22 04:36:58.806+07	2025-11-22 04:36:58.806+07
60	2	2025-11-21	04:00:00	05:00:00	1	0	t	2025-11-22 04:36:58.808+07	2025-11-22 04:36:58.808+07
61	2	2025-11-21	06:00:00	07:00:00	1	0	t	2025-11-22 04:36:58.81+07	2025-11-22 04:36:58.81+07
62	2	2025-11-21	07:00:00	08:00:00	1	0	t	2025-11-22 04:36:58.812+07	2025-11-22 04:36:58.812+07
63	2	2025-11-21	08:00:00	09:00:00	1	0	t	2025-11-22 04:36:58.814+07	2025-11-22 04:36:58.814+07
64	2	2025-11-21	09:00:00	10:00:00	1	0	t	2025-11-22 04:36:58.815+07	2025-11-22 04:36:58.815+07
65	2	2025-11-22	01:00:00	02:00:00	1	0	t	2025-11-22 04:36:58.82+07	2025-11-22 04:36:58.82+07
66	2	2025-11-22	02:00:00	03:00:00	1	0	t	2025-11-22 04:36:58.823+07	2025-11-22 04:36:58.823+07
67	2	2025-11-22	03:00:00	04:00:00	1	0	t	2025-11-22 04:36:58.825+07	2025-11-22 04:36:58.825+07
68	2	2025-11-22	04:00:00	05:00:00	1	0	t	2025-11-22 04:36:58.828+07	2025-11-22 04:36:58.828+07
69	2	2025-11-22	06:00:00	07:00:00	1	0	t	2025-11-22 04:36:58.83+07	2025-11-22 04:36:58.83+07
70	2	2025-11-22	07:00:00	08:00:00	1	0	t	2025-11-22 04:36:58.831+07	2025-11-22 04:36:58.831+07
71	2	2025-11-22	08:00:00	09:00:00	1	0	t	2025-11-22 04:36:58.833+07	2025-11-22 04:36:58.833+07
72	2	2025-11-22	09:00:00	10:00:00	1	0	t	2025-11-22 04:36:58.836+07	2025-11-22 04:36:58.836+07
73	2	2025-11-23	01:00:00	02:00:00	1	0	t	2025-11-22 04:36:58.84+07	2025-11-22 04:36:58.84+07
74	2	2025-11-23	02:00:00	03:00:00	1	0	t	2025-11-22 04:36:58.842+07	2025-11-22 04:36:58.842+07
75	2	2025-11-23	03:00:00	04:00:00	1	0	t	2025-11-22 04:36:58.844+07	2025-11-22 04:36:58.844+07
76	2	2025-11-23	04:00:00	05:00:00	1	0	t	2025-11-22 04:36:58.846+07	2025-11-22 04:36:58.846+07
77	2	2025-11-23	06:00:00	07:00:00	1	0	t	2025-11-22 04:36:58.848+07	2025-11-22 04:36:58.848+07
78	2	2025-11-23	07:00:00	08:00:00	1	0	t	2025-11-22 04:36:58.85+07	2025-11-22 04:36:58.85+07
79	2	2025-11-23	08:00:00	09:00:00	1	0	t	2025-11-22 04:36:58.852+07	2025-11-22 04:36:58.852+07
80	2	2025-11-23	09:00:00	10:00:00	1	0	t	2025-11-22 04:36:58.854+07	2025-11-22 04:36:58.854+07
81	2	2025-11-24	01:00:00	02:00:00	1	0	t	2025-11-22 04:36:58.858+07	2025-11-22 04:36:58.858+07
82	2	2025-11-24	02:00:00	03:00:00	1	0	t	2025-11-22 04:36:58.86+07	2025-11-22 04:36:58.86+07
83	2	2025-11-24	03:00:00	04:00:00	1	0	t	2025-11-22 04:36:58.862+07	2025-11-22 04:36:58.862+07
84	2	2025-11-24	04:00:00	05:00:00	1	0	t	2025-11-22 04:36:58.863+07	2025-11-22 04:36:58.863+07
85	2	2025-11-24	06:00:00	07:00:00	1	0	t	2025-11-22 04:36:58.865+07	2025-11-22 04:36:58.865+07
86	2	2025-11-24	07:00:00	08:00:00	1	0	t	2025-11-22 04:36:58.868+07	2025-11-22 04:36:58.868+07
87	2	2025-11-24	08:00:00	09:00:00	1	0	t	2025-11-22 04:36:58.87+07	2025-11-22 04:36:58.87+07
88	2	2025-11-24	09:00:00	10:00:00	1	0	t	2025-11-22 04:36:58.872+07	2025-11-22 04:36:58.872+07
89	2	2025-11-25	01:00:00	02:00:00	1	0	t	2025-11-22 04:36:58.876+07	2025-11-22 04:36:58.876+07
90	2	2025-11-25	02:00:00	03:00:00	1	0	t	2025-11-22 04:36:58.88+07	2025-11-22 04:36:58.88+07
91	2	2025-11-25	03:00:00	04:00:00	1	0	t	2025-11-22 04:36:58.881+07	2025-11-22 04:36:58.881+07
92	2	2025-11-25	04:00:00	05:00:00	1	0	t	2025-11-22 04:36:58.884+07	2025-11-22 04:36:58.884+07
93	2	2025-11-25	06:00:00	07:00:00	1	0	t	2025-11-22 04:36:58.887+07	2025-11-22 04:36:58.887+07
94	2	2025-11-25	07:00:00	08:00:00	1	0	t	2025-11-22 04:36:58.89+07	2025-11-22 04:36:58.89+07
95	2	2025-11-25	08:00:00	09:00:00	1	0	t	2025-11-22 04:36:58.892+07	2025-11-22 04:36:58.892+07
96	2	2025-11-25	09:00:00	10:00:00	1	0	t	2025-11-22 04:36:58.894+07	2025-11-22 04:36:58.894+07
97	2	2025-11-26	01:00:00	02:00:00	1	0	t	2025-11-22 04:36:58.898+07	2025-11-22 04:36:58.898+07
98	2	2025-11-26	02:00:00	03:00:00	1	0	t	2025-11-22 04:36:58.901+07	2025-11-22 04:36:58.901+07
99	2	2025-11-26	03:00:00	04:00:00	1	0	t	2025-11-22 04:36:58.904+07	2025-11-22 04:36:58.904+07
100	2	2025-11-26	04:00:00	05:00:00	1	0	t	2025-11-22 04:36:58.906+07	2025-11-22 04:36:58.906+07
101	2	2025-11-26	06:00:00	07:00:00	1	0	t	2025-11-22 04:36:58.909+07	2025-11-22 04:36:58.909+07
102	2	2025-11-26	07:00:00	08:00:00	1	0	t	2025-11-22 04:36:58.912+07	2025-11-22 04:36:58.912+07
103	2	2025-11-26	08:00:00	09:00:00	1	0	t	2025-11-22 04:36:58.913+07	2025-11-22 04:36:58.913+07
104	2	2025-11-26	09:00:00	10:00:00	1	0	t	2025-11-22 04:36:58.915+07	2025-11-22 04:36:58.915+07
105	2	2025-11-27	01:00:00	02:00:00	1	0	t	2025-11-22 04:36:58.92+07	2025-11-22 04:36:58.92+07
106	2	2025-11-27	02:00:00	03:00:00	1	0	t	2025-11-22 04:36:58.923+07	2025-11-22 04:36:58.923+07
107	2	2025-11-27	03:00:00	04:00:00	1	0	t	2025-11-22 04:36:58.925+07	2025-11-22 04:36:58.925+07
108	2	2025-11-27	04:00:00	05:00:00	1	0	t	2025-11-22 04:36:58.927+07	2025-11-22 04:36:58.927+07
109	2	2025-11-27	06:00:00	07:00:00	1	0	t	2025-11-22 04:36:58.929+07	2025-11-22 04:36:58.929+07
110	2	2025-11-27	07:00:00	08:00:00	1	0	t	2025-11-22 04:36:58.931+07	2025-11-22 04:36:58.931+07
111	2	2025-11-27	08:00:00	09:00:00	1	0	t	2025-11-22 04:36:58.932+07	2025-11-22 04:36:58.932+07
112	2	2025-11-27	09:00:00	10:00:00	1	0	t	2025-11-22 04:36:58.935+07	2025-11-22 04:36:58.935+07
113	3	2025-11-21	01:00:00	02:00:00	1	0	t	2025-11-22 04:36:58.94+07	2025-11-22 04:36:58.94+07
114	3	2025-11-21	02:00:00	03:00:00	1	0	t	2025-11-22 04:36:58.942+07	2025-11-22 04:36:58.942+07
115	3	2025-11-21	03:00:00	04:00:00	1	0	t	2025-11-22 04:36:58.945+07	2025-11-22 04:36:58.945+07
116	3	2025-11-21	04:00:00	05:00:00	1	0	t	2025-11-22 04:36:58.947+07	2025-11-22 04:36:58.947+07
117	3	2025-11-21	06:00:00	07:00:00	1	0	t	2025-11-22 04:36:58.949+07	2025-11-22 04:36:58.949+07
118	3	2025-11-21	07:00:00	08:00:00	1	0	t	2025-11-22 04:36:58.952+07	2025-11-22 04:36:58.952+07
119	3	2025-11-21	08:00:00	09:00:00	1	0	t	2025-11-22 04:36:58.954+07	2025-11-22 04:36:58.954+07
120	3	2025-11-21	09:00:00	10:00:00	1	0	t	2025-11-22 04:36:58.958+07	2025-11-22 04:36:58.958+07
121	3	2025-11-22	01:00:00	02:00:00	1	0	t	2025-11-22 04:36:58.963+07	2025-11-22 04:36:58.963+07
122	3	2025-11-22	02:00:00	03:00:00	1	0	t	2025-11-22 04:36:58.964+07	2025-11-22 04:36:58.964+07
123	3	2025-11-22	03:00:00	04:00:00	1	0	t	2025-11-22 04:36:58.966+07	2025-11-22 04:36:58.966+07
124	3	2025-11-22	04:00:00	05:00:00	1	0	t	2025-11-22 04:36:58.969+07	2025-11-22 04:36:58.969+07
125	3	2025-11-22	06:00:00	07:00:00	1	0	t	2025-11-22 04:36:58.971+07	2025-11-22 04:36:58.971+07
126	3	2025-11-22	07:00:00	08:00:00	1	0	t	2025-11-22 04:36:58.973+07	2025-11-22 04:36:58.973+07
127	3	2025-11-22	08:00:00	09:00:00	1	0	t	2025-11-22 04:36:58.976+07	2025-11-22 04:36:58.976+07
128	3	2025-11-22	09:00:00	10:00:00	1	0	t	2025-11-22 04:36:58.978+07	2025-11-22 04:36:58.978+07
129	3	2025-11-23	01:00:00	02:00:00	1	0	t	2025-11-22 04:36:58.981+07	2025-11-22 04:36:58.981+07
130	3	2025-11-23	02:00:00	03:00:00	1	0	t	2025-11-22 04:36:58.983+07	2025-11-22 04:36:58.983+07
131	3	2025-11-23	03:00:00	04:00:00	1	0	t	2025-11-22 04:36:58.986+07	2025-11-22 04:36:58.986+07
132	3	2025-11-23	04:00:00	05:00:00	1	0	t	2025-11-22 04:36:58.988+07	2025-11-22 04:36:58.988+07
133	3	2025-11-23	06:00:00	07:00:00	1	0	t	2025-11-22 04:36:58.99+07	2025-11-22 04:36:58.99+07
134	3	2025-11-23	07:00:00	08:00:00	1	0	t	2025-11-22 04:36:58.993+07	2025-11-22 04:36:58.993+07
135	3	2025-11-23	08:00:00	09:00:00	1	0	t	2025-11-22 04:36:58.994+07	2025-11-22 04:36:58.994+07
136	3	2025-11-23	09:00:00	10:00:00	1	0	t	2025-11-22 04:36:58.997+07	2025-11-22 04:36:58.997+07
137	3	2025-11-24	01:00:00	02:00:00	1	0	t	2025-11-22 04:36:59.001+07	2025-11-22 04:36:59.001+07
138	3	2025-11-24	02:00:00	03:00:00	1	0	t	2025-11-22 04:36:59.003+07	2025-11-22 04:36:59.003+07
139	3	2025-11-24	03:00:00	04:00:00	1	0	t	2025-11-22 04:36:59.005+07	2025-11-22 04:36:59.005+07
140	3	2025-11-24	04:00:00	05:00:00	1	0	t	2025-11-22 04:36:59.007+07	2025-11-22 04:36:59.007+07
141	3	2025-11-24	06:00:00	07:00:00	1	0	t	2025-11-22 04:36:59.01+07	2025-11-22 04:36:59.01+07
142	3	2025-11-24	07:00:00	08:00:00	1	0	t	2025-11-22 04:36:59.012+07	2025-11-22 04:36:59.012+07
143	3	2025-11-24	08:00:00	09:00:00	1	0	t	2025-11-22 04:36:59.014+07	2025-11-22 04:36:59.014+07
144	3	2025-11-24	09:00:00	10:00:00	1	0	t	2025-11-22 04:36:59.016+07	2025-11-22 04:36:59.016+07
145	3	2025-11-25	01:00:00	02:00:00	1	0	t	2025-11-22 04:36:59.02+07	2025-11-22 04:36:59.02+07
146	3	2025-11-25	02:00:00	03:00:00	1	0	t	2025-11-22 04:36:59.021+07	2025-11-22 04:36:59.021+07
147	3	2025-11-25	03:00:00	04:00:00	1	0	t	2025-11-22 04:36:59.023+07	2025-11-22 04:36:59.023+07
148	3	2025-11-25	04:00:00	05:00:00	1	0	t	2025-11-22 04:36:59.026+07	2025-11-22 04:36:59.026+07
149	3	2025-11-25	06:00:00	07:00:00	1	0	t	2025-11-22 04:36:59.029+07	2025-11-22 04:36:59.029+07
150	3	2025-11-25	07:00:00	08:00:00	1	0	t	2025-11-22 04:36:59.031+07	2025-11-22 04:36:59.031+07
151	3	2025-11-25	08:00:00	09:00:00	1	0	t	2025-11-22 04:36:59.032+07	2025-11-22 04:36:59.032+07
152	3	2025-11-25	09:00:00	10:00:00	1	0	t	2025-11-22 04:36:59.035+07	2025-11-22 04:36:59.035+07
153	3	2025-11-26	01:00:00	02:00:00	1	0	t	2025-11-22 04:36:59.039+07	2025-11-22 04:36:59.039+07
154	3	2025-11-26	02:00:00	03:00:00	1	0	t	2025-11-22 04:36:59.041+07	2025-11-22 04:36:59.041+07
155	3	2025-11-26	03:00:00	04:00:00	1	0	t	2025-11-22 04:36:59.043+07	2025-11-22 04:36:59.043+07
156	3	2025-11-26	04:00:00	05:00:00	1	0	t	2025-11-22 04:36:59.045+07	2025-11-22 04:36:59.045+07
157	3	2025-11-26	06:00:00	07:00:00	1	0	t	2025-11-22 04:36:59.047+07	2025-11-22 04:36:59.047+07
158	3	2025-11-26	07:00:00	08:00:00	1	0	t	2025-11-22 04:36:59.049+07	2025-11-22 04:36:59.049+07
159	3	2025-11-26	08:00:00	09:00:00	1	0	t	2025-11-22 04:36:59.052+07	2025-11-22 04:36:59.052+07
160	3	2025-11-26	09:00:00	10:00:00	1	0	t	2025-11-22 04:36:59.054+07	2025-11-22 04:36:59.054+07
161	3	2025-11-27	01:00:00	02:00:00	1	0	t	2025-11-22 04:36:59.057+07	2025-11-22 04:36:59.057+07
162	3	2025-11-27	02:00:00	03:00:00	1	0	t	2025-11-22 04:36:59.06+07	2025-11-22 04:36:59.06+07
163	3	2025-11-27	03:00:00	04:00:00	1	0	t	2025-11-22 04:36:59.062+07	2025-11-22 04:36:59.062+07
164	3	2025-11-27	04:00:00	05:00:00	1	0	t	2025-11-22 04:36:59.064+07	2025-11-22 04:36:59.064+07
165	3	2025-11-27	06:00:00	07:00:00	1	0	t	2025-11-22 04:36:59.065+07	2025-11-22 04:36:59.065+07
166	3	2025-11-27	07:00:00	08:00:00	1	0	t	2025-11-22 04:36:59.068+07	2025-11-22 04:36:59.068+07
167	3	2025-11-27	08:00:00	09:00:00	1	0	t	2025-11-22 04:36:59.07+07	2025-11-22 04:36:59.07+07
168	3	2025-11-27	09:00:00	10:00:00	1	0	t	2025-11-22 04:36:59.072+07	2025-11-22 04:36:59.072+07
169	4	2025-11-21	01:00:00	02:00:00	1	0	t	2025-11-22 04:36:59.078+07	2025-11-22 04:36:59.078+07
170	4	2025-11-21	02:00:00	03:00:00	1	0	t	2025-11-22 04:36:59.079+07	2025-11-22 04:36:59.079+07
171	4	2025-11-21	03:00:00	04:00:00	1	0	t	2025-11-22 04:36:59.081+07	2025-11-22 04:36:59.081+07
172	4	2025-11-21	04:00:00	05:00:00	1	0	t	2025-11-22 04:36:59.083+07	2025-11-22 04:36:59.083+07
173	4	2025-11-21	06:00:00	07:00:00	1	0	t	2025-11-22 04:36:59.085+07	2025-11-22 04:36:59.085+07
174	4	2025-11-21	07:00:00	08:00:00	1	0	t	2025-11-22 04:36:59.088+07	2025-11-22 04:36:59.088+07
175	4	2025-11-21	08:00:00	09:00:00	1	0	t	2025-11-22 04:36:59.089+07	2025-11-22 04:36:59.089+07
176	4	2025-11-21	09:00:00	10:00:00	1	0	t	2025-11-22 04:36:59.091+07	2025-11-22 04:36:59.091+07
177	4	2025-11-22	01:00:00	02:00:00	1	0	t	2025-11-22 04:36:59.095+07	2025-11-22 04:36:59.095+07
178	4	2025-11-22	02:00:00	03:00:00	1	0	t	2025-11-22 04:36:59.097+07	2025-11-22 04:36:59.097+07
179	4	2025-11-22	03:00:00	04:00:00	1	0	t	2025-11-22 04:36:59.099+07	2025-11-22 04:36:59.099+07
180	4	2025-11-22	04:00:00	05:00:00	1	0	t	2025-11-22 04:36:59.103+07	2025-11-22 04:36:59.103+07
181	4	2025-11-22	06:00:00	07:00:00	1	0	t	2025-11-22 04:36:59.105+07	2025-11-22 04:36:59.105+07
182	4	2025-11-22	07:00:00	08:00:00	1	0	t	2025-11-22 04:36:59.107+07	2025-11-22 04:36:59.107+07
183	4	2025-11-22	08:00:00	09:00:00	1	0	t	2025-11-22 04:36:59.11+07	2025-11-22 04:36:59.11+07
184	4	2025-11-22	09:00:00	10:00:00	1	0	t	2025-11-22 04:36:59.111+07	2025-11-22 04:36:59.111+07
185	4	2025-11-23	01:00:00	02:00:00	1	0	t	2025-11-22 04:36:59.114+07	2025-11-22 04:36:59.114+07
186	4	2025-11-23	02:00:00	03:00:00	1	0	t	2025-11-22 04:36:59.117+07	2025-11-22 04:36:59.117+07
187	4	2025-11-23	03:00:00	04:00:00	1	0	t	2025-11-22 04:36:59.119+07	2025-11-22 04:36:59.119+07
188	4	2025-11-23	04:00:00	05:00:00	1	0	t	2025-11-22 04:36:59.122+07	2025-11-22 04:36:59.122+07
189	4	2025-11-23	06:00:00	07:00:00	1	0	t	2025-11-22 04:36:59.123+07	2025-11-22 04:36:59.123+07
190	4	2025-11-23	07:00:00	08:00:00	1	0	t	2025-11-22 04:36:59.126+07	2025-11-22 04:36:59.126+07
191	4	2025-11-23	08:00:00	09:00:00	1	0	t	2025-11-22 04:36:59.128+07	2025-11-22 04:36:59.128+07
192	4	2025-11-23	09:00:00	10:00:00	1	0	t	2025-11-22 04:36:59.131+07	2025-11-22 04:36:59.131+07
193	4	2025-11-24	01:00:00	02:00:00	1	0	t	2025-11-22 04:36:59.137+07	2025-11-22 04:36:59.137+07
194	4	2025-11-24	02:00:00	03:00:00	1	0	t	2025-11-22 04:36:59.139+07	2025-11-22 04:36:59.139+07
195	4	2025-11-24	03:00:00	04:00:00	1	0	t	2025-11-22 04:36:59.141+07	2025-11-22 04:36:59.141+07
196	4	2025-11-24	04:00:00	05:00:00	1	0	t	2025-11-22 04:36:59.144+07	2025-11-22 04:36:59.144+07
197	4	2025-11-24	06:00:00	07:00:00	1	0	t	2025-11-22 04:36:59.147+07	2025-11-22 04:36:59.147+07
198	4	2025-11-24	07:00:00	08:00:00	1	0	t	2025-11-22 04:36:59.149+07	2025-11-22 04:36:59.149+07
199	4	2025-11-24	08:00:00	09:00:00	1	0	t	2025-11-22 04:36:59.153+07	2025-11-22 04:36:59.153+07
200	4	2025-11-24	09:00:00	10:00:00	1	0	t	2025-11-22 04:36:59.156+07	2025-11-22 04:36:59.156+07
201	4	2025-11-25	01:00:00	02:00:00	1	0	t	2025-11-22 04:36:59.162+07	2025-11-22 04:36:59.162+07
202	4	2025-11-25	02:00:00	03:00:00	1	0	t	2025-11-22 04:36:59.165+07	2025-11-22 04:36:59.165+07
203	4	2025-11-25	03:00:00	04:00:00	1	0	t	2025-11-22 04:36:59.169+07	2025-11-22 04:36:59.169+07
204	4	2025-11-25	04:00:00	05:00:00	1	0	t	2025-11-22 04:36:59.172+07	2025-11-22 04:36:59.172+07
205	4	2025-11-25	06:00:00	07:00:00	1	0	t	2025-11-22 04:36:59.175+07	2025-11-22 04:36:59.175+07
206	4	2025-11-25	07:00:00	08:00:00	1	0	t	2025-11-22 04:36:59.179+07	2025-11-22 04:36:59.179+07
207	4	2025-11-25	08:00:00	09:00:00	1	0	t	2025-11-22 04:36:59.182+07	2025-11-22 04:36:59.182+07
208	4	2025-11-25	09:00:00	10:00:00	1	0	t	2025-11-22 04:36:59.185+07	2025-11-22 04:36:59.185+07
209	4	2025-11-26	01:00:00	02:00:00	1	0	t	2025-11-22 04:36:59.19+07	2025-11-22 04:36:59.19+07
210	4	2025-11-26	02:00:00	03:00:00	1	0	t	2025-11-22 04:36:59.194+07	2025-11-22 04:36:59.194+07
211	4	2025-11-26	03:00:00	04:00:00	1	0	t	2025-11-22 04:36:59.196+07	2025-11-22 04:36:59.196+07
212	4	2025-11-26	04:00:00	05:00:00	1	0	t	2025-11-22 04:36:59.198+07	2025-11-22 04:36:59.198+07
213	4	2025-11-26	06:00:00	07:00:00	1	0	t	2025-11-22 04:36:59.201+07	2025-11-22 04:36:59.201+07
214	4	2025-11-26	07:00:00	08:00:00	1	0	t	2025-11-22 04:36:59.204+07	2025-11-22 04:36:59.204+07
215	4	2025-11-26	08:00:00	09:00:00	1	0	t	2025-11-22 04:36:59.205+07	2025-11-22 04:36:59.205+07
216	4	2025-11-26	09:00:00	10:00:00	1	0	t	2025-11-22 04:36:59.208+07	2025-11-22 04:36:59.208+07
217	4	2025-11-27	01:00:00	02:00:00	1	0	t	2025-11-22 04:36:59.212+07	2025-11-22 04:36:59.212+07
218	4	2025-11-27	02:00:00	03:00:00	1	0	t	2025-11-22 04:36:59.214+07	2025-11-22 04:36:59.214+07
219	4	2025-11-27	03:00:00	04:00:00	1	0	t	2025-11-22 04:36:59.217+07	2025-11-22 04:36:59.217+07
220	4	2025-11-27	04:00:00	05:00:00	1	0	t	2025-11-22 04:36:59.219+07	2025-11-22 04:36:59.219+07
221	4	2025-11-27	06:00:00	07:00:00	1	0	t	2025-11-22 04:36:59.221+07	2025-11-22 04:36:59.221+07
222	4	2025-11-27	07:00:00	08:00:00	1	0	t	2025-11-22 04:36:59.224+07	2025-11-22 04:36:59.224+07
223	4	2025-11-27	08:00:00	09:00:00	1	0	t	2025-11-22 04:36:59.228+07	2025-11-22 04:36:59.228+07
224	4	2025-11-27	09:00:00	10:00:00	1	0	t	2025-11-22 04:36:59.23+07	2025-11-22 04:36:59.23+07
231	5	2025-11-23	09:40:00	10:00:00	1	0	t	2025-11-22 04:38:58.26035+07	2025-11-22 04:38:58.26035+07
232	5	2025-11-23	09:20:00	09:40:00	1	0	t	2025-11-22 04:38:58.26035+07	2025-11-22 04:38:58.26035+07
233	5	2025-11-23	09:00:00	09:20:00	1	0	t	2025-11-22 04:38:58.26035+07	2025-11-22 04:38:58.26035+07
234	5	2025-11-22	09:40:00	10:00:00	1	0	t	2025-11-22 04:38:58.26035+07	2025-11-22 04:38:58.26035+07
235	5	2025-11-22	09:20:00	09:40:00	1	0	t	2025-11-22 04:38:58.26035+07	2025-11-22 04:38:58.26035+07
236	5	2025-11-22	09:00:00	09:20:00	1	0	t	2025-11-22 04:38:58.26035+07	2025-11-22 04:38:58.26035+07
237	5	2025-11-23	10:40:00	11:00:00	1	0	t	2025-11-22 04:38:58.26035+07	2025-11-22 04:38:58.26035+07
238	5	2025-11-23	10:20:00	10:40:00	1	0	t	2025-11-22 04:38:58.26035+07	2025-11-22 04:38:58.26035+07
239	5	2025-11-23	10:00:00	10:20:00	1	0	t	2025-11-22 04:38:58.26035+07	2025-11-22 04:38:58.26035+07
240	5	2025-11-22	10:40:00	11:00:00	1	0	t	2025-11-22 04:38:58.26035+07	2025-11-22 04:38:58.26035+07
241	5	2025-11-22	10:20:00	10:40:00	1	0	t	2025-11-22 04:38:58.26035+07	2025-11-22 04:38:58.26035+07
242	5	2025-11-22	10:00:00	10:20:00	1	0	t	2025-11-22 04:38:58.26035+07	2025-11-22 04:38:58.26035+07
243	5	2025-11-23	11:40:00	12:00:00	1	0	t	2025-11-22 04:38:58.26035+07	2025-11-22 04:38:58.26035+07
244	5	2025-11-23	11:20:00	11:40:00	1	0	t	2025-11-22 04:38:58.26035+07	2025-11-22 04:38:58.26035+07
245	5	2025-11-23	11:00:00	11:20:00	1	0	t	2025-11-22 04:38:58.26035+07	2025-11-22 04:38:58.26035+07
246	5	2025-11-22	11:40:00	12:00:00	1	0	t	2025-11-22 04:38:58.26035+07	2025-11-22 04:38:58.26035+07
247	5	2025-11-22	11:20:00	11:40:00	1	0	t	2025-11-22 04:38:58.26035+07	2025-11-22 04:38:58.26035+07
248	5	2025-11-22	11:00:00	11:20:00	1	0	t	2025-11-22 04:38:58.26035+07	2025-11-22 04:38:58.26035+07
249	5	2025-11-23	12:40:00	13:00:00	1	0	t	2025-11-22 04:38:58.26035+07	2025-11-22 04:38:58.26035+07
250	5	2025-11-23	12:20:00	12:40:00	1	0	t	2025-11-22 04:38:58.26035+07	2025-11-22 04:38:58.26035+07
251	5	2025-11-23	12:00:00	12:20:00	1	0	t	2025-11-22 04:38:58.26035+07	2025-11-22 04:38:58.26035+07
252	5	2025-11-22	12:40:00	13:00:00	1	0	t	2025-11-22 04:38:58.26035+07	2025-11-22 04:38:58.26035+07
253	5	2025-11-22	12:20:00	12:40:00	1	0	t	2025-11-22 04:38:58.26035+07	2025-11-22 04:38:58.26035+07
254	5	2025-11-22	12:00:00	12:20:00	1	0	t	2025-11-22 04:38:58.26035+07	2025-11-22 04:38:58.26035+07
255	5	2025-11-23	13:40:00	14:00:00	1	0	t	2025-11-22 04:38:58.26035+07	2025-11-22 04:38:58.26035+07
256	5	2025-11-23	13:20:00	13:40:00	1	0	t	2025-11-22 04:38:58.26035+07	2025-11-22 04:38:58.26035+07
257	5	2025-11-23	13:00:00	13:20:00	1	0	t	2025-11-22 04:38:58.26035+07	2025-11-22 04:38:58.26035+07
258	5	2025-11-22	13:40:00	14:00:00	1	0	t	2025-11-22 04:38:58.26035+07	2025-11-22 04:38:58.26035+07
259	5	2025-11-22	13:20:00	13:40:00	1	0	t	2025-11-22 04:38:58.26035+07	2025-11-22 04:38:58.26035+07
260	5	2025-11-22	13:00:00	13:20:00	1	0	t	2025-11-22 04:38:58.26035+07	2025-11-22 04:38:58.26035+07
261	5	2025-11-23	14:40:00	15:00:00	1	0	t	2025-11-22 04:38:58.26035+07	2025-11-22 04:38:58.26035+07
262	5	2025-11-23	14:20:00	14:40:00	1	0	t	2025-11-22 04:38:58.26035+07	2025-11-22 04:38:58.26035+07
263	5	2025-11-23	14:00:00	14:20:00	1	0	t	2025-11-22 04:38:58.26035+07	2025-11-22 04:38:58.26035+07
264	5	2025-11-22	14:40:00	15:00:00	1	0	t	2025-11-22 04:38:58.26035+07	2025-11-22 04:38:58.26035+07
265	5	2025-11-22	14:20:00	14:40:00	1	0	t	2025-11-22 04:38:58.26035+07	2025-11-22 04:38:58.26035+07
266	5	2025-11-22	14:00:00	14:20:00	1	0	t	2025-11-22 04:38:58.26035+07	2025-11-22 04:38:58.26035+07
267	5	2025-11-23	15:40:00	16:00:00	1	0	t	2025-11-22 04:38:58.26035+07	2025-11-22 04:38:58.26035+07
268	5	2025-11-23	15:20:00	15:40:00	1	0	t	2025-11-22 04:38:58.26035+07	2025-11-22 04:38:58.26035+07
269	5	2025-11-23	15:00:00	15:20:00	1	0	t	2025-11-22 04:38:58.26035+07	2025-11-22 04:38:58.26035+07
270	5	2025-11-22	15:40:00	16:00:00	1	0	t	2025-11-22 04:38:58.26035+07	2025-11-22 04:38:58.26035+07
271	5	2025-11-22	15:20:00	15:40:00	1	0	t	2025-11-22 04:38:58.26035+07	2025-11-22 04:38:58.26035+07
272	5	2025-11-22	15:00:00	15:20:00	1	0	t	2025-11-22 04:38:58.26035+07	2025-11-22 04:38:58.26035+07
273	5	2025-11-23	16:40:00	17:00:00	1	0	t	2025-11-22 04:38:58.26035+07	2025-11-22 04:38:58.26035+07
274	5	2025-11-23	16:20:00	16:40:00	1	0	t	2025-11-22 04:38:58.26035+07	2025-11-22 04:38:58.26035+07
275	5	2025-11-23	16:00:00	16:20:00	1	0	t	2025-11-22 04:38:58.26035+07	2025-11-22 04:38:58.26035+07
276	5	2025-11-22	16:40:00	17:00:00	1	0	t	2025-11-22 04:38:58.26035+07	2025-11-22 04:38:58.26035+07
277	5	2025-11-22	16:20:00	16:40:00	1	0	t	2025-11-22 04:38:58.26035+07	2025-11-22 04:38:58.26035+07
278	5	2025-11-22	16:00:00	16:20:00	1	0	t	2025-11-22 04:38:58.26035+07	2025-11-22 04:38:58.26035+07
1	1	2025-11-21	01:00:00	02:00:00	1	1	t	2025-11-22 04:36:58.675+07	2025-11-22 04:36:58.675+07
2	1	2025-11-21	02:00:00	03:00:00	1	1	t	2025-11-22 04:36:58.679+07	2025-11-22 04:36:58.679+07
3	1	2025-11-21	03:00:00	04:00:00	1	1	t	2025-11-22 04:36:58.682+07	2025-11-22 04:36:58.682+07
4	1	2025-11-21	04:00:00	05:00:00	1	1	t	2025-11-22 04:36:58.684+07	2025-11-22 04:36:58.684+07
225	5	2025-11-23	08:40:00	09:00:00	1	1	t	2025-11-22 04:38:58.26035+07	2025-11-22 04:38:58.26035+07
226	5	2025-11-23	08:20:00	08:40:00	1	1	t	2025-11-22 04:38:58.26035+07	2025-11-22 04:38:58.26035+07
227	5	2025-11-23	08:00:00	08:20:00	1	1	t	2025-11-22 04:38:58.26035+07	2025-11-22 04:38:58.26035+07
228	5	2025-11-22	08:40:00	09:00:00	1	1	t	2025-11-22 04:38:58.26035+07	2025-11-22 04:38:58.26035+07
229	5	2025-11-22	08:20:00	08:40:00	1	1	t	2025-11-22 04:38:58.26035+07	2025-11-22 04:38:58.26035+07
230	5	2025-11-22	08:00:00	08:20:00	1	1	t	2025-11-22 04:38:58.26035+07	2025-11-22 04:38:58.26035+07
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, email, password, full_name, phone, dob, avatar_url, is_active, role_id, created_at, updated_at, deleted_at) FROM stdin;
1	admin@example.com	$2a$10$H29hQbEuk4WJbwzoo.VI/u6vwiC4CVO20st1i.0Js825wCLQ7BHQa	Administrator	\N	\N	\N	t	1	2025-11-22 04:36:57.721+07	2025-11-22 04:36:57.721+07	\N
2	doctor@example.com	$2a$10$kdmUulVY6KOLJcez8kCzRu/mQXc7w69e7wUS2llnibEVk3C34dP..	Doctor Account	\N	\N	\N	t	2	2025-11-22 04:36:57.794+07	2025-11-22 04:36:57.794+07	\N
3	reception@example.com	$2a$10$uO/9lfI8XcIeNailjDVpR.lBD//.hu42mP/3gaCRth44/P4hJ/cee	Reception Account	\N	\N	\N	t	3	2025-11-22 04:36:57.865+07	2025-11-22 04:36:57.865+07	\N
4	patient@example.com	$2a$10$lkXDvosWSM1AEDMZVgJDeeSFaE4BlGPPxhogZHeNHX0p9QcCFBAH.	Patient Account	\N	\N	\N	t	4	2025-11-22 04:36:57.938+07	2025-11-22 04:36:57.938+07	\N
5	dr1@example.test	$2a$10$Xh7MxjFslxO0HzPgiYABQuVfL.GlFEVnGkbedq32.8k4bEpPDtZta	Dr. Nguyen Van A	\N	\N	\N	t	2	2025-11-22 04:36:58.014+07	2025-11-22 04:36:58.014+07	\N
6	dr2@example.test	$2a$10$5rhz.ZLlvImFGDUaeQaReu4okDRlyBvEoT.oXffIygzAVURuVXySm	Dr. Tran Thi B	\N	\N	\N	t	2	2025-11-22 04:36:58.1+07	2025-11-22 04:36:58.1+07	\N
7	dr3@example.test	$2a$10$pleZvqa49cDOKDp8KT1FjO/Hc9mkkyR5O22N3mCz3.PDz0BUW8cKC	Dr. Le Van C	\N	\N	\N	t	2	2025-11-22 04:36:58.183+07	2025-11-22 04:36:58.183+07	\N
8	dr4@example.test	$2a$10$LYbfmuSEev3PDIuXvkIWr.Wbp70Zc8uwGegdWsO8llspKiF0ZUsC6	Dr. Pham Thi D	\N	\N	\N	t	2	2025-11-22 04:36:58.263+07	2025-11-22 04:36:58.263+07	\N
9	patient1@example.test	$2a$10$DVZzIbWL4fi9cE2U5OxxtecL91rhb80zc5bVlyzyV6WAt2tguJKuG	Patient One	\N	\N	\N	t	4	2025-11-22 04:36:58.344+07	2025-11-22 04:36:58.344+07	\N
10	patient2@example.test	$2a$10$p4fO6r4SVb8XiKuJgpHx0eEgF4rGqZd.RphvnYuqjREnBnXCAKoOq	Patient Two	\N	\N	\N	t	4	2025-11-22 04:36:58.433+07	2025-11-22 04:36:58.433+07	\N
11	patient3@example.test	$2a$10$2PmOXdxWhTfrPq8WOjS6J.X8N7Zur/BWfgNIcfQBeyTY46EnA46i.	Patient Three	\N	\N	\N	t	4	2025-11-22 04:36:58.52+07	2025-11-22 04:36:58.52+07	\N
12	patient4@example.test	$2a$10$nEiUNUmy5inmrt4UVJpa4uDSJiW.830hXxbkIBEpQXdqKMk0hYelm	Patient Four	\N	\N	\N	t	4	2025-11-22 04:36:58.606+07	2025-11-22 04:36:58.606+07	\N
13	general.med@example.com	$2b$12$7DJh87RcG3x/wHJMP6Baqes54G6xteskbF/JvuKotfH/J.3sTgJiW	Dr. Nguyen Van A	+84000000000	\N	\N	t	2	2025-11-22 04:38:58.365522+07	2025-11-22 04:38:58.365522+07	\N
14	cardio@example.com	$2b$12$7DJh87RcG3x/wHJMP6Baqes54G6xteskbF/JvuKotfH/J.3sTgJiW	Dr. Tran Thi B	+84000000000	\N	\N	t	2	2025-11-22 04:38:58.365522+07	2025-11-22 04:38:58.365522+07	\N
15	gastro@example.com	$2b$12$7DJh87RcG3x/wHJMP6Baqes54G6xteskbF/JvuKotfH/J.3sTgJiW	Dr. Le Van C	+84000000000	\N	\N	t	2	2025-11-22 04:38:58.365522+07	2025-11-22 04:38:58.365522+07	\N
16	endo@example.com	$2b$12$7DJh87RcG3x/wHJMP6Baqes54G6xteskbF/JvuKotfH/J.3sTgJiW	Dr. Pham Thi D	+84000000000	\N	\N	t	2	2025-11-22 04:38:58.365522+07	2025-11-22 04:38:58.365522+07	\N
17	derma@example.com	$2b$12$7DJh87RcG3x/wHJMP6Baqes54G6xteskbF/JvuKotfH/J.3sTgJiW	Dr. Hoang Van E	+84000000000	\N	\N	t	2	2025-11-22 04:38:58.365522+07	2025-11-22 04:38:58.365522+07	\N
18	ent@example.com	$2b$12$7DJh87RcG3x/wHJMP6Baqes54G6xteskbF/JvuKotfH/J.3sTgJiW	Dr. Bui Thi F	+84000000000	\N	\N	t	2	2025-11-22 04:38:58.365522+07	2025-11-22 04:38:58.365522+07	\N
19	pulmo@example.com	$2b$12$7DJh87RcG3x/wHJMP6Baqes54G6xteskbF/JvuKotfH/J.3sTgJiW	Dr. Dao Van G	+84000000000	\N	\N	t	2	2025-11-22 04:38:58.365522+07	2025-11-22 04:38:58.365522+07	\N
\.


--
-- Name: appointments_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.appointments_id_seq', 10, true);


--
-- Name: audit_logs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.audit_logs_id_seq', 20, true);


--
-- Name: doctor_reviews_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.doctor_reviews_id_seq', 1, false);


--
-- Name: doctor_specialties_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.doctor_specialties_id_seq', 8, true);


--
-- Name: doctors_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.doctors_id_seq', 9, true);


--
-- Name: invoices_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.invoices_id_seq', 29, true);


--
-- Name: lab_orders_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.lab_orders_id_seq', 10, true);


--
-- Name: medical_records_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.medical_records_id_seq', 10, true);


--
-- Name: medicines_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.medicines_id_seq', 5, true);


--
-- Name: notifications_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.notifications_id_seq', 33, true);


--
-- Name: patients_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.patients_id_seq', 30, true);


--
-- Name: prescriptions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.prescriptions_id_seq', 28, true);


--
-- Name: roles_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.roles_id_seq', 6, true);


--
-- Name: rooms_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.rooms_id_seq', 12, true);


--
-- Name: schedules_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.schedules_id_seq', 128, true);


--
-- Name: specialties_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.specialties_id_seq', 5, true);


--
-- Name: stocks_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.stocks_id_seq', 5, true);


--
-- Name: suppliers_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.suppliers_id_seq', 3, true);


--
-- Name: timeslots_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.timeslots_id_seq', 1097, true);


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.users_id_seq', 32, true);


--
-- Name: _prisma_migrations _prisma_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public._prisma_migrations
    ADD CONSTRAINT _prisma_migrations_pkey PRIMARY KEY (id);


--
-- Name: appointments appointments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.appointments
    ADD CONSTRAINT appointments_pkey PRIMARY KEY (id);


--
-- Name: audit_logs audit_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.audit_logs
    ADD CONSTRAINT audit_logs_pkey PRIMARY KEY (id);


--
-- Name: doctor_reviews doctor_reviews_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.doctor_reviews
    ADD CONSTRAINT doctor_reviews_pkey PRIMARY KEY (id);


--
-- Name: doctor_specialties doctor_specialties_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.doctor_specialties
    ADD CONSTRAINT doctor_specialties_pkey PRIMARY KEY (id);


--
-- Name: doctors doctors_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.doctors
    ADD CONSTRAINT doctors_pkey PRIMARY KEY (id);


--
-- Name: invoices invoices_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_pkey PRIMARY KEY (id);


--
-- Name: lab_orders lab_orders_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.lab_orders
    ADD CONSTRAINT lab_orders_pkey PRIMARY KEY (id);


--
-- Name: medical_records medical_records_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.medical_records
    ADD CONSTRAINT medical_records_pkey PRIMARY KEY (id);


--
-- Name: medicines medicines_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.medicines
    ADD CONSTRAINT medicines_pkey PRIMARY KEY (id);


--
-- Name: notifications notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_pkey PRIMARY KEY (id);


--
-- Name: patients patients_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patients
    ADD CONSTRAINT patients_pkey PRIMARY KEY (id);


--
-- Name: prescriptions prescriptions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.prescriptions
    ADD CONSTRAINT prescriptions_pkey PRIMARY KEY (id);


--
-- Name: roles roles_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (id);


--
-- Name: rooms rooms_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rooms
    ADD CONSTRAINT rooms_pkey PRIMARY KEY (id);


--
-- Name: schedules schedules_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.schedules
    ADD CONSTRAINT schedules_pkey PRIMARY KEY (id);


--
-- Name: specialties specialties_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.specialties
    ADD CONSTRAINT specialties_pkey PRIMARY KEY (id);


--
-- Name: stocks stocks_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.stocks
    ADD CONSTRAINT stocks_pkey PRIMARY KEY (id);


--
-- Name: suppliers suppliers_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.suppliers
    ADD CONSTRAINT suppliers_pkey PRIMARY KEY (id);


--
-- Name: timeslots timeslots_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.timeslots
    ADD CONSTRAINT timeslots_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: doctor_reviews_doctor_id_patient_id_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX doctor_reviews_doctor_id_patient_id_key ON public.doctor_reviews USING btree (doctor_id, patient_id);


--
-- Name: doctor_specialties_doctor_id_specialty_id_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX doctor_specialties_doctor_id_specialty_id_key ON public.doctor_specialties USING btree (doctor_id, specialty_id);


--
-- Name: doctors_user_id_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX doctors_user_id_key ON public.doctors USING btree (user_id);


--
-- Name: idx_appointments_doctor_date; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_appointments_doctor_date ON public.appointments USING btree (doctor_id, appointment_date);


--
-- Name: idx_appointments_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_appointments_status ON public.appointments USING btree (status);


--
-- Name: idx_doctorspecialty_doctor; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_doctorspecialty_doctor ON public.doctor_specialties USING btree (doctor_id);


--
-- Name: idx_doctorspecialty_specialty; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_doctorspecialty_specialty ON public.doctor_specialties USING btree (specialty_id);


--
-- Name: idx_invoices_patient; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_invoices_patient ON public.invoices USING btree (patient_id);


--
-- Name: idx_medicalrecords_patient; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_medicalrecords_patient ON public.medical_records USING btree (patient_id);


--
-- Name: idx_patients_id_number; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_patients_id_number ON public.patients USING btree (id_number);


--
-- Name: idx_patients_owner_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_patients_owner_user_id ON public.patients USING btree (owner_user_id);


--
-- Name: idx_prescriptions_patient; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_prescriptions_patient ON public.prescriptions USING btree (patient_id);


--
-- Name: idx_reviews_doctor; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_reviews_doctor ON public.doctor_reviews USING btree (doctor_id);


--
-- Name: idx_reviews_patient; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_reviews_patient ON public.doctor_reviews USING btree (patient_id);


--
-- Name: idx_timeslots_active; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_timeslots_active ON public.timeslots USING btree (is_active);


--
-- Name: idx_timeslots_doctor_date; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_timeslots_doctor_date ON public.timeslots USING btree (doctor_id, date);


--
-- Name: medicines_code_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX medicines_code_key ON public.medicines USING btree (code);


--
-- Name: patients_user_id_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX patients_user_id_key ON public.patients USING btree (user_id);


--
-- Name: roles_name_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX roles_name_key ON public.roles USING btree (name);


--
-- Name: specialties_name_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX specialties_name_key ON public.specialties USING btree (name);


--
-- Name: specialties_slug_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX specialties_slug_key ON public.specialties USING btree (slug);


--
-- Name: stocks_medicine_id_batch_number_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX stocks_medicine_id_batch_number_key ON public.stocks USING btree (medicine_id, batch_number);


--
-- Name: timeslot_unique; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX timeslot_unique ON public.timeslots USING btree (doctor_id, date, start_time, end_time);


--
-- Name: uq_appointments_patient_timeslot; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX uq_appointments_patient_timeslot ON public.appointments USING btree (patient_id, timeslot_id);


--
-- Name: uq_doctor_patient_review; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX uq_doctor_patient_review ON public.doctor_reviews USING btree (doctor_id, patient_id);


--
-- Name: users_email_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX users_email_key ON public.users USING btree (email);


--
-- Name: appointments appointments_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.appointments
    ADD CONSTRAINT appointments_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: appointments appointments_doctor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.appointments
    ADD CONSTRAINT appointments_doctor_id_fkey FOREIGN KEY (doctor_id) REFERENCES public.doctors(id) ON DELETE CASCADE;


--
-- Name: appointments appointments_patient_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.appointments
    ADD CONSTRAINT appointments_patient_id_fkey FOREIGN KEY (patient_id) REFERENCES public.patients(id) ON DELETE CASCADE;


--
-- Name: appointments appointments_timeslot_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.appointments
    ADD CONSTRAINT appointments_timeslot_id_fkey FOREIGN KEY (timeslot_id) REFERENCES public.timeslots(id) ON DELETE SET NULL;


--
-- Name: doctor_reviews doctor_reviews_doctor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.doctor_reviews
    ADD CONSTRAINT doctor_reviews_doctor_id_fkey FOREIGN KEY (doctor_id) REFERENCES public.doctors(id) ON DELETE CASCADE;


--
-- Name: doctor_reviews doctor_reviews_patient_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.doctor_reviews
    ADD CONSTRAINT doctor_reviews_patient_id_fkey FOREIGN KEY (patient_id) REFERENCES public.patients(id) ON DELETE CASCADE;


--
-- Name: doctor_specialties doctor_specialties_doctor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.doctor_specialties
    ADD CONSTRAINT doctor_specialties_doctor_id_fkey FOREIGN KEY (doctor_id) REFERENCES public.doctors(id) ON DELETE CASCADE;


--
-- Name: doctor_specialties doctor_specialties_specialty_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.doctor_specialties
    ADD CONSTRAINT doctor_specialties_specialty_id_fkey FOREIGN KEY (specialty_id) REFERENCES public.specialties(id) ON DELETE CASCADE;


--
-- Name: doctors doctors_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.doctors
    ADD CONSTRAINT doctors_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: patients fk_patients_owner_user_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patients
    ADD CONSTRAINT fk_patients_owner_user_id FOREIGN KEY (owner_user_id) REFERENCES public.users(id);


--
-- Name: invoices invoices_appointment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_appointment_id_fkey FOREIGN KEY (appointment_id) REFERENCES public.appointments(id) ON DELETE SET NULL;


--
-- Name: invoices invoices_patient_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_patient_id_fkey FOREIGN KEY (patient_id) REFERENCES public.patients(id) ON DELETE CASCADE;


--
-- Name: invoices invoices_prescription_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_prescription_id_fkey FOREIGN KEY (prescription_id) REFERENCES public.prescriptions(id) ON DELETE SET NULL;


--
-- Name: lab_orders lab_orders_appointment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.lab_orders
    ADD CONSTRAINT lab_orders_appointment_id_fkey FOREIGN KEY (appointment_id) REFERENCES public.appointments(id) ON DELETE SET NULL;


--
-- Name: lab_orders lab_orders_doctor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.lab_orders
    ADD CONSTRAINT lab_orders_doctor_id_fkey FOREIGN KEY (doctor_id) REFERENCES public.doctors(id) ON DELETE SET NULL;


--
-- Name: lab_orders lab_orders_patient_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.lab_orders
    ADD CONSTRAINT lab_orders_patient_id_fkey FOREIGN KEY (patient_id) REFERENCES public.patients(id) ON DELETE CASCADE;


--
-- Name: medical_records medical_records_appointment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.medical_records
    ADD CONSTRAINT medical_records_appointment_id_fkey FOREIGN KEY (appointment_id) REFERENCES public.appointments(id) ON DELETE SET NULL;


--
-- Name: medical_records medical_records_doctor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.medical_records
    ADD CONSTRAINT medical_records_doctor_id_fkey FOREIGN KEY (doctor_id) REFERENCES public.doctors(id) ON DELETE SET NULL;


--
-- Name: medical_records medical_records_patient_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.medical_records
    ADD CONSTRAINT medical_records_patient_id_fkey FOREIGN KEY (patient_id) REFERENCES public.patients(id) ON DELETE CASCADE;


--
-- Name: notifications notifications_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: patients patients_owner_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patients
    ADD CONSTRAINT patients_owner_user_id_fkey FOREIGN KEY (owner_user_id) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: patients patients_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patients
    ADD CONSTRAINT patients_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: prescriptions prescriptions_appointment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.prescriptions
    ADD CONSTRAINT prescriptions_appointment_id_fkey FOREIGN KEY (appointment_id) REFERENCES public.appointments(id) ON DELETE SET NULL;


--
-- Name: prescriptions prescriptions_doctor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.prescriptions
    ADD CONSTRAINT prescriptions_doctor_id_fkey FOREIGN KEY (doctor_id) REFERENCES public.doctors(id) ON DELETE SET NULL;


--
-- Name: prescriptions prescriptions_notified_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.prescriptions
    ADD CONSTRAINT prescriptions_notified_by_fkey FOREIGN KEY (notified_by) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: prescriptions prescriptions_patient_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.prescriptions
    ADD CONSTRAINT prescriptions_patient_id_fkey FOREIGN KEY (patient_id) REFERENCES public.patients(id) ON DELETE CASCADE;


--
-- Name: schedules schedules_doctor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.schedules
    ADD CONSTRAINT schedules_doctor_id_fkey FOREIGN KEY (doctor_id) REFERENCES public.doctors(id) ON DELETE CASCADE;


--
-- Name: schedules schedules_room_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.schedules
    ADD CONSTRAINT schedules_room_id_fkey FOREIGN KEY (room_id) REFERENCES public.rooms(id) ON DELETE SET NULL;


--
-- Name: stocks stocks_medicine_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.stocks
    ADD CONSTRAINT stocks_medicine_id_fkey FOREIGN KEY (medicine_id) REFERENCES public.medicines(id) ON DELETE CASCADE;


--
-- Name: timeslots timeslots_doctor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.timeslots
    ADD CONSTRAINT timeslots_doctor_id_fkey FOREIGN KEY (doctor_id) REFERENCES public.doctors(id) ON DELETE CASCADE;


--
-- Name: users users_role_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_role_id_fkey FOREIGN KEY (role_id) REFERENCES public.roles(id) ON DELETE RESTRICT;


--
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE USAGE ON SCHEMA public FROM PUBLIC;


--
-- PostgreSQL database dump complete
--

