-- Create the roles 
CREATE ROLE backup;
CREATE ROLE clickhouse;
CREATE ROLE peerdb;
CREATE ROLE tickets;
CREATE ROLE votelistener;

--
-- PostgreSQL database dump
--

-- Dumped from database version 16.6 (Ubuntu 16.6-1.pgdg20.04+1)
-- Dumped by pg_dump version 16.6 (Ubuntu 16.6-1.pgdg20.04+1)

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
-- Name: public; Type: SCHEMA; Schema: -; Owner: postgres
--

-- *not* creating schema, since initdb creates it


ALTER SCHEMA public OWNER TO postgres;

--
-- Name: pg_stat_statements; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_stat_statements WITH SCHEMA public;


--
-- Name: EXTENSION pg_stat_statements; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pg_stat_statements IS 'track execution statistics of all SQL statements executed';


--
-- Name: pg_trgm; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_trgm WITH SCHEMA public;


--
-- Name: EXTENSION pg_trgm; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pg_trgm IS 'text similarity measurement and index searching based on trigrams';


--
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


--
-- Name: premium_source; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.premium_source AS ENUM (
    'discord',
    'patreon',
    'voting',
    'key'
);


ALTER TYPE public.premium_source OWNER TO postgres;

--
-- Name: premium_tier; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.premium_tier AS ENUM (
    'premium',
    'whitelabel'
);


ALTER TYPE public.premium_tier OWNER TO postgres;

--
-- Name: sku_type; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.sku_type AS ENUM (
    'subscription',
    'consumable',
    'durable'
);


ALTER TYPE public.sku_type OWNER TO postgres;

--
-- Name: ticket_status; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.ticket_status AS ENUM (
    'OPEN',
    'PENDING',
    'CLOSED'
);


ALTER TYPE public.ticket_status OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: active_language; Type: TABLE; Schema: public; Owner: tickets
--

CREATE TABLE public.active_language (
    guild_id bigint NOT NULL,
    language character varying(8) NOT NULL
);


ALTER TABLE public.active_language OWNER TO tickets;

--
-- Name: archive_channel; Type: TABLE; Schema: public; Owner: tickets
--

CREATE TABLE public.archive_channel (
    guild_id bigint NOT NULL,
    channel_id bigint
);


ALTER TABLE public.archive_channel OWNER TO tickets;

--
-- Name: archive_messages; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.archive_messages (
    guild_id bigint NOT NULL,
    ticket_id integer NOT NULL,
    channel_id bigint NOT NULL,
    message_id bigint NOT NULL
);


ALTER TABLE public.archive_messages OWNER TO postgres;

--
-- Name: auto_close; Type: TABLE; Schema: public; Owner: tickets
--

CREATE TABLE public.auto_close (
    guild_id bigint NOT NULL,
    enabled boolean NOT NULL,
    since_open_with_no_response interval,
    since_last_message interval,
    on_user_leave boolean
);


ALTER TABLE public.auto_close OWNER TO tickets;

--
-- Name: auto_close_exclude; Type: TABLE; Schema: public; Owner: tickets
--

CREATE TABLE public.auto_close_exclude (
    guild_id bigint NOT NULL,
    ticket_id integer NOT NULL
);


ALTER TABLE public.auto_close_exclude OWNER TO tickets;

--
-- Name: blacklist; Type: TABLE; Schema: public; Owner: tickets
--

CREATE TABLE public.blacklist (
    guild_id bigint NOT NULL,
    user_id bigint NOT NULL
);


ALTER TABLE public.blacklist OWNER TO tickets;

--
-- Name: bot_staff; Type: TABLE; Schema: public; Owner: tickets
--

CREATE TABLE public.bot_staff (
    user_id bigint NOT NULL
);


ALTER TABLE public.bot_staff OWNER TO tickets;

--
-- Name: category_update_queue; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.category_update_queue (
    guild_id bigint NOT NULL,
    ticket_id bigint NOT NULL,
    new_status public.ticket_status NOT NULL,
    status_changed_at timestamp with time zone NOT NULL
);


ALTER TABLE public.category_update_queue OWNER TO postgres;

--
-- Name: channel_category; Type: TABLE; Schema: public; Owner: tickets
--

CREATE TABLE public.channel_category (
    guild_id bigint NOT NULL,
    category_id bigint NOT NULL
);


ALTER TABLE public.channel_category OWNER TO tickets;

--
-- Name: claim_settings; Type: TABLE; Schema: public; Owner: tickets
--

CREATE TABLE public.claim_settings (
    guild_id bigint NOT NULL,
    support_can_view boolean NOT NULL,
    support_can_type boolean NOT NULL
);


ALTER TABLE public.claim_settings OWNER TO tickets;

--
-- Name: close_confirmation; Type: TABLE; Schema: public; Owner: tickets
--

CREATE TABLE public.close_confirmation (
    guild_id bigint NOT NULL,
    confirm boolean NOT NULL
);


ALTER TABLE public.close_confirmation OWNER TO tickets;

--
-- Name: close_reason; Type: TABLE; Schema: public; Owner: tickets
--

CREATE TABLE public.close_reason (
    guild_id bigint NOT NULL,
    ticket_id integer NOT NULL,
    close_reason text,
    closed_by bigint
);


ALTER TABLE public.close_reason OWNER TO tickets;

--
-- Name: close_request; Type: TABLE; Schema: public; Owner: tickets
--

CREATE TABLE public.close_request (
    guild_id bigint NOT NULL,
    ticket_id integer NOT NULL,
    user_id bigint NOT NULL,
    message_id bigint,
    close_at timestamp with time zone,
    close_reason character varying(255)
);


ALTER TABLE public.close_request OWNER TO tickets;

--
-- Name: tickets; Type: TABLE; Schema: public; Owner: tickets
--

CREATE TABLE public.tickets (
    id integer NOT NULL,
    guild_id bigint NOT NULL,
    channel_id bigint,
    user_id bigint NOT NULL,
    open boolean NOT NULL,
    open_time timestamp with time zone NOT NULL,
    welcome_message_id bigint,
    panel_id integer,
    has_transcript boolean DEFAULT false NOT NULL,
    close_time timestamp with time zone,
    join_message_id bigint,
    is_thread boolean DEFAULT false,
    notes_thread_id bigint,
    status public.ticket_status DEFAULT 'OPEN'::public.ticket_status NOT NULL
);


ALTER TABLE public.tickets OWNER TO tickets;

--
-- Name: counter_view; Type: VIEW; Schema: public; Owner: tickets
--

CREATE VIEW public.counter_view AS
 SELECT guild_id,
    (max(id) + 1) AS next_id
   FROM public.tickets
  GROUP BY guild_id;


ALTER VIEW public.counter_view OWNER TO tickets;

--
-- Name: custom_colours; Type: TABLE; Schema: public; Owner: tickets
--

CREATE TABLE public.custom_colours (
    guild_id bigint NOT NULL,
    colour_id smallint NOT NULL,
    colour_code integer NOT NULL
);


ALTER TABLE public.custom_colours OWNER TO tickets;

--
-- Name: custom_integration_guilds; Type: TABLE; Schema: public; Owner: tickets
--

CREATE TABLE public.custom_integration_guilds (
    integration_id integer NOT NULL,
    guild_id bigint NOT NULL
);


ALTER TABLE public.custom_integration_guilds OWNER TO tickets;

--
-- Name: custom_integration_guild_counts; Type: MATERIALIZED VIEW; Schema: public; Owner: tickets
--

CREATE MATERIALIZED VIEW public.custom_integration_guild_counts AS
 SELECT integration_id,
    count(*) AS count
   FROM public.custom_integration_guilds
  GROUP BY integration_id
  WITH NO DATA;


ALTER MATERIALIZED VIEW public.custom_integration_guild_counts OWNER TO tickets;

--
-- Name: custom_integration_headers; Type: TABLE; Schema: public; Owner: tickets
--

CREATE TABLE public.custom_integration_headers (
    id integer NOT NULL,
    integration_id integer NOT NULL,
    name character varying(32) NOT NULL,
    value character varying(255) NOT NULL
);


ALTER TABLE public.custom_integration_headers OWNER TO tickets;

--
-- Name: custom_integration_headers_id_seq; Type: SEQUENCE; Schema: public; Owner: tickets
--

CREATE SEQUENCE public.custom_integration_headers_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.custom_integration_headers_id_seq OWNER TO tickets;

--
-- Name: custom_integration_headers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: tickets
--

ALTER SEQUENCE public.custom_integration_headers_id_seq OWNED BY public.custom_integration_headers.id;


--
-- Name: custom_integration_placeholders; Type: TABLE; Schema: public; Owner: tickets
--

CREATE TABLE public.custom_integration_placeholders (
    id integer NOT NULL,
    integration_id integer NOT NULL,
    name character varying(32) NOT NULL,
    json_path character varying(255) NOT NULL
);


ALTER TABLE public.custom_integration_placeholders OWNER TO tickets;

--
-- Name: custom_integration_placeholders_id_seq; Type: SEQUENCE; Schema: public; Owner: tickets
--

CREATE SEQUENCE public.custom_integration_placeholders_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.custom_integration_placeholders_id_seq OWNER TO tickets;

--
-- Name: custom_integration_placeholders_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: tickets
--

ALTER SEQUENCE public.custom_integration_placeholders_id_seq OWNED BY public.custom_integration_placeholders.id;


--
-- Name: custom_integration_secret_values; Type: TABLE; Schema: public; Owner: tickets
--

CREATE TABLE public.custom_integration_secret_values (
    secret_id integer NOT NULL,
    integration_id integer NOT NULL,
    guild_id bigint NOT NULL,
    value character varying(255) NOT NULL
);


ALTER TABLE public.custom_integration_secret_values OWNER TO tickets;

--
-- Name: custom_integration_secret_values_secret_id_seq; Type: SEQUENCE; Schema: public; Owner: tickets
--

CREATE SEQUENCE public.custom_integration_secret_values_secret_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.custom_integration_secret_values_secret_id_seq OWNER TO tickets;

--
-- Name: custom_integration_secret_values_secret_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: tickets
--

ALTER SEQUENCE public.custom_integration_secret_values_secret_id_seq OWNED BY public.custom_integration_secret_values.secret_id;


--
-- Name: custom_integration_secrets; Type: TABLE; Schema: public; Owner: tickets
--

CREATE TABLE public.custom_integration_secrets (
    id integer NOT NULL,
    integration_id integer NOT NULL,
    name character varying(32) NOT NULL,
    description character varying(255)
);


ALTER TABLE public.custom_integration_secrets OWNER TO tickets;

--
-- Name: custom_integration_secrets_id_seq; Type: SEQUENCE; Schema: public; Owner: tickets
--

CREATE SEQUENCE public.custom_integration_secrets_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.custom_integration_secrets_id_seq OWNER TO tickets;

--
-- Name: custom_integration_secrets_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: tickets
--

ALTER SEQUENCE public.custom_integration_secrets_id_seq OWNED BY public.custom_integration_secrets.id;


--
-- Name: custom_integrations; Type: TABLE; Schema: public; Owner: tickets
--

CREATE TABLE public.custom_integrations (
    id integer NOT NULL,
    owner_id bigint NOT NULL,
    webhook_url character varying(255) NOT NULL,
    http_method character varying(4) NOT NULL,
    name character varying(32) NOT NULL,
    description character varying(255) NOT NULL,
    image_url character varying(255),
    privacy_policy_url character varying(255),
    public boolean DEFAULT false NOT NULL,
    approved boolean DEFAULT false NOT NULL,
    validation_url character varying(255) DEFAULT NULL::character varying
);


ALTER TABLE public.custom_integrations OWNER TO tickets;

--
-- Name: custom_integrations_id_seq; Type: SEQUENCE; Schema: public; Owner: tickets
--

CREATE SEQUENCE public.custom_integrations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.custom_integrations_id_seq OWNER TO tickets;

--
-- Name: custom_integrations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: tickets
--

ALTER SEQUENCE public.custom_integrations_id_seq OWNED BY public.custom_integrations.id;


--
-- Name: dashboard_users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.dashboard_users (
    user_id bigint NOT NULL,
    last_seen timestamp with time zone NOT NULL
);


ALTER TABLE public.dashboard_users OWNER TO postgres;

--
-- Name: discord_entitlements; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.discord_entitlements (
    discord_id bigint NOT NULL,
    entitlement_id uuid NOT NULL
);


ALTER TABLE public.discord_entitlements OWNER TO postgres;

--
-- Name: discord_store_skus; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.discord_store_skus (
    discord_id bigint NOT NULL,
    sku_id uuid NOT NULL
);


ALTER TABLE public.discord_store_skus OWNER TO postgres;

--
-- Name: dm_on_open; Type: TABLE; Schema: public; Owner: tickets
--

CREATE TABLE public.dm_on_open (
    guild_id bigint NOT NULL,
    dm_on_open boolean NOT NULL
);


ALTER TABLE public.dm_on_open OWNER TO tickets;

--
-- Name: embed_fields; Type: TABLE; Schema: public; Owner: tickets
--

CREATE TABLE public.embed_fields (
    id integer NOT NULL,
    embed_id integer NOT NULL,
    name character varying(255) NOT NULL,
    value text NOT NULL,
    inline boolean NOT NULL,
    CONSTRAINT value_length CHECK ((length(value) <= 1024))
);


ALTER TABLE public.embed_fields OWNER TO tickets;

--
-- Name: embed_fields_id_seq; Type: SEQUENCE; Schema: public; Owner: tickets
--

CREATE SEQUENCE public.embed_fields_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.embed_fields_id_seq OWNER TO tickets;

--
-- Name: embed_fields_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: tickets
--

ALTER SEQUENCE public.embed_fields_id_seq OWNED BY public.embed_fields.id;


--
-- Name: embeds; Type: TABLE; Schema: public; Owner: tickets
--

CREATE TABLE public.embeds (
    id integer NOT NULL,
    guild_id bigint NOT NULL,
    title character varying(255),
    description text,
    url character varying(255),
    colour integer DEFAULT 3066993 NOT NULL,
    author_name character varying(255),
    author_icon_url character varying(255),
    author_url character varying(255),
    image_url character varying(255),
    thumbnail_url character varying(255),
    footer_text text,
    footer_icon_url character varying(255),
    "timestamp" timestamp without time zone,
    CONSTRAINT colour_range CHECK (((colour >= 0) AND (colour <= 16777215))),
    CONSTRAINT description_length CHECK ((length(description) <= 4096)),
    CONSTRAINT footer_text_length CHECK ((length(footer_text) <= 2048))
);


ALTER TABLE public.embeds OWNER TO tickets;

--
-- Name: embeds_id_seq; Type: SEQUENCE; Schema: public; Owner: tickets
--

CREATE SEQUENCE public.embeds_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.embeds_id_seq OWNER TO tickets;

--
-- Name: embeds_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: tickets
--

ALTER SEQUENCE public.embeds_id_seq OWNED BY public.embeds.id;


--
-- Name: entitlements; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.entitlements (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    guild_id bigint,
    user_id bigint,
    sku_id uuid NOT NULL,
    source public.premium_source NOT NULL,
    expires_at timestamp with time zone
);


ALTER TABLE public.entitlements OWNER TO postgres;

--
-- Name: exit_survey_responses; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.exit_survey_responses (
    guild_id bigint NOT NULL,
    ticket_id integer NOT NULL,
    form_id integer,
    question_id integer NOT NULL,
    response text
);


ALTER TABLE public.exit_survey_responses OWNER TO postgres;

--
-- Name: feedback_enabled; Type: TABLE; Schema: public; Owner: tickets
--

CREATE TABLE public.feedback_enabled (
    guild_id bigint NOT NULL,
    feedback_enabled boolean NOT NULL
);


ALTER TABLE public.feedback_enabled OWNER TO tickets;

--
-- Name: first_response_time; Type: TABLE; Schema: public; Owner: tickets
--

CREATE TABLE public.first_response_time (
    guild_id bigint NOT NULL,
    ticket_id integer NOT NULL,
    user_id bigint NOT NULL,
    response_time interval NOT NULL
);


ALTER TABLE public.first_response_time OWNER TO tickets;

--
-- Name: first_response_time_export; Type: VIEW; Schema: public; Owner: tickets
--

CREATE VIEW public.first_response_time_export AS
 SELECT guild_id,
    ticket_id,
    user_id,
    (date_part('epoch'::text, response_time))::integer AS response_time_seconds
   FROM public.first_response_time;


ALTER VIEW public.first_response_time_export OWNER TO tickets;

--
-- Name: first_response_time_guild_view; Type: MATERIALIZED VIEW; Schema: public; Owner: tickets
--

CREATE MATERIALIZED VIEW public.first_response_time_guild_view AS
 SELECT first_response_time.guild_id,
    avg(first_response_time.response_time) AS all_time,
    avg(first_response_time.response_time) FILTER (WHERE (tickets.open_time > (now() - '30 days'::interval))) AS monthly,
    avg(first_response_time.response_time) FILTER (WHERE (tickets.open_time > (now() - '7 days'::interval))) AS weekly
   FROM (public.first_response_time
     JOIN public.tickets ON (((first_response_time.guild_id = tickets.guild_id) AND (first_response_time.ticket_id = tickets.id))))
  GROUP BY first_response_time.guild_id
  WITH NO DATA;


