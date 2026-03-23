--
-- PostgreSQL database cluster dump
--

SET default_transaction_read_only = off;

SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;

--
-- Drop databases (except postgres and template1)
--

DROP DATABASE enterprise_mcp_server;




--
-- Drop roles
--

DROP ROLE postgres;


--
-- Roles
--

CREATE ROLE postgres;
ALTER ROLE postgres WITH SUPERUSER INHERIT CREATEROLE CREATEDB LOGIN REPLICATION BYPASSRLS PASSWORD 'SCRAM-SHA-256$4096:B9J0QIWawbIT2RAW31OGmA==$pPYqcizRNzK1tWJLM6Q34fvy0G631zrsdeR6fo+fJIU=:fPFFfvHVtRHbUNLtaBWmBcOZdKGygm+hDmATQJOvRsg=';

--
-- User Configurations
--








--
-- Databases
--

--
-- Database "template1" dump
--

--
-- PostgreSQL database dump
--

-- Dumped from database version 15.13
-- Dumped by pg_dump version 15.13

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

UPDATE pg_catalog.pg_database SET datistemplate = false WHERE datname = 'template1';
DROP DATABASE template1;
--
-- Name: template1; Type: DATABASE; Schema: -; Owner: postgres
--

CREATE DATABASE template1 WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'en_US.utf8';


ALTER DATABASE template1 OWNER TO postgres;

\connect template1

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: DATABASE template1; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON DATABASE template1 IS 'default template for new databases';


--
-- Name: template1; Type: DATABASE PROPERTIES; Schema: -; Owner: postgres
--

ALTER DATABASE template1 IS_TEMPLATE = true;


\connect template1

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: DATABASE template1; Type: ACL; Schema: -; Owner: postgres
--

REVOKE CONNECT,TEMPORARY ON DATABASE template1 FROM PUBLIC;
GRANT CONNECT ON DATABASE template1 TO PUBLIC;


--
-- PostgreSQL database dump complete
--

--
-- Database "enterprise_mcp_server" dump
--

--
-- PostgreSQL database dump
--

-- Dumped from database version 15.13
-- Dumped by pg_dump version 15.13

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: enterprise_mcp_server; Type: DATABASE; Schema: -; Owner: postgres
--

CREATE DATABASE enterprise_mcp_server WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'en_US.utf8';


ALTER DATABASE enterprise_mcp_server OWNER TO postgres;

\connect enterprise_mcp_server

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: pg_trgm; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_trgm WITH SCHEMA public;


--
-- Name: EXTENSION pg_trgm; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pg_trgm IS 'text similarity measurement and index searching based on trigrams';


