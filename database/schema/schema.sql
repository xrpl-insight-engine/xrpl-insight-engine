--
-- PostgreSQL database dump
--

\restrict G83jee5ysSgOPlTuMqPJGjYZengtlXDtyLEFk5y2oXaLaodDBIc8R5Jdd9O14Ca

-- Dumped from database version 18.1
-- Dumped by pg_dump version 18.1

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

ALTER TABLE IF EXISTS ONLY public.token_states DROP CONSTRAINT IF EXISTS token_states_token_id_fkey;
ALTER TABLE IF EXISTS ONLY public.token_momentum DROP CONSTRAINT IF EXISTS token_momentum_token_id_fkey;
ALTER TABLE IF EXISTS ONLY public.token_features DROP CONSTRAINT IF EXISTS token_features_token_id_fkey;
ALTER TABLE IF EXISTS ONLY public.token_feature_snapshots DROP CONSTRAINT IF EXISTS token_feature_snapshots_token_id_fkey;
ALTER TABLE IF EXISTS ONLY public.token_alerts DROP CONSTRAINT IF EXISTS token_alerts_token_id_fkey;
ALTER TABLE IF EXISTS ONLY public.token_alert_flags DROP CONSTRAINT IF EXISTS token_alert_flags_token_id_fkey;
ALTER TABLE IF EXISTS ONLY public.shortlisted_tokens DROP CONSTRAINT IF EXISTS shortlisted_tokens_token_id_fkey;
ALTER TABLE IF EXISTS ONLY public.tokens DROP CONSTRAINT IF EXISTS fk_collision_parent;
ALTER TABLE IF EXISTS ONLY public.active_alerts DROP CONSTRAINT IF EXISTS active_alerts_token_id_fkey;
DROP INDEX IF EXISTS public.idx_tokens_meme_qualified;
DROP INDEX IF EXISTS public.idx_tokens_last_scanned;
DROP INDEX IF EXISTS public.idx_tokens_issuer;
DROP INDEX IF EXISTS public.idx_tokens_decoded_name;
DROP INDEX IF EXISTS public.idx_tokens_currency;
DROP INDEX IF EXISTS public.idx_tokens_canonical;
DROP INDEX IF EXISTS public.idx_token_states_state;
DROP INDEX IF EXISTS public.idx_token_features_token_id;
DROP INDEX IF EXISTS public.idx_token_features_snapshot_time;
DROP INDEX IF EXISTS public.idx_token_alerts_token;
DROP INDEX IF EXISTS public.idx_snapshot_token_time;
DROP INDEX IF EXISTS public.idx_shortlisted_score;
DROP INDEX IF EXISTS public.idx_momentum_score;
DROP INDEX IF EXISTS public.idx_feed_score;
DROP INDEX IF EXISTS public.idx_alert_flags_spike;
DROP INDEX IF EXISTS public.idx_active_alerts_type;
ALTER TABLE IF EXISTS ONLY public.tokens DROP CONSTRAINT IF EXISTS tokens_pkey;
ALTER TABLE IF EXISTS ONLY public.tokens DROP CONSTRAINT IF EXISTS tokens_currency_issuer_key;
ALTER TABLE IF EXISTS ONLY public.token_states DROP CONSTRAINT IF EXISTS token_states_pkey;
ALTER TABLE IF EXISTS ONLY public.token_momentum DROP CONSTRAINT IF EXISTS token_momentum_pkey;
ALTER TABLE IF EXISTS ONLY public.token_features DROP CONSTRAINT IF EXISTS token_features_token_id_unique;
ALTER TABLE IF EXISTS ONLY public.token_features DROP CONSTRAINT IF EXISTS token_features_token_id_snapshot_time_key;
ALTER TABLE IF EXISTS ONLY public.token_features DROP CONSTRAINT IF EXISTS token_features_pkey;
ALTER TABLE IF EXISTS ONLY public.token_feature_snapshots DROP CONSTRAINT IF EXISTS token_feature_snapshots_pkey;
ALTER TABLE IF EXISTS ONLY public.token_alerts DROP CONSTRAINT IF EXISTS token_alerts_token_id_alert_type_key;
ALTER TABLE IF EXISTS ONLY public.token_alerts DROP CONSTRAINT IF EXISTS token_alerts_pkey;
ALTER TABLE IF EXISTS ONLY public.token_alert_flags DROP CONSTRAINT IF EXISTS token_alert_flags_pkey;
ALTER TABLE IF EXISTS ONLY public.shortlisted_tokens DROP CONSTRAINT IF EXISTS shortlisted_tokens_pkey;
ALTER TABLE IF EXISTS ONLY public.scanner_state DROP CONSTRAINT IF EXISTS scanner_state_pkey;
ALTER TABLE IF EXISTS ONLY public.feed_rankings DROP CONSTRAINT IF EXISTS feed_rankings_pkey;
ALTER TABLE IF EXISTS ONLY public.active_alerts DROP CONSTRAINT IF EXISTS active_alerts_pkey;
ALTER TABLE IF EXISTS public.tokens ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.token_features ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.token_feature_snapshots ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.token_alerts ALTER COLUMN id DROP DEFAULT;
DROP SEQUENCE IF EXISTS public.tokens_id_seq;
DROP SEQUENCE IF EXISTS public.token_features_id_seq;
DROP TABLE IF EXISTS public.token_features;
DROP SEQUENCE IF EXISTS public.token_feature_snapshots_id_seq;
DROP SEQUENCE IF EXISTS public.token_alerts_id_seq;
DROP TABLE IF EXISTS public.token_alerts;
DROP TABLE IF EXISTS public.token_alert_flags;
DROP VIEW IF EXISTS public.system_health_dashboard;
DROP TABLE IF EXISTS public.tokens;
DROP TABLE IF EXISTS public.token_states;
DROP TABLE IF EXISTS public.token_momentum;
DROP TABLE IF EXISTS public.token_feature_snapshots;
DROP TABLE IF EXISTS public.shortlisted_tokens;
DROP TABLE IF EXISTS public.scanner_state;
DROP TABLE IF EXISTS public.feed_rankings;
DROP TABLE IF EXISTS public.active_alerts;
SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: active_alerts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.active_alerts (
    token_id integer NOT NULL,
    alert_type text NOT NULL,
    alert_strength double precision DEFAULT 0,
    first_triggered timestamp without time zone DEFAULT now(),
    last_seen timestamp without time zone DEFAULT now()
);