ALTER MATERIALIZED VIEW public.first_response_time_guild_view OWNER TO tickets;

--
-- Name: first_response_time_user_view; Type: MATERIALIZED VIEW; Schema: public; Owner: tickets
--

CREATE MATERIALIZED VIEW public.first_response_time_user_view AS
 SELECT first_response_time.guild_id,
    first_response_time.user_id,
    avg(first_response_time.response_time) AS all_time,
    avg(first_response_time.response_time) FILTER (WHERE (tickets.open_time > (now() - '30 days'::interval))) AS monthly,
    avg(first_response_time.response_time) FILTER (WHERE (tickets.open_time > (now() - '7 days'::interval))) AS weekly
   FROM (public.first_response_time
     JOIN public.tickets ON (((first_response_time.guild_id = tickets.guild_id) AND (first_response_time.ticket_id = tickets.id))))
  GROUP BY first_response_time.guild_id, first_response_time.user_id
  WITH NO DATA;


ALTER MATERIALIZED VIEW public.first_response_time_user_view OWNER TO tickets;

--
-- Name: form_input; Type: TABLE; Schema: public; Owner: tickets
--

CREATE TABLE public.form_input (
    id integer NOT NULL,
    form_id integer NOT NULL,
    custom_id character varying(100) NOT NULL,
    style smallint NOT NULL,
    label character varying(255) NOT NULL,
    placeholder character varying(100),
    required boolean DEFAULT true NOT NULL,
    "position" integer NOT NULL,
    min_length smallint,
    max_length smallint,
    CONSTRAINT check_position_max CHECK (("position" <= 5)),
    CONSTRAINT check_position_positive CHECK (("position" >= 1))
);


ALTER TABLE public.form_input OWNER TO tickets;

--
-- Name: form_input_id_seq; Type: SEQUENCE; Schema: public; Owner: tickets
--

CREATE SEQUENCE public.form_input_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.form_input_id_seq OWNER TO tickets;

--
-- Name: form_input_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: tickets
--

ALTER SEQUENCE public.form_input_id_seq OWNED BY public.form_input.id;


--
-- Name: forms; Type: TABLE; Schema: public; Owner: tickets
--

CREATE TABLE public.forms (
    form_id integer NOT NULL,
    guild_id bigint NOT NULL,
    title character varying(255) NOT NULL,
    custom_id character varying(100) NOT NULL
);


ALTER TABLE public.forms OWNER TO tickets;

--
-- Name: forms_form_id_seq; Type: SEQUENCE; Schema: public; Owner: tickets
--

CREATE SEQUENCE public.forms_form_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.forms_form_id_seq OWNER TO tickets;

--
-- Name: forms_form_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: tickets
--

ALTER SEQUENCE public.forms_form_id_seq OWNED BY public.forms.form_id;


--
-- Name: global_blacklist; Type: TABLE; Schema: public; Owner: tickets
--

CREATE TABLE public.global_blacklist (
    user_id bigint NOT NULL,
    reason character varying(255)
);


ALTER TABLE public.global_blacklist OWNER TO tickets;

--
-- Name: guild_leave_time; Type: TABLE; Schema: public; Owner: tickets
--

CREATE TABLE public.guild_leave_time (
    guild_id bigint NOT NULL,
    leave_time timestamp with time zone NOT NULL
);


ALTER TABLE public.guild_leave_time OWNER TO tickets;

--
-- Name: guild_metadata; Type: TABLE; Schema: public; Owner: tickets
--

CREATE TABLE public.guild_metadata (
    guild_id bigint NOT NULL,
    on_call_role bigint
);


ALTER TABLE public.guild_metadata OWNER TO tickets;

--
-- Name: legacy_premium_entitlement_guilds; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.legacy_premium_entitlement_guilds (
    user_id bigint NOT NULL,
    guild_id bigint NOT NULL,
    entitlement_id uuid NOT NULL
);


ALTER TABLE public.legacy_premium_entitlement_guilds OWNER TO postgres;

--
-- Name: legacy_premium_entitlements; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.legacy_premium_entitlements (
    user_id bigint NOT NULL,
    tier integer NOT NULL,
    sku_label character varying(255) NOT NULL,
    expires_at timestamp without time zone NOT NULL,
    is_legacy boolean NOT NULL,
    sku_id uuid NOT NULL
);


ALTER TABLE public.legacy_premium_entitlements OWNER TO postgres;

--
-- Name: modmail_archive; Type: TABLE; Schema: public; Owner: tickets
--

CREATE TABLE public.modmail_archive (
    uuid uuid NOT NULL,
    guild_id bigint NOT NULL,
    user_id bigint NOT NULL,
    close_time timestamp without time zone NOT NULL
);


ALTER TABLE public.modmail_archive OWNER TO tickets;

--
-- Name: modmail_enabled; Type: TABLE; Schema: public; Owner: tickets
--

CREATE TABLE public.modmail_enabled (
    guild_id bigint NOT NULL,
    enabled boolean NOT NULL
);


ALTER TABLE public.modmail_enabled OWNER TO tickets;

--
-- Name: modmail_forced_guilds; Type: TABLE; Schema: public; Owner: tickets
--

CREATE TABLE public.modmail_forced_guilds (
    bot_id bigint NOT NULL,
    guild_id bigint NOT NULL
);


ALTER TABLE public.modmail_forced_guilds OWNER TO tickets;

--
-- Name: modmail_sessions; Type: TABLE; Schema: public; Owner: tickets
--

CREATE TABLE public.modmail_sessions (
    uuid uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    guild_id bigint NOT NULL,
    bot_id bigint NOT NULL,
    user_id bigint NOT NULL,
    staff_channel bigint NOT NULL,
    welcome_message_id bigint NOT NULL
);


ALTER TABLE public.modmail_sessions OWNER TO tickets;

--
-- Name: modmail_webhooks; Type: TABLE; Schema: public; Owner: tickets
--

CREATE TABLE public.modmail_webhooks (
    uuid uuid NOT NULL,
    webhook_id bigint NOT NULL,
    webhook_token character varying(100) NOT NULL
);


ALTER TABLE public.modmail_webhooks OWNER TO tickets;

--
-- Name: multi_panel_targets; Type: TABLE; Schema: public; Owner: tickets
--

CREATE TABLE public.multi_panel_targets (
    multi_panel_id integer NOT NULL,
    panel_id integer NOT NULL
);


ALTER TABLE public.multi_panel_targets OWNER TO tickets;

--
-- Name: multi_panels; Type: TABLE; Schema: public; Owner: tickets
--

CREATE TABLE public.multi_panels (
    id integer NOT NULL,
    message_id bigint NOT NULL,
    channel_id bigint NOT NULL,
    guild_id bigint NOT NULL,
    title character varying(255),
    content text,
    colour integer,
    select_menu boolean DEFAULT false,
    image_url character varying(255) DEFAULT NULL::character varying,
    thumbnail_url character varying(255) DEFAULT NULL::character varying,
    embed jsonb,
    select_menu_placeholder character varying(150) DEFAULT NULL::character varying
);


ALTER TABLE public.multi_panels OWNER TO tickets;

--
-- Name: multi_panels_id_seq; Type: SEQUENCE; Schema: public; Owner: tickets
--

CREATE SEQUENCE public.multi_panels_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.multi_panels_id_seq OWNER TO tickets;

--
-- Name: multi_panels_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: tickets
--

ALTER SEQUENCE public.multi_panels_id_seq OWNED BY public.multi_panels.id;


--
-- Name: multi_server_skus; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.multi_server_skus (
    sku_id uuid NOT NULL,
    servers_permitted integer NOT NULL
);


ALTER TABLE public.multi_server_skus OWNER TO postgres;

--
-- Name: naming_scheme; Type: TABLE; Schema: public; Owner: tickets
--

CREATE TABLE public.naming_scheme (
    guild_id bigint NOT NULL,
    naming_scheme character varying(16) NOT NULL
);


ALTER TABLE public.naming_scheme OWNER TO tickets;

--
-- Name: on_call; Type: TABLE; Schema: public; Owner: tickets
--

CREATE TABLE public.on_call (
    guild_id bigint NOT NULL,
    user_id bigint NOT NULL,
    is_on_call boolean NOT NULL
);


ALTER TABLE public.on_call OWNER TO tickets;

--
-- Name: panel_access_control_rules; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.panel_access_control_rules (
    panel_id integer NOT NULL,
    role_id bigint NOT NULL,
    "position" integer NOT NULL,
    action character varying(5) NOT NULL
);


ALTER TABLE public.panel_access_control_rules OWNER TO postgres;

--
-- Name: panel_role_mentions; Type: TABLE; Schema: public; Owner: tickets
--

CREATE TABLE public.panel_role_mentions (
    role_id bigint NOT NULL,
    panel_id integer NOT NULL
);


ALTER TABLE public.panel_role_mentions OWNER TO tickets;

--
-- Name: panel_teams; Type: TABLE; Schema: public; Owner: tickets
--

CREATE TABLE public.panel_teams (
    team_id integer NOT NULL,
    panel_id integer NOT NULL
);


ALTER TABLE public.panel_teams OWNER TO tickets;

--
-- Name: panel_user_mentions; Type: TABLE; Schema: public; Owner: tickets
--

CREATE TABLE public.panel_user_mentions (
    should_mention_user boolean NOT NULL,
    panel_id integer NOT NULL
);


ALTER TABLE public.panel_user_mentions OWNER TO tickets;

--
-- Name: panels; Type: TABLE; Schema: public; Owner: tickets
--

CREATE TABLE public.panels (
    message_id bigint NOT NULL,
    channel_id bigint NOT NULL,
    guild_id bigint NOT NULL,
    title character varying(255) NOT NULL,
    content text NOT NULL,
    colour integer NOT NULL,
    target_category bigint NOT NULL,
    default_team boolean DEFAULT true NOT NULL,
    panel_id integer NOT NULL,
    custom_id character varying(100) DEFAULT ''::character varying NOT NULL,
    image_url character varying(255) DEFAULT NULL::character varying,
    thumbnail_url character varying(255) DEFAULT NULL::character varying,
    button_style smallint DEFAULT 1,
    form_id integer,
    button_label character varying(80) NOT NULL,
    emoji_name character varying(32) DEFAULT NULL::character varying,
    emoji_id bigint,
    naming_scheme character varying(100) DEFAULT NULL::character varying,
    welcome_message integer,
    force_disabled boolean DEFAULT false NOT NULL,
    disabled boolean DEFAULT false NOT NULL,
    exit_survey_form_id integer,
    pending_category bigint
);


ALTER TABLE public.panels OWNER TO tickets;

--
-- Name: panels_panel_id_seq; Type: SEQUENCE; Schema: public; Owner: tickets
--

CREATE SEQUENCE public.panels_panel_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.panels_panel_id_seq OWNER TO tickets;

--
-- Name: panels_panel_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: tickets
--

ALTER SEQUENCE public.panels_panel_id_seq OWNED BY public.panels.panel_id;


--
-- Name: participant; Type: TABLE; Schema: public; Owner: tickets
--

CREATE TABLE public.participant (
    guild_id bigint NOT NULL,
    ticket_id integer NOT NULL,
    user_id bigint NOT NULL
);


ALTER TABLE public.participant OWNER TO tickets;

--
-- Name: patreon_entitlements; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.patreon_entitlements (
    entitlement_id uuid NOT NULL,
    user_id bigint NOT NULL
);


ALTER TABLE public.patreon_entitlements OWNER TO postgres;

--
-- Name: permissions; Type: TABLE; Schema: public; Owner: tickets
--

CREATE TABLE public.permissions (
    guild_id bigint NOT NULL,
    user_id bigint NOT NULL,
    support boolean NOT NULL,
    admin boolean NOT NULL
);


ALTER TABLE public.permissions OWNER TO tickets;

--
-- Name: ping_everyone; Type: TABLE; Schema: public; Owner: tickets
--

CREATE TABLE public.ping_everyone (
    guild_id bigint NOT NULL,
    ping_everyone boolean NOT NULL
);


ALTER TABLE public.ping_everyone OWNER TO tickets;

--
-- Name: prefix; Type: TABLE; Schema: public; Owner: tickets
--

CREATE TABLE public.prefix (
    guild_id bigint NOT NULL,
    prefix character varying(8) NOT NULL
);


ALTER TABLE public.prefix OWNER TO tickets;

--
-- Name: premium_guilds; Type: TABLE; Schema: public; Owner: tickets
--

CREATE TABLE public.premium_guilds (
    guild_id bigint NOT NULL,
    expiry timestamp without time zone NOT NULL
);


ALTER TABLE public.premium_guilds OWNER TO tickets;

--
-- Name: premium_keys; Type: TABLE; Schema: public; Owner: tickets
--

CREATE TABLE public.premium_keys (
    key uuid NOT NULL,
    length interval NOT NULL,
    premium_type integer,
    sku_id uuid NOT NULL,
    generated_at timestamp with time zone NOT NULL
);


ALTER TABLE public.premium_keys OWNER TO tickets;

--
-- Name: role_blacklist; Type: TABLE; Schema: public; Owner: tickets
--

CREATE TABLE public.role_blacklist (
    guild_id bigint NOT NULL,
    role_id bigint NOT NULL
);


ALTER TABLE public.role_blacklist OWNER TO tickets;

--
-- Name: role_permissions; Type: TABLE; Schema: public; Owner: tickets
--

CREATE TABLE public.role_permissions (
    guild_id bigint NOT NULL,
    role_id bigint NOT NULL,
    support boolean NOT NULL,
    admin boolean NOT NULL,
    CONSTRAINT everyone_role_check CHECK ((role_id <> guild_id))
);


ALTER TABLE public.role_permissions OWNER TO tickets;

--
-- Name: server_blacklist; Type: TABLE; Schema: public; Owner: tickets
--

