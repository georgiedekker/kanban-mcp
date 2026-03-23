--
-- PostgreSQL database dump
--

\restrict bvkQRfmp0ajahdmgcz8cTEnTQbQ8d20yKt1ucltzy4hukO39KGReOkXKMALIWrd

-- Dumped from database version 18.1 (Ubuntu 18.1-1.pgdg24.04+2)
-- Dumped by pg_dump version 18.1 (Ubuntu 18.1-1.pgdg24.04+2)

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
-- Name: timescaledb; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS timescaledb WITH SCHEMA public;


--
-- Name: EXTENSION timescaledb; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION timescaledb IS 'Enables scalable inserts and complex queries for time-series data (Community Edition)';


--
-- Name: pg_stat_statements; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_stat_statements WITH SCHEMA public;


--
-- Name: EXTENSION pg_stat_statements; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pg_stat_statements IS 'track planning and execution statistics of all SQL statements executed';


--
-- Name: pg_trgm; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_trgm WITH SCHEMA public;


--
-- Name: EXTENSION pg_trgm; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pg_trgm IS 'text similarity measurement and index searching based on trigrams';


--
-- Name: unaccent; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS unaccent WITH SCHEMA public;


--
-- Name: EXTENSION unaccent; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION unaccent IS 'text search dictionary that removes accents';


--
-- Name: next_id(); Type: FUNCTION; Schema: public; Owner: georgedekker
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


ALTER FUNCTION public.next_id(OUT id bigint) OWNER TO georgedekker;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: action; Type: TABLE; Schema: public; Owner: mini1
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


ALTER TABLE public.action OWNER TO mini1;

--
-- Name: attachment; Type: TABLE; Schema: public; Owner: mini1
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


ALTER TABLE public.attachment OWNER TO mini1;

--
-- Name: background_image; Type: TABLE; Schema: public; Owner: mini1
--

CREATE TABLE public.background_image (
    id bigint DEFAULT public.next_id() NOT NULL,
    project_id bigint NOT NULL,
    uploaded_file_id text NOT NULL,
    extension text NOT NULL,
    size bigint NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


ALTER TABLE public.background_image OWNER TO mini1;

--
-- Name: base_custom_field_group; Type: TABLE; Schema: public; Owner: mini1
--

CREATE TABLE public.base_custom_field_group (
    id bigint DEFAULT public.next_id() NOT NULL,
    project_id bigint NOT NULL,
    name text NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


ALTER TABLE public.base_custom_field_group OWNER TO mini1;

--
-- Name: board; Type: TABLE; Schema: public; Owner: mini1
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
    updated_at timestamp without time zone,
    expand_task_lists_by_default boolean NOT NULL
);


ALTER TABLE public.board OWNER TO mini1;

--
-- Name: board_membership; Type: TABLE; Schema: public; Owner: mini1
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


ALTER TABLE public.board_membership OWNER TO mini1;

--
-- Name: board_subscription; Type: TABLE; Schema: public; Owner: mini1
--

CREATE TABLE public.board_subscription (
    id bigint DEFAULT public.next_id() NOT NULL,
    board_id bigint NOT NULL,
    user_id bigint NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


ALTER TABLE public.board_subscription OWNER TO mini1;

--
-- Name: card; Type: TABLE; Schema: public; Owner: mini1
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
    comments_total integer NOT NULL,
    is_closed boolean NOT NULL,
    is_due_completed boolean
);


ALTER TABLE public.card OWNER TO mini1;

--
-- Name: card_label; Type: TABLE; Schema: public; Owner: mini1
--

CREATE TABLE public.card_label (
    id bigint DEFAULT public.next_id() NOT NULL,
    card_id bigint NOT NULL,
    label_id bigint NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


ALTER TABLE public.card_label OWNER TO mini1;

--
-- Name: card_membership; Type: TABLE; Schema: public; Owner: mini1
--

CREATE TABLE public.card_membership (
    id bigint DEFAULT public.next_id() NOT NULL,
    card_id bigint NOT NULL,
    user_id bigint NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


ALTER TABLE public.card_membership OWNER TO mini1;

--
-- Name: card_subscription; Type: TABLE; Schema: public; Owner: mini1
--

CREATE TABLE public.card_subscription (
    id bigint DEFAULT public.next_id() NOT NULL,
    card_id bigint NOT NULL,
    user_id bigint NOT NULL,
    is_permanent boolean NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


ALTER TABLE public.card_subscription OWNER TO mini1;

--
-- Name: comment; Type: TABLE; Schema: public; Owner: mini1
--

CREATE TABLE public.comment (
    id bigint DEFAULT public.next_id() NOT NULL,
    card_id bigint NOT NULL,
    user_id bigint,
    text text NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


ALTER TABLE public.comment OWNER TO mini1;

--
-- Name: config; Type: TABLE; Schema: public; Owner: mini1
--

CREATE TABLE public.config (
    id bigint DEFAULT public.next_id() NOT NULL,
    is_initialized boolean NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    smtp_host text,
    smtp_port integer,
    smtp_name text,
    smtp_secure boolean NOT NULL,
    smtp_tls_reject_unauthorized boolean NOT NULL,
    smtp_user text,
    smtp_password text,
    smtp_from text
);


ALTER TABLE public.config OWNER TO mini1;

--
-- Name: custom_field; Type: TABLE; Schema: public; Owner: mini1
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


ALTER TABLE public.custom_field OWNER TO mini1;

--
-- Name: custom_field_group; Type: TABLE; Schema: public; Owner: mini1
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


ALTER TABLE public.custom_field_group OWNER TO mini1;

--
-- Name: custom_field_value; Type: TABLE; Schema: public; Owner: mini1
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


ALTER TABLE public.custom_field_value OWNER TO mini1;

--
-- Name: identity_provider_user; Type: TABLE; Schema: public; Owner: mini1
--

CREATE TABLE public.identity_provider_user (
    id bigint DEFAULT public.next_id() NOT NULL,
    user_id bigint NOT NULL,
    issuer text NOT NULL,
    sub text NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


ALTER TABLE public.identity_provider_user OWNER TO mini1;

--
-- Name: label; Type: TABLE; Schema: public; Owner: mini1
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


ALTER TABLE public.label OWNER TO mini1;

--
-- Name: list; Type: TABLE; Schema: public; Owner: mini1
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


ALTER TABLE public.list OWNER TO mini1;

--
-- Name: migration; Type: TABLE; Schema: public; Owner: mini1
--

CREATE TABLE public.migration (
    id integer NOT NULL,
    name character varying(255),
    batch integer,
    migration_time timestamp with time zone
);


ALTER TABLE public.migration OWNER TO mini1;

--
-- Name: migration_id_seq; Type: SEQUENCE; Schema: public; Owner: mini1
--

CREATE SEQUENCE public.migration_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.migration_id_seq OWNER TO mini1;

--
-- Name: migration_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: mini1
--

ALTER SEQUENCE public.migration_id_seq OWNED BY public.migration.id;


--
-- Name: migration_lock; Type: TABLE; Schema: public; Owner: mini1
--

CREATE TABLE public.migration_lock (
    index integer NOT NULL,
    is_locked integer
);


ALTER TABLE public.migration_lock OWNER TO mini1;

--
-- Name: migration_lock_index_seq; Type: SEQUENCE; Schema: public; Owner: mini1
--

CREATE SEQUENCE public.migration_lock_index_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.migration_lock_index_seq OWNER TO mini1;

--
-- Name: migration_lock_index_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: mini1
--

ALTER SEQUENCE public.migration_lock_index_seq OWNED BY public.migration_lock.index;


--
-- Name: next_id_seq; Type: SEQUENCE; Schema: public; Owner: mini1
--

CREATE SEQUENCE public.next_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.next_id_seq OWNER TO mini1;

--
-- Name: notification; Type: TABLE; Schema: public; Owner: mini1
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


ALTER TABLE public.notification OWNER TO mini1;

--
-- Name: notification_service; Type: TABLE; Schema: public; Owner: mini1
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


ALTER TABLE public.notification_service OWNER TO mini1;

--
-- Name: project; Type: TABLE; Schema: public; Owner: mini1
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


ALTER TABLE public.project OWNER TO mini1;

--
-- Name: project_favorite; Type: TABLE; Schema: public; Owner: mini1
--

CREATE TABLE public.project_favorite (
    id bigint DEFAULT public.next_id() NOT NULL,
    project_id bigint NOT NULL,
    user_id bigint NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


ALTER TABLE public.project_favorite OWNER TO mini1;

--
-- Name: project_manager; Type: TABLE; Schema: public; Owner: mini1
--

CREATE TABLE public.project_manager (
    id bigint DEFAULT public.next_id() NOT NULL,
    project_id bigint NOT NULL,
    user_id bigint NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


ALTER TABLE public.project_manager OWNER TO mini1;

--
-- Name: session; Type: TABLE; Schema: public; Owner: mini1
--

CREATE TABLE public.session (
    id bigint DEFAULT public.next_id() NOT NULL,
    user_id bigint NOT NULL,
    access_token text,
    http_only_token text,
    remote_address text NOT NULL,
    user_agent text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    deleted_at timestamp without time zone,
    pending_token text
);


ALTER TABLE public.session OWNER TO mini1;

--
-- Name: storage_usage; Type: TABLE; Schema: public; Owner: mini1
--

CREATE TABLE public.storage_usage (
    id bigint DEFAULT public.next_id() NOT NULL,
    total bigint NOT NULL,
    user_avatars bigint NOT NULL,
    background_images bigint NOT NULL,
    attachments bigint NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


ALTER TABLE public.storage_usage OWNER TO mini1;

--
-- Name: task; Type: TABLE; Schema: public; Owner: mini1
--

CREATE TABLE public.task (
    id bigint DEFAULT public.next_id() NOT NULL,
    task_list_id bigint NOT NULL,
    assignee_user_id bigint,
    "position" double precision NOT NULL,
    name text NOT NULL,
    is_completed boolean NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    linked_card_id bigint
);


ALTER TABLE public.task OWNER TO mini1;

--
-- Name: task_list; Type: TABLE; Schema: public; Owner: mini1
--

CREATE TABLE public.task_list (
    id bigint DEFAULT public.next_id() NOT NULL,
    card_id bigint NOT NULL,
    "position" double precision NOT NULL,
    name text NOT NULL,
    show_on_front_of_card boolean NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    hide_completed_tasks boolean NOT NULL
);


ALTER TABLE public.task_list OWNER TO mini1;

--
-- Name: uploaded_file; Type: TABLE; Schema: public; Owner: mini1
--

CREATE TABLE public.uploaded_file (
    id text DEFAULT public.next_id() NOT NULL,
    references_total integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    type text NOT NULL,
    mime_type text,
    size bigint NOT NULL
);


ALTER TABLE public.uploaded_file OWNER TO mini1;

--
-- Name: user_account; Type: TABLE; Schema: public; Owner: mini1
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
    password_changed_at timestamp without time zone,
    terms_signature text,
    terms_accepted_at timestamp without time zone,
    api_key_prefix text,
    api_key_hash text,
    api_key_created_at timestamp without time zone
);


ALTER TABLE public.user_account OWNER TO mini1;

--
-- Name: webhook; Type: TABLE; Schema: public; Owner: mini1
--

CREATE TABLE public.webhook (
    id bigint DEFAULT public.next_id() NOT NULL,
    board_id bigint,
    name text NOT NULL,
    url text NOT NULL,
    access_token text,
    events text[],
    excluded_events text[],
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


ALTER TABLE public.webhook OWNER TO mini1;

--
-- Name: migration id; Type: DEFAULT; Schema: public; Owner: mini1
--

ALTER TABLE ONLY public.migration ALTER COLUMN id SET DEFAULT nextval('public.migration_id_seq'::regclass);


--
-- Name: migration_lock index; Type: DEFAULT; Schema: public; Owner: mini1
--

ALTER TABLE ONLY public.migration_lock ALTER COLUMN index SET DEFAULT nextval('public.migration_lock_index_seq'::regclass);


--
-- Data for Name: hypertable; Type: TABLE DATA; Schema: _timescaledb_catalog; Owner: postgres
--

COPY _timescaledb_catalog.hypertable (id, schema_name, table_name, associated_schema_name, associated_table_prefix, num_dimensions, chunk_sizing_func_schema, chunk_sizing_func_name, chunk_target_size, compression_state, compressed_hypertable_id, status) FROM stdin;
\.


--
-- Data for Name: chunk; Type: TABLE DATA; Schema: _timescaledb_catalog; Owner: postgres
--

COPY _timescaledb_catalog.chunk (id, hypertable_id, schema_name, table_name, compressed_chunk_id, dropped, status, osm_chunk, creation_time) FROM stdin;
\.


--
-- Data for Name: chunk_column_stats; Type: TABLE DATA; Schema: _timescaledb_catalog; Owner: postgres
--

COPY _timescaledb_catalog.chunk_column_stats (id, hypertable_id, chunk_id, column_name, range_start, range_end, valid) FROM stdin;
\.


--
-- Data for Name: dimension; Type: TABLE DATA; Schema: _timescaledb_catalog; Owner: postgres
--

COPY _timescaledb_catalog.dimension (id, hypertable_id, column_name, column_type, aligned, num_slices, partitioning_func_schema, partitioning_func, interval_length, compress_interval_length, integer_now_func_schema, integer_now_func) FROM stdin;
\.


--
-- Data for Name: dimension_slice; Type: TABLE DATA; Schema: _timescaledb_catalog; Owner: postgres
--

COPY _timescaledb_catalog.dimension_slice (id, dimension_id, range_start, range_end) FROM stdin;
\.


--
-- Data for Name: chunk_constraint; Type: TABLE DATA; Schema: _timescaledb_catalog; Owner: postgres
--

COPY _timescaledb_catalog.chunk_constraint (chunk_id, dimension_slice_id, constraint_name, hypertable_constraint_name) FROM stdin;
\.


--
-- Data for Name: compression_chunk_size; Type: TABLE DATA; Schema: _timescaledb_catalog; Owner: postgres
--

COPY _timescaledb_catalog.compression_chunk_size (chunk_id, compressed_chunk_id, uncompressed_heap_size, uncompressed_toast_size, uncompressed_index_size, compressed_heap_size, compressed_toast_size, compressed_index_size, numrows_pre_compression, numrows_post_compression, numrows_frozen_immediately) FROM stdin;
\.


--
-- Data for Name: compression_settings; Type: TABLE DATA; Schema: _timescaledb_catalog; Owner: postgres
--

COPY _timescaledb_catalog.compression_settings (relid, compress_relid, segmentby, orderby, orderby_desc, orderby_nullsfirst, index) FROM stdin;
\.


--
-- Data for Name: continuous_agg; Type: TABLE DATA; Schema: _timescaledb_catalog; Owner: postgres
--

COPY _timescaledb_catalog.continuous_agg (mat_hypertable_id, raw_hypertable_id, parent_mat_hypertable_id, user_view_schema, user_view_name, partial_view_schema, partial_view_name, direct_view_schema, direct_view_name, materialized_only, finalized) FROM stdin;
\.


--
-- Data for Name: continuous_agg_migrate_plan; Type: TABLE DATA; Schema: _timescaledb_catalog; Owner: postgres
--

COPY _timescaledb_catalog.continuous_agg_migrate_plan (mat_hypertable_id, start_ts, end_ts, user_view_definition) FROM stdin;
\.


--
-- Data for Name: continuous_agg_migrate_plan_step; Type: TABLE DATA; Schema: _timescaledb_catalog; Owner: postgres
--

COPY _timescaledb_catalog.continuous_agg_migrate_plan_step (mat_hypertable_id, step_id, status, start_ts, end_ts, type, config) FROM stdin;
\.


--
-- Data for Name: continuous_aggs_bucket_function; Type: TABLE DATA; Schema: _timescaledb_catalog; Owner: postgres
--

COPY _timescaledb_catalog.continuous_aggs_bucket_function (mat_hypertable_id, bucket_func, bucket_width, bucket_origin, bucket_offset, bucket_timezone, bucket_fixed_width) FROM stdin;
\.


--
-- Data for Name: continuous_aggs_hypertable_invalidation_log; Type: TABLE DATA; Schema: _timescaledb_catalog; Owner: postgres
--

COPY _timescaledb_catalog.continuous_aggs_hypertable_invalidation_log (hypertable_id, lowest_modified_value, greatest_modified_value) FROM stdin;
\.


--
-- Data for Name: continuous_aggs_invalidation_threshold; Type: TABLE DATA; Schema: _timescaledb_catalog; Owner: postgres
--

COPY _timescaledb_catalog.continuous_aggs_invalidation_threshold (hypertable_id, watermark) FROM stdin;
\.


--
-- Data for Name: continuous_aggs_materialization_invalidation_log; Type: TABLE DATA; Schema: _timescaledb_catalog; Owner: postgres
--

COPY _timescaledb_catalog.continuous_aggs_materialization_invalidation_log (materialization_id, lowest_modified_value, greatest_modified_value) FROM stdin;
\.


--
-- Data for Name: continuous_aggs_materialization_ranges; Type: TABLE DATA; Schema: _timescaledb_catalog; Owner: postgres
--

COPY _timescaledb_catalog.continuous_aggs_materialization_ranges (materialization_id, lowest_modified_value, greatest_modified_value) FROM stdin;
\.


--
-- Data for Name: continuous_aggs_watermark; Type: TABLE DATA; Schema: _timescaledb_catalog; Owner: postgres
--

COPY _timescaledb_catalog.continuous_aggs_watermark (mat_hypertable_id, watermark) FROM stdin;
\.


--
-- Data for Name: metadata; Type: TABLE DATA; Schema: _timescaledb_catalog; Owner: postgres
--

COPY _timescaledb_catalog.metadata (key, value, include_in_telemetry) FROM stdin;
install_timestamp	2025-12-20 00:05:08.295108+00	t
timescaledb_version	2.24.0	f
exported_uuid	ebb582a3-7a7b-445c-8c01-c7e8272d8d8a	t
\.


--
-- Data for Name: tablespace; Type: TABLE DATA; Schema: _timescaledb_catalog; Owner: postgres
--

COPY _timescaledb_catalog.tablespace (id, hypertable_id, tablespace_name) FROM stdin;
\.


--
-- Data for Name: bgw_job; Type: TABLE DATA; Schema: _timescaledb_config; Owner: postgres
--

COPY _timescaledb_config.bgw_job (id, application_name, schedule_interval, max_runtime, max_retries, retry_period, proc_schema, proc_name, owner, scheduled, fixed_schedule, initial_start, hypertable_id, config, check_schema, check_name, timezone) FROM stdin;
\.


--
-- Data for Name: action; Type: TABLE DATA; Schema: public; Owner: mini1
--

COPY public.action (id, card_id, user_id, type, data, created_at, updated_at, board_id) FROM stdin;
1566011327149769792	1566011327091049535	1560278692305830913	createCard	{"card": {"name": "test"}, "list": {"id": "1566004621732742167", "name": "TODO", "type": "active"}}	2025-07-30 11:24:57.736	\N	1541385320996537361
1566031207873905757	1566011327091049535	1560328737491256322	moveCard	{"card": {"name": "test"}, "toList": {"id": "1566004621741130776", "name": "READY", "type": "active"}, "fromList": {"id": "1566004621732742167", "name": "TODO", "type": "active"}}	2025-07-30 12:04:27.702	\N	1541385320996537361
1566031272583627871	1566011327091049535	1560328737491256322	moveCard	{"card": {"name": "test"}, "toList": {"id": "1566004621732742167", "name": "TODO", "type": "active"}, "fromList": {"id": "1566004621741130776", "name": "READY", "type": "active"}}	2025-07-30 12:04:35.417	\N	1541385320996537361
1566031331001893985	1566011327091049535	1560328737491256322	moveCard	{"card": {"name": "test"}, "toList": {"id": "1566004621741130776", "name": "READY", "type": "active"}, "fromList": {"id": "1566004621732742167", "name": "TODO", "type": "active"}}	2025-07-30 12:04:42.38	\N	1541385320996537361
1566031382063350883	1566011327091049535	1560328737491256322	moveCard	{"card": {"name": "test"}, "toList": {"id": "1566004621732742167", "name": "TODO", "type": "active"}, "fromList": {"id": "1566004621741130776", "name": "READY", "type": "active"}}	2025-07-30 12:04:48.468	\N	1541385320996537361
1566034264774935664	1566034264749769839	1560328737491256322	createCard	{"card": {"name": "test"}, "list": {"id": "1566000088495424528", "name": "TODO", "type": "active"}}	2025-07-30 12:10:32.115	\N	1565999911277691916
1653695343876900229	1653695338323641732	1560328737491256322	createCard	{"card": {"name": "Test Card 1764327446297"}, "list": {"id": "1653695337761604995", "name": "To Do", "type": "active"}}	2025-11-28 10:57:27.048	\N	1653695336411039103
1653695522386478480	1653695522285815183	1560328737491256322	createCard	{"card": {"name": "Test Card 1764327468228"}, "list": {"id": "1653695521698612622", "name": "To Do", "type": "active"}}	2025-11-28 10:57:48.328	\N	1653695520348046730
1653696113682679197	1653696113531684252	1560328737491256322	createCard	{"card": {"name": "Test Card 1764327538704"}, "list": {"id": "1653696112936093083", "name": "To Do", "type": "active"}}	2025-11-28 10:58:58.812	\N	1653696111543584151
1653696661626553769	1653696661500724648	1560328737491256322	createCard	{"card": {"name": "Test Card 1764327604009"}, "list": {"id": "1653696660770915751", "name": "To Do", "type": "active"}}	2025-11-28 11:00:04.132	\N	1653696659168691619
1654047141334615509	1654047141141677524	1560328737491256322	createCard	{"card": {"name": "Test Card 1764369384520"}, "list": {"id": "1654047140403480019", "name": "To Do", "type": "active"}}	2025-11-28 22:36:24.609	\N	1654047138868364751
1654034713687360948	1654034713234376115	1560328737491256322	createCard	{"card": {"name": "Test Card 1764367902977"}, "list": {"id": "1654034712454235570", "name": "To Do", "type": "active"}}	2025-11-28 22:11:43.116	\N	1654034710910731694
1627548744608122480	1627548744566179439	1560328737491256322	createCard	{"card": {"name": "fwe"}, "list": {"id": "1573201068957894398", "name": "TODO", "type": "active"}}	2025-10-23 09:08:49.553	\N	1573201068874008314
1635621825411024644	1635621824966428401	1560328737491256322	createCard	{"card": {"name": "Template_Card (copy)"}, "list": {"id": "1573201068957894398", "name": "TODO", "type": "active"}}	2025-11-03 12:28:35.78	\N	1573201068874008314
1654035099546551743	1654035099429111230	1560328737491256322	createCard	{"card": {"name": "Test Card 1764367949032"}, "list": {"id": "1654035098791577021", "name": "To Do", "type": "active"}}	2025-11-28 22:12:29.117	\N	1654035097298404793
1654036099225355722	1654036099074360777	1560328737491256322	createCard	{"card": {"name": "Test Card 1764368068205"}, "list": {"id": "1654036098478769608", "name": "To Do", "type": "active"}}	2025-11-28 22:14:28.287	\N	1654036096985597380
1654047320330733024	1654047320230069727	1560328737491256322	createCard	{"card": {"name": "Test Card 1764369405887"}, "list": {"id": "1654047319626089950", "name": "To Do", "type": "active"}}	2025-11-28 22:36:45.949	\N	1654047318191637978
1686500600704927526	1654047320230069727	1560328737491256322	moveCard	{"card": {"name": "Test Card 1764369405887"}, "toList": {"id": "1686500351345166112", "name": "READY", "type": "active"}, "fromList": {"id": "1654047319626089950", "name": "TODO", "type": "active"}}	2026-01-12 17:15:38.435	\N	1654047318191637978
1686500611484288807	1654047320230069727	1560328737491256322	moveCard	{"card": {"name": "Test Card 1764369405887"}, "toList": {"id": "1654047319626089950", "name": "TODO", "type": "active"}, "fromList": {"id": "1686500351345166112", "name": "READY", "type": "active"}}	2026-01-12 17:15:39.722	\N	1654047318191637978
1686500901646239528	1654047320230069727	1560328737491256322	moveCard	{"card": {"name": "Test Card 1764369405887"}, "toList": {"id": "1686500351345166112", "name": "READY", "type": "active"}, "fromList": {"id": "1654047319626089950", "name": "TODO", "type": "active"}}	2026-01-12 17:16:14.31	\N	1654047318191637978
1686502415999698730	1654047320230069727	1560328737491256322	moveCard	{"card": {"name": "Test Card 1764369405887"}, "toList": {"id": "1654047319626089950", "name": "TODO", "type": "active"}, "fromList": {"id": "1686500351345166112", "name": "READY", "type": "active"}}	2026-01-12 17:19:14.836	\N	1654047318191637978
1689343984180135762	1689343983534212945	1560328737491256322	createCard	{"card": {"name": "Test Card 1768577095961"}, "list": {"id": "1689343980849858384", "name": "To Do", "type": "active"}}	2026-01-16 15:24:56.096	\N	1689343974952666956
1689345779543574365	1689345779426133852	1560328737491256322	createCard	{"card": {"name": "Test Card 1768577310054"}, "list": {"id": "1689345777932961627", "name": "To Do", "type": "active"}}	2026-01-16 15:28:30.181	\N	1689345775265384279
1689345824691062632	1689345824045139815	1560328737491256322	createCard	{"card": {"name": "Test Card 1768577315396"}, "list": {"id": "1689345823231444838", "name": "To Do", "type": "active"}}	2026-01-16 15:28:35.564	\N	1689345821436282722
1689347040175196019	1689347039436998514	1560328737491256322	createCard	{"card": {"name": "Test Card 1768577459780"}, "list": {"id": "1689347034378667889", "name": "To Do", "type": "active"}}	2026-01-16 15:31:00.461	\N	1689347031887251309
1689350331227441022	1689350331143554941	1560328737491256322	createCard	{"card": {"name": "Test Card 1768577852666"}, "list": {"id": "1689350330162087804", "name": "To Do", "type": "active"}}	2026-01-16 15:37:32.785	\N	1689350327721002872
1689350465436780425	1689350465352894344	1560328737491256322	createCard	{"card": {"name": "Test Card 1768577868683"}, "list": {"id": "1689350464539199367", "name": "To Do", "type": "active"}}	2026-01-16 15:37:48.784	\N	1689350462995695491
1689351147212507028	1689351146725967763	1560328737491256322	createCard	{"card": {"name": "Test Card 1768577949968"}, "list": {"id": "1689351146407200658", "name": "To Do", "type": "active"}}	2026-01-16 15:39:10.011	\N	1689351144813365134
1689351926774237087	1689351926698739614	1560328737491256322	createCard	{"card": {"name": "Test Card 1768578042889"}, "list": {"id": "1689351925876656029", "name": "To Do", "type": "active"}}	2026-01-16 15:40:42.99	\N	1689351924089882521
1689351965940647850	1689351965378611113	1560328737491256322	createCard	{"card": {"name": "Test Card 1768578047557"}, "list": {"id": "1689351964355200936", "name": "To Do", "type": "active"}}	2026-01-16 15:40:47.658	\N	1689351962048333732
1689478818521155509	1689478817724237748	1560328737491256322	createCard	{"card": {"name": "Test Card 1768593169372"}, "list": {"id": "1689478816021350323", "name": "To Do", "type": "active"}}	2026-01-16 19:52:49.665	\N	1689478809578899375
1689483604180076480	1689483603475433407	1560328737491256322	createCard	{"card": {"name": "Test Card 1768593739659"}, "list": {"id": "1689483599222409150", "name": "To Do", "type": "active"}}	2026-01-16 20:02:20.16	\N	1689483596672272314
1690085653955479502	1690085653863204813	1560328737491256322	createCard	{"card": {"name": "Test Card 1768665509977"}, "list": {"id": "1690085652923680716", "name": "To Do", "type": "active"}}	2026-01-17 15:58:30.086	\N	1690085642874128328
1692202951222757327	1627548744566179439	1560328737491256322	moveCard	{"card": {"name": "Template_Card"}, "toList": {"id": "1573201069058557695", "name": "READY", "type": "active"}, "fromList": {"id": "1573201068957894398", "name": "TODO", "type": "active"}}	2026-01-20 14:05:11.587	\N	1573201068874008314
1692203164201125841	1627548744566179439	1560328737491256322	moveCard	{"card": {"name": "Template_Card"}, "toList": {"id": "1573201068957894398", "name": "TODO", "type": "active"}, "fromList": {"id": "1573201069058557695", "name": "READY", "type": "active"}}	2026-01-20 14:05:36.976	\N	1573201068874008314
1706713451163812879	1706713451071538190	1560328737491256322	createCard	{"card": {"name": "Demo Card"}, "list": {"id": "1706713449553200141", "name": "To Do", "type": "active"}}	2026-02-09 14:34:57.977	\N	1706713448546567177
1706713505622656025	1706713505538769944	1560328737491256322	createCard	{"card": {"name": "Demo Card"}, "list": {"id": "1706713503861048343", "name": "To Do", "type": "active"}}	2026-02-09 14:35:04.469	\N	1706713502200103955
1706713609574286374	1706713609263907877	1560328737491256322	createCard	{"card": {"name": "Demo Card"}, "list": {"id": "1706713608710259748", "name": "To Do", "type": "active"}}	2026-02-09 14:35:16.86	\N	1706713607250641952
1706713715463685167	1706713715388187694	1560328737491256322	createCard	{"card": {"name": "Demo Card"}, "list": {"id": "1706713711118386221", "name": "To Do", "type": "active"}}	2026-02-09 14:35:29.485	\N	1706713708803130409
1706713769754756152	1706713769494709303	1560328737491256322	createCard	{"card": {"name": "Demo Card"}, "list": {"id": "1706713768983004214", "name": "To Do", "type": "active"}}	2026-02-09 14:35:35.935	\N	1706713768160920626
1706721990640927819	1706721990238274634	1560328737491256322	createCard	{"card": {"name": "Demo Card"}, "list": {"id": "1706721989089035337", "name": "To Do", "type": "active"}}	2026-02-09 14:51:55.962	\N	1706721988174677061
1706722042633520213	1706722042373473364	1560328737491256322	createCard	{"card": {"name": "Demo Card"}, "list": {"id": "1706722041878545491", "name": "To Do", "type": "active"}}	2026-02-09 14:52:02.16	\N	1706722040955798607
1706722146039891042	1706722145947616353	1560328737491256322	createCard	{"card": {"name": "Demo Card"}, "list": {"id": "1706722145427522656", "name": "To Do", "type": "active"}}	2026-02-09 14:52:14.486	\N	1706722144345392220
1706722249060385899	1706722248968111210	1560328737491256322	createCard	{"card": {"name": "Demo Card"}, "list": {"id": "1706722246518637673", "name": "To Do", "type": "active"}}	2026-02-09 14:52:26.768	\N	1706722243205137509
1706722301816341620	1706722301464020083	1560328737491256322	createCard	{"card": {"name": "Demo Card"}, "list": {"id": "1706722300784542834", "name": "To Do", "type": "active"}}	2026-02-09 14:52:33.025	\N	1706722300205728878
1706725909144274045	1706725909068776572	1560328737491256322	createCard	{"card": {"name": "Demo Card"}, "list": {"id": "1706725908531905659", "name": "To Do", "type": "active"}}	2026-02-09 14:59:43.084	\N	1706725906568971383
1706769438419715209	1706769438319051912	1560328737491256322	createCard	{"card": {"name": "Test Card 1770654371975"}, "list": {"id": "1706769436658107527", "name": "To Do", "type": "active"}}	2026-02-09 16:26:12.179	\N	1706769433613042819
\.


--
-- Data for Name: attachment; Type: TABLE DATA; Schema: public; Owner: mini1
--

COPY public.attachment (id, card_id, creator_user_id, type, data, name, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: background_image; Type: TABLE DATA; Schema: public; Owner: mini1
--

COPY public.background_image (id, project_id, uploaded_file_id, extension, size, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: base_custom_field_group; Type: TABLE DATA; Schema: public; Owner: mini1
--

COPY public.base_custom_field_group (id, project_id, name, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: board; Type: TABLE DATA; Schema: public; Owner: mini1
--

COPY public.board (id, project_id, "position", name, default_view, default_card_type, limit_card_types_to_default_one, always_display_card_creator, created_at, updated_at, expand_task_lists_by_default) FROM stdin;
1573201068874008314	1573201067548608248	1	EXECUTION	kanban	project	f	f	2025-08-09 09:29:41.74	\N	f
1653693153007371587	1653693149668705601	16384	Test Board 1764327185796	kanban	project	f	f	2025-11-28 10:53:05.88	\N	f
1653693368300995915	1653693365348205897	16384	Test Board 1764327211459	kanban	project	f	f	2025-11-28 10:53:31.547	\N	f
1653693448303150419	1653693445518132561	16384	Test Board 1764327221001	kanban	project	f	f	2025-11-28 10:53:41.084	\N	f
1653693548219860315	1653693545300624729	16384	Test Board 1764327232910	kanban	project	f	f	2025-11-28 10:53:52.995	\N	f
1653693669393302883	1653693666348238177	16384	Test Board 1764327247352	kanban	project	f	f	2025-11-28 10:54:07.438	\N	f
1653694225499293036	1653694222638777706	16384	Test Board 1764327313650	kanban	project	f	f	2025-11-28 10:55:13.731	\N	f
1653694386074027381	1653694383079294323	16384	Test Board 1764327332785	kanban	project	f	f	2025-11-28 10:55:32.871	\N	f
1653695336411039103	1653695333500192125	16384	Test Board 1764327446074	kanban	project	f	f	2025-11-28 10:57:26.158	\N	f
1653695520348046730	1653695517529474440	16384	Test Board 1764327467998	kanban	project	f	f	2025-11-28 10:57:48.085	\N	f
1653696111543584151	1653696108490130837	16384	Test Board 1764327538476	kanban	project	f	f	2025-11-28 10:58:58.56	\N	f
1653696659168691619	1653696655704196513	16384	Test Board 1764327603754	kanban	project	f	f	2025-11-28 11:00:03.839	\N	f
1654034710910731694	1654034706909365676	16384	Test Board 1764367902711	kanban	project	f	f	2025-11-28 22:11:42.782	\N	f
1654035097298404793	1654035094077179319	16384	Test Board 1764367948783	kanban	project	f	f	2025-11-28 22:12:28.849	\N	f
1654036096985597380	1654036093932144066	16384	Test Board 1764368067967	kanban	project	f	f	2025-11-28 22:14:28.022	\N	f
1654047138868364751	1654047135361926605	16384	Test Board 1764369384257	kanban	project	f	f	2025-11-28 22:36:24.3	\N	f
1654047318191637978	1654047314408375768	16384	Test Board 1764369405646	kanban	project	f	f	2025-11-28 22:36:45.694	\N	f
1686990512290006846	1686990505906276156	65535	Test Board	kanban	project	f	f	2026-01-13 09:29:00.448	\N	f
1689343974952666956	1689343960775919434	16384	Test Board 1768577094961	kanban	project	f	f	2026-01-16 15:24:55.058	\N	f
1689345775265384279	1689345763437446997	16384	Test Board 1768577309568	kanban	project	f	f	2026-01-16 15:28:29.67	\N	f
1689345821436282722	1689345808928868192	16384	Test Board 1768577315087	kanban	project	f	f	2026-01-16 15:28:35.176	\N	f
1689347031887251309	1689347017710503787	16384	Test Board 1768577459265	kanban	project	f	f	2026-01-16 15:30:59.47	\N	f
1689350327721002872	1689350319701493622	16384	Test Board 1768577852260	kanban	project	f	f	2026-01-16 15:37:32.367	\N	f
1689350462995695491	1689350457987696513	16384	Test Board 1768577868464	kanban	project	f	f	2026-01-16 15:37:48.494	\N	f
1689351144813365134	1689351138941339532	16384	Test Board 1768577949706	kanban	project	f	f	2026-01-16 15:39:09.773	\N	f
1689351924089882521	1689351918536624023	16384	Test Board 1768578042581	kanban	project	f	f	2026-01-16 15:40:42.669	\N	f
1689351962048333732	1689351953357735842	16384	Test Board 1768578047166	kanban	project	f	f	2026-01-16 15:40:47.195	\N	f
1689478809578899375	1689478798388496301	16384	Test Board 1768593168560	kanban	project	f	f	2026-01-16 19:52:48.598	\N	f
1689483596672272314	1689483585146324920	16384	Test Board 1768593739070	kanban	project	f	f	2026-01-16 20:02:19.266	\N	f
1690085642874128328	1690085633638270918	16384	Test Board 1768665508684	kanban	project	f	f	2026-01-17 15:58:28.763	\N	f
1706713448546567177	1706713447162446855	16384	Tasks Board	kanban	project	f	f	2026-02-09 14:34:57.663	\N	f
1706713502200103955	1706713500681765905	16384	Labels Board	kanban	project	f	f	2026-02-09 14:35:04.062	\N	f
1706713607250641952	1706713606260786206	16384	Membership Board	kanban	project	f	f	2026-02-09 14:35:16.585	\N	f
1706713708803130409	1706713707158963239	16384	Actions Board	kanban	project	f	f	2026-02-09 14:35:28.69	\N	f
1706713768160920626	1706713766323815472	16384	Fields Board	kanban	project	f	f	2026-02-09 14:35:35.767	\N	f
1706721988174677061	1706721985775535171	16384	Tasks Board	kanban	project	f	f	2026-02-09 14:51:55.666	\N	f
1706722040955798607	1706722039638787149	16384	Labels Board	kanban	project	f	f	2026-02-09 14:52:01.96	\N	f
1706722144345392220	1706722143615583322	16384	Membership Board	kanban	project	f	f	2026-02-09 14:52:14.285	\N	f
1706722243205137509	1706722242064286819	16384	Actions Board	kanban	project	f	f	2026-02-09 14:52:26.07	\N	f
1706722300205728878	1706722298502841452	16384	Fields Board	kanban	project	f	f	2026-02-09 14:52:32.865	\N	f
1706725906568971383	1706725905268737141	16384	Tasks Board	kanban	project	f	f	2026-02-09 14:59:42.776	\N	f
1706769433613042819	1706769420744918145	16384	Test Board 1770654371574	kanban	project	f	f	2026-02-09 16:26:11.606	\N	f
\.


--
-- Data for Name: board_membership; Type: TABLE DATA; Schema: public; Owner: mini1
--

COPY public.board_membership (id, project_id, board_id, user_id, role, can_comment, created_at, updated_at) FROM stdin;
1573201068882396923	1573201067548608248	1573201068874008314	1560328737491256322	editor	\N	2025-08-09 09:29:41.742	\N
1573201069377324804	1573201067548608248	1573201068874008314	1560328737491256323	editor	\N	2025-08-09 09:29:41.801	\N
1573201069486376709	1573201067548608248	1573201068874008314	1560328737491256324	viewer	t	2025-08-09 09:29:41.814	\N
1573201069553485574	1573201067548608248	1573201068874008314	1560328737491256325	viewer	t	2025-08-09 09:29:41.822	\N
1653693153082869060	1653693149668705601	1653693153007371587	1560328737491256322	editor	\N	2025-11-28 10:53:05.892	\N
1653693368351327564	1653693365348205897	1653693368300995915	1560328737491256322	editor	\N	2025-11-28 10:53:31.552	\N
1653693448336704852	1653693445518132561	1653693448303150419	1560328737491256322	editor	\N	2025-11-28 10:53:41.089	\N
1653693548261803356	1653693545300624729	1653693548219860315	1560328737491256322	editor	\N	2025-11-28 10:53:53	\N
1653693669452023140	1653693666348238177	1653693669393302883	1560328737491256322	editor	\N	2025-11-28 10:54:07.446	\N
1653694225558013293	1653694222638777706	1653694225499293036	1560328737491256322	editor	\N	2025-11-28 10:55:13.737	\N
1653694386115970422	1653694383079294323	1653694386074027381	1560328737491256322	editor	\N	2025-11-28 10:55:32.877	\N
1653695336452982144	1653695333500192125	1653695336411039103	1560328737491256322	editor	\N	2025-11-28 10:57:26.165	\N
1653695520398378379	1653695517529474440	1653695520348046730	1560328737491256322	editor	\N	2025-11-28 10:57:48.091	\N
1653696111585527192	1653696108490130837	1653696111543584151	1560328737491256322	editor	\N	2025-11-28 10:58:58.566	\N
1653696659227411876	1653696655704196513	1653696659168691619	1560328737491256322	editor	\N	2025-11-28 11:00:03.846	\N
1654047138935473616	1654047135361926605	1654047138868364751	1560328737491256322	editor	\N	2025-11-28 22:36:24.325	\N
1654034711003006383	1654034706909365676	1654034710910731694	1560328737491256322	editor	\N	2025-11-28 22:11:42.797	\N
1654035097348736442	1654035094077179319	1654035097298404793	1560328737491256322	editor	\N	2025-11-28 22:12:28.855	\N
1654036097027540421	1654036093932144066	1654036096985597380	1560328737491256322	editor	\N	2025-11-28 22:14:28.028	\N
1654047318258746843	1654047314408375768	1654047318191637978	1560328737491256322	editor	\N	2025-11-28 22:36:45.7	\N
1686990512340338495	1686990505906276156	1686990512290006846	1560328737491256322	editor	\N	2026-01-13 09:29:00.454	\N
1689343975019775821	1689343960775919434	1689343974952666956	1560328737491256322	editor	\N	2026-01-16 15:24:55.065	\N
1689345775307327320	1689345763437446997	1689345775265384279	1560328737491256322	editor	\N	2026-01-16 15:28:29.678	\N
1689345821478225763	1689345808928868192	1689345821436282722	1560328737491256322	editor	\N	2026-01-16 15:28:35.181	\N
1689347031945971566	1689347017710503787	1689347031887251309	1560328737491256322	editor	\N	2026-01-16 15:30:59.48	\N
1689350327746168697	1689350319701493622	1689350327721002872	1560328737491256322	editor	\N	2026-01-16 15:37:32.371	\N
1689350463029249924	1689350457987696513	1689350462995695491	1560328737491256322	editor	\N	2026-01-16 15:37:48.497	\N
1689351144846919567	1689351138941339532	1689351144813365134	1560328737491256322	editor	\N	2026-01-16 15:39:09.777	\N
1689351924115048346	1689351918536624023	1689351924089882521	1560328737491256322	editor	\N	2026-01-16 15:40:42.673	\N
1689351962081888165	1689351953357735842	1689351962048333732	1560328737491256322	editor	\N	2026-01-16 15:40:47.199	\N
1689478809620842416	1689478798388496301	1689478809578899375	1560328737491256322	editor	\N	2026-01-16 19:52:48.605	\N
1689483596714215355	1689483585146324920	1689483596672272314	1560328737491256322	editor	\N	2026-01-16 20:02:19.271	\N
1690085642916071369	1690085633638270918	1690085642874128328	1560328737491256322	editor	\N	2026-01-17 15:58:28.77	\N
1706713448596898826	1706713447162446855	1706713448546567177	1560328737491256322	editor	\N	2026-02-09 14:34:57.672	\N
1706713502267212820	1706713500681765905	1706713502200103955	1560328737491256322	editor	\N	2026-02-09 14:35:04.066	\N
1706713607284196385	1706713606260786206	1706713607250641952	1560328737491256322	editor	\N	2026-02-09 14:35:16.589	\N
1706713708845073450	1706713707158963239	1706713708803130409	1560328737491256322	editor	\N	2026-02-09 14:35:28.696	\N
1706713768202863667	1706713766323815472	1706713768160920626	1560328737491256322	editor	\N	2026-02-09 14:35:35.771	\N
1706721988225008710	1706721985775535171	1706721988174677061	1560328737491256322	editor	\N	2026-02-09 14:51:55.674	\N
1706722040997741648	1706722039638787149	1706722040955798607	1560328737491256322	editor	\N	2026-02-09 14:52:01.964	\N
1706722144370558045	1706722143615583322	1706722144345392220	1560328737491256322	editor	\N	2026-02-09 14:52:14.289	\N
1706722243238691942	1706722242064286819	1706722243205137509	1560328737491256322	editor	\N	2026-02-09 14:52:26.074	\N
1706722300239283311	1706722298502841452	1706722300205728878	1560328737491256322	editor	\N	2026-02-09 14:52:32.869	\N
1706725907265225848	1706725905268737141	1706725906568971383	1560328737491256322	editor	\N	2026-02-09 14:59:42.859	\N
1706769433646597252	1706769420744918145	1706769433613042819	1560328737491256322	editor	\N	2026-02-09 16:26:11.61	\N
\.


--
-- Data for Name: board_subscription; Type: TABLE DATA; Schema: public; Owner: mini1
--

COPY public.board_subscription (id, board_id, user_id, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: card; Type: TABLE DATA; Schema: public; Owner: mini1
--

COPY public.card (id, board_id, list_id, creator_user_id, prev_list_id, cover_attachment_id, type, "position", name, description, due_date, stopwatch, created_at, updated_at, list_changed_at, comments_total, is_closed, is_due_completed) FROM stdin;
1635621824966428401	1573201068874008314	1573201068957894398	1560328737491256322	\N	\N	project	131072	Example-Card	Context: This card is an example card.\n\nObjective: The objective of this card is to be an example for the creation of other cards\n\nAcceptance Criteria:\n\n```gherkin\nFeature: Kanban Card Example\nThe card example card provides guidance for creating other Kanban cards.\nIt must be sufficient, extensible, usable, and unambiguous.\n```\n\n```gherkin\nScenario: Example card provides an interpretation of the template to inform card creation\n  Given the card example is available\n  When I review the card example\n  Then I see the card example provides:\n    """\n    - A clear example of each field’s name\n    - For each field: an example\n    - For each field: an indication of the type of content that is expected\n    """\n```\n\n```gherkin\nScenario: Card example is usable as an example by card creators\n  Given someone is about to create a new card using the card template\n  When they open the card template\n  Then they should be able to use it as a reference of what information to supply in what location on the card\n```	\N	\N	2025-11-03 12:28:35.703	2025-11-03 12:34:59.795	2025-11-03 12:28:35.702	0	f	\N
1653695338323641732	1653695336411039103	1653695337761604995	1560328737491256322	\N	\N	project	16384	Test Card 1764327446297	Updated description	\N	\N	2025-11-28 10:57:26.388	2025-11-28 10:57:27.245	2025-11-28 10:57:26.387	0	f	\N
1653695522285815183	1653695520348046730	1653695521698612622	1560328737491256322	\N	\N	project	16384	Test Card 1764327468228	Updated description	\N	\N	2025-11-28 10:57:48.317	2025-11-28 10:57:48.508	2025-11-28 10:57:48.317	0	f	\N
1653696113531684252	1653696111543584151	1653696112936093083	1560328737491256322	\N	\N	project	16384	Test Card 1764327538704	Updated description	\N	\N	2025-11-28 10:58:58.797	2025-11-28 10:58:58.992	2025-11-28 10:58:58.797	0	f	\N
1653696661500724648	1653696659168691619	1653696660770915751	1560328737491256322	\N	\N	project	16384	Test Card 1764327604009	Updated description	\N	\N	2025-11-28 11:00:04.12	2025-11-28 11:00:04.342	2025-11-28 11:00:04.12	0	f	\N
1654034713234376115	1654034710910731694	1654034712454235570	1560328737491256322	\N	\N	project	16384	Test Card 1764367902977	Updated description	\N	\N	2025-11-28 22:11:43.058	2025-11-28 22:11:43.312	2025-11-28 22:11:43.057	0	f	\N
1654035099429111230	1654035097298404793	1654035098791577021	1560328737491256322	\N	\N	project	16384	Test Card 1764367949032	Updated description	\N	\N	2025-11-28 22:12:29.103	2025-11-28 22:12:29.312	2025-11-28 22:12:29.103	0	f	\N
1654036099074360777	1654036096985597380	1654036098478769608	1560328737491256322	\N	\N	project	16384	Test Card 1764368068205	Updated description	\N	\N	2025-11-28 22:14:28.27	2025-11-28 22:14:28.502	2025-11-28 22:14:28.269	0	f	\N
1654047141141677524	1654047138868364751	1654047140403480019	1560328737491256322	\N	\N	project	16384	Test Card 1764369384520	Updated description	\N	\N	2025-11-28 22:36:24.588	2025-11-28 22:36:24.813	2025-11-28 22:36:24.588	0	f	\N
1654047320230069727	1654047318191637978	1654047319626089950	1560328737491256322	\N	\N	project	65536	Test Card 1764369405887	Updated description	\N	\N	2025-11-28 22:36:45.938	2026-01-12 17:19:14.83	2026-01-12 17:19:14.826	0	f	\N
1689343983534212945	1689343974952666956	1689343980849858384	1560328737491256322	\N	\N	project	16384	Test Card 1768577095961	Updated description	\N	\N	2026-01-16 15:24:56.081	2026-01-16 15:24:57.069	2026-01-16 15:24:56.078	0	f	\N
1689345779426133852	1689345775265384279	1689345777932961627	1560328737491256322	\N	\N	project	16384	Test Card 1768577310054	Updated description	\N	\N	2026-01-16 15:28:30.169	2026-01-16 15:28:30.477	2026-01-16 15:28:30.167	0	f	\N
1689345824045139815	1689345821436282722	1689345823231444838	1560328737491256322	\N	\N	project	16384	Test Card 1768577315396	Updated description	\N	\N	2026-01-16 15:28:35.487	2026-01-16 15:28:35.788	2026-01-16 15:28:35.486	0	f	\N
1689347039436998514	1689347031887251309	1689347034378667889	1560328737491256322	\N	\N	project	16384	Test Card 1768577459780	Updated description	\N	\N	2026-01-16 15:31:00.374	2026-01-16 15:31:00.883	2026-01-16 15:31:00.371	0	f	\N
1689350331143554941	1689350327721002872	1689350330162087804	1560328737491256322	\N	\N	project	16384	Test Card 1768577852666	Updated description	\N	\N	2026-01-16 15:37:32.775	2026-01-16 15:37:33.062	2026-01-16 15:37:32.774	0	f	\N
1689350465352894344	1689350462995695491	1689350464539199367	1560328737491256322	\N	\N	project	16384	Test Card 1768577868683	Updated description	\N	\N	2026-01-16 15:37:48.774	2026-01-16 15:37:49.761	2026-01-16 15:37:48.772	0	f	\N
1689351146725967763	1689351144813365134	1689351146407200658	1560328737491256322	\N	\N	project	16384	Test Card 1768577949968	Updated description	\N	\N	2026-01-16 15:39:10.001	2026-01-16 15:39:10.302	2026-01-16 15:39:09.999	0	f	\N
1689351926698739614	1689351924089882521	1689351925876656029	1560328737491256322	\N	\N	project	16384	Test Card 1768578042889	Updated description	\N	\N	2026-01-16 15:40:42.98	2026-01-16 15:40:43.179	2026-01-16 15:40:42.979	0	f	\N
1689351965378611113	1689351962048333732	1689351964355200936	1560328737491256322	\N	\N	project	16384	Test Card 1768578047557	Updated description	\N	\N	2026-01-16 15:40:47.591	2026-01-16 15:40:47.804	2026-01-16 15:40:47.589	0	f	\N
1689478817724237748	1689478809578899375	1689478816021350323	1560328737491256322	\N	\N	project	16384	Test Card 1768593169372	Updated description	\N	\N	2026-01-16 19:52:49.57	2026-01-16 19:52:50.084	2026-01-16 19:52:49.567	0	f	\N
1689483603475433407	1689483596672272314	1689483599222409150	1560328737491256322	\N	\N	project	16384	Test Card 1768593739659	Updated description	\N	\N	2026-01-16 20:02:20.077	2026-01-16 20:02:20.475	2026-01-16 20:02:20.075	0	f	\N
1690085653863204813	1690085642874128328	1690085652923680716	1560328737491256322	\N	\N	project	16384	Test Card 1768665509977	Updated description	\N	\N	2026-01-17 15:58:30.075	2026-01-17 15:58:30.282	2026-01-17 15:58:30.072	0	f	\N
1627548744566179439	1573201068874008314	1573201068957894398	1560328737491256322	\N	\N	project	65536	Template_Card	Context: This card template serves to inform card creation in order to standardize cards so that card quality can be more easily assessed and card content can be processed programmatically.\n\nObjective: The objective of this card template is to inform the structure and intended use of a card.\n\nAcceptance Criteria:\n\n```gherkin\nFeature: Standard Kanban Card Template Definition\nThe card template defines the structure and guidance for creating Kanban cards.\nIt must be sufficient, extensible, usable, and unambiguous.\n```\n\n```gherkin\nScenario: Template defines required structure to inform card creation\n  Given the card template is available\n  When I review the template document\n  Then I see the template provides:\n    """\n    - A clear declaration of each field’s name\n    - For each field: whether it is mandatory or optional\n    - For each field: a description of its purpose (what information the card creator should provide)\n    - For each field: any constraints or formats (e.g., “must be one of …”, “date/time in UTC”, etc.)\n    - A note of fields which are type-specific (placeholders/extensions) vs base fields\n    - Guidance that the template is to be used for all card types (or to be extended by type-specific templates)\n    """\n```\n\n```gherkin\nScenario: Template supports extensibility for different card types\n  Given the template is defined as the base card template\n  When I consider future card types (e.g., flow-cards, task-cards, procedure-cards)\n  Then the template must allow for extension\n  And the base fields remain consistent while type-specific fields may be added\n  And the template must indicate how to add or mark type-specific placeholders\n  And the template must clearly distinguish which fields are universal and which are optional or type-specific\n```\n\n```gherkin\nScenario: Template is usable as a checklist by card creators\n  Given someone is about to create a new card using the template\n  When they open the template document\n  Then they should be able to use it as a checklist to ensure they supply all required information for the card\n  And they should clearly see which fields can be left blank and which must be filled\n  And they should clearly understand what goes into each required field\n```\n\n```gherkin\nScenario: Template is unambiguous and testable\n  Given the template defines the fields and structure\n  When I assess it as a reviewer\n  Then none of the field descriptions shall be ambiguous\n  And the constraints and formats must be specific enough to validate later\n  And the template must use consistent language and style so that any card creator or reviewer can interpret it the same way\n```\n\n```gherkin\nScenario: Template acceptance decision\n  Given the template is ready for review by stakeholders\n  When all criteria (structure definition, extensibility, usability, and clarity) are satisfied\n  Then the template shall be accepted as the standard base template for all Kanban cards\n  And this acceptance shall be recorded and versioned\n```	\N	\N	2025-10-23 09:08:49.548	2026-01-20 14:05:36.967	2026-01-20 14:05:36.963	2	f	\N
1706713451071538190	1706713448546567177	1706713449553200141	1560328737491256322	\N	\N	project	65535	Demo Card	\N	\N	\N	2026-02-09 14:34:57.966	\N	2026-02-09 14:34:57.964	0	f	\N
1706713505538769944	1706713502200103955	1706713503861048343	1560328737491256322	\N	\N	project	65535	Demo Card	\N	\N	\N	2026-02-09 14:35:04.459	\N	2026-02-09 14:35:04.371	0	f	\N
1706713609263907877	1706713607250641952	1706713608710259748	1560328737491256322	\N	\N	project	65535	Demo Card	\N	\N	\N	2026-02-09 14:35:16.824	\N	2026-02-09 14:35:16.823	0	f	\N
1706713715388187694	1706713708803130409	1706713711118386221	1560328737491256322	\N	\N	project	65535	Demo Card	\N	\N	\N	2026-02-09 14:35:29.475	\N	2026-02-09 14:35:29.473	0	f	\N
1706713769494709303	1706713768160920626	1706713768983004214	1560328737491256322	\N	\N	project	65535	Demo Card	\N	\N	\N	2026-02-09 14:35:35.925	\N	2026-02-09 14:35:35.923	0	f	\N
1706721990238274634	1706721988174677061	1706721989089035337	1560328737491256322	\N	\N	project	65535	Demo Card	\N	\N	\N	2026-02-09 14:51:55.913	\N	2026-02-09 14:51:55.912	0	f	\N
1706722042373473364	1706722040955798607	1706722041878545491	1560328737491256322	\N	\N	project	65535	Demo Card	\N	\N	\N	2026-02-09 14:52:02.129	\N	2026-02-09 14:52:02.128	0	f	\N
1706722145947616353	1706722144345392220	1706722145427522656	1560328737491256322	\N	\N	project	65535	Demo Card	\N	\N	\N	2026-02-09 14:52:14.476	\N	2026-02-09 14:52:14.474	0	f	\N
1706722248968111210	1706722243205137509	1706722246518637673	1560328737491256322	\N	\N	project	65535	Demo Card	\N	\N	\N	2026-02-09 14:52:26.717	\N	2026-02-09 14:52:26.715	0	f	\N
1706722301464020083	1706722300205728878	1706722300784542834	1560328737491256322	\N	\N	project	65535	Demo Card	\N	\N	\N	2026-02-09 14:52:33.015	\N	2026-02-09 14:52:33.014	0	f	\N
1706725909068776572	1706725906568971383	1706725908531905659	1560328737491256322	\N	\N	project	65535	Demo Card	\N	\N	\N	2026-02-09 14:59:43.075	\N	2026-02-09 14:59:43.073	0	f	\N
1706769438319051912	1706769433613042819	1706769436658107527	1560328737491256322	\N	\N	project	16384	Test Card 1770654371975	Updated description	\N	\N	2026-02-09 16:26:12.167	2026-02-09 16:26:12.388	2026-02-09 16:26:12.165	0	f	\N
\.


--
-- Data for Name: card_label; Type: TABLE DATA; Schema: public; Owner: mini1
--

COPY public.card_label (id, card_id, label_id, created_at, updated_at) FROM stdin;
1634823372326045403	1627548744566179439	1634823372175050458	2025-11-02 10:02:12.756	\N
1635621825092257522	1635621824966428401	1634823372175050458	2025-11-03 12:28:35.741	\N
\.


--
-- Data for Name: card_membership; Type: TABLE DATA; Schema: public; Owner: mini1
--

COPY public.card_membership (id, card_id, user_id, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: card_subscription; Type: TABLE DATA; Schema: public; Owner: mini1
--

COPY public.card_subscription (id, card_id, user_id, is_permanent, created_at, updated_at) FROM stdin;
1634801900509464274	1627548744566179439	1560328737491256322	t	2025-11-02 09:19:33.116	\N
1634802288759408342	1627548744566179439	1560328737491256323	t	2025-11-02 09:20:19.399	\N
\.


--
-- Data for Name: comment; Type: TABLE DATA; Schema: public; Owner: mini1
--

COPY public.comment (id, card_id, user_id, text, created_at, updated_at) FROM stdin;
1634802288608413396	1627548744566179439	1560328737491256323	@[admin_agent](1560328737491256322) you	2025-11-02 09:20:19.377	\N
1634801900140365520	1627548744566179439	1560328737491256322	@[admin_agent](1560328737491256322) who can help me?	2025-11-02 09:19:33.071	2025-11-03 12:23:12.268
\.


--
-- Data for Name: config; Type: TABLE DATA; Schema: public; Owner: mini1
--

COPY public.config (id, is_initialized, created_at, updated_at, smtp_host, smtp_port, smtp_name, smtp_secure, smtp_tls_reject_unauthorized, smtp_user, smtp_password, smtp_from) FROM stdin;
1	t	2025-11-07 08:29:22.464	\N	\N	\N	\N	f	t	\N	\N	\N
\.


--
-- Data for Name: custom_field; Type: TABLE DATA; Schema: public; Owner: mini1
--

COPY public.custom_field (id, base_custom_field_group_id, custom_field_group_id, "position", name, show_on_front_of_card, created_at, updated_at) FROM stdin;
1635422730473965284	\N	1635422566837389027	65536	Requirement 1	t	2025-11-03 05:53:01.812	2025-11-03 05:53:40.003
1635423419665221352	\N	1635423337154873063	65536	Principle 1	t	2025-11-03 05:54:23.973	\N
1635424561790977774	\N	1635424505201428205	65536	Decision 1	t	2025-11-03 05:56:40.125	\N
1635621825192920826	\N	1635621825192920823	65536	Requirement 1	t	2025-11-03 12:28:35.768	\N
1635621825192920827	\N	1635621825192920824	65536	Principle 1	t	2025-11-03 12:28:35.768	\N
1635621825192920828	\N	1635621825192920825	65536	Decision 1	t	2025-11-03 12:28:35.768	\N
1636624468346406787	\N	1636624468262520706	16384	repository_url	t	2025-11-04 21:40:40.133	\N
1636624468413515652	\N	1636624468262520706	65536	branch	t	2025-11-04 21:40:40.141	\N
1636624468463847301	\N	1636624468262520706	131072	project_id	t	2025-11-04 21:40:40.146	\N
1636624468547733383	\N	1636624468505790342	16384	file_path	t	2025-11-04 21:40:40.157	\N
1636624468589676424	\N	1636624468505790342	65536	issue_description	f	2025-11-04 21:40:40.162	\N
1636624468631619465	\N	1636624468505790342	131072	analysis_card_id	f	2025-11-04 21:40:40.167	\N
1636624468673562506	\N	1636624468505790342	196608	project_id	f	2025-11-04 21:40:40.171	\N
1636624468740671372	\N	1636624468707116939	16384	fix_card_id	f	2025-11-04 21:40:40.18	\N
1636624468774225805	\N	1636624468707116939	65536	test_command	f	2025-11-04 21:40:40.184	\N
1636624468816168846	\N	1636624468707116939	131072	project_id	f	2025-11-04 21:40:40.189	\N
1636629175731226551	\N	1636629175680894902	16384	repository_url	t	2025-11-04 21:50:01.297	\N
1636629175806724024	\N	1636629175680894902	65536	branch	t	2025-11-04 21:50:01.305	\N
1636629175873832889	\N	1636629175680894902	131072	project_id	t	2025-11-04 21:50:01.314	\N
1636629175949330363	\N	1636629175907387322	16384	file_path	t	2025-11-04 21:50:01.322	\N
1636629175982884796	\N	1636629175907387322	65536	issue_description	f	2025-11-04 21:50:01.327	\N
1636629176024827837	\N	1636629175907387322	131072	analysis_card_id	f	2025-11-04 21:50:01.331	\N
1636629176058382270	\N	1636629175907387322	196608	project_id	f	2025-11-04 21:50:01.336	\N
1636629176125491136	\N	1636629176091936703	16384	fix_card_id	f	2025-11-04 21:50:01.344	\N
1636629176159045569	\N	1636629176091936703	65536	test_command	f	2025-11-04 21:50:01.348	\N
1636629176192600002	\N	1636629176091936703	131072	project_id	f	2025-11-04 21:50:01.352	\N
1636635394634155995	\N	1636635394575435738	16384	repository_url	t	2025-11-04 22:02:22.648	\N
1636635394684487644	\N	1636635394575435738	65536	branch	t	2025-11-04 22:02:22.654	\N
1636635394759985117	\N	1636635394575435738	131072	project_id	t	2025-11-04 22:02:22.663	\N
1636635394827093983	\N	1636635394793539550	16384	file_path	t	2025-11-04 22:02:22.671	\N
1636635394860648416	\N	1636635394793539550	65536	issue_description	f	2025-11-04 22:02:22.675	\N
1636635394894202849	\N	1636635394793539550	131072	analysis_card_id	f	2025-11-04 22:02:22.679	\N
1636635394986477538	\N	1636635394793539550	196608	project_id	f	2025-11-04 22:02:22.689	\N
1636635395246524388	\N	1636635395112306659	16384	fix_card_id	f	2025-11-04 22:02:22.721	\N
1636635395280078821	\N	1636635395112306659	65536	test_command	f	2025-11-04 22:02:22.725	\N
1636635395330410470	\N	1636635395112306659	131072	project_id	f	2025-11-04 22:02:22.731	\N
1636639390413359103	\N	1636639390371416062	16384	repository_url	t	2025-11-04 22:10:18.982	\N
1636639390463689728	\N	1636639390371416062	65536	branch	t	2025-11-04 22:10:18.988	\N
1636639390505632769	\N	1636639390371416062	131072	project_id	t	2025-11-04 22:10:18.992	\N
1636639390572741635	\N	1636639390539187202	16384	file_path	t	2025-11-04 22:10:19.001	\N
1636639390606296068	\N	1636639390539187202	65536	issue_description	f	2025-11-04 22:10:19.005	\N
1636639390639850501	\N	1636639390539187202	131072	analysis_card_id	f	2025-11-04 22:10:19.009	\N
1636639390673404934	\N	1636639390539187202	196608	project_id	f	2025-11-04 22:10:19.013	\N
1636639390849565704	\N	1636639390715347975	16384	fix_card_id	f	2025-11-04 22:10:19.033	\N
1636639390891508745	\N	1636639390715347975	65536	test_command	f	2025-11-04 22:10:19.038	\N
1636639390941840394	\N	1636639390715347975	131072	project_id	f	2025-11-04 22:10:19.044	\N
\.


--
-- Data for Name: custom_field_group; Type: TABLE DATA; Schema: public; Owner: mini1
--

COPY public.custom_field_group (id, board_id, card_id, base_custom_field_group_id, "position", name, created_at, updated_at) FROM stdin;
1635422566837389027	\N	1627548744566179439	\N	65536	Requirements	2025-11-03 05:52:42.289	\N
1635423337154873063	\N	1627548744566179439	\N	131072	Principles	2025-11-03 05:54:14.135	\N
1635424505201428205	\N	1627548744566179439	\N	196608	Decisions	2025-11-03 05:56:33.376	\N
1635621825192920823	\N	1635621824966428401	\N	65536	Requirements	2025-11-03 12:28:35.766	\N
1635621825192920824	\N	1635621824966428401	\N	131072	Principles	2025-11-03 12:28:35.766	\N
1635621825192920825	\N	1635621824966428401	\N	196608	Decisions	2025-11-03 12:28:35.766	\N
1636624468262520706	1636624465494280050	\N	\N	16384	Repository Info	2025-11-04 21:40:40.123	\N
1636624468505790342	1636624465494280050	\N	\N	1	Fix Details	2025-11-04 21:40:40.152	\N
1636624468707116939	1636624465494280050	\N	\N	2	Validation Info	2025-11-04 21:40:40.176	\N
1636629175680894902	1636629173223032742	\N	\N	16384	Repository Info	2025-11-04 21:50:01.291	\N
1636629175907387322	1636629173223032742	\N	\N	1	Fix Details	2025-11-04 21:50:01.318	\N
1636629176091936703	1636629173223032742	\N	\N	2	Validation Info	2025-11-04 21:50:01.34	\N
1636635394575435738	1636635392016910282	\N	\N	16384	Repository Info	2025-11-04 22:02:22.641	\N
1636635394793539550	1636635392016910282	\N	\N	1	Fix Details	2025-11-04 22:02:22.667	\N
1636635395112306659	1636635392016910282	\N	\N	2	Validation Info	2025-11-04 22:02:22.705	\N
1636639390371416062	1636639387921942510	\N	\N	16384	Repository Info	2025-11-04 22:10:18.977	\N
1636639390539187202	1636639387921942510	\N	\N	1	Fix Details	2025-11-04 22:10:18.997	\N
1636639390715347975	1636639387921942510	\N	\N	2	Validation Info	2025-11-04 22:10:19.018	\N
\.


--
-- Data for Name: custom_field_value; Type: TABLE DATA; Schema: public; Owner: mini1
--

COPY public.custom_field_value (id, card_id, custom_field_group_id, custom_field_id, content, created_at, updated_at) FROM stdin;
1635422809402377957	1627548744566179439	1635422566837389027	1635422730473965284	Some requirement text	2025-11-03 05:53:11.22	2025-11-03 05:53:46.947
1635423497805104873	1627548744566179439	1635423337154873063	1635423419665221352	Some principle text	2025-11-03 05:54:33.287	\N
1635424605235578607	1627548744566179439	1635424505201428205	1635424561790977774	Some decision text	2025-11-03 05:56:45.304	\N
1635621825360692993	1635621824966428401	1635621825192920823	1635621825192920826	Cards inform all behavior related to the card	2025-11-03 12:28:35.774	2025-11-03 12:35:42.713
1635621825377470210	1635621824966428401	1635621825192920824	1635621825192920827	Cards are the Single Source Of Truth	2025-11-03 12:28:35.774	2025-11-03 12:36:30.302
1635621825377470211	1635621824966428401	1635621825192920825	1635621825192920828	Any information that does not fit on the card needs to be stored in the state store	2025-11-03 12:28:35.774	2025-11-03 12:36:56.344
\.


--
-- Data for Name: identity_provider_user; Type: TABLE DATA; Schema: public; Owner: mini1
--

COPY public.identity_provider_user (id, user_id, issuer, sub, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: label; Type: TABLE DATA; Schema: public; Owner: mini1
--

COPY public.label (id, board_id, "position", name, color, created_at, updated_at) FROM stdin;
1634823372175050458	1573201068874008314	65536	TEMPLATE	pirate-gold	2025-11-02 10:02:12.734	\N
1706713506327299098	1706713502200103955	65536	Updated Label	lagoon-blue	2026-02-09 14:35:04.554	2026-02-09 14:35:04.716
1706722043153613910	1706722040955798607	65536	Updated Label	lagoon-blue	2026-02-09 14:52:02.223	2026-02-09 14:52:02.486
\.


--
-- Data for Name: list; Type: TABLE DATA; Schema: public; Owner: mini1
--

COPY public.list (id, board_id, type, "position", name, color, created_at, updated_at) FROM stdin;
1573201068890785532	1573201068874008314	archive	\N	\N	\N	2025-08-09 09:29:41.743	\N
1573201068890785533	1573201068874008314	trash	\N	\N	\N	2025-08-09 09:29:41.743	\N
1573201068957894398	1573201068874008314	active	65536	TODO	\N	2025-08-09 09:29:41.751	\N
1573201069058557695	1573201068874008314	active	131072	READY	\N	2025-08-09 09:29:41.762	\N
1573201069100500736	1573201068874008314	active	196608	DOING	\N	2025-08-09 09:29:41.768	\N
1573201069150832385	1573201068874008314	active	262144	QA	\N	2025-08-09 09:29:41.774	\N
1573201069226329858	1573201068874008314	active	327680	BLOCKED	\N	2025-08-09 09:29:41.783	\N
1573201069268272899	1573201068874008314	active	393216	DONE	\N	2025-08-09 09:29:41.788	\N
1653693153250641221	1653693153007371587	archive	\N	\N	\N	2025-11-28 10:53:05.9	\N
1653693153267418438	1653693153007371587	trash	\N	\N	\N	2025-11-28 10:53:05.9	\N
1653693368418436429	1653693368300995915	archive	\N	\N	\N	2025-11-28 10:53:31.559	\N
1653693368418436430	1653693368300995915	trash	\N	\N	\N	2025-11-28 10:53:31.559	\N
1653693448387036501	1653693448303150419	archive	\N	\N	\N	2025-11-28 10:53:41.094	\N
1653693448387036502	1653693448303150419	trash	\N	\N	\N	2025-11-28 10:53:41.094	\N
1653693548320523613	1653693548219860315	archive	\N	\N	\N	2025-11-28 10:53:53.006	\N
1653693548328912222	1653693548219860315	trash	\N	\N	\N	2025-11-28 10:53:53.006	\N
1653693669510743397	1653693669393302883	archive	\N	\N	\N	2025-11-28 10:54:07.453	\N
1653693669510743398	1653693669393302883	trash	\N	\N	\N	2025-11-28 10:54:07.453	\N
1653694225608344942	1653694225499293036	archive	\N	\N	\N	2025-11-28 10:55:13.743	\N
1653694225608344943	1653694225499293036	trash	\N	\N	\N	2025-11-28 10:55:13.743	\N
1653694226942133616	1653694225499293036	active	16384	To Do	\N	2025-11-28 10:55:13.902	\N
1653694386166302071	1653694386074027381	archive	\N	\N	\N	2025-11-28 10:55:32.883	\N
1653694386174690680	1653694386074027381	trash	\N	\N	\N	2025-11-28 10:55:32.883	\N
1653694387483313529	1653694386074027381	active	16384	To Do	\N	2025-11-28 10:55:33.04	\N
1653695336511702401	1653695336411039103	archive	\N	\N	\N	2025-11-28 10:57:26.171	\N
1653695336511702402	1653695336411039103	trash	\N	\N	\N	2025-11-28 10:57:26.171	\N
1653695337761604995	1653695336411039103	active	16384	To Do	\N	2025-11-28 10:57:26.318	\N
1653695520440321420	1653695520348046730	archive	\N	\N	\N	2025-11-28 10:57:48.098	\N
1653695520448710029	1653695520348046730	trash	\N	\N	\N	2025-11-28 10:57:48.098	\N
1653695521698612622	1653695520348046730	active	16384	To Do	\N	2025-11-28 10:57:48.246	\N
1653696111627470233	1653696111543584151	archive	\N	\N	\N	2025-11-28 10:58:58.571	\N
1653696111635858842	1653696111543584151	trash	\N	\N	\N	2025-11-28 10:58:58.571	\N
1653696112936093083	1653696111543584151	active	16384	To Do	\N	2025-11-28 10:58:58.725	\N
1653696659269354917	1653696659168691619	archive	\N	\N	\N	2025-11-28 11:00:03.853	\N
1653696659269354918	1653696659168691619	trash	\N	\N	\N	2025-11-28 11:00:03.853	\N
1653696660770915751	1653696659168691619	active	16384	To Do	\N	2025-11-28 11:00:04.032	\N
1654034711070115248	1654034710910731694	archive	\N	\N	\N	2025-11-28 22:11:42.806	\N
1654034711086892465	1654034710910731694	trash	\N	\N	\N	2025-11-28 22:11:42.806	\N
1654034712454235570	1654034710910731694	active	16384	To Do	\N	2025-11-28 22:11:42.972	\N
1654035097399068091	1654035097298404793	archive	\N	\N	\N	2025-11-28 22:12:28.861	\N
1654035097407456700	1654035097298404793	trash	\N	\N	\N	2025-11-28 22:12:28.861	\N
1654035098791577021	1654035097298404793	active	16384	To Do	\N	2025-11-28 22:12:29.027	\N
1654036097077872070	1654036096985597380	archive	\N	\N	\N	2025-11-28 22:14:28.034	\N
1654036097077872071	1654036096985597380	trash	\N	\N	\N	2025-11-28 22:14:28.034	\N
1654036098478769608	1654036096985597380	active	16384	To Do	\N	2025-11-28 22:14:28.199	\N
1654047138985805265	1654047138868364751	archive	\N	\N	\N	2025-11-28 22:36:24.331	\N
1654047139002582482	1654047138868364751	trash	\N	\N	\N	2025-11-28 22:36:24.331	\N
1654047140403480019	1654047138868364751	active	16384	To Do	\N	2025-11-28 22:36:24.501	\N
1654047318300689884	1654047318191637978	archive	\N	\N	\N	2025-11-28 22:36:45.708	\N
1654047318300689885	1654047318191637978	trash	\N	\N	\N	2025-11-28 22:36:45.708	\N
1686500351345166112	1654047318191637978	active	81920	READY	\N	2026-01-12 17:15:08.709	\N
1654047319626089950	1654047318191637978	active	16384	TODO	\N	2025-11-28 22:36:45.865	2026-01-12 17:15:12.462
1686500398296205089	1654047318191637978	active	147456	DOING	\N	2026-01-12 17:15:14.217	\N
1686500425987000098	1654047318191637978	active	212992	QA	\N	2026-01-12 17:15:17.608	\N
1686500440541234979	1654047318191637978	active	278528	BLOCKED	\N	2026-01-12 17:15:19.343	\N
1686500451647751972	1654047318191637978	active	344064	DONE	\N	2026-01-12 17:15:20.667	\N
1686990512407447360	1686990512290006846	archive	\N	\N	\N	2026-01-13 09:29:00.46	\N
1686990512407447361	1686990512290006846	trash	\N	\N	\N	2026-01-13 09:29:00.46	\N
1689343975086884686	1689343974952666956	archive	\N	\N	\N	2026-01-16 15:24:55.073	\N
1689343975095273295	1689343974952666956	trash	\N	\N	\N	2026-01-16 15:24:55.073	\N
1689343980849858384	1689343974952666956	active	16384	To Do	\N	2026-01-16 15:24:55.761	\N
1689345775349270361	1689345775265384279	archive	\N	\N	\N	2026-01-16 15:28:29.682	\N
1689345775357658970	1689345775265384279	trash	\N	\N	\N	2026-01-16 15:28:29.682	\N
1689345777932961627	1689345775265384279	active	16384	To Do	\N	2026-01-16 15:28:29.991	\N
1689345821520168804	1689345821436282722	archive	\N	\N	\N	2026-01-16 15:28:35.186	\N
1689345821520168805	1689345821436282722	trash	\N	\N	\N	2026-01-16 15:28:35.186	\N
1689345823231444838	1689345821436282722	active	16384	To Do	\N	2026-01-16 15:28:35.39	\N
1689347031987914607	1689347031887251309	archive	\N	\N	\N	2026-01-16 15:30:59.485	\N
1689347031987914608	1689347031887251309	trash	\N	\N	\N	2026-01-16 15:30:59.485	\N
1689347034378667889	1689347031887251309	active	16384	To Do	\N	2026-01-16 15:30:59.77	\N
1689350327788111738	1689350327721002872	archive	\N	\N	\N	2026-01-16 15:37:32.375	\N
1689350327788111739	1689350327721002872	trash	\N	\N	\N	2026-01-16 15:37:32.375	\N
1689350330162087804	1689350327721002872	active	16384	To Do	\N	2026-01-16 15:37:32.578	\N
1689350463062804357	1689350462995695491	archive	\N	\N	\N	2026-01-16 15:37:48.501	\N
1689350463062804358	1689350462995695491	trash	\N	\N	\N	2026-01-16 15:37:48.501	\N
1689350464539199367	1689350462995695491	active	16384	To Do	\N	2026-01-16 15:37:48.677	\N
1689351144880474000	1689351144813365134	archive	\N	\N	\N	2026-01-16 15:39:09.781	\N
1689351144888862609	1689351144813365134	trash	\N	\N	\N	2026-01-16 15:39:09.781	\N
1689351146407200658	1689351144813365134	active	16384	To Do	\N	2026-01-16 15:39:09.962	\N
1689351924148602779	1689351924089882521	archive	\N	\N	\N	2026-01-16 15:40:42.677	\N
1689351924148602780	1689351924089882521	trash	\N	\N	\N	2026-01-16 15:40:42.677	\N
1689351925876656029	1689351924089882521	active	16384	To Do	\N	2026-01-16 15:40:42.883	\N
1689351962123831206	1689351962048333732	archive	\N	\N	\N	2026-01-16 15:40:47.203	\N
1689351962132219815	1689351962048333732	trash	\N	\N	\N	2026-01-16 15:40:47.203	\N
1689351964355200936	1689351962048333732	active	16384	To Do	\N	2026-01-16 15:40:47.47	\N
1689478809662785457	1689478809578899375	archive	\N	\N	\N	2026-01-16 19:52:48.61	\N
1689478809671174066	1689478809578899375	trash	\N	\N	\N	2026-01-16 19:52:48.61	\N
1689478816021350323	1689478809578899375	active	16384	To Do	\N	2026-01-16 19:52:49.367	\N
1689483597452412860	1689483596672272314	archive	\N	\N	\N	2026-01-16 20:02:19.359	\N
1689483597460801469	1689483596672272314	trash	\N	\N	\N	2026-01-16 20:02:19.359	\N
1689483599222409150	1689483596672272314	active	16384	To Do	\N	2026-01-16 20:02:19.57	\N
1690085642958014410	1690085642874128328	archive	\N	\N	\N	2026-01-17 15:58:28.775	\N
1690085642966403019	1690085642874128328	trash	\N	\N	\N	2026-01-17 15:58:28.775	\N
1690085652923680716	1690085642874128328	active	16384	To Do	\N	2026-01-17 15:58:29.963	\N
1706713448638841867	1706713448546567177	archive	\N	\N	\N	2026-02-09 14:34:57.677	\N
1706713448638841868	1706713448546567177	trash	\N	\N	\N	2026-02-09 14:34:57.677	\N
1706713449553200141	1706713448546567177	active	65535	To Do	\N	2026-02-09 14:34:57.785	\N
1706713502334321685	1706713502200103955	archive	\N	\N	\N	2026-02-09 14:35:04.076	\N
1706713502334321686	1706713502200103955	trash	\N	\N	\N	2026-02-09 14:35:04.076	\N
1706713503861048343	1706713502200103955	active	65535	To Do	\N	2026-02-09 14:35:04.26	\N
1706713607326139426	1706713607250641952	archive	\N	\N	\N	2026-02-09 14:35:16.593	\N
1706713607326139427	1706713607250641952	trash	\N	\N	\N	2026-02-09 14:35:16.593	\N
1706713608710259748	1706713607250641952	active	65535	To Do	\N	2026-02-09 14:35:16.758	\N
1706713708887016491	1706713708803130409	archive	\N	\N	\N	2026-02-09 14:35:28.701	\N
1706713708895405100	1706713708803130409	trash	\N	\N	\N	2026-02-09 14:35:28.701	\N
1706713711118386221	1706713708803130409	active	65535	To Do	\N	2026-02-09 14:35:28.966	\N
1706713768236418100	1706713768160920626	archive	\N	\N	\N	2026-02-09 14:35:35.776	\N
1706713768244806709	1706713768160920626	trash	\N	\N	\N	2026-02-09 14:35:35.776	\N
1706713768983004214	1706713768160920626	active	65535	To Do	\N	2026-02-09 14:35:35.865	\N
1706721988258563143	1706721988174677061	archive	\N	\N	\N	2026-02-09 14:51:55.679	\N
1706721988266951752	1706721988174677061	trash	\N	\N	\N	2026-02-09 14:51:55.679	\N
1706721989089035337	1706721988174677061	active	65535	To Do	\N	2026-02-09 14:51:55.777	\N
1706722041048073297	1706722040955798607	archive	\N	\N	\N	2026-02-09 14:52:01.971	\N
1706722041048073298	1706722040955798607	trash	\N	\N	\N	2026-02-09 14:52:01.971	\N
1706722041878545491	1706722040955798607	active	65535	To Do	\N	2026-02-09 14:52:02.07	\N
1706722144404112478	1706722144345392220	archive	\N	\N	\N	2026-02-09 14:52:14.293	\N
1706722144404112479	1706722144345392220	trash	\N	\N	\N	2026-02-09 14:52:14.293	\N
1706722145427522656	1706722144345392220	active	65535	To Do	\N	2026-02-09 14:52:14.415	\N
1706722243272246375	1706722243205137509	archive	\N	\N	\N	2026-02-09 14:52:26.079	\N
1706722243272246376	1706722243205137509	trash	\N	\N	\N	2026-02-09 14:52:26.079	\N
1706722246518637673	1706722243205137509	active	65535	To Do	\N	2026-02-09 14:52:26.464	\N
1706722300272837744	1706722300205728878	archive	\N	\N	\N	2026-02-09 14:52:32.873	\N
1706722300272837745	1706722300205728878	trash	\N	\N	\N	2026-02-09 14:52:32.873	\N
1706725907315557497	1706725906568971383	archive	\N	\N	\N	2026-02-09 14:59:42.866	\N
1706722300784542834	1706722300205728878	active	65535	To Do	\N	2026-02-09 14:52:32.934	\N
1706725907315557498	1706725906568971383	trash	\N	\N	\N	2026-02-09 14:59:42.866	\N
1706725908531905659	1706725906568971383	active	65535	To Do	\N	2026-02-09 14:59:43.012	\N
1706769433680151685	1706769433613042819	archive	\N	\N	\N	2026-02-09 16:26:11.614	\N
1706769433688540294	1706769433613042819	trash	\N	\N	\N	2026-02-09 16:26:11.614	\N
1706769436658107527	1706769433613042819	active	16384	To Do	\N	2026-02-09 16:26:11.969	\N
\.


--
-- Data for Name: migration; Type: TABLE DATA; Schema: public; Owner: mini1
--

COPY public.migration (id, name, batch, migration_time) FROM stdin;
1	20250228000022_version_2.js	1	2025-07-22 13:35:14.35+00
2	20250522151122_add_board_activity_log.js	1	2025-07-22 13:35:14.352+00
3	20250523131647_add_comments_counter.js	1	2025-07-22 13:35:14.353+00
4	20250603102521_canonicalize_locale_codes.js	1	2025-07-22 13:35:14.354+00
5	20250703122452_move_webhooks_configuration_from_environment_variable_to_ui.js	2	2025-11-07 08:29:22.424+00
6	20250708200908_persist_closed_state_per_card.js	2	2025-11-07 08:29:22.447+00
7	20250709160208_add_ability_to_link_tasks_to_cards.js	2	2025-11-07 08:29:22.45+00
8	20250721132312_add_ability_to_hide_completed_tasks.js	2	2025-11-07 08:29:22.454+00
9	20250728105713_add_legal_requirements.js	2	2025-11-07 08:29:22.469+00
10	20250820144730_track_storage_usage.js	2	2025-11-07 08:29:22.489+00
11	20250905101408_restore_toggleable_due_dates.js	2	2025-11-07 08:29:22.49+00
12	20250905205438_add_board_setting_to_expand_task_lists_by_default.js	2	2025-11-07 08:29:22.491+00
13	20250917123048_add_ability_to_configure_smtp_via_ui.js	2	2025-11-07 08:29:22.494+00
14	20251105104948_add_api_key_authentication.js	2	2025-11-07 08:29:22.496+00
\.


--
-- Data for Name: migration_lock; Type: TABLE DATA; Schema: public; Owner: mini1
--

COPY public.migration_lock (index, is_locked) FROM stdin;
1	0
\.


--
-- Data for Name: notification; Type: TABLE DATA; Schema: public; Owner: mini1
--

COPY public.notification (id, user_id, creator_user_id, board_id, card_id, comment_id, action_id, type, data, is_read, created_at, updated_at) FROM stdin;
1626890448008119599	1560328737491256325	1560328737491256322	1626139471911061302	1626139517612197737	\N	1626890447974565166	addMemberToCard	{"card": {"name": "Load Core Procedures for CODE_ANALYSIS"}, "user": {"id": "1560328737491256325", "name": "Meta Agent"}}	f	2025-10-22 11:20:54.484	\N
1634801900475909841	1560328737491256322	1560328737491256322	1573201068874008314	1627548744566179439	1634801900140365520	\N	mentionInComment	{"card": {"name": "fwe"}, "text": "@[admin_agent](1560328737491256322) hi"}	t	2025-11-02 09:19:33.112	2025-11-02 09:19:33.133
1634802288725853909	1560328737491256322	1560328737491256323	1573201068874008314	1627548744566179439	1634802288608413396	\N	mentionInComment	{"card": {"name": "fwe"}, "text": "@[admin_agent](1560328737491256322) you"}	t	2025-11-02 09:20:19.395	2025-11-02 09:20:29.296
1692202951826737104	1560328737491256323	1560328737491256322	1573201068874008314	1627548744566179439	\N	1692202951222757327	moveCard	{"card": {"name": "Template_Card"}, "toList": {"id": "1573201069058557695", "name": "READY", "type": "active"}, "fromList": {"id": "1573201068957894398", "name": "TODO", "type": "active"}}	f	2026-01-20 14:05:11.669	\N
1692203164301789138	1560328737491256323	1560328737491256322	1573201068874008314	1627548744566179439	\N	1692203164201125841	moveCard	{"card": {"name": "Template_Card"}, "toList": {"id": "1573201068957894398", "name": "TODO", "type": "active"}, "fromList": {"id": "1573201069058557695", "name": "READY", "type": "active"}}	f	2026-01-20 14:05:36.997	\N
\.


--
-- Data for Name: notification_service; Type: TABLE DATA; Schema: public; Owner: mini1
--

COPY public.notification_service (id, user_id, board_id, url, format, created_at, updated_at) FROM stdin;
1565999542187328521	1560278692305830913	\N	json://mini2.local:8634/api/v1/flow-events/webhook	markdown	2025-07-30 11:01:32.859	\N
1566022531410822231	\N	1541385320996537361	json://core-app:8634/api/v1/notifications/webhook	markdown	2025-07-30 11:47:13.388652	2025-07-30 12:08:07.365
1566022531410822232	\N	1541386488111957023	json://core-app:8634/api/v1/notifications/webhook	markdown	2025-07-30 11:47:13.388652	2025-07-30 12:08:15.742
1566022531410822233	\N	1541386853553275948	json://core-app:8634/api/v1/notifications/webhook	markdown	2025-07-30 11:47:13.388652	2025-07-30 12:08:23.596
1566033706831840358	\N	1566019210167977028	json://core-app:8634/api/v1/notifications/webhook	markdown	2025-07-30 12:09:25.602	\N
1566033750276441191	\N	1566019210167977027	json://core-app:8634/api/v1/notifications/webhook	markdown	2025-07-30 12:09:30.782	\N
1566033792991233128	\N	1565999911277691916	json://core-app:8634/api/v1/notifications/webhook	markdown	2025-07-30 12:09:35.874	\N
1566022633139471450	\N	1565999911277691916	json://core-app:8634/api/v1/notifications/webhook	markdown	2025-07-30 11:47:25.515868	2025-07-30 11:47:25.515868
1566022633139471451	\N	1566019210167977027	json://core-app:8634/api/v1/notifications/webhook	markdown	2025-07-30 11:47:25.515868	2025-07-30 11:47:25.515868
1566022633139471452	\N	1566019210167977028	json://core-app:8634/api/v1/notifications/webhook	markdown	2025-07-30 11:47:25.515868	2025-07-30 11:47:25.515868
\.


--
-- Data for Name: project; Type: TABLE DATA; Schema: public; Owner: mini1
--

COPY public.project (id, owner_project_manager_id, background_image_id, name, description, background_type, background_gradient, is_hidden, created_at, updated_at) FROM stdin;
1573201067548608248	\N	\N	Core Repository - Rearchitecture	\N	\N	\N	f	2025-08-09 09:29:41.572	\N
1653692626093737277	1653692626186011966	\N	Integration Test Project	\N	\N	\N	f	2025-11-28 10:52:03.069	2025-11-28 10:52:03.096
1653693149668705601	1653693149710648642	\N	Updated Project 1764327185713	\N	\N	\N	f	2025-11-28 10:53:05.485	2025-11-28 10:53:05.794
1653693365348205897	1653693365406926154	\N	Updated Project 1764327211386	\N	\N	\N	f	2025-11-28 10:53:31.195	2025-11-28 10:53:31.466
1653693445518132561	1653693445568464210	\N	Updated Project 1764327220939	\N	\N	\N	f	2025-11-28 10:53:40.751	2025-11-28 10:53:41.014
1653693545300624729	1653693545342567770	\N	Updated Project 1764327232841	\N	\N	\N	f	2025-11-28 10:53:52.647	2025-11-28 10:53:52.92
1653693666348238177	1653693666390181218	\N	Updated Project 1764327247277	\N	\N	\N	f	2025-11-28 10:54:07.076	2025-11-28 10:54:07.358
1653694222638777706	1653694222697497963	\N	Updated Project 1764327313585	\N	\N	\N	f	2025-11-28 10:55:13.39	2025-11-28 10:55:13.662
1653694383079294323	1653694383146403188	\N	Updated Project 1764327332718	\N	\N	\N	f	2025-11-28 10:55:32.512	2025-11-28 10:55:32.794
1653695333500192125	1653695333550523774	\N	Updated Project 1764327446001	\N	\N	\N	f	2025-11-28 10:57:25.812	2025-11-28 10:57:26.078
1653695517529474440	1653695517579806089	\N	Updated Project 1764327467930	\N	\N	\N	f	2025-11-28 10:57:47.749	2025-11-28 10:57:48.007
1653696108490130837	1653696108540462486	\N	Updated Project 1764327538408	\N	\N	\N	f	2025-11-28 10:58:58.195	2025-11-28 10:58:58.485
1653696655704196513	1653696655746139554	\N	Updated Project 1764327603687	\N	\N	\N	f	2025-11-28 11:00:03.426	2025-11-28 11:00:03.765
1654034706909365676	1654034706984863149	\N	Updated Project 1764367902622	\N	\N	\N	f	2025-11-28 22:11:42.303	2025-11-28 22:11:42.677
1654035094077179319	1654035094135899576	\N	Updated Project 1764367948714	\N	\N	\N	f	2025-11-28 22:12:28.465	2025-11-28 22:12:28.767
1654036093932144066	1654036093974087107	\N	Updated Project 1764368067900	\N	\N	\N	f	2025-11-28 22:14:27.659	2025-11-28 22:14:27.951
1654047135361926605	1654047135412258254	\N	Updated Project 1764369384185	\N	\N	\N	f	2025-11-28 22:36:23.898	2025-11-28 22:36:24.224
1654047314408375768	1654047314458707417	\N	Updated Project 1764369405568	\N	\N	\N	f	2025-11-28 22:36:45.243	2025-11-28 22:36:45.615
1686524948740310829	1686524948815808302	\N	Demo Project 1768241040862	\N	\N	\N	f	2026-01-12 18:04:00.942	2026-01-12 18:04:01.047
1706725905268737141	1706725905310680182	\N	Tasks Demo 1770649182582	\N	\N	\N	f	2026-02-09 14:59:42.621	2026-02-09 14:59:42.634
1686966615729506097	1686966615788226354	\N	Demo Project 1768293691675	\N	\N	\N	f	2026-01-13 08:41:31.755	2026-01-13 08:41:31.856
1686971307226302259	1686971307285022516	\N	Demo Project 1768294250953	\N	\N	\N	f	2026-01-13 08:50:51.024	2026-01-13 08:50:51.04
1686987487366350646	1686987488188434231	\N	Demo Project 1768296179672	\N	\N	\N	f	2026-01-13 09:22:59.758	2026-01-13 09:22:59.957
1706769420744918145	1706769420795249794	\N	Updated Project 1770654371462	\N	\N	\N	f	2026-02-09 16:26:10.072	2026-02-09 16:26:11.566
1686989338715359032	1686989338748913465	\N	Demo Project 1768296400513	\N	\N	\N	f	2026-01-13 09:26:40.546	2026-01-13 09:26:40.557
1686990505906276156	1686990505948219197	\N	Test Project	\N	\N	\N	f	2026-01-13 09:28:59.686	2026-01-13 09:28:59.748
1686992092804417346	1686992092846360387	\N	Demo Project 1768296728837	\N	\N	\N	f	2026-01-13 09:32:08.86	2026-01-13 09:32:08.871
1689343960775919434	1689343961539282763	\N	Updated Project 1768577094670	\N	\N	\N	f	2026-01-16 15:24:53.368	2026-01-16 15:24:54.864
1689345763437446997	1689345763479390038	\N	Updated Project 1768577309277	\N	\N	\N	f	2026-01-16 15:28:28.262	2026-01-16 15:28:29.472
1689345808928868192	1689345808962422625	\N	Updated Project 1768577314957	\N	\N	\N	f	2026-01-16 15:28:33.686	2026-01-16 15:28:35.073
1689347017710503787	1689347018339649388	\N	Updated Project 1768577458970	\N	\N	\N	f	2026-01-16 15:30:57.783	2026-01-16 15:30:59.163
1689350319701493622	1689350320104146807	\N	Updated Project 1768577852155	\N	\N	\N	f	2026-01-16 15:37:31.412	2026-01-16 15:37:32.184
1689350457987696513	1689350458021250946	\N	Updated Project 1768577868378	\N	\N	\N	f	2026-01-16 15:37:47.897	2026-01-16 15:37:48.403
1689351138941339532	1689351138974893965	\N	Updated Project 1768577949671	\N	\N	\N	f	2026-01-16 15:39:09.072	2026-01-16 15:39:09.696
1689351918536624023	1689351918570178456	\N	Updated Project 1768578042465	\N	\N	\N	f	2026-01-16 15:40:42.008	2026-01-16 15:40:42.569
1689351953357735842	1689351954280482723	\N	Updated Project 1768578047073	\N	\N	\N	f	2026-01-16 15:40:46.066	2026-01-16 15:40:47.101
1689478798388496301	1689478798447216558	\N	Updated Project 1768593168474	\N	\N	\N	f	2026-01-16 19:52:47.265	2026-01-16 19:52:48.507
1689483585146324920	1689483585188267961	\N	Updated Project 1768593738869	\N	\N	\N	f	2026-01-16 20:02:17.892	2026-01-16 20:02:18.973
1689894993243670466	1689894993285613507	\N	Demo Project 1768642781486	\N	\N	\N	f	2026-01-17 09:39:41.56	2026-01-17 09:39:41.572
1690085633638270918	1690085633688602567	\N	Updated Project 1768665508589	\N	\N	\N	f	2026-01-17 15:58:27.663	2026-01-17 15:58:28.673
1704726107284047828	1704726107342768085	\N	Custom Fields Demo 1770410788085	\N	\N	\N	f	2026-02-06 20:46:28.125	2026-02-06 20:46:28.141
1704788350109485015	1704788350159816664	\N	Demo Project 1770418208018	\N	\N	\N	f	2026-02-06 22:50:08.05	2026-02-06 22:50:08.064
1705853281646938075	1705853281688881116	\N	Demo Project 1770545157690	\N	\N	\N	f	2026-02-08 10:05:57.781	2026-02-08 10:05:57.796
1705866245301077981	1705866245343021022	\N	Demo Project 1770546703061	\N	\N	\N	f	2026-02-08 10:31:43.168	2026-02-08 10:31:43.181
1705968297784117216	1705968297826060257	\N	Demo Project 1770558868716	\N	\N	\N	f	2026-02-08 13:54:28.774	2026-02-08 13:54:28.785
1705971716779411426	1705971716829743075	\N	Demo Project 1770559276308	\N	\N	\N	f	2026-02-08 14:01:16.348	2026-02-08 14:01:16.363
1705982425424725988	1705982425466669029	\N	Demo Project 1770560552845	\N	\N	\N	f	2026-02-08 14:22:32.919	2026-02-08 14:22:32.933
1705995525720901607	1705995525762844648	\N	Demo Project 1770562114568	\N	\N	\N	f	2026-02-08 14:48:34.598	2026-02-08 14:48:34.61
1706539301874960364	1706539301992400877	\N	Demo Project 1770626937679	\N	\N	\N	f	2026-02-09 08:48:57.761	2026-02-09 08:48:57.868
1706583932683683823	1706583932725626864	\N	new_project	\N	\N	\N	f	2026-02-09 10:17:38.172	2026-02-09 10:17:38.184
1706624284035647475	1706624284077590516	\N	Demo Project 1770637068381	\N	\N	\N	f	2026-02-09 11:37:48.427	2026-02-09 11:37:48.438
1706665572344793078	1706665572386736119	\N	Demo Project 1770641990280	\N	\N	\N	f	2026-02-09 12:59:50.381	2026-02-09 12:59:50.393
1706705066934667260	1706705066968221693	\N	Demo Project 1770646698400	\N	\N	\N	f	2026-02-09 14:18:18.501	2026-02-09 14:18:18.512
1706713447162446855	1706713447196001288	\N	Tasks Demo 1770647697460	\N	\N	\N	f	2026-02-09 14:34:57.501	2026-02-09 14:34:57.511
1706713500681765905	1706713500715320338	\N	Labels Demo 1770647703841	\N	\N	\N	f	2026-02-09 14:35:03.881	2026-02-09 14:35:03.891
1706713557581693980	1706713557606859805	\N	Webhooks Demo 1770647710631	\N	\N	\N	f	2026-02-09 14:35:10.664	2026-02-09 14:35:10.673
1706713606260786206	1706713606285952031	\N	Membership Demo 1770647716423	\N	\N	\N	f	2026-02-09 14:35:16.466	2026-02-09 14:35:16.476
1706713707158963239	1706713707192517672	\N	Actions Demo 1770647728457	\N	\N	\N	f	2026-02-09 14:35:28.495	2026-02-09 14:35:28.506
1706713766323815472	1706713766357369905	\N	Fields Demo 1770647735510	\N	\N	\N	f	2026-02-09 14:35:35.548	2026-02-09 14:35:35.558
1706721985775535171	1706721985809089604	\N	Tasks Demo 1770648715354	\N	\N	\N	f	2026-02-09 14:51:55.382	2026-02-09 14:51:55.393
1706722039638787149	1706722039680730190	\N	Labels Demo 1770648721776	\N	\N	\N	f	2026-02-09 14:52:01.804	2026-02-09 14:52:01.815
1706722094684832856	1706722094718387289	\N	Webhooks Demo 1770648728339	\N	\N	\N	f	2026-02-09 14:52:08.366	2026-02-09 14:52:08.375
1706722143615583322	1706722143649137755	\N	Membership Demo 1770648734169	\N	\N	\N	f	2026-02-09 14:52:14.198	2026-02-09 14:52:14.209
1706722242064286819	1706722242089452644	\N	Actions Demo 1770648745907	\N	\N	\N	f	2026-02-09 14:52:25.934	2026-02-09 14:52:25.943
1706722298502841452	1706722298528007277	\N	Fields Demo 1770648752633	\N	\N	\N	f	2026-02-09 14:52:32.662	2026-02-09 14:52:32.671
\.


--
-- Data for Name: project_favorite; Type: TABLE DATA; Schema: public; Owner: mini1
--

COPY public.project_favorite (id, project_id, user_id, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: project_manager; Type: TABLE DATA; Schema: public; Owner: mini1
--

COPY public.project_manager (id, project_id, user_id, created_at, updated_at) FROM stdin;
1573201067573774073	1573201067548608248	1560328737491256322	2025-08-09 09:29:41.586	\N
1653692626186011966	1653692626093737277	1560328737491256322	2025-11-28 10:52:03.078	\N
1653693149710648642	1653693149668705601	1560328737491256322	2025-11-28 10:53:05.49	\N
1653693365406926154	1653693365348205897	1560328737491256322	2025-11-28 10:53:31.2	\N
1653693445568464210	1653693445518132561	1560328737491256322	2025-11-28 10:53:40.758	\N
1653693545342567770	1653693545300624729	1560328737491256322	2025-11-28 10:53:52.652	\N
1653693666390181218	1653693666348238177	1560328737491256322	2025-11-28 10:54:07.081	\N
1653694222697497963	1653694222638777706	1560328737491256322	2025-11-28 10:55:13.395	\N
1653694383146403188	1653694383079294323	1560328737491256322	2025-11-28 10:55:32.52	\N
1653695333550523774	1653695333500192125	1560328737491256322	2025-11-28 10:57:25.817	\N
1653695517579806089	1653695517529474440	1560328737491256322	2025-11-28 10:57:47.755	\N
1653696108540462486	1653696108490130837	1560328737491256322	2025-11-28 10:58:58.201	\N
1653696655746139554	1653696655704196513	1560328737491256322	2025-11-28 11:00:03.433	\N
1654034706984863149	1654034706909365676	1560328737491256322	2025-11-28 22:11:42.319	\N
1654035094135899576	1654035094077179319	1560328737491256322	2025-11-28 22:12:28.472	\N
1654036093974087107	1654036093932144066	1560328737491256322	2025-11-28 22:14:27.664	\N
1654047135412258254	1654047135361926605	1560328737491256322	2025-11-28 22:36:23.905	\N
1654047314458707417	1654047314408375768	1560328737491256322	2025-11-28 22:36:45.249	\N
1686524948815808302	1686524948740310829	1560328737491256322	2026-01-12 18:04:00.955	\N
1686966615788226354	1686966615729506097	1560328737491256322	2026-01-13 08:41:31.762	\N
1686971307285022516	1686971307226302259	1560328737491256322	2026-01-13 08:50:51.031	\N
1686987488188434231	1686987487366350646	1560328737491256322	2026-01-13 09:22:59.857	\N
1686989338748913465	1686989338715359032	1560328737491256322	2026-01-13 09:26:40.551	\N
1686990505948219197	1686990505906276156	1560328737491256322	2026-01-13 09:28:59.691	\N
1686992092846360387	1686992092804417346	1560328737491256322	2026-01-13 09:32:08.865	\N
1689343961539282763	1689343960775919434	1560328737491256322	2026-01-16 15:24:53.459	\N
1689345763479390038	1689345763437446997	1560328737491256322	2026-01-16 15:28:28.267	\N
1689345808962422625	1689345808928868192	1560328737491256322	2026-01-16 15:28:33.689	\N
1689347018339649388	1689347017710503787	1560328737491256322	2026-01-16 15:30:57.788	\N
1689350320104146807	1689350319701493622	1560328737491256322	2026-01-16 15:37:31.459	\N
1689350458021250946	1689350457987696513	1560328737491256322	2026-01-16 15:37:47.9	\N
1689351138974893965	1689351138941339532	1560328737491256322	2026-01-16 15:39:09.076	\N
1689351918570178456	1689351918536624023	1560328737491256322	2026-01-16 15:40:42.012	\N
1689351954280482723	1689351953357735842	1560328737491256322	2026-01-16 15:40:46.26	\N
1689478798447216558	1689478798388496301	1560328737491256322	2026-01-16 19:52:47.272	\N
1689483585188267961	1689483585146324920	1560328737491256322	2026-01-16 20:02:17.897	\N
1689894993285613507	1689894993243670466	1560328737491256322	2026-01-17 09:39:41.565	\N
1690085633688602567	1690085633638270918	1560328737491256322	2026-01-17 15:58:27.67	\N
1704726107342768085	1704726107284047828	1560328737491256322	2026-02-06 20:46:28.131	\N
1704788350159816664	1704788350109485015	1560328737491256322	2026-02-06 22:50:08.056	\N
1705853281688881116	1705853281646938075	1560328737491256322	2026-02-08 10:05:57.789	\N
1705866245343021022	1705866245301077981	1560328737491256322	2026-02-08 10:31:43.175	\N
1705968297826060257	1705968297784117216	1560328737491256322	2026-02-08 13:54:28.779	\N
1705971716829743075	1705971716779411426	1560328737491256322	2026-02-08 14:01:16.355	\N
1705982425466669029	1705982425424725988	1560328737491256322	2026-02-08 14:22:32.926	\N
1705995525762844648	1705995525720901607	1560328737491256322	2026-02-08 14:48:34.602	\N
1706539301992400877	1706539301874960364	1560328737491256322	2026-02-09 08:48:57.778	\N
1706583932725626864	1706583932683683823	1560328737491256322	2026-02-09 10:17:38.177	\N
1706624284077590516	1706624284035647475	1560328737491256322	2026-02-09 11:37:48.431	\N
1706665572386736119	1706665572344793078	1560328737491256322	2026-02-09 12:59:50.386	\N
1706705066968221693	1706705066934667260	1560328737491256322	2026-02-09 14:18:18.506	\N
1706713447196001288	1706713447162446855	1560328737491256322	2026-02-09 14:34:57.505	\N
1706713500715320338	1706713500681765905	1560328737491256322	2026-02-09 14:35:03.885	\N
1706713557606859805	1706713557581693980	1560328737491256322	2026-02-09 14:35:10.667	\N
1706713606285952031	1706713606260786206	1560328737491256322	2026-02-09 14:35:16.47	\N
1706713707192517672	1706713707158963239	1560328737491256322	2026-02-09 14:35:28.499	\N
1706713766357369905	1706713766323815472	1560328737491256322	2026-02-09 14:35:35.552	\N
1706721985809089604	1706721985775535171	1560328737491256322	2026-02-09 14:51:55.386	\N
1706722039680730190	1706722039638787149	1560328737491256322	2026-02-09 14:52:01.807	\N
1706722094718387289	1706722094684832856	1560328737491256322	2026-02-09 14:52:08.369	\N
1706722143649137755	1706722143615583322	1560328737491256322	2026-02-09 14:52:14.202	\N
1706722242089452644	1706722242064286819	1560328737491256322	2026-02-09 14:52:25.938	\N
1706722298528007277	1706722298502841452	1560328737491256322	2026-02-09 14:52:32.666	\N
1706725905310680182	1706725905268737141	1560328737491256322	2026-02-09 14:59:42.627	\N
1706769420795249794	1706769420744918145	1560328737491256322	2026-02-09 16:26:10.078	\N
\.


--
-- Data for Name: session; Type: TABLE DATA; Schema: public; Owner: mini1
--

COPY public.session (id, user_id, access_token, http_only_token, remote_address, user_agent, created_at, updated_at, deleted_at, pending_token) FROM stdin;
1565996599279092742	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6ImIxMDJmZjE3LWU4MjgtNDJhZC05ZDk4LTVlMDFmNjgxNWY4ZiJ9.eyJpYXQiOjE3NTM4NzI5NDIsImV4cCI6MTc4NTQwODk0Miwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.ml3BmWfjj03jomVI2uJdJLlqj8F2fIQkuT5c6CBtNLA	b153c63b-4562-49ca-8cee-2727a4dc051d	142.251.36.27	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36	2025-07-30 10:55:42.036	2025-07-30 11:00:11.817	2025-07-30 11:00:11.816	\N
1565998904820892680	1560278692305830913	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjE3ZDFhYTk1LTM1MmUtNDMwNS04NjZjLTdmMjA0MTY1MjU4ZCJ9.eyJpYXQiOjE3NTM4NzMyMTYsImV4cCI6MTc4NTQwOTIxNiwic3ViIjoiMTU2MDI3ODY5MjMwNTgzMDkxMyJ9.wxOtFDkb6tEuB-e-G87QBgIFe98EKxESq2uc6vxbvdU	6bfaa4a3-4721-4086-ba63-b0cab1c19a18	142.251.36.27	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36	2025-07-30 11:00:16.878	2025-07-30 11:11:25.3	2025-07-30 11:11:25.298	\N
1566004531731366934	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjBmYmM0ODk2LTI4MWYtNDViOC04NzAyLTNmMGIyMGM4Y2RiZiJ9.eyJpYXQiOjE3NTM4NzM4ODcsImV4cCI6MTc4NTQwOTg4Nywic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.8DAHLMniUdCG8eMZkrVi6xM6P0vbTmcx8LYuLbSKAmU	c8d09b71-a2f6-4a6f-927c-fd894eeda38b	142.251.36.27	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36	2025-07-30 11:11:27.659	2025-07-30 11:23:34.744	2025-07-30 11:23:34.743	\N
1566010658535769148	1560278692305830913	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjkxODMwNWZmLWMzYzMtNDkxMy05YmJkLWZhODkwYWQ0N2UxMiJ9.eyJpYXQiOjE3NTM4NzQ2MTgsImV4cCI6MTc4NTQxMDYxOCwic3ViIjoiMTU2MDI3ODY5MjMwNTgzMDkxMyJ9.TM6KEQJQBuXsZ7ffjVjcRKrFcArXVaelDHBjgVuxunI	606003c2-c924-4b8f-bae4-f45c63da76ff	142.251.36.27	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36	2025-07-30 11:23:38.032	2025-07-30 11:29:54.912	2025-07-30 11:29:54.91	\N
1634801807093925583	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6ImUwOWNmMDVkLTY3MTctNGNkYy05MWMxLWNhMjI5MzViODliNyJ9.eyJpYXQiOjE3NjIwNzUxNjEsImV4cCI6NDkxNTY3NTE2MSwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.ioMN0sQftO0EiaNssOllAmuKAejAYb4yJUK_vDyQRt4	3ee4b2cd-07b7-4287-bb47-2c1e587007ba	172.18.0.20	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36	2025-11-02 09:19:21.932	2025-11-02 09:19:48.779	2025-11-02 09:19:48.778	\N
1634802098757437139	1560328737491256323	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjIzZTRiODVlLWJlMDgtNDc2Yi1iMmUyLTdlYTkxZDQ0OGEwNSJ9.eyJpYXQiOjE3NjIwNzUxOTYsImV4cCI6NDkxNTY3NTE5Niwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMyJ9.ZeZFTik0r-aL6H_YOPrYOKbOvxIBrabJ0ujV0U2PVpQ	c1aa9a8a-c909-49a2-a11e-2a69aa445f76	172.18.0.20	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36	2025-11-02 09:19:56.748	2025-11-02 09:20:24.938	2025-11-02 09:20:24.935	\N
1626995069854680532	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjY0ZmI3ZDliLTA4M2UtNGNiMC1hMjAzLTYzMTQ2NmZjMmQ4NyJ9.eyJpYXQiOjE3NjExNDQ1MjYsImV4cCI6NDkxNDc0NDUyNiwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.Zbpl10pcpxdHUl-BBCrUqISoEXpA_TwYvKQ0TRMBPeo	\N	172.18.0.15	Python/3.12 aiohttp/3.13.0	2025-10-22 14:48:46.379	\N	2025-11-07 08:29:22.465	\N
1630689136950118091	1560278692305830913	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjkwMTY1MjI0LTY3NzAtNDA2NC1iMTJiLWJlZTk5MGVlMWU0MSJ9.eyJpYXQiOjE3NjE1ODQ4OTMsImV4cCI6NDkxNTE4NDg5Mywic3ViIjoiMTU2MDI3ODY5MjMwNTgzMDkxMyJ9.hxknv2Lfbx94zYtV4H7O5dLC8OsebMLABkZBfPBTOf0	cd69872a-24fb-4b0b-bb89-492be2106a26	172.18.0.20	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 OPR/122.0.0.0	2025-10-27 17:08:13.491	2025-11-06 11:39:29.56	2025-11-06 11:39:29.559	\N
1560294586092356611	1560278692305830913	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjAzN2Y4YjIyLTU0YzMtNDVhMi04Mzk2LTM2N2FiZWI0M2U2YiJ9.eyJpYXQiOjE3NTMxOTMyMDksImV4cCI6MTc4NDcyOTIwOSwic3ViIjoiMTU2MDI3ODY5MjMwNTgzMDkxMyJ9.B9YaJbWEbGLo5wG6UuGgeFKDtcixTiCLeCQ0Z462oIs	fcd4dc85-2b9d-4125-81bb-1f21c400d3c6	151.101.128.223	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36	2025-07-22 14:06:49.095	\N	2025-11-07 08:29:22.465	\N
1560328737491256326	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjllZDg4ODgzLWI0Y2MtNDI0NS1iOTZjLTVkZWZmZTk0ZTg1YSJ9.eyJpYXQiOjE3NTM4NzI2ODMsImV4cCI6MTc4NTQwODY4Mywic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.q02RBVLTM2Ald69pfn8xBcUCATBdqAFcFP-ndN-_hF4	\N	127.0.0.1	API Client	2025-07-30 10:51:29.898679	2025-07-30 10:51:29.898679	2025-11-07 08:29:22.465	\N
1566013844503921729	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjcyZmQyYzM1LWVhNjItNDZkYy1iYjA4LTk2MDgzOTUyYmFkMCJ9.eyJpYXQiOjE3NTM4NzQ5OTcsImV4cCI6MTc4NTQxMDk5Nywic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.Ut1GIjkn2kdZ_OFTubbZTlm7VWgfrycsHTGkORENfXs	49686d2f-d3b0-4688-8979-9ee345e3db01	142.251.36.27	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36	2025-07-30 11:29:57.829	\N	2025-11-07 08:29:22.465	\N
1572105354811016308	1560278692305830913	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjQzYWMyMTcxLTQ0YmEtNDQ0Yi05YzU0LTVhYzU5NDMzY2Y2YSJ9.eyJpYXQiOjE3NTQ2MDExNjIsImV4cCI6MTc4NjEzNzE2Miwic3ViIjoiMTU2MDI3ODY5MjMwNTgzMDkxMyJ9.wqarkYGmWGchfdqW2CCtNpDL4JXLYAPL4SkDN6ryTnE	019fe815-6f03-496c-ac49-6cab12d4014e	142.250.179.187	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.0 Safari/605.1.15	2025-08-07 21:12:42.443	\N	2025-11-07 08:29:22.465	\N
1572120589982762101	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6Ijg2M2FiMDMwLTUwZjEtNDJmNy1iYTUyLTU3MmEzMzUwMzJkYSJ9.eyJpYXQiOjE3NTQ2MDI5NzgsImV4cCI6MTc4NjEzODk3OCwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.hIi2r_oad-oBu-zclw2ZvaxaS0W11NLeorH-cKTSJY8	\N	142.250.179.187	Python-urllib/3.13	2025-08-07 21:42:58.618	\N	2025-11-07 08:29:22.465	\N
1572120638863180918	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjY0Y2YxMDM5LTQ3YTAtNDgwNC1iNWE4LWNjZGNmOTgzODdlZSJ9.eyJpYXQiOjE3NTQ2MDI5ODQsImV4cCI6MTc4NjEzODk4NCwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.Yuq7g116ACd5kml5HP0ayS9FiniAig3gUSC2-gerVE4	\N	142.250.179.187	Python-urllib/3.13	2025-08-07 21:43:04.447	\N	2025-11-07 08:29:22.465	\N
1572120709486871671	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6ImQ3YzIyOTQxLTkyYTQtNDA4NC1iYTc4LWMxNTVmOTE1ZWYzMSJ9.eyJpYXQiOjE3NTQ2MDI5OTIsImV4cCI6MTc4NjEzODk5Miwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.e-vOn0G3GnL7PS98X8qmv0QusZxIk1fi_oXHW7fa3WM	\N	142.250.179.187	Python-urllib/3.13	2025-08-07 21:43:12.866	\N	2025-11-07 08:29:22.465	\N
1572120946196612216	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjQyM2MzYjlkLTNmZGItNDZhYS04NDc0LTJlNzBlMjJiNTNhYiJ9.eyJpYXQiOjE3NTQ2MDMwMjEsImV4cCI6MTc4NjEzOTAyMSwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.LmOR5Htz6wICxT-Ek1aRWKUS6YkSIZqrtFmt7WcDV5k	\N	142.250.179.187	python-requests/2.32.4	2025-08-07 21:43:41.082	\N	2025-11-07 08:29:22.465	\N
1572121045853275257	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6Ijg4OTQ3NGI0LTRmODctNDdhMi04YzUzLTZhMWZmMzQ4NzY4NyJ9.eyJpYXQiOjE3NTQ2MDMwMzIsImV4cCI6MTc4NjEzOTAzMiwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.Os9ISwVNBNLUjGJE29ZKBh30-KZkxoBqxM7Y07lg8dI	\N	142.250.179.187	python-requests/2.32.4	2025-08-07 21:43:52.963	\N	2025-11-07 08:29:22.465	\N
1572121901784892538	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjI3NGQxNzJkLTA2ZTktNDA4Zi05ZWIxLWFhODAxZTRkMWI5YiJ9.eyJpYXQiOjE3NTQ2MDMxMzQsImV4cCI6MTc4NjEzOTEzNCwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.qqoOOaAnQXVUv_Szc4r9WMa0fN-jC18zZl0QdCQyEXc	\N	142.250.179.187	python-requests/2.32.4	2025-08-07 21:45:34.998	\N	2025-11-07 08:29:22.465	\N
1572122394867270779	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6ImU4YjM1OWZkLTk4Y2ItNGUyMy05NjU0LTM1MDUyMTBmZTBmNSJ9.eyJpYXQiOjE3NTQ2MDMxOTMsImV4cCI6MTc4NjEzOTE5Mywic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.46DwZc1MK9h2tD2wBgE-nOADpdG9w-Zu7IY4_ZdsMIk	\N	142.250.179.187	python-requests/2.32.4	2025-08-07 21:46:33.778	\N	2025-11-07 08:29:22.465	\N
1572122796731925628	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjE0YTMzM2YzLTI2NTgtNDAyYy05Y2Q4LTFmZjRiNGZlOTM3OSJ9.eyJpYXQiOjE3NTQ2MDMyNDEsImV4cCI6MTc4NjEzOTI0MSwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.2lAOwYbTlPAZS3K6D6qhpe9h2xX7ffgg1VzOIciD2Bw	\N	142.250.179.187	python-requests/2.32.4	2025-08-07 21:47:21.683	\N	2025-11-07 08:29:22.465	\N
1572123028853097599	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjFkNWFmMzBmLTM1YzAtNGZiNy1iY2EwLWE5YzczNDg1YzQ3OCJ9.eyJpYXQiOjE3NTQ2MDMyNjksImV4cCI6MTc4NjEzOTI2OSwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.37eztz7Z_VmsL8CNsvm_-Qr80vXvglVlVZtc7S90RZI	\N	142.250.179.187	python-requests/2.32.4	2025-08-07 21:47:49.355	\N	2025-11-07 08:29:22.465	\N
1572130827263804546	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjJjM2VkODc2LTJkNmMtNDAwNi04MWFkLWExMTEyZmM0NjM5OCJ9.eyJpYXQiOjE3NTQ2MDQxOTgsImV4cCI6MTc4NjE0MDE5OCwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.4rSidu_0MEvWHb36QnCIESkr0urZO4ZYw2J8472hXRU	\N	142.250.179.187	python-requests/2.32.4	2025-08-07 22:03:18.996	\N	2025-11-07 08:29:22.465	\N
1572131155786859665	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjVmZjA1NzY0LTk0ZTQtNGExNi1hNjBhLWI0OWYzNzFhY2YwNSJ9.eyJpYXQiOjE3NTQ2MDQyMzgsImV4cCI6MTc4NjE0MDIzOCwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.cIifhdg3RiuPw7BSOdLRKqm4903UZt7OqOOGoVhCU6w	\N	142.250.179.187	python-requests/2.32.4	2025-08-07 22:03:58.161	\N	2025-11-07 08:29:22.465	\N
1572131313291363488	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjlhZGU5YjQ0LTkyM2MtNDNiYi1hYzczLTE2ZmFiZDkyNGMyMiJ9.eyJpYXQiOjE3NTQ2MDQyNTYsImV4cCI6MTc4NjE0MDI1Niwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.9jrwy4HYjcfDmV3jBvQLhrEROKzo5GWvii12RA8bmQo	\N	142.250.179.187	python-requests/2.32.4	2025-08-07 22:04:16.937	\N	2025-11-07 08:29:22.465	\N
1572131367280444591	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6ImVhNmYyZDNlLTk4ZGUtNDg4ZC04ODhkLWFhMDhjMGUyZGI0NiJ9.eyJpYXQiOjE3NTQ2MDQyNjMsImV4cCI6MTc4NjE0MDI2Mywic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.Lb110Bgwgd-uvPpHOBj8d2JftFhUwaLg-AuUmdnm3bI	\N	142.250.179.187	python-requests/2.32.4	2025-08-07 22:04:23.374	\N	2025-11-07 08:29:22.465	\N
1572131515842692286	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjllZTRkZjc5LTZlODAtNGFhNC04OGRlLWE3MWZlM2RkYjBiOCJ9.eyJpYXQiOjE3NTQ2MDQyODEsImV4cCI6MTc4NjE0MDI4MSwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.7t0D8fRszB2hRqnlo2HV_n0A65YB-BpTy-AzwIt7zWY	\N	142.250.179.187	python-requests/2.32.4	2025-08-07 22:04:41.082	\N	2025-11-07 08:29:22.465	\N
1572132139728635103	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6ImFjMmM4Yzc1LTU1YTUtNDUzZi05NTg1LTVmYmRlYWM5Y2Q4MCJ9.eyJpYXQiOjE3NTQ2MDQzNTUsImV4cCI6MTc4NjE0MDM1NSwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.33sXLWxXv5OqxPc7w6wYEWyMKVRtvfTShfqWLDmXRDE	\N	142.250.179.187	python-requests/2.32.4	2025-08-07 22:05:55.455	\N	2025-11-07 08:29:22.465	\N
1572132307601458432	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjZiN2FlMDlkLWJhNzYtNGRmNC1hZTU2LWJhNmVkNGVlMjQyZSJ9.eyJpYXQiOjE3NTQ2MDQzNzUsImV4cCI6MTc4NjE0MDM3NSwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.BlgzsB6XtVucEjzOPudMcjrry0LSoZqdt80V03rC6Jo	\N	142.250.179.187	python-requests/2.32.4	2025-08-07 22:06:15.467	\N	2025-11-07 08:29:22.465	\N
1572132506755400961	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6ImUzMjE4YjkyLTA2MTUtNGEwNi05ODgyLThjMTdjNDlmN2Y4MiJ9.eyJpYXQiOjE3NTQ2MDQzOTksImV4cCI6MTc4NjE0MDM5OSwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.5nrfWnMwyYMcZhMA5KopAvEPSxh875YAWCsfCvU7PhM	\N	142.250.179.187	python-requests/2.32.4	2025-08-07 22:06:39.208	\N	2025-11-07 08:29:22.465	\N
1572133168926950658	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6Ijc0YmMzMTE4LTExNDUtNDk4NS1hOTY0LTM5OWNjNmNhMDM5NCJ9.eyJpYXQiOjE3NTQ2MDQ0NzgsImV4cCI6MTc4NjE0MDQ3OCwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.ktDc75UculROzIG6FKvUfetBEW4amYDaLbqCk_eZPkw	\N	142.250.179.187	python-requests/2.32.4	2025-08-07 22:07:58.145	\N	2025-11-07 08:29:22.465	\N
1572139607955342627	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6Ijg4NDNiNTAwLTg4M2QtNDExNS1hOTc1LTU5ZDU3OWU4ZTYwYSJ9.eyJpYXQiOjE3NTQ2MDUyNDUsImV4cCI6MTc4NjE0MTI0NSwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.eVskS1Lq74Or76EMZjQ2_XPOW-OYImmxuOkCnlaLPVo	4ed8dc5c-8393-44ba-a459-4063f96f4eb3	142.250.179.187	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36	2025-08-07 22:20:45.737	\N	2025-11-07 08:29:22.465	\N
1572140517012014373	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6ImNhNWFkMTM4LTJiYjgtNGIzZi1iNDRkLTI0ZmFiZGViZGNmMSJ9.eyJpYXQiOjE3NTQ2MDUzNTQsImV4cCI6MTc4NjE0MTM1NCwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.Xue2Vaqs0sEhuZ4Hn8L8CnOUdaJBYuN7i8iC8_iy8ek	\N	142.250.179.187	python-requests/2.32.4	2025-08-07 22:22:34.105	\N	2025-11-07 08:29:22.465	\N
1572141597875766607	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjliOTM5ZjhiLWE4NmMtNGM5Ny1iYmVmLWY2NzQ5NGIzYTk2MyJ9.eyJpYXQiOjE3NTQ2MDU0ODIsImV4cCI6MTc4NjE0MTQ4Miwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.Dw5urJY2zYUd29uI46VFo-ms_V0kfeA7QE54qiO2xds	\N	142.250.179.187	python-requests/2.32.4	2025-08-07 22:24:42.955	\N	2025-11-07 08:29:22.465	\N
1573185207350068570	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjI2ZDlkY2U5LWQ4NGYtNGMwZC1iY2E1LThhN2RjMzc1ZGVkOCJ9.eyJpYXQiOjE3NTQ3Mjk4OTAsImV4cCI6MTc4NjI2NTg5MCwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.zhOJNh-CKHIMbB30xPt_YWPW6jdCYLbsIEDCm0e9Las	924a3417-bc5d-4a68-a961-f928e9ca1d8c	172.66.128.70	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36	2025-08-09 08:58:10.898	\N	2025-11-07 08:29:22.465	\N
1573191082949215580	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjMwZGU2ZWYzLTExY2MtNDE3Yy05Y2EzLTY3MzQyYWQ4ZWU0YSJ9.eyJpYXQiOjE3NTQ3MzA1OTEsImV4cCI6MTc4NjI2NjU5MSwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.U1DIW7L6FlObNkU6Zp2-ZPs4fyYKYXqPUJeDK_Yd3Zk	\N	172.26.0.2	Python/3.12 aiohttp/3.12.15	2025-08-09 09:09:51.316	\N	2025-11-07 08:29:22.465	\N
1573193974946989610	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6ImJhNzM1ZDlhLThkZTgtNGRkMy04NWYyLWM5Y2U1N2I0NzYyZiJ9.eyJpYXQiOjE3NTQ3MzA5MzYsImV4cCI6MTc4NjI2NjkzNiwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.SOIem_vkR5aL54QKRn5z_eZKHJzXC4uCM9HP6ryKsIA	\N	172.26.0.2	python-requests/2.32.4	2025-08-09 09:15:36.078	\N	2025-11-07 08:29:22.465	\N
1573201460772996897	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6ImI4Nzg0MzhkLTM0ZDktNDEwNi05NzdkLWVkZWU3MDIwZjBjOSJ9.eyJpYXQiOjE3NTQ3MzE4MjgsImV4cCI6MTc4NjI2NzgyOCwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.MhMuJaIsQi6hClay_-6VXQfR1jDTxyx6rUQdygkAUkc	\N	172.26.0.2	python-requests/2.32.4	2025-08-09 09:30:28.457	\N	2025-11-07 08:29:22.465	\N
1573203893385430818	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6ImVkZDcwZGY0LTc0MjItNGE0ZS04Y2U2LTBhMmQ5ZGI0ODkzMCJ9.eyJpYXQiOjE3NTQ3MzIxMTgsImV4cCI6MTc4NjI2ODExOCwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.Q_3kWuwevvjPzTSY7-TCoBt6OxLoKS-VYosldUtI7fE	\N	172.26.0.2	python-requests/2.32.4	2025-08-09 09:35:18.448	\N	2025-11-07 08:29:22.465	\N
1573216175389673253	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6ImMyZWNjZWE2LWU2MTAtNDFiMi1hNjRiLTY2MGRmZGQ2ZTgzMyJ9.eyJpYXQiOjE3NTQ3MzM1ODIsImV4cCI6MTc4NjI2OTU4Miwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.PtDpuG9BxXuAK8oXmKJQCTXayN0TwgCSU7VhnjNIuGo	228dd350-bd34-480c-9982-9189f989fa29	172.66.128.70	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36	2025-08-09 09:59:42.574	\N	2025-11-07 08:29:22.465	\N
1626139469595805479	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjE2MmRlNWNhLWEzZmQtNGI1MC1hMjY5LTAyYTY3MGY5OWVkYSJ9.eyJpYXQiOjE3NjEwNDI1MzAsImV4cCI6NDkxNDY0MjUzMCwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.HBIFYso2NmSdW4hM8ddE0o9BbJ87gVHrLxec-1jximQ	\N	172.18.0.13	Python/3.12 aiohttp/3.13.0	2025-10-21 10:28:50.878	\N	2025-11-07 08:29:22.465	\N
1626139470241728298	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjcyMzVhYWQyLTFkZjktNDU0ZS04MjU3LTVlMGMwNDUxNDA2OCJ9.eyJpYXQiOjE3NjEwNDI1MzAsImV4cCI6NDkxNDY0MjUzMCwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.1V6vuNlKVIjtJQTglmLS99WYr6masL4kQ_rRK-hjZsc	\N	172.18.0.13	Python/3.12 aiohttp/3.13.0	2025-10-21 10:28:50.957	\N	2025-11-07 08:29:22.465	\N
1626139471852341045	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6ImYyMDhjZmVmLTIzNmQtNDdiZS04MzI2LWZkYzlhYzkyODIzNyJ9.eyJpYXQiOjE3NjEwNDI1MzEsImV4cCI6NDkxNDY0MjUzMSwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.TB13IWVmMKL87IYp1EcA-2JkolS0CxBIC958xpx1JpM	\N	172.18.0.13	Python/3.12 aiohttp/3.13.0	2025-10-21 10:28:51.15	\N	2025-11-07 08:29:22.465	\N
1637642448693888060	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6ImQwMDAyNDFmLWY0MTctNDEzMS1iMzEyLTQxYTEzMzc2NWE0YiJ9.eyJpYXQiOjE3NjI0MTM3OTIsImV4cCI6NDkxNjAxMzc5Miwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.F51Rl0YPwhLo7M8iCM3Yru6VyGV7dP1cwML4r1BA8pE	\N	172.18.0.6	curl/8.7.1	2025-11-06 07:23:12.842	\N	2025-11-07 08:29:22.465	\N
1626139472733144896	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjdlMmE1NjFjLTUzNmEtNDE0NC1hZTRhLWUyYzk5NGYwNTg1ZSJ9.eyJpYXQiOjE3NjEwNDI1MzEsImV4cCI6NDkxNDY0MjUzMSwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.3Zn0HgmxoLpiXXO2OobtJwfUGEhFNu_lC5lSMO2i7Sk	\N	172.18.0.13	Python/3.12 aiohttp/3.13.0	2025-10-21 10:28:51.255	\N	2025-11-07 08:29:22.465	\N
1626139473546839883	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6ImE4YzRmYjExLWFiNWUtNGQxYy1hNTBkLTBmNWEwN2VmNThhYSJ9.eyJpYXQiOjE3NjEwNDI1MzEsImV4cCI6NDkxNDY0MjUzMSwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.vDkuaUusY6WgmGypxmjNZvIwxRG1zlePKMjCZ-fyYY8	\N	172.18.0.13	Python/3.12 aiohttp/3.13.0	2025-10-21 10:28:51.352	\N	2025-11-07 08:29:22.465	\N
1626139474545084246	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6ImVjNmM4NzZiLTZhNTItNDc2NC04MGVkLTFiNTIxMWVlODBkOCJ9.eyJpYXQiOjE3NjEwNDI1MzEsImV4cCI6NDkxNDY0MjUzMSwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.acXSkKej7Ifi0hzllWFHjJMoRXzS0mQ0uzlD8Qqcco8	\N	172.18.0.13	Python/3.12 aiohttp/3.13.0	2025-10-21 10:28:51.47	\N	2025-11-07 08:29:22.465	\N
1626139476818397031	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjEyYTM2Y2ZhLTlmNjEtNDI1NC1hODUwLWNjZTUyMmEyZDQ3MSJ9.eyJpYXQiOjE3NjEwNDI1MzEsImV4cCI6NDkxNDY0MjUzMSwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.oJnAEkKRu7xSYshkQrJXuqNohQfKgbhecopBba8fAIA	f8fa67dd-c779-491c-931f-3be780d26de1	172.18.0.13	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36	2025-10-21 10:28:51.741	\N	2025-11-07 08:29:22.465	\N
1626139517461202792	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjIwMTUwMjFlLTdmODAtNGFlZS1iNjU3LWE0ZDQ0NDJlOGQ1NSJ9.eyJpYXQiOjE3NjEwNDI1MzYsImV4cCI6NDkxNDY0MjUzNiwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.NPw8DM8cKlKtO9uVQfT9Vtp4CIIXDWyy0FjUoRp42xA	\N	172.18.0.13	Python/3.12 aiohttp/3.13.0	2025-10-21 10:28:56.587	\N	2025-11-07 08:29:22.465	\N
1626139639549003637	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjNmMjk1OWQ2LTZjODYtNDkwYy1iMzdmLTFhZjgwODEzMjYzZiJ9.eyJpYXQiOjE3NjEwNDI1NTEsImV4cCI6NDkxNDY0MjU1MSwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.8i2kP6VllzIZN3A6PlFKpErmh4lT4M4zZSQmh0848uA	\N	172.18.0.13	Python/3.12 aiohttp/3.13.0	2025-10-21 10:29:11.14	\N	2025-11-07 08:29:22.465	\N
1626139640060708728	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6ImZkMjQxMTE2LTQzOGMtNDcwMC04YTQ5LTkyYzRmNDAxMGRlYiJ9.eyJpYXQiOjE3NjEwNDI1NTEsImV4cCI6NDkxNDY0MjU1MSwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.F4DPnzV2wo0kU8CjYFDrRYtKO0G2mA2ykZtsOjZLdxc	\N	172.18.0.13	Python/3.12 aiohttp/3.13.0	2025-10-21 10:29:11.202	\N	2025-11-07 08:29:22.465	\N
1626139640597579641	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjdjMjgyZjEzLWNkMjMtNDZhZS1iNGIyLTNhZDI4M2I3NzU1NCJ9.eyJpYXQiOjE3NjEwNDI1NTEsImV4cCI6NDkxNDY0MjU1MSwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.2zOV2jiU5oHtug4PZXtQ0aOzUc1TqFvcGwuuN3G0NKg	\N	172.18.0.13	Python/3.12 aiohttp/3.13.0	2025-10-21 10:29:11.266	\N	2025-11-07 08:29:22.465	\N
1626139641226725243	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjEzMDQ0YTFkLTQ4MjktNGVhNC04YjQyLTJiZjU1MmM2NGE4MCJ9.eyJpYXQiOjE3NjEwNDI1NTEsImV4cCI6NDkxNDY0MjU1MSwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.-EaEdaNMfZ0CSl3tPvC5MpKwB3G5VgKuCPG0M9bUOtI	\N	172.18.0.13	Python/3.12 aiohttp/3.13.0	2025-10-21 10:29:11.34	\N	2025-11-07 08:29:22.465	\N
1626139703705077630	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjUyMGMxYzkwLTNlNjktNDIwZS1iZWYxLWQ2NDY4M2Q1MGEzNCJ9.eyJpYXQiOjE3NjEwNDI1NTgsImV4cCI6NDkxNDY0MjU1OCwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.BiJs1f-4m2OSTJwzXuqQP-L2M1R3EPtG2h-pQIpVKF8	\N	172.18.0.13	Python/3.12 aiohttp/3.13.0	2025-10-21 10:29:18.788	\N	2025-11-07 08:29:22.465	\N
1626139704342611839	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjI3YTAzNmRlLTQwNmEtNGQwMS1iNDlhLTkwNjAxYmRjOTc2OCJ9.eyJpYXQiOjE3NjEwNDI1NTgsImV4cCI6NDkxNDY0MjU1OCwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.s97pmKX-gmlsvXDsJFxwXkOsSm2BY4sulNuXeypPa9s	\N	172.18.0.13	Python/3.12 aiohttp/3.13.0	2025-10-21 10:29:18.865	\N	2025-11-07 08:29:22.465	\N
1626143867289995138	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6ImRmYzUxZWZlLTA4YWUtNDBkNy1hYmQ4LWZhM2U5Y2Q2ZWJhNiJ9.eyJpYXQiOjE3NjEwNDMwNTUsImV4cCI6NDkxNDY0MzA1NSwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.o7s2TTc7H9jIiGqpbTuTN34sVRefCQLD21Kf1AHFEEA	\N	172.18.0.13	Python/3.12 aiohttp/3.13.0	2025-10-21 10:37:35.124	\N	2025-11-07 08:29:22.465	\N
1626143868187576197	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjM3NmU2YzFhLTc1NjUtNDAwOC1hYjFiLWIxOTU1OWM4ZWJhNSJ9.eyJpYXQiOjE3NjEwNDMwNTUsImV4cCI6NDkxNDY0MzA1NSwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9._iJ4k6mBQcwnQGO2lWO_i4bGZfEGBABbW9_1ubW5kmM	\N	172.18.0.13	Python/3.12 aiohttp/3.13.0	2025-10-21 10:37:35.234	\N	2025-11-07 08:29:22.465	\N
1626143869177431952	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjEwNmJkMWY0LWU2YzUtNDVjYy04NzkwLTQ2YzBjOTNhMmRjNSJ9.eyJpYXQiOjE3NjEwNDMwNTUsImV4cCI6NDkxNDY0MzA1NSwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.Xi6yM_38ln7zEq5gGfIROzCGlGPRfV0SmvqB-YnUhPE	\N	172.18.0.13	Python/3.12 aiohttp/3.13.0	2025-10-21 10:37:35.352	\N	2025-11-07 08:29:22.465	\N
1626143870209230747	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjBiZTI1MzI5LWEwN2YtNDNiMy1hNDE2LTQ2ZmFmZTU3Y2UwMSJ9.eyJpYXQiOjE3NjEwNDMwNTUsImV4cCI6NDkxNDY0MzA1NSwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.6zUfecnQ0os6_8jtyQRt7ktbgskjAJlLYWdbNxUlWrc	\N	172.18.0.13	Python/3.12 aiohttp/3.13.0	2025-10-21 10:37:35.474	\N	2025-11-07 08:29:22.465	\N
1626143871031314342	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjZiOTQ2OGQ5LWI3MDctNDViMy05YjZiLTVlNDY3ODA3N2Y1YiJ9.eyJpYXQiOjE3NjEwNDMwNTUsImV4cCI6NDkxNDY0MzA1NSwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.0zv4RYbRDABS59_QYImY7L6sKpxOoSwuRNJBENi4-Vk	\N	172.18.0.13	Python/3.12 aiohttp/3.13.0	2025-10-21 10:37:35.572	\N	2025-11-07 08:29:22.465	\N
1626143872499320753	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjEwYzIwOTJkLTg2ODctNGUxMy1hNTcxLTNkYmZlMTFiMzdiNiJ9.eyJpYXQiOjE3NjEwNDMwNTUsImV4cCI6NDkxNDY0MzA1NSwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9._gk9f1T0RroW5vk5mjHiA1NGjNwAutVlz8lXzsBW5KE	\N	172.18.0.13	Python/3.12 aiohttp/3.13.0	2025-10-21 10:37:35.743	\N	2025-11-07 08:29:22.465	\N
1626144083355371462	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6ImM3ZjA3MDI5LWM1MWYtNGNkNC05NDkxLTViZGQzYjA1NWZjOSJ9.eyJpYXQiOjE3NjEwNDMwODAsImV4cCI6NDkxNDY0MzA4MCwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.4j_Nq0B33FaLAC-tj4aAljLhri2vxMslt9ai59L8tg0	\N	172.18.0.13	Python/3.12 aiohttp/3.13.0	2025-10-21 10:38:00.881	\N	2025-11-07 08:29:22.465	\N
1626144574768416720	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjZhMDMzZTA3LWVhY2EtNDY0Ny1iYjYyLWI0ZTViZTUwODBkNSJ9.eyJpYXQiOjE3NjEwNDMxMzksImV4cCI6NDkxNDY0MzEzOSwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.J7Zlnd0504HEZzmURL5a0jBxDrNNwFmbeYiLc4rtzU8	\N	172.18.0.13	Python/3.12 aiohttp/3.13.0	2025-10-21 10:38:59.462	\N	2025-11-07 08:29:22.465	\N
1626144575347230675	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjkwNTNmMTFiLTI2ZDQtNDY5MS1hMTQ5LWQ4MWZlYzFmYTM1YSJ9.eyJpYXQiOjE3NjEwNDMxMzksImV4cCI6NDkxNDY0MzEzOSwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.Y2nUBiO5ZhE_eqOOVAgVCzNxBgybyV6sD7T48zXPaQo	\N	172.18.0.13	Python/3.12 aiohttp/3.13.0	2025-10-21 10:38:59.533	\N	2025-11-07 08:29:22.465	\N
1626144575875712980	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6ImE3Yzg5ZDM1LTJiZDktNDAyOC1hMjU0LTFlYTNkZjUxMWE5NCJ9.eyJpYXQiOjE3NjEwNDMxMzksImV4cCI6NDkxNDY0MzEzOSwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.rsasVGizICIW5Fo80hX-bDBHZyk1IvvHatK1dNelmyo	\N	172.18.0.13	Python/3.12 aiohttp/3.13.0	2025-10-21 10:38:59.597	\N	2025-11-07 08:29:22.465	\N
1626144576496469974	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjExNDA5OGVlLTc2MGItNGJiYS04YWI0LWU1YzkxZTgwMWI1MSJ9.eyJpYXQiOjE3NjEwNDMxMzksImV4cCI6NDkxNDY0MzEzOSwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.R5bt08JiktsGcUW0qgMZnG6mxKTs2-jAIH_H5vFHSl4	\N	172.18.0.13	Python/3.12 aiohttp/3.13.0	2025-10-21 10:38:59.67	\N	2025-11-07 08:29:22.465	\N
1626146339102394329	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjM3Zjg2MTNkLTMzOTktNDg3NS1iMjliLTk5OTk5NWIwNjVjOCJ9.eyJpYXQiOjE3NjEwNDMzNDksImV4cCI6NDkxNDY0MzM0OSwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.5rTfTrhj9gRP9egP-VBpV90jQyvUrTDYPyer-HVM54I	\N	172.18.0.13	Python/3.12 aiohttp/3.13.0	2025-10-21 10:42:29.787	\N	2025-11-07 08:29:22.465	\N
1626762336658261981	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6ImVmMmRkZGI1LWU5ODEtNDIyNi1iOTE0LTdlYjZiZDhlYzk4NyJ9.eyJpYXQiOjE3NjExMTY3ODIsImV4cCI6NDkxNDcxNjc4Miwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.FOgr81iWAmb5HipwePmXjvWR3aZFugjsRwTEcmg0K98	\N	172.18.0.3	Python/3.12 aiohttp/3.13.0	2025-10-22 07:06:22.414	\N	2025-11-07 08:29:22.465	\N
1626762337388070880	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjU4MWFmOTk3LTMwNzUtNDlkYS1hOGZkLTY5NDUzMjkzZTdiYyJ9.eyJpYXQiOjE3NjExMTY3ODIsImV4cCI6NDkxNDcxNjc4Miwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.IX0rAJ8DdW_WTwgwe7uLHFDJ9vl8Sn_k4OARvcdS8Y4	\N	172.18.0.3	Python/3.12 aiohttp/3.13.0	2025-10-22 07:06:22.507	\N	2025-11-07 08:29:22.465	\N
1626762338763802603	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6ImEyOTYwOGYxLTExNmEtNGUyMS05N2MwLWQ5ODZjYmE2MzA1ZCJ9.eyJpYXQiOjE3NjExMTY3ODIsImV4cCI6NDkxNDcxNjc4Miwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.iGNur6M4qKEWZAcXnQfzu1-BzLMj21QIK-SwqdcD-SY	\N	172.18.0.3	Python/3.12 aiohttp/3.13.0	2025-10-22 07:06:22.672	\N	2025-11-07 08:29:22.465	\N
1626762339661383670	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6ImZiYTc0M2YyLTUxMDEtNDVlZi05ZjdhLTc1OWEzNGIwZGMxNCJ9.eyJpYXQiOjE3NjExMTY3ODIsImV4cCI6NDkxNDcxNjc4Miwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.ZdUfW8_xzYRQ_t_reYxdEwZ7OisMvbFgpzhji8N4G7k	\N	172.18.0.3	Python/3.12 aiohttp/3.13.0	2025-10-22 07:06:22.778	\N	2025-11-07 08:29:22.465	\N
1626762340475077633	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjIzOWQ3OWM3LTRjNmItNGNmYS1iNDY2LWVmNWYyOTQyNGMzMCJ9.eyJpYXQiOjE3NjExMTY3ODIsImV4cCI6NDkxNDcxNjc4Miwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.IbL8maFkmYnb7m4VlU9W8HZAjN6AP1mH02_C1Koa4DE	\N	172.18.0.3	Python/3.12 aiohttp/3.13.0	2025-10-22 07:06:22.876	\N	2025-11-07 08:29:22.465	\N
1626762341993415692	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjUyMDgyODY0LWQyM2YtNDc5ZC04MDI4LTRkNzkzNmVmZTJiMyJ9.eyJpYXQiOjE3NjExMTY3ODMsImV4cCI6NDkxNDcxNjc4Mywic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.Vg5DxlwHucDqfwY8eN3PVGmOMgsJHIM5niPU8J10rnE	\N	172.18.0.3	Python/3.12 aiohttp/3.13.0	2025-10-22 07:06:23.057	\N	2025-11-07 08:29:22.465	\N
1626762359903093793	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjliZTFiMThmLWI3YTgtNGI5OC1iNzc2LWM1ZGMyNjdkNGUyZSJ9.eyJpYXQiOjE3NjExMTY3ODUsImV4cCI6NDkxNDcxNjc4NSwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.VPAzWP1XxznkLOHpshA65MbhHW6AEt8DUMBu_GDI2c4	\N	172.18.0.3	Python/3.12 aiohttp/3.13.0	2025-10-22 07:06:25.192	\N	2025-11-07 08:29:22.465	\N
1626762564148921389	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjQ3ZjZiZWFmLTBkMGItNDBiZC04ZjM1LTM1NTM2OGI0MTZlNCJ9.eyJpYXQiOjE3NjExMTY4MDksImV4cCI6NDkxNDcxNjgwOSwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.CSlYyMY4ML23Kq6O3KpoRjyslHEM3q7P3tatTvbYPgo	edfe8e4e-fda2-4e4b-976d-17b32b8cd3bd	172.18.0.3	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36	2025-10-22 07:06:49.539	\N	2025-11-07 08:29:22.465	\N
1626762740183860270	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjJhNjUzOWRjLTFhMGItNDlkZS1hNDYwLTdkMTE3ODA5ZDI3ZCJ9.eyJpYXQiOjE3NjExMTY4MzAsImV4cCI6NDkxNDcxNjgzMCwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.4xhLIRWoNyma-HXNReJanl8JPUUO10njLow64WDpol4	\N	172.18.0.3	Python/3.12 aiohttp/3.13.0	2025-10-22 07:07:10.524	\N	2025-11-07 08:29:22.465	\N
1626762740695565361	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6ImZjZWVhMmQ4LTQ5YmItNDU4OS1iN2I1LWFlYThlNjZhYjQ0YyJ9.eyJpYXQiOjE3NjExMTY4MzAsImV4cCI6NDkxNDcxNjgzMCwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.Skmdgd9mPKq-IvN1gXGn2mZSp5GvTT4TTIRkO0zpTHM	\N	172.18.0.3	Python/3.12 aiohttp/3.13.0	2025-10-22 07:07:10.586	\N	2025-11-07 08:29:22.465	\N
1626762741207270450	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6ImRhNTc5NTY0LWRkMDItNDgzYS1hOTY1LTRmYzExZDIxZTc3YyJ9.eyJpYXQiOjE3NjExMTY4MzAsImV4cCI6NDkxNDcxNjgzMCwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.XTuea1-J66v7mdK7r0q3Z6Gc4C3CPK6lrVuZgYD70t8	\N	172.18.0.3	Python/3.12 aiohttp/3.13.0	2025-10-22 07:07:10.647	\N	2025-11-07 08:29:22.465	\N
1626762741811250228	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjdhYjFkOWE1LThiYjQtNDAyZC04MzFkLTdkMTI3YzY4NjBmZiJ9.eyJpYXQiOjE3NjExMTY4MzAsImV4cCI6NDkxNDcxNjgzMCwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.kWoM07kWHJYnQpYKIEDgHtn3kE8BnopZZTJ3dCG6RoY	\N	172.18.0.3	Python/3.12 aiohttp/3.13.0	2025-10-22 07:07:10.719	\N	2025-11-07 08:29:22.465	\N
1626762950654034999	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjdjZGM3NjE3LThjZmQtNDgxMC1iMWEyLWRkYTU2Y2QwYWM5YSJ9.eyJpYXQiOjE3NjExMTY4NTUsImV4cCI6NDkxNDcxNjg1NSwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.oRBxGdp0C2jNE6LKlRBiJjgpsR5ySrN479z5OydU-r0	\N	172.18.0.3	Python/3.12 aiohttp/3.13.0	2025-10-22 07:07:35.613	\N	2025-11-07 08:29:22.465	\N
1626776935344374843	1626139592824457076	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6ImU0NDk0ZDUzLWZiNDItNGVmMi1iMWU5LWVkZTg0MDEyYjdkZSJ9.eyJpYXQiOjE3NjExMTg1MjIsImV4cCI6NDkxNDcxODUyMiwic3ViIjoiMTYyNjEzOTU5MjgyNDQ1NzA3NiJ9.EU0NsfM2j23zR-XZK8jq7F0xsLxn735oLduuxOy8w5g	17f2a673-3bb5-4f00-8fc7-4dda16ee2ee9	172.18.0.15	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36	2025-10-22 07:35:22.718	\N	2025-11-07 08:29:22.465	\N
1626777062280791100	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6ImZhYWIzN2Q2LTg2OWItNGM0NS05ZDRmLWNiNDQxNWEyYzQxMiJ9.eyJpYXQiOjE3NjExMTg1MzcsImV4cCI6NDkxNDcxODUzNywic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.EHeurSb3CgGk2WbAKathO6LzMT41T_yGLblOMVMVOIU	\N	172.18.0.15	Python/3.12 aiohttp/3.13.0	2025-10-22 07:35:37.85	\N	2025-11-07 08:29:22.465	\N
1626777062901548095	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjhlNmVmN2Q5LTljNWItNGIzYi04NzRhLWI1M2YzMzkxNjRjZCJ9.eyJpYXQiOjE3NjExMTg1MzcsImV4cCI6NDkxNDcxODUzNywic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.Llcr4ON1SSYH-fZ9YztY0Ogkzwy0MBQ0ptBbax_OZuU	\N	172.18.0.15	Python/3.12 aiohttp/3.13.0	2025-10-22 07:35:37.925	\N	2025-11-07 08:29:22.465	\N
1626777064185005130	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjJiODQ2ZDQ1LTFlYTMtNGM1NS04NjFkLTBmOGVjYTFmZTczZSJ9.eyJpYXQiOjE3NjExMTg1MzgsImV4cCI6NDkxNDcxODUzOCwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.HKD77xO2jMND24w7IS6d_4nyogQDrVPvTZBWb4lZnRY	\N	172.18.0.15	Python/3.12 aiohttp/3.13.0	2025-10-22 07:35:38.079	\N	2025-11-07 08:29:22.465	\N
1626777065585902677	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjQzMDM0ZGY4LTE2ZDMtNGRiOC1iYzQxLTI5ODhjM2ViMmUzNyJ9.eyJpYXQiOjE3NjExMTg1MzgsImV4cCI6NDkxNDcxODUzOCwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.rFl7Q1u6t3ikzYh1YzcA3rkZt8DiwyR4nRRwkULh3wk	\N	172.18.0.15	Python/3.12 aiohttp/3.13.0	2025-10-22 07:35:38.246	\N	2025-11-07 08:29:22.465	\N
1626777066416374880	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6Ijg5ZjNmYTZlLTU4NzAtNDU2MC04NzQ1LTc4YTFiODExZmZjZiJ9.eyJpYXQiOjE3NjExMTg1MzgsImV4cCI6NDkxNDcxODUzOCwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.vqtffRgSSvcWMkj8qyRiae86GSy9_ctRta7L-krqMzE	\N	172.18.0.15	Python/3.12 aiohttp/3.13.0	2025-10-22 07:35:38.345	\N	2025-11-07 08:29:22.465	\N
1626777067406230635	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjhhYWQwMGU4LTdkNzYtNDMzNi05MWFjLTI4MzI3MGY5MTFhMSJ9.eyJpYXQiOjE3NjExMTg1MzgsImV4cCI6NDkxNDcxODUzOCwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.o_GV51Lj1sZ76VdMG8kMXxzndAF6MocND98moE74nhk	\N	172.18.0.15	Python/3.12 aiohttp/3.13.0	2025-10-22 07:35:38.463	\N	2025-11-07 08:29:22.465	\N
1626777168111469696	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjJkZmUyOWM5LWYzNmQtNDhkNy04N2RhLTQ2YTg3ZDU3NzQ3ZCJ9.eyJpYXQiOjE3NjExMTg1NTAsImV4cCI6NDkxNDcxODU1MCwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.6eD09vVD7HZfvKgSiVIRAV-nVfx4Z8wUA7a2kPtTD14	\N	172.18.0.15	Python/3.12 aiohttp/3.13.0	2025-10-22 07:35:50.466	\N	2025-11-07 08:29:22.465	\N
1626840254361109642	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjM1NTdiM2M1LWNmZTAtNGIzOS05MjM3LWMzOTczNTk3OTk4MCJ9.eyJpYXQiOjE3NjExMjYwNzAsImV4cCI6NDkxNDcyNjA3MCwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.a12SGChQqTKv_CjjYuZ_lvKHmcG5u2TdZ2JU-RU_Zw0	\N	172.18.0.15	Python/3.12 aiohttp/3.13.0	2025-10-22 09:41:10.93	\N	2025-11-07 08:29:22.465	\N
1626840255954945165	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjkxZmYxZWUyLWEzYmUtNDhmMS1iZDA0LWI4MzFkOGZhNTI4ZCJ9.eyJpYXQiOjE3NjExMjYwNzEsImV4cCI6NDkxNDcyNjA3MSwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.J_ZZ_1uUY1UwbOP6_iZz5BBXvQblfIgoJIvEQq-XmRc	\N	172.18.0.15	Python/3.12 aiohttp/3.13.0	2025-10-22 09:41:11.124	\N	2025-11-07 08:29:22.465	\N
1626840257297122456	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6ImZhY2ZjMGViLTU1NDYtNDI5OS1hM2Y2LWUyY2I2M2FlMjIwYyJ9.eyJpYXQiOjE3NjExMjYwNzEsImV4cCI6NDkxNDcyNjA3MSwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.lNh0WrJGkxUIYUbM5n8KzP8KsxnA0N1bkBxzMbJ-m8E	\N	172.18.0.15	Python/3.12 aiohttp/3.13.0	2025-10-22 09:41:11.284	\N	2025-11-07 08:29:22.465	\N
1626840258286978211	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjRiZDg3YjI0LTJkYmUtNDhjNC05NDgxLTk2YWUzMGI4ODM4MCJ9.eyJpYXQiOjE3NjExMjYwNzEsImV4cCI6NDkxNDcyNjA3MSwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.MpIAa4iXJgnfEOQ9sadORjHzGDiJPmitDC-LSrCxWFI	\N	172.18.0.15	Python/3.12 aiohttp/3.13.0	2025-10-22 09:41:11.402	\N	2025-11-07 08:29:22.465	\N
1626840259402663086	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjIxYzYyYTFjLWRhNzktNGZkMC04YzQwLTI3ZjVlMjkyZjBjMCJ9.eyJpYXQiOjE3NjExMjYwNzEsImV4cCI6NDkxNDcyNjA3MSwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.CWMg-vKNhd9fFf7b1BK28m5keVvdFnPK4e6A4oS3aF8	\N	172.18.0.15	Python/3.12 aiohttp/3.13.0	2025-10-22 09:41:11.536	\N	2025-11-07 08:29:22.465	\N
1626840260459627705	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjVlYzYxZmI5LThiNWMtNDc0Ny1iMGU5LWNiMmIzMTY1ZDQ4YyJ9.eyJpYXQiOjE3NjExMjYwNzEsImV4cCI6NDkxNDcyNjA3MSwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.7lS08pZQlsSz33hWJ7pBGuoUTVfqRVYNHYYTPwBx5ls	\N	172.18.0.15	Python/3.12 aiohttp/3.13.0	2025-10-22 09:41:11.661	\N	2025-11-07 08:29:22.465	\N
1626840781727728846	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6ImY5OWFlNmNlLWY2YTYtNDk1OS1hYzdkLTg1NWQzOGVlNGVjMyJ9.eyJpYXQiOjE3NjExMjYxMzMsImV4cCI6NDkxNDcyNjEzMywic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.DrR9lXPhy0xEA-2C8BaWO2v6_v-mpF604DrhObujNI0	\N	172.18.0.15	Python/3.12 aiohttp/3.13.0	2025-10-22 09:42:13.799	\N	2025-11-07 08:29:22.465	\N
1626853198293632218	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjkxN2FkNDc2LTMzNjAtNGNmNS04MmI4LWUyZjAyMGE2OTUyMCJ9.eyJpYXQiOjE3NjExMjc2MTMsImV4cCI6NDkxNDcyNzYxMywic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.I6VMtLUTJpJbquK2q89YtCQHddtxO5LS4Zc9fPol5GM	\N	172.18.0.15	Python/3.12 aiohttp/3.13.0	2025-10-22 10:06:53.964	\N	2025-11-07 08:29:22.465	\N
1626853198989886685	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6ImU2YTk2YzA3LTVjMmUtNDc5NS1iNzMwLTJjMDhkZmRhNDllYSJ9.eyJpYXQiOjE3NjExMjc2MTQsImV4cCI6NDkxNDcyNzYxNCwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.wZ6PLkBxwf8i2BoIcobx4nKwq9WzWJTlKZdQSN9saLY	\N	172.18.0.15	Python/3.12 aiohttp/3.13.0	2025-10-22 10:06:54.055	\N	2025-11-07 08:29:22.465	\N
1626853200181069032	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjZjMmU3OGRmLWRjYzEtNGQ3MC05ZWE4LTljMTk1YTIwMjYwMiJ9.eyJpYXQiOjE3NjExMjc2MTQsImV4cCI6NDkxNDcyNzYxNCwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.lXXOzuuCXlhItqHgnwFPOZ3EgXDsEMh9mPFrHzziKJk	\N	172.18.0.15	Python/3.12 aiohttp/3.13.0	2025-10-22 10:06:54.196	\N	2025-11-07 08:29:22.465	\N
1626853201036707059	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6Ijc5MTgxMGFhLWEzY2EtNGY5Zi1iMjc0LTVjM2IxZmFiYjRmZSJ9.eyJpYXQiOjE3NjExMjc2MTQsImV4cCI6NDkxNDcyNzYxNCwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.vrDF2kKQj13GCbouBtfZbj3rEpspE2F7kJI5P60bZp4	\N	172.18.0.15	Python/3.12 aiohttp/3.13.0	2025-10-22 10:06:54.298	\N	2025-11-07 08:29:22.465	\N
1626853202152391934	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjgyMGRiOThiLTg4NGQtNDQ0Mi05MTYzLTNjM2RmZGNmNjIyOSJ9.eyJpYXQiOjE3NjExMjc2MTQsImV4cCI6NDkxNDcyNzYxNCwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.Ryzuo_3Jg1iz1Ill6bYC09RIJ2dpzSJxkYCoiRoEgUc	\N	172.18.0.15	Python/3.12 aiohttp/3.13.0	2025-10-22 10:06:54.431	\N	2025-11-07 08:29:22.465	\N
1626853203100304649	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjJhMDkzNzMxLTM4MDktNGZlYi05MWQ5LTI4YjczZTQ5MGExYSJ9.eyJpYXQiOjE3NjExMjc2MTQsImV4cCI6NDkxNDcyNzYxNCwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.BjTYJvz6H1QpTpMdByFmuYGbsmmcUXAUvEXE1gY-0Rk	\N	172.18.0.15	Python/3.12 aiohttp/3.13.0	2025-10-22 10:06:54.545	\N	2025-11-07 08:29:22.465	\N
1626853521842242846	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjZmYTEzYTMxLWExYzAtNGQyYi1hMzY3LTMyMTk5YTg3ZTNlMSJ9.eyJpYXQiOjE3NjExMjc2NTIsImV4cCI6NDkxNDcyNzY1Miwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.Pgw80Egthavw4hcon4XASP0a03z0IWMRXWkE5aFWtxI	\N	172.18.0.15	Python/3.12 aiohttp/3.13.0	2025-10-22 10:07:32.539	\N	2025-11-07 08:29:22.465	\N
1626870949351523626	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjQ1YjU4MTgzLTczZmUtNDI5YS1iMjU5LTVjYzVkMmI3MjgzNSJ9.eyJpYXQiOjE3NjExMjk3MzAsImV4cCI6NDkxNDcyOTczMCwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.ZMjj2869pPDu5KwdrLp6_6mCI1BtRNFP5sANlEYAGZk	3b5a09f8-e232-48b7-9212-a3b3c1ba3edd	172.18.0.15	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	2025-10-22 10:42:10.059	\N	2025-11-07 08:29:22.465	\N
1626885881862292779	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjRiMDNiNDczLTY3ZTUtNGE0YS04ZDM0LWIyMDVjMmU2YTg1MCJ9.eyJpYXQiOjE3NjExMzE1MTAsImV4cCI6NDkxNDczMTUxMCwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.YgCl-VkZQroSW_nx8exYjElORP1YhIpDxRQ0--W42h8	81cf3169-5a76-4034-b09e-0b58b03292ff	172.18.0.15	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36	2025-10-22 11:11:50.151	\N	2025-11-07 08:29:22.465	\N
1626893016901879090	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjQ2MmZhZjU3LWEwZDMtNGFlOC04OTBjLTJjNmQ1ZmVjNzg3ZiJ9.eyJpYXQiOjE3NjExMzIzNjAsImV4cCI6NDkxNDczMjM2MCwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.O7ooD8rZSqwZYJPRI_UHWcapmJlMkoq5wvc8-mIz_Gs	\N	172.18.0.15	Python/3.12 aiohttp/3.13.0	2025-10-22 11:26:00.718	\N	2025-11-07 08:29:22.465	\N
1626893017489081653	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjE3ODdiYmE2LWY0NjMtNDEzYy1hZDU1LTI0M2JjOWFlNTU4NyJ9.eyJpYXQiOjE3NjExMzIzNjAsImV4cCI6NDkxNDczMjM2MCwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.Szi9uG7Uyf7vmxuiL5ESk9QNutyGmJekPtCOkVUjYOQ	\N	172.18.0.15	Python/3.12 aiohttp/3.13.0	2025-10-22 11:26:00.789	\N	2025-11-07 08:29:22.465	\N
1626893018428605760	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjkyZjZjMDg5LWZlNTAtNDk3My04Y2Y3LTAwODc5NzQ3NWYyMyJ9.eyJpYXQiOjE3NjExMzIzNjAsImV4cCI6NDkxNDczMjM2MCwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.ekmE24kOwLkfDmfOadu1zsjDzzZjDEDwA953vGHWxe4	\N	172.18.0.15	Python/3.12 aiohttp/3.13.0	2025-10-22 11:26:00.902	\N	2025-11-07 08:29:22.465	\N
1626893019418461515	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjgyMWYxNmYzLTZjZmUtNDdlYy1iYzc5LTljYWUxZGRkODYyMSJ9.eyJpYXQiOjE3NjExMzIzNjEsImV4cCI6NDkxNDczMjM2MSwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.MeYGuWhVlwB4g6MIgnBklA1SGio3y4oOJIP7YZvLaFo	\N	172.18.0.15	Python/3.12 aiohttp/3.13.0	2025-10-22 11:26:01.02	\N	2025-11-07 08:29:22.465	\N
1626893020190213462	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjQ2YWRiMDc1LWYzOGUtNDY2OS04NzVlLTQ1ZTNhNDBkYTQ0MCJ9.eyJpYXQiOjE3NjExMzIzNjEsImV4cCI6NDkxNDczMjM2MSwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.NQTx1WndR9-h2_GbfLyWQoWQdugBnXvuEgO9wzeJ-oY	\N	172.18.0.15	Python/3.12 aiohttp/3.13.0	2025-10-22 11:26:01.112	\N	2025-11-07 08:29:22.465	\N
1626893021205235041	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjFmNWFlNDZjLTllY2MtNDNlMS04MTE0LTU1NTE5ZTdjM2VkMyJ9.eyJpYXQiOjE3NjExMzIzNjEsImV4cCI6NDkxNDczMjM2MSwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.qM7PXMSYxbGX_9_MsIhAeQnlFgOvKbBTq5hZ4vVat8A	\N	172.18.0.15	Python/3.12 aiohttp/3.13.0	2025-10-22 11:26:01.232	\N	2025-11-07 08:29:22.465	\N
1626893542515279222	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjM1NWE1NWYxLTM5ZWMtNDJmYi05MjZlLWI5ZDJmZTJlNjVhOSJ9.eyJpYXQiOjE3NjExMzI0MjMsImV4cCI6NDkxNDczMjQyMywic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.qUH7pjc7r61JMrZu1VUR-5WcyY8owdxGqsWmUHL7_h4	\N	172.18.0.15	Python/3.12 aiohttp/3.13.0	2025-10-22 11:27:03.376	\N	2025-11-07 08:29:22.465	\N
1626894229064123778	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6ImJhN2EyMGIzLWIzMDItNGExNi05NjAwLTAxMmRkNzY4Mjg4MyJ9.eyJpYXQiOjE3NjExMzI1MDUsImV4cCI6NDkxNDczMjUwNSwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.YS5bSCE37LuDqDZad35n-4npLynxbjdP_FdT5tDuDIw	a79a209e-ad94-4543-85c2-62a75fe45be0	172.18.0.15	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36	2025-10-22 11:28:25.218	\N	2025-11-07 08:29:22.465	\N
1626978046693082499	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjgzNmVjMWMwLWRlOGQtNGU5NS04ZTkxLWFiNTE0NTQ3NzFiYSJ9.eyJpYXQiOjE3NjExNDI0OTcsImV4cCI6NDkxNDc0MjQ5Nywic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.CrXi0uNXszTCEluNo4wfApEMy7Ug7p-vU-dYXwF7bvY	\N	172.18.0.15	Python/3.12 aiohttp/3.13.0	2025-10-22 14:14:57.056	\N	2025-11-07 08:29:22.465	\N
1626978047490000262	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjJlMjE5OGY5LTQ1NDItNGU1Zi1hOTJhLTYxOWJiMWIxYzYwNyJ9.eyJpYXQiOjE3NjExNDI0OTcsImV4cCI6NDkxNDc0MjQ5Nywic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.I0tAjwahAWm0EZrlUT3QzXv8Z-Ab-yT_ie5r2JOQ1VQ	\N	172.18.0.15	Python/3.12 aiohttp/3.13.0	2025-10-22 14:14:57.155	\N	2025-11-07 08:29:22.465	\N
1626978048689571217	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjQ4ZjAwMDE0LWZhNjUtNDg5YS04MWI0LThhNmU3N2RmNWFkNyJ9.eyJpYXQiOjE3NjExNDI0OTcsImV4cCI6NDkxNDc0MjQ5Nywic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9._uZOpHh-QKe-ubET7JuI7gU_b4NfZG57kfQqrVXkTlA	\N	172.18.0.15	Python/3.12 aiohttp/3.13.0	2025-10-22 14:14:57.299	\N	2025-11-07 08:29:22.465	\N
1626978049536820636	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjliY2Q3OGI0LTc1YmYtNDYwZS1hYzUzLWEwZWU5ZTU4ZDIzZCJ9.eyJpYXQiOjE3NjExNDI0OTcsImV4cCI6NDkxNDc0MjQ5Nywic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.Lfe6C1OdBwr-MkyBKfshKN3l-vXAvoE2r_9caIiXjHE	\N	172.18.0.15	Python/3.12 aiohttp/3.13.0	2025-10-22 14:14:57.4	\N	2025-11-07 08:29:22.465	\N
1626978050409235879	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjIxODNmZmI3LWI4ZGQtNGUzNS04ZTc4LTgwMGFkYzdkOTY3MiJ9.eyJpYXQiOjE3NjExNDI0OTcsImV4cCI6NDkxNDc0MjQ5Nywic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.712spH33NehCBwhNs6ogHP8-FKNESa0EUPPw_zOJx7w	\N	172.18.0.15	Python/3.12 aiohttp/3.13.0	2025-10-22 14:14:57.504	\N	2025-11-07 08:29:22.465	\N
1626978051575252402	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6ImY1MGMyNTQ1LTEyNWUtNDBiZC04ZjU3LTU2MjcwNDg1OGFjYyJ9.eyJpYXQiOjE3NjExNDI0OTcsImV4cCI6NDkxNDc0MjQ5Nywic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9._TyYz6qozA_XE_OMdn1CjBJ9ItA75q7ZHEQlfoqca94	\N	172.18.0.15	Python/3.12 aiohttp/3.13.0	2025-10-22 14:14:57.642	\N	2025-11-07 08:29:22.465	\N
1626978457088951751	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjQ0M2ZhNTNiLTI1MDctNDRmZC1hYzFiLTNlMmY1N2YyNmFjZCJ9.eyJpYXQiOjE3NjExNDI1NDUsImV4cCI6NDkxNDc0MjU0NSwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.soRQAwzRCjCyisS-QAE98SOIjOFVKRhOJiSzMaRJC1A	\N	172.18.0.15	Python/3.12 aiohttp/3.13.0	2025-10-22 14:15:45.981	\N	2025-11-07 08:29:22.465	\N
1626995069208757713	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjM2ZTZiZTIwLWE5ZTctNDY2Yi1iODQ3LWNlMjc4MWY0NzFlZSJ9.eyJpYXQiOjE3NjExNDQ1MjYsImV4cCI6NDkxNDc0NDUyNiwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.q0eEr-oppB_hTE4GhNi3KSmMA3s1M3MSA6GNonh6Nps	\N	172.18.0.15	Python/3.12 aiohttp/3.13.0	2025-10-22 14:48:46.3	\N	2025-11-07 08:29:22.465	\N
1626995071247189471	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6ImYyM2EwNjY2LTJlNTgtNGFjNC05OTM1LTY5YjNmZTdlOWQ2NyJ9.eyJpYXQiOjE3NjExNDQ1MjYsImV4cCI6NDkxNDc0NDUyNiwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.sQPcJ1LnsPXIPAzZ1G53OXqyclFN4I9rP8yvtTziCsI	\N	172.18.0.15	Python/3.12 aiohttp/3.13.0	2025-10-22 14:48:46.545	\N	2025-11-07 08:29:22.465	\N
1626995072086050282	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6ImVjZWU1MmFkLTk2NTQtNGMwOC04MTJmLTRjMzMyZjk4ODUzMCJ9.eyJpYXQiOjE3NjExNDQ1MjYsImV4cCI6NDkxNDc0NDUyNiwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.MmNKRtYR3BaMEvf617ZucrgxqRmB19NjX2NdaD7ZExE	\N	172.18.0.15	Python/3.12 aiohttp/3.13.0	2025-10-22 14:48:46.646	\N	2025-11-07 08:29:22.465	\N
1626995072832636405	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjI2MjEwYzdkLWJlODktNDJmMi05ZmI2LTJhZGQyNjYyMDEwNyJ9.eyJpYXQiOjE3NjExNDQ1MjYsImV4cCI6NDkxNDc0NDUyNiwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.yCB97uoIv1l_-huyk9w0KqS7vVLhVhRHkpgCJraybdc	\N	172.18.0.15	Python/3.12 aiohttp/3.13.0	2025-10-22 14:48:46.735	\N	2025-11-07 08:29:22.465	\N
1626995073822492160	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6ImE5ODMxNTE4LTMzN2EtNDVjOC04ZWFkLTYwZGQ5NTE0YWU4NyJ9.eyJpYXQiOjE3NjExNDQ1MjYsImV4cCI6NDkxNDc0NDUyNiwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.J0Mr42oEFRaWdsYF7-vFrzhADFQBU3NnqTm8lVH3AFs	\N	172.18.0.15	Python/3.12 aiohttp/3.13.0	2025-10-22 14:48:46.852	\N	2025-11-07 08:29:22.465	\N
1626995678246864405	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6ImE3MTEyMmRmLWMyNWUtNDU5Mi1hNDM2LTM3NjgxNzViMWE5OSJ9.eyJpYXQiOjE3NjExNDQ1OTgsImV4cCI6NDkxNDc0NDU5OCwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.FOVjdi2b8KsAqRXyjHB3veuBQA9YDmrhO2mGDAT0cdM	\N	172.18.0.15	Python/3.12 aiohttp/3.13.0	2025-10-22 14:49:58.903	\N	2025-11-07 08:29:22.465	\N
1627092963207153183	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6ImZjMTg1ZGY4LTUwODctNDA3OS1hMWNjLWZiYTUxY2FhZTIzYSJ9.eyJpYXQiOjE3NjExNTYxOTYsImV4cCI6NDkxNDc1NjE5Niwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.s1Mz9MgKzcSTch2GLcyzrjUTl_UiQ5wP4nBVJVK1QAk	323b1fc8-1dee-4e5a-a652-d19550aa3922	172.18.0.15	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36	2025-10-22 18:03:16.173	\N	2025-11-07 08:29:22.465	\N
1627092978902238752	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjMzZDVlOWFlLWZjNTAtNDQ0Zi04YmE1LTVlMGQ2YzVlZjEwNCJ9.eyJpYXQiOjE3NjExNTYxOTgsImV4cCI6NDkxNDc1NjE5OCwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.KBF1jKWKcZ3uKHLZamHz-0upFvE1YcXR6u0RDE7FAfU	\N	172.18.0.15	Python/3.12 aiohttp/3.13.0	2025-10-22 18:03:18.048	\N	2025-11-07 08:29:22.465	\N
1627092979514607139	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6ImU2MDlkMWE3LTQxMTctNDA1NS1hNGZkLWMzYTVkMDc3YjFkYiJ9.eyJpYXQiOjE3NjExNTYxOTgsImV4cCI6NDkxNDc1NjE5OCwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.hrG1EIP90j5caw5jKdYVkeAztJdQIdj5U5mZ1oDeN2s	\N	172.18.0.15	Python/3.12 aiohttp/3.13.0	2025-10-22 18:03:18.12	\N	2025-11-07 08:29:22.465	\N
1627092980705789486	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6ImQ5OGY0MjZmLWU4ZjItNDU4MS04NTMyLTg0OTQ3ZWVjYzNmMyJ9.eyJpYXQiOjE3NjExNTYxOTgsImV4cCI6NDkxNDc1NjE5OCwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.sO1V2i0HC3yOWmEMP41BO1akyNyQDXvZ4_yuXxE8FZM	\N	172.18.0.15	Python/3.12 aiohttp/3.13.0	2025-10-22 18:03:18.262	\N	2025-11-07 08:29:22.465	\N
1627092981594981945	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjMwMzdiNzZmLTE3MWQtNDU0Yi04ODcxLWE5MGRlMjJkNzZjNiJ9.eyJpYXQiOjE3NjExNTYxOTgsImV4cCI6NDkxNDc1NjE5OCwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.TIdnKae7PfipV1phcrKdPn2z0d8Yj_HrnxG5HsWa8Gw	\N	172.18.0.15	Python/3.12 aiohttp/3.13.0	2025-10-22 18:03:18.369	\N	2025-11-07 08:29:22.465	\N
1627092982568060484	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6ImRmOTk3MmYyLWNmYjUtNGI3Ni04ZjRjLWYyODE5ZjU0MDYwNyJ9.eyJpYXQiOjE3NjExNTYxOTgsImV4cCI6NDkxNDc1NjE5OCwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.TLlBGmLqbWG2hb1tLaBIDX9s-u_DxYxZBUHJUlIBKtg	\N	172.18.0.15	Python/3.12 aiohttp/3.13.0	2025-10-22 18:03:18.484	\N	2025-11-07 08:29:22.465	\N
1627092983708911183	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6ImZiZTZhMDJlLTQxMGItNDk4OS04ZjYzLTRjYzI2YTlhYmFlNCJ9.eyJpYXQiOjE3NjExNTYxOTgsImV4cCI6NDkxNDc1NjE5OCwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.O_Jl-9jBKbXRE28760wBXhFcwwIPJvL2bIO21ec2Rp4	\N	172.18.0.15	Python/3.12 aiohttp/3.13.0	2025-10-22 18:03:18.62	\N	2025-11-07 08:29:22.465	\N
1627093220561258084	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6ImNhMjA0NDRmLTczMWQtNDFlMi04MjE2LTQ1ZDdiYzQ2NTVmOCJ9.eyJpYXQiOjE3NjExNTYyMjYsImV4cCI6NDkxNDc1NjIyNiwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.gpqUkXpt0sZrFi33_zOrAPyOrAwiIC--TkzybvpnDy4	\N	172.18.0.15	Python/3.12 aiohttp/3.13.0	2025-10-22 18:03:46.853	\N	2025-11-07 08:29:22.465	\N
1627548712412644974	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6ImFiMmJlOTM2LTFiYWEtNDc3ZC04ZmQ3LTMyZjQ4ZTExZmExZSJ9.eyJpYXQiOjE3NjEyMTA1MjUsImV4cCI6NDkxNDgxMDUyNSwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.Udqk5hED0u55sb_2PTINohHh-jP_Qc8L7D7zwYhI6hg	6cac0238-c8b5-4d1d-9bf7-721b5a14d05c	172.18.0.15	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36	2025-10-23 09:08:45.709	\N	2025-11-07 08:29:22.465	\N
1636555341552420678	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjZjMWQ3MzUwLThjZWQtNGUwNC1hYzNmLWQ2ODQ3MzZiNDE0OCJ9.eyJpYXQiOjE3NjIyODQxOTksImV4cCI6NDkxNTg4NDE5OSwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.n9bK5gYVa0oEk2HP7FZA4yLXCaFzLwK0ApNFAywv--I	\N	172.18.0.6	python-httpx/0.28.1	2025-11-04 19:23:19.572	\N	2025-11-07 08:29:22.465	\N
1627865015086220914	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjA2ZGZiMWM4LWJhNmQtNDJmMS1hYzhhLWI2MzI0NzU0YTEwMSJ9.eyJpYXQiOjE3NjEyNDgyMzEsImV4cCI6NDkxNDg0ODIzMSwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.GmCiFBGyyqxWsFp2HjcEwri2Ip_tH16mUSPF2fXp5oU	d21a6851-021e-4b05-ab38-d372b2a1f364	172.18.0.15	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	2025-10-23 19:37:11.92	\N	2025-11-07 08:29:22.465	\N
1628340410990462579	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6ImJkMmJiMDgxLWQ2NjItNDBjNC1hOTMwLWZlMTkwZjU3MDY3MSJ9.eyJpYXQiOjE3NjEzMDQ5MDMsImV4cCI6NDkxNDkwNDkwMywic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.lsudNQvqwWMMq0PCWK3gRmDiOSTcFjZTnmIkgwfwL5U	ac65f0fb-3e92-46e7-8e83-29388d476656	172.18.0.15	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	2025-10-24 11:21:43.536	\N	2025-11-07 08:29:22.465	\N
1630695022531708621	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6ImE5Y2NlZjNlLTZiYWUtNGVhYi04NTIyLWQ5NzkzYmU5ZWJlMiJ9.eyJpYXQiOjE3NjE1ODU1OTUsImV4cCI6NDkxNTE4NTU5NSwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.coRInUthB2DHusWM9vmNtcHDNWeH0G6N_vPkxA8rUEA	0c9457f3-5749-40f5-8845-1c200ded0238	172.18.0.20	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36	2025-10-27 17:19:55.104	\N	2025-11-07 08:29:22.465	\N
1634802356480640727	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6Ijc2ODlmMjljLTg0YTUtNDM5Zi1iNGY3LTNhYTM5Y2FkYmVkOCJ9.eyJpYXQiOjE3NjIwNzUyMjcsImV4cCI6NDkxNTY3NTIyNywic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.ylp6TqkWZCnEKTwMtzYrEn1scwC-Ghnt7GiDTadmtUI	5bfda0b8-4f33-41c9-8431-5a6fb6c45cea	172.18.0.20	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36	2025-11-02 09:20:27.471	\N	2025-11-07 08:29:22.465	\N
1634825456123381474	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjI2MmMwN2IxLWRmMjMtNDViYi04OThjLWY3ZWVjZDQyNzRkMiJ9.eyJpYXQiOjE3NjIwNzc5ODEsImV4cCI6NDkxNTY3Nzk4MSwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.qd5mj5GDbN56cQrmycZoyhTOhI-bqvhqbu1mJVk7xes	\N	172.18.0.20	PostmanRuntime/7.49.0	2025-11-02 10:06:21.161	\N	2025-11-07 08:29:22.465	\N
1635448115542623984	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjkzZmI4MDdlLTk4MjQtNGI0OS05ODFkLWIwZTNhYThjZWVjYyJ9.eyJpYXQiOjE3NjIxNTIyMDcsImV4cCI6NDkxNTc1MjIwNywic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.AagI-H27T6dNQO88k8ABXO2ruaoNVmPfA3AaoM1CP84	\N	172.18.0.20	PostmanRuntime/7.49.0	2025-11-03 06:43:27.948	\N	2025-11-07 08:29:22.465	\N
1636181107370100508	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjZlMjk2NmM2LTYxY2QtNGZmNi1hZjc4LWZlY2YxYjkxM2VjMSJ9.eyJpYXQiOjE3NjIyMzk1ODcsImV4cCI6NDkxNTgzOTU4Nywic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.FwVUYxwug8eo_bNBsAXUhBofU8RHN20Mb4RGh9By_Zs	\N	172.18.0.6	Python-urllib/3.13	2025-11-04 06:59:47.375	\N	2025-11-07 08:29:22.465	\N
1636182529859913501	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjRiN2ZhMjZlLWU1OTMtNDFmNy1hYzVjLTJhNGFmMGYzY2NkZSJ9.eyJpYXQiOjE3NjIyMzk3NTYsImV4cCI6NDkxNTgzOTc1Niwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.9Aj4Qnu9Uprsm34pE7cxZAlNdgazX1URu13TYw0-ct0	\N	172.18.0.6	python-httpx/0.27.2	2025-11-04 07:02:36.958	\N	2025-11-07 08:29:22.465	\N
1636184278700132128	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjYzZjcyYjg2LTFhNjUtNGUzOC04NGYxLWMxYTViY2VhYjM3OSJ9.eyJpYXQiOjE3NjIyMzk5NjUsImV4cCI6NDkxNTgzOTk2NSwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.xlEl8BErHqXWbRr48cP9ALl8jadhP8UNaXz4SgaAf30	\N	172.18.0.6	python-httpx/0.27.2	2025-11-04 07:06:05.435	\N	2025-11-07 08:29:22.465	\N
1636184279522215715	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjMwY2M1NmFkLWQ5YjktNGRmYy1hMTI1LWI2YTU4NTAyMjExMCJ9.eyJpYXQiOjE3NjIyMzk5NjUsImV4cCI6NDkxNTgzOTk2NSwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.nCfbr9COyDxGILptpJhxq8TmZ-bQSA46Ycsz7253dds	\N	172.18.0.6	python-httpx/0.27.2	2025-11-04 07:06:05.534	\N	2025-11-07 08:29:22.465	\N
1636194979585984292	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjY3ZjBkZTVhLWFmNDgtNDAwOS05ZTY0LWRlYzEwYTBkYjBmMyJ9.eyJpYXQiOjE3NjIyNDEyNDEsImV4cCI6NDkxNTg0MTI0MSwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.r8mZxjbfCrQBBNR9-BP4Muk76JOFHJF8tswOz0dyX9M	\N	172.18.0.6	python-httpx/0.27.2	2025-11-04 07:27:21.08	\N	2025-11-07 08:29:22.465	\N
1636194980391290663	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6ImNkMDMzMWY0LTdkMjItNDkyNi04ZjU1LTUwYTc4MGFhNDc5ZiJ9.eyJpYXQiOjE3NjIyNDEyNDEsImV4cCI6NDkxNTg0MTI0MSwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.a_VTqXMk2xGS7mQVFuPMTSvUFbzDWlxyuFk4N6Xp-Lw	\N	172.18.0.6	python-httpx/0.27.2	2025-11-04 07:27:21.177	\N	2025-11-07 08:29:22.465	\N
1636362670242268972	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6ImRmYjIyZDY3LWMwNjMtNGU1Mi05MDcwLTk5YjczMjIxZGNkMyJ9.eyJpYXQiOjE3NjIyNjEyMzEsImV4cCI6NDkxNTg2MTIzMSwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.GDNAtoEVvp4jb8qiCGBJ5jqGJLYrL9xDO7RW_x1Shco	\N	172.18.0.6	python-httpx/0.28.1	2025-11-04 13:00:31.347	\N	2025-11-07 08:29:22.465	\N
1636362671391508271	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjNhMTQ4M2M1LTUxMzktNDdiMy1hYjhiLWUxZTAzYmI5YjY2NSJ9.eyJpYXQiOjE3NjIyNjEyMzEsImV4cCI6NDkxNTg2MTIzMSwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.2xYKvm4X_SLCEAXcH4DolJJoNVX95FELmuzYdt6CA4o	\N	172.18.0.6	python-httpx/0.28.1	2025-11-04 13:00:31.503	\N	2025-11-07 08:29:22.465	\N
1636366527567497012	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjYzMmYwYzZlLTFjNjItNGUyMy05YTg4LWRmYjIyNWJjMmE4YSJ9.eyJpYXQiOjE3NjIyNjE2OTEsImV4cCI6NDkxNTg2MTY5MSwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.HhW7ADDIwmC--pFNa1DnckwXLT0VjmyqYlQxXPnBqgk	\N	172.18.0.6	python-httpx/0.28.1	2025-11-04 13:08:11.19	\N	2025-11-07 08:29:22.465	\N
1636366528439912247	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjY2YjVhOThmLTIzMDAtNDllMC05MTA0LTk5ZGYxY2NlODdmNiJ9.eyJpYXQiOjE3NjIyNjE2OTEsImV4cCI6NDkxNTg2MTY5MSwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.f_vve9HghPSvC5wiIqzhLYHA87cfTnzpnUGx2SrsebU	\N	172.18.0.6	python-httpx/0.28.1	2025-11-04 13:08:11.298	\N	2025-11-07 08:29:22.465	\N
1636366529186498364	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6ImIzODBkMmMzLTY5NjYtNDc5OS05YmQ2LWFjYzE2MDJmMDQ2OCJ9.eyJpYXQiOjE3NjIyNjE2OTEsImV4cCI6NDkxNTg2MTY5MSwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.yTNh5WGB3uIz24qg4ClQw_Xed1gnq5Q8R1rDlRTuU7U	\N	172.18.0.6	python-httpx/0.28.1	2025-11-04 13:08:11.389	\N	2025-11-07 08:29:22.465	\N
1636423058640078653	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6ImMzYmIzOGM0LWExNGUtNGQzYy1hMjhhLWViNjczYTJhMDg5NSJ9.eyJpYXQiOjE3NjIyNjg0MzAsImV4cCI6NDkxNTg2ODQzMCwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.ZHsrtv4QBrj3OAwSxQWxkQoVvmDpT_mC59U3w76Pu4E	\N	172.18.0.6	python-httpx/0.28.1	2025-11-04 15:00:30.222	\N	2025-11-07 08:29:22.465	\N
1636498709413889856	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjgwMDlhZmRjLTdiZjgtNDBkMC05ZGY5LTAxNWI2ODg3YmYyMyJ9.eyJpYXQiOjE3NjIyNzc0NDgsImV4cCI6NDkxNTg3NzQ0OCwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.ZAqtkZX1PZF6204cO9GWXkFu5hBscSrhZJxLtDVVrto	\N	172.18.0.6	python-httpx/0.28.1	2025-11-04 17:30:48.489	\N	2025-11-07 08:29:22.465	\N
1636537680428795713	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6ImFhZmE1ZWJlLWQ1OGUtNGFmYS1hNzBlLTU2YzExYTJmYTZkYiJ9.eyJpYXQiOjE3NjIyODIwOTQsImV4cCI6NDkxNTg4MjA5NCwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.D7tn6WOsVgNqR4oYe9iIO5T9_WGgW_6ZBJwv9H-6oVs	\N	172.18.0.6	python-httpx/0.28.1	2025-11-04 18:48:14.204	\N	2025-11-07 08:29:22.465	\N
1636538679285516098	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjIxZGQxOWQ2LThkZmUtNGFhYi1iOTY2LTYyZmE1MWY0ODY1NiJ9.eyJpYXQiOjE3NjIyODIyMTMsImV4cCI6NDkxNTg4MjIxMywic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.fjYr_f5MREs_C68lZEqmp3_5AWpe2GPHHExj5S7EvME	\N	172.18.0.6	python-httpx/0.28.1	2025-11-04 18:50:13.277	\N	2025-11-07 08:29:22.465	\N
1636543758906427203	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6ImU2MWJlMjI1LTQxOWUtNDFkZi1hMDcxLTNhMWM5MjNhOGJiYSJ9.eyJpYXQiOjE3NjIyODI4MTgsImV4cCI6NDkxNTg4MjgxOCwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.CHlhWsjBU8DvtwkqsBv61DsTJyTwsjIVjTaUA6lDEh0	\N	172.18.0.6	python-httpx/0.28.1	2025-11-04 19:00:18.814	\N	2025-11-07 08:29:22.465	\N
1636560255481546567	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6Ijg1OWIzM2NhLTkzNjMtNDNmNS1iODlhLTY1NzNmNmFhZTNlMSJ9.eyJpYXQiOjE3NjIyODQ3ODUsImV4cCI6NDkxNTg4NDc4NSwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.lgveVyfRpHz9aqTLvlnowG4bLMX0HwoZ-H7YPHeZjro	\N	172.18.0.6	python-httpx/0.28.1	2025-11-04 19:33:05.359	\N	2025-11-07 08:29:22.465	\N
1636569167815509832	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjkzZmNmMDkwLWI3NjQtNGE2Mi05NGM3LTQ0MjUzNmE3ODQwMCJ9.eyJpYXQiOjE3NjIyODU4NDcsImV4cCI6NDkxNTg4NTg0Nywic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.gEAE8cTDqStFmahpxsjlGG2BxZpHFvvJnZ2ShdCbNbE	\N	172.18.0.6	python-httpx/0.28.1	2025-11-04 19:50:47.793	\N	2025-11-07 08:29:22.465	\N
1636569886425614153	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjFiOWJmYTQzLWYwMjctNGE1ZS1hZmM4LTBjY2VjMTRhN2Y5MSJ9.eyJpYXQiOjE3NjIyODU5MzMsImV4cCI6NDkxNTg4NTkzMywic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.Wwnqt9NSuk-SHQzas4IQKFYLVoECHVB6Jhk-yDEOe-s	\N	172.18.0.6	python-httpx/0.28.1	2025-11-04 19:52:13.457	\N	2025-11-07 08:29:22.465	\N
1636570285622691658	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6Ijk3Y2VjODM2LTU1MjAtNDMzZi1hNDdkLTIzZjZhNzM4MDBhYSJ9.eyJpYXQiOjE3NjIyODU5ODEsImV4cCI6NDkxNTg4NTk4MSwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.CKjNksfRSm6v6kIAF4YWZfDZj2ojVoP4xe2azC88JuU	\N	172.18.0.6	python-httpx/0.28.1	2025-11-04 19:53:01.043	\N	2025-11-07 08:29:22.465	\N
1636574684642281291	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjY5Y2Q5NGMyLWJlZmMtNDRlMi05ZGQ5LTczMzA1ZTEwZjkwZSJ9.eyJpYXQiOjE3NjIyODY1MDUsImV4cCI6NDkxNTg4NjUwNSwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.Z0c_toVQjdE1lXYk61HPU5hxf1DfMlI7-TSFWgGrpnA	\N	172.18.0.6	python-httpx/0.28.1	2025-11-04 20:01:45.45	\N	2025-11-07 08:29:22.465	\N
1636578026839869260	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6ImUxNzA2ZGY4LWJlZjUtNGM0OC1hMDI2LWI5MmRiOGJkZGMyYiJ9.eyJpYXQiOjE3NjIyODY5MDMsImV4cCI6NDkxNTg4NjkwMywic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.V-iYXe-mozTqjXfkJidEQzcwTylg8fY8meMN31Z5dKM	\N	172.18.0.6	python-httpx/0.28.1	2025-11-04 20:08:23.87	\N	2025-11-07 08:29:22.465	\N
1636581031916078925	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjgyMjZlNTE2LTE5M2EtNDgwZS1hMWM4LTZkNWM3MTVmYmFlOCJ9.eyJpYXQiOjE3NjIyODcyNjIsImV4cCI6NDkxNTg4NzI2Miwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.jAXrfXyIhoBLnaTE6U2SL4gEepAHNU27BN6_oTFfoQc	\N	172.18.0.6	python-httpx/0.28.1	2025-11-04 20:14:22.095	\N	2025-11-07 08:29:22.465	\N
1636582546705745742	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6ImEyZGE5YWJkLWNmZWItNGFhNi1iZDhkLTM3MmJlN2YxNzY5NyJ9.eyJpYXQiOjE3NjIyODc0NDIsImV4cCI6NDkxNTg4NzQ0Miwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.cit9OubYXb1qWrf9TKIepIFabg0ESBKqcm6-YG5K2cc	\N	172.18.0.6	python-httpx/0.28.1	2025-11-04 20:17:22.681	\N	2025-11-07 08:29:22.465	\N
1636602006338537297	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjBlOGY1MDhmLWU0ZGMtNGZlOS1hNGY0LTQzZTA1Y2UyMmI0OCJ9.eyJpYXQiOjE3NjIyODk3NjIsImV4cCI6NDkxNTg4OTc2Miwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.pcMXT8HtyL318EUa7b10oF1dYCK1IBgxcmdXldy6iS0	\N	172.18.0.6	python-httpx/0.28.1	2025-11-04 20:56:02.45	\N	2025-11-07 08:29:22.465	\N
1636618542222673748	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6ImRhNWNjMzE1LTZlNWItNDBjNy1iYzNmLTcyMWY3MjliM2FhNSJ9.eyJpYXQiOjE3NjIyOTE3MzMsImV4cCI6NDkxNTg5MTczMywic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.3Euoh6edRGfMU75FovviGXq3cm1g9awX386XH3wV53I	\N	172.18.0.6	python-httpx/0.28.1	2025-11-04 21:28:53.68	\N	2025-11-07 08:29:22.465	\N
1636618543170586455	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjEwNTYxZGNkLTJkNmYtNGY5NC1iYWUwLWFhNzFjNDFlMzc4NCJ9.eyJpYXQiOjE3NjIyOTE3MzMsImV4cCI6NDkxNTg5MTczMywic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.3tF9yDxA-lmUQBGd4-sHT-LOjJbCAEdw1-8naULZz50	\N	172.18.0.6	python-httpx/0.28.1	2025-11-04 21:28:53.796	\N	2025-11-07 08:29:22.465	\N
1636621051263715164	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6ImJjY2QxNGI3LTAzZTAtNDU0YS04OTNmLTFhY2I0MTAwMzJkNCJ9.eyJpYXQiOjE3NjIyOTIwMzIsImV4cCI6NDkxNTg5MjAzMiwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.Rr2vbdYkr3AVI4uWrOFb_UfmOHjpGcKTIxrcpTCBeNo	\N	172.18.0.6	python-httpx/0.28.1	2025-11-04 21:33:52.781	\N	2025-11-07 08:29:22.465	\N
1636621052161296223	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjFhYTZiZGRjLTkzZDUtNDU1MC1iOTVhLTY2YTg0YTI1ZmQyZSJ9.eyJpYXQiOjE3NjIyOTIwMzIsImV4cCI6NDkxNTg5MjAzMiwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.NKF2vHhyHxOyeSOeOjSFsp5q9__5p1K2udYmr50P_QI	\N	172.18.0.6	python-httpx/0.28.1	2025-11-04 21:33:52.89	\N	2025-11-07 08:29:22.465	\N
1636622652187608932	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6Ijg5NmQwMGEwLTc5YzctNGIwZi05NzMxLTUzNzg5MTQ1ZmZmYyJ9.eyJpYXQiOjE3NjIyOTIyMjMsImV4cCI6NDkxNTg5MjIyMywic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.kRTWoF43nPfIz8-mWMxImOmz60_s7NfoBHMl-GRfLyw	\N	172.18.0.6	python-httpx/0.28.1	2025-11-04 21:37:03.624	\N	2025-11-07 08:29:22.465	\N
1636622653026469735	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjViZWVkNTFjLWRmZWYtNGE1Yy04ZjJlLTU5ZjJhYzE3M2ZmNCJ9.eyJpYXQiOjE3NjIyOTIyMjMsImV4cCI6NDkxNTg5MjIyMywic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.oKNUj7yywiTcAyflBK7fITNxN62Ym1M9zIvILDITZgs	\N	172.18.0.6	python-httpx/0.28.1	2025-11-04 21:37:03.73	\N	2025-11-07 08:29:22.465	\N
1636622653806610284	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjFjYTBhY2JkLWFjZTMtNDk1NS1hZmQ0LWQ2ZmYyOWUyY2QwYSJ9.eyJpYXQiOjE3NjIyOTIyMjMsImV4cCI6NDkxNTg5MjIyMywic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.6shUHZ80DlNLhBgdH-bAomqXe_zSfPMb8CLfBRmP-Jg	\N	172.18.0.6	python-httpx/0.28.1	2025-11-04 21:37:03.823	\N	2025-11-07 08:29:22.465	\N
1636624464462481262	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjM4MjA0MDQ5LWVjZjktNGMzZS1hYTYzLWIyYTc4YTU0Yzk5NyJ9.eyJpYXQiOjE3NjIyOTI0MzksImV4cCI6NDkxNTg5MjQzOSwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.l3P9mPAp9ZJQdAE73_-KAaZd-3HrxyYK1oOw7gMpDD4	\N	172.18.0.6	python-httpx/0.28.1	2025-11-04 21:40:39.665	\N	2025-11-07 08:29:22.465	\N
1636624465267787633	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjRkZWRiNWY3LTc0M2EtNDZjMi05YjQzLTZhYmU5ZWZlMmQ2MCJ9.eyJpYXQiOjE3NjIyOTI0MzksImV4cCI6NDkxNTg5MjQzOSwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.WeS47McalUfdW8xeOZftXdtTYpKx8LMQfXa-XasjMbs	\N	172.18.0.6	python-httpx/0.28.1	2025-11-04 21:40:39.765	\N	2025-11-07 08:29:22.465	\N
1636624466316363638	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6ImI2MWQ1NzkwLTI2OWYtNDJmYi1hNjM4LTkzNmMxNjNkMGFhZCJ9.eyJpYXQiOjE3NjIyOTI0MzksImV4cCI6NDkxNTg5MjQzOSwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.IJcMKWFVYqF9I-gPVw3Ecg3j0_HbCQ8JTes6WIzLh6E	\N	172.18.0.6	python-httpx/0.28.1	2025-11-04 21:40:39.891	\N	2025-11-07 08:29:22.465	\N
1636624467339773821	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6ImIyYzQ4ZmM0LWY3ODQtNDY3ZS1iNmQ5LTJlY2E2YmNmYjliZiJ9.eyJpYXQiOjE3NjIyOTI0NDAsImV4cCI6NDkxNTg5MjQ0MCwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.Hv6wtCuq8ivI_F_QQtxbi8-VLr9zvBzwyLaLZEqp1KI	\N	172.18.0.6	python-httpx/0.28.1	2025-11-04 21:40:40.013	\N	2025-11-07 08:29:22.465	\N
1636624468094748545	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjNkM2Q4NmNjLTJmZWEtNDNkMS1hOTdmLWFjYjJhZmFhZTMxNCJ9.eyJpYXQiOjE3NjIyOTI0NDAsImV4cCI6NDkxNTg5MjQ0MCwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.kbXUoVSDK0TcKQoUGGiGpmOEbM-ZT-hwLx-GHZ-ro1Y	\N	172.18.0.6	python-httpx/0.28.1	2025-11-04 21:40:40.103	\N	2025-11-07 08:29:22.465	\N
1636624469294319503	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6ImE3ZDFiYTNiLTJhYTYtNGI1OS1iNjUwLWQ0ZGE4NDQ5OTUwMSJ9.eyJpYXQiOjE3NjIyOTI0NDAsImV4cCI6NDkxNTg5MjQ0MCwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.vgnZ_36x64d1Xt6PRxfvDNTSXfHZw8maOgPIYYfYmc4	\N	172.18.0.6	python-httpx/0.28.1	2025-11-04 21:40:40.245	\N	2025-11-07 08:29:22.465	\N
1636626841273894802	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjY2MWM4ZjQ1LTEyMWMtNGI5ZS05ODIxLWE2Mzk2YTg1YWQxYyJ9.eyJpYXQiOjE3NjIyOTI3MjMsImV4cCI6NDkxNTg5MjcyMywic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.rUAEknvCtszf6sFwUmwja0IoD_chxuuxnMu5xA1K-88	\N	172.18.0.6	python-httpx/0.28.1	2025-11-04 21:45:23.006	\N	2025-11-07 08:29:22.465	\N
1636626842121144213	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjQ0MmM5MDAyLWRiNjAtNDNkMC05YThjLTk3YjUzMjAyNDYxNyJ9.eyJpYXQiOjE3NjIyOTI3MjMsImV4cCI6NDkxNTg5MjcyMywic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.dMbamyDwePkHaG8jNruDan4w5G6dJUZlcAKqWsVy7VM	\N	172.18.0.6	python-httpx/0.28.1	2025-11-04 21:45:23.107	\N	2025-11-07 08:29:22.465	\N
1636626842968393626	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjZjZmQwZTdmLTA2ZWYtNDE5Yy1iM2JmLWJmNWM0NWYwOWUyYSJ9.eyJpYXQiOjE3NjIyOTI3MjMsImV4cCI6NDkxNTg5MjcyMywic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.lT2PhABAq6CL6dFYDSKWsK3qtvXczNdC6pkpQ0s-3AU	\N	172.18.0.6	python-httpx/0.28.1	2025-11-04 21:45:23.21	\N	2025-11-07 08:29:22.465	\N
1636626843966637985	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6ImVmMDUxM2ZhLTNhMWYtNDE2MS1hZDJiLTE3NWNkNjhhYzNiOSJ9.eyJpYXQiOjE3NjIyOTI3MjMsImV4cCI6NDkxNTg5MjcyMywic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.NuEdsHzvlzYCTEQ1hHft6yC0XhWTsR33xabXUgevdSI	\N	172.18.0.6	python-httpx/0.28.1	2025-11-04 21:45:23.329	\N	2025-11-07 08:29:22.465	\N
1636629172140902306	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjZlYWY3NGZiLTYxZTUtNGY0Zi05N2EzLTYyMTJiN2M3Mzk4OCJ9.eyJpYXQiOjE3NjIyOTMwMDAsImV4cCI6NDkxNTg5MzAwMCwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9._ZnZpqdhjWEb2yZzOe-DEnHoBn46Na-0logD1804jdw	\N	172.18.0.6	python-httpx/0.28.1	2025-11-04 21:50:00.864	\N	2025-11-07 08:29:22.465	\N
1636629173004928933	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjAwMTI5Njg4LTZmNWQtNGQ2My1iZjFjLWEyZTA2N2Y2ZWNlOCJ9.eyJpYXQiOjE3NjIyOTMwMDAsImV4cCI6NDkxNTg5MzAwMCwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.X1OVv3XE_wT0QZbjzKTQwoKx7Q5lKj14wLENQTdFmXM	\N	172.18.0.6	python-httpx/0.28.1	2025-11-04 21:50:00.971	\N	2025-11-07 08:29:22.465	\N
1636629173734737834	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjVlNWE5MDliLTUzNDctNDk1Yy05MWUyLTc2YTU0Mjc1ZThkMSJ9.eyJpYXQiOjE3NjIyOTMwMDEsImV4cCI6NDkxNTg5MzAwMSwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.S6mASqcUMmWjPGdU6u-YSfrAqZ_t5GljCP_oYrgLibg	\N	172.18.0.6	python-httpx/0.28.1	2025-11-04 21:50:01.058	\N	2025-11-07 08:29:22.465	\N
1636629174758148017	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6ImNkZjk3NDQ0LTUzMDItNGI4Ny1hZjUwLTNmMTA1MzE0OTU3OCJ9.eyJpYXQiOjE3NjIyOTMwMDEsImV4cCI6NDkxNTg5MzAwMSwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.IzskG6e5KmbbpnHGqRxRc9DGGHN543KB14HVXzM2V8g	\N	172.18.0.6	python-httpx/0.28.1	2025-11-04 21:50:01.18	\N	2025-11-07 08:29:22.465	\N
1636629175513122741	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjQ2NmM2YTU4LTUwZTItNDMwMi1hMjM1LWZkYzFmMWVhZjM4ZCJ9.eyJpYXQiOjE3NjIyOTMwMDEsImV4cCI6NDkxNTg5MzAwMSwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.EkGt0AQEfHPZ8a9zcq_Ko6TPiy7G8zVdDwaJopY_QQA	\N	172.18.0.6	python-httpx/0.28.1	2025-11-04 21:50:01.271	\N	2025-11-07 08:29:22.465	\N
1636629176670750659	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjRmMjE0ZDk3LWM5MTItNGU2MS05MWE3LTJhMmJiYTk3NjkyNCJ9.eyJpYXQiOjE3NjIyOTMwMDEsImV4cCI6NDkxNTg5MzAwMSwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.tDVRpKlq7Tege7M8Rd9RRsQcXrmquZt7or3j0znEQ1s	\N	172.18.0.6	python-httpx/0.28.1	2025-11-04 21:50:01.408	\N	2025-11-07 08:29:22.465	\N
1636635390792173510	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjlhNGUwNzg3LWM4ODItNDQ3ZC1iMjRiLWJjOTc4OWY3MDBlNyJ9.eyJpYXQiOjE3NjIyOTM3NDIsImV4cCI6NDkxNTg5Mzc0Miwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.t8no855pYjfbNYgHXZil9Z7U6hBNA6ZARdZSUcxP_z8	\N	172.18.0.6	python-httpx/0.28.1	2025-11-04 22:02:22.187	\N	2025-11-07 08:29:22.465	\N
1636635391790417865	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6ImFkZWZiNjk3LWQzMGEtNGE3Ny04NGIwLTRkZjZlZjU4YTM0MiJ9.eyJpYXQiOjE3NjIyOTM3NDIsImV4cCI6NDkxNTg5Mzc0Miwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.dXIpBSjfGJyd-sUlqgzqPO1HB2aR3M7EbIcAd4Cpf54	\N	172.18.0.6	python-httpx/0.28.1	2025-11-04 22:02:22.308	\N	2025-11-07 08:29:22.465	\N
1636635392520226766	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjYyMGFiNjU5LWVhZTYtNDBlNS1iNGMwLTUyY2JlZGYwM2MwZSJ9.eyJpYXQiOjE3NjIyOTM3NDIsImV4cCI6NDkxNTg5Mzc0Miwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.8d5MgY07kyvDqrF0KuMlC-5xXjgbnq6X8lpMyusNNfw	\N	172.18.0.6	python-httpx/0.28.1	2025-11-04 22:02:22.396	\N	2025-11-07 08:29:22.465	\N
1636635393610745813	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6ImYwMDQxYjg5LTA4MWYtNDg1MC1hOGM5LTg3YmIzZTUzOGE4NiJ9.eyJpYXQiOjE3NjIyOTM3NDIsImV4cCI6NDkxNTg5Mzc0Miwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.4Oxgsxg-TlrtEnBZ8MG3M52sTY9-j4PRt6e-Z3fuOEA	\N	172.18.0.6	python-httpx/0.28.1	2025-11-04 22:02:22.526	\N	2025-11-07 08:29:22.465	\N
1636635394416052185	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjM1OTFjNjZiLWU3YjEtNGQ1Yy05MzI0LWFhOWY2NWIwZjMyMSJ9.eyJpYXQiOjE3NjIyOTM3NDIsImV4cCI6NDkxNTg5Mzc0Miwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.t1OXmEzK0kPA9cPGnFSveKXGK9DSIguHWGDd4R5LGj4	\N	172.18.0.6	python-httpx/0.28.1	2025-11-04 22:02:22.621	\N	2025-11-07 08:29:22.465	\N
1636635395825338343	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjRhNDNmZTA0LWFkODAtNDNjMi05ZGQzLWQ0ZjhlYjllZWZjMCJ9.eyJpYXQiOjE3NjIyOTM3NDIsImV4cCI6NDkxNTg5Mzc0Miwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.2S-l1zgCwnYrQkYl15EWO05N6LG9HyRlhyzqInN6N0c	\N	172.18.0.6	python-httpx/0.28.1	2025-11-04 22:02:22.79	\N	2025-11-07 08:29:22.465	\N
1636639386932086762	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjFmZGU2OGFiLTE4NmItNDYyZS04Yjc0LTk3NDYyYTY2YTI0YSJ9.eyJpYXQiOjE3NjIyOTQyMTgsImV4cCI6NDkxNTg5NDIxOCwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.IM4h6E-9r55LydFN4q4IIFRJwcxEKhDkk48oaMYj6Qo	\N	172.18.0.6	python-httpx/0.28.1	2025-11-04 22:10:18.564	\N	2025-11-07 08:29:22.465	\N
1636639387720615917	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6Ijc1YzQ4MjIzLWI4NDYtNDZlOS1hYzhjLTEwYjJmMTQxZGVlYSJ9.eyJpYXQiOjE3NjIyOTQyMTgsImV4cCI6NDkxNTg5NDIxOCwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.ZQ9OLweUGfqFt5beEQjZRcSvkHTXkJzxt_gMRGskf04	\N	172.18.0.6	python-httpx/0.28.1	2025-11-04 22:10:18.661	\N	2025-11-07 08:29:22.465	\N
1636639388433647602	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjE2MmNmYTYxLTA4MGUtNDk5Mi1hMzRjLTY0ODdjYmMyYTU5ZiJ9.eyJpYXQiOjE3NjIyOTQyMTgsImV4cCI6NDkxNTg5NDIxOCwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.SJLwaR0qtEYwjSk4sdEfvD5FYccdgi5MYY-eq8iODQg	\N	172.18.0.6	python-httpx/0.28.1	2025-11-04 22:10:18.745	\N	2025-11-07 08:29:22.465	\N
1636639389499000825	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjhmZTcwMmI3LWM1NDQtNDc2ZC1hZDQ0LTU2NTM3YjU2NDU4YyJ9.eyJpYXQiOjE3NjIyOTQyMTgsImV4cCI6NDkxNTg5NDIxOCwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.yz-Y76NyXbAm5FfbaURVP1rMydos6uWpwk6RBm1RhOw	\N	172.18.0.6	python-httpx/0.28.1	2025-11-04 22:10:18.872	\N	2025-11-07 08:29:22.465	\N
1636639390228809725	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6ImMzYWQwNzE5LTZkZmMtNGY2OC1hMGFhLWJjYjJkNWYyYzhiMyJ9.eyJpYXQiOjE3NjIyOTQyMTgsImV4cCI6NDkxNTg5NDIxOCwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.3Bk2IV-cfMZVtj0hFArK6J7kukxD8unqY2PDrJncmfQ	\N	172.18.0.6	python-httpx/0.28.1	2025-11-04 22:10:18.96	\N	2025-11-07 08:29:22.465	\N
1636639391562597387	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjE5MzllNmE5LTczNTEtNGNlNi1iZmE1LWEzMjBkNWNmOWQ3NSJ9.eyJpYXQiOjE3NjIyOTQyMTksImV4cCI6NDkxNTg5NDIxOSwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.dlgJSh7sQA5VPoP1l6bOrXSA4Xyqbjcq_ADpn25MRcI	\N	172.18.0.6	python-httpx/0.28.1	2025-11-04 22:10:19.119	\N	2025-11-07 08:29:22.465	\N
1637116326331810831	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6Ijg4Nzc2MWQ3LWVjM2ItNDhkMy1iYWRkLTdhMDMwOWUwY2RlYyJ9.eyJpYXQiOjE3NjIzNTEwNzQsImV4cCI6NDkxNTk1MTA3NCwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.wI2KTbHblptZ_EJ2Wu_M_uH9NYE0iroMVTySJNHffqY	\N	172.18.0.6	Python-urllib/3.14	2025-11-05 13:57:54.163	\N	2025-11-07 08:29:22.465	\N
1637116398322844688	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjM0YWNmYmI1LTY0ZDAtNDE3My04OWNiLTk3ZjRlN2EwMjVhMiJ9.eyJpYXQiOjE3NjIzNTEwODIsImV4cCI6NDkxNTk1MTA4Miwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.hWmWdGJPxsRUSvJXKl8YulTS69RdnruKs5ALw-rcg6M	\N	172.18.0.6	Python-urllib/3.14	2025-11-05 13:58:02.755	\N	2025-11-07 08:29:22.465	\N
1637202878529537080	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjgzMjkyYWM3LTAyYjMtNDdhOS1hMDhlLTMzNjAyOGI5ZDFkNiJ9.eyJpYXQiOjE3NjIzNjEzOTEsImV4cCI6NDkxNTk2MTM5MSwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.Cfk7cM14nPnHhRJ7HK0tg9Kc0oJSKrCn0Z3KAxiHnng	\N	172.18.0.6	curl/8.7.1	2025-11-05 16:49:51.989	\N	2025-11-07 08:29:22.465	\N
1637379573190493243	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjFmNzY0ZjdjLWU1YmQtNGQ2MC05MTU2LTViMmE3ZDUzNzllOCJ9.eyJpYXQiOjE3NjIzODI0NTUsImV4cCI6NDkxNTk4MjQ1NSwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.tyipti3up5JeDGuhIwIaVOSkFMLlG0OzWRdpCQijslk	\N	172.18.0.6	modelcontextprotocol/servers/planka/v0.1.0 Node.js/24	2025-11-05 22:40:55.639	\N	2025-11-07 08:29:22.465	\N
1637771579049903167	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6ImRkYjU1ZmFkLTRkMDgtNDE0Yy1iOWFkLTZmM2FkNWFhNTVlMiJ9.eyJpYXQiOjE3NjI0MjkxODYsImV4cCI6NDkxNjAyOTE4Niwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.kOAEMn9XsyBTRArkfPXHt6WWAR19-yZ4FHF4LC-FOIU	2a1a4935-fbff-40ed-9e99-44477b01382c	172.18.0.6	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 OPR/122.0.0.0	2025-11-06 11:39:46.382	\N	2025-11-07 08:29:22.465	\N
1637814492794455104	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjQzZGQ1NzE1LWU0ODgtNDNhNy1hODczLTU4NDBkOTBlNWQ4NyJ9.eyJpYXQiOjE3NjI0MzQzMDIsImV4cCI6NDkxNjAzNDMwMiwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.0mmnp7FWAKkhMN9BVwDoap_DwqStpEJTm9MO3Xl_0lw	\N	172.18.0.6	Bun/1.2.23	2025-11-06 13:05:02.092	\N	2025-11-07 08:29:22.465	\N
1637877167582872651	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjllODU0MjhiLTM2YzgtNGVmOS05NmY1LTRiNTFmY2YxZGYzYiJ9.eyJpYXQiOjE3NjI0NDE3NzMsImV4cCI6NDkxNjA0MTc3Mywic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.xmPSEhEaVJm4wO8p0xrsNJ0sWNYI1zshB0MDLziaXAE	\N	172.18.0.6	Bun/1.2.23	2025-11-06 15:09:33.51	\N	2025-11-07 08:29:22.465	\N
1638393359846343757	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6ImYwODI5M2Q1LTI2YWUtNDdhOS04OGIxLTNmMjQyYzBmY2MwOCJ9.eyJpYXQiOjE3NjI1MDMzMDgsImV4cCI6NDkxNjEwMzMwOCwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.MaAk9IPVvW_4ZvkA5i0HHkee5rbr7Ac2lr8M8lqfYc0	\N	172.18.0.6	modelcontextprotocol/servers/planka/v0.1.0 Node.js/24	2025-11-07 08:15:08.428	\N	2025-11-07 08:29:22.465	\N
1638777790868227152	1560328737491256322	\N	\N	172.18.0.6	curl/8.7.1	2025-11-07 20:58:56.178	\N	\N	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6ImM4OTMwZDk1LTQ0MWItNDFhYi05YjNlLWQwMDJhZDQwOTQ2YiJ9.eyJpYXQiOjE3NjI1NDkxMzYsImV4cCI6MTc2MjU0OTczNiwic3ViIjoiYWNjZXB0LXRlcm1zIn0._JYGz7aF16fph7oxf_fBP5QcfyBaLe6ugwaH7b_ylbI
1639160226894578769	1560328737491256322	\N	\N	172.18.0.6	curl/8.7.1	2025-11-08 09:38:46.105	\N	\N	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjQ5ZDI0MjZmLWJhZjYtNGRmZS1iMGQ0LTFiZTliY2I1YzM2NSJ9.eyJpYXQiOjE3NjI1OTQ3MjYsImV4cCI6MTc2MjU5NTMyNiwic3ViIjoiYWNjZXB0LXRlcm1zIn0.S6oCSGExaeDBaiZE_c1S6TU8_VOi6kgpuap369jNEo8
1639160256724468818	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjA2ODdhOWY1LTlmODgtNDk4Ni1hMjZmLWJlZDllYzY3OWMyMCJ9.eyJpYXQiOjE3NjI1OTQ5MzEsImV4cCI6NDkxNjE5NDkzMSwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.I1JDqfy7OzP6fFYDm2RFvUmRuVN8qtMf-8lPXepR3Lo	\N	172.18.0.6	curl/8.7.1	2025-11-08 09:38:49.663	2025-11-08 09:42:11.851	\N	\N
1643453443471311981	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6ImQ0NmZlMTdiLTQwMWUtNDQxNi05MDQ4LTQxMWM1ZDQ0NTFiZSJ9.eyJpYXQiOjE3NjMxMDY1MTcsImV4cCI6MTc5NDY0MjUxNywic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.961HOmoURajoDnWbmgHyv_HZzh92x5_bc-Dgc9LYu2s	ef068765-c21e-4f65-80ff-b7835c7938cc	172.66.150.169	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	2025-11-14 07:48:37.295	\N	\N	\N
1644156136787543151	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjlmZjQzYzY3LTJmMTctNDI3NS1hMjRjLWI4ZjJjYzFmODQzOSJ9.eyJpYXQiOjE3NjMxOTAyODQsImV4cCI6NDkxNjc5MDI4NCwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.pqTmxdls7qk8ePRZPaupLrI-y2EAWkqCfuzpyt7OJ-g	7af73253-8e66-4d38-9eb6-3c7c682b405e	172.18.0.8	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	2025-11-15 07:04:44.959	\N	\N	\N
1644160172572017777	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6ImM3ZWFiNTMyLWNhM2YtNDYwMC05MzE1LWQ3OWIyNmJkMGU2ZiJ9.eyJpYXQiOjE3NjMxOTA3NjYsImV4cCI6NDkxNjc5MDc2Niwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.LwOJFmegP_lEYyqmc8i8xQ0PuqCgXwP7doE2Y32FISg	\N	172.18.0.8	modelcontextprotocol/servers/planka/v0.1.0 Node.js/25	2025-11-15 07:12:46.077	\N	\N	\N
1644162031546270835	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6ImM1MjA2NDNlLTA0YTYtNGNhNC04YmNhLTY5ODZhYTZhMWQ3OSJ9.eyJpYXQiOjE3NjMxOTA5ODcsImV4cCI6NDkxNjc5MDk4Nywic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.sTCir3gd4m0O6U7C4XGBTqp_Bsm2byV-GoKMBvhxlvk	\N	172.18.0.8	python-httpx/0.28.1	2025-11-15 07:16:27.686	\N	\N	\N
1646330706638406784	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjY2MjFjNDM3LTc5ODYtNDIzYS1hNmMxLTE0NTFlMTRjMjM0ZCJ9.eyJpYXQiOjE3NjM0NDk1MTMsImV4cCI6NDkxNzA0OTUxMywic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.4OwK3V3ADni1LCbh5VV1QcEqG3gLOVpBsv1rjBnFbLs	ea0f7690-86f0-4205-934f-cd6ad3b7030d	172.18.0.21	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	2025-11-18 07:05:13.888	\N	\N	\N
1646359974651102340	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjI1YTg5ZGM3LTZiMGEtNDZkNy1hYzUyLTNhZGVjNGU1NmVlZCJ9.eyJpYXQiOjE3NjM0NTMwMDIsImV4cCI6NDkxNzA1MzAwMiwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.aXKRhd-_bjVg9AGLo7FywF-dhglq56au7WLFsjFnYT4	dc68ebdd-b61a-4522-8be6-050df7ea2fd9	172.18.0.21	node	2025-11-18 08:03:22.836	\N	\N	\N
1646386614219310215	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6ImZjMGY3NDY3LTgzYTctNDM2OS04OWFkLTVjNzk5YzM3M2I1MyJ9.eyJpYXQiOjE3NjM0NTYxNzgsImV4cCI6NDkxNzA1NjE3OCwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.IxGVCJ0_gB3-aQmJPxX4WLkMI4BHbzSvnH7oxNWzpfI	44a91297-30b9-4f0d-a6f0-2b7a01431768	172.18.0.21	node	2025-11-18 08:56:18.587	\N	\N	\N
1646409504608224394	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjUwNTY3MDJkLTY0ZWItNGI5Mi1iM2QyLTdlOTQ0YWMxZWRjMCJ9.eyJpYXQiOjE3NjM0NTg5MDcsImV4cCI6NDkxNzA1ODkwNywic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.yJtQQw7QI7QFyl_XwDkcNTVhN_zRzhmDknyV73zaGI8	1436a2a0-bf12-40b8-98e4-d1597c1577be	172.18.0.21	node	2025-11-18 09:41:47.32	\N	\N	\N
1646413022228382891	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjNjNDI4YzJjLWFhYjMtNDg1My1iNjc2LTg5MWEyYmJkNmRiMiJ9.eyJpYXQiOjE3NjM0NTkzMjYsImV4cCI6NDkxNzA1OTMyNiwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.kup1pO7ZL63GmTu_625GMkSu6L-6lwrIjxA7TaI-h8E	825b0858-e0ad-4c5e-9f84-2ba42124d032	172.18.0.21	node	2025-11-18 09:48:46.679	\N	\N	\N
1646629679555151026	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6Ijc0MjM0OWU0LTdiMzAtNDZlYS04ZDM3LTk3YzQ1Y2I2OWYyYyJ9.eyJpYXQiOjE3NjM0ODUxNTQsImV4cCI6NDkxNzA4NTE1NCwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.l-02uWUJx2Ga-n-BTrq6zqdfLlcBdXSYgA9FVc0pzEI	3485e358-81ed-4f59-b3dc-f103be945d48	172.18.0.21	node	2025-11-18 16:59:14.237	\N	\N	\N
1646657406874158265	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6ImE2NGI2N2U3LTBiNGMtNDVkNS1iZjZlLTYyMjYwZmFmYjg3ZiJ9.eyJpYXQiOjE3NjM0ODg0NTksImV4cCI6NDkxNzA4ODQ1OSwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.tYf0LYLK3gf2knrQVm_cdDstZO6HBoveNyKGmvF4KFg	95254e87-3a73-4e9d-9fd7-7d18d541d3e2	172.18.0.21	node	2025-11-18 17:54:19.596	\N	\N	\N
1650897447318193354	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6ImU2ODIzYzkyLTdmN2YtNDQzZS1hMDNhLWZiYTdkNGI1ZTIxYyJ9.eyJpYXQiOjE3NjM5OTM5MTEsImV4cCI6NDkxNzU5MzkxMSwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.TkUoPgRxiv4z5o0DL3qN7GGSDX3r3iPZfXdsyr50ROg	cee2aef1-8d9c-4cca-b808-4f241de54699	172.18.0.4	node	2025-11-24 14:18:31.793	\N	\N	\N
1650905419633132747	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6ImE0OTlmOGUyLTAxOTAtNDQwNS05NjcxLTA2NzRjZmNlOTg4YyJ9.eyJpYXQiOjE3NjM5OTQ4NjIsImV4cCI6NDkxNzU5NDg2Miwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.Rnakc3KnPc6KQNQ-doMnXSI8OAEIHHSbF2EASHmsjBo	8f5c5c22-3ad7-4f33-b59f-b25fdf05c84e	172.18.0.4	node	2025-11-24 14:34:22.183	\N	\N	\N
1652940384457721077	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6ImJhMDY4OTZiLTI2NDUtNGVlZi1hYTdkLWNhMTc1YzAzMTU1NSJ9.eyJpYXQiOjE3NjQyMzc0NDgsImV4cCI6NDkxNzgzNzQ0OCwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.srbn4KAJN-7PtEGTyLXIiSuXT_tdrUSFGLWA2HGUy2Q	64b474cc-4a0f-4fdd-9801-1116b643180e	172.18.0.20	node	2025-11-27 09:57:28.874	\N	\N	\N
1652942050099725558	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjIwMWJjNDIyLTMyNGEtNDY4Ni04NmQ0LTI2MDdmMWIxOWRlMiJ9.eyJpYXQiOjE3NjQyMzc2NDcsImV4cCI6NDkxNzgzNzY0Nywic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.McGJ_0v6oP-zFL6n1zQJwrecp5ehv1CmK1D8grPljxs	d51c7de3-f066-41c8-8dfe-4415c1ddc7ce	172.18.0.20	node	2025-11-27 10:00:47.474	\N	\N	\N
1652943835363280119	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjZkMTIyMDc3LTQyMmMtNGVjOS1hODA0LTE3ODU2NDU0ZTA0YiJ9.eyJpYXQiOjE3NjQyMzc4NjAsImV4cCI6NDkxNzgzNzg2MCwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9._l1s-LVW8rkVXstTMWg2DGAPhp1nLq2oRy9LGvxgAOc	5bb044e6-754d-4314-84cf-1dc2f6e84d08	172.18.0.20	node	2025-11-27 10:04:20.293	\N	\N	\N
1652955732825343224	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjZlZjcyNmMwLTMyZWUtNDZkOS04OGY1LTE5M2E3M2I0ZWNkNiJ9.eyJpYXQiOjE3NjQyMzkyNzgsImV4cCI6NDkxNzgzOTI3OCwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.sycqgGhGCu-NcaDCprcW5ZNmIZrsxUNIxcApayWszJ8	1e1ccdfd-739b-42d4-843e-e0b1f0a9a309	172.18.0.20	node	2025-11-27 10:27:58.556	\N	\N	\N
1652957237238301947	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjQ0NWFkMjgxLTQ0MzktNDExMy1hYjVlLTJhZmQ2OTdlYTg0YSJ9.eyJpYXQiOjE3NjQyMzk0NTcsImV4cCI6NDkxNzgzOTQ1Nywic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.3C3Gs5fFY6obvo9T72Ptf8j8w4SxBwR7s6DXNUAlT1g	fd12ca4e-b3b6-43b4-8f8c-7d240831b221	172.18.0.20	node	2025-11-27 10:30:57.899	\N	\N	\N
1653157509566825736	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjhlYjMyNDI4LTAwZTAtNGM0MC05M2Y4LTNiYjcxMDU1ZTU4NyJ9.eyJpYXQiOjE3NjQyNjMzMzIsImV4cCI6NDkxNzg2MzMzMiwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.vkdM70P0M22OBBOjjrDtnmM_C3OdRZYLRnQAHaT-Q9s	\N	172.18.0.20	node	2025-11-27 17:08:52.215	\N	\N	\N
1653159326908417296	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6ImE5MjA4MWQzLTE4YzQtNDU4YS1iYzY5LWFmMzRmYmZlNmU5MiJ9.eyJpYXQiOjE3NjQyNjM1NDgsImV4cCI6NDkxNzg2MzU0OCwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.z2VAy-YnwnE-LL5BmRe-Wg2er-LQ7Ne_v0HzZoAdYi4	\N	172.18.0.20	node	2025-11-27 17:12:28.877	\N	\N	\N
1653641187644409109	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjQzYWQwNWMyLTc0ZDUtNGE3OC05NzQ0LTRjNDdiMDM2YWEwMCJ9.eyJpYXQiOjE3NjQzMjA5OTEsImV4cCI6NDkxNzkyMDk5MSwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.c2Bcz8k0KJ7dynZYkQyhrX9xNktVwubA1MI9JMHeHPs	\N	172.18.0.11	node	2025-11-28 09:09:51.148	\N	\N	\N
1653690036295566646	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6ImU2ODY1MDJlLWYxMWMtNDQzOS05YWNiLTMxMzdkMDQwMThjYyJ9.eyJpYXQiOjE3NjQzMjY4MTQsImV4cCI6NDkxNzkyNjgxNCwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.DW98eNh0b0m_1L1mLdQFpxbkI1pFF1fBKpg8j8h81eQ	\N	172.18.0.11	node	2025-11-28 10:46:54.254	\N	\N	\N
1654047312478995926	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjQ0NTIyYzY3LWRkMjEtNGRjYy04YmVhLWRjM2IxMzAzNDY1YiJ9.eyJpYXQiOjE3NjQzNjk0MDUsImV4cCI6NDkxNzk2OTQwNSwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.rAw_7E0xbgrhbgkkts4ZE6deF4WVyi0QQHLnZIqDVfc	\N	172.18.0.11	node	2025-11-28 22:36:45.013	\N	\N	\N
1646342512412984449	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjAyODNkNzU4LTEzYTYtNDczYi1iYWYxLTliMTAzNzVlMTVhMCJ9.eyJpYXQiOjE3NjM0NTA5MjEsImV4cCI6NDkxNzA1MDkyMSwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9._ZFoGqc17fWmZX60lhnTDOvi2WtfAu9H1-HIDfyJGlE	1383f64e-1a73-4963-8864-a497b206f049	172.18.0.21	node	2025-11-18 07:28:41.251	\N	\N	\N
1646369523151930501	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6Ijc1Zjc0OTU1LWY2ZTItNDIwOC05YzMzLWI0MjI5MmYzMTBhNCJ9.eyJpYXQiOjE3NjM0NTQxNDEsImV4cCI6NDkxNzA1NDE0MSwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.j7fJg4yBRIrYTrJJfPfVYMSjjLzaMA-h_MMlVyz2jjM	170fea0a-841c-4edb-a9f2-3540493909e5	172.18.0.21	node	2025-11-18 08:22:21.184	\N	\N	\N
1646387329734018184	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6Ijc2OTFkZjk1LTQxNjUtNGQ1ZS1iZDQ0LWI3NDM1N2EwYTIwYyJ9.eyJpYXQiOjE3NjM0NTYyNjMsImV4cCI6NDkxNzA1NjI2Mywic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.QasIseO9k8n0S96Uhfb-ACrBUfbsFj_dKHkiCx6Vo7o	47c8d0e7-f555-4ac6-8ff9-f3d3cdaffea3	172.18.0.21	node	2025-11-18 08:57:43.89	\N	\N	\N
1646414811442971820	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjUzNzhiZGEzLTY0ZTctNDIwMi1hODNmLWVjODUyYjA4OWQwNyJ9.eyJpYXQiOjE3NjM0NTk1MzksImV4cCI6NDkxNzA1OTUzOSwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.vSTJ3baZo8lhvNiWjftjAnoEMChoCfMXcopt5agY09s	e1a7339d-d03d-428e-bb6c-15ff0ecd8e6d	172.18.0.21	node	2025-11-18 09:52:19.971	\N	\N	\N
1646644164089087155	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6Ijc2NDUxODBkLWFkZjItNGRiMi05MjYyLTMzOTNhYmNjY2NkZiJ9.eyJpYXQiOjE3NjM0ODY4ODAsImV4cCI6NDkxNzA4Njg4MCwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.4N1vq85qO7028Svx8Ze6Yrlbx6aMjbWNAbcsn7et6d0	b34048b5-0c01-49da-b178-f143db77c808	172.18.0.21	node	2025-11-18 17:28:00.93	\N	\N	\N
1646662921729606842	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6Ijk2ZDE0OGFhLWMxNjgtNGExYy05NTVkLWMxYWEzYmMxMTMxYyJ9.eyJpYXQiOjE3NjM0ODkxMTcsImV4cCI6NDkxNzA4OTExNywic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.7jKKsdFOmJT0TAw9AVr8BcMXsf899xx4VrqRW42uXDk	122dfef9-447d-4fe9-b861-6bc96229880c	172.18.0.21	node	2025-11-18 18:05:17.02	\N	\N	\N
1652965755097974012	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6ImZlMjEyZDQxLTNlYmMtNDk5Ni05NDYyLTg0ODAyODBkODU2YSJ9.eyJpYXQiOjE3NjQyNDA0NzMsImV4cCI6NDkxNzg0MDQ3Mywic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.I8dcDpKrD-RsQC9zNi6efYv4A_k-QzgPHZiYiM7Dup4	d4d31c02-1355-49bf-a995-4427d7f63f5c	172.18.0.20	node	2025-11-27 10:47:53.279	\N	\N	\N
1653157513014543625	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjcwZjQ4ODg0LWE5YTgtNDhiMS04M2Q4LWQ1ODIwYjVjNDI1MiJ9.eyJpYXQiOjE3NjQyNjMzMzIsImV4cCI6NDkxNzg2MzMzMiwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.Bvu2_affcGx2X4stJMW6iIWEd6tfJaXiQb-tqqGfSOE	\N	172.18.0.20	node	2025-11-27 17:08:52.64	\N	\N	\N
1653641190655919382	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjcwMzNjMjNjLTRiMDMtNDIzMy05NDUzLTc2Y2Y5ZGNkNzZjNSJ9.eyJpYXQiOjE3NjQzMjA5OTEsImV4cCI6NDkxNzkyMDk5MSwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.yBCGh8gF2myxA-RBKy4q5gSrUnCw2jrx5AZUul5eV38	\N	172.18.0.11	node	2025-11-28 09:09:51.53	\N	\N	\N
1653690039986554167	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6Ijc5NWU5MmFhLWFhNmEtNDI2Mi1iNGRiLWFhN2ZhYTc5NTllOSJ9.eyJpYXQiOjE3NjQzMjY4MTQsImV4cCI6NDkxNzkyNjgxNCwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.DmAsZUr-1tlS6SAZv9eOUplqFG5__w4-IwJx_V1T7aE	\N	172.18.0.11	node	2025-11-28 10:46:54.782	\N	\N	\N
1654047313779230167	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjM2M2E2NzZhLWE0ZDYtNDUwNi1hYjhmLTNlMjk2ZDQ1MWUyNyJ9.eyJpYXQiOjE3NjQzNjk0MDUsImV4cCI6NDkxNzk2OTQwNSwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.Nli9eVvwoXQZK_168cAQp2KZijSAGauGR-tz45GYxh4	\N	172.18.0.11	node	2025-11-28 22:36:45.168	\N	\N	\N
1646342763685348482	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjBhMTkyZDY3LTcyNjYtNDM2Ny1iNjdkLWMwZTI0NDA5NmQwZSJ9.eyJpYXQiOjE3NjM0NTA5NTEsImV4cCI6NDkxNzA1MDk1MSwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.YppWKZTlGhclRcGWjbTfZ8FODf502nVCyD55phdzCX4	726472b0-700a-4df8-b0e2-95fac83fb363	172.18.0.21	node	2025-11-18 07:29:11.218	\N	\N	\N
1646369629041329286	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjJjMjg5NjBjLWY1MDEtNGIwNy1iYWYxLTlkMGUxZjY5NjIzMSJ9.eyJpYXQiOjE3NjM0NTQxNTMsImV4cCI6NDkxNzA1NDE1Mywic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.OSjhwGOoQY9eZfrPZjPaX-WV612SLgP5RFTXArpQIGM	96359eef-afb8-493e-bd31-841e4ce844e6	172.18.0.21	node	2025-11-18 08:22:33.815	\N	\N	\N
1646388787858637961	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjRiYmQzMTY1LTY1YjQtNDQyNi05NWUxLTY4N2Q5ZjcwYWIwNSJ9.eyJpYXQiOjE3NjM0NTY0MzcsImV4cCI6NDkxNzA1NjQzNywic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.Kems4fPHXjvvL2TDHVbkdq5M04Nvp77QW5GKpOB5CTU	276a5118-e25b-41d6-9aaa-5c10f21674c6	172.18.0.21	node	2025-11-18 09:00:37.723	\N	\N	\N
1646418376693646509	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjJiYTMxYTU5LTBlYTYtNGQ5Yy04M2JjLWIwMGE0MTBiODIxMyJ9.eyJpYXQiOjE3NjM0NTk5NjQsImV4cCI6NDkxNzA1OTk2NCwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.U-9CKTOxoKyCgcwapq7moJEFTyJ4xQSI_4wGV79xEbU	0354e914-982f-45f2-a864-8e0574fe52ae	172.18.0.21	node	2025-11-18 09:59:24.981	\N	\N	\N
1646644256489604276	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6ImRmOWY4YzA1LTBjNzUtNDM1My05MzUzLWJkZjE5N2Q1Mzc2NyJ9.eyJpYXQiOjE3NjM0ODY4OTEsImV4cCI6NDkxNzA4Njg5MSwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.yEGmWAKXLDfejOV3SGuKpsrHGlV_gtNvVWZW-Yp8RsA	5aa7fd85-2f4f-421a-9fc7-23d4e06b5ae3	172.18.0.21	node	2025-11-18 17:28:11.558	\N	\N	\N
1646854722117698748	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjExYzYyOTgwLWY1MDItNDE4Yy05ZmIzLTdiZjRhNTYzMjUwYiJ9.eyJpYXQiOjE3NjM1MTE5ODEsImV4cCI6NDkxNzExMTk4MSwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.VgoA66RJKsMGLg_26lgLP4qGuj6f2Ft8pZe6a7a3n4E	\N	172.18.0.21	PostmanRuntime/7.49.1	2025-11-19 00:26:21.335	\N	\N	\N
1653052507229783293	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6ImRhOWZkOGIwLTY0OGQtNDYxYy1hOWIzLTJjYzY1OGFlMDkxMyJ9.eyJpYXQiOjE3NjQyNTA4MTQsImV4cCI6NDkxNzg1MDgxNCwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.r2evTX4yFsiNVE6uSJrAHQ191-rjxJNEAtsW76u3l4Y	81fd33ef-3045-4726-b50a-a6964485839c	172.18.0.20	node	2025-11-27 13:40:14.955	\N	\N	\N
1653157678580499722	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6ImRmMTk4MTU4LWY2ZGYtNDNjMS05MjhlLWZhMjM0OTQ5NDc3NCJ9.eyJpYXQiOjE3NjQyNjMzNTIsImV4cCI6NDkxNzg2MzM1Miwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.WZ8tQOLEQvJq39_3dTw63BqLMde8JII3yv_vn8inMNg	\N	172.18.0.20	node	2025-11-27 17:09:12.379	\N	\N	\N
1653157681441015051	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6ImYzZDNjOTY1LWMyYWEtNDYyMy1iYzE3LTQ0YWY0Y2YxMjA3YSJ9.eyJpYXQiOjE3NjQyNjMzNTIsImV4cCI6NDkxNzg2MzM1Miwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.VPAB9LlVUcPUMLYxwaZKc11yW_KuXXc5nw2H2GXV_YE	\N	172.18.0.20	node	2025-11-27 17:09:12.724	\N	\N	\N
1653690114762605880	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6Ijk2NGYyMmZjLTBiZGQtNDllNy04NGYyLTljMTQxMzU2NjdjMyJ9.eyJpYXQiOjE3NjQzMjY4MjMsImV4cCI6NDkxNzkyNjgyMywic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.YCXtHTTenhM9rtwYhrfh2OmiXp98c6VOaxrGjcPA-x8	\N	172.18.0.11	node	2025-11-28 10:47:03.695	\N	\N	\N
1653690117883168057	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6ImIzZmIxZjA0LWNmOTYtNDNlZS1iMmIxLTNlNzJkNjAzOTVkZSJ9.eyJpYXQiOjE3NjQzMjY4MjQsImV4cCI6NDkxNzkyNjgyNCwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.TlCvPzWN2RLMh1xTyzNrwhQi_hbfUWAAJExOUiPpWBs	\N	172.18.0.11	node	2025-11-28 10:47:04.074	\N	\N	\N
1653690487602677050	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6ImFjNjk0OTAxLThjZjMtNDI4ZC1iMmIxLTBjYmQ3MGQ4NjcwZCJ9.eyJpYXQiOjE3NjQzMjY4NjgsImV4cCI6NDkxNzkyNjg2OCwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.InJAAjE2obCfdnBoyy3L_kSvd9zVhvkKs-rJqj1Pai8	\N	172.18.0.11	curl/8.7.1	2025-11-28 10:47:48.148	\N	\N	\N
1653690754217805115	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6ImI5MGFmYTg1LWQwNGYtNDdkMi05YzkxLTZkNGQyODUzYzliMyJ9.eyJpYXQiOjE3NjQzMjY4OTksImV4cCI6NDkxNzkyNjg5OSwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.FgqAxJlJhtzsn2y45lrGkQJKQokTp6P54VE4qWfxlHg	\N	172.18.0.11	curl/8.7.1	2025-11-28 10:48:19.929	\N	\N	\N
1653692625305208124	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjgxMjJhZmNmLTZiZjAtNGUzMS1iNzU1LTU5MTAxOWU2Mjk2OSJ9.eyJpYXQiOjE3NjQzMjcxMjIsImV4cCI6NDkxNzkyNzEyMiwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.E-e-78HTun20j2iyqtRNKshq5RhCX0yOxr_JClFsHnM	\N	172.18.0.11	curl/8.7.1	2025-11-28 10:52:02.976	\N	\N	\N
1653693147655439679	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjRkNGE4MjM5LWRhZDctNDc4Mi1iYjQ1LTZkMTM3MDMyNGE0YyJ9.eyJpYXQiOjE3NjQzMjcxODUsImV4cCI6NDkxNzkyNzE4NSwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.TMD6DpAuNQXjM8GdTZvtlzwfcYMD7q5S195KH6GEOQI	\N	172.18.0.11	node	2025-11-28 10:53:05.239	\N	\N	\N
1653693149106668864	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjY1Mzk5ODI0LTgyODAtNGM5NS05ZDdkLWFjOWNiNWRhYWFiZiJ9.eyJpYXQiOjE3NjQzMjcxODUsImV4cCI6NDkxNzkyNzE4NSwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.TeKx6sYUSdyqIjKiWQn1lOXCQR2PtFemW1pJCXPrxgo	\N	172.18.0.11	node	2025-11-28 10:53:05.415	\N	\N	\N
1653693363209110855	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6ImI1Nzc5NDM4LWRmY2ItNGJlYi05ZWRlLTI3MzliMjExZGNiZSJ9.eyJpYXQiOjE3NjQzMjcyMTAsImV4cCI6NDkxNzkyNzIxMCwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.X0jLCoSH1sJqLQXJGb6K3Ln5RppIj5oVQS27wgnOngg	\N	172.18.0.11	node	2025-11-28 10:53:30.94	\N	\N	\N
1653693364551288136	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjcyZDIzNzEyLTkzYjEtNGZlMC04NDEwLWM5MGQ1OGU0MWYxMiJ9.eyJpYXQiOjE3NjQzMjcyMTEsImV4cCI6NDkxNzkyNzIxMSwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.y_wkksl7AvF3pqNnGDuBJqQCEI27CofqDx5x6ZAR-qk	\N	172.18.0.11	node	2025-11-28 10:53:31.1	\N	\N	\N
1653693443890742607	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6ImIwNGY4M2Q5LWU1ZjktNDc3MS1hODc5LWM1NjA0Njk2MmE0YyJ9.eyJpYXQiOjE3NjQzMjcyMjAsImV4cCI6NDkxNzkyNzIyMCwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.0cZt-0bZ984KGE6pEZ6IyxiTBwPnKEtbRpM6pIqBCpw	\N	172.18.0.11	node	2025-11-28 10:53:40.558	\N	\N	\N
1653693444956095824	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6ImVlNjZmNWQ0LWY1YjktNGFiZi04YjhiLWVlMDlhNmJjMDUzYyJ9.eyJpYXQiOjE3NjQzMjcyMjAsImV4cCI6NDkxNzkyNzIyMCwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.i6x3cpt5wUUGg1vqTm9obwsPKAVjxRHn20GbbKeJRA0	\N	172.18.0.11	node	2025-11-28 10:53:40.686	\N	\N	\N
1653693543799063895	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6ImY1NjE1MTgwLTc0MmQtNDA5OC1iODU2LWIxODdkYzk4NjAzMyJ9.eyJpYXQiOjE3NjQzMjcyMzIsImV4cCI6NDkxNzkyNzIzMiwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.bfb1g0PqdwnMHoB80oPW_xbT77EgZBivSrdMnBZOnNA	\N	172.18.0.11	node	2025-11-28 10:53:52.467	\N	\N	\N
1653693544738587992	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6ImI1ZjVmNjdmLTcxYjQtNDBmMi05NWRlLWVmZWY2MjRkNTdkMyJ9.eyJpYXQiOjE3NjQzMjcyMzIsImV4cCI6NDkxNzkyNzIzMiwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.pbItQ5ih6USkDYYfeVfDnvd-8omuYehIuHTP6UU9knM	\N	172.18.0.11	node	2025-11-28 10:53:52.579	\N	\N	\N
1653693664670516575	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6ImI3NjIwZGJjLTFlYzUtNDdlZi1iNDVkLWMxOTk0M2EyMmM3MSJ9.eyJpYXQiOjE3NjQzMjcyNDYsImV4cCI6NDkxNzkyNzI0Niwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.uankHrJ2ywLa7aBfJZF5wh5dBKCVidD0B7-1lUz-umw	\N	172.18.0.11	node	2025-11-28 10:54:06.875	\N	\N	\N
1653693665761035616	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6ImU1YTkyMWNhLWU3YmEtNDQ3Ny05MzQ2LTcyODhmMmRmYWI1NyJ9.eyJpYXQiOjE3NjQzMjcyNDcsImV4cCI6NDkxNzkyNzI0Nywic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.h8KCi01DZAvmYetYkzQARlXAPTlKGFa0pAVlQ0qQsl0	\N	172.18.0.11	node	2025-11-28 10:54:07.006	\N	\N	\N
1653693880953996647	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6ImE0NTkwYzg0LTVkNjItNDcxYi1iZDNlLWUwNDkzMDZhNjIzNiJ9.eyJpYXQiOjE3NjQzMjcyNzIsImV4cCI6NDkxNzkyNzI3Miwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.m3Ji8q9YlK4PQy6G7beHxLkypVeAlGpi5zzMXyAyY_M	\N	172.18.0.11	curl/8.7.1	2025-11-28 10:54:32.657	\N	\N	\N
1646344008655438979	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjBjNDdhYmNlLWViNTMtNGE2Yi1hYzcxLTMyZmM0MWRjZTY0ZiJ9.eyJpYXQiOjE3NjM0NTEwOTksImV4cCI6NDkxNzA1MTA5OSwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.o5HS9YDSk5JhMMUepfNac7LSF_B2mCYI_X6BOStpClE	f6d4fe7c-80dd-43e8-9e07-c02ff1caee97	172.18.0.21	node	2025-11-18 07:31:39.625	\N	\N	\N
1646447179499308207	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjFlZDcwODdhLWQxMjItNGVjOS05OWYyLTRhNmYyNTRiOTE1ZiJ9.eyJpYXQiOjE3NjM0NjMzOTgsImV4cCI6NDkxNzA2MzM5OCwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.dMWG9O0Aj0bDhk-ssFaK_prz6r9iplMUP78JP2gMxIM	d93e7767-13ce-41e8-a030-3fac7967861d	172.18.0.19	curl/8.7.1	2025-11-18 10:56:38.527	\N	\N	\N
1646645614143866037	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6ImI2MzgyMTFiLWY4YWQtNGNhYi05MWIyLWUzNDMyMTIzNWU1NCJ9.eyJpYXQiOjE3NjM0ODcwNTMsImV4cCI6NDkxNzA4NzA1Mywic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.D8n3RvlijWwSHaBSX5orYZyaLeH4TIPllCmfbmHNtr8	8cb17715-5091-4b86-a3de-d2280140eeb7	172.18.0.21	node	2025-11-18 17:30:53.53	\N	\N	\N
1653123636837483774	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6ImU5YTllNmJjLTM0MTQtNDdmZC1hZWE5LTAyN2I5MjUwNTk4YiJ9.eyJpYXQiOjE3NjQyNTkyOTQsImV4cCI6NDkxNzg1OTI5NCwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.MeCIv3h4Y37mzSHaJC3L4phrmY22nwB2q28Jd2Mvkv8	\N	172.18.0.20	node	2025-11-27 16:01:34.175	\N	\N	\N
1653158923676419340	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjdhYmEwMjE3LWQzMTQtNDdmZC1hNjUyLTJjNDFjMGNhNGI4OCJ9.eyJpYXQiOjE3NjQyNjM1MDAsImV4cCI6NDkxNzg2MzUwMCwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.28Sk1UmlCiMabmvxZ0VMZxmjrW9dwlPxjCpYdqjYblA	\N	172.18.0.20	node	2025-11-27 17:11:40.726	\N	\N	\N
1653158926570489101	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6Ijk4YzAwYmQ0LWVhZDUtNDQ0Ni04NWUwLTFiMWU3MzA5OGM3NSJ9.eyJpYXQiOjE3NjQyNjM1MDEsImV4cCI6NDkxNzg2MzUwMSwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.bMyRloD-b8l06tD49VMDeYwkyWPCfEK1qFv34rHFjT8	\N	172.18.0.20	node	2025-11-27 17:11:41.155	\N	\N	\N
1653158996153992462	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6ImFjMjk3YzBjLWJmODctNGZkYy05NGM4LTY0ZWVkZjY5MGQwNiJ9.eyJpYXQiOjE3NjQyNjM1MDksImV4cCI6NDkxNzg2MzUwOSwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.FPSfjYa4D3EsecMVp-GSnGVufmPk2XaJDWavuF3LCDg	\N	172.18.0.20	node	2025-11-27 17:11:49.448	\N	\N	\N
1653158999031285007	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjdiNTAyNDJkLWIwYTQtNGM2My04ZjU3LTQ5MmRlY2Q2NjlmNCJ9.eyJpYXQiOjE3NjQyNjM1MDksImV4cCI6NDkxNzg2MzUwOSwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.1DdF-8t77-v5_688Z1xIYncEn1Cj76CFA2WkC8cUp3o	\N	172.18.0.20	node	2025-11-27 17:11:49.793	\N	\N	\N
1653694220717786472	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6ImYyYzBkMmE4LTdkMDQtNDE0ZS1hMjRkLTgyOGRmZTk5M2YwOCJ9.eyJpYXQiOjE3NjQzMjczMTMsImV4cCI6NDkxNzkyNzMxMywic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.atpGLOZhJGM0KYhXkRvw8l_S5uXh5N4zHo9ecCxq68s	\N	172.18.0.11	node	2025-11-28 10:55:13.159	\N	\N	\N
1653694222093518185	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6ImVhOTc3N2ZkLWQzNGItNDU4Yi05MWZlLTIxNjI3ZDI1YTllZSJ9.eyJpYXQiOjE3NjQzMjczMTMsImV4cCI6NDkxNzkyNzMxMywic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.-_30v3z5WwNH9coLNsqJ8iiRDS8KUIUpfFfsPc9gNIs	\N	172.18.0.11	node	2025-11-28 10:55:13.325	\N	\N	\N
1653694381586122097	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6Ijk0MmU3MDlhLWVlMjYtNDM1Mi1iOGE1LTU0ZDNjNjg0ZjRiMyJ9.eyJpYXQiOjE3NjQzMjczMzIsImV4cCI6NDkxNzkyNzMzMiwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.jdMw8E4hZxLPIJXLnEhvQBwWIPrCBEEuZbgNfGPB0aM	\N	172.18.0.11	node	2025-11-28 10:55:32.336	\N	\N	\N
1653694382550812018	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6ImZiYTQxYWViLTIzMTUtNGVhZS1iYTJkLTJjMDViMDMzMjIyMiJ9.eyJpYXQiOjE3NjQzMjczMzIsImV4cCI6NDkxNzkyNzMzMiwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.56iN7XGHChxtaNfECnp4KUmUSVVmLxKP8oVgMQ5tamA	\N	172.18.0.11	node	2025-11-28 10:55:32.449	\N	\N	\N
1653694561681147258	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjcyNGVlOTYxLTJhOTMtNDYxNS05NWRiLTM3MjMzMTAxYTBhZCJ9.eyJpYXQiOjE3NjQzMjczNTMsImV4cCI6NDkxNzkyNzM1Mywic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.3bYWb3_swCuHQ7q4xCQtzUE4OsGENLDUXdqr9cm4e-E	\N	172.18.0.11	curl/8.7.1	2025-11-28 10:55:53.807	\N	\N	\N
1653695331780527483	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6ImMxMDhkYjZlLWUwNzMtNDA1Yy04OWNiLWU3MTkyNmQ3OTNiYiJ9.eyJpYXQiOjE3NjQzMjc0NDUsImV4cCI6NDkxNzkyNzQ0NSwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.WkmnmHf87NMXwPyWHTp5Rg7GFupxgxbZ1FkAx1Z6oXM	\N	172.18.0.11	node	2025-11-28 10:57:25.607	\N	\N	\N
1653695332929766780	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjM5Yjc1MzBlLTc1NTMtNDcyZC04NDAzLWRmMjc1MTFiZmUwOCJ9.eyJpYXQiOjE3NjQzMjc0NDUsImV4cCI6NDkxNzkyNzQ0NSwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.DPgasU1fpUauwAEEich7spUOQdbZdpSwotq1TzLysbk	\N	172.18.0.11	node	2025-11-28 10:57:25.744	\N	\N	\N
1653695516027913606	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjEyNTlmNWZkLTVhZjMtNDI5Yi1hYzJmLTQxMjUyMWRlOTc2MSJ9.eyJpYXQiOjE3NjQzMjc0NjcsImV4cCI6NDkxNzkyNzQ2Nywic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.fTJHSSVbDQPjf9KavyvSdU0hLArmzCFn4zzZXLTFnl8	\N	172.18.0.11	node	2025-11-28 10:57:47.57	\N	\N	\N
1653695516959049095	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjE4MjQ1YmRiLWMyMDktNDFjMS1hMGQ2LTMxZjkwMmFhZjdhYSJ9.eyJpYXQiOjE3NjQzMjc0NjcsImV4cCI6NDkxNzkyNzQ2Nywic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.mq71mXiPPj23Za8dSPZJfVHRLiE99RPRZX-ETnT5ET4	\N	172.18.0.11	node	2025-11-28 10:57:47.682	\N	\N	\N
1653695707514668433	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6ImI2MjNkYjQwLWZlMzAtNDExOC04YzhmLWEzOWU3MDFkNDIxMSJ9.eyJpYXQiOjE3NjQzMjc0OTAsImV4cCI6NDkxNzkyNzQ5MCwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.cKEe88YkvVFQhObaBiQa4lAD66v6JFwok04i05_S8cs	\N	172.18.0.11	curl/8.7.1	2025-11-28 10:58:10.397	\N	\N	\N
1653695933872866706	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjNkZWNjMmFiLTAwMWUtNDljMS04Y2FkLTcxN2RmYzg5ZmMyYSJ9.eyJpYXQiOjE3NjQzMjc1MTcsImV4cCI6NDkxNzkyNzUxNywic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.U7ENm636zJUevULKWMGn3UpCzGotqrB1O9JuiBAtXPM	\N	172.18.0.11	curl/8.7.1	2025-11-28 10:58:37.381	\N	\N	\N
1653696106644637075	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6Ijc0MDE0ZWIzLTMzOGYtNGJjNS05MjIzLTcwODFlNDBlMTlkNiJ9.eyJpYXQiOjE3NjQzMjc1MzcsImV4cCI6NDkxNzkyNzUzNywic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.hG2YN0SZq_xioIY7kzxtk6HjHLJ8slGuBuO08JqMdf8	\N	172.18.0.11	node	2025-11-28 10:58:57.969	\N	\N	\N
1653696107911316884	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjU0NjI5NDUzLTdlNjMtNDM5YS05OGEzLWY5YWViNTk2OTQyNSJ9.eyJpYXQiOjE3NjQzMjc1MzgsImV4cCI6NDkxNzkyNzUzOCwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.uBMcvOkQFYmdaNUeFIukKGAndKOSGqtPeJWNk9BcFPA	\N	172.18.0.11	node	2025-11-28 10:58:58.127	\N	\N	\N
1653696272898459038	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjI3NGE0NmE1LTVlOGEtNDE0OC04NjU0LWIyYzM5NTk0ZjNjZCJ9.eyJpYXQiOjE3NjQzMjc1NTcsImV4cCI6NDkxNzkyNzU1Nywic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.USu_ABx_sL9vUlSDJWTar77LFYHd8-GPViHR_GndX78	e4a791ff-7451-4f7b-81ea-3a1011c48cf5	172.18.0.11	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	2025-11-28 10:59:17.567	\N	\N	\N
1653696653758039455	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjI5NzFhOGJjLTg2NjQtNGUxZC05YTNiLWExYzUxM2ZkZTdkMyJ9.eyJpYXQiOjE3NjQzMjc2MDMsImV4cCI6NDkxNzkyNzYwMywic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.-BBh-qs38lb8B9gvE26k5mdjivmjos-stKXUkoRGNYI	\N	172.18.0.11	node	2025-11-28 11:00:03.192	\N	\N	\N
1653696655100216736	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjBhMGE4NzYwLWY5MWUtNDI3MC04MTUwLTkyNzRiYjU3OWUwNSJ9.eyJpYXQiOjE3NjQzMjc2MDMsImV4cCI6NDkxNzkyNzYwMywic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.CyoR2Dd4peJzShsCNThJ4574KcsCFU40tqa0UnrWebA	\N	172.18.0.11	node	2025-11-28 11:00:03.355	\N	\N	\N
1646647253160428726	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjRmYjA4OGUwLWFhNTYtNDI5NS04NDNjLWI5OTdkYzFhOGNmZiJ9.eyJpYXQiOjE3NjM0ODcyNDksImV4cCI6NDkxNzA4NzI0OSwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.ipgq2HHowtWZJl-QAjx9zH7hCtSbqvuFtaANWRTpRPo	ffba6227-a518-4dba-968c-47bf1f0dc746	172.18.0.21	node	2025-11-18 17:34:09.175	\N	\N	\N
1646647313709401271	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6ImU2NWU4ZDIzLWZlZTEtNDk5MC1hZWE3LWY2ODAxNjNhNTIxYiJ9.eyJpYXQiOjE3NjM0ODcyNTYsImV4cCI6NDkxNzA4NzI1Niwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.FUMzvVeaF9wbiFOM39j4UKA-WjpLvSfHd0Ykrbnw-Y4	73a00d80-3f70-4b46-b9ce-8ef6e7995736	172.18.0.21	node	2025-11-18 17:34:16.409	\N	\N	\N
1653123640058709247	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6ImUyMjc0YjhkLTY1MWQtNDFhNC1iYzdlLWFmZTMyMzdjYTczYSJ9.eyJpYXQiOjE3NjQyNTkyOTQsImV4cCI6NDkxNzg1OTI5NCwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.OT-BFvcvOVRMW94LCrLSxA4FGFmYYYR6DbOtCv2Wl8M	\N	172.18.0.20	node	2025-11-27 16:01:34.666	\N	\N	\N
1653159330003813649	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6ImM0OTJmZTg5LTgxZDQtNDk0Zi1hZGJjLTdjN2NkMWI5YjYzNyJ9.eyJpYXQiOjE3NjQyNjM1NDksImV4cCI6NDkxNzg2MzU0OSwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.pfidsaFLn0-RYI6hmp1bEzQsILU4qA4z1EmUh5dLRAA	\N	172.18.0.20	node	2025-11-27 17:12:29.233	\N	\N	\N
1653159410979046674	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjY0OWI4YThjLTQzMGQtNDdlNC1hODBiLWU2MGM2YTA0OGU2MyJ9.eyJpYXQiOjE3NjQyNjM1NTgsImV4cCI6NDkxNzg2MzU1OCwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.Liz9zComhpI4shN61sWdLEKxevVaUVRFoCjTMgYwopo	\N	172.18.0.20	node	2025-11-27 17:12:38.897	\N	\N	\N
1653159413982168339	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjUyZjJmMWI0LWJjYzItNDFjZS05ZDc0LWU2Y2YyZWI4ZWI4YyJ9.eyJpYXQiOjE3NjQyNjM1NTksImV4cCI6NDkxNzg2MzU1OSwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.UxRcR322irChteeS3wa0XZqFi7JCWWxwgOxr4ZAU_Ps	\N	172.18.0.20	node	2025-11-27 17:12:39.257	\N	\N	\N
1654034704770270634	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjY4ZGQyMTZmLTdkMjMtNDhmMC05NDg5LWNiODhmODc0MDMzMSJ9.eyJpYXQiOjE3NjQzNjc5MDEsImV4cCI6NDkxNzk2NzkwMSwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.sVE7MX3w8mlNF53DgnDFqgb1x_52GV5hxQLEkMipoAo	\N	172.18.0.11	node	2025-11-28 22:11:41.947	\N	\N	\N
1654034706162779563	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjMzNjk5M2M4LTg5ODgtNDg5Yy05YzNlLTIzNTE3OTZhN2QxNCJ9.eyJpYXQiOjE3NjQzNjc5MDIsImV4cCI6NDkxNzk2NzkwMiwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.bqGllpiU9j3L87G6gtid0_hl83Ao1a9HM-oO7dsQgK8	\N	172.18.0.11	node	2025-11-28 22:11:42.215	\N	\N	\N
1646649774968931512	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6ImU1ZGUyYThhLWIzMWUtNDhiMS04NTdlLTkxNTZkZmM1NTRmZSJ9.eyJpYXQiOjE3NjM0ODc1NDksImV4cCI6NDkxNzA4NzU0OSwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.zCUenivRv7UU29W5u76AXajUIZAIJlVZ1bQx_H_dXPM	d633007a-8bf4-4d8c-b102-7bafe1c3c01a	172.18.0.21	node	2025-11-18 17:39:09.804	\N	\N	\N
1653124189764191488	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjZjYTBiYmFhLTRiMTItNDM4Yi04MmMzLTQ5NjI3OWRlYjg4NiJ9.eyJpYXQiOjE3NjQyNTkzNjAsImV4cCI6NDkxNzg1OTM2MCwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.DvyZXs7-XoEnbjy8tOhEVRHNnCPelwfWNhwqyWgi0gA	\N	172.18.0.20	node	2025-11-27 16:02:40.191	\N	\N	\N
1653124192842810625	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6ImJiMDk3OTM4LTRlZTMtNDhkYy1hN2YzLWFkNDI5ZDFlYmQyNSJ9.eyJpYXQiOjE3NjQyNTkzNjAsImV4cCI6NDkxNzg1OTM2MCwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.yqOCuhoR26zafT5q9LML_7-5tjJRpL0xfJe4C4Pqdfc	\N	172.18.0.20	node	2025-11-27 16:02:40.569	\N	\N	\N
1653137541240456450	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6ImM5NGIzZjE4LTlmNTAtNDQ1ZC1iMTk1LTIyOWU4ZmI3OThiOCJ9.eyJpYXQiOjE3NjQyNjA5NTEsImV4cCI6NDkxNzg2MDk1MSwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.hG5yTn4HyazUVY8w8te32px1HxslsaSYWvBBBoF1q-4	\N	172.18.0.20	node	2025-11-27 16:29:11.82	\N	\N	\N
1653137544260355331	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjdiZGVlYjUzLTUwNzQtNDUxNS05ZDQ4LWExZmRkYjdmYzYyZCJ9.eyJpYXQiOjE3NjQyNjA5NTIsImV4cCI6NDkxNzg2MDk1Miwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.f4vcPy3ZfA2tREr6z7fNX4YzhYtAJTpgDsShZAVjgGI	\N	172.18.0.20	node	2025-11-27 16:29:12.183	\N	\N	\N
1653137596554937604	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjgwZDAyNmU2LTc1MGEtNGYwNS05NjE2LWM5OGY1NWY3MDBlNyJ9.eyJpYXQiOjE3NjQyNjA5NTgsImV4cCI6NDkxNzg2MDk1OCwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.P3t0gto6VYUIC1pwc8S1IEUOWqaO0ibNIXb4IzMFvNc	\N	172.18.0.20	node	2025-11-27 16:29:18.413	\N	\N	\N
1653137599591613701	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjE1NzJjZTdjLWYyNjgtNGU2NS05NTkyLTNhYWM5ODNmNDQzZCJ9.eyJpYXQiOjE3NjQyNjA5NTgsImV4cCI6NDkxNzg2MDk1OCwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.wUVUYfRt7HpY5DCF9PPCJGp6WiSLVyXiADbGVXEHQaM	\N	172.18.0.20	node	2025-11-27 16:29:18.779	\N	\N	\N
1653137812779697414	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6ImQ4MjM5Y2M3LTU1ZGUtNDAyZC1hNjg2LWM5ODAzODdjMTkzZSJ9.eyJpYXQiOjE3NjQyNjA5ODQsImV4cCI6NDkxNzg2MDk4NCwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.Xjvuix8GktOheX7HIwwjoO-pthNQoDUY1PazNBZ6Ds4	\N	172.18.0.20	node	2025-11-27 16:29:44.194	\N	\N	\N
1653137815707321607	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjZiMWRlYjNhLThlMDQtNDA3ZS04NTMxLWIzMjlkOTc1NDc3MCJ9.eyJpYXQiOjE3NjQyNjA5ODQsImV4cCI6NDkxNzg2MDk4NCwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.dI5OKCmIwLEdZ0BjywSjhVw56u4NoU_soZgf3FGd9QA	\N	172.18.0.20	node	2025-11-27 16:29:44.542	\N	\N	\N
1654035092097467829	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjYyN2E1NjQ5LWNkZTItNDA4OS1hOTZjLTJmMTUwMDg5NDgwOSJ9.eyJpYXQiOjE3NjQzNjc5NDgsImV4cCI6NDkxNzk2Nzk0OCwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.dsCXYlVgAgu9ioXO5Js5a58vNVJqch3b9V4E1NQdTbQ	\N	172.18.0.11	node	2025-11-28 22:12:28.224	\N	\N	\N
1654035093322204598	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjRmYzdjMmM5LTU2YzQtNDVkNy04YjUwLWI0OGQ4OWUwN2QxZSJ9.eyJpYXQiOjE3NjQzNjc5NDgsImV4cCI6NDkxNzk2Nzk0OCwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.2e2XXuqAXCjnqgSNHMXeQ_Zr4BGDrJ0m0h21wI-ThYI	\N	172.18.0.11	node	2025-11-28 22:12:28.372	\N	\N	\N
1654036091977598400	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6ImNkZjdjODczLWI5MDYtNDVkYy1hZGQ5LWRmZDkwMmQ2MzliZiJ9.eyJpYXQiOjE3NjQzNjgwNjcsImV4cCI6NDkxNzk2ODA2Nywic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.5wpuf4q6q_A5T-TSMHyVrXggTxmy3jjwxCJXuBScmgA	\N	172.18.0.11	node	2025-11-28 22:14:27.42	\N	\N	\N
1654036093286221249	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6ImI5YzBiMGI3LTIyYjMtNGQ2OS1hNWEzLWZmMTg1NTcwYTNmOCJ9.eyJpYXQiOjE3NjQzNjgwNjcsImV4cCI6NDkxNzk2ODA2Nywic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.IWFA3U15em0wkgjo7LRGsVOovrAV7A_iQ1mO57o5gpA	\N	172.18.0.11	node	2025-11-28 22:14:27.582	\N	\N	\N
1654047133549987275	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjZjZTEwM2U0LTBmNmEtNGRhZC04ZjZiLTc0MjI1ODUyM2VjMiJ9.eyJpYXQiOjE3NjQzNjkzODMsImV4cCI6NDkxNzk2OTM4Mywic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.BXOklpT_vQOeLqMnx81wWUxFRhNdeNv7kUxhDwWVmO8	\N	172.18.0.11	node	2025-11-28 22:36:23.68	\N	\N	\N
1654047134699226572	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6ImRjOTM2ZjE0LTJiNjgtNGQ5Yi1hNTU4LWM3OGJiMzQ1Mjk1MyJ9.eyJpYXQiOjE3NjQzNjkzODMsImV4cCI6NDkxNzk2OTM4Mywic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.bl43O7eA8CqY9pp9ZCcoUa0gGcChkWZNV2QMHIZ9EiE	\N	172.18.0.11	node	2025-11-28 22:36:23.819	\N	\N	\N
1663802213228611137	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjlmZGFhMWRkLWUyY2EtNDc0ZC04NTcxLTVkYjg3ZmJhNzM5NCJ9.eyJpYXQiOjE3NjU1MzIyNzksImV4cCI6NDkxOTEzMjI3OSwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.vK0-wgN6UGY6hHZe55XQpfGsGIs7wZs-moZesa4BLgg	6d2ebdc3-91ef-4ba6-ad43-5b015b454647	192.168.0.69	node	2025-12-12 09:37:59.751	\N	\N	\N
1663806534410307138	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6ImFjZWFmYTY3LTFhOTAtNDY3Yi04MDA2LTdlOGM4YzhhYjAxYSJ9.eyJpYXQiOjE3NjU1MzI3OTQsImV4cCI6NDkxOTEzMjc5NCwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.d7CDOxGC4RPiLUmFtLT8c7wu9cr69_HpSlScGSzBeBo	cfe1623b-34db-4e47-aed9-777fc450930f	192.168.0.69	node	2025-12-12 09:46:34.929	\N	\N	\N
1663807825568073283	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjdlMTk5MDkzLTYzYTItNDU2Yi1iNWFlLWI3MmM1NmU2ZDg0NSJ9.eyJpYXQiOjE3NjU1MzI5NDgsImV4cCI6NDkxOTEzMjk0OCwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.tMrbNYXSFfTCUPB-ScyG9jaKoroWFUSlmZRUKJ1N-8s	bb85aaa0-9d10-4cea-951d-a0e0140d0700	192.168.0.69	node	2025-12-12 09:49:08.844	\N	\N	\N
1663835863693395526	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjlkMWNmYzM1LWE4OWYtNGJjZC05ZjkyLThkOGNhY2VkOGE3NSJ9.eyJpYXQiOjE3NjU1MzYyOTEsImV4cCI6NDkxOTEzNjI5MSwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.HYgfppf0zNGryStk0k7rd19YRGzF5p0ImJ7-bwufrTs	dbe3aeae-3612-4511-a334-3a8f0ab38266	192.168.0.69	node	2025-12-12 10:44:51.247	\N	\N	\N
1663849040485287496	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjNjOTRlNzM5LWMxMGQtNDAwNi05Mjk3LTE3YWZiOGExYWNiNyJ9.eyJpYXQiOjE3NjU1Mzc4NjIsImV4cCI6NDkxOTEzNzg2Miwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.-g5XqzEDVmCfbjCeWqlwN3-3S71g8iFkE6hgiCYKFcs	c47043bf-424e-4683-8b28-3ccca1ba448f	192.168.0.69	node	2025-12-12 11:11:02.041	\N	\N	\N
1663855527144195659	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6ImY4YTJjOThkLWVjMTktNDcxMS1hZGJlLTUxNzA5ODAzZDgwMiJ9.eyJpYXQiOjE3NjU1Mzg2MzUsImV4cCI6NDkxOTEzODYzNSwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.BUlXitw3F1M2lPHnkly8WOG1rjcZaQuSvDoH7VvpP98	321f7666-1de1-443b-8e80-f4e451a0d6ff	192.168.0.69	node	2025-12-12 11:23:55.312	\N	\N	\N
1663865234147771982	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjdmNWM1YWQ2LWI0MjctNGU4Zi1hMTkyLWRlMGVkNmVlOTk2YyJ9.eyJpYXQiOjE3NjU1Mzk3OTIsImV4cCI6NDkxOTEzOTc5Miwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.h-8kO5WigcMEzXOZeDkkmHxueFmM9fLrlObhkckz-ng	8b65e016-a430-4503-b86b-0cdb7f973198	192.168.0.69	node	2025-12-12 11:43:12.477	\N	\N	\N
1663866878407214671	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6ImEwNDM4YWYzLWNiMTctNDFlMC1hYjVjLTM4NWI4Zjg2NzdkYSJ9.eyJpYXQiOjE3NjU1Mzk5ODgsImV4cCI6NDkxOTEzOTk4OCwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.Qrwb2y-JRT3X79pC8uilgvbaTnHGQxarEDoscof7-4U	28b0f5f0-da44-4db9-a726-cb1878832786	192.168.0.69	node	2025-12-12 11:46:28.494	\N	\N	\N
1663867993454544464	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjlhZTI3ZmFiLTRlMmItNGM5MC04YzVhLTgzNmY1Y2FiY2YzMyJ9.eyJpYXQiOjE3NjU1NDAxMjEsImV4cCI6NDkxOTE0MDEyMSwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.JHtHd2fr_tcOoh26W39pnuzY4nXAV2Tr7kD6hxVnqQU	3d9e9a0c-d2d4-4a30-955b-84e07481fa7c	192.168.0.69	node	2025-12-12 11:48:41.417	\N	\N	\N
1663868501518976593	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6ImY1NzQyMGQ4LWFhYTItNDlkMy04Y2Q4LWZiZGI3ODE2NjE4ZiJ9.eyJpYXQiOjE3NjU1NDAxODEsImV4cCI6NDkxOTE0MDE4MSwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.0AYTgv6SFi0p7527B9Dmp_nuUu4dw_IV2cpFw1Fd4iU	5a63c982-1f8c-4513-b053-2db619d3527d	192.168.0.69	node	2025-12-12 11:49:41.984	\N	\N	\N
1663869103904917074	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6ImQyYzU3OTMxLWY3YTMtNGVmZC05ZGFhLWI5Mjc1NTExZDRjYSJ9.eyJpYXQiOjE3NjU1NDAyNTMsImV4cCI6NDkxOTE0MDI1Mywic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.zXrSdl5esp-8jfsJxrVg4jzfmCJgGrX6Acr9paonVfc	c5f3c1a3-74ed-40a1-8d41-c52b29ab42d2	192.168.0.69	node	2025-12-12 11:50:53.794	\N	\N	\N
1663869147668285011	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjkwMDcyMWY0LWI3M2MtNDlhMy04YWUzLWIxOGM2MjA4YTFlMCJ9.eyJpYXQiOjE3NjU1NDAyNTksImV4cCI6NDkxOTE0MDI1OSwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.pUT4aZP-OMw6ewNqWuJaX1Yyry1X2In7J919lYxGNVI	558f5e5b-d080-47a8-b437-3c2e1b6c3956	192.168.0.69	node	2025-12-12 11:50:59.011	\N	\N	\N
1663869429458404948	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjE3OTI2ZmY1LTMwZmQtNGNjOC1hYzE3LWQ3ZTU3NGYxYTVlYSJ9.eyJpYXQiOjE3NjU1NDAyOTIsImV4cCI6NDkxOTE0MDI5Miwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.WziIbDEkzxXKPshKA-R35iN6zQDMNy2VZCYqzGH1XDY	5c39d43d-d7ce-40d2-996b-9873714c3003	192.168.0.69	node	2025-12-12 11:51:32.603	\N	\N	\N
1663870454219146837	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6ImJkOWI2ZGMzLTMyNjktNDk1Yy05NTY0LTgyNjgxNDczODQ2NCJ9.eyJpYXQiOjE3NjU1NDA0MTQsImV4cCI6NDkxOTE0MDQxNCwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.Za_1BPd4HzFopNSxe8B2fXGMU03a_v-K5gGboeKoqjM	0950c072-d193-477a-ac94-b2eb443545c6	192.168.0.69	node	2025-12-12 11:53:34.764	\N	\N	\N
1663871378182374998	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6Ijc4ZDY2NDQxLThlNDEtNDUyYi1hMzJiLTcwMDg5ZDI3MzlmZiJ9.eyJpYXQiOjE3NjU1NDA1MjQsImV4cCI6NDkxOTE0MDUyNCwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.ZUqo3az5nWRFPfW3tN6kFgnZ3l6fRjaD1alZBaFTI1Y	c08b20f4-d3fc-43e5-b6c5-52bbd896cf98	192.168.0.69	node	2025-12-12 11:55:24.908	\N	\N	\N
1663875980734760536	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6Ijc0MzcxZTI3LTI1ZTUtNGQ4Ny04OWZiLWQ3YjA1MTg1N2VmMyJ9.eyJpYXQiOjE3NjU1NDEwNzMsImV4cCI6NDkxOTE0MTA3Mywic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.BO5ixBAg_CmrQuPM1xRtMfWJXHM8L72iqDrBiagqcYk	d5cea6aa-57a7-4646-94df-04bc86a8a44d	192.168.0.69	node	2025-12-12 12:04:33.569	\N	\N	\N
1663878328697751129	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6Ijc4MTgyYjYyLWNlNGEtNDVhMy05YTMxLTJkZGY3ZjY2NDI3OCJ9.eyJpYXQiOjE3NjU1NDEzNTMsImV4cCI6NDkxOTE0MTM1Mywic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.cWSgGqL3kpu9NgQKQXsZFNf7PJAUjAYqwNZk86m71SY	f4f1974b-212b-4b86-abe5-03f481824946	192.168.0.69	node	2025-12-12 12:09:13.473	\N	\N	\N
1663881803057858138	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjE3OGU1N2NiLWExOGYtNDUyNi1hY2Y1LTE3MzczODg5MmQxYyJ9.eyJpYXQiOjE3NjU1NDE3NjcsImV4cCI6NDkxOTE0MTc2Nywic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.x0gvm69TotOjuHYz5zG6yxP7dhBmZJcloWwOIbG5esg	5cd002d4-dbcf-4a0b-a3b4-1501836be5a2	192.168.0.69	node	2025-12-12 12:16:07.648	\N	\N	\N
1663822093508150852	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6ImE1N2FmYjJhLTZkMGYtNGRjMy04MWE1LWQxOWEyY2M5OWE2YSJ9.eyJpYXQiOjE3NjU1MzQ2NDksImV4cCI6NDkxOTEzNDY0OSwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.mjUhcVPzM90HpMGoJvMfJLxrVxV2Z3iZUibrxW67NkQ	740facf5-d635-49fe-995d-8a6a07b1d8e6	192.168.0.69	node	2025-12-12 10:17:29.701	\N	\N	\N
1663825418483926597	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjYwN2I4NmM0LTBiMjQtNDU1Mi1hNDEyLTM5ZTNjZDIxMWEzZSJ9.eyJpYXQiOjE3NjU1MzUwNDYsImV4cCI6NDkxOTEzNTA0Niwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.UuAzlxf0NndYOmNyUVIuiPAHZHifXjY2p36ZJsiJsr8	72c41789-ed78-4e5a-9749-6229cb98edd4	192.168.0.69	node	2025-12-12 10:24:06.085	\N	\N	\N
1663842005580514887	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6ImIzZWQ1YjY0LTQ0ZTItNGE4Yi1iN2IxLWQwNWQ2YzRmYmI0MiJ9.eyJpYXQiOjE3NjU1MzcwMjMsImV4cCI6NDkxOTEzNzAyMywic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.eGrAcOdIrfPxb6iHNKqdOLkluLUKSWeQIL1Nxk2PBsA	cb73020e-9cf2-4d6e-a7d3-1e029e901d18	192.168.0.69	node	2025-12-12 10:57:03.417	\N	\N	\N
1663853418516579913	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6ImQ1M2RjY2U2LTYxNTUtNGFkNy1iZWMzLTNiNjRjODc5YzlmYyJ9.eyJpYXQiOjE3NjU1MzgzODMsImV4cCI6NDkxOTEzODM4Mywic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.ghexaXpmhYwIOOaEGNqreFGSwW9VL877Jwa57GQGYfY	d0e35d26-5066-494e-80bb-32f33cb22670	192.168.0.69	node	2025-12-12 11:19:43.945	\N	\N	\N
1663853895400556106	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjVhYTAwYTUyLTI3NzUtNGZmYS1iNDE2LWQ3ZGQ1OWVlZmFlMCJ9.eyJpYXQiOjE3NjU1Mzg0NDAsImV4cCI6NDkxOTEzODQ0MCwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.kYVFz2GAuWUSE-5VyFXSW2MQfFXQhVyGDVgV5uOS104	f140981d-3ddf-4d71-a063-fa8990dac209	192.168.0.69	node	2025-12-12 11:20:40.798	\N	\N	\N
1663856293980407372	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6ImJiNGQxNmQwLTU0ZGQtNDY4Ny1hY2Q0LWQ1MzMwODI4NWFmMSJ9.eyJpYXQiOjE3NjU1Mzg3MjYsImV4cCI6NDkxOTEzODcyNiwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.89vWghyL1UsQ4zZ-sSszFKthnBs_EdWjmdEgmBIMugw	9f53539a-481c-49b9-9c13-e2d0a2237fdc	192.168.0.69	node	2025-12-12 11:25:26.727	\N	\N	\N
1663858968176363085	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjY0M2E1YTBlLWJkZjAtNDUxZC1hNjBiLWI0MzU1NjI4Yzg4NyJ9.eyJpYXQiOjE3NjU1MzkwNDUsImV4cCI6NDkxOTEzOTA0NSwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.mBxcWc_Tz60ehJnNQN0L033O8k85DiV0edNJaOZjckY	ea14b3e6-b8b0-4af9-8797-cdf273000e5c	192.168.0.69	node	2025-12-12 11:30:45.521	\N	\N	\N
1676246541012043537	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjVkNTNlYzFjLTM2NGYtNDExMi04MmUxLTFmNjFlM2Q1YTUyNyJ9.eyJpYXQiOjE3NjcwMTU3NTksImV4cCI6NDkyMDYxNTc1OSwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.3eQrYVYcDAMwrwWp2TI2cHEgnh94Eds7Z1UHCqoBgfc	5ff154d4-caac-4fdf-a6fb-2c1c6755f926	192.168.1.117	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-29 13:42:39.257	\N	\N	\N
1684240853121369879	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjQxYzZjYWZhLWI0NzEtNGMwMy04ZjI5LWVlOTEwYWNhYjQ5ZiJ9.eyJpYXQiOjE3Njc5Njg3NTUsImV4cCI6NDkyMTU2ODc1NSwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.AB8il0Vg3rNHD0KH5aBTME7DN0I5oJl1-Av7Z3rHdss	80458970-3780-4500-aeac-1d19e2a7de45	192.168.1.111	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36 OPR/125.0.0.0	2026-01-09 14:25:55.525	\N	\N	\N
1685132428823234328	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6ImRhNWJjZjQxLTQ2NTUtNDkzNS1iNGY0LWI0Y2ZlMDkwM2YxMyJ9.eyJpYXQiOjE3NjgwNzUwMzksImV4cCI6NDkyMTY3NTAzOSwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.8Ys9VptoAif_pTJHmYITaVk3svHjFhUcZMJWxIqNoVQ	\N	10.42.3.173	curl/8.17.0	2026-01-10 19:57:19.632	\N	\N	\N
1685134190162478873	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6ImI2OWM3ZjViLWQyM2QtNGNiZS1hMTA2LWJmZThiYmMyMTcyYSJ9.eyJpYXQiOjE3NjgwNzUyNDksImV4cCI6NDkyMTY3NTI0OSwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.zblVX6kFS7-3lbqwLc4urLaPGkCXmcqR2Lqih7BfKzU	\N	10.42.3.173	curl/8.17.0	2026-01-10 20:00:49.602	\N	\N	\N
1686259954945623834	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjI0MTA0Yjc2LWI3MmUtNGQ4Zi1hN2FkLWVmODY2N2FlMjMwNiJ9.eyJpYXQiOjE3NjgyMDk0NTEsImV4cCI6NDkyMTgwOTQ1MSwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.owIYAC4nVqgbYputVDeEhsbJfeUMgCzWnH2jdHSI1is	cd00e800-d3a6-4d6e-aac3-a1e27a439ad0	192.168.1.119	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2026-01-12 09:17:31.219	\N	\N	\N
1686453446602917659	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6ImI0ODY2NzliLThjMmMtNDkxNS04ZTQxLTYwOGRiMDYyZjdmZSJ9.eyJpYXQiOjE3NjgyMzI1MTcsImV4cCI6NDkyMTgzMjUxNywic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.P9YuwWCPbJkI1QBCLPI6oSUI_aIt1qJFi0vgDZUqpJI	434d5493-73e2-48e0-b211-de30497049a5	192.168.1.119	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2026-01-12 15:41:57.217	\N	\N	\N
1686464474334103324	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6Ijk4NjFhMzQ1LWQwZDctNDkzMi1hNzdiLTgzOTA3YTMyMGFjOSJ9.eyJpYXQiOjE3NjgyMzM4MzEsImV4cCI6NDkyMTgzMzgzMSwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.ZEYkz9rLiuflVYs9LcYd9OvMRW1mQLJY3_KsiT9DiqI	f576f77e-20d8-4d34-8e3c-d6573b0c8e35	192.168.1.119	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2026-01-12 16:03:51.834	\N	\N	\N
1686497918850172702	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjNhMjQ0MjY5LTZkZjEtNDFkMS1hNGE0LTU0NWI3NjQwNThkYSJ9.eyJpYXQiOjE3NjgyMzc4MTgsImV4cCI6NDkyMTgzNzgxOCwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.fVeEXwJCB5XEr9yRyPDluvJm4o6URr7a3p5MqSG7NzU	\N	192.168.1.111	curl/8.7.1	2026-01-12 17:10:18.729	\N	\N	\N
1686497976630904607	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6ImNkNTkwYTEwLTk0MzQtNGRlZC1hYTAxLWQ3OTAwOGQyZTJmYyJ9.eyJpYXQiOjE3NjgyMzc4MjUsImV4cCI6NDkyMTgzNzgyNSwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.Lh-bL4WbWwcyAwmgRB_GWADyQ8d3WvdXkZFWkCUa5tA	\N	192.168.1.111	curl/8.7.1	2026-01-12 17:10:25.622	\N	\N	\N
1686500562125719333	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6ImIxMjVjYmEzLWNlZDAtNDZhOS1iNjk2LTg1YzA3NzUzMzBiZCJ9.eyJpYXQiOjE3NjgyMzgxMzMsImV4cCI6NDkyMTgzODEzMywic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.C5BaM8sNQM1KW_5i70tE0veUJYQZXXsQaSvdhQnJI1c	\N	::1	\N	2026-01-12 17:15:33.837	\N	\N	\N
1686524947398133548	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjA4YTQzZjhjLTU1ZjItNDdjMi05ZjZiLWRmYjYyNWM1ODRkNSJ9.eyJpYXQiOjE3NjgyNDEwNDAsImV4cCI6NDkyMTg0MTA0MCwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.Kb4jqsil5ig9hOeE07KLhwomaDIG_pHLBHo9V3kwYwU	\N	10.42.2.151	axios/1.12.0	2026-01-12 18:04:00.782	\N	\N	\N
1686565068189206319	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6ImNkMmQ1MzQ3LTQ0NGYtNDFiZi1hMDUwLTJkNmYyMDk4ZTIwNiJ9.eyJpYXQiOjE3NjgyNDU4MjMsImV4cCI6NDkyMTg0NTgyMywic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.8yUg49WWMDhs3Vrqe1rKDWOJAkpYl0EmyB9Ae9tvysI	56c79423-9a23-4de1-8841-6fe3e9037b24	192.168.1.119	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2026-01-12 19:23:43.553	\N	\N	\N
1686966614924199728	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjBjZTFiMWNkLTA3MDAtNDhmZC1iNTZhLTNiOWRjY2FlMjMxZSJ9.eyJpYXQiOjE3NjgyOTM2OTEsImV4cCI6NDkyMTg5MzY5MSwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.Lljy1uv6QcxuJQE_ei99Ts3ZQtxtqkG5wdhcyYKjskc	\N	10.42.2.127	axios/1.12.0	2026-01-13 08:41:31.654	\N	\N	\N
1686987485814458165	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjkzNzRlODQ0LTk0ZjItNDYwNC1hZjllLTQwZDdiZjUzZGE0YSJ9.eyJpYXQiOjE3NjgyOTYxNzksImV4cCI6NDkyMTg5NjE3OSwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.fPQv2fIy8VwgOQVo5WwE-6IMjpXIBpjJzJKE2oh_IME	\N	10.42.2.136	axios/1.12.0	2026-01-13 09:22:59.662	\N	\N	\N
1686989657566349114	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjIyZjZiMGM0LTViNWItNDNiMC1iNjgzLWM4ZjNiMGEwZjFiNiJ9.eyJpYXQiOjE3NjgyOTY0MzgsImV4cCI6NDkyMTg5NjQzOCwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.QWzcCVWW_-34a1-dKC91Nm7Iw-y1QGkqszgQ3IaXpj0	\N	10.42.3.168	curl/8.17.0	2026-01-13 09:27:18.555	\N	\N	\N
1686989795919660859	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjBiZjU3NGIzLWQ5NDEtNGRlMC1hNGFjLTE2N2IzYTg0MjVhMiJ9.eyJpYXQiOjE3NjgyOTY0NTUsImV4cCI6NDkyMTg5NjQ1NSwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.BG1F7ErqsDs4S8eCJcViGpJpn0EHSZjONkdInJwX9dY	\N	10.42.3.168	curl/8.17.0	2026-01-13 09:27:35.05	\N	\N	\N
1687155239645349700	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6ImMzNTU1OGVhLTQ5YmEtNGY2Yi1hODE5LTE3OWIzMTg0YTg3NyJ9.eyJpYXQiOjE3NjgzMTYxNzcsImV4cCI6NDkyMTkxNjE3Nywic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.8RxVivuYquzW8RHW8xumkLJHk3IXWistDdvn8_O6Dsk	e6355318-541e-4c5d-8a50-739f14a22075	192.168.1.119	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2026-01-13 14:56:17.477	\N	\N	\N
1687804423197165381	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6Ijc0YzY0OGQ3LTIxNWQtNGM3Yy05MzY2LWYyNWQ0ZTVjYmE3MCJ9.eyJpYXQiOjE3NjgzOTM1NjYsImV4cCI6NDkyMTk5MzU2Niwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.LjBsDpk1b_zwrhPe7E-PdogKl_9TKYugkUpin3eOOQ8	9df6d25b-cef5-4e46-9359-81e740548062	192.168.1.119	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2026-01-14 12:26:06.183	\N	\N	\N
1689343956011190088	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjliMjRjOWFhLTM4ODQtNGIxMi1iY2FjLTJhZWU0MWY2YmFkOCJ9.eyJpYXQiOjE3Njg1NzcwOTIsImV4cCI6NDkyMjE3NzA5Miwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.IPj2h111PdBMSgfxOx8H0hMrV7SXoUHSmhgc5Mpo-vw	\N	192.168.1.111	node	2026-01-16 15:24:52.795	\N	\N	\N
1689343959207249737	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjU2Y2NhZDJlLTc2NjMtNDFhMS1hNmE0LWI1MTk0YzQzY2M4MiJ9.eyJpYXQiOjE3Njg1NzcwOTMsImV4cCI6NDkyMjE3NzA5Mywic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.1xN-j-d0HgV3pdRyDLLDfp7rYjESohuTG1E5N_cxCyw	\N	192.168.1.111	node	2026-01-16 15:24:53.181	\N	\N	\N
1689345759318640467	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjI2ZTgyYzAzLTVlMDAtNGQyZi05NDBlLWNhMzRiZDcyNDNjYSJ9.eyJpYXQiOjE3Njg1NzczMDcsImV4cCI6NDkyMjE3NzMwNywic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.bNe6Li-LsBCWXFkkyqEVgoMLYjM7VAdlI8xTzm5XlX0	\N	192.168.1.111	node	2026-01-16 15:28:27.771	\N	\N	\N
1689345762036549460	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6ImI4ODRjMjExLTFjMzEtNDQyNi1iNzkwLTg3OWVjNGZiZWYxMSJ9.eyJpYXQiOjE3Njg1NzczMDgsImV4cCI6NDkyMjE3NzMwOCwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.GRN2NVDvjK4cif8uStfgIIqYouM7VFXY-Jz0q9BCOUk	\N	192.168.1.111	node	2026-01-16 15:28:28.095	\N	\N	\N
1689345805455984478	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjNiNjJlMTE2LTliZGItNGMzZC1hZjhlLTE4MzU2YmIyNWYzYiJ9.eyJpYXQiOjE3Njg1NzczMTMsImV4cCI6NDkyMjE3NzMxMywic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.4C8vnHRdPWnusPwqFEFfPPWULV72EWIXN3Az1NLnDpA	\N	192.168.1.111	node	2026-01-16 15:28:33.271	\N	\N	\N
1689345808131950431	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6ImJhZDJkMmYzLTQ3ODItNDZjZi1iNjUxLWM5YjY2NDFiNTI2ZCJ9.eyJpYXQiOjE3Njg1NzczMTMsImV4cCI6NDkyMjE3NzMxMywic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.1lkCxmWGX8Rcx3-_PzqCqaAcuVJ8SUdrC6o0r1QhR-k	\N	192.168.1.111	node	2026-01-16 15:28:33.591	\N	\N	\N
1689347013574920041	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjljNzI4NmQ2LTVkMTgtNDJiMS1hYzNkLTgyODhiNDE3ZjMyOCJ9.eyJpYXQiOjE3Njg1Nzc0NTcsImV4cCI6NDkyMjE3NzQ1Nywic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.SR0pGOswHvzcmglHKqlFcFBydrJzuwseKAuJ9ux3PQw	\N	192.168.1.111	node	2026-01-16 15:30:57.289	\N	\N	\N
1689347016955529066	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjgwNDM3NjZjLWEwMWItNDVhYi04Y2IxLWI5YTkyOWQzMGFjZSJ9.eyJpYXQiOjE3Njg1Nzc0NTcsImV4cCI6NDkyMjE3NzQ1Nywic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.rnldP2brsrfvTj_fL1RqrHi91CzflRujXNXk8wY2McE	\N	192.168.1.111	node	2026-01-16 15:30:57.694	\N	\N	\N
1689350316731926388	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6ImNjYTkzOGRhLWM2YzctNDNlNy05ZjI3LWVlNmZhOTdhNTI0ZCJ9.eyJpYXQiOjE3Njg1Nzc4NTAsImV4cCI6NDkyMjE3Nzg1MCwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.pce1LxQOLeDqsPpw5oMSgtsv6lOxyVkkXUQB2_fOG18	\N	192.168.1.111	node	2026-01-16 15:37:30.998	\N	\N	\N
1689350319365949301	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjU4NWZhYzk3LWU2NzktNDliZC1hZGRhLTc1NGM0NjJjODc2YiJ9.eyJpYXQiOjE3Njg1Nzc4NTEsImV4cCI6NDkyMjE3Nzg1MSwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.lLb057bm7GX1MWYSexcC-uRcDirZ3MwzLAXIdWioUtY	\N	192.168.1.111	node	2026-01-16 15:37:31.371	\N	\N	\N
1689350454539978623	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6Ijc1YTcwN2E2LTA3OWItNDcwYy04N2Y3LWFhNTUxNjFjZTZiZSJ9.eyJpYXQiOjE3Njg1Nzc4NjcsImV4cCI6NDkyMjE3Nzg2Nywic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.dH_nPjKW1ge-UCO9du_Mfhf8-cPoWRPUcFXhFwu7Z4o	\N	192.168.1.111	node	2026-01-16 15:37:47.486	\N	\N	\N
1689350457660540800	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6ImNiZDFlZWNhLTkwYjItNGMyNS1iNjkwLTEwYmZiMDBiMjdmNiJ9.eyJpYXQiOjE3Njg1Nzc4NjcsImV4cCI6NDkyMjE3Nzg2Nywic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.RX5pvJ1_IFaT0pP5RKXyzNMW37r9g-eov8VkoYUZpEA	\N	192.168.1.111	node	2026-01-16 15:37:47.797	\N	\N	\N
1689351134671538058	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjRkMDVhNGM4LTM4YzgtNGJmZi04MzllLWM4MDliNWYyZDYyZiJ9.eyJpYXQiOjE3Njg1Nzc5NDgsImV4cCI6NDkyMjE3Nzk0OCwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.VWFjQTTDEePZT8p3dDS67tlaurjYOV6zCDB6kId18LM	\N	192.168.1.111	node	2026-01-16 15:39:08.564	\N	\N	\N
1689351137993426827	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjQwYThlZTdjLTAwZmMtNGU3YS04YmEzLWJkYTNhYjdjYmZmYyJ9.eyJpYXQiOjE3Njg1Nzc5NDgsImV4cCI6NDkyMjE3Nzk0OCwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.d8EZS5pgR0aL_Z-DMIEWN9oo2urh1Pmrj5eK5q38qnY	\N	192.168.1.111	node	2026-01-16 15:39:08.959	\N	\N	\N
1689351915038574485	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjkyOTM4N2M1LWZhMmItNDI5Mi05YzA4LTkxZmY5ZmVlNTA3NSJ9.eyJpYXQiOjE3Njg1NzgwNDEsImV4cCI6NDkyMjE3ODA0MSwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.PZguz4bYyXLlSDQeo4jwlR1J-197lVo83oPoPZxwvFU	\N	192.168.1.111	node	2026-01-16 15:40:41.591	\N	\N	\N
1689351918184302486	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjYzMDg2MTNhLWQwMmYtNDY1OC1hNzVhLTdhMDM1MzhmYmRiNCJ9.eyJpYXQiOjE3Njg1NzgwNDEsImV4cCI6NDkyMjE3ODA0MSwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.8kpPiLC1OaKGi_Pc_v8JqWr54TdYOR7SC6nUG0Oz81o	\N	192.168.1.111	node	2026-01-16 15:40:41.966	\N	\N	\N
1689351947762534304	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6ImI5NDQyZjQ4LWI3NjMtNDQ5Yi05ZjBiLTkyZTMzZDZjOGFhNCJ9.eyJpYXQiOjE3Njg1NzgwNDUsImV4cCI6NDkyMjE3ODA0NSwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.ooFKTVKWSsojl9KcYV5zTPaaC-RbB9f-09Pg6ZRhfCw	\N	192.168.1.111	node	2026-01-16 15:40:45.492	\N	\N	\N
1689351950950205345	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjQzOWYxZmM1LWMzNjQtNDhjMC1iOTViLWQ2NDEwMDJlNWFkZiJ9.eyJpYXQiOjE3Njg1NzgwNDUsImV4cCI6NDkyMjE3ODA0NSwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.0Mg8YdS5Xy62MeO-XRXuaWAAllqr0L8e7OqMwNqnS3g	\N	192.168.1.111	node	2026-01-16 15:40:45.871	\N	\N	\N
1689478794177415083	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjM1MDM5MDQyLWNjNzktNDdkNS05NjQzLTdjZTFkNzE5YWQ0YSJ9.eyJpYXQiOjE3Njg1OTMxNjYsImV4cCI6NDkyMjE5MzE2Niwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.NSCtZbfCDiLyqarcH5Kkbekv-CT54-eCqaVXiRs4f-U	\N	192.168.1.111	node	2026-01-16 19:52:46.761	\N	\N	\N
1689478796861769644	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6ImYzYjczMjVkLWEyNzktNGRhOC04YTQxLTliZDA3NGMxZmI5MyJ9.eyJpYXQiOjE3Njg1OTMxNjcsImV4cCI6NDkyMjE5MzE2Nywic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.tZEagnBzukmf9oVwKkq1jA5q7RV3Oz6JmW9-eYfjxM8	\N	192.168.1.111	node	2026-01-16 19:52:47.084	\N	\N	\N
1689483581648275382	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjgxMGQ1ZWRmLTNmMzctNDA5Yi05NTdjLTdiODQwM2YyMDgwYiJ9.eyJpYXQiOjE3Njg1OTM3MzcsImV4cCI6NDkyMjE5MzczNywic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.2tz3xkfSIKdb62qU1X8m3XM8AlBNrcLM9QQk2X0zCd4	\N	192.168.1.111	node	2026-01-16 20:02:17.473	\N	\N	\N
1689483584852723639	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjQ3NzljMGUyLWU2YzEtNGQzOC04MDBhLTZiZTkyZmE4NTQ5MSJ9.eyJpYXQiOjE3Njg1OTM3MzcsImV4cCI6NDkyMjE5MzczNywic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.TVrsCmoLh5l9ji_tER-D1NaEMYqjCzZ1OtuoFBF6yHM	\N	192.168.1.111	node	2026-01-16 20:02:17.798	\N	\N	\N
1689894992547416001	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6ImY0OWFiMWEwLTMxOTgtNDBhYy1iYmU1LWYzZDE5ZDRhYjBkZCJ9.eyJpYXQiOjE3Njg2NDI3ODEsImV4cCI6NDkyMjI0Mjc4MSwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.lGnfA5v02spxcAlH3vpIFzJTjlFR_lJQIVr0z2zSQ1U	\N	10.42.2.96	axios/1.12.0	2026-01-17 09:39:41.475	\N	\N	\N
1690085629418801092	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6ImM5ODI5MDA0LTQ3M2ItNGE2Mi05MzgxLTBmZWI2NjM4ZThmNyJ9.eyJpYXQiOjE3Njg2NjU1MDcsImV4cCI6NDkyMjI2NTUwNywic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.gWZKnu-oIc_gyzZCJyyppq4CyO1diuQ4U-avYbu2hQw	\N	192.168.1.111	node	2026-01-17 15:58:27.158	\N	\N	\N
1690085632103155653	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjMwZTk3MDEyLTNmYWQtNDcxYS1iMDVjLWVlZDRjYTBmM2RkNCJ9.eyJpYXQiOjE3Njg2NjU1MDcsImV4cCI6NDkyMjI2NTUwNywic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.o_OzjyL8-ovIp41eED7OMCzJ4xnZrcfKAEXR8x-wyGk	\N	192.168.1.111	node	2026-01-17 15:58:27.481	\N	\N	\N
1704726106864617427	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjM1NTg5ODRiLWU5NmMtNGIwYS1hNWM3LTRmZDAyMTBkMjFlZSJ9.eyJpYXQiOjE3NzA0MTA3ODgsImV4cCI6NDkyNDAxMDc4OCwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.HDzsrZ63FSODqLYhYCteFBJBS81gLX3wEOKbnVKmoXU	\N	10.42.2.185	axios/1.12.0	2026-02-06 20:46:28.072	\N	\N	\N
1704788347718731734	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6ImZiYjI2MDg5LTlmZDUtNDNjMC1iZDY3LTU3NTdiMGMyNDQ1MyJ9.eyJpYXQiOjE3NzA0MTgyMDcsImV4cCI6NDkyNDAxODIwNywic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.MounObvVdt7NUB6b8cA4UBze14ykpa1rWbCQqd3s8s8	\N	10.42.2.185	axios/1.12.0	2026-02-06 22:50:07.761	\N	\N	\N
1705848997677107161	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6ImFiMmZjNmZjLTVhMDQtNDVlZC04MzFmLThkZDM0ZjkzMjI3NSJ9.eyJpYXQiOjE3NzA1NDQ2NDcsImV4cCI6NDkyNDE0NDY0Nywic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.RQFAs0l3N4i7RsZPnrQWZZIsXz1AYQPA8MDAOYKm-is	\N	192.168.1.111	curl/8.7.1	2026-02-08 09:57:27.092	\N	\N	\N
1705853037571999706	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6ImI0MGVmOWJlLWRlODMtNDc2NC1iMWMzLTMxMThmZDMzYTUzYiJ9.eyJpYXQiOjE3NzA1NDUxMjgsImV4cCI6NDkyNDE0NTEyOCwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.ZO2lFCuwl2a5QlzlIGl4j7OYQkpD6_weE85BKQ_eQqs	\N	10.42.2.185	axios/1.12.0	2026-02-08 10:05:28.687	\N	\N	\N
1705968297154971615	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6ImFlYzk0MTg3LTU0N2YtNGQ2Zi1iMDRiLWMxOTQwNDE3OTBjZCJ9.eyJpYXQiOjE3NzA1NTg4NjgsImV4cCI6NDkyNDE1ODg2OCwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.F0eWiuw2sCZFKS8Q4g4uoQTRPdCt7zHHGVERK-t0N7Y	\N	10.42.2.133	axios/1.12.0	2026-02-08 13:54:28.696	\N	\N	\N
1705995525402134502	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6ImY1ZWExNTQ1LTRhNTgtNDczMC05NDk1LTQ1OTgwNGVmNTA1NyJ9.eyJpYXQiOjE3NzA1NjIxMTQsImV4cCI6NDkyNDE2MjExNCwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.SBKp_97K-5vXPUUkj_reR4jvjhBAyGfCKepDbgXFbOg	\N	10.42.2.133	axios/1.12.0	2026-02-08 14:48:34.499	\N	\N	\N
1706131629845514217	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjU0MWUyMTE1LTU2M2YtNGJhMC1iYjQ1LTE1Mzk4ZTk4YTc0ZSJ9.eyJpYXQiOjE3NzA1NzgzMzksImV4cCI6NDkyNDE3ODMzOSwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.TYeRfIL_1xBLBKw0f9FsmW6K-DCYwddWO6PLvn1W0Mk	\N	::1	curl/8.17.0	2026-02-08 19:18:59.473	\N	\N	\N
1706131674229639146	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6ImRiYmRkOThhLTljYzktNDI0Ny05MTE3LTc3YmY1ZDMzMjk1OSJ9.eyJpYXQiOjE3NzA1NzgzNDQsImV4cCI6NDkyNDE3ODM0NCwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.TV4tNDKxR2sMuc7Uk4xk9BkRZg5d2EFj5dcvPp-Rto8	\N	10.42.4.90	curl/8.17.0	2026-02-08 19:19:04.767	\N	\N	\N
1706539301069653995	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6ImM3OTcxZWVlLWZlMjMtNDAxOC04ZTc4LTBkNjNlMTEwNmIxNSJ9.eyJpYXQiOjE3NzA2MjY5MzcsImV4cCI6NDkyNDIyNjkzNywic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.5M33asFGxPjrMM-7WhljqLz8HfnDtGWR65KRnC44bfI	\N	10.42.2.59	axios/1.12.0	2026-02-09 08:48:57.666	\N	\N	\N
1706583931802879982	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6Ijg2ZjEyYjRjLWU4N2ItNDY4MC04NGU0LWM3MWZkMGJmY2ExMSJ9.eyJpYXQiOjE3NzA2MzIyNTgsImV4cCI6NDkyNDIzMjI1OCwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.WLDd7fb-h7zYvKHx_JsUgstmw4y45JPJQNULXNllNKQ	\N	192.168.1.125	axios/1.12.0	2026-02-09 10:17:38.065	\N	\N	\N
1706584179409422321	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjBjOWRhN2VhLTM4ZWEtNDY2NS04YjRhLTIzZDFjMDhjMDcxZiJ9.eyJpYXQiOjE3NzA2MzIyODcsImV4cCI6NDkyNDIzMjI4Nywic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.4dGoqwwLp2XKsWmwZOYNVm4tXZyNwK9cnQGWq-z73wk	6165e283-670c-488e-88d4-09c6ce1856a2	192.168.1.125	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	2026-02-09 10:18:07.585	\N	\N	\N
1706624283582662642	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjUwMjQ4YjgyLTNhZDQtNDMyOC1iMDU1LWYxODU1NThkODRjZiJ9.eyJpYXQiOjE3NzA2MzcwNjgsImV4cCI6NDkyNDIzNzA2OCwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.8j6KVSQLqV5FB8qcxBSFLOi2VaGm3YNkjYWg8ZIL6Kg	\N	10.42.2.75	axios/1.12.0	2026-02-09 11:37:48.37	\N	\N	\N
1706665571371714549	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjU0MDBiNjkyLThkNjYtNDE3YS1iM2RhLTEzNDEyNjc3MmM3NyJ9.eyJpYXQiOjE3NzA2NDE5OTAsImV4cCI6NDkyNDI0MTk5MCwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.egZOGo6REwMpf3SU1_DtmdCGjrvQztdPDgFWVc7Bv0U	\N	10.42.2.104	axios/1.12.0	2026-02-09 12:59:50.263	\N	\N	\N
1706674429011953656	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjljZDM5ZGIxLTI3YmQtNGVlMS05YTgxLTY2N2YwZTgxZDAwYSJ9.eyJpYXQiOjE3NzA2NDMwNDYsImV4cCI6NDkyNDI0MzA0Niwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.KaJ5FPUCIV9RoMDa5GP6ShEKftKKM6cbhgFHI44iRSM	\N	::1	Wget	2026-02-09 13:17:26.178	\N	\N	\N
1706676416189302777	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6Ijg0Y2RkZWQzLWYyMzMtNGM0NC04ODU0LTBhYjViNTYyOTdkYSJ9.eyJpYXQiOjE3NzA2NDMyODMsImV4cCI6NDkyNDI0MzI4Mywic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.CQlUXuzWPX-NWhMbbTI5C0VZJ2154W_7KdW8meapb1M	\N	10.42.3.233	Wget	2026-02-09 13:21:23.065	\N	\N	\N
1706680117981349882	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjZiYjMwYTJjLWQxMjYtNDM0MC05ZTE4LWNkNzFhYjA4OTAxOSJ9.eyJpYXQiOjE3NzA2NDM3MjQsImV4cCI6NDkyNDI0MzcyNCwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.8Ww2mQLBUKSApY5NR__8UXTWjpX-7dl-J4ZIDwPbfVE	\N	10.42.3.241	Wget	2026-02-09 13:28:44.297	\N	\N	\N
1706705065961588731	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6ImNiNThlY2IwLWNhMTktNDg0Yi1hYjYzLWRiOTg1ZGFhODhhYiJ9.eyJpYXQiOjE3NzA2NDY2OTgsImV4cCI6NDkyNDI0NjY5OCwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.aVqWk3rl7Ne5IRxhJc2TWeUIAcjmAM8Tqj0VZVqmaLg	\N	10.42.2.116	axios/1.12.0	2026-02-09 14:18:18.383	\N	\N	\N
1706721824596821049	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6Ijc0ZDdkZGM0LTNmZWQtNGY3Yi1iNDgxLWFjMmZiNTZhNmYwMyJ9.eyJpYXQiOjE3NzA2NDg2OTYsImV4cCI6NDkyNDI0ODY5Niwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.b-93a6BW98YHo9LN6eGTcaeqpIEptMnvXZTyPrDTbsU	\N	10.42.2.116	axios/1.12.0	2026-02-09 14:51:36.166	\N	\N	\N
1706769417439806591	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjVlYTkxZDM5LWMxZTAtNDU5OC05YmYxLTQzZWY5NzMwZGYwYyJ9.eyJpYXQiOjE3NzA2NTQzNjksImV4cCI6NDkyNDI1NDM2OSwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.uleSjsM5Ljhd92CFqTJ8VOcqIAjU_frYABDtt9Bq93c	\N	192.168.1.111	node	2026-02-09 16:26:09.676	\N	\N	\N
1706769420031886464	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjJhNjNiNWUwLThiYmQtNDcwNS1iMTFkLTI4MWEwNzZiNDc5YyJ9.eyJpYXQiOjE3NzA2NTQzNjksImV4cCI6NDkyNDI1NDM2OSwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.-wd4_eEPQjxaT6v_wUZsNkclZa0x7QdAeO1YUOkcMhE	\N	192.168.1.111	node	2026-02-09 16:26:09.987	\N	\N	\N
1709044625227908234	1560328737491256322	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6ImQ3ZDRjN2YxLWQwNDQtNDUyYy04YjY1LTIzYzUzMTFjOGQwMSJ9.eyJpYXQiOjE3NzA5MjU1OTUsImV4cCI6NDkyNDUyNTU5NSwic3ViIjoiMTU2MDMyODczNzQ5MTI1NjMyMiJ9.gZPD55KuXnhPk4P-3RmTQ53PMlI-hcBKOsx5tiGbrFI	770c895a-5144-4aa3-83b1-19a290fef973	84.80.5.71	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	2026-02-12 19:46:35.582	\N	\N	\N
\.


--
-- Data for Name: storage_usage; Type: TABLE DATA; Schema: public; Owner: mini1
--

COPY public.storage_usage (id, total, user_avatars, background_images, attachments, created_at, updated_at) FROM stdin;
1	0	0	0	0	2025-11-07 08:29:22.407578	\N
\.


--
-- Data for Name: task; Type: TABLE DATA; Schema: public; Owner: mini1
--

COPY public.task (id, task_list_id, assignee_user_id, "position", name, is_completed, created_at, updated_at, linked_card_id) FROM stdin;
1634824081566074589	1634803184562079449	1560328737491256323	65536	TaskTitle - TaskReferenceID - TaskStateReference	f	2025-11-02 10:03:37.303	2025-11-02 10:05:03.571	\N
1634824442695648991	1634824401155262174	1560328737491256323	65536	TaskTitle - TaskReferenceID - TaskStateReference	f	2025-11-02 10:04:20.353	2025-11-02 10:05:05.631	\N
1634824608949470945	1634824583389382368	\N	65536	TaskTitle - TaskReferenceID - TaskStateReference	f	2025-11-02 10:04:40.172	2025-11-02 10:05:07.128	\N
1635647558657246998	1635621825192920820	\N	229376	Provide a task list for the QA Task List given the card label: {{card.card_label}}, card title: {{card.title}}, card description: {{card.description}}, acceptance criteria {{card.acceptance_criteria}}, and the DOING task list {{card.todo_task_list}} | CARD_REQUEST, CARD | CARD {qa_task_list:{task_index:Integer, task_title, task_inputs, task_output, task_output_schema}}	f	2025-11-03 13:19:43.421	2025-11-03 13:20:08.671	\N
1634824058203801308	1634803011739977432	1560328737491256323	65536	TaskTitle - TaskReferenceID - TaskStateReferences [IN: OBJECT, OBJECT, OBJECT, OUT:OBJECT]	f	2025-11-02 10:03:34.515	2025-11-03 12:28:33.783	\N
1635639275007510289	1635621825192920819	\N	327680	Provide 4 scenario titles for BDD acceptance criteria to evaluate the card during quality inspection |  [CARD_LABEL, CARD_REQUEST, CARD_DESCRIPTION] | CARD {scenarios:{index:Integer, {feature_title: String}}}	f	2025-11-03 13:03:15.932	\N	\N
1635639327050434322	1635621825192920819	\N	393216	For scenario title {{scenarios[0].title}} define the BDD acceptance criteria in gherkin |  [CARD_LABEL, CARD_REQUEST, CARD_DESCRIPTION, SCENARIO_TITLES] | CARD {scenarios:{index:Integer, {scenario_content: String (gherkin)}}}	f	2025-11-03 13:03:22.139	2025-11-03 13:08:44.432	\N
1635640523928635155	1635621825192920819	\N	458752	For scenario {{title scenarios[1].title}} define the BDD acceptance criteria in gherkin |  [CARD_LABEL, CARD_REQUEST, CARD_DESCRIPTION, SCENARIO_TITLES] | CARD {scenarios:{index:Integer, {scenario_content: String (gherkin)}}}	f	2025-11-03 13:05:44.813	2025-11-03 13:08:50.77	\N
1635641068961662740	1635621825192920819	\N	524288	For scenario {{title scenarios[2].title}} define the BDD acceptance criteria in gherkin |  [CARD_LABEL, CARD_REQUEST, CARD_DESCRIPTION, SCENARIO_TITLES] | CARD {scenarios:{index:Integer, {scenario_content: String (gherkin)}}}	f	2025-11-03 13:06:49.787	2025-11-03 13:08:57.483	\N
1635631806579476238	1635621825192920820	\N	196608	Provide a task list for the DOING Task List given the card label: {{card.card_label}}, card title: {{card.title}}, card description: {{card.description}}, acceptance criteria {{card.acceptance_criteria}}, and the TODO task list {{card.todo_task_list}} | CARD_REQUEST, CARD | CARD {doing_task_list:{task_index:Integer, task_title, task_inputs, task_output, task_output_schema}}	f	2025-11-03 12:48:25.628	2025-11-03 13:20:14.62	\N
1635626798614054665	1635621825192920819	\N	196608	Based on the context create a card description | [PROJECT, CARD_LABEL, CARD_REQUEST] | CARD {description: String}	f	2025-11-03 12:38:28.63	2025-11-03 12:55:40.862	\N
1635648104747239191	1635621825192920820	\N	327680	Provide a task list for the DONE Task List given the card label: {{card.card_label}}, card title: {{card.title}}, card description: {{card.description}}, acceptance criteria {{card.acceptance_criteria}}, and the DOING task list {{card.doing_task_list}} | CARD_REQUEST, CARD | CARD {qa_task_list:{task_index:Integer, task_title, task_inputs, task_output, task_output_schema}}	f	2025-11-03 13:20:48.516	\N	\N
1635641112582424341	1635621825192920819	\N	589824	For scenario title {{scenarios[3].title}} define the BDD acceptance criteria in gherkin |  [CARD_LABEL, CARD_REQUEST, CARD_DESCRIPTION, SCENARIO_TITLES] | CARD {scenarios:{index:Integer, {scenario_content: String (gherkin)}}}	f	2025-11-03 13:06:54.991	2025-11-03 13:09:05.691	\N
1635621825251641087	1635621825192920821	1560328737491256323	65536	Evaluate the completess of the {{card}} and identify which item on the card is ambiguous or unclear | CARD | CARD_FEEDBACK {item:String:{feedback: String}}	f	2025-11-03 12:28:35.761	2025-11-03 13:41:07.149	\N
1635629919822153482	1635621825192920819	\N	262144	Based on the context create the card title for a card described with {{card.description}} | [CARD_LABEL, CARD_REQUEST, CARD_DESCRIPTION] | CARD {title: String}	f	2025-11-03 12:44:40.707	2025-11-03 13:09:44.485	\N
1635648737843873560	1635621825192920819	\N	81920	PROJECT = planka.get_project(project_id)	f	2025-11-03 13:22:03.991	2025-11-03 13:22:50.099	\N
1635634623549540111	1635621825192920819	\N	163840	Based on the context decide the card label | [PROJECT, CARD_REQUEST, CARD_LABEL_LIST] | CARD {card_label: Enum}	f	2025-11-03 12:54:01.435	2025-11-03 13:12:10.017	\N
1635631754737878797	1635621825192920820	\N	131072	Provide a task list for the TODO Task List given the card label: {{card.card_label}}, card title: {{card.title}}, card description: {{card.description}}, acceptance criteria {{card.acceptance_criteria}} | CARD_REQUEST, CARD | CARD {todo_task_list:{task_index:Integer, task_title, task_inputs, task_output, task_output_schema}}	f	2025-11-03 12:48:19.447	2025-11-03 13:18:44.346	\N
1635659290435913498	1635621825192920821	\N	131072	Decide if the card feedback should warrant returning the card back to the DOING list card feedback {{card_feedback}} card {{card}} | CARD, CARD_FEEDBACK | QA_PASS {boolean}	f	2025-11-03 13:43:01.957	\N	\N
1635649481712076569	1635621825192920819	\N	122880	CARD_REQUEST = state_store.get(card_request_id)	f	2025-11-03 13:23:32.659	2025-11-03 13:23:37.121	\N
\.


--
-- Data for Name: task_list; Type: TABLE DATA; Schema: public; Owner: mini1
--

COPY public.task_list (id, card_id, "position", name, show_on_front_of_card, created_at, updated_at, hide_completed_tasks) FROM stdin;
1634803011739977432	1627548744566179439	65536	TODO TASK LIST	t	2025-11-02 09:21:45.582	2025-11-02 10:02:51.93	f
1634803184562079449	1627548744566179439	131072	DOING TASK LIST	t	2025-11-02 09:22:06.185	2025-11-02 10:02:58.623	f
1634824401155262174	1627548744566179439	196608	QA TASK LIST	t	2025-11-02 10:04:15.399	\N	f
1634824583389382368	1627548744566179439	262144	DONE TASK LIST	t	2025-11-02 10:04:37.124	\N	f
1635621825192920819	1635621824966428401	65536	TODO TASK LIST	t	2025-11-03 12:28:35.757	\N	f
1635621825192920820	1635621824966428401	131072	DOING TASK LIST	t	2025-11-03 12:28:35.757	\N	f
1635621825192920821	1635621824966428401	196608	QA TASK LIST	t	2025-11-03 12:28:35.757	\N	f
1635621825192920822	1635621824966428401	262144	DONE TASK LIST	t	2025-11-03 12:28:35.757	\N	f
1706713451935564816	1706713451071538190	65536	Demo Checklist	t	2026-02-09 14:34:58.07	\N	f
1706721991161021516	1706721990238274634	65536	Demo Checklist	t	2026-02-09 14:51:56.025	\N	f
1706725910620669054	1706725909068776572	65536	Demo Checklist	t	2026-02-09 14:59:43.26	\N	f
\.


--
-- Data for Name: uploaded_file; Type: TABLE DATA; Schema: public; Owner: mini1
--

COPY public.uploaded_file (id, references_total, created_at, updated_at, type, mime_type, size) FROM stdin;
\.


--
-- Data for Name: user_account; Type: TABLE DATA; Schema: public; Owner: mini1
--

COPY public.user_account (id, email, password, role, name, username, avatar, phone, organization, language, subscribe_to_own_cards, subscribe_to_card_when_commenting, turn_off_recent_card_highlighting, enable_favorites_by_default, default_editor_mode, default_home_view, default_projects_order, is_sso_user, is_deactivated, created_at, updated_at, password_changed_at, terms_signature, terms_accepted_at, api_key_prefix, api_key_hash, api_key_created_at) FROM stdin;
1560328737491256323	execution_agent@gmail.com	$2b$10$vpoSEvqsa0KymG.SnTHsU.CwGePmc/gPAO0Ze4/QE.BAUF8UH1SeK	boardUser	Execution Agent	execution_agent	\N	\N	\N	\N	f	t	f	f	wysiwyg	groupedProjects	byDefault	f	f	2025-07-30 10:50:39.567685	2025-07-30 11:00:33.651	\N	\N	\N	\N	\N	\N
1560328737491256324	kanban_agent@gmail.com	$2b$10$vpoSEvqsa0KymG.SnTHsU.CwGePmc/gPAO0Ze4/QE.BAUF8UH1SeK	boardUser	Kanban Agent	kanban_agent	\N	\N	\N	\N	f	t	f	f	wysiwyg	groupedProjects	byDefault	f	f	2025-07-30 10:50:39.567685	2025-07-30 11:00:37.275	\N	\N	\N	\N	\N	\N
1560328737491256325	meta_agent@gmail.com	$2b$10$vpoSEvqsa0KymG.SnTHsU.CwGePmc/gPAO0Ze4/QE.BAUF8UH1SeK	boardUser	Meta Agent	meta_agent	\N	\N	\N	\N	f	t	f	f	wysiwyg	groupedProjects	byDefault	f	f	2025-07-30 10:50:39.567685	2025-07-30 11:00:41.191	\N	\N	\N	\N	\N	\N
1626139592824457076	project_agent@gmail.com	$2b$10$WPFiaWU6vxE/LrMu4j2oGOBTYX4UGtYDzU1Iv44oQYaA68XptBU9e	boardUser	Project Agent	project_agent	\N	\N	\N	\N	f	t	f	f	wysiwyg	groupedProjects	byDefault	f	f	2025-10-21 10:29:05.57	\N	\N	\N	\N	\N	\N	\N
1560278692305830913	demo@demo.demo	$2b$10$Q1Xu1a/GBhEHHyWqXFaNH.mL.ANSQ7RCCLSopR/NL6QA0HIF1Rrc6	admin	Demo User	demo	\N	\N	\N	\N	f	t	f	f	wysiwyg	groupedProjects	byDefault	f	f	2025-07-22 13:35:14.411	\N	\N	\N	\N	\N	\N	\N
1560328737491256322	agent@gmail.com	$2b$10$N5lrSDX77fVYj1eoJEqn2eUE4TcQ.zhwMOvrKK8mwYhnuWsYzi1gO	admin	admin	admin user	\N	\N	\N	\N	f	t	f	f	markup	groupedProjects	byDefault	f	f	2025-07-30 10:50:39.567685	2025-11-08 09:42:11.844	\N	b6d551164552f5886e8e9d372ba1198a1b991ed7df4e4fc3c005883483b6a8a2	2025-11-08 09:42:11.841	\N	\N	\N
\.


--
-- Data for Name: webhook; Type: TABLE DATA; Schema: public; Owner: mini1
--

COPY public.webhook (id, board_id, name, url, access_token, events, excluded_events, created_at, updated_at) FROM stdin;
1686502322810652457	\N	n8n-integration	http://n8n.n8n.svc.cluster.local:5678/webhook/kanban	planka-n8n-webhook-token-2025	{cardCreate,cardUpdate,cardDelete,cardMembershipCreate,cardMembershipDelete,cardLabelCreate,cardLabelDelete,commentCreate,commentUpdate,commentDelete,attachmentCreate,attachmentDelete,taskCreate,taskUpdate,taskDelete,listCreate,listUpdate,listDelete}	\N	2026-01-12 17:19:03.725	\N
\.


--
-- Name: chunk_column_stats_id_seq; Type: SEQUENCE SET; Schema: _timescaledb_catalog; Owner: postgres
--

SELECT pg_catalog.setval('_timescaledb_catalog.chunk_column_stats_id_seq', 1, false);


--
-- Name: chunk_constraint_name; Type: SEQUENCE SET; Schema: _timescaledb_catalog; Owner: postgres
--

SELECT pg_catalog.setval('_timescaledb_catalog.chunk_constraint_name', 1, false);


--
-- Name: chunk_id_seq; Type: SEQUENCE SET; Schema: _timescaledb_catalog; Owner: postgres
--

SELECT pg_catalog.setval('_timescaledb_catalog.chunk_id_seq', 1, false);


--
-- Name: continuous_agg_migrate_plan_step_step_id_seq; Type: SEQUENCE SET; Schema: _timescaledb_catalog; Owner: postgres
--

SELECT pg_catalog.setval('_timescaledb_catalog.continuous_agg_migrate_plan_step_step_id_seq', 1, false);


--
-- Name: dimension_id_seq; Type: SEQUENCE SET; Schema: _timescaledb_catalog; Owner: postgres
--

SELECT pg_catalog.setval('_timescaledb_catalog.dimension_id_seq', 1, false);


--
-- Name: dimension_slice_id_seq; Type: SEQUENCE SET; Schema: _timescaledb_catalog; Owner: postgres
--

SELECT pg_catalog.setval('_timescaledb_catalog.dimension_slice_id_seq', 1, false);


--
-- Name: hypertable_id_seq; Type: SEQUENCE SET; Schema: _timescaledb_catalog; Owner: postgres
--

SELECT pg_catalog.setval('_timescaledb_catalog.hypertable_id_seq', 1, false);


--
-- Name: bgw_job_id_seq; Type: SEQUENCE SET; Schema: _timescaledb_config; Owner: postgres
--

SELECT pg_catalog.setval('_timescaledb_config.bgw_job_id_seq', 1000, false);


--
-- Name: migration_id_seq; Type: SEQUENCE SET; Schema: public; Owner: mini1
--

SELECT pg_catalog.setval('public.migration_id_seq', 14, true);


--
-- Name: migration_lock_index_seq; Type: SEQUENCE SET; Schema: public; Owner: mini1
--

SELECT pg_catalog.setval('public.migration_lock_index_seq', 1, true);


--
-- Name: next_id_seq; Type: SEQUENCE SET; Schema: public; Owner: mini1
--

SELECT pg_catalog.setval('public.next_id_seq', 3214, true);


--
-- Name: action action_pkey; Type: CONSTRAINT; Schema: public; Owner: mini1
--

ALTER TABLE ONLY public.action
    ADD CONSTRAINT action_pkey PRIMARY KEY (id);


--
-- Name: attachment attachment_pkey; Type: CONSTRAINT; Schema: public; Owner: mini1
--

ALTER TABLE ONLY public.attachment
    ADD CONSTRAINT attachment_pkey PRIMARY KEY (id);


--
-- Name: background_image background_image_pkey; Type: CONSTRAINT; Schema: public; Owner: mini1
--

ALTER TABLE ONLY public.background_image
    ADD CONSTRAINT background_image_pkey PRIMARY KEY (id);


--
-- Name: base_custom_field_group base_custom_field_group_pkey; Type: CONSTRAINT; Schema: public; Owner: mini1
--

ALTER TABLE ONLY public.base_custom_field_group
    ADD CONSTRAINT base_custom_field_group_pkey PRIMARY KEY (id);


--
-- Name: board_membership board_membership_board_id_user_id_unique; Type: CONSTRAINT; Schema: public; Owner: mini1
--

ALTER TABLE ONLY public.board_membership
    ADD CONSTRAINT board_membership_board_id_user_id_unique UNIQUE (board_id, user_id);


--
-- Name: board_membership board_membership_pkey; Type: CONSTRAINT; Schema: public; Owner: mini1
--

ALTER TABLE ONLY public.board_membership
    ADD CONSTRAINT board_membership_pkey PRIMARY KEY (id);


--
-- Name: board board_pkey; Type: CONSTRAINT; Schema: public; Owner: mini1
--

ALTER TABLE ONLY public.board
    ADD CONSTRAINT board_pkey PRIMARY KEY (id);


--
-- Name: board_subscription board_subscription_board_id_user_id_unique; Type: CONSTRAINT; Schema: public; Owner: mini1
--

ALTER TABLE ONLY public.board_subscription
    ADD CONSTRAINT board_subscription_board_id_user_id_unique UNIQUE (board_id, user_id);


--
-- Name: board_subscription board_subscription_pkey; Type: CONSTRAINT; Schema: public; Owner: mini1
--

ALTER TABLE ONLY public.board_subscription
    ADD CONSTRAINT board_subscription_pkey PRIMARY KEY (id);


--
-- Name: card_label card_label_card_id_label_id_unique; Type: CONSTRAINT; Schema: public; Owner: mini1
--

ALTER TABLE ONLY public.card_label
    ADD CONSTRAINT card_label_card_id_label_id_unique UNIQUE (card_id, label_id);


--
-- Name: card_label card_label_pkey; Type: CONSTRAINT; Schema: public; Owner: mini1
--

ALTER TABLE ONLY public.card_label
    ADD CONSTRAINT card_label_pkey PRIMARY KEY (id);


--
-- Name: card_membership card_membership_card_id_user_id_unique; Type: CONSTRAINT; Schema: public; Owner: mini1
--

ALTER TABLE ONLY public.card_membership
    ADD CONSTRAINT card_membership_card_id_user_id_unique UNIQUE (card_id, user_id);


--
-- Name: card_membership card_membership_pkey; Type: CONSTRAINT; Schema: public; Owner: mini1
--

ALTER TABLE ONLY public.card_membership
    ADD CONSTRAINT card_membership_pkey PRIMARY KEY (id);


--
-- Name: card card_pkey; Type: CONSTRAINT; Schema: public; Owner: mini1
--

ALTER TABLE ONLY public.card
    ADD CONSTRAINT card_pkey PRIMARY KEY (id);


--
-- Name: card_subscription card_subscription_card_id_user_id_unique; Type: CONSTRAINT; Schema: public; Owner: mini1
--

ALTER TABLE ONLY public.card_subscription
    ADD CONSTRAINT card_subscription_card_id_user_id_unique UNIQUE (card_id, user_id);


--
-- Name: card_subscription card_subscription_pkey; Type: CONSTRAINT; Schema: public; Owner: mini1
--

ALTER TABLE ONLY public.card_subscription
    ADD CONSTRAINT card_subscription_pkey PRIMARY KEY (id);


--
-- Name: comment comment_pkey; Type: CONSTRAINT; Schema: public; Owner: mini1
--

ALTER TABLE ONLY public.comment
    ADD CONSTRAINT comment_pkey PRIMARY KEY (id);


--
-- Name: config config_pkey; Type: CONSTRAINT; Schema: public; Owner: mini1
--

ALTER TABLE ONLY public.config
    ADD CONSTRAINT config_pkey PRIMARY KEY (id);


--
-- Name: custom_field_group custom_field_group_pkey; Type: CONSTRAINT; Schema: public; Owner: mini1
--

ALTER TABLE ONLY public.custom_field_group
    ADD CONSTRAINT custom_field_group_pkey PRIMARY KEY (id);


--
-- Name: custom_field custom_field_pkey; Type: CONSTRAINT; Schema: public; Owner: mini1
--

ALTER TABLE ONLY public.custom_field
    ADD CONSTRAINT custom_field_pkey PRIMARY KEY (id);


--
-- Name: custom_field_value custom_field_value_card_id_custom_field_group_id_custom_field_i; Type: CONSTRAINT; Schema: public; Owner: mini1
--

ALTER TABLE ONLY public.custom_field_value
    ADD CONSTRAINT custom_field_value_card_id_custom_field_group_id_custom_field_i UNIQUE (card_id, custom_field_group_id, custom_field_id);


--
-- Name: custom_field_value custom_field_value_pkey; Type: CONSTRAINT; Schema: public; Owner: mini1
--

ALTER TABLE ONLY public.custom_field_value
    ADD CONSTRAINT custom_field_value_pkey PRIMARY KEY (id);


--
-- Name: identity_provider_user identity_provider_user_issuer_sub_unique; Type: CONSTRAINT; Schema: public; Owner: mini1
--

ALTER TABLE ONLY public.identity_provider_user
    ADD CONSTRAINT identity_provider_user_issuer_sub_unique UNIQUE (issuer, sub);


--
-- Name: identity_provider_user identity_provider_user_pkey; Type: CONSTRAINT; Schema: public; Owner: mini1
--

ALTER TABLE ONLY public.identity_provider_user
    ADD CONSTRAINT identity_provider_user_pkey PRIMARY KEY (id);


--
-- Name: label label_pkey; Type: CONSTRAINT; Schema: public; Owner: mini1
--

ALTER TABLE ONLY public.label
    ADD CONSTRAINT label_pkey PRIMARY KEY (id);


--
-- Name: list list_pkey; Type: CONSTRAINT; Schema: public; Owner: mini1
--

ALTER TABLE ONLY public.list
    ADD CONSTRAINT list_pkey PRIMARY KEY (id);


--
-- Name: migration_lock migration_lock_pkey; Type: CONSTRAINT; Schema: public; Owner: mini1
--

ALTER TABLE ONLY public.migration_lock
    ADD CONSTRAINT migration_lock_pkey PRIMARY KEY (index);


--
-- Name: migration migration_pkey; Type: CONSTRAINT; Schema: public; Owner: mini1
--

ALTER TABLE ONLY public.migration
    ADD CONSTRAINT migration_pkey PRIMARY KEY (id);


--
-- Name: notification notification_pkey; Type: CONSTRAINT; Schema: public; Owner: mini1
--

ALTER TABLE ONLY public.notification
    ADD CONSTRAINT notification_pkey PRIMARY KEY (id);


--
-- Name: notification_service notification_service_pkey; Type: CONSTRAINT; Schema: public; Owner: mini1
--

ALTER TABLE ONLY public.notification_service
    ADD CONSTRAINT notification_service_pkey PRIMARY KEY (id);


--
-- Name: project_favorite project_favorite_pkey; Type: CONSTRAINT; Schema: public; Owner: mini1
--

ALTER TABLE ONLY public.project_favorite
    ADD CONSTRAINT project_favorite_pkey PRIMARY KEY (id);


--
-- Name: project_favorite project_favorite_project_id_user_id_unique; Type: CONSTRAINT; Schema: public; Owner: mini1
--

ALTER TABLE ONLY public.project_favorite
    ADD CONSTRAINT project_favorite_project_id_user_id_unique UNIQUE (project_id, user_id);


--
-- Name: project_manager project_manager_pkey; Type: CONSTRAINT; Schema: public; Owner: mini1
--

ALTER TABLE ONLY public.project_manager
    ADD CONSTRAINT project_manager_pkey PRIMARY KEY (id);


--
-- Name: project_manager project_manager_project_id_user_id_unique; Type: CONSTRAINT; Schema: public; Owner: mini1
--

ALTER TABLE ONLY public.project_manager
    ADD CONSTRAINT project_manager_project_id_user_id_unique UNIQUE (project_id, user_id);


--
-- Name: project project_pkey; Type: CONSTRAINT; Schema: public; Owner: mini1
--

ALTER TABLE ONLY public.project
    ADD CONSTRAINT project_pkey PRIMARY KEY (id);


--
-- Name: session session_access_token_unique; Type: CONSTRAINT; Schema: public; Owner: mini1
--

ALTER TABLE ONLY public.session
    ADD CONSTRAINT session_access_token_unique UNIQUE (access_token);


--
-- Name: session session_pending_token_unique; Type: CONSTRAINT; Schema: public; Owner: mini1
--

ALTER TABLE ONLY public.session
    ADD CONSTRAINT session_pending_token_unique UNIQUE (pending_token);


--
-- Name: session session_pkey; Type: CONSTRAINT; Schema: public; Owner: mini1
--

ALTER TABLE ONLY public.session
    ADD CONSTRAINT session_pkey PRIMARY KEY (id);


--
-- Name: storage_usage storage_usage_pkey; Type: CONSTRAINT; Schema: public; Owner: mini1
--

ALTER TABLE ONLY public.storage_usage
    ADD CONSTRAINT storage_usage_pkey PRIMARY KEY (id);


--
-- Name: task_list task_list_pkey; Type: CONSTRAINT; Schema: public; Owner: mini1
--

ALTER TABLE ONLY public.task_list
    ADD CONSTRAINT task_list_pkey PRIMARY KEY (id);


--
-- Name: task task_pkey; Type: CONSTRAINT; Schema: public; Owner: mini1
--

ALTER TABLE ONLY public.task
    ADD CONSTRAINT task_pkey PRIMARY KEY (id);


--
-- Name: uploaded_file uploaded_file_pkey; Type: CONSTRAINT; Schema: public; Owner: mini1
--

ALTER TABLE ONLY public.uploaded_file
    ADD CONSTRAINT uploaded_file_pkey PRIMARY KEY (id);


--
-- Name: user_account user_account_api_key_hash_unique; Type: CONSTRAINT; Schema: public; Owner: mini1
--

ALTER TABLE ONLY public.user_account
    ADD CONSTRAINT user_account_api_key_hash_unique UNIQUE (api_key_hash);


--
-- Name: user_account user_account_email_unique; Type: CONSTRAINT; Schema: public; Owner: mini1
--

ALTER TABLE ONLY public.user_account
    ADD CONSTRAINT user_account_email_unique UNIQUE (email);


--
-- Name: user_account user_account_pkey; Type: CONSTRAINT; Schema: public; Owner: mini1
--

ALTER TABLE ONLY public.user_account
    ADD CONSTRAINT user_account_pkey PRIMARY KEY (id);


--
-- Name: user_account user_account_username_unique; Type: CONSTRAINT; Schema: public; Owner: mini1
--

ALTER TABLE ONLY public.user_account
    ADD CONSTRAINT user_account_username_unique EXCLUDE USING btree (username WITH =) WHERE ((username IS NOT NULL));


--
-- Name: webhook webhook_pkey; Type: CONSTRAINT; Schema: public; Owner: mini1
--

ALTER TABLE ONLY public.webhook
    ADD CONSTRAINT webhook_pkey PRIMARY KEY (id);


--
-- Name: action_board_id_index; Type: INDEX; Schema: public; Owner: mini1
--

CREATE INDEX action_board_id_index ON public.action USING btree (board_id);


--
-- Name: action_card_id_index; Type: INDEX; Schema: public; Owner: mini1
--

CREATE INDEX action_card_id_index ON public.action USING btree (card_id);


--
-- Name: action_user_id_index; Type: INDEX; Schema: public; Owner: mini1
--

CREATE INDEX action_user_id_index ON public.action USING btree (user_id);


--
-- Name: attachment_card_id_index; Type: INDEX; Schema: public; Owner: mini1
--

CREATE INDEX attachment_card_id_index ON public.attachment USING btree (card_id);


--
-- Name: attachment_creator_user_id_index; Type: INDEX; Schema: public; Owner: mini1
--

CREATE INDEX attachment_creator_user_id_index ON public.attachment USING btree (creator_user_id);


--
-- Name: background_image_project_id_index; Type: INDEX; Schema: public; Owner: mini1
--

CREATE INDEX background_image_project_id_index ON public.background_image USING btree (project_id);


--
-- Name: base_custom_field_group_project_id_index; Type: INDEX; Schema: public; Owner: mini1
--

CREATE INDEX base_custom_field_group_project_id_index ON public.base_custom_field_group USING btree (project_id);


--
-- Name: board_membership_project_id_index; Type: INDEX; Schema: public; Owner: mini1
--

CREATE INDEX board_membership_project_id_index ON public.board_membership USING btree (project_id);


--
-- Name: board_membership_user_id_index; Type: INDEX; Schema: public; Owner: mini1
--

CREATE INDEX board_membership_user_id_index ON public.board_membership USING btree (user_id);


--
-- Name: board_position_index; Type: INDEX; Schema: public; Owner: mini1
--

CREATE INDEX board_position_index ON public.board USING btree ("position");


--
-- Name: board_project_id_index; Type: INDEX; Schema: public; Owner: mini1
--

CREATE INDEX board_project_id_index ON public.board USING btree (project_id);


--
-- Name: board_subscription_user_id_index; Type: INDEX; Schema: public; Owner: mini1
--

CREATE INDEX board_subscription_user_id_index ON public.board_subscription USING btree (user_id);


--
-- Name: card_board_id_index; Type: INDEX; Schema: public; Owner: mini1
--

CREATE INDEX card_board_id_index ON public.card USING btree (board_id);


--
-- Name: card_creator_user_id_index; Type: INDEX; Schema: public; Owner: mini1
--

CREATE INDEX card_creator_user_id_index ON public.card USING btree (creator_user_id);


--
-- Name: card_description_index; Type: INDEX; Schema: public; Owner: mini1
--

CREATE INDEX card_description_index ON public.card USING gin (description public.gin_trgm_ops);


--
-- Name: card_label_label_id_index; Type: INDEX; Schema: public; Owner: mini1
--

CREATE INDEX card_label_label_id_index ON public.card_label USING btree (label_id);


--
-- Name: card_list_changed_at_index; Type: INDEX; Schema: public; Owner: mini1
--

CREATE INDEX card_list_changed_at_index ON public.card USING btree (list_changed_at);


--
-- Name: card_list_id_index; Type: INDEX; Schema: public; Owner: mini1
--

CREATE INDEX card_list_id_index ON public.card USING btree (list_id);


--
-- Name: card_membership_user_id_index; Type: INDEX; Schema: public; Owner: mini1
--

CREATE INDEX card_membership_user_id_index ON public.card_membership USING btree (user_id);


--
-- Name: card_name_index; Type: INDEX; Schema: public; Owner: mini1
--

CREATE INDEX card_name_index ON public.card USING gin (name public.gin_trgm_ops);


--
-- Name: card_position_index; Type: INDEX; Schema: public; Owner: mini1
--

CREATE INDEX card_position_index ON public.card USING btree ("position");


--
-- Name: card_subscription_user_id_index; Type: INDEX; Schema: public; Owner: mini1
--

CREATE INDEX card_subscription_user_id_index ON public.card_subscription USING btree (user_id);


--
-- Name: comment_card_id_index; Type: INDEX; Schema: public; Owner: mini1
--

CREATE INDEX comment_card_id_index ON public.comment USING btree (card_id);


--
-- Name: comment_user_id_index; Type: INDEX; Schema: public; Owner: mini1
--

CREATE INDEX comment_user_id_index ON public.comment USING btree (user_id);


--
-- Name: custom_field_base_custom_field_group_id_index; Type: INDEX; Schema: public; Owner: mini1
--

CREATE INDEX custom_field_base_custom_field_group_id_index ON public.custom_field USING btree (base_custom_field_group_id);


--
-- Name: custom_field_custom_field_group_id_index; Type: INDEX; Schema: public; Owner: mini1
--

CREATE INDEX custom_field_custom_field_group_id_index ON public.custom_field USING btree (custom_field_group_id);


--
-- Name: custom_field_group_base_custom_field_group_id_index; Type: INDEX; Schema: public; Owner: mini1
--

CREATE INDEX custom_field_group_base_custom_field_group_id_index ON public.custom_field_group USING btree (base_custom_field_group_id);


--
-- Name: custom_field_group_board_id_index; Type: INDEX; Schema: public; Owner: mini1
--

CREATE INDEX custom_field_group_board_id_index ON public.custom_field_group USING btree (board_id);


--
-- Name: custom_field_group_card_id_index; Type: INDEX; Schema: public; Owner: mini1
--

CREATE INDEX custom_field_group_card_id_index ON public.custom_field_group USING btree (card_id);


--
-- Name: custom_field_group_position_index; Type: INDEX; Schema: public; Owner: mini1
--

CREATE INDEX custom_field_group_position_index ON public.custom_field_group USING btree ("position");


--
-- Name: custom_field_position_index; Type: INDEX; Schema: public; Owner: mini1
--

CREATE INDEX custom_field_position_index ON public.custom_field USING btree ("position");


--
-- Name: custom_field_value_custom_field_group_id_index; Type: INDEX; Schema: public; Owner: mini1
--

CREATE INDEX custom_field_value_custom_field_group_id_index ON public.custom_field_value USING btree (custom_field_group_id);


--
-- Name: custom_field_value_custom_field_id_index; Type: INDEX; Schema: public; Owner: mini1
--

CREATE INDEX custom_field_value_custom_field_id_index ON public.custom_field_value USING btree (custom_field_id);


--
-- Name: identity_provider_user_user_id_index; Type: INDEX; Schema: public; Owner: mini1
--

CREATE INDEX identity_provider_user_user_id_index ON public.identity_provider_user USING btree (user_id);


--
-- Name: idx_board_name_trgm; Type: INDEX; Schema: public; Owner: mini1
--

CREATE INDEX idx_board_name_trgm ON public.board USING gin (name public.gin_trgm_ops);


--
-- Name: idx_card_desc_trgm; Type: INDEX; Schema: public; Owner: mini1
--

CREATE INDEX idx_card_desc_trgm ON public.card USING gin (description public.gin_trgm_ops);


--
-- Name: idx_card_name_trgm; Type: INDEX; Schema: public; Owner: mini1
--

CREATE INDEX idx_card_name_trgm ON public.card USING gin (name public.gin_trgm_ops);


--
-- Name: idx_project_name_trgm; Type: INDEX; Schema: public; Owner: mini1
--

CREATE INDEX idx_project_name_trgm ON public.project USING gin (name public.gin_trgm_ops);


--
-- Name: label_board_id_index; Type: INDEX; Schema: public; Owner: mini1
--

CREATE INDEX label_board_id_index ON public.label USING btree (board_id);


--
-- Name: label_position_index; Type: INDEX; Schema: public; Owner: mini1
--

CREATE INDEX label_position_index ON public.label USING btree ("position");


--
-- Name: list_board_id_index; Type: INDEX; Schema: public; Owner: mini1
--

CREATE INDEX list_board_id_index ON public.list USING btree (board_id);


--
-- Name: list_position_index; Type: INDEX; Schema: public; Owner: mini1
--

CREATE INDEX list_position_index ON public.list USING btree ("position");


--
-- Name: list_type_index; Type: INDEX; Schema: public; Owner: mini1
--

CREATE INDEX list_type_index ON public.list USING btree (type);


--
-- Name: notification_action_id_index; Type: INDEX; Schema: public; Owner: mini1
--

CREATE INDEX notification_action_id_index ON public.notification USING btree (action_id);


--
-- Name: notification_card_id_index; Type: INDEX; Schema: public; Owner: mini1
--

CREATE INDEX notification_card_id_index ON public.notification USING btree (card_id);


--
-- Name: notification_comment_id_index; Type: INDEX; Schema: public; Owner: mini1
--

CREATE INDEX notification_comment_id_index ON public.notification USING btree (comment_id);


--
-- Name: notification_creator_user_id_index; Type: INDEX; Schema: public; Owner: mini1
--

CREATE INDEX notification_creator_user_id_index ON public.notification USING btree (creator_user_id);


--
-- Name: notification_is_read_index; Type: INDEX; Schema: public; Owner: mini1
--

CREATE INDEX notification_is_read_index ON public.notification USING btree (is_read);


--
-- Name: notification_service_board_id_index; Type: INDEX; Schema: public; Owner: mini1
--

CREATE INDEX notification_service_board_id_index ON public.notification_service USING btree (board_id);


--
-- Name: notification_service_user_id_index; Type: INDEX; Schema: public; Owner: mini1
--

CREATE INDEX notification_service_user_id_index ON public.notification_service USING btree (user_id);


--
-- Name: notification_user_id_index; Type: INDEX; Schema: public; Owner: mini1
--

CREATE INDEX notification_user_id_index ON public.notification USING btree (user_id);


--
-- Name: project_favorite_user_id_index; Type: INDEX; Schema: public; Owner: mini1
--

CREATE INDEX project_favorite_user_id_index ON public.project_favorite USING btree (user_id);


--
-- Name: project_manager_user_id_index; Type: INDEX; Schema: public; Owner: mini1
--

CREATE INDEX project_manager_user_id_index ON public.project_manager USING btree (user_id);


--
-- Name: project_owner_project_manager_id_index; Type: INDEX; Schema: public; Owner: mini1
--

CREATE INDEX project_owner_project_manager_id_index ON public.project USING btree (owner_project_manager_id);


--
-- Name: session_remote_address_index; Type: INDEX; Schema: public; Owner: mini1
--

CREATE INDEX session_remote_address_index ON public.session USING btree (remote_address);


--
-- Name: session_user_id_index; Type: INDEX; Schema: public; Owner: mini1
--

CREATE INDEX session_user_id_index ON public.session USING btree (user_id);


--
-- Name: task_assignee_user_id_index; Type: INDEX; Schema: public; Owner: mini1
--

CREATE INDEX task_assignee_user_id_index ON public.task USING btree (assignee_user_id);


--
-- Name: task_linked_card_id_index; Type: INDEX; Schema: public; Owner: mini1
--

CREATE INDEX task_linked_card_id_index ON public.task USING btree (linked_card_id);


--
-- Name: task_list_card_id_index; Type: INDEX; Schema: public; Owner: mini1
--

CREATE INDEX task_list_card_id_index ON public.task_list USING btree (card_id);


--
-- Name: task_list_position_index; Type: INDEX; Schema: public; Owner: mini1
--

CREATE INDEX task_list_position_index ON public.task_list USING btree ("position");


--
-- Name: task_position_index; Type: INDEX; Schema: public; Owner: mini1
--

CREATE INDEX task_position_index ON public.task USING btree ("position");


--
-- Name: task_task_list_id_index; Type: INDEX; Schema: public; Owner: mini1
--

CREATE INDEX task_task_list_id_index ON public.task USING btree (task_list_id);


--
-- Name: uploaded_file_references_total_index; Type: INDEX; Schema: public; Owner: mini1
--

CREATE INDEX uploaded_file_references_total_index ON public.uploaded_file USING btree (references_total);


--
-- Name: uploaded_file_type_index; Type: INDEX; Schema: public; Owner: mini1
--

CREATE INDEX uploaded_file_type_index ON public.uploaded_file USING btree (type);


--
-- Name: user_account_is_deactivated_index; Type: INDEX; Schema: public; Owner: mini1
--

CREATE INDEX user_account_is_deactivated_index ON public.user_account USING btree (is_deactivated);


--
-- Name: user_account_role_index; Type: INDEX; Schema: public; Owner: mini1
--

CREATE INDEX user_account_role_index ON public.user_account USING btree (role);


--
-- Name: user_account_username_index; Type: INDEX; Schema: public; Owner: mini1
--

CREATE INDEX user_account_username_index ON public.user_account USING btree (username);


--
-- Name: webhook_board_id_index; Type: INDEX; Schema: public; Owner: mini1
--

CREATE INDEX webhook_board_id_index ON public.webhook USING btree (board_id);


--
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: pg_database_owner
--

GRANT ALL ON SCHEMA public TO planka;


--
-- Name: TABLE action; Type: ACL; Schema: public; Owner: mini1
--

GRANT ALL ON TABLE public.action TO planka;
GRANT ALL ON TABLE public.action TO kanban_user;


--
-- Name: TABLE attachment; Type: ACL; Schema: public; Owner: mini1
--

GRANT ALL ON TABLE public.attachment TO planka;
GRANT ALL ON TABLE public.attachment TO kanban_user;


--
-- Name: TABLE background_image; Type: ACL; Schema: public; Owner: mini1
--

GRANT ALL ON TABLE public.background_image TO planka;
GRANT ALL ON TABLE public.background_image TO kanban_user;


--
-- Name: TABLE base_custom_field_group; Type: ACL; Schema: public; Owner: mini1
--

GRANT ALL ON TABLE public.base_custom_field_group TO planka;
GRANT ALL ON TABLE public.base_custom_field_group TO kanban_user;


--
-- Name: TABLE board; Type: ACL; Schema: public; Owner: mini1
--

GRANT ALL ON TABLE public.board TO planka;
GRANT ALL ON TABLE public.board TO kanban_user;


--
-- Name: TABLE board_membership; Type: ACL; Schema: public; Owner: mini1
--

GRANT ALL ON TABLE public.board_membership TO planka;
GRANT ALL ON TABLE public.board_membership TO kanban_user;


--
-- Name: TABLE board_subscription; Type: ACL; Schema: public; Owner: mini1
--

GRANT ALL ON TABLE public.board_subscription TO planka;
GRANT ALL ON TABLE public.board_subscription TO kanban_user;


--
-- Name: TABLE card; Type: ACL; Schema: public; Owner: mini1
--

GRANT ALL ON TABLE public.card TO planka;
GRANT ALL ON TABLE public.card TO kanban_user;


--
-- Name: TABLE card_label; Type: ACL; Schema: public; Owner: mini1
--

GRANT ALL ON TABLE public.card_label TO planka;
GRANT ALL ON TABLE public.card_label TO kanban_user;


--
-- Name: TABLE card_membership; Type: ACL; Schema: public; Owner: mini1
--

GRANT ALL ON TABLE public.card_membership TO planka;
GRANT ALL ON TABLE public.card_membership TO kanban_user;


--
-- Name: TABLE card_subscription; Type: ACL; Schema: public; Owner: mini1
--

GRANT ALL ON TABLE public.card_subscription TO planka;
GRANT ALL ON TABLE public.card_subscription TO kanban_user;


--
-- Name: TABLE comment; Type: ACL; Schema: public; Owner: mini1
--

GRANT ALL ON TABLE public.comment TO planka;
GRANT ALL ON TABLE public.comment TO kanban_user;


--
-- Name: TABLE config; Type: ACL; Schema: public; Owner: mini1
--

GRANT ALL ON TABLE public.config TO planka;
GRANT ALL ON TABLE public.config TO kanban_user;


--
-- Name: TABLE custom_field; Type: ACL; Schema: public; Owner: mini1
--

GRANT ALL ON TABLE public.custom_field TO planka;
GRANT ALL ON TABLE public.custom_field TO kanban_user;


--
-- Name: TABLE custom_field_group; Type: ACL; Schema: public; Owner: mini1
--

GRANT ALL ON TABLE public.custom_field_group TO planka;
GRANT ALL ON TABLE public.custom_field_group TO kanban_user;


--
-- Name: TABLE custom_field_value; Type: ACL; Schema: public; Owner: mini1
--

GRANT ALL ON TABLE public.custom_field_value TO planka;
GRANT ALL ON TABLE public.custom_field_value TO kanban_user;


--
-- Name: TABLE identity_provider_user; Type: ACL; Schema: public; Owner: mini1
--

GRANT ALL ON TABLE public.identity_provider_user TO planka;
GRANT ALL ON TABLE public.identity_provider_user TO kanban_user;


--
-- Name: TABLE label; Type: ACL; Schema: public; Owner: mini1
--

GRANT ALL ON TABLE public.label TO planka;
GRANT ALL ON TABLE public.label TO kanban_user;


--
-- Name: TABLE list; Type: ACL; Schema: public; Owner: mini1
--

GRANT ALL ON TABLE public.list TO planka;
GRANT ALL ON TABLE public.list TO kanban_user;


--
-- Name: TABLE migration; Type: ACL; Schema: public; Owner: mini1
--

GRANT ALL ON TABLE public.migration TO planka;
GRANT ALL ON TABLE public.migration TO kanban_user;


--
-- Name: SEQUENCE migration_id_seq; Type: ACL; Schema: public; Owner: mini1
--

GRANT ALL ON SEQUENCE public.migration_id_seq TO planka;
GRANT ALL ON SEQUENCE public.migration_id_seq TO kanban_user;


--
-- Name: TABLE migration_lock; Type: ACL; Schema: public; Owner: mini1
--

GRANT ALL ON TABLE public.migration_lock TO planka;
GRANT ALL ON TABLE public.migration_lock TO kanban_user;


--
-- Name: SEQUENCE migration_lock_index_seq; Type: ACL; Schema: public; Owner: mini1
--

GRANT ALL ON SEQUENCE public.migration_lock_index_seq TO planka;
GRANT ALL ON SEQUENCE public.migration_lock_index_seq TO kanban_user;


--
-- Name: SEQUENCE next_id_seq; Type: ACL; Schema: public; Owner: mini1
--

GRANT ALL ON SEQUENCE public.next_id_seq TO planka;
GRANT ALL ON SEQUENCE public.next_id_seq TO kanban_user;


--
-- Name: TABLE notification; Type: ACL; Schema: public; Owner: mini1
--

GRANT ALL ON TABLE public.notification TO planka;
GRANT ALL ON TABLE public.notification TO kanban_user;


--
-- Name: TABLE notification_service; Type: ACL; Schema: public; Owner: mini1
--

GRANT ALL ON TABLE public.notification_service TO planka;
GRANT ALL ON TABLE public.notification_service TO kanban_user;


--
-- Name: TABLE pg_stat_statements; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.pg_stat_statements TO planka;
GRANT ALL ON TABLE public.pg_stat_statements TO kanban_user;


--
-- Name: TABLE pg_stat_statements_info; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.pg_stat_statements_info TO planka;
GRANT ALL ON TABLE public.pg_stat_statements_info TO kanban_user;


--
-- Name: TABLE project; Type: ACL; Schema: public; Owner: mini1
--

GRANT ALL ON TABLE public.project TO planka;
GRANT ALL ON TABLE public.project TO kanban_user;


--
-- Name: TABLE project_favorite; Type: ACL; Schema: public; Owner: mini1
--

GRANT ALL ON TABLE public.project_favorite TO planka;
GRANT ALL ON TABLE public.project_favorite TO kanban_user;


--
-- Name: TABLE project_manager; Type: ACL; Schema: public; Owner: mini1
--

GRANT ALL ON TABLE public.project_manager TO planka;
GRANT ALL ON TABLE public.project_manager TO kanban_user;


--
-- Name: TABLE session; Type: ACL; Schema: public; Owner: mini1
--

GRANT ALL ON TABLE public.session TO planka;
GRANT ALL ON TABLE public.session TO kanban_user;


--
-- Name: TABLE storage_usage; Type: ACL; Schema: public; Owner: mini1
--

GRANT ALL ON TABLE public.storage_usage TO planka;
GRANT ALL ON TABLE public.storage_usage TO kanban_user;


--
-- Name: TABLE task; Type: ACL; Schema: public; Owner: mini1
--

GRANT ALL ON TABLE public.task TO planka;
GRANT ALL ON TABLE public.task TO kanban_user;


--
-- Name: TABLE task_list; Type: ACL; Schema: public; Owner: mini1
--

GRANT ALL ON TABLE public.task_list TO planka;
GRANT ALL ON TABLE public.task_list TO kanban_user;


--
-- Name: TABLE uploaded_file; Type: ACL; Schema: public; Owner: mini1
--

GRANT ALL ON TABLE public.uploaded_file TO planka;
GRANT ALL ON TABLE public.uploaded_file TO kanban_user;


--
-- Name: TABLE user_account; Type: ACL; Schema: public; Owner: mini1
--

GRANT ALL ON TABLE public.user_account TO planka;
GRANT ALL ON TABLE public.user_account TO kanban_user;


--
-- Name: TABLE webhook; Type: ACL; Schema: public; Owner: mini1
--

GRANT ALL ON TABLE public.webhook TO planka;
GRANT ALL ON TABLE public.webhook TO kanban_user;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: public; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON SEQUENCES TO kanban_user;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: public; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON TABLES TO kanban_user;


--
-- PostgreSQL database dump complete
--

\unrestrict bvkQRfmp0ajahdmgcz8cTEnTQbQ8d20yKt1ucltzy4hukO39KGReOkXKMALIWrd