--
-- Name: feed_rankings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.feed_rankings (
    token_id integer NOT NULL,
    feed_score double precision,
    feed_stage text,
    momentum_score double precision,
    alpha_score double precision,
    liquidity_15m double precision,
    canonical_confidence double precision,
    last_updated timestamp without time zone
);


--
-- Name: scanner_state; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.scanner_state (
    key text NOT NULL,
    value text NOT NULL,
    updated_at timestamp without time zone DEFAULT now()
);


--
-- Name: shortlisted_tokens; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.shortlisted_tokens (
    token_id integer NOT NULL,
    shortlist_score double precision NOT NULL,
    reasons text[] NOT NULL,
    last_updated timestamp without time zone DEFAULT now()
);


--
-- Name: token_feature_snapshots; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.token_feature_snapshots (
    id integer NOT NULL,
    token_id integer NOT NULL,
    snapshot_time timestamp without time zone DEFAULT now() NOT NULL,
    liquidity_xrp double precision,
    holders integer,
    alpha_score double precision,
    age_seconds double precision,
    canonical_confidence double precision,
    tx_surge_norm double precision,
    holder_growth_norm double precision,
    liquidity_shift_norm double precision
);


--
-- Name: token_momentum; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.token_momentum (
    token_id integer NOT NULL,
    liquidity_15m double precision DEFAULT 0,
    liquidity_1h double precision DEFAULT 0,
    liquidity_6h double precision DEFAULT 0,
    holders_1h integer DEFAULT 0,
    holders_6h integer DEFAULT 0,
    holders_24h integer DEFAULT 0,
    momentum_score double precision DEFAULT 0,
    last_updated timestamp without time zone DEFAULT now(),
    baseline_liquidity double precision DEFAULT 0,
    baseline_holders integer DEFAULT 0,
    liq_15m_norm double precision DEFAULT 0,
    liq_1h_norm double precision DEFAULT 0,
    liq_6h_norm double precision DEFAULT 0,
    holders_1h_norm double precision DEFAULT 0,
    holders_6h_norm double precision DEFAULT 0,
    holders_24h_norm double precision DEFAULT 0
);