--
-- Name: next_id(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.next_id(OUT id bigint) RETURNS bigint
    LANGUAGE plpgsql
    AS $$
      DECLARE
        shard INT := 1;
        epoch BIGINT := 1567191600000;
        sequence BIGINT;
        milliseconds BIGINT;
      BEGIN
        SELECT nextval('next_id_seq') % 1024 INTO sequence;
        SELECT FLOOR(EXTRACT(EPOCH FROM clock_timestamp()) * 1000) INTO milliseconds;
        id := (milliseconds - epoch) << 23;
        id := id | (shard << 10);
        id := id | (sequence);
      END;
    $$;


ALTER FUNCTION public.next_id(OUT id bigint) OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: action; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.action (
    id bigint DEFAULT public.next_id() NOT NULL,
    card_id bigint NOT NULL,
    user_id bigint,
    type text NOT NULL,
    data jsonb NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    board_id bigint
);


ALTER TABLE public.action OWNER TO postgres;

--
-- Name: attachment; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.attachment (
    id bigint DEFAULT public.next_id() NOT NULL,
    card_id bigint NOT NULL,
    creator_user_id bigint,
    type text NOT NULL,
    data jsonb NOT NULL,
    name text NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


ALTER TABLE public.attachment OWNER TO postgres;

--
-- Name: background_image; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.background_image (
    id bigint DEFAULT public.next_id() NOT NULL,
    project_id bigint NOT NULL,
    dirname text NOT NULL,
    extension text NOT NULL,
    size_in_bytes bigint NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


ALTER TABLE public.background_image OWNER TO postgres;

--
-- Name: base_custom_field_group; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.base_custom_field_group (
    id bigint DEFAULT public.next_id() NOT NULL,
    project_id bigint NOT NULL,
    name text NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


ALTER TABLE public.base_custom_field_group OWNER TO postgres;

--
-- Name: board; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.board (
    id bigint DEFAULT public.next_id() NOT NULL,
    project_id bigint NOT NULL,
    "position" double precision NOT NULL,
    name text NOT NULL,
    default_view text NOT NULL,
    default_card_type text NOT NULL,
    limit_card_types_to_default_one boolean NOT NULL,
    always_display_card_creator boolean NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


ALTER TABLE public.board OWNER TO postgres;

--
-- Name: board_membership; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.board_membership (
    id bigint DEFAULT public.next_id() NOT NULL,
    project_id bigint NOT NULL,
    board_id bigint NOT NULL,
    user_id bigint NOT NULL,
    role text NOT NULL,
    can_comment boolean,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


ALTER TABLE public.board_membership OWNER TO postgres;

--
-- Name: board_subscription; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.board_subscription (
    id bigint DEFAULT public.next_id() NOT NULL,
    board_id bigint NOT NULL,
    user_id bigint NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


ALTER TABLE public.board_subscription OWNER TO postgres;

--
-- Name: card; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.card (
    id bigint DEFAULT public.next_id() NOT NULL,
    board_id bigint NOT NULL,
    list_id bigint NOT NULL,
    creator_user_id bigint,
    prev_list_id bigint,
    cover_attachment_id bigint,
    type text NOT NULL,
    "position" double precision,
    name text NOT NULL,
    description text,
    due_date timestamp without time zone,
    stopwatch jsonb,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    list_changed_at timestamp without time zone,
    comments_total integer NOT NULL
);


ALTER TABLE public.card OWNER TO postgres;

--
-- Name: card_label; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.card_label (
    id bigint DEFAULT public.next_id() NOT NULL,
    card_id bigint NOT NULL,
    label_id bigint NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


ALTER TABLE public.card_label OWNER TO postgres;

--
-- Name: card_membership; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.card_membership (
    id bigint DEFAULT public.next_id() NOT NULL,
    card_id bigint NOT NULL,
    user_id bigint NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


ALTER TABLE public.card_membership OWNER TO postgres;

--
-- Name: card_subscription; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.card_subscription (
    id bigint DEFAULT public.next_id() NOT NULL,
    card_id bigint NOT NULL,
    user_id bigint NOT NULL,
    is_permanent boolean NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


ALTER TABLE public.card_subscription OWNER TO postgres;

--
-- Name: comment; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.comment (
    id bigint DEFAULT public.next_id() NOT NULL,
    card_id bigint NOT NULL,
    user_id bigint,
    text text NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


ALTER TABLE public.comment OWNER TO postgres;

--
-- Name: custom_field; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.custom_field (
    id bigint DEFAULT public.next_id() NOT NULL,
    base_custom_field_group_id bigint,
    custom_field_group_id bigint,
    "position" double precision NOT NULL,
    name text NOT NULL,
    show_on_front_of_card boolean NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


ALTER TABLE public.custom_field OWNER TO postgres;

--
-- Name: custom_field_group; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.custom_field_group (
    id bigint DEFAULT public.next_id() NOT NULL,
    board_id bigint,
    card_id bigint,
    base_custom_field_group_id bigint,
    "position" double precision NOT NULL,
    name text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


ALTER TABLE public.custom_field_group OWNER TO postgres;

--
-- Name: custom_field_value; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.custom_field_value (
    id bigint DEFAULT public.next_id() NOT NULL,
    card_id bigint NOT NULL,
    custom_field_group_id bigint NOT NULL,
    custom_field_id bigint NOT NULL,
    content text NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


ALTER TABLE public.custom_field_value OWNER TO postgres;

--
-- Name: file_reference; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.file_reference (
    id bigint DEFAULT public.next_id() NOT NULL,
    total integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


ALTER TABLE public.file_reference OWNER TO postgres;

--
-- Name: identity_provider_user; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.identity_provider_user (
    id bigint DEFAULT public.next_id() NOT NULL,
    user_id bigint NOT NULL,
    issuer text NOT NULL,
    sub text NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


ALTER TABLE public.identity_provider_user OWNER TO postgres;

--
-- Name: label; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.label (
    id bigint DEFAULT public.next_id() NOT NULL,
    board_id bigint NOT NULL,
    "position" double precision NOT NULL,
    name text,
    color text NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


ALTER TABLE public.label OWNER TO postgres;

--
-- Name: list; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.list (
    id bigint DEFAULT public.next_id() NOT NULL,
    board_id bigint NOT NULL,
    type text NOT NULL,
    "position" double precision,
    name text,
    color text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


ALTER TABLE public.list OWNER TO postgres;

--
-- Name: migration; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.migration (
    id integer NOT NULL,
    name character varying(255),
    batch integer,
    migration_time timestamp with time zone
);


ALTER TABLE public.migration OWNER TO postgres;

--
-- Name: migration_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.migration_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.migration_id_seq OWNER TO postgres;

--
-- Name: migration_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.migration_id_seq OWNED BY public.migration.id;


--
-- Name: migration_lock; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.migration_lock (
    index integer NOT NULL,
    is_locked integer
);


ALTER TABLE public.migration_lock OWNER TO postgres;

--
-- Name: migration_lock_index_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.migration_lock_index_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.migration_lock_index_seq OWNER TO postgres;

--
-- Name: migration_lock_index_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.migration_lock_index_seq OWNED BY public.migration_lock.index;


--
-- Name: next_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.next_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.next_id_seq OWNER TO postgres;

--
-- Name: notification; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.notification (
    id bigint DEFAULT public.next_id() NOT NULL,
    user_id bigint NOT NULL,
    creator_user_id bigint,
    board_id bigint NOT NULL,
    card_id bigint NOT NULL,
    comment_id bigint,
    action_id bigint,
    type text NOT NULL,
    data jsonb NOT NULL,
    is_read boolean NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


ALTER TABLE public.notification OWNER TO postgres;

--
-- Name: notification_service; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.notification_service (
    id bigint DEFAULT public.next_id() NOT NULL,
    user_id bigint,
    board_id bigint,
    url text NOT NULL,
    format text NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


ALTER TABLE public.notification_service OWNER TO postgres;

--
-- Name: project; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.project (
    id bigint DEFAULT public.next_id() NOT NULL,
    owner_project_manager_id bigint,
    background_image_id bigint,
    name text NOT NULL,
    description text,
    background_type text,
    background_gradient text,
    is_hidden boolean NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


ALTER TABLE public.project OWNER TO postgres;

--
-- Name: project_favorite; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.project_favorite (
    id bigint DEFAULT public.next_id() NOT NULL,
    project_id bigint NOT NULL,
    user_id bigint NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


ALTER TABLE public.project_favorite OWNER TO postgres;

--
-- Name: project_manager; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.project_manager (
    id bigint DEFAULT public.next_id() NOT NULL,
    project_id bigint NOT NULL,
    user_id bigint NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


ALTER TABLE public.project_manager OWNER TO postgres;

--
-- Name: session; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.session (
    id bigint DEFAULT public.next_id() NOT NULL,
    user_id bigint NOT NULL,
    access_token text NOT NULL,
    http_only_token text,
    remote_address text NOT NULL,
    user_agent text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    deleted_at timestamp without time zone
);


ALTER TABLE public.session OWNER TO postgres;

--
-- Name: task; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.task (
    id bigint DEFAULT public.next_id() NOT NULL,
    task_list_id bigint NOT NULL,
    assignee_user_id bigint,
    "position" double precision NOT NULL,
    name text NOT NULL,
    is_completed boolean NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


ALTER TABLE public.task OWNER TO postgres;

--
-- Name: task_list; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.task_list (
    id bigint DEFAULT public.next_id() NOT NULL,
    card_id bigint NOT NULL,
    "position" double precision NOT NULL,
    name text NOT NULL,
    show_on_front_of_card boolean NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


ALTER TABLE public.task_list OWNER TO postgres;

--
-- Name: user_account; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_account (
    id bigint DEFAULT public.next_id() NOT NULL,
    email text NOT NULL,
    password text,
    role text NOT NULL,
    name text NOT NULL,
    username text,
    avatar jsonb,
    phone text,
    organization text,
    language text,
    subscribe_to_own_cards boolean NOT NULL,
    subscribe_to_card_when_commenting boolean NOT NULL,
    turn_off_recent_card_highlighting boolean NOT NULL,
    enable_favorites_by_default boolean NOT NULL,
    default_editor_mode text NOT NULL,
    default_home_view text NOT NULL,
    default_projects_order text NOT NULL,
    is_sso_user boolean NOT NULL,
    is_deactivated boolean NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    password_changed_at timestamp without time zone
);


ALTER TABLE public.user_account OWNER TO postgres;

--
-- Name: migration id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.migration ALTER COLUMN id SET DEFAULT nextval('public.migration_id_seq'::regclass);


--
-- Name: migration_lock index; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.migration_lock ALTER COLUMN index SET DEFAULT nextval('public.migration_lock_index_seq'::regclass);


--
-- Data for Name: action; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.action (id, card_id, user_id, type, data, created_at, updated_at, board_id) FROM stdin;
\.


--
-- Data for Name: attachment; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.attachment (id, card_id, creator_user_id, type, data, name, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: background_image; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.background_image (id, project_id, dirname, extension, size_in_bytes, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: base_custom_field_group; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.base_custom_field_group (id, project_id, name, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: board; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.board (id, project_id, "position", name, default_view, default_card_type, limit_card_types_to_default_one, always_display_card_creator, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: board_membership; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.board_membership (id, project_id, board_id, user_id, role, can_comment, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: board_subscription; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.board_subscription (id, board_id, user_id, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: card; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.card (id, board_id, list_id, creator_user_id, prev_list_id, cover_attachment_id, type, "position", name, description, due_date, stopwatch, created_at, updated_at, list_changed_at, comments_total) FROM stdin;
\.


--
-- Data for Name: card_label; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.card_label (id, card_id, label_id, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: card_membership; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.card_membership (id, card_id, user_id, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: card_subscription; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.card_subscription (id, card_id, user_id, is_permanent, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: comment; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.comment (id, card_id, user_id, text, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: custom_field; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.custom_field (id, base_custom_field_group_id, custom_field_group_id, "position", name, show_on_front_of_card, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: custom_field_group; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.custom_field_group (id, board_id, card_id, base_custom_field_group_id, "position", name, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: custom_field_value; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.custom_field_value (id, card_id, custom_field_group_id, custom_field_id, content, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: file_reference; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.file_reference (id, total, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: identity_provider_user; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.identity_provider_user (id, user_id, issuer, sub, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: label; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.label (id, board_id, "position", name, color, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: list; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.list (id, board_id, type, "position", name, color, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: migration; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.migration (id, name, batch, migration_time) FROM stdin;
1	20250228000022_version_2.js	1	2025-07-20 20:08:34.966+00
2	20250522151122_add_board_activity_log.js	1	2025-07-20 20:08:34.968+00
3	20250523131647_add_comments_counter.js	1	2025-07-20 20:08:34.969+00
4	20250603102521_canonicalize_locale_codes.js	1	2025-07-20 20:08:34.97+00
\.


--
-- Data for Name: migration_lock; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.migration_lock (index, is_locked) FROM stdin;
1	0
\.


--
-- Data for Name: notification; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.notification (id, user_id, creator_user_id, board_id, card_id, comment_id, action_id, type, data, is_read, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: notification_service; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.notification_service (id, user_id, board_id, url, format, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: project; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.project (id, owner_project_manager_id, background_image_id, name, description, background_type, background_gradient, is_hidden, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: project_favorite; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.project_favorite (id, project_id, user_id, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: project_manager; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.project_manager (id, project_id, user_id, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: session; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.session (id, user_id, access_token, http_only_token, remote_address, user_agent, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: task; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.task (id, task_list_id, assignee_user_id, "position", name, is_completed, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: task_list; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.task_list (id, card_id, "position", name, show_on_front_of_card, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: user_account; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.user_account (id, email, password, role, name, username, avatar, phone, organization, language, subscribe_to_own_cards, subscribe_to_card_when_commenting, turn_off_recent_card_highlighting, enable_favorites_by_default, default_editor_mode, default_home_view, default_projects_order, is_sso_user, is_deactivated, created_at, updated_at, password_changed_at) FROM stdin;
1559027117360940033	agent@gmail.com	$2b$10$PSsFlF/YxhlkWWVn0quRa.bDP3lMLJsIznQpsw8rh4T8SJvD9lzNm	admin	Demo User	demo	\N	\N	\N	\N	f	t	f	f	wysiwyg	groupedProjects	byDefault	f	f	2025-07-20 20:08:35.05	\N	\N
\.


--
-- Name: migration_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.migration_id_seq', 33, true);


--
-- Name: migration_lock_index_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.migration_lock_index_seq', 33, true);


--
-- Name: next_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.next_id_seq', 36, true);


--
-- Name: action action_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.action
    ADD CONSTRAINT action_pkey PRIMARY KEY (id);


--
-- Name: attachment attachment_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.attachment
    ADD CONSTRAINT attachment_pkey PRIMARY KEY (id);


--
-- Name: background_image background_image_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.background_image
    ADD CONSTRAINT background_image_pkey PRIMARY KEY (id);


--
-- Name: base_custom_field_group base_custom_field_group_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.base_custom_field_group
    ADD CONSTRAINT base_custom_field_group_pkey PRIMARY KEY (id);


--
-- Name: board_membership board_membership_board_id_user_id_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.board_membership
    ADD CONSTRAINT board_membership_board_id_user_id_unique UNIQUE (board_id, user_id);


--
-- Name: board_membership board_membership_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.board_membership
    ADD CONSTRAINT board_membership_pkey PRIMARY KEY (id);


--
-- Name: board board_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.board
    ADD CONSTRAINT board_pkey PRIMARY KEY (id);


--
-- Name: board_subscription board_subscription_board_id_user_id_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.board_subscription
    ADD CONSTRAINT board_subscription_board_id_user_id_unique UNIQUE (board_id, user_id);


--
-- Name: board_subscription board_subscription_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.board_subscription
    ADD CONSTRAINT board_subscription_pkey PRIMARY KEY (id);


--
-- Name: card_label card_label_card_id_label_id_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.card_label
    ADD CONSTRAINT card_label_card_id_label_id_unique UNIQUE (card_id, label_id);


--
-- Name: card_label card_label_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.card_label
    ADD CONSTRAINT card_label_pkey PRIMARY KEY (id);


--
-- Name: card_membership card_membership_card_id_user_id_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.card_membership
    ADD CONSTRAINT card_membership_card_id_user_id_unique UNIQUE (card_id, user_id);


--
-- Name: card_membership card_membership_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.card_membership
    ADD CONSTRAINT card_membership_pkey PRIMARY KEY (id);


--
-- Name: card card_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.card
    ADD CONSTRAINT card_pkey PRIMARY KEY (id);


--
-- Name: card_subscription card_subscription_card_id_user_id_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.card_subscription
    ADD CONSTRAINT card_subscription_card_id_user_id_unique UNIQUE (card_id, user_id);


--
-- Name: card_subscription card_subscription_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.card_subscription
    ADD CONSTRAINT card_subscription_pkey PRIMARY KEY (id);


--
-- Name: comment comment_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.comment
    ADD CONSTRAINT comment_pkey PRIMARY KEY (id);


--
-- Name: custom_field_group custom_field_group_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.custom_field_group
    ADD CONSTRAINT custom_field_group_pkey PRIMARY KEY (id);


--
-- Name: custom_field custom_field_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.custom_field
    ADD CONSTRAINT custom_field_pkey PRIMARY KEY (id);


--
-- Name: custom_field_value custom_field_value_card_id_custom_field_group_id_custom_field_i; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.custom_field_value
    ADD CONSTRAINT custom_field_value_card_id_custom_field_group_id_custom_field_i UNIQUE (card_id, custom_field_group_id, custom_field_id);


--
-- Name: custom_field_value custom_field_value_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.custom_field_value
    ADD CONSTRAINT custom_field_value_pkey PRIMARY KEY (id);


--
-- Name: file_reference file_reference_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.file_reference
    ADD CONSTRAINT file_reference_pkey PRIMARY KEY (id);


--
-- Name: identity_provider_user identity_provider_user_issuer_sub_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.identity_provider_user
    ADD CONSTRAINT identity_provider_user_issuer_sub_unique UNIQUE (issuer, sub);


--
-- Name: identity_provider_user identity_provider_user_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.identity_provider_user
    ADD CONSTRAINT identity_provider_user_pkey PRIMARY KEY (id);


--
-- Name: label label_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.label
    ADD CONSTRAINT label_pkey PRIMARY KEY (id);


--
-- Name: list list_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.list
    ADD CONSTRAINT list_pkey PRIMARY KEY (id);


--
-- Name: migration_lock migration_lock_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.migration_lock
    ADD CONSTRAINT migration_lock_pkey PRIMARY KEY (index);


--
-- Name: migration migration_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.migration
    ADD CONSTRAINT migration_pkey PRIMARY KEY (id);


--
-- Name: notification notification_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notification
    ADD CONSTRAINT notification_pkey PRIMARY KEY (id);


--
-- Name: notification_service notification_service_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notification_service
    ADD CONSTRAINT notification_service_pkey PRIMARY KEY (id);


--
-- Name: project_favorite project_favorite_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.project_favorite
    ADD CONSTRAINT project_favorite_pkey PRIMARY KEY (id);


--
-- Name: project_favorite project_favorite_project_id_user_id_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.project_favorite
    ADD CONSTRAINT project_favorite_project_id_user_id_unique UNIQUE (project_id, user_id);


--
-- Name: project_manager project_manager_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.project_manager
    ADD CONSTRAINT project_manager_pkey PRIMARY KEY (id);


--
-- Name: project_manager project_manager_project_id_user_id_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.project_manager
    ADD CONSTRAINT project_manager_project_id_user_id_unique UNIQUE (project_id, user_id);


--
-- Name: project project_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.project
    ADD CONSTRAINT project_pkey PRIMARY KEY (id);


--
-- Name: session session_access_token_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.session
    ADD CONSTRAINT session_access_token_unique UNIQUE (access_token);


--
-- Name: session session_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.session
    ADD CONSTRAINT session_pkey PRIMARY KEY (id);


--
-- Name: task_list task_list_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task_list
    ADD CONSTRAINT task_list_pkey PRIMARY KEY (id);


--
-- Name: task task_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task
    ADD CONSTRAINT task_pkey PRIMARY KEY (id);


--
-- Name: user_account user_account_email_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_account
    ADD CONSTRAINT user_account_email_unique UNIQUE (email);


--
-- Name: user_account user_account_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_account
    ADD CONSTRAINT user_account_pkey PRIMARY KEY (id);


--
-- Name: user_account user_account_username_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_account
    ADD CONSTRAINT user_account_username_unique EXCLUDE USING btree (username WITH =) WHERE ((username IS NOT NULL));


--
-- Name: action_board_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX action_board_id_index ON public.action USING btree (board_id);


--
-- Name: action_card_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX action_card_id_index ON public.action USING btree (card_id);


--
-- Name: action_user_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX action_user_id_index ON public.action USING btree (user_id);


--
-- Name: attachment_card_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX attachment_card_id_index ON public.attachment USING btree (card_id);


--
-- Name: attachment_creator_user_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX attachment_creator_user_id_index ON public.attachment USING btree (creator_user_id);


--
-- Name: background_image_project_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX background_image_project_id_index ON public.background_image USING btree (project_id);


--
-- Name: base_custom_field_group_project_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX base_custom_field_group_project_id_index ON public.base_custom_field_group USING btree (project_id);


--
-- Name: board_membership_project_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX board_membership_project_id_index ON public.board_membership USING btree (project_id);


--
-- Name: board_membership_user_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX board_membership_user_id_index ON public.board_membership USING btree (user_id);


--
-- Name: board_position_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX board_position_index ON public.board USING btree ("position");


--
-- Name: board_project_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX board_project_id_index ON public.board USING btree (project_id);


--
-- Name: board_subscription_user_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX board_subscription_user_id_index ON public.board_subscription USING btree (user_id);


--
-- Name: card_board_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX card_board_id_index ON public.card USING btree (board_id);


--
-- Name: card_creator_user_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX card_creator_user_id_index ON public.card USING btree (creator_user_id);


--
-- Name: card_description_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX card_description_index ON public.card USING gin (description public.gin_trgm_ops);


--
-- Name: card_label_label_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX card_label_label_id_index ON public.card_label USING btree (label_id);


--
-- Name: card_list_changed_at_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX card_list_changed_at_index ON public.card USING btree (list_changed_at);


--
-- Name: card_list_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX card_list_id_index ON public.card USING btree (list_id);


--
-- Name: card_membership_user_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX card_membership_user_id_index ON public.card_membership USING btree (user_id);


--
-- Name: card_name_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX card_name_index ON public.card USING gin (name public.gin_trgm_ops);


--
-- Name: card_position_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX card_position_index ON public.card USING btree ("position");


--
-- Name: card_subscription_user_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX card_subscription_user_id_index ON public.card_subscription USING btree (user_id);


--
-- Name: comment_card_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX comment_card_id_index ON public.comment USING btree (card_id);


--
-- Name: comment_user_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX comment_user_id_index ON public.comment USING btree (user_id);


--
-- Name: custom_field_base_custom_field_group_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX custom_field_base_custom_field_group_id_index ON public.custom_field USING btree (base_custom_field_group_id);


--
-- Name: custom_field_custom_field_group_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX custom_field_custom_field_group_id_index ON public.custom_field USING btree (custom_field_group_id);


--
-- Name: custom_field_group_base_custom_field_group_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX custom_field_group_base_custom_field_group_id_index ON public.custom_field_group USING btree (base_custom_field_group_id);


--
-- Name: custom_field_group_board_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX custom_field_group_board_id_index ON public.custom_field_group USING btree (board_id);


--
-- Name: custom_field_group_card_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX custom_field_group_card_id_index ON public.custom_field_group USING btree (card_id);


--
-- Name: custom_field_group_position_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX custom_field_group_position_index ON public.custom_field_group USING btree ("position");


--
-- Name: custom_field_position_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX custom_field_position_index ON public.custom_field USING btree ("position");


--
-- Name: custom_field_value_custom_field_group_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX custom_field_value_custom_field_group_id_index ON public.custom_field_value USING btree (custom_field_group_id);


--
-- Name: custom_field_value_custom_field_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX custom_field_value_custom_field_id_index ON public.custom_field_value USING btree (custom_field_id);


--
-- Name: file_reference_total_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX file_reference_total_index ON public.file_reference USING btree (total);


--
-- Name: identity_provider_user_user_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX identity_provider_user_user_id_index ON public.identity_provider_user USING btree (user_id);


--
-- Name: label_board_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX label_board_id_index ON public.label USING btree (board_id);


--
-- Name: label_position_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX label_position_index ON public.label USING btree ("position");


--
-- Name: list_board_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX list_board_id_index ON public.list USING btree (board_id);


--
-- Name: list_position_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX list_position_index ON public.list USING btree ("position");


--
-- Name: list_type_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX list_type_index ON public.list USING btree (type);


--
-- Name: notification_action_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX notification_action_id_index ON public.notification USING btree (action_id);


--
-- Name: notification_card_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX notification_card_id_index ON public.notification USING btree (card_id);


--
-- Name: notification_comment_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX notification_comment_id_index ON public.notification USING btree (comment_id);


--
-- Name: notification_creator_user_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX notification_creator_user_id_index ON public.notification USING btree (creator_user_id);


--
-- Name: notification_is_read_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX notification_is_read_index ON public.notification USING btree (is_read);


--
-- Name: notification_service_board_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX notification_service_board_id_index ON public.notification_service USING btree (board_id);


--
-- Name: notification_service_user_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX notification_service_user_id_index ON public.notification_service USING btree (user_id);


--
-- Name: notification_user_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX notification_user_id_index ON public.notification USING btree (user_id);


--
-- Name: project_favorite_user_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX project_favorite_user_id_index ON public.project_favorite USING btree (user_id);


--
-- Name: project_manager_user_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX project_manager_user_id_index ON public.project_manager USING btree (user_id);


--
-- Name: project_owner_project_manager_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX project_owner_project_manager_id_index ON public.project USING btree (owner_project_manager_id);


--
-- Name: session_remote_address_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX session_remote_address_index ON public.session USING btree (remote_address);


--
-- Name: session_user_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX session_user_id_index ON public.session USING btree (user_id);


--
-- Name: task_assignee_user_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX task_assignee_user_id_index ON public.task USING btree (assignee_user_id);


--
-- Name: task_list_card_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX task_list_card_id_index ON public.task_list USING btree (card_id);


--
-- Name: task_list_position_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX task_list_position_index ON public.task_list USING btree ("position");


--
-- Name: task_position_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX task_position_index ON public.task USING btree ("position");


--
-- Name: task_task_list_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX task_task_list_id_index ON public.task USING btree (task_list_id);


--
-- Name: user_account_is_deactivated_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX user_account_is_deactivated_index ON public.user_account USING btree (is_deactivated);


--
-- Name: user_account_role_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX user_account_role_index ON public.user_account USING btree (role);


--
-- Name: user_account_username_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX user_account_username_index ON public.user_account USING btree (username);


--
-- PostgreSQL database dump complete
--

--
-- Database "postgres" dump
--

--
-- PostgreSQL database dump
--

-- Dumped from database version 15.13
-- Dumped by pg_dump version 15.13

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

DROP DATABASE postgres;
--
-- Name: postgres; Type: DATABASE; Schema: -; Owner: postgres
--

CREATE DATABASE postgres WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'en_US.utf8';


ALTER DATABASE postgres OWNER TO postgres;

\connect postgres

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: DATABASE postgres; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON DATABASE postgres IS 'default administrative connection database';


--
-- PostgreSQL database dump complete
--

--
-- PostgreSQL database cluster dump complete
--