CREATE TABLE public.server_blacklist (
    guild_id bigint NOT NULL,
    reason character varying(255) DEFAULT NULL::character varying,
    blacklisted_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.server_blacklist OWNER TO tickets;

--
-- Name: service_ratings; Type: TABLE; Schema: public; Owner: tickets
--

CREATE TABLE public.service_ratings (
    guild_id bigint NOT NULL,
    ticket_id integer NOT NULL,
    rating smallint NOT NULL
);


ALTER TABLE public.service_ratings OWNER TO tickets;

--
-- Name: settings; Type: TABLE; Schema: public; Owner: tickets
--

CREATE TABLE public.settings (
    guild_id bigint NOT NULL,
    hide_claim_button boolean DEFAULT false,
    disable_open_command boolean DEFAULT false,
    context_menu_permission_level integer DEFAULT 0,
    context_menu_add_sender boolean DEFAULT true,
    context_menu_panel integer,
    store_transcripts boolean DEFAULT true,
    use_threads boolean DEFAULT false,
    thread_archive_duration integer DEFAULT 10080,
    overflow_enabled boolean DEFAULT false,
    overflow_category_id bigint,
    ticket_notification_channel bigint,
    anonymise_dashboard_responses boolean DEFAULT false NOT NULL,
    CONSTRAINT ticket_notification_channel_check CHECK (((use_threads = false) OR (ticket_notification_channel IS NOT NULL)))
);


ALTER TABLE public.settings OWNER TO tickets;

--
-- Name: skus; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.skus (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    label character varying(255) NOT NULL,
    type public.sku_type NOT NULL
);


ALTER TABLE public.skus OWNER TO postgres;

--
-- Name: staff_override; Type: TABLE; Schema: public; Owner: tickets
--

CREATE TABLE public.staff_override (
    guild_id bigint NOT NULL,
    expires timestamp with time zone NOT NULL
);


ALTER TABLE public.staff_override OWNER TO tickets;

--
-- Name: subscription_skus; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.subscription_skus (
    sku_id uuid NOT NULL,
    tier public.premium_tier NOT NULL,
    priority integer NOT NULL,
    is_global boolean DEFAULT false NOT NULL
);


ALTER TABLE public.subscription_skus OWNER TO postgres;

--
-- Name: support_team; Type: TABLE; Schema: public; Owner: tickets
--

CREATE TABLE public.support_team (
    id integer NOT NULL,
    guild_id bigint NOT NULL,
    name character varying(32) NOT NULL,
    on_call_role_id bigint
);


ALTER TABLE public.support_team OWNER TO tickets;

--
-- Name: support_team_id_seq; Type: SEQUENCE; Schema: public; Owner: tickets
--

CREATE SEQUENCE public.support_team_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.support_team_id_seq OWNER TO tickets;

--
-- Name: support_team_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: tickets
--

ALTER SEQUENCE public.support_team_id_seq OWNED BY public.support_team.id;


--
-- Name: support_team_members; Type: TABLE; Schema: public; Owner: tickets
--

CREATE TABLE public.support_team_members (
    team_id integer NOT NULL,
    user_id bigint NOT NULL
);


ALTER TABLE public.support_team_members OWNER TO tickets;

--
-- Name: support_team_roles; Type: TABLE; Schema: public; Owner: tickets
--

CREATE TABLE public.support_team_roles (
    team_id integer NOT NULL,
    role_id bigint NOT NULL
);


ALTER TABLE public.support_team_roles OWNER TO tickets;

--
-- Name: tags; Type: TABLE; Schema: public; Owner: tickets
--

CREATE TABLE public.tags (
    guild_id bigint NOT NULL,
    tag_id character varying(16) NOT NULL,
    content text,
    embed jsonb,
    application_command_id bigint,
    CONSTRAINT content_length CHECK ((length(content) <= 4096))
);


ALTER TABLE public.tags OWNER TO tickets;

--
-- Name: ticket_claims; Type: TABLE; Schema: public; Owner: tickets
--

CREATE TABLE public.ticket_claims (
    guild_id bigint NOT NULL,
    ticket_id integer NOT NULL,
    user_id bigint NOT NULL
);


ALTER TABLE public.ticket_claims OWNER TO tickets;

--
-- Name: ticket_duration; Type: MATERIALIZED VIEW; Schema: public; Owner: tickets
--

CREATE MATERIALIZED VIEW public.ticket_duration AS
 SELECT guild_id,
    avg((close_time - open_time)) AS all_time,
    avg((close_time - open_time)) FILTER (WHERE (close_time > (now() - '30 days'::interval))) AS monthly,
    avg((close_time - open_time)) FILTER (WHERE (close_time > (now() - '7 days'::interval))) AS weekly
   FROM public.tickets
  WHERE (close_time IS NOT NULL)
  GROUP BY guild_id
  WITH NO DATA;


ALTER MATERIALIZED VIEW public.ticket_duration OWNER TO tickets;

--
-- Name: ticket_last_message; Type: TABLE; Schema: public; Owner: tickets
--

CREATE TABLE public.ticket_last_message (
    guild_id bigint NOT NULL,
    ticket_id integer NOT NULL,
    last_message_id bigint,
    last_message_time timestamp with time zone,
    user_id bigint,
    user_is_staff boolean DEFAULT false NOT NULL
);


ALTER TABLE public.ticket_last_message OWNER TO tickets;

--
-- Name: ticket_limit; Type: TABLE; Schema: public; Owner: tickets
--

CREATE TABLE public.ticket_limit (
    guild_id bigint NOT NULL,
    "limit" smallint NOT NULL
);


ALTER TABLE public.ticket_limit OWNER TO tickets;

--
-- Name: ticket_members; Type: TABLE; Schema: public; Owner: tickets
--

CREATE TABLE public.ticket_members (
    guild_id bigint NOT NULL,
    ticket_id integer NOT NULL,
    user_id bigint NOT NULL
);


ALTER TABLE public.ticket_members OWNER TO tickets;

--
-- Name: ticket_permissions; Type: TABLE; Schema: public; Owner: tickets
--

CREATE TABLE public.ticket_permissions (
    guild_id bigint NOT NULL,
    attach_files boolean DEFAULT true NOT NULL,
    embed_links boolean DEFAULT true NOT NULL,
    add_reactions boolean DEFAULT true NOT NULL
);


ALTER TABLE public.ticket_permissions OWNER TO tickets;

--
-- Name: top_close_reasons; Type: MATERIALIZED VIEW; Schema: public; Owner: tickets
--

CREATE MATERIALIZED VIEW public.top_close_reasons AS
 SELECT guild_id,
    panel_id,
    close_reason,
    ranking
   FROM ( SELECT tickets.guild_id,
            tickets.panel_id,
            close_reason.close_reason,
            row_number() OVER (PARTITION BY tickets.guild_id, tickets.panel_id ORDER BY (count(*)) DESC) AS ranking
           FROM (public.close_reason
             JOIN public.tickets ON (((close_reason.guild_id = tickets.guild_id) AND (close_reason.ticket_id = tickets.id))))
          WHERE (close_reason.close_reason <> 'Automatically closed due to inactivity'::text)
          GROUP BY tickets.guild_id, tickets.panel_id, close_reason.close_reason) top_reasons_inner
  WHERE (ranking <= 10)
  WITH NO DATA;


ALTER MATERIALIZED VIEW public.top_close_reasons OWNER TO tickets;

--
-- Name: translations; Type: TABLE; Schema: public; Owner: tickets
--

CREATE TABLE public.translations (
    language character varying(8) NOT NULL,
    message_id integer NOT NULL,
    content text
);


ALTER TABLE public.translations OWNER TO tickets;

--
-- Name: used_keys; Type: TABLE; Schema: public; Owner: tickets
--

CREATE TABLE public.used_keys (
    key uuid NOT NULL,
    guild_id bigint NOT NULL,
    activated_by bigint NOT NULL
);


ALTER TABLE public.used_keys OWNER TO tickets;

--
-- Name: user_guilds; Type: TABLE; Schema: public; Owner: tickets
--

CREATE TABLE public.user_guilds (
    user_id bigint NOT NULL,
    guild_id bigint NOT NULL,
    name character varying(100) NOT NULL,
    owner boolean NOT NULL,
    permissions bigint NOT NULL,
    icon character varying(34)
);


ALTER TABLE public.user_guilds OWNER TO tickets;

--
-- Name: users_can_close; Type: TABLE; Schema: public; Owner: tickets
--

CREATE TABLE public.users_can_close (
    guild_id bigint NOT NULL,
    users_can_close boolean NOT NULL
);


ALTER TABLE public.users_can_close OWNER TO tickets;

--
-- Name: vote_credits; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.vote_credits (
    user_id bigint NOT NULL,
    credits integer DEFAULT 0 NOT NULL
);


ALTER TABLE public.vote_credits OWNER TO postgres;

--
-- Name: webhooks; Type: TABLE; Schema: public; Owner: tickets
--

CREATE TABLE public.webhooks (
    guild_id bigint NOT NULL,
    ticket_id integer NOT NULL,
    webhook_id bigint NOT NULL,
    webhook_token character varying(100) NOT NULL
);


ALTER TABLE public.webhooks OWNER TO tickets;

--
-- Name: welcome_messages; Type: TABLE; Schema: public; Owner: tickets
--

CREATE TABLE public.welcome_messages (
    guild_id bigint NOT NULL,
    welcome_message text NOT NULL
);


ALTER TABLE public.welcome_messages OWNER TO tickets;

--
-- Name: whitelabel; Type: TABLE; Schema: public; Owner: tickets
--

CREATE TABLE public.whitelabel (
    user_id bigint NOT NULL,
    bot_id bigint NOT NULL,
    token character varying(84) NOT NULL,
    public_key character(64) NOT NULL
);


ALTER TABLE public.whitelabel OWNER TO tickets;

--
-- Name: whitelabel_errors; Type: TABLE; Schema: public; Owner: tickets
--

CREATE TABLE public.whitelabel_errors (
    error_id integer NOT NULL,
    user_id bigint NOT NULL,
    error character varying(255) NOT NULL,
    error_time timestamp with time zone NOT NULL
);


ALTER TABLE public.whitelabel_errors OWNER TO tickets;

--
-- Name: whitelabel_errors_error_id_seq; Type: SEQUENCE; Schema: public; Owner: tickets
--

CREATE SEQUENCE public.whitelabel_errors_error_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.whitelabel_errors_error_id_seq OWNER TO tickets;

--
-- Name: whitelabel_errors_error_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: tickets
--

ALTER SEQUENCE public.whitelabel_errors_error_id_seq OWNED BY public.whitelabel_errors.error_id;


--
-- Name: whitelabel_guilds; Type: TABLE; Schema: public; Owner: tickets
--

CREATE TABLE public.whitelabel_guilds (
    bot_id bigint NOT NULL,
    guild_id bigint NOT NULL
);


ALTER TABLE public.whitelabel_guilds OWNER TO tickets;

--
-- Name: whitelabel_keys_remove; Type: TABLE; Schema: public; Owner: tickets
--

CREATE TABLE public.whitelabel_keys_remove (
    bot_id bigint NOT NULL,
    key character varying(64) NOT NULL
);


ALTER TABLE public.whitelabel_keys_remove OWNER TO tickets;

--
-- Name: whitelabel_skus; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.whitelabel_skus (
    sku_id uuid NOT NULL,
    bots_permitted integer NOT NULL,
    servers_per_bot_permitted integer
);


ALTER TABLE public.whitelabel_skus OWNER TO postgres;

--
-- Name: whitelabel_statuses; Type: TABLE; Schema: public; Owner: tickets
--

CREATE TABLE public.whitelabel_statuses (
    bot_id bigint NOT NULL,
    status character varying(255) NOT NULL,
    status_type smallint DEFAULT 2 NOT NULL
);


ALTER TABLE public.whitelabel_statuses OWNER TO tickets;

--
-- Name: whitelabel_users; Type: TABLE; Schema: public; Owner: tickets
--

CREATE TABLE public.whitelabel_users (
    user_id bigint NOT NULL,
    expiry timestamp without time zone NOT NULL
);


ALTER TABLE public.whitelabel_users OWNER TO tickets;

--
-- Name: custom_integration_headers id; Type: DEFAULT; Schema: public; Owner: tickets
--

ALTER TABLE ONLY public.custom_integration_headers ALTER COLUMN id SET DEFAULT nextval('public.custom_integration_headers_id_seq'::regclass);


--
-- Name: custom_integration_placeholders id; Type: DEFAULT; Schema: public; Owner: tickets
--

ALTER TABLE ONLY public.custom_integration_placeholders ALTER COLUMN id SET DEFAULT nextval('public.custom_integration_placeholders_id_seq'::regclass);


--
-- Name: custom_integration_secret_values secret_id; Type: DEFAULT; Schema: public; Owner: tickets
--

ALTER TABLE ONLY public.custom_integration_secret_values ALTER COLUMN secret_id SET DEFAULT nextval('public.custom_integration_secret_values_secret_id_seq'::regclass);


--
-- Name: custom_integration_secrets id; Type: DEFAULT; Schema: public; Owner: tickets
--

ALTER TABLE ONLY public.custom_integration_secrets ALTER COLUMN id SET DEFAULT nextval('public.custom_integration_secrets_id_seq'::regclass);


--
-- Name: custom_integrations id; Type: DEFAULT; Schema: public; Owner: tickets
--

ALTER TABLE ONLY public.custom_integrations ALTER COLUMN id SET DEFAULT nextval('public.custom_integrations_id_seq'::regclass);


--
-- Name: embed_fields id; Type: DEFAULT; Schema: public; Owner: tickets
--

ALTER TABLE ONLY public.embed_fields ALTER COLUMN id SET DEFAULT nextval('public.embed_fields_id_seq'::regclass);


--
-- Name: embeds id; Type: DEFAULT; Schema: public; Owner: tickets
--

ALTER TABLE ONLY public.embeds ALTER COLUMN id SET DEFAULT nextval('public.embeds_id_seq'::regclass);


--
-- Name: form_input id; Type: DEFAULT; Schema: public; Owner: tickets
--

ALTER TABLE ONLY public.form_input ALTER COLUMN id SET DEFAULT nextval('public.form_input_id_seq'::regclass);


--
-- Name: forms form_id; Type: DEFAULT; Schema: public; Owner: tickets
--

ALTER TABLE ONLY public.forms ALTER COLUMN form_id SET DEFAULT nextval('public.forms_form_id_seq'::regclass);


--
-- Name: multi_panels id; Type: DEFAULT; Schema: public; Owner: tickets
--

ALTER TABLE ONLY public.multi_panels ALTER COLUMN id SET DEFAULT nextval('public.multi_panels_id_seq'::regclass);


--
-- Name: panels panel_id; Type: DEFAULT; Schema: public; Owner: tickets
--

ALTER TABLE ONLY public.panels ALTER COLUMN panel_id SET DEFAULT nextval('public.panels_panel_id_seq'::regclass);


--
-- Name: support_team id; Type: DEFAULT; Schema: public; Owner: tickets
--

ALTER TABLE ONLY public.support_team ALTER COLUMN id SET DEFAULT nextval('public.support_team_id_seq'::regclass);


--
-- Name: whitelabel_errors error_id; Type: DEFAULT; Schema: public; Owner: tickets
--

ALTER TABLE ONLY public.whitelabel_errors ALTER COLUMN error_id SET DEFAULT nextval('public.whitelabel_errors_error_id_seq'::regclass);


--
-- Name: active_language active_language_pkey; Type: CONSTRAINT; Schema: public; Owner: tickets
--

ALTER TABLE ONLY public.active_language
    ADD CONSTRAINT active_language_pkey PRIMARY KEY (guild_id);


--
-- Name: archive_channel archive_channel_pkey; Type: CONSTRAINT; Schema: public; Owner: tickets
--

ALTER TABLE ONLY public.archive_channel
    ADD CONSTRAINT archive_channel_pkey PRIMARY KEY (guild_id);


--
-- Name: archive_messages archive_messages_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.archive_messages
    ADD CONSTRAINT archive_messages_pkey PRIMARY KEY (guild_id, ticket_id);


--
-- Name: auto_close_exclude auto_close_exclude_pkey; Type: CONSTRAINT; Schema: public; Owner: tickets
--

ALTER TABLE ONLY public.auto_close_exclude
    ADD CONSTRAINT auto_close_exclude_pkey PRIMARY KEY (guild_id, ticket_id);


--
-- Name: auto_close auto_close_pkey; Type: CONSTRAINT; Schema: public; Owner: tickets
--

ALTER TABLE ONLY public.auto_close
    ADD CONSTRAINT auto_close_pkey PRIMARY KEY (guild_id);


--
-- Name: blacklist blacklist_pkey; Type: CONSTRAINT; Schema: public; Owner: tickets
--

ALTER TABLE ONLY public.blacklist
    ADD CONSTRAINT blacklist_pkey PRIMARY KEY (guild_id, user_id);


--
-- Name: bot_staff bot_staff_pkey; Type: CONSTRAINT; Schema: public; Owner: tickets
--

ALTER TABLE ONLY public.bot_staff
    ADD CONSTRAINT bot_staff_pkey PRIMARY KEY (user_id);


--
-- Name: category_update_queue category_update_queue_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.category_update_queue
    ADD CONSTRAINT category_update_queue_pkey PRIMARY KEY (guild_id, ticket_id);


--
-- Name: channel_category channel_category_category_id_key; Type: CONSTRAINT; Schema: public; Owner: tickets
--

ALTER TABLE ONLY public.channel_category
    ADD CONSTRAINT channel_category_category_id_key UNIQUE (category_id);


--
-- Name: channel_category channel_category_pkey; Type: CONSTRAINT; Schema: public; Owner: tickets
--

ALTER TABLE ONLY public.channel_category
    ADD CONSTRAINT channel_category_pkey PRIMARY KEY (guild_id);


--
-- Name: claim_settings claim_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: tickets
--

ALTER TABLE ONLY public.claim_settings
    ADD CONSTRAINT claim_settings_pkey PRIMARY KEY (guild_id);


--
-- Name: close_confirmation close_confirmation_pkey; Type: CONSTRAINT; Schema: public; Owner: tickets
--

ALTER TABLE ONLY public.close_confirmation
    ADD CONSTRAINT close_confirmation_pkey PRIMARY KEY (guild_id);


--
-- Name: close_reason close_reason_pkey; Type: CONSTRAINT; Schema: public; Owner: tickets
--

ALTER TABLE ONLY public.close_reason
    ADD CONSTRAINT close_reason_pkey PRIMARY KEY (guild_id, ticket_id);


--
-- Name: close_request close_request_pkey; Type: CONSTRAINT; Schema: public; Owner: tickets
--

ALTER TABLE ONLY public.close_request
    ADD CONSTRAINT close_request_pkey PRIMARY KEY (guild_id, ticket_id);


--
-- Name: custom_colours custom_colours_pkey; Type: CONSTRAINT; Schema: public; Owner: tickets
--

ALTER TABLE ONLY public.custom_colours
    ADD CONSTRAINT custom_colours_pkey PRIMARY KEY (guild_id, colour_id);


--
-- Name: custom_integration_guilds custom_integration_guilds_pkey; Type: CONSTRAINT; Schema: public; Owner: tickets
--

ALTER TABLE ONLY public.custom_integration_guilds
    ADD CONSTRAINT custom_integration_guilds_pkey PRIMARY KEY (integration_id, guild_id);


--
-- Name: custom_integration_headers custom_integration_headers_integration_id_name_key; Type: CONSTRAINT; Schema: public; Owner: tickets
--

ALTER TABLE ONLY public.custom_integration_headers
    ADD CONSTRAINT custom_integration_headers_integration_id_name_key UNIQUE (integration_id, name);


--
-- Name: custom_integration_headers custom_integration_headers_pkey; Type: CONSTRAINT; Schema: public; Owner: tickets
--

ALTER TABLE ONLY public.custom_integration_headers
    ADD CONSTRAINT custom_integration_headers_pkey PRIMARY KEY (id);


--
-- Name: custom_integration_placeholders custom_integration_placeholders_integration_id_name_key; Type: CONSTRAINT; Schema: public; Owner: tickets
--

ALTER TABLE ONLY public.custom_integration_placeholders
    ADD CONSTRAINT custom_integration_placeholders_integration_id_name_key UNIQUE (integration_id, name);


--
-- Name: custom_integration_placeholders custom_integration_placeholders_pkey; Type: CONSTRAINT; Schema: public; Owner: tickets
--

ALTER TABLE ONLY public.custom_integration_placeholders
    ADD CONSTRAINT custom_integration_placeholders_pkey PRIMARY KEY (id);


--
-- Name: custom_integration_secret_values custom_integration_secret_values_pkey; Type: CONSTRAINT; Schema: public; Owner: tickets
--

ALTER TABLE ONLY public.custom_integration_secret_values
    ADD CONSTRAINT custom_integration_secret_values_pkey PRIMARY KEY (secret_id, guild_id);


--
-- Name: custom_integration_secrets custom_integration_secrets_integration_id_name_key; Type: CONSTRAINT; Schema: public; Owner: tickets
--

ALTER TABLE ONLY public.custom_integration_secrets
    ADD CONSTRAINT custom_integration_secrets_integration_id_name_key UNIQUE (integration_id, name);


--
-- Name: custom_integration_secrets custom_integration_secrets_pkey; Type: CONSTRAINT; Schema: public; Owner: tickets
--

ALTER TABLE ONLY public.custom_integration_secrets
    ADD CONSTRAINT custom_integration_secrets_pkey PRIMARY KEY (id);


--
-- Name: custom_integrations custom_integrations_pkey; Type: CONSTRAINT; Schema: public; Owner: tickets
--

ALTER TABLE ONLY public.custom_integrations
    ADD CONSTRAINT custom_integrations_pkey PRIMARY KEY (id);


--
-- Name: dashboard_users dashboard_users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dashboard_users
    ADD CONSTRAINT dashboard_users_pkey PRIMARY KEY (user_id);


--
-- Name: discord_entitlements discord_entitlements_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.discord_entitlements
    ADD CONSTRAINT discord_entitlements_pkey PRIMARY KEY (discord_id);


--
-- Name: discord_store_skus discord_store_skus_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.discord_store_skus
    ADD CONSTRAINT discord_store_skus_pkey PRIMARY KEY (discord_id);


--
-- Name: dm_on_open dm_on_open_pkey; Type: CONSTRAINT; Schema: public; Owner: tickets
--

ALTER TABLE ONLY public.dm_on_open
    ADD CONSTRAINT dm_on_open_pkey PRIMARY KEY (guild_id);


--
-- Name: embed_fields embed_fields_pkey; Type: CONSTRAINT; Schema: public; Owner: tickets
--

ALTER TABLE ONLY public.embed_fields
    ADD CONSTRAINT embed_fields_pkey PRIMARY KEY (id);


--
-- Name: embeds embeds_pkey; Type: CONSTRAINT; Schema: public; Owner: tickets
--

ALTER TABLE ONLY public.embeds
    ADD CONSTRAINT embeds_pkey PRIMARY KEY (id);


--
-- Name: entitlements entitlements_guild_id_user_id_sku_id_source_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.entitlements
    ADD CONSTRAINT entitlements_guild_id_user_id_sku_id_source_key UNIQUE NULLS NOT DISTINCT (guild_id, user_id, sku_id, source);


--
-- Name: entitlements entitlements_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.entitlements
    ADD CONSTRAINT entitlements_pkey PRIMARY KEY (id);


--
-- Name: exit_survey_responses exit_survey_responses_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.exit_survey_responses
    ADD CONSTRAINT exit_survey_responses_pkey PRIMARY KEY (guild_id, ticket_id, question_id);


--
-- Name: feedback_enabled feedback_enabled_pkey; Type: CONSTRAINT; Schema: public; Owner: tickets
--

ALTER TABLE ONLY public.feedback_enabled
    ADD CONSTRAINT feedback_enabled_pkey PRIMARY KEY (guild_id);


--
-- Name: first_response_time first_response_time_pkey; Type: CONSTRAINT; Schema: public; Owner: tickets
--

ALTER TABLE ONLY public.first_response_time
    ADD CONSTRAINT first_response_time_pkey PRIMARY KEY (guild_id, ticket_id);


--
-- Name: form_input form_input_custom_id_key; Type: CONSTRAINT; Schema: public; Owner: tickets
--

ALTER TABLE ONLY public.form_input
    ADD CONSTRAINT form_input_custom_id_key UNIQUE (custom_id);


--
-- Name: form_input form_input_pkey; Type: CONSTRAINT; Schema: public; Owner: tickets
--

ALTER TABLE ONLY public.form_input
    ADD CONSTRAINT form_input_pkey PRIMARY KEY (id);


--
-- Name: forms forms_custom_id_key; Type: CONSTRAINT; Schema: public; Owner: tickets
--

ALTER TABLE ONLY public.forms
    ADD CONSTRAINT forms_custom_id_key UNIQUE (custom_id);


--
-- Name: forms forms_pkey; Type: CONSTRAINT; Schema: public; Owner: tickets
--

ALTER TABLE ONLY public.forms
    ADD CONSTRAINT forms_pkey PRIMARY KEY (form_id);


--
-- Name: global_blacklist global_blacklist_pkey; Type: CONSTRAINT; Schema: public; Owner: tickets
--

ALTER TABLE ONLY public.global_blacklist
    ADD CONSTRAINT global_blacklist_pkey PRIMARY KEY (user_id);


--
-- Name: guild_leave_time guild_leave_time_pkey; Type: CONSTRAINT; Schema: public; Owner: tickets
--

ALTER TABLE ONLY public.guild_leave_time
    ADD CONSTRAINT guild_leave_time_pkey PRIMARY KEY (guild_id);


--
-- Name: guild_metadata guild_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: tickets
--

ALTER TABLE ONLY public.guild_metadata
    ADD CONSTRAINT guild_metadata_pkey PRIMARY KEY (guild_id);


--
-- Name: legacy_premium_entitlement_guilds legacy_premium_entitlement_guilds_entitlement_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.legacy_premium_entitlement_guilds
    ADD CONSTRAINT legacy_premium_entitlement_guilds_entitlement_id_key UNIQUE (entitlement_id);


--
-- Name: legacy_premium_entitlement_guilds legacy_premium_entitlement_guilds_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.legacy_premium_entitlement_guilds
    ADD CONSTRAINT legacy_premium_entitlement_guilds_pkey PRIMARY KEY (user_id, guild_id);


--
-- Name: legacy_premium_entitlements legacy_premium_entitlements_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.legacy_premium_entitlements
    ADD CONSTRAINT legacy_premium_entitlements_pkey PRIMARY KEY (user_id);


--
-- Name: panels message_id_unique; Type: CONSTRAINT; Schema: public; Owner: tickets
--

ALTER TABLE ONLY public.panels
    ADD CONSTRAINT message_id_unique UNIQUE (message_id);


--
-- Name: modmail_archive modmail_archive_pkey; Type: CONSTRAINT; Schema: public; Owner: tickets
--

ALTER TABLE ONLY public.modmail_archive
    ADD CONSTRAINT modmail_archive_pkey PRIMARY KEY (uuid);


--
-- Name: modmail_enabled modmail_enabled_pkey; Type: CONSTRAINT; Schema: public; Owner: tickets
--

ALTER TABLE ONLY public.modmail_enabled
    ADD CONSTRAINT modmail_enabled_pkey PRIMARY KEY (guild_id);


--
-- Name: modmail_forced_guilds modmail_forced_guilds_pkey; Type: CONSTRAINT; Schema: public; Owner: tickets
--

ALTER TABLE ONLY public.modmail_forced_guilds
    ADD CONSTRAINT modmail_forced_guilds_pkey PRIMARY KEY (bot_id);


--
-- Name: modmail_sessions modmail_sessions_bot_id_user_id_key; Type: CONSTRAINT; Schema: public; Owner: tickets
--

ALTER TABLE ONLY public.modmail_sessions
    ADD CONSTRAINT modmail_sessions_bot_id_user_id_key UNIQUE (bot_id, user_id);


--
-- Name: modmail_sessions modmail_sessions_pkey1; Type: CONSTRAINT; Schema: public; Owner: tickets
--

ALTER TABLE ONLY public.modmail_sessions
    ADD CONSTRAINT modmail_sessions_pkey1 PRIMARY KEY (uuid);


--
-- Name: modmail_sessions modmail_sessions_staff_channel_key1; Type: CONSTRAINT; Schema: public; Owner: tickets
--

ALTER TABLE ONLY public.modmail_sessions
    ADD CONSTRAINT modmail_sessions_staff_channel_key1 UNIQUE (staff_channel);


--
-- Name: modmail_sessions modmail_sessions_welcome_message_id_key1; Type: CONSTRAINT; Schema: public; Owner: tickets
--

ALTER TABLE ONLY public.modmail_sessions
    ADD CONSTRAINT modmail_sessions_welcome_message_id_key1 UNIQUE (welcome_message_id);


--
-- Name: modmail_webhooks modmail_webhooks_pkey; Type: CONSTRAINT; Schema: public; Owner: tickets
--

ALTER TABLE ONLY public.modmail_webhooks
    ADD CONSTRAINT modmail_webhooks_pkey PRIMARY KEY (uuid);


--
-- Name: modmail_webhooks modmail_webhooks_webhook_id_key; Type: CONSTRAINT; Schema: public; Owner: tickets
--

ALTER TABLE ONLY public.modmail_webhooks
    ADD CONSTRAINT modmail_webhooks_webhook_id_key UNIQUE (webhook_id);


--
-- Name: multi_panel_targets multi_panel_targets_pkey; Type: CONSTRAINT; Schema: public; Owner: tickets
--

ALTER TABLE ONLY public.multi_panel_targets
    ADD CONSTRAINT multi_panel_targets_pkey PRIMARY KEY (multi_panel_id, panel_id);


--
-- Name: multi_panels multi_panels_pkey; Type: CONSTRAINT; Schema: public; Owner: tickets
--

ALTER TABLE ONLY public.multi_panels
    ADD CONSTRAINT multi_panels_pkey PRIMARY KEY (id);


--
-- Name: multi_server_skus multi_server_skus_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.multi_server_skus
    ADD CONSTRAINT multi_server_skus_pkey PRIMARY KEY (sku_id);


--
-- Name: naming_scheme naming_scheme_pkey; Type: CONSTRAINT; Schema: public; Owner: tickets
--

ALTER TABLE ONLY public.naming_scheme
    ADD CONSTRAINT naming_scheme_pkey PRIMARY KEY (guild_id);


--
-- Name: on_call on_call_pkey; Type: CONSTRAINT; Schema: public; Owner: tickets
--

ALTER TABLE ONLY public.on_call
    ADD CONSTRAINT on_call_pkey PRIMARY KEY (guild_id, user_id);


--
-- Name: panel_access_control_rules panel_access_control_rules_panel_id_position_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.panel_access_control_rules
    ADD CONSTRAINT panel_access_control_rules_panel_id_position_key UNIQUE (panel_id, "position");


--
-- Name: panel_access_control_rules panel_access_control_rules_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.panel_access_control_rules
    ADD CONSTRAINT panel_access_control_rules_pkey PRIMARY KEY (panel_id, role_id);


--
-- Name: panel_user_mentions panel_id_key; Type: CONSTRAINT; Schema: public; Owner: tickets
--

ALTER TABLE ONLY public.panel_user_mentions
    ADD CONSTRAINT panel_id_key UNIQUE (panel_id);


--
-- Name: panel_role_mentions panel_role_mentions_key; Type: CONSTRAINT; Schema: public; Owner: tickets
--

ALTER TABLE ONLY public.panel_role_mentions
    ADD CONSTRAINT panel_role_mentions_key UNIQUE (panel_id, role_id);


--
-- Name: panel_role_mentions panel_role_mentions_pkey; Type: CONSTRAINT; Schema: public; Owner: tickets
--

ALTER TABLE ONLY public.panel_role_mentions
    ADD CONSTRAINT panel_role_mentions_pkey PRIMARY KEY (panel_id, role_id);


--
-- Name: panel_teams panel_teams_pkey; Type: CONSTRAINT; Schema: public; Owner: tickets
--

ALTER TABLE ONLY public.panel_teams
    ADD CONSTRAINT panel_teams_pkey PRIMARY KEY (panel_id, team_id);


--
-- Name: panel_user_mentions panel_user_mentions_pkey; Type: CONSTRAINT; Schema: public; Owner: tickets
--

ALTER TABLE ONLY public.panel_user_mentions
    ADD CONSTRAINT panel_user_mentions_pkey PRIMARY KEY (panel_id);


--
-- Name: panels panels_panel_id_key; Type: CONSTRAINT; Schema: public; Owner: tickets
--

ALTER TABLE ONLY public.panels
    ADD CONSTRAINT panels_panel_id_key UNIQUE (panel_id);


--
-- Name: panels panels_pkey; Type: CONSTRAINT; Schema: public; Owner: tickets
--

ALTER TABLE ONLY public.panels
    ADD CONSTRAINT panels_pkey PRIMARY KEY (panel_id);


--
-- Name: participant participant_pkey; Type: CONSTRAINT; Schema: public; Owner: tickets
--

ALTER TABLE ONLY public.participant
    ADD CONSTRAINT participant_pkey PRIMARY KEY (guild_id, ticket_id, user_id);


--
-- Name: patreon_entitlements patreon_entitlements_entitlement_id_user_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patreon_entitlements
    ADD CONSTRAINT patreon_entitlements_entitlement_id_user_id_key UNIQUE (entitlement_id, user_id);


--
-- Name: patreon_entitlements patreon_entitlements_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patreon_entitlements
    ADD CONSTRAINT patreon_entitlements_pkey PRIMARY KEY (entitlement_id);


--
-- Name: patreon_entitlements patreon_entitlements_user_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patreon_entitlements
    ADD CONSTRAINT patreon_entitlements_user_id_key UNIQUE (user_id);


--
-- Name: permissions permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: tickets
--

ALTER TABLE ONLY public.permissions
    ADD CONSTRAINT permissions_pkey PRIMARY KEY (guild_id, user_id);


--
-- Name: ping_everyone ping_everyone_pkey; Type: CONSTRAINT; Schema: public; Owner: tickets
--

ALTER TABLE ONLY public.ping_everyone
    ADD CONSTRAINT ping_everyone_pkey PRIMARY KEY (guild_id);


--
-- Name: form_input position_unique; Type: CONSTRAINT; Schema: public; Owner: tickets
--

ALTER TABLE ONLY public.form_input
    ADD CONSTRAINT position_unique UNIQUE (form_id, "position") DEFERRABLE INITIALLY DEFERRED;


--
-- Name: prefix prefix_pkey; Type: CONSTRAINT; Schema: public; Owner: tickets
--

ALTER TABLE ONLY public.prefix
    ADD CONSTRAINT prefix_pkey PRIMARY KEY (guild_id);


--
-- Name: premium_guilds premium_guilds_pkey; Type: CONSTRAINT; Schema: public; Owner: tickets
--

ALTER TABLE ONLY public.premium_guilds
    ADD CONSTRAINT premium_guilds_pkey PRIMARY KEY (guild_id);


--
-- Name: premium_keys premium_keys_pkey; Type: CONSTRAINT; Schema: public; Owner: tickets
--

ALTER TABLE ONLY public.premium_keys
    ADD CONSTRAINT premium_keys_pkey PRIMARY KEY (key);


--
-- Name: role_blacklist role_blacklist_pkey; Type: CONSTRAINT; Schema: public; Owner: tickets
--

ALTER TABLE ONLY public.role_blacklist
    ADD CONSTRAINT role_blacklist_pkey PRIMARY KEY (guild_id, role_id);


--
-- Name: role_permissions role_permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: tickets
--

ALTER TABLE ONLY public.role_permissions
    ADD CONSTRAINT role_permissions_pkey PRIMARY KEY (role_id);


--
-- Name: server_blacklist server_blacklist_pkey; Type: CONSTRAINT; Schema: public; Owner: tickets
--

ALTER TABLE ONLY public.server_blacklist
    ADD CONSTRAINT server_blacklist_pkey PRIMARY KEY (guild_id);


--
-- Name: service_ratings service_ratings_pkey; Type: CONSTRAINT; Schema: public; Owner: tickets
--

ALTER TABLE ONLY public.service_ratings
    ADD CONSTRAINT service_ratings_pkey PRIMARY KEY (guild_id, ticket_id);


--
-- Name: settings settings_pkey; Type: CONSTRAINT; Schema: public; Owner: tickets
--

ALTER TABLE ONLY public.settings
    ADD CONSTRAINT settings_pkey PRIMARY KEY (guild_id);


--
-- Name: skus skus_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.skus
    ADD CONSTRAINT skus_pkey PRIMARY KEY (id);


--
-- Name: staff_override staff_override_pkey; Type: CONSTRAINT; Schema: public; Owner: tickets
--

ALTER TABLE ONLY public.staff_override
    ADD CONSTRAINT staff_override_pkey PRIMARY KEY (guild_id);


--
-- Name: subscription_skus subscription_skus_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.subscription_skus
    ADD CONSTRAINT subscription_skus_pkey PRIMARY KEY (sku_id);


--
-- Name: support_team support_team_guild_id_name_key; Type: CONSTRAINT; Schema: public; Owner: tickets
--

ALTER TABLE ONLY public.support_team
    ADD CONSTRAINT support_team_guild_id_name_key UNIQUE (guild_id, name);


--
-- Name: support_team_members support_team_members_pkey; Type: CONSTRAINT; Schema: public; Owner: tickets
--

ALTER TABLE ONLY public.support_team_members
    ADD CONSTRAINT support_team_members_pkey PRIMARY KEY (team_id, user_id);


--
-- Name: support_team support_team_on_call_role_id_key; Type: CONSTRAINT; Schema: public; Owner: tickets
--

ALTER TABLE ONLY public.support_team
    ADD CONSTRAINT support_team_on_call_role_id_key UNIQUE (on_call_role_id);


--
-- Name: support_team support_team_pkey; Type: CONSTRAINT; Schema: public; Owner: tickets
--

ALTER TABLE ONLY public.support_team
    ADD CONSTRAINT support_team_pkey PRIMARY KEY (id);


--
-- Name: support_team_roles support_team_roles_pkey; Type: CONSTRAINT; Schema: public; Owner: tickets
--

ALTER TABLE ONLY public.support_team_roles
    ADD CONSTRAINT support_team_roles_pkey PRIMARY KEY (team_id, role_id);


--
-- Name: tags tags_pkey; Type: CONSTRAINT; Schema: public; Owner: tickets
--

ALTER TABLE ONLY public.tags
    ADD CONSTRAINT tags_pkey PRIMARY KEY (guild_id, tag_id);


--
-- Name: ticket_claims ticket_claims_pkey; Type: CONSTRAINT; Schema: public; Owner: tickets
--

ALTER TABLE ONLY public.ticket_claims
    ADD CONSTRAINT ticket_claims_pkey PRIMARY KEY (guild_id, ticket_id);


--
-- Name: ticket_last_message ticket_last_message_pkey; Type: CONSTRAINT; Schema: public; Owner: tickets
--

ALTER TABLE ONLY public.ticket_last_message
    ADD CONSTRAINT ticket_last_message_pkey PRIMARY KEY (guild_id, ticket_id);


--
-- Name: ticket_limit ticket_limit_pkey; Type: CONSTRAINT; Schema: public; Owner: tickets
--

ALTER TABLE ONLY public.ticket_limit
    ADD CONSTRAINT ticket_limit_pkey PRIMARY KEY (guild_id);


--
-- Name: ticket_members ticket_members_pkey; Type: CONSTRAINT; Schema: public; Owner: tickets
--

ALTER TABLE ONLY public.ticket_members
    ADD CONSTRAINT ticket_members_pkey PRIMARY KEY (guild_id, ticket_id, user_id);


--
-- Name: ticket_permissions ticket_permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: tickets
--

ALTER TABLE ONLY public.ticket_permissions
    ADD CONSTRAINT ticket_permissions_pkey PRIMARY KEY (guild_id);


--
-- Name: tickets tickets_channel_id_key; Type: CONSTRAINT; Schema: public; Owner: tickets
--

ALTER TABLE ONLY public.tickets
    ADD CONSTRAINT tickets_channel_id_key UNIQUE (channel_id);


--
-- Name: tickets tickets_pkey; Type: CONSTRAINT; Schema: public; Owner: tickets
--

ALTER TABLE ONLY public.tickets
    ADD CONSTRAINT tickets_pkey PRIMARY KEY (id, guild_id);


--
-- Name: translations translations_pkey; Type: CONSTRAINT; Schema: public; Owner: tickets
--

ALTER TABLE ONLY public.translations
    ADD CONSTRAINT translations_pkey PRIMARY KEY (language, message_id);


--
-- Name: used_keys used_keys_pkey; Type: CONSTRAINT; Schema: public; Owner: tickets
--

ALTER TABLE ONLY public.used_keys
    ADD CONSTRAINT used_keys_pkey PRIMARY KEY (key);


--
-- Name: user_guilds user_guilds_pkey; Type: CONSTRAINT; Schema: public; Owner: tickets
--

ALTER TABLE ONLY public.user_guilds
    ADD CONSTRAINT user_guilds_pkey PRIMARY KEY (user_id, guild_id);


--
-- Name: users_can_close users_can_close_pkey; Type: CONSTRAINT; Schema: public; Owner: tickets
--

ALTER TABLE ONLY public.users_can_close
    ADD CONSTRAINT users_can_close_pkey PRIMARY KEY (guild_id);


--
-- Name: vote_credits vote_credits_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.vote_credits
    ADD CONSTRAINT vote_credits_pkey PRIMARY KEY (user_id);


--
-- Name: webhooks webhooks_pkey; Type: CONSTRAINT; Schema: public; Owner: tickets
--

ALTER TABLE ONLY public.webhooks
    ADD CONSTRAINT webhooks_pkey PRIMARY KEY (guild_id, ticket_id);


--
-- Name: webhooks webhooks_webhook_id_key; Type: CONSTRAINT; Schema: public; Owner: tickets
--

ALTER TABLE ONLY public.webhooks
    ADD CONSTRAINT webhooks_webhook_id_key UNIQUE (webhook_id);


--
-- Name: welcome_messages welcome_messages_pkey; Type: CONSTRAINT; Schema: public; Owner: tickets
--

ALTER TABLE ONLY public.welcome_messages
    ADD CONSTRAINT welcome_messages_pkey PRIMARY KEY (guild_id);


--
-- Name: whitelabel_errors whitelabel_errors_pkey; Type: CONSTRAINT; Schema: public; Owner: tickets
--

ALTER TABLE ONLY public.whitelabel_errors
    ADD CONSTRAINT whitelabel_errors_pkey PRIMARY KEY (error_id);


--
-- Name: whitelabel_guilds whitelabel_guilds_pkey; Type: CONSTRAINT; Schema: public; Owner: tickets
--

ALTER TABLE ONLY public.whitelabel_guilds
    ADD CONSTRAINT whitelabel_guilds_pkey PRIMARY KEY (bot_id, guild_id);


--
-- Name: whitelabel_keys_remove whitelabel_keys_pkey; Type: CONSTRAINT; Schema: public; Owner: tickets
--

ALTER TABLE ONLY public.whitelabel_keys_remove
    ADD CONSTRAINT whitelabel_keys_pkey PRIMARY KEY (bot_id);


--
-- Name: whitelabel whitelabel_pkey; Type: CONSTRAINT; Schema: public; Owner: tickets
--

ALTER TABLE ONLY public.whitelabel
    ADD CONSTRAINT whitelabel_pkey PRIMARY KEY (bot_id);


--
-- Name: whitelabel_skus whitelabel_skus_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.whitelabel_skus
    ADD CONSTRAINT whitelabel_skus_pkey PRIMARY KEY (sku_id);


--
-- Name: whitelabel_statuses whitelabel_statuses_pkey; Type: CONSTRAINT; Schema: public; Owner: tickets
--

ALTER TABLE ONLY public.whitelabel_statuses
    ADD CONSTRAINT whitelabel_statuses_pkey PRIMARY KEY (bot_id);


--
-- Name: whitelabel whitelabel_token_key; Type: CONSTRAINT; Schema: public; Owner: tickets
--

ALTER TABLE ONLY public.whitelabel
    ADD CONSTRAINT whitelabel_token_key UNIQUE (token);


--
-- Name: whitelabel whitelabel_user_id_key; Type: CONSTRAINT; Schema: public; Owner: tickets
--

ALTER TABLE ONLY public.whitelabel
    ADD CONSTRAINT whitelabel_user_id_key UNIQUE (user_id);


--
-- Name: whitelabel_users whitelabel_users_pkey; Type: CONSTRAINT; Schema: public; Owner: tickets
--

ALTER TABLE ONLY public.whitelabel_users
    ADD CONSTRAINT whitelabel_users_pkey PRIMARY KEY (user_id);


--
-- Name: archive_channel_channel_id_key; Type: INDEX; Schema: public; Owner: tickets
--

CREATE INDEX archive_channel_channel_id_key ON public.archive_channel USING btree (channel_id);


--
-- Name: close_reason_close_reason_idx; Type: INDEX; Schema: public; Owner: tickets
--

CREATE INDEX close_reason_close_reason_idx ON public.close_reason USING gin (close_reason public.gin_trgm_ops);


--
-- Name: custom_colours_guild_id_key; Type: INDEX; Schema: public; Owner: tickets
--

CREATE INDEX custom_colours_guild_id_key ON public.custom_colours USING btree (guild_id);


--
-- Name: custom_integration_guild_counts_integration_id_key; Type: INDEX; Schema: public; Owner: tickets
--

CREATE UNIQUE INDEX custom_integration_guild_counts_integration_id_key ON public.custom_integration_guild_counts USING btree (integration_id);


--
-- Name: custom_integration_guilds_guild_id; Type: INDEX; Schema: public; Owner: tickets
--

CREATE INDEX custom_integration_guilds_guild_id ON public.custom_integration_guilds USING btree (guild_id);


--
-- Name: custom_integration_headers_integration_id; Type: INDEX; Schema: public; Owner: tickets
--

CREATE INDEX custom_integration_headers_integration_id ON public.custom_integration_headers USING btree (integration_id);


--
-- Name: custom_integration_placeholders_integration_id; Type: INDEX; Schema: public; Owner: tickets
--

CREATE INDEX custom_integration_placeholders_integration_id ON public.custom_integration_placeholders USING btree (integration_id);


--
-- Name: custom_integration_secret_values_guild_id_idx; Type: INDEX; Schema: public; Owner: tickets
--

CREATE INDEX custom_integration_secret_values_guild_id_idx ON public.custom_integration_secret_values USING btree (guild_id);


--
-- Name: custom_integration_secret_values_integration_id_idx; Type: INDEX; Schema: public; Owner: tickets
--

CREATE INDEX custom_integration_secret_values_integration_id_idx ON public.custom_integration_secret_values USING btree (integration_id);


--
-- Name: custom_integration_secret_values_secret_id_idx; Type: INDEX; Schema: public; Owner: tickets
--

CREATE INDEX custom_integration_secret_values_secret_id_idx ON public.custom_integration_secret_values USING btree (secret_id);


--
-- Name: custom_integration_secrets_integration_id; Type: INDEX; Schema: public; Owner: tickets
--

CREATE INDEX custom_integration_secrets_integration_id ON public.custom_integration_secrets USING btree (integration_id);


--
-- Name: custom_integrations_owner_id; Type: INDEX; Schema: public; Owner: tickets
--

CREATE INDEX custom_integrations_owner_id ON public.custom_integrations USING btree (owner_id);


--
-- Name: dashboard_users_user_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX dashboard_users_user_id_idx ON public.dashboard_users USING btree (user_id);


--
-- Name: embeds_guild_id; Type: INDEX; Schema: public; Owner: tickets
--

CREATE INDEX embeds_guild_id ON public.embeds USING btree (guild_id);


--
-- Name: exit_survey_responses_form_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX exit_survey_responses_form_id ON public.exit_survey_responses USING btree (form_id);


--
-- Name: exit_survey_responses_guild_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX exit_survey_responses_guild_id ON public.exit_survey_responses USING btree (guild_id);


--
-- Name: first_response_time_guild_id; Type: INDEX; Schema: public; Owner: tickets
--

CREATE INDEX first_response_time_guild_id ON public.first_response_time USING btree (guild_id);


--
-- Name: first_response_time_guild_view_guild_id_key; Type: INDEX; Schema: public; Owner: tickets
--

CREATE UNIQUE INDEX first_response_time_guild_view_guild_id_key ON public.first_response_time_guild_view USING btree (guild_id);


--
-- Name: first_response_time_guild_view_guild_id_user_id_key; Type: INDEX; Schema: public; Owner: tickets
--

CREATE UNIQUE INDEX first_response_time_guild_view_guild_id_user_id_key ON public.first_response_time_user_view USING btree (guild_id, user_id);


--
-- Name: first_response_time_response_time_idx; Type: INDEX; Schema: public; Owner: tickets
--

CREATE INDEX first_response_time_response_time_idx ON public.first_response_time USING btree (guild_id, response_time DESC);


--
-- Name: form_input_form_id; Type: INDEX; Schema: public; Owner: tickets
--

CREATE INDEX form_input_form_id ON public.form_input USING btree (form_id);


--
-- Name: forms_guild_id; Type: INDEX; Schema: public; Owner: tickets
--

CREATE INDEX forms_guild_id ON public.forms USING btree (guild_id);


--
-- Name: multi_panel_targets_multi_panel_id; Type: INDEX; Schema: public; Owner: tickets
--

CREATE INDEX multi_panel_targets_multi_panel_id ON public.multi_panel_targets USING btree (multi_panel_id);


--
-- Name: multi_panels_guild_id; Type: INDEX; Schema: public; Owner: tickets
--

CREATE INDEX multi_panels_guild_id ON public.multi_panels USING btree (guild_id);


--
-- Name: multi_panels_message_id; Type: INDEX; Schema: public; Owner: tickets
--

CREATE INDEX multi_panels_message_id ON public.multi_panels USING btree (message_id);


--
-- Name: panel_access_control_rules_panel_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX panel_access_control_rules_panel_id ON public.panel_access_control_rules USING btree (panel_id);


--
-- Name: panel_role_mentions_panel_id; Type: INDEX; Schema: public; Owner: tickets
--

CREATE INDEX panel_role_mentions_panel_id ON public.panel_role_mentions USING btree (panel_id);


--
-- Name: panel_teams_panel_id; Type: INDEX; Schema: public; Owner: tickets
--

CREATE INDEX panel_teams_panel_id ON public.panel_teams USING btree (panel_id);


--
-- Name: panels_custom_id; Type: INDEX; Schema: public; Owner: tickets
--

CREATE INDEX panels_custom_id ON public.panels USING btree (custom_id);


--
-- Name: panels_form_id; Type: INDEX; Schema: public; Owner: tickets
--

CREATE INDEX panels_form_id ON public.panels USING btree (form_id);


--
-- Name: panels_guild_id; Type: INDEX; Schema: public; Owner: tickets
--

CREATE INDEX panels_guild_id ON public.panels USING btree (guild_id);


--
-- Name: panels_guild_id_form_id; Type: INDEX; Schema: public; Owner: tickets
--

CREATE INDEX panels_guild_id_form_id ON public.panels USING btree (guild_id, form_id);


--
-- Name: panels_message_id; Type: INDEX; Schema: public; Owner: tickets
--

CREATE INDEX panels_message_id ON public.panels USING btree (message_id);


--
-- Name: participant_user_id_idx; Type: INDEX; Schema: public; Owner: tickets
--

CREATE INDEX participant_user_id_idx ON public.participant USING btree (user_id);


--
-- Name: permissions_guild_id; Type: INDEX; Schema: public; Owner: tickets
--

CREATE INDEX permissions_guild_id ON public.permissions USING btree (guild_id);


--
-- Name: role_permissions_guild_id; Type: INDEX; Schema: public; Owner: tickets
--

CREATE INDEX role_permissions_guild_id ON public.role_permissions USING btree (guild_id);


--
-- Name: tags_guild_id_application_command_id_idx; Type: INDEX; Schema: public; Owner: tickets
--

CREATE INDEX tags_guild_id_application_command_id_idx ON public.tags USING btree (guild_id, application_command_id);


--
-- Name: tags_guild_id_idx; Type: INDEX; Schema: public; Owner: tickets
--

CREATE INDEX tags_guild_id_idx ON public.tags USING btree (guild_id);


--
-- Name: ticket_duration_guild_id_key; Type: INDEX; Schema: public; Owner: tickets
--

CREATE UNIQUE INDEX ticket_duration_guild_id_key ON public.ticket_duration USING btree (guild_id);


--
-- Name: ticket_members_guild_ticket; Type: INDEX; Schema: public; Owner: tickets
--

CREATE INDEX ticket_members_guild_ticket ON public.ticket_members USING btree (guild_id, ticket_id);


--
-- Name: tickets_channel_id_hash; Type: INDEX; Schema: public; Owner: tickets
--

CREATE INDEX tickets_channel_id_hash ON public.tickets USING hash (channel_id);


--
-- Name: tickets_guild_id; Type: INDEX; Schema: public; Owner: tickets
--

CREATE INDEX tickets_guild_id ON public.tickets USING btree (guild_id);


--
-- Name: tickets_guild_id_channel_id_key; Type: INDEX; Schema: public; Owner: tickets
--

CREATE INDEX tickets_guild_id_channel_id_key ON public.tickets USING btree (guild_id, channel_id);


--
-- Name: tickets_guild_id_id_key; Type: INDEX; Schema: public; Owner: tickets
--

CREATE INDEX tickets_guild_id_id_key ON public.tickets USING btree (guild_id, id DESC);


--
-- Name: tickets_guild_id_open_idx; Type: INDEX; Schema: public; Owner: tickets
--

CREATE INDEX tickets_guild_id_open_idx ON public.tickets USING btree (guild_id) WHERE (open = true);


--
-- Name: tickets_guild_id_user_id; Type: INDEX; Schema: public; Owner: tickets
--

CREATE INDEX tickets_guild_id_user_id ON public.tickets USING btree (guild_id, user_id);


--
-- Name: tickets_panel_id; Type: INDEX; Schema: public; Owner: tickets
--

CREATE INDEX tickets_panel_id ON public.tickets USING btree (panel_id);


--
-- Name: tickets_user_id_idx; Type: INDEX; Schema: public; Owner: tickets
--

CREATE INDEX tickets_user_id_idx ON public.tickets USING btree (user_id);


--
-- Name: top_close_reasons_guild_id_panel_id_key; Type: INDEX; Schema: public; Owner: tickets
--

CREATE INDEX top_close_reasons_guild_id_panel_id_key ON public.top_close_reasons USING btree (guild_id, panel_id);


--
-- Name: whitelabel_bot_id; Type: INDEX; Schema: public; Owner: tickets
--

CREATE INDEX whitelabel_bot_id ON public.whitelabel USING btree (bot_id);


--
-- Name: whitelabel_errors_user_id_idx; Type: INDEX; Schema: public; Owner: tickets
--

CREATE INDEX whitelabel_errors_user_id_idx ON public.whitelabel USING btree (user_id);


--
-- Name: whitelabel_guilds_guild_id_idx; Type: INDEX; Schema: public; Owner: tickets
--

CREATE INDEX whitelabel_guilds_guild_id_idx ON public.whitelabel_guilds USING btree (guild_id);


--
-- Name: whitelabel_user_id; Type: INDEX; Schema: public; Owner: tickets
--

CREATE INDEX whitelabel_user_id ON public.whitelabel USING btree (user_id);


--
-- Name: archive_messages archive_messages_guild_id_ticket_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.archive_messages
    ADD CONSTRAINT archive_messages_guild_id_ticket_id_fkey FOREIGN KEY (guild_id, ticket_id) REFERENCES public.tickets(guild_id, id) ON DELETE CASCADE;


--
-- Name: auto_close_exclude auto_close_exclude_guild_id_ticket_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: tickets
--

ALTER TABLE ONLY public.auto_close_exclude
    ADD CONSTRAINT auto_close_exclude_guild_id_ticket_id_fkey FOREIGN KEY (guild_id, ticket_id) REFERENCES public.tickets(guild_id, id);


--
-- Name: category_update_queue category_update_queue_guild_id_ticket_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.category_update_queue
    ADD CONSTRAINT category_update_queue_guild_id_ticket_id_fkey FOREIGN KEY (guild_id, ticket_id) REFERENCES public.tickets(guild_id, id) ON DELETE CASCADE;


--
-- Name: close_reason close_reason_guild_id_ticket_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: tickets
--

ALTER TABLE ONLY public.close_reason
    ADD CONSTRAINT close_reason_guild_id_ticket_id_fkey FOREIGN KEY (guild_id, ticket_id) REFERENCES public.tickets(guild_id, id);


--
-- Name: close_request close_request_guild_id_ticket_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: tickets
--

ALTER TABLE ONLY public.close_request
    ADD CONSTRAINT close_request_guild_id_ticket_id_fkey FOREIGN KEY (guild_id, ticket_id) REFERENCES public.tickets(guild_id, id);


--
-- Name: settings context_menu_panel_fkey; Type: FK CONSTRAINT; Schema: public; Owner: tickets
--

ALTER TABLE ONLY public.settings
    ADD CONSTRAINT context_menu_panel_fkey FOREIGN KEY (context_menu_panel) REFERENCES public.panels(panel_id) ON DELETE SET NULL;


--
-- Name: custom_integration_guilds custom_integration_guilds_integration_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: tickets
--

ALTER TABLE ONLY public.custom_integration_guilds
    ADD CONSTRAINT custom_integration_guilds_integration_id_fkey FOREIGN KEY (integration_id) REFERENCES public.custom_integrations(id) ON DELETE CASCADE;


--
-- Name: custom_integration_headers custom_integration_headers_integration_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: tickets
--

ALTER TABLE ONLY public.custom_integration_headers
    ADD CONSTRAINT custom_integration_headers_integration_id_fkey FOREIGN KEY (integration_id) REFERENCES public.custom_integrations(id) ON DELETE CASCADE;


--
-- Name: custom_integration_placeholders custom_integration_placeholders_integration_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: tickets
--

ALTER TABLE ONLY public.custom_integration_placeholders
    ADD CONSTRAINT custom_integration_placeholders_integration_id_fkey FOREIGN KEY (integration_id) REFERENCES public.custom_integrations(id) ON DELETE CASCADE;


--
-- Name: custom_integration_secret_values custom_integration_secret_values_integration_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: tickets
--

ALTER TABLE ONLY public.custom_integration_secret_values
    ADD CONSTRAINT custom_integration_secret_values_integration_id_fkey FOREIGN KEY (integration_id) REFERENCES public.custom_integrations(id) ON DELETE CASCADE;


--
-- Name: custom_integration_secret_values custom_integration_secret_values_integration_id_guild_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: tickets
--

ALTER TABLE ONLY public.custom_integration_secret_values
    ADD CONSTRAINT custom_integration_secret_values_integration_id_guild_id_fkey FOREIGN KEY (integration_id, guild_id) REFERENCES public.custom_integration_guilds(integration_id, guild_id) ON DELETE CASCADE;


--
-- Name: custom_integration_secret_values custom_integration_secret_values_secret_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: tickets
--

ALTER TABLE ONLY public.custom_integration_secret_values
    ADD CONSTRAINT custom_integration_secret_values_secret_id_fkey FOREIGN KEY (secret_id) REFERENCES public.custom_integration_secrets(id) ON DELETE CASCADE;


--
-- Name: custom_integration_secrets custom_integration_secrets_integration_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: tickets
--

ALTER TABLE ONLY public.custom_integration_secrets
    ADD CONSTRAINT custom_integration_secrets_integration_id_fkey FOREIGN KEY (integration_id) REFERENCES public.custom_integrations(id) ON DELETE CASCADE;


--
-- Name: discord_entitlements discord_entitlements_entitlement_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.discord_entitlements
    ADD CONSTRAINT discord_entitlements_entitlement_id_fkey FOREIGN KEY (entitlement_id) REFERENCES public.entitlements(id) ON DELETE CASCADE;


--
-- Name: discord_store_skus discord_store_skus_sku_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.discord_store_skus
    ADD CONSTRAINT discord_store_skus_sku_id_fkey FOREIGN KEY (sku_id) REFERENCES public.skus(id);


--
-- Name: embed_fields embed_fields_embed_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: tickets
--

ALTER TABLE ONLY public.embed_fields
    ADD CONSTRAINT embed_fields_embed_id_fkey FOREIGN KEY (embed_id) REFERENCES public.embeds(id) ON DELETE CASCADE;


--
-- Name: entitlements entitlements_sku_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.entitlements
    ADD CONSTRAINT entitlements_sku_id_fkey FOREIGN KEY (sku_id) REFERENCES public.skus(id);


--
-- Name: exit_survey_responses exit_survey_responses_form_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.exit_survey_responses
    ADD CONSTRAINT exit_survey_responses_form_id_fkey FOREIGN KEY (form_id) REFERENCES public.forms(form_id) ON DELETE CASCADE;


--
-- Name: exit_survey_responses exit_survey_responses_guild_id_ticket_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.exit_survey_responses
    ADD CONSTRAINT exit_survey_responses_guild_id_ticket_id_fkey FOREIGN KEY (guild_id, ticket_id) REFERENCES public.tickets(guild_id, id);


--
-- Name: exit_survey_responses exit_survey_responses_question_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.exit_survey_responses
    ADD CONSTRAINT exit_survey_responses_question_id_fkey FOREIGN KEY (question_id) REFERENCES public.form_input(id) ON DELETE CASCADE;


--
-- Name: first_response_time first_response_time_guild_id_ticket_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: tickets
--

ALTER TABLE ONLY public.first_response_time
    ADD CONSTRAINT first_response_time_guild_id_ticket_id_fkey FOREIGN KEY (guild_id, ticket_id) REFERENCES public.tickets(guild_id, id);


--
-- Name: form_input form_input_form_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: tickets
--

ALTER TABLE ONLY public.form_input
    ADD CONSTRAINT form_input_form_id_fkey FOREIGN KEY (form_id) REFERENCES public.forms(form_id) ON DELETE CASCADE;


--
-- Name: legacy_premium_entitlement_guilds legacy_premium_entitlement_guilds_entitlement_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.legacy_premium_entitlement_guilds
    ADD CONSTRAINT legacy_premium_entitlement_guilds_entitlement_id_fkey FOREIGN KEY (entitlement_id) REFERENCES public.entitlements(id);


--
-- Name: legacy_premium_entitlement_guilds legacy_premium_entitlement_guilds_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.legacy_premium_entitlement_guilds
    ADD CONSTRAINT legacy_premium_entitlement_guilds_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.legacy_premium_entitlements(user_id);


--
-- Name: legacy_premium_entitlements legacy_premium_entitlements_fk_sku_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.legacy_premium_entitlements
    ADD CONSTRAINT legacy_premium_entitlements_fk_sku_id FOREIGN KEY (sku_id) REFERENCES public.skus(id);


--
-- Name: modmail_forced_guilds modmail_forced_guilds_bot_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: tickets
--

ALTER TABLE ONLY public.modmail_forced_guilds
    ADD CONSTRAINT modmail_forced_guilds_bot_id_fkey FOREIGN KEY (bot_id) REFERENCES public.whitelabel(bot_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: modmail_webhooks modmail_webhooks_uuid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: tickets
--

ALTER TABLE ONLY public.modmail_webhooks
    ADD CONSTRAINT modmail_webhooks_uuid_fkey FOREIGN KEY (uuid) REFERENCES public.modmail_sessions(uuid);


--
-- Name: multi_panel_targets multi_panel_targets_multi_panel_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: tickets
--

ALTER TABLE ONLY public.multi_panel_targets
    ADD CONSTRAINT multi_panel_targets_multi_panel_id_fkey FOREIGN KEY (multi_panel_id) REFERENCES public.multi_panels(id) ON DELETE CASCADE;


--
-- Name: multi_server_skus multi_server_skus_sku_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.multi_server_skus
    ADD CONSTRAINT multi_server_skus_sku_id_fkey FOREIGN KEY (sku_id) REFERENCES public.skus(id);


--
-- Name: panel_access_control_rules panel_access_control_rules_panel_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.panel_access_control_rules
    ADD CONSTRAINT panel_access_control_rules_panel_id_fkey FOREIGN KEY (panel_id) REFERENCES public.panels(panel_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: panel_role_mentions panel_role_mentions_panel_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: tickets
--

ALTER TABLE ONLY public.panel_role_mentions
    ADD CONSTRAINT panel_role_mentions_panel_id_fkey FOREIGN KEY (panel_id) REFERENCES public.panels(panel_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: panel_teams panel_teams_team_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: tickets
--

ALTER TABLE ONLY public.panel_teams
    ADD CONSTRAINT panel_teams_team_id_fkey FOREIGN KEY (team_id) REFERENCES public.support_team(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: panel_user_mentions panel_user_mentions_panel_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: tickets
--

ALTER TABLE ONLY public.panel_user_mentions
    ADD CONSTRAINT panel_user_mentions_panel_id_fkey FOREIGN KEY (panel_id) REFERENCES public.panels(panel_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: panels panels_exit_survey_form_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: tickets
--

ALTER TABLE ONLY public.panels
    ADD CONSTRAINT panels_exit_survey_form_id_fkey FOREIGN KEY (exit_survey_form_id) REFERENCES public.forms(form_id) ON DELETE SET NULL;


--
-- Name: panels panels_form_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: tickets
--

ALTER TABLE ONLY public.panels
    ADD CONSTRAINT panels_form_id_fkey FOREIGN KEY (form_id) REFERENCES public.forms(form_id) ON DELETE SET NULL;


--
-- Name: panel_teams panels_panel_id; Type: FK CONSTRAINT; Schema: public; Owner: tickets
--

ALTER TABLE ONLY public.panel_teams
    ADD CONSTRAINT panels_panel_id FOREIGN KEY (panel_id) REFERENCES public.panels(panel_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: tickets panels_panel_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: tickets
--

ALTER TABLE ONLY public.tickets
    ADD CONSTRAINT panels_panel_id_fkey FOREIGN KEY (panel_id) REFERENCES public.panels(panel_id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: participant participant_guild_id_ticket_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: tickets
--

ALTER TABLE ONLY public.participant
    ADD CONSTRAINT participant_guild_id_ticket_id_fkey FOREIGN KEY (guild_id, ticket_id) REFERENCES public.tickets(guild_id, id);


--
-- Name: patreon_entitlements patreon_entitlements_entitlement_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patreon_entitlements
    ADD CONSTRAINT patreon_entitlements_entitlement_id_fkey FOREIGN KEY (entitlement_id) REFERENCES public.entitlements(id);


--
-- Name: patreon_entitlements patreon_entitlements_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patreon_entitlements
    ADD CONSTRAINT patreon_entitlements_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.legacy_premium_entitlements(user_id);


--
-- Name: premium_keys premium_keys_fk_sku_id; Type: FK CONSTRAINT; Schema: public; Owner: tickets
--

ALTER TABLE ONLY public.premium_keys
    ADD CONSTRAINT premium_keys_fk_sku_id FOREIGN KEY (sku_id) REFERENCES public.skus(id) ON UPDATE CASCADE;


--
-- Name: service_ratings service_ratings_guild_id_ticket_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: tickets
--

ALTER TABLE ONLY public.service_ratings
    ADD CONSTRAINT service_ratings_guild_id_ticket_id_fkey FOREIGN KEY (guild_id, ticket_id) REFERENCES public.tickets(guild_id, id);


--
-- Name: subscription_skus subscription_skus_sku_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.subscription_skus
    ADD CONSTRAINT subscription_skus_sku_id_fkey FOREIGN KEY (sku_id) REFERENCES public.skus(id);


--
-- Name: support_team_members support_team_members_team_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: tickets
--

ALTER TABLE ONLY public.support_team_members
    ADD CONSTRAINT support_team_members_team_id_fkey FOREIGN KEY (team_id) REFERENCES public.support_team(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: support_team_roles support_team_roles_team_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: tickets
--

ALTER TABLE ONLY public.support_team_roles
    ADD CONSTRAINT support_team_roles_team_id_fkey FOREIGN KEY (team_id) REFERENCES public.support_team(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: ticket_claims ticket_claims_guild_id_ticket_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: tickets
--

ALTER TABLE ONLY public.ticket_claims
    ADD CONSTRAINT ticket_claims_guild_id_ticket_id_fkey FOREIGN KEY (guild_id, ticket_id) REFERENCES public.tickets(guild_id, id);


--
-- Name: ticket_last_message ticket_last_message_guild_id_ticket_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: tickets
--

ALTER TABLE ONLY public.ticket_last_message
    ADD CONSTRAINT ticket_last_message_guild_id_ticket_id_fkey FOREIGN KEY (guild_id, ticket_id) REFERENCES public.tickets(guild_id, id);


--
-- Name: ticket_members ticket_members_guild_id_ticket_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: tickets
--

ALTER TABLE ONLY public.ticket_members
    ADD CONSTRAINT ticket_members_guild_id_ticket_id_fkey FOREIGN KEY (guild_id, ticket_id) REFERENCES public.tickets(guild_id, id);


--
-- Name: user_guilds user_guilds_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: tickets
--

ALTER TABLE ONLY public.user_guilds
    ADD CONSTRAINT user_guilds_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.dashboard_users(user_id) ON DELETE CASCADE;


--
-- Name: webhooks webhooks_guild_id_ticket_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: tickets
--

ALTER TABLE ONLY public.webhooks
    ADD CONSTRAINT webhooks_guild_id_ticket_id_fkey FOREIGN KEY (guild_id, ticket_id) REFERENCES public.tickets(guild_id, id);


--
-- Name: panels welcome_message_new_fkey; Type: FK CONSTRAINT; Schema: public; Owner: tickets
--

ALTER TABLE ONLY public.panels
    ADD CONSTRAINT welcome_message_new_fkey FOREIGN KEY (welcome_message) REFERENCES public.embeds(id) ON DELETE SET NULL;


--
-- Name: whitelabel_guilds whitelabel_guilds_bot_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: tickets
--

ALTER TABLE ONLY public.whitelabel_guilds
    ADD CONSTRAINT whitelabel_guilds_bot_id_fkey FOREIGN KEY (bot_id) REFERENCES public.whitelabel(bot_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: whitelabel_keys_remove whitelabel_keys_bot_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: tickets
--

ALTER TABLE ONLY public.whitelabel_keys_remove
    ADD CONSTRAINT whitelabel_keys_bot_id_fkey FOREIGN KEY (bot_id) REFERENCES public.whitelabel(bot_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: whitelabel_skus whitelabel_skus_sku_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.whitelabel_skus
    ADD CONSTRAINT whitelabel_skus_sku_id_fkey FOREIGN KEY (sku_id) REFERENCES public.skus(id);


--
-- Name: whitelabel_statuses whitelabel_statuses_bot_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: tickets
--

ALTER TABLE ONLY public.whitelabel_statuses
    ADD CONSTRAINT whitelabel_statuses_bot_id_fkey FOREIGN KEY (bot_id) REFERENCES public.whitelabel(bot_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: tickets_ch_publication; Type: PUBLICATION; Schema: -; Owner: clickhouse
--

CREATE PUBLICATION tickets_ch_publication WITH (publish = 'insert, update, delete, truncate');


ALTER PUBLICATION tickets_ch_publication OWNER TO clickhouse;

--
-- Name: tickets_ch_publication close_reason; Type: PUBLICATION TABLE; Schema: public; Owner: clickhouse
--

ALTER PUBLICATION tickets_ch_publication ADD TABLE ONLY public.close_reason;


--
-- Name: tickets_ch_publication custom_integration_guilds; Type: PUBLICATION TABLE; Schema: public; Owner: clickhouse
--

ALTER PUBLICATION tickets_ch_publication ADD TABLE ONLY public.custom_integration_guilds;


--
-- Name: tickets_ch_publication first_response_time; Type: PUBLICATION TABLE; Schema: public; Owner: clickhouse
--

ALTER PUBLICATION tickets_ch_publication ADD TABLE ONLY public.first_response_time;


--
-- Name: tickets_ch_publication panels; Type: PUBLICATION TABLE; Schema: public; Owner: clickhouse
--

ALTER PUBLICATION tickets_ch_publication ADD TABLE ONLY public.panels;


--
-- Name: tickets_ch_publication participant; Type: PUBLICATION TABLE; Schema: public; Owner: clickhouse
--

ALTER PUBLICATION tickets_ch_publication ADD TABLE ONLY public.participant;


--
-- Name: tickets_ch_publication service_ratings; Type: PUBLICATION TABLE; Schema: public; Owner: clickhouse
--

ALTER PUBLICATION tickets_ch_publication ADD TABLE ONLY public.service_ratings;


--
-- Name: tickets_ch_publication ticket_claims; Type: PUBLICATION TABLE; Schema: public; Owner: clickhouse
--

ALTER PUBLICATION tickets_ch_publication ADD TABLE ONLY public.ticket_claims;


--
-- Name: tickets_ch_publication tickets; Type: PUBLICATION TABLE; Schema: public; Owner: clickhouse
--

ALTER PUBLICATION tickets_ch_publication ADD TABLE ONLY public.tickets;


--
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE USAGE ON SCHEMA public FROM PUBLIC;
GRANT ALL ON SCHEMA public TO PUBLIC;
GRANT USAGE ON SCHEMA public TO votelistener;
GRANT USAGE ON SCHEMA public TO backup;
GRANT USAGE ON SCHEMA public TO peerdb;


--
-- Name: TABLE active_language; Type: ACL; Schema: public; Owner: tickets
--

GRANT SELECT ON TABLE public.active_language TO backup;
GRANT SELECT ON TABLE public.active_language TO clickhouse;
GRANT SELECT ON TABLE public.active_language TO peerdb;


--
-- Name: TABLE archive_channel; Type: ACL; Schema: public; Owner: tickets
--

GRANT SELECT ON TABLE public.archive_channel TO backup;
GRANT SELECT ON TABLE public.archive_channel TO clickhouse;
GRANT SELECT ON TABLE public.archive_channel TO peerdb;


--
-- Name: TABLE archive_messages; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.archive_messages TO backup;
GRANT SELECT ON TABLE public.archive_messages TO peerdb;


--
-- Name: TABLE auto_close; Type: ACL; Schema: public; Owner: tickets
--

GRANT SELECT ON TABLE public.auto_close TO backup;
GRANT SELECT ON TABLE public.auto_close TO clickhouse;
GRANT SELECT ON TABLE public.auto_close TO peerdb;


--
-- Name: TABLE auto_close_exclude; Type: ACL; Schema: public; Owner: tickets
--

GRANT SELECT ON TABLE public.auto_close_exclude TO backup;
GRANT SELECT ON TABLE public.auto_close_exclude TO clickhouse;
GRANT SELECT ON TABLE public.auto_close_exclude TO peerdb;


--
-- Name: TABLE blacklist; Type: ACL; Schema: public; Owner: tickets
--

GRANT SELECT ON TABLE public.blacklist TO backup;
GRANT SELECT ON TABLE public.blacklist TO clickhouse;
GRANT SELECT ON TABLE public.blacklist TO peerdb;


--
-- Name: TABLE bot_staff; Type: ACL; Schema: public; Owner: tickets
--

GRANT SELECT ON TABLE public.bot_staff TO backup;
GRANT SELECT ON TABLE public.bot_staff TO clickhouse;
GRANT SELECT ON TABLE public.bot_staff TO peerdb;


--
-- Name: TABLE category_update_queue; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.category_update_queue TO backup;
GRANT SELECT ON TABLE public.category_update_queue TO peerdb;


--
-- Name: TABLE channel_category; Type: ACL; Schema: public; Owner: tickets
--

GRANT SELECT ON TABLE public.channel_category TO backup;
GRANT SELECT ON TABLE public.channel_category TO clickhouse;
GRANT SELECT ON TABLE public.channel_category TO peerdb;


--
-- Name: TABLE claim_settings; Type: ACL; Schema: public; Owner: tickets
--

GRANT SELECT ON TABLE public.claim_settings TO backup;
GRANT SELECT ON TABLE public.claim_settings TO clickhouse;
GRANT SELECT ON TABLE public.claim_settings TO peerdb;


--
-- Name: TABLE close_confirmation; Type: ACL; Schema: public; Owner: tickets
--

GRANT SELECT ON TABLE public.close_confirmation TO backup;
GRANT SELECT ON TABLE public.close_confirmation TO clickhouse;
GRANT SELECT ON TABLE public.close_confirmation TO peerdb;


--
-- Name: TABLE close_reason; Type: ACL; Schema: public; Owner: tickets
--

GRANT SELECT ON TABLE public.close_reason TO backup;
GRANT SELECT ON TABLE public.close_reason TO clickhouse;
GRANT SELECT ON TABLE public.close_reason TO peerdb;


--
-- Name: TABLE close_request; Type: ACL; Schema: public; Owner: tickets
--

GRANT SELECT ON TABLE public.close_request TO backup;
GRANT SELECT ON TABLE public.close_request TO clickhouse;
GRANT SELECT ON TABLE public.close_request TO peerdb;


--
-- Name: TABLE tickets; Type: ACL; Schema: public; Owner: tickets
--

GRANT SELECT ON TABLE public.tickets TO backup;
GRANT SELECT ON TABLE public.tickets TO clickhouse;
GRANT SELECT ON TABLE public.tickets TO peerdb;


--
-- Name: TABLE counter_view; Type: ACL; Schema: public; Owner: tickets
--

GRANT SELECT ON TABLE public.counter_view TO backup;
GRANT SELECT ON TABLE public.counter_view TO clickhouse;
GRANT SELECT ON TABLE public.counter_view TO peerdb;


--
-- Name: TABLE custom_colours; Type: ACL; Schema: public; Owner: tickets
--

GRANT SELECT ON TABLE public.custom_colours TO backup;
GRANT SELECT ON TABLE public.custom_colours TO clickhouse;
GRANT SELECT ON TABLE public.custom_colours TO peerdb;


--
-- Name: TABLE custom_integration_guilds; Type: ACL; Schema: public; Owner: tickets
--

GRANT SELECT ON TABLE public.custom_integration_guilds TO backup;
GRANT SELECT ON TABLE public.custom_integration_guilds TO clickhouse;
GRANT SELECT ON TABLE public.custom_integration_guilds TO peerdb;


--
-- Name: TABLE custom_integration_guild_counts; Type: ACL; Schema: public; Owner: tickets
--

GRANT SELECT ON TABLE public.custom_integration_guild_counts TO peerdb;


--
-- Name: TABLE custom_integration_headers; Type: ACL; Schema: public; Owner: tickets
--

GRANT SELECT ON TABLE public.custom_integration_headers TO backup;
GRANT SELECT ON TABLE public.custom_integration_headers TO clickhouse;
GRANT SELECT ON TABLE public.custom_integration_headers TO peerdb;


--
-- Name: SEQUENCE custom_integration_headers_id_seq; Type: ACL; Schema: public; Owner: tickets
--

GRANT SELECT,USAGE ON SEQUENCE public.custom_integration_headers_id_seq TO backup;


--
-- Name: TABLE custom_integration_placeholders; Type: ACL; Schema: public; Owner: tickets
--

GRANT SELECT ON TABLE public.custom_integration_placeholders TO backup;
GRANT SELECT ON TABLE public.custom_integration_placeholders TO clickhouse;
GRANT SELECT ON TABLE public.custom_integration_placeholders TO peerdb;


--
-- Name: SEQUENCE custom_integration_placeholders_id_seq; Type: ACL; Schema: public; Owner: tickets
--

GRANT SELECT,USAGE ON SEQUENCE public.custom_integration_placeholders_id_seq TO backup;


--
-- Name: TABLE custom_integration_secret_values; Type: ACL; Schema: public; Owner: tickets
--

GRANT SELECT ON TABLE public.custom_integration_secret_values TO backup;
GRANT SELECT ON TABLE public.custom_integration_secret_values TO clickhouse;
GRANT SELECT ON TABLE public.custom_integration_secret_values TO peerdb;


--
-- Name: SEQUENCE custom_integration_secret_values_secret_id_seq; Type: ACL; Schema: public; Owner: tickets
--

GRANT SELECT,USAGE ON SEQUENCE public.custom_integration_secret_values_secret_id_seq TO backup;


--
-- Name: TABLE custom_integration_secrets; Type: ACL; Schema: public; Owner: tickets
--

GRANT SELECT ON TABLE public.custom_integration_secrets TO backup;
GRANT SELECT ON TABLE public.custom_integration_secrets TO clickhouse;
GRANT SELECT ON TABLE public.custom_integration_secrets TO peerdb;


--
-- Name: SEQUENCE custom_integration_secrets_id_seq; Type: ACL; Schema: public; Owner: tickets
--

GRANT SELECT,USAGE ON SEQUENCE public.custom_integration_secrets_id_seq TO backup;


--
-- Name: TABLE custom_integrations; Type: ACL; Schema: public; Owner: tickets
--

GRANT SELECT ON TABLE public.custom_integrations TO backup;
GRANT SELECT ON TABLE public.custom_integrations TO clickhouse;
GRANT SELECT ON TABLE public.custom_integrations TO peerdb;


--
-- Name: SEQUENCE custom_integrations_id_seq; Type: ACL; Schema: public; Owner: tickets
--

GRANT SELECT,USAGE ON SEQUENCE public.custom_integrations_id_seq TO backup;


--
-- Name: TABLE dashboard_users; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.dashboard_users TO backup;
GRANT SELECT ON TABLE public.dashboard_users TO peerdb;


--
-- Name: TABLE discord_entitlements; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.discord_entitlements TO backup;
GRANT SELECT ON TABLE public.discord_entitlements TO peerdb;


--
-- Name: TABLE discord_store_skus; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.discord_store_skus TO backup;
GRANT SELECT ON TABLE public.discord_store_skus TO peerdb;


--
-- Name: TABLE dm_on_open; Type: ACL; Schema: public; Owner: tickets
--

GRANT SELECT ON TABLE public.dm_on_open TO backup;
GRANT SELECT ON TABLE public.dm_on_open TO clickhouse;
GRANT SELECT ON TABLE public.dm_on_open TO peerdb;


--
-- Name: TABLE embed_fields; Type: ACL; Schema: public; Owner: tickets
--

GRANT SELECT ON TABLE public.embed_fields TO backup;
GRANT SELECT ON TABLE public.embed_fields TO clickhouse;
GRANT SELECT ON TABLE public.embed_fields TO peerdb;


--
-- Name: SEQUENCE embed_fields_id_seq; Type: ACL; Schema: public; Owner: tickets
--

GRANT SELECT,USAGE ON SEQUENCE public.embed_fields_id_seq TO backup;


--
-- Name: TABLE embeds; Type: ACL; Schema: public; Owner: tickets
--

GRANT SELECT ON TABLE public.embeds TO backup;
GRANT SELECT ON TABLE public.embeds TO clickhouse;
GRANT SELECT ON TABLE public.embeds TO peerdb;


--
-- Name: SEQUENCE embeds_id_seq; Type: ACL; Schema: public; Owner: tickets
--

GRANT SELECT,USAGE ON SEQUENCE public.embeds_id_seq TO backup;


--
-- Name: TABLE entitlements; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.entitlements TO backup;
GRANT SELECT ON TABLE public.entitlements TO peerdb;


--
-- Name: TABLE exit_survey_responses; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.exit_survey_responses TO backup;
GRANT SELECT ON TABLE public.exit_survey_responses TO peerdb;


--
-- Name: TABLE feedback_enabled; Type: ACL; Schema: public; Owner: tickets
--

GRANT SELECT ON TABLE public.feedback_enabled TO backup;
GRANT SELECT ON TABLE public.feedback_enabled TO clickhouse;
GRANT SELECT ON TABLE public.feedback_enabled TO peerdb;


--
-- Name: TABLE first_response_time; Type: ACL; Schema: public; Owner: tickets
--

GRANT SELECT ON TABLE public.first_response_time TO backup;
GRANT SELECT ON TABLE public.first_response_time TO clickhouse;
GRANT SELECT ON TABLE public.first_response_time TO peerdb;


--
-- Name: TABLE first_response_time_export; Type: ACL; Schema: public; Owner: tickets
--

GRANT SELECT ON TABLE public.first_response_time_export TO backup;
GRANT SELECT ON TABLE public.first_response_time_export TO clickhouse;
GRANT SELECT ON TABLE public.first_response_time_export TO peerdb;


--
-- Name: TABLE first_response_time_guild_view; Type: ACL; Schema: public; Owner: tickets
--

GRANT SELECT ON TABLE public.first_response_time_guild_view TO peerdb;


--
-- Name: TABLE first_response_time_user_view; Type: ACL; Schema: public; Owner: tickets
--

GRANT SELECT ON TABLE public.first_response_time_user_view TO backup;
GRANT SELECT ON TABLE public.first_response_time_user_view TO clickhouse;
GRANT SELECT ON TABLE public.first_response_time_user_view TO peerdb;


--
-- Name: TABLE form_input; Type: ACL; Schema: public; Owner: tickets
--

GRANT SELECT ON TABLE public.form_input TO backup;
GRANT SELECT ON TABLE public.form_input TO clickhouse;
GRANT SELECT ON TABLE public.form_input TO peerdb;


--
-- Name: SEQUENCE form_input_id_seq; Type: ACL; Schema: public; Owner: tickets
--

GRANT SELECT,USAGE ON SEQUENCE public.form_input_id_seq TO backup;


--
-- Name: TABLE forms; Type: ACL; Schema: public; Owner: tickets
--

GRANT SELECT ON TABLE public.forms TO backup;
GRANT SELECT ON TABLE public.forms TO clickhouse;
GRANT SELECT ON TABLE public.forms TO peerdb;


--
-- Name: SEQUENCE forms_form_id_seq; Type: ACL; Schema: public; Owner: tickets
--

GRANT SELECT,USAGE ON SEQUENCE public.forms_form_id_seq TO backup;


--
-- Name: TABLE global_blacklist; Type: ACL; Schema: public; Owner: tickets
--

GRANT SELECT ON TABLE public.global_blacklist TO backup;
GRANT SELECT ON TABLE public.global_blacklist TO clickhouse;
GRANT SELECT ON TABLE public.global_blacklist TO peerdb;


--
-- Name: TABLE guild_leave_time; Type: ACL; Schema: public; Owner: tickets
--

GRANT SELECT ON TABLE public.guild_leave_time TO backup;
GRANT SELECT ON TABLE public.guild_leave_time TO clickhouse;
GRANT SELECT ON TABLE public.guild_leave_time TO peerdb;


--
-- Name: TABLE guild_metadata; Type: ACL; Schema: public; Owner: tickets
--

GRANT SELECT ON TABLE public.guild_metadata TO backup;
GRANT SELECT ON TABLE public.guild_metadata TO clickhouse;
GRANT SELECT ON TABLE public.guild_metadata TO peerdb;


--
-- Name: TABLE legacy_premium_entitlement_guilds; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.legacy_premium_entitlement_guilds TO backup;
GRANT SELECT ON TABLE public.legacy_premium_entitlement_guilds TO peerdb;


--
-- Name: TABLE legacy_premium_entitlements; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.legacy_premium_entitlements TO backup;
GRANT SELECT ON TABLE public.legacy_premium_entitlements TO peerdb;


--
-- Name: TABLE modmail_archive; Type: ACL; Schema: public; Owner: tickets
--

GRANT SELECT ON TABLE public.modmail_archive TO backup;
GRANT SELECT ON TABLE public.modmail_archive TO clickhouse;
GRANT SELECT ON TABLE public.modmail_archive TO peerdb;


--
-- Name: TABLE modmail_enabled; Type: ACL; Schema: public; Owner: tickets
--

GRANT SELECT ON TABLE public.modmail_enabled TO backup;
GRANT SELECT ON TABLE public.modmail_enabled TO clickhouse;
GRANT SELECT ON TABLE public.modmail_enabled TO peerdb;


--
-- Name: TABLE modmail_forced_guilds; Type: ACL; Schema: public; Owner: tickets
--

GRANT SELECT ON TABLE public.modmail_forced_guilds TO backup;
GRANT SELECT ON TABLE public.modmail_forced_guilds TO clickhouse;
GRANT SELECT ON TABLE public.modmail_forced_guilds TO peerdb;


--
-- Name: TABLE modmail_sessions; Type: ACL; Schema: public; Owner: tickets
--

GRANT SELECT ON TABLE public.modmail_sessions TO backup;
GRANT SELECT ON TABLE public.modmail_sessions TO clickhouse;
GRANT SELECT ON TABLE public.modmail_sessions TO peerdb;


--
-- Name: TABLE modmail_webhooks; Type: ACL; Schema: public; Owner: tickets
--

GRANT SELECT ON TABLE public.modmail_webhooks TO backup;
GRANT SELECT ON TABLE public.modmail_webhooks TO clickhouse;
GRANT SELECT ON TABLE public.modmail_webhooks TO peerdb;


--
-- Name: TABLE multi_panel_targets; Type: ACL; Schema: public; Owner: tickets
--

GRANT SELECT ON TABLE public.multi_panel_targets TO backup;
GRANT SELECT ON TABLE public.multi_panel_targets TO clickhouse;
GRANT SELECT ON TABLE public.multi_panel_targets TO peerdb;


--
-- Name: TABLE multi_panels; Type: ACL; Schema: public; Owner: tickets
--

GRANT SELECT ON TABLE public.multi_panels TO backup;
GRANT SELECT ON TABLE public.multi_panels TO clickhouse;
GRANT SELECT ON TABLE public.multi_panels TO peerdb;


--
-- Name: SEQUENCE multi_panels_id_seq; Type: ACL; Schema: public; Owner: tickets
--

GRANT SELECT,USAGE ON SEQUENCE public.multi_panels_id_seq TO backup;


--
-- Name: TABLE multi_server_skus; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.multi_server_skus TO backup;
GRANT SELECT ON TABLE public.multi_server_skus TO peerdb;


--
-- Name: TABLE naming_scheme; Type: ACL; Schema: public; Owner: tickets
--

GRANT SELECT ON TABLE public.naming_scheme TO backup;
GRANT SELECT ON TABLE public.naming_scheme TO clickhouse;
GRANT SELECT ON TABLE public.naming_scheme TO peerdb;


--
-- Name: TABLE on_call; Type: ACL; Schema: public; Owner: tickets
--

GRANT SELECT ON TABLE public.on_call TO backup;
GRANT SELECT ON TABLE public.on_call TO clickhouse;
GRANT SELECT ON TABLE public.on_call TO peerdb;


--
-- Name: TABLE panel_access_control_rules; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.panel_access_control_rules TO backup;
GRANT SELECT ON TABLE public.panel_access_control_rules TO peerdb;


--
-- Name: TABLE panel_role_mentions; Type: ACL; Schema: public; Owner: tickets
--

GRANT SELECT ON TABLE public.panel_role_mentions TO backup;
GRANT SELECT ON TABLE public.panel_role_mentions TO clickhouse;
GRANT SELECT ON TABLE public.panel_role_mentions TO peerdb;


--
-- Name: TABLE panel_teams; Type: ACL; Schema: public; Owner: tickets
--

GRANT SELECT ON TABLE public.panel_teams TO backup;
GRANT SELECT ON TABLE public.panel_teams TO clickhouse;
GRANT SELECT ON TABLE public.panel_teams TO peerdb;


--
-- Name: TABLE panel_user_mentions; Type: ACL; Schema: public; Owner: tickets
--

GRANT SELECT ON TABLE public.panel_user_mentions TO backup;
GRANT SELECT ON TABLE public.panel_user_mentions TO clickhouse;
GRANT SELECT ON TABLE public.panel_user_mentions TO peerdb;


--
-- Name: TABLE panels; Type: ACL; Schema: public; Owner: tickets
--

GRANT SELECT ON TABLE public.panels TO backup;
GRANT SELECT ON TABLE public.panels TO clickhouse;
GRANT SELECT ON TABLE public.panels TO peerdb;


--
-- Name: SEQUENCE panels_panel_id_seq; Type: ACL; Schema: public; Owner: tickets
--

GRANT SELECT,USAGE ON SEQUENCE public.panels_panel_id_seq TO backup;


--
-- Name: TABLE participant; Type: ACL; Schema: public; Owner: tickets
--

GRANT SELECT ON TABLE public.participant TO backup;
GRANT SELECT ON TABLE public.participant TO clickhouse;
GRANT SELECT ON TABLE public.participant TO peerdb;


--
-- Name: TABLE patreon_entitlements; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.patreon_entitlements TO backup;
GRANT SELECT ON TABLE public.patreon_entitlements TO peerdb;


--
-- Name: TABLE permissions; Type: ACL; Schema: public; Owner: tickets
--

GRANT SELECT ON TABLE public.permissions TO backup;
GRANT SELECT ON TABLE public.permissions TO clickhouse;
GRANT SELECT ON TABLE public.permissions TO peerdb;


--
-- Name: TABLE pg_stat_statements; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.pg_stat_statements TO peerdb;


--
-- Name: TABLE pg_stat_statements_info; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.pg_stat_statements_info TO peerdb;


--
-- Name: TABLE ping_everyone; Type: ACL; Schema: public; Owner: tickets
--

GRANT SELECT ON TABLE public.ping_everyone TO backup;
GRANT SELECT ON TABLE public.ping_everyone TO clickhouse;
GRANT SELECT ON TABLE public.ping_everyone TO peerdb;


--
-- Name: TABLE prefix; Type: ACL; Schema: public; Owner: tickets
--

GRANT SELECT ON TABLE public.prefix TO backup;
GRANT SELECT ON TABLE public.prefix TO clickhouse;
GRANT SELECT ON TABLE public.prefix TO peerdb;


--
-- Name: TABLE premium_guilds; Type: ACL; Schema: public; Owner: tickets
--

GRANT SELECT ON TABLE public.premium_guilds TO backup;
GRANT SELECT ON TABLE public.premium_guilds TO clickhouse;
GRANT SELECT ON TABLE public.premium_guilds TO peerdb;


--
-- Name: TABLE premium_keys; Type: ACL; Schema: public; Owner: tickets
--

GRANT SELECT ON TABLE public.premium_keys TO backup;
GRANT SELECT ON TABLE public.premium_keys TO clickhouse;
GRANT SELECT ON TABLE public.premium_keys TO peerdb;


--
-- Name: TABLE role_blacklist; Type: ACL; Schema: public; Owner: tickets
--

GRANT SELECT ON TABLE public.role_blacklist TO backup;
GRANT SELECT ON TABLE public.role_blacklist TO clickhouse;
GRANT SELECT ON TABLE public.role_blacklist TO peerdb;


--
-- Name: TABLE role_permissions; Type: ACL; Schema: public; Owner: tickets
--

GRANT SELECT ON TABLE public.role_permissions TO backup;
GRANT SELECT ON TABLE public.role_permissions TO clickhouse;
GRANT SELECT ON TABLE public.role_permissions TO peerdb;


--
-- Name: TABLE server_blacklist; Type: ACL; Schema: public; Owner: tickets
--

GRANT SELECT ON TABLE public.server_blacklist TO backup;
GRANT SELECT ON TABLE public.server_blacklist TO clickhouse;
GRANT SELECT ON TABLE public.server_blacklist TO peerdb;


--
-- Name: TABLE service_ratings; Type: ACL; Schema: public; Owner: tickets
--

GRANT SELECT ON TABLE public.service_ratings TO backup;
GRANT SELECT ON TABLE public.service_ratings TO clickhouse;
GRANT SELECT ON TABLE public.service_ratings TO peerdb;


--
-- Name: TABLE settings; Type: ACL; Schema: public; Owner: tickets
--

GRANT SELECT ON TABLE public.settings TO backup;
GRANT SELECT ON TABLE public.settings TO clickhouse;
GRANT SELECT ON TABLE public.settings TO peerdb;


--
-- Name: TABLE skus; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.skus TO backup;
GRANT SELECT ON TABLE public.skus TO peerdb;


--
-- Name: TABLE staff_override; Type: ACL; Schema: public; Owner: tickets
--

GRANT SELECT ON TABLE public.staff_override TO backup;
GRANT SELECT ON TABLE public.staff_override TO clickhouse;
GRANT SELECT ON TABLE public.staff_override TO peerdb;


--
-- Name: TABLE subscription_skus; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.subscription_skus TO backup;
GRANT SELECT ON TABLE public.subscription_skus TO peerdb;


--
-- Name: TABLE support_team; Type: ACL; Schema: public; Owner: tickets
--

GRANT SELECT ON TABLE public.support_team TO backup;
GRANT SELECT ON TABLE public.support_team TO clickhouse;
GRANT SELECT ON TABLE public.support_team TO peerdb;


--
-- Name: SEQUENCE support_team_id_seq; Type: ACL; Schema: public; Owner: tickets
--

GRANT SELECT,USAGE ON SEQUENCE public.support_team_id_seq TO backup;


--
-- Name: TABLE support_team_members; Type: ACL; Schema: public; Owner: tickets
--

GRANT SELECT ON TABLE public.support_team_members TO backup;
GRANT SELECT ON TABLE public.support_team_members TO clickhouse;
GRANT SELECT ON TABLE public.support_team_members TO peerdb;


--
-- Name: TABLE support_team_roles; Type: ACL; Schema: public; Owner: tickets
--

GRANT SELECT ON TABLE public.support_team_roles TO backup;
GRANT SELECT ON TABLE public.support_team_roles TO clickhouse;
GRANT SELECT ON TABLE public.support_team_roles TO peerdb;


--
-- Name: TABLE tags; Type: ACL; Schema: public; Owner: tickets
--

GRANT SELECT ON TABLE public.tags TO backup;
GRANT SELECT ON TABLE public.tags TO clickhouse;
GRANT SELECT ON TABLE public.tags TO peerdb;


--
-- Name: TABLE ticket_claims; Type: ACL; Schema: public; Owner: tickets
--

GRANT SELECT ON TABLE public.ticket_claims TO backup;
GRANT SELECT ON TABLE public.ticket_claims TO clickhouse;
GRANT SELECT ON TABLE public.ticket_claims TO peerdb;


--
-- Name: TABLE ticket_duration; Type: ACL; Schema: public; Owner: tickets
--

GRANT SELECT ON TABLE public.ticket_duration TO peerdb;


--
-- Name: TABLE ticket_last_message; Type: ACL; Schema: public; Owner: tickets
--

GRANT SELECT ON TABLE public.ticket_last_message TO backup;
GRANT SELECT ON TABLE public.ticket_last_message TO clickhouse;
GRANT SELECT ON TABLE public.ticket_last_message TO peerdb;


--
-- Name: TABLE ticket_limit; Type: ACL; Schema: public; Owner: tickets
--

GRANT SELECT ON TABLE public.ticket_limit TO backup;
GRANT SELECT ON TABLE public.ticket_limit TO clickhouse;
GRANT SELECT ON TABLE public.ticket_limit TO peerdb;


--
-- Name: TABLE ticket_members; Type: ACL; Schema: public; Owner: tickets
--

GRANT SELECT ON TABLE public.ticket_members TO backup;
GRANT SELECT ON TABLE public.ticket_members TO clickhouse;
GRANT SELECT ON TABLE public.ticket_members TO peerdb;


--
-- Name: TABLE ticket_permissions; Type: ACL; Schema: public; Owner: tickets
--

GRANT SELECT ON TABLE public.ticket_permissions TO backup;
GRANT SELECT ON TABLE public.ticket_permissions TO clickhouse;
GRANT SELECT ON TABLE public.ticket_permissions TO peerdb;


--
-- Name: TABLE top_close_reasons; Type: ACL; Schema: public; Owner: tickets
--

GRANT SELECT ON TABLE public.top_close_reasons TO peerdb;


--
-- Name: TABLE translations; Type: ACL; Schema: public; Owner: tickets
--

GRANT SELECT ON TABLE public.translations TO backup;
GRANT SELECT ON TABLE public.translations TO clickhouse;
GRANT SELECT ON TABLE public.translations TO peerdb;


--
-- Name: TABLE used_keys; Type: ACL; Schema: public; Owner: tickets
--

GRANT SELECT ON TABLE public.used_keys TO backup;
GRANT SELECT ON TABLE public.used_keys TO clickhouse;
GRANT SELECT ON TABLE public.used_keys TO peerdb;


--
-- Name: TABLE user_guilds; Type: ACL; Schema: public; Owner: tickets
--

GRANT SELECT ON TABLE public.user_guilds TO backup;
GRANT SELECT ON TABLE public.user_guilds TO clickhouse;
GRANT SELECT ON TABLE public.user_guilds TO peerdb;


--
-- Name: TABLE users_can_close; Type: ACL; Schema: public; Owner: tickets
--

GRANT SELECT ON TABLE public.users_can_close TO backup;
GRANT SELECT ON TABLE public.users_can_close TO clickhouse;
GRANT SELECT ON TABLE public.users_can_close TO peerdb;


--
-- Name: TABLE vote_credits; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.vote_credits TO backup;
GRANT SELECT ON TABLE public.vote_credits TO peerdb;
GRANT ALL ON TABLE public.vote_credits TO votelistener;


--
-- Name: TABLE webhooks; Type: ACL; Schema: public; Owner: tickets
--

GRANT SELECT ON TABLE public.webhooks TO backup;
GRANT SELECT ON TABLE public.webhooks TO clickhouse;
GRANT SELECT ON TABLE public.webhooks TO peerdb;


--
-- Name: TABLE welcome_messages; Type: ACL; Schema: public; Owner: tickets
--

GRANT SELECT ON TABLE public.welcome_messages TO backup;
GRANT SELECT ON TABLE public.welcome_messages TO clickhouse;
GRANT SELECT ON TABLE public.welcome_messages TO peerdb;


--
-- Name: TABLE whitelabel; Type: ACL; Schema: public; Owner: tickets
--

GRANT SELECT ON TABLE public.whitelabel TO backup;
GRANT SELECT ON TABLE public.whitelabel TO clickhouse;
GRANT SELECT ON TABLE public.whitelabel TO peerdb;


--
-- Name: TABLE whitelabel_errors; Type: ACL; Schema: public; Owner: tickets
--

GRANT SELECT ON TABLE public.whitelabel_errors TO backup;
GRANT SELECT ON TABLE public.whitelabel_errors TO clickhouse;
GRANT SELECT ON TABLE public.whitelabel_errors TO peerdb;


--
-- Name: SEQUENCE whitelabel_errors_error_id_seq; Type: ACL; Schema: public; Owner: tickets
--

GRANT SELECT,USAGE ON SEQUENCE public.whitelabel_errors_error_id_seq TO backup;


--
-- Name: TABLE whitelabel_guilds; Type: ACL; Schema: public; Owner: tickets
--

GRANT SELECT ON TABLE public.whitelabel_guilds TO backup;
GRANT SELECT ON TABLE public.whitelabel_guilds TO clickhouse;
GRANT SELECT ON TABLE public.whitelabel_guilds TO peerdb;


--
-- Name: TABLE whitelabel_keys_remove; Type: ACL; Schema: public; Owner: tickets
--

GRANT SELECT ON TABLE public.whitelabel_keys_remove TO backup;
GRANT SELECT ON TABLE public.whitelabel_keys_remove TO clickhouse;
GRANT SELECT ON TABLE public.whitelabel_keys_remove TO peerdb;


--
-- Name: TABLE whitelabel_skus; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.whitelabel_skus TO backup;
GRANT SELECT ON TABLE public.whitelabel_skus TO peerdb;


--
-- Name: TABLE whitelabel_statuses; Type: ACL; Schema: public; Owner: tickets
--

GRANT SELECT ON TABLE public.whitelabel_statuses TO backup;
GRANT SELECT ON TABLE public.whitelabel_statuses TO clickhouse;
GRANT SELECT ON TABLE public.whitelabel_statuses TO peerdb;


--
-- Name: TABLE whitelabel_users; Type: ACL; Schema: public; Owner: tickets
--

GRANT SELECT ON TABLE public.whitelabel_users TO backup;
GRANT SELECT ON TABLE public.whitelabel_users TO clickhouse;
GRANT SELECT ON TABLE public.whitelabel_users TO peerdb;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: public; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT SELECT ON SEQUENCES TO backup;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: public; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT SELECT ON TABLES TO backup;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT SELECT ON TABLES TO peerdb;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: -; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres GRANT USAGE ON SEQUENCES TO backup;


--
-- Name: DEFAULT PRIVILEGES FOR SCHEMAS; Type: DEFAULT ACL; Schema: -; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres GRANT USAGE ON SCHEMAS TO backup;


--
-- PostgreSQL database dump complete
--