--
-- Name: token_states; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.token_states (
    token_id integer NOT NULL,
    state text NOT NULL,
    last_updated timestamp without time zone DEFAULT now()
);


--
-- Name: tokens; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tokens (
    id integer NOT NULL,
    currency text NOT NULL,
    issuer text NOT NULL,
    decoded_name text,
    method text,
    first_seen timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    holders integer DEFAULT 0,
    liquidity_xrp double precision DEFAULT 0,
    risk_score integer DEFAULT 0,
    alpha_score double precision DEFAULT 0,
    last_scanned timestamp without time zone,
    rejected boolean DEFAULT false,
    name_collision boolean DEFAULT false,
    collision_parent_id integer,
    is_canonical boolean DEFAULT false,
    canonical_confidence double precision DEFAULT 0,
    canonical_last_changed timestamp without time zone,
    meme_score double precision DEFAULT 0,
    meme_qualified boolean DEFAULT false,
    last_analysis_status text DEFAULT 'ok'::text,
    last_analysis_error text,
    last_analysis_at timestamp without time zone
);


--
-- Name: system_health_dashboard; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.system_health_dashboard AS
 SELECT ( SELECT count(*) AS count
           FROM public.token_feature_snapshots) AS total_snapshots,
    ( SELECT count(*) AS count
           FROM public.token_feature_snapshots
          WHERE (token_feature_snapshots.snapshot_time > (now() - '00:15:00'::interval))) AS snapshots_last_15m,
    ( SELECT (now() - (max(token_feature_snapshots.snapshot_time))::timestamp with time zone)
           FROM public.token_feature_snapshots) AS feature_store_lag,
    ( SELECT count(*) AS count
           FROM public.token_momentum) AS momentum_rows,
    ( SELECT count(*) AS count
           FROM public.token_momentum
          WHERE (token_momentum.momentum_score > (0)::double precision)) AS momentum_active_tokens,
    ( SELECT count(*) AS count
           FROM public.active_alerts) AS active_alerts,
    ( SELECT count(DISTINCT active_alerts.alert_type) AS count
           FROM public.active_alerts) AS alert_types,
    ( SELECT count(*) AS count
           FROM public.tokens) AS total_tokens,
    ( SELECT count(*) AS count
           FROM public.tokens
          WHERE (tokens.is_canonical = true)) AS canonical_tokens,
    ( SELECT count(*) AS count
           FROM public.feed_rankings) AS feed_rows,
    ( SELECT count(*) AS count
           FROM public.token_states
          WHERE (token_states.state = 'dead'::text)) AS dead_tokens,
    ( SELECT count(*) AS count
           FROM public.token_states
          WHERE (token_states.state <> 'dead'::text)) AS active_or_neutral_tokens;


--
-- Name: token_alert_flags; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.token_alert_flags (
    token_id integer NOT NULL,
    momentum_spike boolean DEFAULT false,
    liquidity_spike boolean DEFAULT false,
    early_breakout boolean DEFAULT false,
    revival boolean DEFAULT false,
    last_updated timestamp without time zone DEFAULT now()
);


--
-- Name: token_alerts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.token_alerts (
    id integer NOT NULL,
    token_id integer NOT NULL,
    alert_type text NOT NULL,
    severity integer DEFAULT 1,
    value double precision,
    created_at timestamp without time zone DEFAULT now()
);


--
-- Name: token_alerts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.token_alerts_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: token_alerts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.token_alerts_id_seq OWNED BY public.token_alerts.id;


--
-- Name: token_feature_snapshots_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.token_feature_snapshots_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: token_feature_snapshots_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.token_feature_snapshots_id_seq OWNED BY public.token_feature_snapshots.id;


--
-- Name: token_features; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.token_features (
    id integer NOT NULL,
    token_id integer NOT NULL,
    snapshot_time timestamp without time zone DEFAULT now() NOT NULL,
    decoded_name text,
    is_canonical boolean,
    alpha_score double precision,
    liquidity_xrp double precision,
    holders integer,
    risk_score integer,
    canonical_confidence double precision,
    source text DEFAULT 'feature_store'::text,
    age_seconds double precision,
    last_updated timestamp without time zone
);


--
-- Name: token_features_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.token_features_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: token_features_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.token_features_id_seq OWNED BY public.token_features.id;


--
-- Name: tokens_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.tokens_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tokens_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.tokens_id_seq OWNED BY public.tokens.id;


--
-- Name: token_alerts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.token_alerts ALTER COLUMN id SET DEFAULT nextval('public.token_alerts_id_seq'::regclass);


--
-- Name: token_feature_snapshots id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.token_feature_snapshots ALTER COLUMN id SET DEFAULT nextval('public.token_feature_snapshots_id_seq'::regclass);


--
-- Name: token_features id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.token_features ALTER COLUMN id SET DEFAULT nextval('public.token_features_id_seq'::regclass);


--
-- Name: tokens id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tokens ALTER COLUMN id SET DEFAULT nextval('public.tokens_id_seq'::regclass);


--
-- Name: active_alerts active_alerts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_alerts
    ADD CONSTRAINT active_alerts_pkey PRIMARY KEY (token_id, alert_type);


--
-- Name: feed_rankings feed_rankings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.feed_rankings
    ADD CONSTRAINT feed_rankings_pkey PRIMARY KEY (token_id);


--
-- Name: scanner_state scanner_state_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.scanner_state
    ADD CONSTRAINT scanner_state_pkey PRIMARY KEY (key);


--
-- Name: shortlisted_tokens shortlisted_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shortlisted_tokens
    ADD CONSTRAINT shortlisted_tokens_pkey PRIMARY KEY (token_id);


--
-- Name: token_alert_flags token_alert_flags_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.token_alert_flags
    ADD CONSTRAINT token_alert_flags_pkey PRIMARY KEY (token_id);


--
-- Name: token_alerts token_alerts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.token_alerts
    ADD CONSTRAINT token_alerts_pkey PRIMARY KEY (id);


--
-- Name: token_alerts token_alerts_token_id_alert_type_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.token_alerts
    ADD CONSTRAINT token_alerts_token_id_alert_type_key UNIQUE (token_id, alert_type);


--
-- Name: token_feature_snapshots token_feature_snapshots_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.token_feature_snapshots
    ADD CONSTRAINT token_feature_snapshots_pkey PRIMARY KEY (id);


--
-- Name: token_features token_features_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.token_features
    ADD CONSTRAINT token_features_pkey PRIMARY KEY (id);


--
-- Name: token_features token_features_token_id_snapshot_time_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.token_features
    ADD CONSTRAINT token_features_token_id_snapshot_time_key UNIQUE (token_id, snapshot_time);


--
-- Name: token_features token_features_token_id_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.token_features
    ADD CONSTRAINT token_features_token_id_unique UNIQUE (token_id);


--
-- Name: token_momentum token_momentum_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.token_momentum
    ADD CONSTRAINT token_momentum_pkey PRIMARY KEY (token_id);


--
-- Name: token_states token_states_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.token_states
    ADD CONSTRAINT token_states_pkey PRIMARY KEY (token_id);


--
-- Name: tokens tokens_currency_issuer_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tokens
    ADD CONSTRAINT tokens_currency_issuer_key UNIQUE (currency, issuer);


--
-- Name: tokens tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tokens
    ADD CONSTRAINT tokens_pkey PRIMARY KEY (id);


--
-- Name: idx_active_alerts_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_active_alerts_type ON public.active_alerts USING btree (alert_type);


--
-- Name: idx_alert_flags_spike; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_alert_flags_spike ON public.token_alert_flags USING btree (momentum_spike, liquidity_spike);


--
-- Name: idx_feed_score; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_feed_score ON public.feed_rankings USING btree (feed_score DESC);


--
-- Name: idx_momentum_score; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_momentum_score ON public.token_momentum USING btree (momentum_score DESC);


--
-- Name: idx_shortlisted_score; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_shortlisted_score ON public.shortlisted_tokens USING btree (shortlist_score DESC);


--
-- Name: idx_snapshot_token_time; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_snapshot_token_time ON public.token_feature_snapshots USING btree (token_id, snapshot_time DESC);


--
-- Name: idx_token_alerts_token; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_token_alerts_token ON public.token_alerts USING btree (token_id);


--
-- Name: idx_token_features_snapshot_time; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_token_features_snapshot_time ON public.token_features USING btree (snapshot_time);


--
-- Name: idx_token_features_token_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_token_features_token_id ON public.token_features USING btree (token_id);


--
-- Name: idx_token_states_state; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_token_states_state ON public.token_states USING btree (state);


--
-- Name: idx_tokens_canonical; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_tokens_canonical ON public.tokens USING btree (is_canonical);


--
-- Name: idx_tokens_currency; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_tokens_currency ON public.tokens USING btree (currency);


--
-- Name: idx_tokens_decoded_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_tokens_decoded_name ON public.tokens USING btree (decoded_name);


--
-- Name: idx_tokens_issuer; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_tokens_issuer ON public.tokens USING btree (issuer);


--
-- Name: idx_tokens_last_scanned; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_tokens_last_scanned ON public.tokens USING btree (last_scanned);


--
-- Name: idx_tokens_meme_qualified; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_tokens_meme_qualified ON public.tokens USING btree (meme_qualified);


--
-- Name: active_alerts active_alerts_token_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_alerts
    ADD CONSTRAINT active_alerts_token_id_fkey FOREIGN KEY (token_id) REFERENCES public.tokens(id) ON DELETE CASCADE;


--
-- Name: tokens fk_collision_parent; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tokens
    ADD CONSTRAINT fk_collision_parent FOREIGN KEY (collision_parent_id) REFERENCES public.tokens(id) ON DELETE SET NULL;


--
-- Name: shortlisted_tokens shortlisted_tokens_token_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shortlisted_tokens
    ADD CONSTRAINT shortlisted_tokens_token_id_fkey FOREIGN KEY (token_id) REFERENCES public.tokens(id) ON DELETE CASCADE;


--
-- Name: token_alert_flags token_alert_flags_token_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.token_alert_flags
    ADD CONSTRAINT token_alert_flags_token_id_fkey FOREIGN KEY (token_id) REFERENCES public.tokens(id) ON DELETE CASCADE;


--
-- Name: token_alerts token_alerts_token_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.token_alerts
    ADD CONSTRAINT token_alerts_token_id_fkey FOREIGN KEY (token_id) REFERENCES public.tokens(id) ON DELETE CASCADE;


--
-- Name: token_feature_snapshots token_feature_snapshots_token_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.token_feature_snapshots
    ADD CONSTRAINT token_feature_snapshots_token_id_fkey FOREIGN KEY (token_id) REFERENCES public.tokens(id) ON DELETE CASCADE;


--
-- Name: token_features token_features_token_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.token_features
    ADD CONSTRAINT token_features_token_id_fkey FOREIGN KEY (token_id) REFERENCES public.tokens(id) ON DELETE CASCADE;


--
-- Name: token_momentum token_momentum_token_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.token_momentum
    ADD CONSTRAINT token_momentum_token_id_fkey FOREIGN KEY (token_id) REFERENCES public.tokens(id) ON DELETE CASCADE;


--
-- Name: token_states token_states_token_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.token_states
    ADD CONSTRAINT token_states_token_id_fkey FOREIGN KEY (token_id) REFERENCES public.tokens(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

\unrestrict G83jee5ysSgOPlTuMqPJGjYZengtlXDtyLEFk5y2oXaLaodDBIc8R5Jdd9O14Ca

