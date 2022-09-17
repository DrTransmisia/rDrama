--
-- PostgreSQL database dump
--

-- Dumped from database version 14.4
-- Dumped by pg_dump version 14.5 (Ubuntu 14.5-1.pgdg20.04+1)

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
-- Name: fuzzystrmatch; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS fuzzystrmatch WITH SCHEMA public;


--
-- Name: EXTENSION fuzzystrmatch; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION fuzzystrmatch IS 'determine similarities and distance between strings';


--
-- Name: pg_stat_statements; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_stat_statements WITH SCHEMA public;


--
-- Name: EXTENSION pg_stat_statements; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pg_stat_statements IS 'track planning and execution statistics of all SQL statements executed';


--
-- Name: pg_trgm; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_trgm WITH SCHEMA public;


--
-- Name: EXTENSION pg_trgm; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pg_trgm IS 'text similarity measurement and index searching based on trigrams';


--
-- Name: casino_game_currency; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.casino_game_currency AS ENUM (
    'coins',
    'procoins'
);


--
-- Name: casino_game_kind; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.casino_game_kind AS ENUM (
    'blackjack',
    'slots',
    'roulette'
);


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: submissions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.submissions (
    id integer NOT NULL,
    author_id integer NOT NULL,
    created_utc integer NOT NULL,
    is_banned boolean DEFAULT false NOT NULL,
    over_18 boolean DEFAULT false NOT NULL,
    distinguish_level integer DEFAULT 0 NOT NULL,
    deleted_utc integer DEFAULT 0 NOT NULL,
    is_approved integer,
    edited_utc integer DEFAULT 0 NOT NULL,
    is_pinned boolean DEFAULT false NOT NULL,
    upvotes integer DEFAULT 1 NOT NULL,
    downvotes integer DEFAULT 0 NOT NULL,
    app_id integer,
    thumburl character varying(200),
    private boolean DEFAULT false NOT NULL,
    views integer DEFAULT 0 NOT NULL,
    is_bot boolean DEFAULT false NOT NULL,
    bannedfor character varying(40),
    comment_count integer DEFAULT 0 NOT NULL,
    club boolean DEFAULT false NOT NULL,
    stickied character varying(40),
    title character varying(500) NOT NULL,
    url character varying(2083),
    body character varying(20000),
    body_html character varying(40000),
    embed_url character varying(1500),
    ban_reason character varying(25),
    title_html character varying(1500) NOT NULL,
    realupvotes integer,
    flair character varying(350),
    stickied_utc integer,
    ghost boolean DEFAULT false NOT NULL,
    sub character varying(25),
    new boolean,
    hole_pinned character varying(30),
    category_id integer,
    notify boolean NOT NULL
);


--
-- Name: bump_utc(public.submissions); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.bump_utc(public.submissions) RETURNS integer
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$
      SELECT CREATED_UTC
      FROM comments
      WHERE parent_submission = $1.id
      ORDER BY created_utc desc
      LIMIT 1
      $_$;


--
-- Name: alts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.alts (
    user1 integer NOT NULL,
    user2 integer NOT NULL,
    is_manual boolean DEFAULT false NOT NULL,
    created_utc integer,
    CONSTRAINT alts_cant_be_equal CHECK ((user1 <> user2))
);


--
-- Name: award_relationships; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.award_relationships (
    id integer NOT NULL,
    user_id integer NOT NULL,
    submission_id integer,
    comment_id integer,
    kind character varying(20) NOT NULL,
    awarded_utc integer,
    granted boolean,
    created_utc integer
);


--
-- Name: award_relationships_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.award_relationships_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: award_relationships_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.award_relationships_id_seq OWNED BY public.award_relationships.id;


--
-- Name: badge_defs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.badge_defs (
    id integer NOT NULL,
    name character varying(50) NOT NULL,
    description character varying(200),
    created_utc integer
);


--
-- Name: badge_defs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.badge_defs_id_seq
    AS integer
    START WITH 106
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: badge_defs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.badge_defs_id_seq OWNED BY public.badge_defs.id;


--
-- Name: badges; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.badges (
    badge_id integer NOT NULL,
    user_id integer NOT NULL,
    description character varying(256),
    url character varying(256),
    created_utc integer NOT NULL
);


--
-- Name: banneddomains; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.banneddomains (
    domain character varying(100) NOT NULL,
    reason character varying(100) NOT NULL,
    created_utc integer
);


--
-- Name: casino_games; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.casino_games (
    id integer NOT NULL,
    user_id integer NOT NULL,
    created_utc integer NOT NULL,
    active boolean DEFAULT true NOT NULL,
    currency public.casino_game_currency NOT NULL,
    wager integer NOT NULL,
    winnings integer NOT NULL,
    kind public.casino_game_kind NOT NULL,
    game_state jsonb NOT NULL
);


--
-- Name: casino_games_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.casino_games_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: casino_games_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.casino_games_id_seq OWNED BY public.casino_games.id;


--
-- Name: category; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.category (
    id integer NOT NULL,
    name character varying(128) NOT NULL,
    sub character varying(25),
    color_text character(6),
    color_bg character(6),
    created_utc integer
);


--
-- Name: category_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.category_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: category_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.category_id_seq OWNED BY public.category.id;


--
-- Name: client_auths; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.client_auths (
    user_id integer NOT NULL,
    oauth_client integer NOT NULL,
    access_token character(128) NOT NULL,
    created_utc integer
);


--
-- Name: comment_option_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.comment_option_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: comment_option_votes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.comment_option_votes (
    option_id integer NOT NULL,
    user_id integer NOT NULL,
    created_utc integer NOT NULL,
    comment_id integer
);


--
-- Name: comment_options; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.comment_options (
    id integer DEFAULT nextval('public.comment_option_id_seq'::regclass) NOT NULL,
    comment_id integer NOT NULL,
    body_html character varying(500) NOT NULL,
    exclusive integer NOT NULL,
    created_utc integer
);


--
-- Name: comment_save_relationship; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.comment_save_relationship (
    user_id integer NOT NULL,
    comment_id integer NOT NULL,
    created_utc integer
);


--
-- Name: commentflags; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.commentflags (
    user_id integer NOT NULL,
    comment_id integer NOT NULL,
    reason character varying(350),
    created_utc integer NOT NULL
);


--
-- Name: comments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.comments (
    id integer NOT NULL,
    author_id integer NOT NULL,
    created_utc integer NOT NULL,
    parent_submission integer,
    is_banned boolean DEFAULT false NOT NULL,
    distinguish_level integer DEFAULT 0 NOT NULL,
    edited_utc integer DEFAULT 0 NOT NULL,
    deleted_utc integer DEFAULT 0 NOT NULL,
    is_approved integer,
    level integer DEFAULT 0 NOT NULL,
    parent_comment_id integer,
    over_18 boolean DEFAULT false NOT NULL,
    upvotes integer DEFAULT 1 NOT NULL,
    downvotes integer DEFAULT 0 NOT NULL,
    is_bot boolean DEFAULT false NOT NULL,
    app_id integer,
    sentto integer,
    bannedfor character varying(40),
    stickied character varying(40),
    body character varying(10000),
    body_html character varying(40000),
    ban_reason character varying(25),
    realupvotes integer DEFAULT 1 NOT NULL,
    top_comment_id integer,
    stickied_utc integer,
    ghost boolean DEFAULT false NOT NULL,
    slots_result character varying(36),
    blackjack_result character varying(860),
    treasure_amount character varying(10),
    wordle_result character varying(115)
);


--
-- Name: comments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.comments_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: comments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.comments_id_seq OWNED BY public.comments.id;


--
-- Name: commentvotes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.commentvotes (
    comment_id integer NOT NULL,
    vote_type integer NOT NULL,
    user_id integer NOT NULL,
    app_id integer,
    "real" boolean DEFAULT true NOT NULL,
    created_utc integer NOT NULL
);


--
-- Name: exiles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.exiles (
    user_id integer NOT NULL,
    sub character varying(25) NOT NULL,
    exiler_id integer NOT NULL,
    created_utc integer
);


--
-- Name: flags; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.flags (
    user_id integer NOT NULL,
    post_id integer NOT NULL,
    reason character varying(350),
    created_utc integer NOT NULL
);


--
-- Name: follows; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.follows (
    user_id integer NOT NULL,
    target_id integer NOT NULL,
    created_utc integer NOT NULL
);


--
-- Name: hat_defs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.hat_defs (
    id integer NOT NULL,
    name character varying(50) NOT NULL,
    description character varying(300) NOT NULL,
    author_id integer NOT NULL,
    price integer NOT NULL,
    submitter_id integer,
    created_utc integer
);


--
-- Name: hat_defs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.hat_defs_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: hat_defs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.hat_defs_id_seq OWNED BY public.hat_defs.id;


--
-- Name: hats; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.hats (
    hat_id integer NOT NULL,
    user_id integer NOT NULL,
    equipped boolean,
    created_utc integer
);


--
-- Name: lotteries; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.lotteries (
    id integer NOT NULL,
    is_active boolean DEFAULT false NOT NULL,
    ends_at integer DEFAULT 0 NOT NULL,
    prize integer DEFAULT 0 NOT NULL,
    tickets_sold integer DEFAULT 0 NOT NULL,
    winner_id integer,
    created_utc integer
);


--
-- Name: lotteries_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.lotteries_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: lotteries_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.lotteries_id_seq OWNED BY public.lotteries.id;


--
-- Name: marseys; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.marseys (
    name character varying(30) NOT NULL,
    author_id integer NOT NULL,
    tags character varying(200) NOT NULL,
    count integer DEFAULT 0 NOT NULL,
    submitter_id integer,
    created_utc integer
);


--
-- Name: modactions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.modactions (
    id integer NOT NULL,
    user_id integer,
    target_user_id integer,
    target_submission_id integer,
    target_comment_id integer,
    created_utc integer NOT NULL,
    kind character varying(32) DEFAULT NULL::character varying,
    _note character varying(500) DEFAULT NULL::character varying
);


--
-- Name: modactions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.modactions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: modactions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.modactions_id_seq OWNED BY public.modactions.id;


--
-- Name: mods; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mods (
    user_id integer NOT NULL,
    sub character varying(25) NOT NULL,
    created_utc integer NOT NULL
);


--
-- Name: notifications; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.notifications (
    user_id integer NOT NULL,
    comment_id integer NOT NULL,
    read boolean NOT NULL,
    created_utc integer NOT NULL
);


--
-- Name: oauth_apps; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oauth_apps (
    id integer NOT NULL,
    client_id character(64),
    app_name character varying(50) NOT NULL,
    redirect_uri character varying(4096) NOT NULL,
    author_id integer NOT NULL,
    description character varying(256) NOT NULL,
    created_utc integer
);


--
-- Name: oauth_apps_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.oauth_apps_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oauth_apps_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.oauth_apps_id_seq OWNED BY public.oauth_apps.id;


--
-- Name: pgbench_accounts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.pgbench_accounts (
    aid integer NOT NULL,
    bid integer,
    abalance integer,
    filler character(84)
)
WITH (fillfactor='100');


--
-- Name: pgbench_branches; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.pgbench_branches (
    bid integer NOT NULL,
    bbalance integer,
    filler character(88)
)
WITH (fillfactor='100');


--
-- Name: pgbench_history; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.pgbench_history (
    tid integer,
    bid integer,
    aid integer,
    delta integer,
    mtime timestamp without time zone,
    filler character(22)
);


--
-- Name: pgbench_tellers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.pgbench_tellers (
    tid integer NOT NULL,
    bid integer,
    tbalance integer,
    filler character(84)
)
WITH (fillfactor='100');


--
-- Name: save_relationship; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.save_relationship (
    submission_id integer NOT NULL,
    user_id integer NOT NULL,
    created_utc integer
);


--
-- Name: sub_blocks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sub_blocks (
    user_id integer NOT NULL,
    sub character varying(25) NOT NULL,
    created_utc integer
);


--
-- Name: sub_joins; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sub_joins (
    user_id integer NOT NULL,
    sub character varying(25) NOT NULL,
    created_utc integer
);


--
-- Name: sub_subscriptions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sub_subscriptions (
    user_id integer NOT NULL,
    sub character varying(25) NOT NULL,
    created_utc integer
);


--
-- Name: submission_option_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.submission_option_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: submission_option_votes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.submission_option_votes (
    option_id integer NOT NULL,
    user_id integer NOT NULL,
    created_utc integer NOT NULL,
    submission_id integer
);


--
-- Name: submission_options; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.submission_options (
    id integer DEFAULT nextval('public.submission_option_id_seq'::regclass) NOT NULL,
    submission_id integer NOT NULL,
    body_html character varying(500) NOT NULL,
    exclusive integer NOT NULL,
    created_utc integer
);


--
-- Name: submissions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.submissions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: submissions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.submissions_id_seq OWNED BY public.submissions.id;


--
-- Name: subs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.subs (
    name character varying(25) NOT NULL,
    sidebar character varying(10000),
    sidebar_html character varying(20000),
    sidebarurl character varying(60),
    bannerurl character varying(60),
    css character varying(6000),
    stealth boolean,
    marseyurl character varying(60),
    created_utc integer
);


--
-- Name: subscriptions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.subscriptions (
    user_id integer NOT NULL,
    submission_id integer NOT NULL,
    created_utc integer
);


--
-- Name: transactions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.transactions (
    id character varying(36) NOT NULL,
    created_utc integer NOT NULL,
    type character varying(12) NOT NULL,
    amount integer NOT NULL,
    email character varying(255) NOT NULL
);


--
-- Name: userblocks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.userblocks (
    user_id integer NOT NULL,
    target_id integer NOT NULL,
    created_utc integer
);


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id integer NOT NULL,
    username character varying(30) NOT NULL,
    email character varying(255),
    passhash character varying(255) NOT NULL,
    created_utc integer NOT NULL,
    admin_level integer DEFAULT 0 NOT NULL,
    over_18 boolean DEFAULT false NOT NULL,
    is_activated boolean DEFAULT false NOT NULL,
    bio character varying(1500),
    bio_html character varying(10000),
    referred_by integer,
    is_banned integer DEFAULT 0 NOT NULL,
    ban_reason character varying(256),
    login_nonce integer DEFAULT 0 NOT NULL,
    reserved character varying(256),
    mfa_secret character varying(32),
    is_private boolean DEFAULT false NOT NULL,
    unban_utc integer DEFAULT 0 NOT NULL,
    is_nofollow boolean DEFAULT false NOT NULL,
    custom_filter_list character varying(1000) DEFAULT ''::character varying,
    discord_id character varying(64),
    stored_subscriber_count integer DEFAULT 0 NOT NULL,
    ban_evade integer DEFAULT 0 NOT NULL,
    original_username character varying(30),
    customtitle character varying(1000),
    defaultsorting character varying(15) DEFAULT 'hot'::character varying NOT NULL,
    defaulttime character varying(5) NOT NULL,
    namecolor character varying(6) NOT NULL,
    titlecolor character varying(6) NOT NULL,
    profileurl character varying(65),
    bannerurl character varying(65),
    hidevotedon boolean DEFAULT false NOT NULL,
    newtab boolean DEFAULT false NOT NULL,
    flairchanged integer,
    defaultsortingcomments character varying(15) DEFAULT 'top'::character varying NOT NULL,
    theme character varying(15) NOT NULL,
    song character varying(50),
    slurreplacer boolean DEFAULT true NOT NULL,
    shadowbanned character varying(25),
    newtabexternal boolean DEFAULT true NOT NULL,
    customtitleplain character varying(100),
    themecolor character varying(6) NOT NULL,
    css character varying(4000),
    profilecss character varying(4000),
    coins integer DEFAULT 0 NOT NULL,
    agendaposter integer DEFAULT 0 NOT NULL,
    post_count integer DEFAULT 0 NOT NULL,
    comment_count integer DEFAULT 0 NOT NULL,
    highres character varying(60),
    patron integer DEFAULT 0 NOT NULL,
    controversial boolean DEFAULT false NOT NULL,
    background character varying(20),
    verified character varying(100),
    cardview boolean NOT NULL,
    received_award_count integer DEFAULT 0 NOT NULL,
    highlightcomments boolean DEFAULT true NOT NULL,
    nitter boolean,
    truecoins integer DEFAULT 0 NOT NULL,
    club_allowed boolean,
    frontsize integer DEFAULT 25 NOT NULL,
    coins_spent integer DEFAULT 0 NOT NULL,
    procoins integer DEFAULT 0 NOT NULL,
    mute boolean,
    unmutable boolean,
    verifiedcolor character varying(6),
    marseyawarded integer,
    sig character varying(200),
    sig_html character varying(1000),
    friends character varying(500),
    friends_html character varying(2000),
    sigs_disabled boolean,
    enemies character varying(500),
    enemies_html character varying(2000),
    fp character varying(21),
    eye boolean,
    alt boolean,
    longpost integer,
    unblockable boolean,
    bird integer,
    fish boolean,
    lootboxes_bought integer DEFAULT 0 NOT NULL,
    progressivestack integer,
    patron_utc integer DEFAULT 0 NOT NULL,
    rehab integer,
    house character varying(16),
    deflector integer,
    reddit character varying(15) NOT NULL,
    currently_held_lottery_tickets integer DEFAULT 0 NOT NULL,
    total_held_lottery_tickets integer DEFAULT 0 NOT NULL,
    total_lottery_winnings integer DEFAULT 0 NOT NULL,
    offsitementions boolean DEFAULT false NOT NULL,
    last_active integer DEFAULT 0 NOT NULL,
    poorcel boolean DEFAULT false NOT NULL,
    last_viewed_post_notifs integer NOT NULL,
    pronouns character varying(11) NOT NULL,
    last_viewed_log_notifs integer NOT NULL,
    imginn boolean,
    earlylife integer,
    bite integer,
    old_house character varying(16),
    owoify integer,
    marsify integer,
    is_muted boolean DEFAULT false NOT NULL,
    coins_spent_on_hats integer DEFAULT 0 NOT NULL,
    rainbow integer
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
-- Name: viewers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.viewers (
    user_id integer NOT NULL,
    viewer_id integer NOT NULL,
    last_view_utc integer NOT NULL,
    created_utc integer
);


--
-- Name: votes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.votes (
    user_id integer NOT NULL,
    submission_id integer NOT NULL,
    vote_type integer NOT NULL,
    app_id integer,
    "real" boolean DEFAULT true NOT NULL,
    created_utc integer NOT NULL
);


--
-- Name: award_relationships id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.award_relationships ALTER COLUMN id SET DEFAULT nextval('public.award_relationships_id_seq'::regclass);


--
-- Name: badge_defs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.badge_defs ALTER COLUMN id SET DEFAULT nextval('public.badge_defs_id_seq'::regclass);


--
-- Name: casino_games id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.casino_games ALTER COLUMN id SET DEFAULT nextval('public.casino_games_id_seq'::regclass);


--
-- Name: category id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.category ALTER COLUMN id SET DEFAULT nextval('public.category_id_seq'::regclass);


--
-- Name: comments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comments ALTER COLUMN id SET DEFAULT nextval('public.comments_id_seq'::regclass);


--
-- Name: hat_defs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.hat_defs ALTER COLUMN id SET DEFAULT nextval('public.hat_defs_id_seq'::regclass);


--
-- Name: lotteries id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lotteries ALTER COLUMN id SET DEFAULT nextval('public.lotteries_id_seq'::regclass);


--
-- Name: modactions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.modactions ALTER COLUMN id SET DEFAULT nextval('public.modactions_id_seq'::regclass);


--
-- Name: oauth_apps id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oauth_apps ALTER COLUMN id SET DEFAULT nextval('public.oauth_apps_id_seq'::regclass);


--
-- Name: submissions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.submissions ALTER COLUMN id SET DEFAULT nextval('public.submissions_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: alts alts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.alts
    ADD CONSTRAINT alts_pkey PRIMARY KEY (user1, user2);


--
-- Name: award_relationships award_constraint; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.award_relationships
    ADD CONSTRAINT award_constraint UNIQUE (user_id, submission_id, comment_id);


--
-- Name: award_relationships award_relationships_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.award_relationships
    ADD CONSTRAINT award_relationships_pkey PRIMARY KEY (id);


--
-- Name: badge_defs badge_def_name_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.badge_defs
    ADD CONSTRAINT badge_def_name_unique UNIQUE (name);


--
-- Name: badge_defs badge_defs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.badge_defs
    ADD CONSTRAINT badge_defs_pkey PRIMARY KEY (id);


--
-- Name: badges badges_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.badges
    ADD CONSTRAINT badges_pkey PRIMARY KEY (user_id, badge_id);


--
-- Name: casino_games casino_games_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.casino_games
    ADD CONSTRAINT casino_games_pkey PRIMARY KEY (id);


--
-- Name: category category_name_sub_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.category
    ADD CONSTRAINT category_name_sub_key UNIQUE (name, sub);


--
-- Name: category category_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.category
    ADD CONSTRAINT category_pkey PRIMARY KEY (id);


--
-- Name: client_auths client_auths_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.client_auths
    ADD CONSTRAINT client_auths_pkey PRIMARY KEY (user_id, oauth_client);


--
-- Name: comment_option_votes comment_option_votes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comment_option_votes
    ADD CONSTRAINT comment_option_votes_pkey PRIMARY KEY (option_id, user_id);


--
-- Name: comment_options comment_options_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comment_options
    ADD CONSTRAINT comment_options_pkey PRIMARY KEY (id);


--
-- Name: comment_save_relationship comment_save_relationship_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comment_save_relationship
    ADD CONSTRAINT comment_save_relationship_pkey PRIMARY KEY (user_id, comment_id);


--
-- Name: commentflags commentflags_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.commentflags
    ADD CONSTRAINT commentflags_pkey PRIMARY KEY (comment_id, user_id);


--
-- Name: comments comments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comments
    ADD CONSTRAINT comments_pkey PRIMARY KEY (id);


--
-- Name: commentvotes commentvotes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.commentvotes
    ADD CONSTRAINT commentvotes_pkey PRIMARY KEY (comment_id, user_id);


--
-- Name: banneddomains domain_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.banneddomains
    ADD CONSTRAINT domain_pkey PRIMARY KEY (domain);


--
-- Name: exiles exiles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.exiles
    ADD CONSTRAINT exiles_pkey PRIMARY KEY (user_id, sub);


--
-- Name: flags flags_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.flags
    ADD CONSTRAINT flags_pkey PRIMARY KEY (post_id, user_id);


--
-- Name: follows follows_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.follows
    ADD CONSTRAINT follows_pkey PRIMARY KEY (target_id, user_id);


--
-- Name: hat_defs hat_defs_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.hat_defs
    ADD CONSTRAINT hat_defs_name_key UNIQUE (name);


--
-- Name: hat_defs hat_defs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.hat_defs
    ADD CONSTRAINT hat_defs_pkey PRIMARY KEY (id);


--
-- Name: hats hats_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.hats
    ADD CONSTRAINT hats_pkey PRIMARY KEY (user_id, hat_id);


--
-- Name: lotteries lotteries_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lotteries
    ADD CONSTRAINT lotteries_pkey PRIMARY KEY (id);


--
-- Name: marseys marseys_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.marseys
    ADD CONSTRAINT marseys_pkey PRIMARY KEY (name);


--
-- Name: modactions modactions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.modactions
    ADD CONSTRAINT modactions_pkey PRIMARY KEY (id);


--
-- Name: mods mods_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mods
    ADD CONSTRAINT mods_pkey PRIMARY KEY (user_id, sub);


--
-- Name: notifications notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_pkey PRIMARY KEY (user_id, comment_id);


--
-- Name: oauth_apps oauth_apps_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oauth_apps
    ADD CONSTRAINT oauth_apps_pkey PRIMARY KEY (id);


--
-- Name: users one_banner; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT one_banner UNIQUE (bannerurl);


--
-- Name: users one_discord_account; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT one_discord_account UNIQUE (discord_id);


--
-- Name: pgbench_accounts pgbench_accounts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pgbench_accounts
    ADD CONSTRAINT pgbench_accounts_pkey PRIMARY KEY (aid);


--
-- Name: pgbench_branches pgbench_branches_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pgbench_branches
    ADD CONSTRAINT pgbench_branches_pkey PRIMARY KEY (bid);


--
-- Name: pgbench_tellers pgbench_tellers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pgbench_tellers
    ADD CONSTRAINT pgbench_tellers_pkey PRIMARY KEY (tid);


--
-- Name: save_relationship save_relationship_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.save_relationship
    ADD CONSTRAINT save_relationship_pkey PRIMARY KEY (user_id, submission_id);


--
-- Name: sub_blocks sub_blocks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sub_blocks
    ADD CONSTRAINT sub_blocks_pkey PRIMARY KEY (user_id, sub);


--
-- Name: sub_joins sub_joins_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sub_joins
    ADD CONSTRAINT sub_joins_pkey PRIMARY KEY (user_id, sub);


--
-- Name: sub_subscriptions sub_subscriptions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sub_subscriptions
    ADD CONSTRAINT sub_subscriptions_pkey PRIMARY KEY (user_id, sub);


--
-- Name: submission_option_votes submission_option_votes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.submission_option_votes
    ADD CONSTRAINT submission_option_votes_pkey PRIMARY KEY (option_id, user_id);


--
-- Name: submission_options submission_options_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.submission_options
    ADD CONSTRAINT submission_options_pkey PRIMARY KEY (id);


--
-- Name: submissions submissions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.submissions
    ADD CONSTRAINT submissions_pkey PRIMARY KEY (id);


--
-- Name: subs subs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subs
    ADD CONSTRAINT subs_pkey PRIMARY KEY (name);


--
-- Name: subscriptions subscriptions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subscriptions
    ADD CONSTRAINT subscriptions_pkey PRIMARY KEY (submission_id, user_id);


--
-- Name: transactions transactions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transactions
    ADD CONSTRAINT transactions_pkey PRIMARY KEY (id);


--
-- Name: users uid_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT uid_unique UNIQUE (id);


--
-- Name: client_auths unique_access; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.client_auths
    ADD CONSTRAINT unique_access UNIQUE (access_token);


--
-- Name: oauth_apps unique_id; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oauth_apps
    ADD CONSTRAINT unique_id UNIQUE (client_id);


--
-- Name: userblocks userblocks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.userblocks
    ADD CONSTRAINT userblocks_pkey PRIMARY KEY (user_id, target_id);


--
-- Name: users users_original_username_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_original_username_key UNIQUE (original_username);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (username);


--
-- Name: users users_username_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key UNIQUE (username);


--
-- Name: viewers viewers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.viewers
    ADD CONSTRAINT viewers_pkey PRIMARY KEY (user_id, viewer_id);


--
-- Name: votes votes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.votes
    ADD CONSTRAINT votes_pkey PRIMARY KEY (submission_id, user_id);


--
-- Name: alts_unique_combination; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX alts_unique_combination ON public.alts USING btree (GREATEST(user1, user2), LEAST(user1, user2));


--
-- Name: alts_user2_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX alts_user2_idx ON public.alts USING btree (user2);


--
-- Name: award_comment_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX award_comment_idx ON public.award_relationships USING btree (comment_id);


--
-- Name: award_post_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX award_post_idx ON public.award_relationships USING btree (submission_id);


--
-- Name: award_user_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX award_user_idx ON public.award_relationships USING btree (user_id);


--
-- Name: badges_badge_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX badges_badge_id_idx ON public.badges USING btree (badge_id);


--
-- Name: block_target_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX block_target_idx ON public.userblocks USING btree (target_id);


--
-- Name: cflag_user_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX cflag_user_idx ON public.commentflags USING btree (user_id);


--
-- Name: comment_parent_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX comment_parent_index ON public.comments USING btree (parent_comment_id);


--
-- Name: comment_post_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX comment_post_id_index ON public.comments USING btree (parent_submission);


--
-- Name: comments_user_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX comments_user_index ON public.comments USING btree (author_id);


--
-- Name: commentvotes_comments_type_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX commentvotes_comments_type_index ON public.commentvotes USING btree (vote_type);


--
-- Name: cvote_user_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX cvote_user_index ON public.commentvotes USING btree (user_id);


--
-- Name: discord_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX discord_id_idx ON public.users USING btree (discord_id);


--
-- Name: domains_domain_trgm_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX domains_domain_trgm_idx ON public.banneddomains USING gin (domain public.gin_trgm_ops);


--
-- Name: fki_comment_approver_fkey; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX fki_comment_approver_fkey ON public.comments USING btree (is_approved);


--
-- Name: fki_comment_save_relationship_comment_fkey; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX fki_comment_save_relationship_comment_fkey ON public.comment_save_relationship USING btree (comment_id);


--
-- Name: fki_comment_sentto_fkey; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX fki_comment_sentto_fkey ON public.comments USING btree (sentto);


--
-- Name: fki_exile_exiler_fkey; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX fki_exile_exiler_fkey ON public.exiles USING btree (exiler_id);


--
-- Name: fki_exile_sub_fkey; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX fki_exile_sub_fkey ON public.exiles USING btree (sub);


--
-- Name: fki_mod_sub_fkey; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX fki_mod_sub_fkey ON public.mods USING btree (sub);


--
-- Name: fki_modactions_user_fkey; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX fki_modactions_user_fkey ON public.modactions USING btree (target_user_id);


--
-- Name: fki_save_relationship_submission_fkey; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX fki_save_relationship_submission_fkey ON public.save_relationship USING btree (submission_id);


--
-- Name: fki_sub_blocks_sub_fkey; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX fki_sub_blocks_sub_fkey ON public.sub_blocks USING btree (sub);


--
-- Name: fki_sub_joins_sub_fkey; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX fki_sub_joins_sub_fkey ON public.sub_joins USING btree (sub);


--
-- Name: fki_sub_subscriptions_sub_fkey; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX fki_sub_subscriptions_sub_fkey ON public.sub_subscriptions USING btree (sub);


--
-- Name: fki_submissions_approver_fkey; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX fki_submissions_approver_fkey ON public.submissions USING btree (is_approved);


--
-- Name: fki_user_referrer_fkey; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX fki_user_referrer_fkey ON public.users USING btree (referred_by);


--
-- Name: fki_view_viewer_fkey; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX fki_view_viewer_fkey ON public.viewers USING btree (viewer_id);


--
-- Name: flag_user_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX flag_user_idx ON public.flags USING btree (user_id);


--
-- Name: follow_user_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX follow_user_id_index ON public.follows USING btree (user_id);


--
-- Name: hat_defs_submitter_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX hat_defs_submitter_id_idx ON public.hat_defs USING btree (submitter_id);


--
-- Name: lowercase_original_username; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX lowercase_original_username ON public.users USING btree (lower((original_username)::text));


--
-- Name: lowercase_username; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX lowercase_username ON public.users USING btree (lower((username)::text));


--
-- Name: marseys_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX marseys_idx ON public.marseys USING btree (name);


--
-- Name: marseys_idx2; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX marseys_idx2 ON public.marseys USING btree (author_id);


--
-- Name: marseys_idx3; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX marseys_idx3 ON public.marseys USING btree (count DESC);


--
-- Name: marseys_idx4; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX marseys_idx4 ON public.marseys USING btree (submitter_id);


--
-- Name: modaction_action_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX modaction_action_idx ON public.modactions USING btree (kind);


--
-- Name: modaction_cid_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX modaction_cid_idx ON public.modactions USING btree (target_comment_id);


--
-- Name: modaction_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX modaction_id_idx ON public.modactions USING btree (id DESC);


--
-- Name: modaction_pid_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX modaction_pid_idx ON public.modactions USING btree (target_submission_id);


--
-- Name: notification_read_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX notification_read_idx ON public.notifications USING btree (read);


--
-- Name: notifications_comment_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX notifications_comment_idx ON public.notifications USING btree (comment_id);


--
-- Name: notifs_user_read_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX notifs_user_read_idx ON public.notifications USING btree (user_id, read);


--
-- Name: option_comment; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX option_comment ON public.comment_options USING btree (comment_id);


--
-- Name: option_submission; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX option_submission ON public.submission_options USING btree (submission_id);


--
-- Name: post_app_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX post_app_id_idx ON public.submissions USING btree (app_id);


--
-- Name: subimssion_binary_group_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX subimssion_binary_group_idx ON public.submissions USING btree (is_banned, deleted_utc, over_18);


--
-- Name: submission_isbanned_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX submission_isbanned_idx ON public.submissions USING btree (is_banned);


--
-- Name: submission_isdeleted_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX submission_isdeleted_idx ON public.submissions USING btree (deleted_utc);


--
-- Name: submission_new_sort_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX submission_new_sort_idx ON public.submissions USING btree (is_banned, deleted_utc, created_utc DESC, over_18);


--
-- Name: submission_pinned_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX submission_pinned_idx ON public.submissions USING btree (is_pinned);


--
-- Name: submissions_author_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX submissions_author_index ON public.submissions USING btree (author_id);


--
-- Name: submissions_created_utc_asc_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX submissions_created_utc_asc_idx ON public.submissions USING btree (created_utc NULLS FIRST);


--
-- Name: submissions_created_utc_desc_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX submissions_created_utc_desc_idx ON public.submissions USING btree (created_utc DESC);


--
-- Name: submissions_over18_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX submissions_over18_index ON public.submissions USING btree (over_18);


--
-- Name: subs_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX subs_idx ON public.subs USING btree (name);


--
-- Name: subscription_user_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX subscription_user_index ON public.subscriptions USING btree (user_id);


--
-- Name: transactions_email_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX transactions_email_idx ON public.transactions USING btree (email);


--
-- Name: user_banned_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX user_banned_idx ON public.users USING btree (is_banned);


--
-- Name: user_private_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX user_private_idx ON public.users USING btree (is_private);


--
-- Name: users_created_utc_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX users_created_utc_index ON public.users USING btree (created_utc);


--
-- Name: users_original_username_trgm_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX users_original_username_trgm_idx ON public.users USING gin (original_username public.gin_trgm_ops);


--
-- Name: users_subs_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX users_subs_idx ON public.users USING btree (stored_subscriber_count);


--
-- Name: users_unbanutc_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX users_unbanutc_idx ON public.users USING btree (unban_utc DESC);


--
-- Name: users_username_trgm_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX users_username_trgm_idx ON public.users USING gin (username public.gin_trgm_ops);


--
-- Name: vote_user_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX vote_user_index ON public.votes USING btree (user_id);


--
-- Name: votes_type_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX votes_type_index ON public.votes USING btree (vote_type);


--
-- Name: alts alt_user1_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.alts
    ADD CONSTRAINT alt_user1_fkey FOREIGN KEY (user1) REFERENCES public.users(id);


--
-- Name: alts alt_user2_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.alts
    ADD CONSTRAINT alt_user2_fkey FOREIGN KEY (user2) REFERENCES public.users(id);


--
-- Name: oauth_apps app_author_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oauth_apps
    ADD CONSTRAINT app_author_id_fkey FOREIGN KEY (author_id) REFERENCES public.users(id);


--
-- Name: award_relationships award_comment_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.award_relationships
    ADD CONSTRAINT award_comment_fkey FOREIGN KEY (comment_id) REFERENCES public.comments(id);


--
-- Name: award_relationships award_submission_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.award_relationships
    ADD CONSTRAINT award_submission_fkey FOREIGN KEY (submission_id) REFERENCES public.submissions(id);


--
-- Name: award_relationships award_user_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.award_relationships
    ADD CONSTRAINT award_user_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: badges badges_badge_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.badges
    ADD CONSTRAINT badges_badge_id_fkey FOREIGN KEY (badge_id) REFERENCES public.badge_defs(id);


--
-- Name: badges badges_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.badges
    ADD CONSTRAINT badges_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: userblocks block_target_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.userblocks
    ADD CONSTRAINT block_target_fkey FOREIGN KEY (target_id) REFERENCES public.users(id);


--
-- Name: userblocks block_user_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.userblocks
    ADD CONSTRAINT block_user_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: casino_games casino_games_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.casino_games
    ADD CONSTRAINT casino_games_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: category category_sub_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.category
    ADD CONSTRAINT category_sub_fkey FOREIGN KEY (sub) REFERENCES public.subs(name);


--
-- Name: client_auths client_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.client_auths
    ADD CONSTRAINT client_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: comments comment_approver_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comments
    ADD CONSTRAINT comment_approver_fkey FOREIGN KEY (is_approved) REFERENCES public.users(id);


--
-- Name: comments comment_parent_comment_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comments
    ADD CONSTRAINT comment_parent_comment_fkey FOREIGN KEY (parent_comment_id) REFERENCES public.comments(id);


--
-- Name: comments comment_parent_submission_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comments
    ADD CONSTRAINT comment_parent_submission_fkey FOREIGN KEY (parent_submission) REFERENCES public.submissions(id);


--
-- Name: comment_save_relationship comment_save_relationship_comment_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comment_save_relationship
    ADD CONSTRAINT comment_save_relationship_comment_fkey FOREIGN KEY (comment_id) REFERENCES public.comments(id) MATCH FULL;


--
-- Name: comment_save_relationship comment_save_relationship_user_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comment_save_relationship
    ADD CONSTRAINT comment_save_relationship_user_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) MATCH FULL;


--
-- Name: comments comment_sentto_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comments
    ADD CONSTRAINT comment_sentto_fkey FOREIGN KEY (sentto) REFERENCES public.users(id);


--
-- Name: commentflags commentflags_comment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.commentflags
    ADD CONSTRAINT commentflags_comment_id_fkey FOREIGN KEY (comment_id) REFERENCES public.comments(id);


--
-- Name: commentflags commentflags_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.commentflags
    ADD CONSTRAINT commentflags_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: comments comments_author_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comments
    ADD CONSTRAINT comments_author_id_fkey FOREIGN KEY (author_id) REFERENCES public.users(id);


--
-- Name: commentvotes commentvote_comment_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.commentvotes
    ADD CONSTRAINT commentvote_comment_fkey FOREIGN KEY (comment_id) REFERENCES public.comments(id) MATCH FULL;


--
-- Name: commentvotes commentvote_user_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.commentvotes
    ADD CONSTRAINT commentvote_user_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: exiles exile_exiler_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.exiles
    ADD CONSTRAINT exile_exiler_fkey FOREIGN KEY (exiler_id) REFERENCES public.users(id);


--
-- Name: exiles exile_sub_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.exiles
    ADD CONSTRAINT exile_sub_fkey FOREIGN KEY (sub) REFERENCES public.subs(name);


--
-- Name: exiles exile_user_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.exiles
    ADD CONSTRAINT exile_user_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: lotteries fk_winner; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lotteries
    ADD CONSTRAINT fk_winner FOREIGN KEY (winner_id) REFERENCES public.users(id);


--
-- Name: flags flags_post_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.flags
    ADD CONSTRAINT flags_post_id_fkey FOREIGN KEY (post_id) REFERENCES public.submissions(id);


--
-- Name: flags flags_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.flags
    ADD CONSTRAINT flags_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: follows follow_target_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.follows
    ADD CONSTRAINT follow_target_fkey FOREIGN KEY (target_id) REFERENCES public.users(id);


--
-- Name: follows follow_user_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.follows
    ADD CONSTRAINT follow_user_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: hat_defs hat_def_submitter_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.hat_defs
    ADD CONSTRAINT hat_def_submitter_fkey FOREIGN KEY (submitter_id) REFERENCES public.users(id);


--
-- Name: hat_defs hat_defs_author_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.hat_defs
    ADD CONSTRAINT hat_defs_author_id_fkey FOREIGN KEY (author_id) REFERENCES public.users(id);


--
-- Name: hats hats_hat_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.hats
    ADD CONSTRAINT hats_hat_id_fkey FOREIGN KEY (hat_id) REFERENCES public.hat_defs(id);


--
-- Name: hats hats_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.hats
    ADD CONSTRAINT hats_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: marseys marsey_author_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.marseys
    ADD CONSTRAINT marsey_author_fkey FOREIGN KEY (author_id) REFERENCES public.users(id);


--
-- Name: marseys marsey_submitter_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.marseys
    ADD CONSTRAINT marsey_submitter_fkey FOREIGN KEY (submitter_id) REFERENCES public.users(id);


--
-- Name: mods mod_sub_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mods
    ADD CONSTRAINT mod_sub_fkey FOREIGN KEY (sub) REFERENCES public.subs(name);


--
-- Name: modactions modactions_comment_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.modactions
    ADD CONSTRAINT modactions_comment_fkey FOREIGN KEY (target_comment_id) REFERENCES public.comments(id);


--
-- Name: modactions modactions_submission_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.modactions
    ADD CONSTRAINT modactions_submission_fkey FOREIGN KEY (target_submission_id) REFERENCES public.submissions(id);


--
-- Name: modactions modactions_user_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.modactions
    ADD CONSTRAINT modactions_user_fkey FOREIGN KEY (target_user_id) REFERENCES public.users(id);


--
-- Name: notifications notifications_comment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_comment_id_fkey FOREIGN KEY (comment_id) REFERENCES public.comments(id);


--
-- Name: notifications notifications_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: client_auths oauth_client_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.client_auths
    ADD CONSTRAINT oauth_client_fkey FOREIGN KEY (oauth_client) REFERENCES public.oauth_apps(id);


--
-- Name: comment_options option_comment_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comment_options
    ADD CONSTRAINT option_comment_fkey FOREIGN KEY (comment_id) REFERENCES public.comments(id) MATCH FULL;


--
-- Name: submission_options option_submission_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.submission_options
    ADD CONSTRAINT option_submission_fkey FOREIGN KEY (submission_id) REFERENCES public.submissions(id) MATCH FULL;


--
-- Name: save_relationship save_relationship_submission_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.save_relationship
    ADD CONSTRAINT save_relationship_submission_fkey FOREIGN KEY (submission_id) REFERENCES public.submissions(id) MATCH FULL;


--
-- Name: save_relationship save_relationship_user_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.save_relationship
    ADD CONSTRAINT save_relationship_user_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) MATCH FULL;


--
-- Name: sub_blocks sub_blocks_sub_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sub_blocks
    ADD CONSTRAINT sub_blocks_sub_fkey FOREIGN KEY (sub) REFERENCES public.subs(name) MATCH FULL;


--
-- Name: sub_blocks sub_blocks_user_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sub_blocks
    ADD CONSTRAINT sub_blocks_user_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) MATCH FULL;


--
-- Name: submissions sub_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.submissions
    ADD CONSTRAINT sub_fkey FOREIGN KEY (sub) REFERENCES public.subs(name);


--
-- Name: sub_joins sub_joins_sub_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sub_joins
    ADD CONSTRAINT sub_joins_sub_fkey FOREIGN KEY (sub) REFERENCES public.subs(name) MATCH FULL;


--
-- Name: sub_joins sub_joins_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sub_joins
    ADD CONSTRAINT sub_joins_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) MATCH FULL;


--
-- Name: sub_subscriptions sub_subscriptions_sub_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sub_subscriptions
    ADD CONSTRAINT sub_subscriptions_sub_fkey FOREIGN KEY (sub) REFERENCES public.subs(name) MATCH FULL;


--
-- Name: sub_subscriptions sub_subscriptions_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sub_subscriptions
    ADD CONSTRAINT sub_subscriptions_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) MATCH FULL;


--
-- Name: submissions submissions_approver_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.submissions
    ADD CONSTRAINT submissions_approver_fkey FOREIGN KEY (is_approved) REFERENCES public.users(id);


--
-- Name: submissions submissions_author_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.submissions
    ADD CONSTRAINT submissions_author_fkey FOREIGN KEY (author_id) REFERENCES public.users(id);


--
-- Name: submissions submissions_category_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.submissions
    ADD CONSTRAINT submissions_category_id_fkey FOREIGN KEY (category_id) REFERENCES public.category(id) ON DELETE SET NULL;


--
-- Name: subscriptions subscription_submission_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subscriptions
    ADD CONSTRAINT subscription_submission_fkey FOREIGN KEY (submission_id) REFERENCES public.submissions(id);


--
-- Name: subscriptions subscription_user_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subscriptions
    ADD CONSTRAINT subscription_user_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: mods user_mod_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mods
    ADD CONSTRAINT user_mod_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: users user_referrer_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT user_referrer_fkey FOREIGN KEY (referred_by) REFERENCES public.users(id);


--
-- Name: viewers view_user_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.viewers
    ADD CONSTRAINT view_user_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: viewers view_viewer_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.viewers
    ADD CONSTRAINT view_viewer_fkey FOREIGN KEY (viewer_id) REFERENCES public.users(id);


--
-- Name: comment_option_votes vote_comment_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comment_option_votes
    ADD CONSTRAINT vote_comment_fkey FOREIGN KEY (comment_id) REFERENCES public.comments(id) MATCH FULL;


--
-- Name: submission_option_votes vote_option_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.submission_option_votes
    ADD CONSTRAINT vote_option_fkey FOREIGN KEY (option_id) REFERENCES public.submission_options(id) MATCH FULL;


--
-- Name: comment_option_votes vote_option_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comment_option_votes
    ADD CONSTRAINT vote_option_fkey FOREIGN KEY (option_id) REFERENCES public.comment_options(id) MATCH FULL;


--
-- Name: submission_option_votes vote_submission_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.submission_option_votes
    ADD CONSTRAINT vote_submission_fkey FOREIGN KEY (submission_id) REFERENCES public.submissions(id) MATCH FULL;


--
-- Name: votes vote_submission_key; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.votes
    ADD CONSTRAINT vote_submission_key FOREIGN KEY (submission_id) REFERENCES public.submissions(id);


--
-- Name: votes vote_user_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.votes
    ADD CONSTRAINT vote_user_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: submission_option_votes vote_user_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.submission_option_votes
    ADD CONSTRAINT vote_user_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) MATCH FULL;


--
-- Name: comment_option_votes vote_user_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comment_option_votes
    ADD CONSTRAINT vote_user_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) MATCH FULL;


--
-- PostgreSQL database dump complete
--

--
-- PostgreSQL database dump
--

-- Dumped from database version 14.4
-- Dumped by pg_dump version 14.5 (Ubuntu 14.5-1.pgdg20.04+1)

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
-- Data for Name: badge_defs; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.badge_defs VALUES (136, 'TRAIN 2022', 'Beware: Found to be one of the most transmisic commenters on the site!', NULL);
INSERT INTO public.badge_defs VALUES (137, 'Lottershe Winner', 'This user won the Lottershe grand prize.', NULL);
INSERT INTO public.badge_defs VALUES (140, 'Y''all Seein'' Eye', 'Gets notified when other sites talk about us', NULL);
INSERT INTO public.badge_defs VALUES (141, 'Marsey Typographer', 'For substantial and exceptional contributions to Marsey Alphabet.', NULL);
INSERT INTO public.badge_defs VALUES (142, 'Punching Down', 'This user mogs incels.', NULL);
INSERT INTO public.badge_defs VALUES (143, 'Marsey God', 'Contributed 100 (or more!!!!) Marsey emojis ✨😻', NULL);
INSERT INTO public.badge_defs VALUES (144, 'Energy Drink Enjoyer', 'Grip ''N Sip.', NULL);
INSERT INTO public.badge_defs VALUES (147, 'Freebase Fiend', 'From the crack grew a glass rose.', NULL);
INSERT INTO public.badge_defs VALUES (148, 'Blackpilled', 'Proud incel ally.', NULL);
INSERT INTO public.badge_defs VALUES (149, 'Thin', 'This user has verified that they are calorically disciplined.', NULL);
INSERT INTO public.badge_defs VALUES (139, 'Auspicious Incident', 'This user was fired from a volunteer position', NULL);
INSERT INTO public.badge_defs VALUES (150, 'Verified', 'Bought a Blue Checkmark.', NULL);
INSERT INTO public.badge_defs VALUES (151, 'Responsible Citizen', 'This user upheld democracy by committing voter fraud.', NULL);
INSERT INTO public.badge_defs VALUES (152, 'Amateur Hathead', 'Collected 25 unique hats', NULL);
INSERT INTO public.badge_defs VALUES (155, 'Ride Or Die Dramalo/Dramalette', 'When I die show no pity / Send my soul to the juggalo city / Dig my grave six feet deep / And put two matches by my feet / Put two hatchets on my chest / And tell my homies I did my best / WHOOP WHOOP', NULL);
INSERT INTO public.badge_defs VALUES (156, 'Hole Neglecter', 'Brought a Hole into this world, only to let it die', NULL);
INSERT INTO public.badge_defs VALUES (21, 'Paypig', 'Contributed at least $5', NULL);
INSERT INTO public.badge_defs VALUES (22, 'Renthog', 'Contributed at least $10', NULL);
INSERT INTO public.badge_defs VALUES (23, 'Landchad', 'Contributed at least $20', NULL);
INSERT INTO public.badge_defs VALUES (24, 'Terminally online turboautist', 'Contributed at least $50', NULL);
INSERT INTO public.badge_defs VALUES (157, 'A Minor Setback', 'Lost a 1,000 dramacoin bet. Keep going!', NULL);
INSERT INTO public.badge_defs VALUES (158, 'Just One More Hand', 'Lost a 10,000 dramacoin bet. But it''s fine, you''re due for a big win!', NULL);
INSERT INTO public.badge_defs VALUES (160, 'Lil Goombler', 'Won a 1,000 dramacoin bet. Nice job!', NULL);
INSERT INTO public.badge_defs VALUES (162, 'King Goombler', 'Won a 100,000 dramacoin bet. Wipe your sweaty palms off and bet it all again, you''re on a roll!', NULL);
INSERT INTO public.badge_defs VALUES (163, 'Marsey Jacobs', 'Designed 10 hats!', NULL);
INSERT INTO public.badge_defs VALUES (166, 'Giorgio Armarsey', 'Designed 250 hats 😲', NULL);
INSERT INTO public.badge_defs VALUES (164, 'Marsey de Givenchy', 'Designed 50 hats, holy cap.', NULL);
INSERT INTO public.badge_defs VALUES (168, 'BITTEN!', 'This user has been forcibly recruited to House Vampire', NULL);
INSERT INTO public.badge_defs VALUES (170, 'Marsified', 'This user''s comments get Marsified automatically', NULL);
INSERT INTO public.badge_defs VALUES (167, 'OwOified', 'This user''s comments get OwOified automatically', NULL);
INSERT INTO public.badge_defs VALUES (169, 'Early Life Checked', 'The Early Life section of this user is on full display', NULL);
INSERT INTO public.badge_defs VALUES (172, 'God Save The Kween', 'Commemorative badge awarded for outliving Her Maj', NULL);
INSERT INTO public.badge_defs VALUES (174, 'George', '@Marsey went to Spokane to fight @TrailerParkBride, but George the Mountain Lion was the real winner.', NULL);
INSERT INTO public.badge_defs VALUES (175, 'Pressuring Peer', 'You have applied pressure to poor souls undergoing rehabilitation [n] times. Shame on you!', 1663105259);
INSERT INTO public.badge_defs VALUES (4, 'White Hat', 'Discreetly reported an exploit', NULL);
INSERT INTO public.badge_defs VALUES (176, 'Fish Of The Year', 'Awarded for outstanding achievement in the field of achievement. Well done!', 1663340894);
INSERT INTO public.badge_defs VALUES (1, 'Alpha User', 'Joined during open alpha', NULL);
INSERT INTO public.badge_defs VALUES (2, 'Verified Email', 'Verified Email', NULL);
INSERT INTO public.badge_defs VALUES (3, 'Code Contributor', 'Contributed to the site''s source code', NULL);
INSERT INTO public.badge_defs VALUES (6, 'Beta User', 'Joined during open beta', NULL);
INSERT INTO public.badge_defs VALUES (7, 'Bug Chaser', 'Found a bug', NULL);
INSERT INTO public.badge_defs VALUES (10, 'Bronze Recruiter', 'Recruited 1 friend to join the site', NULL);
INSERT INTO public.badge_defs VALUES (11, 'Silver Recruiter', 'Recruited 10 friends to join the site', NULL);
INSERT INTO public.badge_defs VALUES (12, 'Gold Recruiter', 'Recruited 100 friends to join the site', NULL);
INSERT INTO public.badge_defs VALUES (15, 'Idea Maker', 'Had a good idea for the site which was implemented by the developers', NULL);
INSERT INTO public.badge_defs VALUES (16, 'Marsey Master', 'Contributed 10 (or more!!!!) Marsey emojis ✨', NULL);
INSERT INTO public.badge_defs VALUES (17, 'Marsey Artisan', 'Contributed a Marsey emoji ✨', NULL);
INSERT INTO public.badge_defs VALUES (18, 'Artisan', 'Contributed to site artwork', NULL);
INSERT INTO public.badge_defs VALUES (85, 'Sigma User', '', NULL);
INSERT INTO public.badge_defs VALUES (145, 'Amphetamine Aficionado', 'Totally not addicted™', NULL);
INSERT INTO public.badge_defs VALUES (146, 'Coffee Consoomer', 'Don''t talk to me until I''ve had my soy latte.', NULL);
INSERT INTO public.badge_defs VALUES (60, 'Unironically Retarded', 'Demonstrated a wholesale inability to read the room', NULL);
INSERT INTO public.badge_defs VALUES (61, 'Lab Rat', 'Helped test features in development', NULL);
INSERT INTO public.badge_defs VALUES (62, 'Master Baiter', 'For outstanding achievement in the field of catching fish', NULL);
INSERT INTO public.badge_defs VALUES (63, 'Balls', 'I wrote carp on my balls as a sign of submission', NULL);
INSERT INTO public.badge_defs VALUES (64, 'The Other Kind Of Good Journalist', 'Contributed positive media attention to the site', NULL);
INSERT INTO public.badge_defs VALUES (65, '2021 Spooooooky Marsey Artist', 'Contributed a VERY SCARY Marsey for Halloween 2021!', NULL);
INSERT INTO public.badge_defs VALUES (66, 'Sk8r Boi', 'Certifies that this user is NOT a poser', NULL);
INSERT INTO public.badge_defs VALUES (67, 'Unpausable', 'Spent 40,000 coins on an unpausable profile anthem', NULL);
INSERT INTO public.badge_defs VALUES (68, 'Pause Button', 'Spent 20,000 coins on a profile anthem pause button', NULL);
INSERT INTO public.badge_defs VALUES (69, 'Little Big Spender', 'Dropped 10,000 coins at the shop', NULL);
INSERT INTO public.badge_defs VALUES (70, 'Big Spender', 'Dropped 100,000 coins at the shop', NULL);
INSERT INTO public.badge_defs VALUES (71, 'Big Big Spender', 'Dropped 250,000 coins at the shop', NULL);
INSERT INTO public.badge_defs VALUES (72, 'Big Big Big Spender', 'Dropped 500,000 coins at the shop', NULL);
INSERT INTO public.badge_defs VALUES (73, 'Le Rich Gentlesir', 'Spent a fucking million coins at the shop', NULL);
INSERT INTO public.badge_defs VALUES (74, 'Grass Toucher', 'Awarded for molesting plant life', NULL);
INSERT INTO public.badge_defs VALUES (75, 'Halloween 21', 'Awarded for surviving Homoween 2021', NULL);
INSERT INTO public.badge_defs VALUES (76, 'Low Roller', 'Bought 10 lootboxes', NULL);
INSERT INTO public.badge_defs VALUES (77, 'Middle Roller', 'Bought 50 lootboxes', NULL);
INSERT INTO public.badge_defs VALUES (78, 'High Roller', 'Bought 150 lootboxes', NULL);
INSERT INTO public.badge_defs VALUES (79, 'Merchant', 'Contributed a new line of product to Marsey''s Coin Emporium', NULL);
INSERT INTO public.badge_defs VALUES (80, 'Artist Laureate', '', NULL);
INSERT INTO public.badge_defs VALUES (81, 'Patron of the Arts', 'Sponsored the creation of an approved Marsey', NULL);
INSERT INTO public.badge_defs VALUES (83, 'All-Seeing Eye', 'Can view private profiles', NULL);
INSERT INTO public.badge_defs VALUES (84, 'Alt-Seeing Eye', 'Can see alts', NULL);
INSERT INTO public.badge_defs VALUES (86, 'Holly Jolly Marsey Artist', 'Contributed a VERY JOLLY Marsey for Christmas 2021!', NULL);
INSERT INTO public.badge_defs VALUES (87, 'Unblockable', 'This user is unblockable', NULL);
INSERT INTO public.badge_defs VALUES (88, 'Provider', 'This user provided a bountiful feast for Thanksgiving', NULL);
INSERT INTO public.badge_defs VALUES (89, 'Dinner', 'Yes, it is edible', NULL);
INSERT INTO public.badge_defs VALUES (90, 'Fish', 'This user cannot be unfollowed', NULL);
INSERT INTO public.badge_defs VALUES (91, 'Grinch', 'This user is a joyless grinch who pays money to avoid having fun', NULL);
INSERT INTO public.badge_defs VALUES (92, 'NFT Artist', 'Drew a marsey that was used as an NFT', NULL);
INSERT INTO public.badge_defs VALUES (93, 'NFT Owner', 'Bought a marsey NFT', NULL);
INSERT INTO public.badge_defs VALUES (94, 'Progressive Stack Award', 'Upvotes/downvotes on this user''s posts and comments have double the ranking effect', NULL);
INSERT INTO public.badge_defs VALUES (95, 'Bird Site Award', 'This user is limited to 140 characters', NULL);
INSERT INTO public.badge_defs VALUES (96, 'Flairlock Award', 'This user''s flair has been locked by someone else', NULL);
INSERT INTO public.badge_defs VALUES (97, 'Pizzashill Award', 'This user has to make their posts and comments more than 280 characters', NULL);
INSERT INTO public.badge_defs VALUES (98, 'Marsey Award', 'This user is limited to posting marseys', NULL);
INSERT INTO public.badge_defs VALUES (99, 'Sidebar Artist', 'Contributed artwork featured on the sidebar', NULL);
INSERT INTO public.badge_defs VALUES (100, 'True Believer', 'This user sees through communist lies', NULL);
INSERT INTO public.badge_defs VALUES (101, 'Banner Artist', 'Contributed a banner image to the site', NULL);
INSERT INTO public.badge_defs VALUES (102, 'Christmas 21', 'Awarded for surviving Fistmas 2021', NULL);
INSERT INTO public.badge_defs VALUES (103, 'Benefactor', 'Gave the Benefactor award to someone', NULL);
INSERT INTO public.badge_defs VALUES (104, 'BADASS OUTLAW', 'Bad boy who does not play by the rules', NULL);
INSERT INTO public.badge_defs VALUES (105, 'SCAM', 'lmao get fucked retard', NULL);
INSERT INTO public.badge_defs VALUES (153, 'Professional Hathead', 'Collected 100 unique hats', NULL);
INSERT INTO public.badge_defs VALUES (107, 'Certified BIPOC', 'The mayocide starts now', NULL);
INSERT INTO public.badge_defs VALUES (108, 'Nword Pass', 'With great power comes great responsibility', NULL);
INSERT INTO public.badge_defs VALUES (154, 'Fiscally Irresponsible Hathead', 'Collected 250 unique hats', NULL);
INSERT INTO public.badge_defs VALUES (110, 'Wolf Artisan', 'Contributed a Zombie Wolf emoji ✨', NULL);
INSERT INTO public.badge_defs VALUES (111, 'Wolf Master', 'Contributed 10 (or more!!!!) Zombie Wolf emojis ✨', NULL);
INSERT INTO public.badge_defs VALUES (112, 'Platy Artisan', 'Contributed a Platy emoji ✨', NULL);
INSERT INTO public.badge_defs VALUES (113, 'Platy Master', 'Contributed 10 (or more!!!!) Platy emojis ✨', NULL);
INSERT INTO public.badge_defs VALUES (109, 'Rehab Award', 'Prevented from gambling', NULL);
INSERT INTO public.badge_defs VALUES (114, 'Capy Artisan', 'Contributed a Capy emoji ✨', NULL);
INSERT INTO public.badge_defs VALUES (115, 'Capy Master', 'Contributed 10 (or more!!!!) Capy emojis ✨', NULL);
INSERT INTO public.badge_defs VALUES (116, 'Outreach Award', 'Brought invaluable drama to the starving masses off-site', NULL);
INSERT INTO public.badge_defs VALUES (128, 'Fart-Free', 'This user does NOT fart.', NULL);
INSERT INTO public.badge_defs VALUES (117, 'Stone Skeptic', 'This user rejects igneous lies', NULL);
INSERT INTO public.badge_defs VALUES (129, 'Misinformation Superspreader', 'This poster was fact checked by real American patriots', NULL);
INSERT INTO public.badge_defs VALUES (130, 'Columbine Enthusiast (TEMPORAL FLUX EDITION)', 'This user is an acclaimed Reb+VoDKa slash author', NULL);
INSERT INTO public.badge_defs VALUES (159, 'It''s Over', 'Lost a 100,000 dramacoin bet. It''s fucking over.', NULL);
INSERT INTO public.badge_defs VALUES (161, 'Pro Goombler', 'Won a 10,000 dramacoin bet. Some would say to quit while you''re ahead, but they didn''t just win 10k - keep at it!', NULL);
INSERT INTO public.badge_defs VALUES (165, 'Marsey Chanel', 'Designed 100 hats!!!', NULL);
INSERT INTO public.badge_defs VALUES (28, 'Chud', 'Marked as a chud', NULL);
INSERT INTO public.badge_defs VALUES (171, 'Rainbowed', 'This user has super cute text', NULL);
INSERT INTO public.badge_defs VALUES (135, '1st Birthgay Bash Survivor', 'Awarded for surviving rDrama''s first annual Birthgay Bash', NULL);
INSERT INTO public.badge_defs VALUES (59, 'Lolcow', 'Beautiful and valid milk provider', NULL);
INSERT INTO public.badge_defs VALUES (25, 'Marsey''s Sugar Daddy', 'Contributed at least $100', NULL);
INSERT INTO public.badge_defs VALUES (26, 'JIDF Bankroller', 'Donated at least $250', NULL);
INSERT INTO public.badge_defs VALUES (27, 'Rich Bich', 'Contributed at least $500', NULL);
INSERT INTO public.badge_defs VALUES (118, 'Hit!', 'Confirmed removal of a r/stupidpol post for hate speech or threatening violence', NULL);
INSERT INTO public.badge_defs VALUES (119, 'BIG Hit!', 'Confirmed removal of a /r/stupidpol MODERATOR''S post for hate speech or threatening violence', NULL);
INSERT INTO public.badge_defs VALUES (120, 'Msar Bomba', 'Confirmed ban of a r/stupidpol user', NULL);
INSERT INTO public.badge_defs VALUES (121, 'Order of Marsey, 2nd Class', 'Confirmed temp ban of a r/stupidpol moderator', NULL);
INSERT INTO public.badge_defs VALUES (122, 'Order of Marsey, 1st Class', 'Confirmed permanent ban of a /r/stupidpol moderator', NULL);
INSERT INTO public.badge_defs VALUES (123, 'Hero of the Marsey Union', 'Awarded to all soldiers who served during the Special Military Operation to de-nazify r/stupidpol', NULL);
INSERT INTO public.badge_defs VALUES (124, 'COOL GUY', 'This user does NOT watch anime', NULL);
INSERT INTO public.badge_defs VALUES (125, 'Certified LOSER', 'This user watches anime', NULL);
INSERT INTO public.badge_defs VALUES (126, 'Survivor', 'This user braved the Oregon Trail and lived to tell the tale', NULL);
INSERT INTO public.badge_defs VALUES (127, 'Wagonfire', 'This user braved the Oregon Trail and fucking died lmao', NULL);
INSERT INTO public.badge_defs VALUES (131, '21st Century Hitlerite (TEMPORAL FLUX EDITION)', 'This user lost the love of their life in 1940s Berlin', NULL);
INSERT INTO public.badge_defs VALUES (132, 'Duterte''s Most Wanted (TEMPORAL FLUX EDITION)', 'dude weed lmao what year is it', NULL);
INSERT INTO public.badge_defs VALUES (133, 'Rockstar', 'This user submitted an original piece to the song contest', NULL);
INSERT INTO public.badge_defs VALUES (134, '1 Year Old 🥰', 'This user has wasted an ENTIRE YEAR of their life here! Happy birthday!', NULL);


--
-- Name: badge_defs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.badge_defs_id_seq', 176, true);


--
-- PostgreSQL database dump complete
--

--
-- PostgreSQL database dump
--

-- Dumped from database version 14.4
-- Dumped by pg_dump version 14.5 (Ubuntu 14.5-1.pgdg20.04+1)

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
-- Data for Name: hat_defs; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.hat_defs VALUES (1, 'Ushanka', 'The People''s Hat', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (2, 'Fur Hat', 'The first step on your path to fursuit ownership', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (3, 'Cat Ears I', 'Mew :3', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (4, 'Cat Ears II', 'Meow :3', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (5, 'Playboy Bunny', 'Will this bring daddy back?', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (6, 'Macaroni', 'Get it? Like the song lol', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (7, 'Pirate', 'BUTT pirate', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (8, 'Pirate Captain', 'Like a regular butt pirate, but for tops only', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (9, 'Dreads', 'Finally, an excuse for poor hygiene', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (10, 'The XXXTentacion', 'Pay homage to your favorite dead criminal!', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (12, 'The Elvis', 'Remember when this dude nailed a 13-year-old?', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (13, 'Gussy Hat', 'Let everyone know that you''re NOT a rapist. Honest.', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (14, 'Riveter', 'Can you do it? Really?', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (15, 'Top Hat (leprechaun)', 'LLM but Irish', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (16, 'Drinky Beer Hat', 'I actually didn''t know these were real things until I made this', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (17, 'Viking', 'Rape, pillage, never bathe. Live the dream.', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (532, 'Under His Eye', 'WATCH ANOTHER SHOW', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (22, 'Southern Gentleman', 'Slaveowner? Fried chicken chain founder? You decide!', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (23, 'Cowboy I', 'Make him wish he could quit you', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (24, 'Cowboy II', 'You''re my favorite deputy!', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (25, 'Halo', 'Dramamine criticized this one and now I''m too self-conscious about it to write a description', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (26, 'Fedora I', 'M''arsey', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (27, 'Bowler', 'Why would you need a hat to go bowling?', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (28, 'Du Rag (black)', 'Shitty bandana 1/6', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (29, 'Du Rag (red)', 'Shitty bandana 2/6', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (30, 'Du Rag (blue)', 'Shitty bandana 3/6', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (31, 'Du Rag (purple)', 'Shitty bandana 4/6', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (32, 'Du Rag (green)', 'Shitty bandana 5/6', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (33, 'Du Rag (yellow)', 'Shitty bandana 6/6', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (34, 'Ash Ketchum', 'You''re not so different, you and he', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (35, 'The Hotep', 'Traditional kangwear. POC ONLY.', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (36, 'Roman', 'Reddit delenda est', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (37, 'Confederate Soldier Cap', 'Basically the Gryffindor of American history', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (38, 'Northern Aggressor Soldier Cap', 'Slytherin irl', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (39, 'Rhodesian Light Infantry Beret', 'Rhodesians never die. Immortality guaranteed!', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (40, 'Magyar Headdress', 'Channel your inner QuadNarca and join Orban''s elite cavalry', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (41, 'The Senator Warren', 'heya heya heya heya heya heya heya heya heya heya heya', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (42, 'Please Be Patient I Have Autism', 'The OFFICIAL hat of rDrama.net', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (44, 'Watermelmet', 'Hydration and head protection all rolled into one stylish headpiece', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (45, 'Frankenstein', 'Akshually, Frankenstein was the scientist. The monster didn''t have a name.', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (46, 'The Drumpf', 'Orange hair bad', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (47, 'Tinfoil Hat', 'Keep Bill Gates'' 5G vaccine OUT of your precious brain!', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (48, 'Fez', 'Isn''t it CUTE?', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (49, 'Ching Chong', 'Me Chinese Me No Dumb Me Stick Finger In Daddy''s Bum', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (50, 'Octopus Friend', 'Awwwwwww!', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (51, 'In The Navy', 'It''s not gay', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (52, 'Seaman', 'semen lol', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (53, 'Flower Crown I', 'oh god i have to write descriptions for 15 flower crowns', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (54, 'Flower Crown II', 'A very cute flower crown', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (55, 'Flower Crown III', 'A super cute flower crown', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (56, 'Flower Crown IV', 'A really cute flower crown', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (57, 'Flower Crown V', 'The cutest flower crown?', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (58, 'Flower Crown VI', 'An extremely cute flower crown', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (59, 'Flower Crown VII', 'A flower crown that''s just so cute', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (60, 'Flower Crown VIII', 'A majorly cute flower crown', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (61, 'Flower Crown IX', 'A mega cute flower crown', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (62, 'Flower Crown X', 'An ultra cute flower crown', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (63, 'Flower Crown XI', 'Definitely the cutest flower crown', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (64, 'Flower Crown XII', 'A hella cute flower crown', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (65, 'Flower Crown XIII', 'An experimental anti-gravity cute flower crown', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (66, 'Flower Crown XIV', 'An adorably cute flower crown', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (67, 'Flower Crown XV', 'The final cute flower crown', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (68, 'Bow', 'What a cute little bow omg', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (69, 'BIPOCsmoke', 'It''s a Newport. You know it''s a Newport.', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (70, 'Gigachin', 'Aw yeah, this user definitely supports trans rights', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (71, 'Queensguard', 'A bear died for this', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (72, 'Queen Crown', 'Don''t be a drag', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (73, 'King Crown', 'King is like the n word, only racists and black people should be allowed to say it', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (74, 'Pope Hat', 'Matthew 16:18', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (75, 'Heebhead', 'Do NOT google the Lavon Affair', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (76, 'Zoomie Zoom Zoom', 'Underage user, do not interact', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (77, 'Sombrero I', 'El Autistico', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (78, 'Sombrero II', 'El Autistico Grandisimo', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (79, 'Crypto Billionaire', 'Sorry about the ice cream machine', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (80, 'Burger King Crown', 'I''m gonna say it', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (81, 'Burger King', 'You can have it your way and you still chose this', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (82, 'Wendys', 'Sassy social media intern', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (83, 'KFC', 'Popeyes is too far away', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (84, 'In-N-Out', 'Kill the commiefornian', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (85, 'Carls Jr', 'Purveyor of literally the finest food in the world', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (86, 'Whataburger', 'Texans don''t know any better', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (87, 'Five Guys', 'I love having 5 guys in my mouth', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (88, 'Taco Bell', 'Enabler of drunken mistakes', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (89, 'Marsey-In-A-Box', 'Awww you''re playing make-believe!', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (90, 'Orthodox Hood', 'User is a schismatic lunatic', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (91, 'Afro', 'Pool''s closed motherlover', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (18, 'Nonspecific Military Officer Hat', '[removed]', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (19, 'Soviet Officer I', 'OUR hat', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (408, 'Chef Hat II', 'Toque blanche', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (414, 'Trilby', '*tip*', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (419, 'Alimony Hair', 'Stay norwooding, king', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (92, 'Top Hat (black)', 'Traditional. Classy. Elegant.', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (93, 'Wizard I', 'Three decades a KHHV', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (94, 'Wizard II', 'Avada kedavra ✨', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (95, 'Witch I', 'Hex the patriarchy', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (96, 'Witch II', 'Bardfinn cosplay gear', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (97, 'Sun Hat', 'Tradwife simplicity', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (98, 'Obey Snapback', 'The timeless classic', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (99, 'Thug Life Snapback', 'User confirmed mayo', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (101, 'Make America Great Again', 'The official headgear of stochastic terrorists everywhere', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (102, 'Born To Feel', 'Do you pee standing up?', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (103, 'Fortunate Son', 'BORN TO SHIT FORCED TO WIPE', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (104, 'WWI', 'How is this supposed to offer any meaningful protection??', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (105, 'Pickelhaube', 'Inarguably the most fashionable of all contemporary military headgear ', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (106, 'Wehrmacht', 'What a cool helmet, I bet the people who wore it were real classy folks ', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (108, 'Helmet w Dog Tags', 'More like dog fags lol', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (109, 'Urban Camo Helmet', 'Man urban camo is cool', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (110, 'Nightvision Helmet', 'Four-eyed freak', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (111, 'Helmet w Mesh', 'Sexy fishnet stocking helmet', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (112, 'Tojo Helmet', 'Artifact from Weeb War II', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (113, 'Officers Cap', 'Get fragged bozo', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (114, 'Jailbird Cap', 'The apex of prison fashion. Why did we stop using this?', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (115, 'P-Hat (green)', 'Zezima fanboy', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (116, 'P-Hat (red)', 'おれはPigAmericanですおれはばか i am average american man i enjoy bad game runescape', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (117, 'P-Hat (yellow)', 'PISS HAT PISS HAT', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (118, 'P-Hat (blue)', 'Ughhhh coming up with different descriptions for RuneScape party hats', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (119, 'P-Hat (pink)', 'It''s pink.', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (120, 'P-Hat (rainbow)', 'LGBTscape 😍', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (121, 'Newsboy', 'Or newsgirl. It''s okay, the hat is actually gender-neutral.', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (122, 'Whirly Tard Hat I', 'Wouldn''t it be neat if they could make one that like uses body heat or whatever to keep the propeller in a state of constant motion', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (123, 'Dunce Cap', 'You retard. Imbecile. Utter buffoon. Oaf. Nincompoop. Idiot. Moron. CLOWN.', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (124, 'Beret', 'Literally the most basic possible hat choice. Please do better. ', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (125, 'Mario', 'BING BING WAHOO ', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (126, 'Luigi', 'LING LING LAHOO', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (127, 'Wing Cap', 'If the hat''s wings are what provide the thrust necessary for flight then how does it stay on and let YOU fly with it huh', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (128, 'Metal Mario', 'Mario hat but with yelling and lots of double bass and distorted guitars and shit heck yeah', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (129, 'Cappy', 'A sentient hat-creature that''s actually a pretty horrifying parasite if you think about it', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (130, 'Wario', 'For the fat, yellow, extremely flatulent dramautist (in loving memory of Bidpots)', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (131, 'Waluigi', 'Coming soon to Smash for sure', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (132, 'Top Hat (kek)', 'Technically a top hat, shut up', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (133, 'Top Hat (white)', 'Oh, how dignified', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (135, 'Top Hat (checkered)', 'Actually chessed, but that''s not really a word.', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (136, 'Top Hat (march hare)', 'April hare, May hare, June hare, July hare,', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (137, 'Top Hat (mad hatter)', 'Hatters mad [x24]', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (533, 'Uncle Sam', 'The world needs our brand of democracy', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (139, 'Top Hat (uncle sam)', 'THIS HAT WAS FACT-CHECKED BY TRUE AMERICAN PATRIOTS', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (140, 'Fireperson I', 'In loving memory of r/HateForFirefighters', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (141, 'Constable', 'Useless bong cop nonsense', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (142, 'NYPD Officer', 'This user is authorized to stop, frisk and cavity search you at any time for any reason', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (143, 'Crossing Guard', 'We love Officer Marsey!', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (144, 'Paper Sailor', 'As idle as a paper ship, upon a paper ocean. Paper, paper, everywhere.', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (145, 'FBI', 'Federal Bussy Inspector', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (146, 'CIA', 'Cisgender Incineration Agency', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (147, 'ATF', 'Ass-Tickling Faggot. HIDE YOUR DOG!', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (148, 'Graduate', 'This hat signifies that the bearer has completed four (4) years of pan-african gender studies coursework', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (149, 'Nurse', 'Minor TikTok celebrity, OnlyFans top 91%', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (150, 'Farmer', 'Feed & Seed shopper', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (151, 'Farmette', 'Feed & Seed shoppette', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (152, 'Kung Lao', 'Why did I make a Kung Lao hat', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (153, 'Top Hat (steampunk)', 'Like a regular top hat but with goggles and gears', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (154, 'Brain Hat', 'Peter Griffin''s dog', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (155, 'The TED_SIMP', 'Wear this hat to express your undying adoration for carp', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (156, 'The Brandon', 'Listen here fat', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (158, 'The King George', 'Proto-drag if you think about it', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (159, 'The Mao', 'Our hair!', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (160, 'The Young Stalin', 'Pockmarks not included', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (161, 'The Ripe Stalin', 'An homage to the #1 most prolific killer of commies in world history', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (162, 'The Austrian Painter', 'For aficionados of mid-20th century fine artists slash authors', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (164, 'Modern Major General', 'For my military knowledge, though I''m plucky and adventury / Has only been brought down to the beginning of the century / But still, in matters vegetable, animal, and mineral / I am the very model of a modern Major-General', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (165, 'Red Star Cap', 'Cannon fodder', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (166, 'Cartman', 'Fat antisemite - the archetypal rDrama user', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (167, 'Cheesehead', 'For fans of the Green Gay Fudge Packers', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (168, 'Kyle', 'ngl I don''t watch South Park so idk the difference between this and Stan', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (169, 'Stan', 'ngl I don''t watch South Park so idk the difference between this and Kyle', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (170, 'Kenny II', 'Like Kenny I except it shows more of your ugly face', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (171, 'The Cleopatra', 'Did you know she was actually white?', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (172, 'Pimp Hat I', 'Women are objects', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (138, 'Top Hat (red)', 'Top hat, menstrual edition', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (157, 'The Brandon II', 'LISTEN HERE FAT', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (100, 'Supreme Snapback', 'Drip so hard omg', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (107, 'Chair Force', 'Yeah I''m a combat veteran, I''ve seen shit you wouldn''t believe. One time the wifi was out for almost an hour. ', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (173, 'Devil Horns', 'Satan is so cool and quirky!!!', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (174, 'Nooticer', 'THIS USER IS ENGAGED IN THOUGHTCRIME. DO NOT INTERACT.', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (175, 'Airpods', 'oh god oh fuck he cant hear us', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (176, 'Maskmaxxer', 'Why aren''t there two? Are you trying to kill us?', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (177, 'The Tupac', 'dead nigger storage', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (178, 'Media Executive', 'despite making up just 2% of the population,', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (179, 'Surgeon', 'Lobotomize me daddy', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (180, 'Mouseketeer', 'please don''t sue please don''t sue please don''t sue please don''t sue please don''t sue', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (181, 'Karen', 'Let me speak to your manager', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (182, 'Badass Fighter Ace', ' Top Gun™ Maverick® Now Showing In Theaters!', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (183, 'Taqiyah', 'It''s not a yarmulke I swear', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (184, 'Cock', 'DM me yours!', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (185, 'Nervous, Sweating', '>mfw', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (186, 'The Cat', 'does this really need a description', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (187, 'Noose', 'Cope or rope', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (188, 'The Penny', 'This shower cap bonnet is perfect for hiding nappy, alopecia-ridden hair', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (189, 'Hard Hat (yellow)', 'A rock hard, throbbing, veiny hat. Check out the girth on this thing', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (190, 'Hard Hat (white)', 'The mayo variant of the hard hat, used to signify someone of importance, or a visitor, at a job site', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (191, 'Beret (TF2)', 'Stylish vidya-variant of the beret', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (192, 'Texas Ten Gallon', 'Yeehaw!', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (193, 'Demoman', 'KaBOOM', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (194, 'Fireperson II', 'For extinguishing hot threads', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (195, 'Miners Hat', 'Please don''t touch minors', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (196, 'Old Man Hat', 'AKA the Wizdumb', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (197, 'Pimp Hat II', 'Women are people and they deserve respect just kidding they should suck my penis', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (198, 'Whirly Tard Hat II', 'Propeller go brrrrrrrrrr', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (199, 'Family Man Free Hat', 'It''s a good show!', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (200, 'Engineer', 'Choo choo!', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (201, 'Vexillaurius Helmet', 'Degenerates like you belong on rDrama', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (202, 'Astronaut Helmet', 'See you, space marsey', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (676, 'Kepi', 'Army cap for those unlucky enough to be French', 1, 500, NULL, 1663303083);
INSERT INTO public.hat_defs VALUES (134, 'Top Hat (striped)', 'Tim Burton''s take on the top hat', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (11, 'The 6ix9ine', 'The finest piece of snitch couture on the market', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (534, 'Para Para Sakura', 'セックスする!', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (678, 'Turkroach', 'Come on Carp this one''s hilarious. It''s semi transparent to clarify', 1, 500, NULL, 1663305640);
INSERT INTO public.hat_defs VALUES (679, 'Judge Dredd', 'THIS USER IS THE LAW', 1, 500, NULL, 1663309533);
INSERT INTO public.hat_defs VALUES (680, 'Hat Stack', 'You are as presumptuous as you are poor and Irish. Challenge not the majesty of my tower of hats.', 1, 500, NULL, 1663310312);
INSERT INTO public.hat_defs VALUES (681, 'Avatar State', 'But when the world needed him most, the Dramatar vanished', 1, 500, 3370, 1663357705);
INSERT INTO public.hat_defs VALUES (682, 'Vampire Mask', 'Totally a current member of House Vampire', 1, 500, 3370, 1663368597);
INSERT INTO public.hat_defs VALUES (683, 'True Capitalist', 'This user is a melting pot of friendship. And a brony.', 1, 500, 768, 1663378533);
INSERT INTO public.hat_defs VALUES (684, 'cans dot wav', 'I am your host, the man they call Ghost.', 1, 500, 768, 1663378616);
INSERT INTO public.hat_defs VALUES (685, 'MasterLawlz', 'Ben 10 aficionado and connoisseur.', 1, 500, 2370, 1663400628);
INSERT INTO public.hat_defs VALUES (686, 'Pingas', '"Snooping as usual, I see!"', 1, 500, 2370, 1663400760);
INSERT INTO public.hat_defs VALUES (687, 'Robbie Rotten', 'Number one hairstyle!', 1, 500, 2370, 1663400876);
INSERT INTO public.hat_defs VALUES (259, 'Marsey Headbang', 'She''s banging on your head lmao get it', 1, 1000, NULL, NULL);
INSERT INTO public.hat_defs VALUES (688, 'Stephanie', 'I am not a creep. It was the third image result when I googled "Robbie Rotten hair png"', 1, 500, 2370, 1663400979);
INSERT INTO public.hat_defs VALUES (689, 'Sportacus', 'Unofficial mascot of /r/fatpeoplehate', 1, 500, 2370, 1663401163);
INSERT INTO public.hat_defs VALUES (258, 'Clownpaint', 'WHOOP WHOOP MATHOFACKO', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (213, 'The Penny II', 'Out of the shower :marseybath: cap, into the bandana', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (278, 'The Justinian', 'Glory to God who has thought me worthy to finish this work. Solomon, I have outdone you.', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (263, 'Colonizing Oppressor', 'Why would you ADMIT to this?', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (264, 'The TracingWoodgrains', 'Bweaking nuwus!', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (265, 'Cat Ears (devil horns)', 'Has science gone too far?', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (268, 'The TracingWoodgrains II', '*nuzzles your bulge mid-interview* OwO whats this', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (273, 'Pilot Hat', 'Daily nonstop flights to Bussyville', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (536, 'The Banzai Bandana', 'May Marsey live ten thousand years!', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (538, 'Timmy Turner', 'So you''re telling me I can wish for ANYTHING?', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (539, 'Fairly Oddparent', 'Obtuse, rubber goose, green moose, guava juice, giant snake, birthday cake, large fries, chocolate shake!', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (540, 'Oney', 'Look Tomar, it''s you.', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (541, 'Morshu', 'Lamp Oil, Rope, Bombs! You want it? It''s yours, my friend! As long as you have enough RUPEES.', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (542, 'Link (Faces of Evil)', 'Could you eat an octorok?', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (543, 'Harkinian (Faces of Evil)', 'Marsey mah boy', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (544, 'Train Conductor', 'It’s MY neurodivergence and I get to choose the special interest', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (546, 'Reimu Bow', 'Gensokyo border control', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (547, 'The Microdose', 'A smaller, safer dose for those who need to self-medicate in public.', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (548, 'The Snooplet', 'I can exercise you, this can be your phys ed, spend all your cizzoins, just perch me on your hizzead', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (550, 'The Entertainment', 'A prize for clever birthday boys that save their tokens.', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (553, 'Banana Bucket Hat', 'Peanut butter jelly time', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (552, 'Doomer Beanie', 'blackpilled again', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (554, 'Clop', 'DM me for MLP clop ERP', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (561, 'The Lawlz', 'Have Max the Dog join you on your PFP. Rest in paradise king!', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (558, 'Suicide King', 'Lost it all in the 52 cards', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (560, 'Dual-Wield Katanas', 'Forged from real Nippon steel, folded 1000 times, shipped directly to your local mall kiosk.', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (564, 'The African Kufi', 'The white man doesn''t want you to know that this website was created by an AFRICAN king', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (563, 'The Dundee', 'That''s not a hat. THIS is a hat!', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (566, 'Heart Crown (rainbow)', '❤🧡💛💚💙💜', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (565, 'Sparkles Crown', '✨✨✨', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (572, 'Heart Crown (sparkles)', '💕💛💔💗♥🖤✨💙 or something idk', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (573, 'CENSORED', '💔literally 1984 💔', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (574, 'Heart Crown (Rainbow II)', 'More gay than the other rainbow heart crown 👍', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (575, 'Heart Crown (superstraight)', '🖤🧡🖤🧡🖤🧡', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (567, 'Heart Crown (blue and purple)', '💙💜', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (568, 'Emoji Crown (hearts and shooting stars)', '💫This is techically the dizzy symbol, but it looks like a shooting star for Apple users 😘', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (576, 'Emoji Crown (sunflower honeypot)', '🌻🍯✨', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (578, 'Baddie Cap', 'All real baddies wear this hat', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (579, 'Skull Mask', '💀Stop the spread!💀', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (580, 'DUM post it note', 'For when u dum :(', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (581, 'I Pee In Pools Cap', 'Share your stance on pool urination', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (582, 'Bee Crown', 'Buzz buzz buzz', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (584, 'Flower Crown (sunflowermoji)', 'A very cute sunflower crown', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (585, 'Fire Crown', '🔥🔥🔥', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (586, 'Weeb Angry Symbol', '😠', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (587, 'Fedora (Red Hat Enterprise Linux)', 'Reminds me of 2004', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (583, 'Weird Banner', 'You may only wear this if you are weird! No appropriation by non weirdos, thx', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (588, 'Large Bow (light pink and blue)', 'It really is a very large bow', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (589, 'The Penny III', 'ALOPECIA B-GONE', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (590, 'Top Hat (rattlesnake)', 'Top hat decorated with rattlesnake', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (591, 'PLA Hat', '中国梦', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (592, 'Du Rag (flames)', 'Shitty bandana 7/6', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (593, 'Top Hat (red and black)', 'This isn''t the right hat for everyone, but is it the right hat for you?', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (594, 'Tin Foil Fedora', 'm''lady, I must warn you of the elecromagnetic mind control rays', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (595, 'The Coon', 'Davy Crockett wore it and now it’s on rDrama', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (597, 'White bow Headband', 'simplicity', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (598, 'Du Rag (black and red)', 'Shitty headband 8/6', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (599, 'Tricorn Hat (brown leather)', 'ruggedized and heavy duty tricorn hat', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (600, 'Captain America Cap', 'WOW I HECKIN LOVE SUPERERO', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (601, 'Cowboy Hat (Jewish)', 'brown leather cowboy hat with a six pointed star', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (602, 'Cowboy Hat (American)', 'Yeehaw faggot', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (603, 'Balaclava (Shark teeth)', '🦈', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (604, 'Backwards Cap', 'How do you do fellow r/teenagers', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (606, 'Fancy Hat (blue and black)', 'made with stable diffusion!', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (607, 'Cheerful colorful knit hat with flower', 'also made with stable diffusion!', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (608, 'Hat of the Future (art deco)', 'According to Stable Diffusion, this is the hat of the future. It''s also art deco, because that gave cooler results.', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (569, 'Paul', 'cringe and dramaphobic llama', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (535, 'The Soren', 'discuss', 1, 1000, NULL, NULL);
INSERT INTO public.hat_defs VALUES (577, 'Zoomie Zoom Zoom II', 'Underage user, do not interact', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (618, 'Cuban Pete', 'Given only to the biggest space assholes.', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (619, 'Marsified', 'become the marsey', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (620, 'Glowing Pickelhaube', 'Glows in the dark, like a secret police', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (559, 'Roulette', 'Around and around it goes', 1, 1000, NULL, NULL);
INSERT INTO public.hat_defs VALUES (551, 'Soyjak Pointing', ':O Dude dude DUDE! Look at this user :OOOOOO', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (555, 'Egg_irl', 'Ask me about my pronouns', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (280, 'Gold Laurel Wreath', 'Veni, vidi, vici', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (332, 'Hairlet', 'It never even began', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (266, 'King Crown II', 'King is our word but you can say kang', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (267, 'Furry Marsey', 'Never forget that Marsey is a furry OC and this site is themed around fanart of her', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (270, 'Perry the Platypus', 'Platybussy > Platygussy', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (271, 'Zorro', 'Z!', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (274, 'Shemagh', 'Shemagh is such an ugly word. It sounds like a phlegmy noise. Even looks like the word phlegm.', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (275, 'Bloods', 'BRIPS GET THA BLATT BLATT', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (276, 'Conscience', 'i can be yuor angle or your devil', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (269, 'SCARY GUN', 'He called it an AK-74u but I''m not sure if that''s right idk idk', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (537, 'The Celtic Kufi', 'Irish were the REAL slaves, stay woke my deartháir', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (549, 'The Bumper Sticker', 'Turn yourself into a legal liability that could threaten the very site itself!', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (571, 'Purple Emoji Crown', '💜💜💜when ur selfie needs an emoji crown with a 🌻, a 👻, and a 🐻 but u still gotta fit that purple aesthetic 💜💜💜', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (570, 'Carl', 'based and dramapilled llama', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (531, 'Zen', 'follow the fish follow the fish follow the fish follow the fish follow the fish', 1, 1000, NULL, NULL);
INSERT INTO public.hat_defs VALUES (612, 'Wizard Hat (pixel)', 'Some sort of vidya thing idfk', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (614, 'Chickenhead', '🤗', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (621, 'The Soren II', 'Soren is an idea, not a person. Shoot him. It’s okay, the bullets do nothing. Try it!', 1, 1000, NULL, NULL);
INSERT INTO public.hat_defs VALUES (279, 'Libertarian', 'This user has certainly read Atlas Shrugged', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (282, 'Green Laurel Wreath', 'Render unto Caesar the things which belong to Caesar', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (557, 'Cottagecore', 'Show your solidarity with men-who-have-sex-with-men by giving them a safe, public space to do whatever it is they''re doing back there.', 1, 1000, NULL, NULL);
INSERT INTO public.hat_defs VALUES (622, 'Colonial Chapeau', 'Whatever happens/we have got/the Maxim gun/and they have not', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (624, 'Metal Gear', 'Detected!', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (291, 'Yea Daddy Choker', 'Remember who you belong to', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (296, 'Sunhat II', 'Yellow to camouflage you from the sun, cunningly making it believe you are one of its own kind. And then you strike.', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (298, 'Flower Bonnet', 'An indescribably cute flower cro- bonnet.', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (299, 'Raspberry Hat', 'Little sissy French girl hat', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (300, 'Lemonsqueezer', 'Iconic kiwi headwear with a very stupid name', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (301, 'Dickhead', 'Really proud of the name for this one. Well done, me!', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (627, 'Pedo Sniper (right)', 'I''m not which is worse - being a pedo, or being left handed?', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (628, 'Gnome Child', 'My mum says: A friendly look, a kindly smile one good act, and life''s worthwhile!', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (308, 'Pothead', 'Cali-grown cast iron goodness', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (631, 'Country Club Visor', 'What country club members wear when discussing your reddit account', 1, 500, NULL, 1663033011);
INSERT INTO public.hat_defs VALUES (311, 'The Lucas Roberts', '#DropKiwiFarms #MandatoryHRTForAllKids', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (632, 'Jotaro Hat', 'The iconic cap of a buff punchy weebshit guy', 1, 500, NULL, 1663033206);
INSERT INTO public.hat_defs VALUES (317, 'AI-Generated Hat', 'Stable Diffusion recommended a 10k price point for this 🤔', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (318, 'Headphones (black)', 'Situational awareness: 0', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (320, 'Summer Hat', '[incoherent Hawaiian gibbering]', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (321, 'Attention Whore', 'DUDE BUSSY LMAO MARSEY HECKIN VALIDERINO AMIRITE BTW I AM TRANS', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (322, 'Pirate Hat II', 'Swab the POOP deck with your TONGUE', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (323, 'Mafioso', 'Something something gabagool 🤌', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (325, 'The Sal', 'Watch me go nowhere in two weeks (I AM SO DEPRESSED)', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (629, 'Marisas Big Witch Hat', 'Fascism is when witches wear big hats, the bigger the hat the more fascist you are.', 1, 500, NULL, 1663010108);
INSERT INTO public.hat_defs VALUES (328, 'Skidmarks', 'Hit me with your car daddy 🤪', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (329, 'Behind Bars', 'Uh oh, someone forgot to say In Minecraft', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (330, 'Panzer Driver', 'No war crimes here, just tanks!', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (331, 'Ghostly Gibus', '(achievement item: not tradable or marketable)', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (333, 'Astronaut Helmet II', 'Used for intrepid explorers of Hollywood basements', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (335, 'Kippah', 'rDrama: a light unto nations', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (337, 'The Tim Pool', 'No one can make fun of you for being bald if you never ever ever ever take it off', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (338, 'Digigoggles', 'DIGIMON. DIGITAL MONSTERS. DIGIMON ARE THE CHAMPIONS.', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (339, 'Sorting Hat', 'HUFFLEPUFF!', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (340, 'Metroid', 'Some sort of alien parasite thing I think. It wants a kiss.', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (341, 'The One Hat', 'One hat to rule them all', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (342, 'Kawaii Usage Hat', 'Bunny bunny bunny bunny bunny bunny bunny bunny bunny bunny bunny bunny', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (343, 'Shroomjak (red)', '🍄🍄🍄🍄🍄🍄🍄🍄', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (20, 'Nonspecific Military Officer Hat II', '[removed]', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (21, 'Soviet Officer II', 'High fashion war criminal chic', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (212, 'Sneed', 'From the business formerly known as Chuck''s Seeduck and Feeduck', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (214, 'Hijab', 'The ONLY way to stop being a whore', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (215, 'Cock II', 'Honk honk', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (216, 'Cummies', 'Yummy yummy cummies in my tummy tummies', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (211, 'Zombiewolf Helmet', 'Everyone knows it''s rDrama''s true mascot', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (633, 'Man, I Love Fishing', 'post-wall appreciator', 1, 500, NULL, 1663043038);
INSERT INTO public.hat_defs VALUES (218, 'Clown Wig', 'Why so serious?', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (219, 'Jimmy Hat', 'Don''t be silly, wrap your willy!', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (220, 'Bane Mask', 'If I pull that off, will you die?', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (221, 'Wolf Ears I', 'OwO what''s this?', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (222, 'Smugjak', 'I''m drunk and can''t think of a good description lol', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (223, 'Foolproof Disguise', 'What''s that, officer? You''re looking for [USERNAME GOES HERE CARP CAN''T CODE]? Never heard of him!', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (224, 'Brain Slug', 'This poor brain slug is STARVING TO DEATH :(', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (272, 'Harry Potter', 'General in the Mages vs. Matriarchy war', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (324, 'Lord of the Flies', 'Sucks to yer ass-mar!', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (314, 'Bright Idea II', 'Guys. GUYS. Bait sub idea: r/HateForGoodThing', 1, 1000, NULL, NULL);
INSERT INTO public.hat_defs VALUES (316, 'Globohomo', 'The gay agenda is no longer optional.', 1, 1000, NULL, NULL);
INSERT INTO public.hat_defs VALUES (313, 'Bright Idea I', 'Guys. GUYS. BAIT SUB IDEA: r/LoveForBadThing', 1, 1000, NULL, NULL);
INSERT INTO public.hat_defs VALUES (225, 'Pat Hat', 'Who''s Daddy;s special little boy?', 1, 1000, NULL, NULL);
INSERT INTO public.hat_defs VALUES (277, 'Cool Wine Aunt', 'It''s pruno, don''t pretend you''re fancy', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (284, 'The Gary Plauche', 'We can''t expect God to do all the work', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (292, 'Marsey Smug Mask', 'I''m not seething, you''re seething', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (295, 'Pinkhat', 'It''s a hat and it''s pink and your nan looks adorable in it. Not you, though.', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (310, 'Bandit Bandana', 'This thread ain''t big enough fer the  of us', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (327, 'Ageplayer', 'It''s cool if it''s not your thing, just don''t yuck someone else''s yum :)', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (312, 'Super Saiyan', 'Taqueria ‘Goku''', 1, 1000, NULL, NULL);
INSERT INTO public.hat_defs VALUES (635, 'Gagged n Blinded', 'Ask me about my sex swing', 1, 500, NULL, 1663049833);
INSERT INTO public.hat_defs VALUES (634, 'Roxy Hair', 'Dommy mommy animatronic wolf', 1, 500, NULL, 1663043599);
INSERT INTO public.hat_defs VALUES (638, 'Chen', 'HONKS VIOLENLTY', 1, 500, NULL, 1663100660);
INSERT INTO public.hat_defs VALUES (636, 'Senjutsu', 'HAAAAAAAAVE YOU SEEN THE WRITING ON THE WALL?', 1, 500, NULL, 1663094125);
INSERT INTO public.hat_defs VALUES (640, 'Bored Ape', 'DO NOT RIGHT CLICK!', 1, 500, NULL, 1663105351);
INSERT INTO public.hat_defs VALUES (641, 'MUSHROOM CLOUD', 'The Samson Option has been invoked.', 1, 1000, NULL, 1663121242);
INSERT INTO public.hat_defs VALUES (643, 'Only One Large Snake Not Mating', 'Looks cute until she''s on YOUR head', 1, 500, NULL, 1663132332);
INSERT INTO public.hat_defs VALUES (644, 'Poppy', 'The TRUE rDrama mascot', 1, 500, NULL, 1663132488);
INSERT INTO public.hat_defs VALUES (645, 'The SRDine', 'CANNED', 1, 500, NULL, 1663132545);
INSERT INTO public.hat_defs VALUES (646, 'Turtle Helmet', 'u/awkwardtheturtle is VERY mad at you', 1, 500, NULL, 1663132947);
INSERT INTO public.hat_defs VALUES (648, 'Diamond Helmet', 'So I did some mining off camera...', 1, 500, NULL, 1663133082);
INSERT INTO public.hat_defs VALUES (226, 'Gay Saudi Headpiece', 'Saudis are all homosexuals and they use this to hide the cum in their receding hairlines', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (227, 'Snekshat', 'Snek Shat Hat', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (228, 'Pride Hat I', 'We''re here, we''re queer, get used to it!', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (229, 'Marsey Ears', '@Dramarama''s first hat and it is PERFECT', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (230, 'Halo II', 'Daddy''s lil angel 😈', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (231, 'Egg', 'Uh oh, someone''s got egg on his/her/their/xer/spiderself''s face', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (232, 'Donut', 'You ever try fucking a donut?', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (233, 'Player One', 'Mom says it''s my turn!', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (234, 'Okapi', 'Big throbbing okapi cock 🤤', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (235, 'Emo Hair I', '''''Rawr'''' means ''''I love you'''' in Dinosaur :3', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (236, 'Ram Horns', 'Not quite sure what a ram is tbh but here are its horns. Like is it a boy sheep? A goat? Some animal of its own? Who knows!', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (237, 'Bunny Ears', 'BUNNY!', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (238, 'Pinhead', 'Dirty Dan''s best friend', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (239, 'Mojo Jojo', 'I once knew a Mexican dude named Nick who pronounced Mojo Jojo as mohohoho', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (240, 'Backstabbed', 'I have information that will lead to the arrest of Hillary Rodh-- ack!', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (241, 'The Garry_Chess', 'I AM A DOCTOR I AM IMPORTANT HURRDURR', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (242, 'Aussie Hat', 'Gday, cunt', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (243, 'Night Cap', 'Imagine putting a fucking :marseytom: hat on before bed lmao', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (244, 'Anime I', 'YIKES! CRINGE!', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (245, 'The Brianna Laundrie', 'RIP Brianna and RIP r/FriendsOfBrian', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (246, 'Lains Bear Kigurumi', 'And you don''t seem to understand / A shame, you seemed an honest man', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (248, 'Furfag Pride', 'We`re here, we fuck animals get used to it.', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (249, 'why', 'BOOHOO NIGGA', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (250, 'Grass Toucher', 'Makes you immune to being told to touch grass', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (251, 'Napoleon', 'Liberté, ordre public', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (252, 'Average rDrama Hat Designer', 'USE THE FUCKING TEMPLATE', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (253, 'Phrygian Cap', 'Liberté, égalité, fraternité', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (254, 'Three Lil Marseys', 'It''s three Marseys. They''re little. What more do you want from me here?', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (255, 'KN95 Mask', 'We are all in this together. If you are serious about flattening the curve, you will wear this.', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (256, 'Confusion', '????????????????????????????', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (257, 'Umbreon Ears', 'For legal reasons, we cannot actually call these Umbreon Ears. Please refer to them as something else.', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (260, 'Carphead', 'A legally viable excuse to have Carp on top of you in public', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (261, 'Journoid Scum', 'The wearer of this hat was coming right for you, I saw it. The shooting was purely self-defense.', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (262, 'Delicious Feet', 'feet > bussy', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (344, 'Slava Ukraini', 'Slava Ukraini!', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (345, 'Gigachad Mask', 'Average rDrama user', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (346, 'Pumpkin Remains', 'A gory pumpkin scalp', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (347, 'Peek-A-Boo Marsey', 'AAAAHHH GET IT OFF GET IT OFF GETITOFF AAAAAAHHHHHHH', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (348, 'Hazmat Suit', 'Standard-issue PPE for wading through the cesspit that is rDrama', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (349, 'Cat Ears (wiggly)', 'MEOW MEOW MEOW MEOW MEOW MEOW MEOW', 1, 1000, NULL, NULL);
INSERT INTO public.hat_defs VALUES (350, 'Marionette Strings', 'Dance, puppet, dance', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (351, 'PaRappa Beanie', 'This is technically a furry item fyi', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (353, 'Double Ds (hat)', 'double deez nuts lmao', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (354, 'SNIFFED', 'Extremely uncomfortable for almost everyone involved', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (356, 'Santa Hat I', 'Frozen Frozen Frozen (like ho ho ho get it), merry Fistmas!', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (357, 'Scumbag Steve', '>comes to your gay poz mixer >wears a rubber', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (358, 'Umbrella Hat', 'Covered in dirty yellow and white streaks', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (359, 'Ridin With Biden', 'You ridin''?', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (360, 'NFT', 'Right clicking is STRICTLY prohibited', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (361, 'The Bog', 'Will you take the call?', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (362, 'Googly Eyes', 'My eyes are up here', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (363, 'Kanohi Hau', 'A description was not provided but google says it''s a Bionicle thing. I think those are like Legos. Mysterious Lego mask oooooooh', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (364, 'The Yugi', 'Children''s card game world champ', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (365, 'Maid Cap', 'CLEAN IT UP MAID 🤣 FOR A RESPECTABLE WAGE 🤣🤣🤣', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (366, 'BLACKED', 'You were built for BBC', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (368, 'Wonder Tiara', '(Lynda Carter''s version, of course)', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (369, 'Fisherman Hat', 'The text is completely indecipherable at this scale. I have no idea if that makes it worthless or adds to the joke.', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (370, 'Crosshair', 'You deserve this.', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (371, 'DONT CARE DIDNT ASK YOUR WHITE', 'DONT CARE + DIDNT ASK + YOUR WHITE', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (372, 'Dragonborn', 'Dragon Shout: FEED/AND/SEED', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (373, 'Sun Hat III', 'So many sun hats to choose from, so little sun.', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (374, 'Anglerfish', 'It''s not Snoo''s scalp. Stop asking that.', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (375, 'Nun Headpiece', 'Bandeau and veil, coif not included', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (376, 'Colovian Fur Helm', 'NOT for n''wahs', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (377, 'Booze Cruise', 'Drunk driver rights are human rights', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (378, 'Son of the Mask Mask', 'Don''t ya just LOVE Homoween?', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (379, 'Bananahead', 'This shit is bananas. B-A-N-A-N-A-S', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (626, 'Pedo Sniper', 'Ready, aim...', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (381, 'Panty Raid (pink)', 'Are ya feeling it now Mr. Krabs?', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (382, 'Panty Raid (red)', 'Are ya feeling it now Mr. Krabs?', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (383, 'Panty Raid (white)', 'Are ya feeling it now Mr. Krabs?', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (384, 'Head Crab', 'It''s a crab. For your head.', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (386, 'Curts New Hat', 'Have you *seen* it?', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (387, 'Gray Cowl of Nocturnal', 'Capital!', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (388, 'Tricorne', 'This hat is for TRUE AMERICAN PATRIOTS only', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (404, 'Knight Helmet', 'kNIGht 🤗', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (352, 'John Deere Hat', 'She (male) thinks my tractor''s sexy', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (355, 'Chef Hat', 'Cloudflare just bent the knee and I''m nauseated and don''t feel like writing descriptions for hats sorry', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (392, 'Chris-Chan', 'Hat to the extreme!', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (393, 'Bunny Buttons', 'Byo requested this one but I''m honestly not even sure what it is', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (394, 'ROFLcopter', 'Lollerskates', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (395, 'Whirly Tard Hat (animated)', 'This one spins omg', 1, 1000, NULL, NULL);
INSERT INTO public.hat_defs VALUES (412, 'The Klenny', '🤣👍', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (422, 'Booba', 'O_O', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (409, 'AI Core', 'Thought this said AL Core for a minute like Al gore but no it''s ai like the robot thing and apparently it''s from a vidya so here we go description done 🤌', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (655, 'Thigarette', 'Smokers are jokers', 1, 1000, NULL, 1663160917);
INSERT INTO public.hat_defs VALUES (656, 'Thigarette (BIPOC)', 'Smokers are JOKERS', 1, 1000, NULL, 1663161103);
INSERT INTO public.hat_defs VALUES (654, 'VR', 'Be honest, you bought it for porn', 1, 500, NULL, 1663153216);
INSERT INTO public.hat_defs VALUES (642, 'Spotlight', 'Lights, Camera, Action!', 1, 1000, NULL, 1663122185);
INSERT INTO public.hat_defs VALUES (651, 'Chainmail Helmet', 'Shameless coloniser of (((villagers)))', 1, 500, NULL, 1663133337);
INSERT INTO public.hat_defs VALUES (653, 'Freddy Mask', '[JUMPSCARE]', 1, 500, NULL, 1663133417);
INSERT INTO public.hat_defs VALUES (657, 'Coins', 'The Princess Is In Another Castle', 1, 1000, NULL, 1663200349);
INSERT INTO public.hat_defs VALUES (659, 'Brain Worms', 'This explains a lot.', 1, 500, NULL, 1663229235);
INSERT INTO public.hat_defs VALUES (674, 'Fat Rat Grab', 'He''ll cook you dinner, the useful rodent', 1, 500, NULL, 1663295500);
INSERT INTO public.hat_defs VALUES (665, 'Diddy Kong Hat', '"He''s back again and about time too! And this time he''s in the mood! He can fly real high with his jetpack on! With his pistols out, he''s one tough Kong!"', 1, 500, NULL, 1663279805);
INSERT INTO public.hat_defs VALUES (666, 'Gamer Hat', 'When you want everyone to know your opinions on the female gender', 1, 500, NULL, 1663279854);
INSERT INTO public.hat_defs VALUES (670, 'Miners Helmet', 'Everybody wants to have sex with them', 1, 500, NULL, 1663280073);
INSERT INTO public.hat_defs VALUES (671, 'The Son of Man', 'Hide your face with an apple', 1, 500, NULL, 1663280110);
INSERT INTO public.hat_defs VALUES (396, 'Obey Snapback w Blunt', 'dude weed lmao', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (406, 'Amogus', 'I saw you vent', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (415, 'WANTED', 'Dangerous thought criminal. Wanted DEAD ONLY.', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (421, 'Emperor Hat', 'Made in China', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (424, 'Pearl Clutcher', 'REEEEEEEEEEEEEEEEE', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (667, 'The Orb', 'Ponder into one''s soul', 1, 500, NULL, 1663279906);
INSERT INTO public.hat_defs VALUES (652, 'Leather Helmet', 'Wow, what a n00b', 1, 500, NULL, 1663133381);
INSERT INTO public.hat_defs VALUES (669, 'Backwards cap 2', 'lookin'' cool', 1, 500, NULL, 1663280007);
INSERT INTO public.hat_defs VALUES (663, 'Santa Hat II', '''Tis the season!', 1, 500, NULL, 1663279621);
INSERT INTO public.hat_defs VALUES (672, 'Birthday Hat', 'Ruins every thread on October 1st (ed: what does this mean????)', 1, 500, NULL, 1663280145);
INSERT INTO public.hat_defs VALUES (397, 'Funko Pop', '...and then he turned himself into Funko Pop. Funniest shit I ever saw.', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (398, 'The Catman', 'This counts as a fursuit', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (668, 'Maxwell Hat', 'Scribblethot', 1, 500, NULL, 1663279953);
INSERT INTO public.hat_defs VALUES (400, 'Current Thing (support)', 'Slava Ukraini!', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (401, 'Current Thing (oppose)', 'Denazify Ukraine!', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (402, 'T-34 Tank', 'For denazification purposes', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (403, 'Weatherman', 'Glad I could help', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (405, 'Israeli Friend Pins', 'If any man shall adore the beast and his image, and receive his character in his forehead, or in his hand.', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (407, 'Top Hat (black glitter)', 'Be careful not to rub this against anything', 1, 1000, NULL, NULL);
INSERT INTO public.hat_defs VALUES (410, 'Retro Snapchat Thot', 'Heckin good pupperino', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (411, 'The Goatse', 'Open wide!', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (418, 'Bass Pro', 'Of course I cum fast, I got fish to catch!', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (420, '2070s Hat', 'State-enforced homosexuality. Teaching JavaScript to refugees. The flyest headwear. Bring on the Paradigm Shift.', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (413, 'Retro Brimstone', 'Look man if you''re gonna submit old vidya imagery as hats I need to know what it IS so I can write descriptions', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (423, 'Dramautist Jar Project', 'Wh-what''s going on? Why am I in here?', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (416, 'Monopoly Hat', 'Do not pass Go. Do not collect 200 dramacoin.', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (417, 'Monopoly Thimble', 'Just the right size for your dick huh', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (425, 'Girlboss', '#GASLIGHT #GATEKEEP #GIRLBOSS', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (426, 'Gold Badge', 'You did so well. You deserve yourself.', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (427, 'Silver Badge', 'First loser', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (428, 'Green Badge', 'Winner of the 20XX Farmers Choice Award', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (429, 'Red Badge', 'The red badge of bussy', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (431, 'Blue Badgr', 'I blue myself', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (433, 'R2D2', '[unintelligible whirring and beeping]', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (434, 'Gay Fawkes Mask', 'Buy curtains, Buy a dog. We are legging. Accept us.', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (437, 'Cigar', 'Sometimes s cigar is just a cigar. Not this time, though. This is clearly about craving dick in your mouth.', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (438, 'Conquistador', 'Sorry, but the human sacrifice stops NOW.', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (439, 'Pumpkin', 'Spowoky Owoky Puwumpykin', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (440, 'Jester Hat (Mardi Gras)', 'YOU Tuesday', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (441, 'Jester Hat (red and blue)', 'Jingle jingle', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (442, 'Jester Hat (blue and purple)', 'Hand wash only', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (443, 'The Ricardo Milos', '✨Iconic✨', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (444, 'The Awoo', 'This is (not) Cirno', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (445, 'Krusty Krew', 'KRUSTY KRAB PIZZA. IS THE PIZZA. FOR YOU AND ME.', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (446, 'Sutton Woo Helmet', 'What a neat helmet. Why would someone leave it lying on the ground?', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (447, 'Cosmonaut Helmet', 'Yuri Gagarsey, hero of the Soviet Union!', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (448, 'The Pizzashill', 'WORDS WORDS WORDS WORDS WORDS WORDS WORDS WORDS WORDS WORDS WORDS WORDS WORDS', 1, 1000, NULL, NULL);
INSERT INTO public.hat_defs VALUES (449, 'Handmaids Bonnet', 'Wear this to protest the ban on infanticide', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (451, 'Influencer', 'Sweet, faceless validation', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (453, 'Top Hat (fancy)', 'Shallow and pedantic, if you ask me. It insists upon itself', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (454, 'Jaguar Warrior', 'The human sacrifices will continue until morale improves', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (455, 'Marsey Brainhat', 'Just two brainlets, hanging out', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (456, 'Black Crown', 'Black crowns matter', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (458, 'Mario Raccoon', 'BING BING RACCOON', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (459, 'Eggscellent Hat', '🥚 lmao', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (367, 'Burning Flames Team Captain', 'Yeah I''m hot shit, could you tell?', 1, 1000, NULL, NULL);
INSERT INTO public.hat_defs VALUES (460, 'Edelgard Hair', 'Please report anyone with this hat to @carpathianflorist for weeb eradication', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (380, 'Witch (Wizard) Hat', 'STOP ASKING WHY I DON''T USE MAGIC TO CHANGE MY GENDER', 1, 1000, NULL, NULL);
INSERT INTO public.hat_defs VALUES (385, 'Magician Hat', 'It''s not just animated so we can charge more for it. Really!', 1, 1000, NULL, NULL);
INSERT INTO public.hat_defs VALUES (389, 'BIG MAD', 'Positively seething', 1, 1000, NULL, NULL);
INSERT INTO public.hat_defs VALUES (390, 'Nervous Sweating', 'oshit >mfw', 1, 1000, NULL, NULL);
INSERT INTO public.hat_defs VALUES (391, 'Sparkles', '✨✨✨✨✨✨✨✨', 1, 1000, NULL, NULL);
INSERT INTO public.hat_defs VALUES (461, 'Gothic Lolita', 'Dark and brooding. Not very brooding, actually. But dark.', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (462, 'Rasta Hat', 'Jah bless', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (463, 'Sheep Horns', 'For the horniest of sheep', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (464, 'Luffy Hat', 'Stretchy pirate weebshit guy', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (465, 'Thin Film Interference Hat', 'Like that movie with the time machine car', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (466, 'BANNED stamp', 'One time at banned stamp I', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (467, 'Minecraft', 'It is impossible to fedpost with this hat on', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (468, 'Brimless Yankee', 'The finest team of juicers money can buy', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (469, 'The Kiwi', 'Wearing this constitutes a hate crime in most developed countries', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (470, 'The Mathematician', 'Special delivery from Mr. Kac- Mr. Kaz- Mr. Kazimspy', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (471, 'Frog Hat', 'It has a cute frog on it', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (472, 'Moriya Frog Hat', 'Big googly eye froge hat', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (473, 'Warning Tape', 'This user is a walking red flag', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (474, 'The Merchant', 'What did he mean by this? 🤔', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (475, 'Stickbug', 'Lookit this lil fella go', 1, 1000, NULL, NULL);
INSERT INTO public.hat_defs VALUES (476, 'Cos Bucket Hat', 'Bitch ima cow', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (477, 'Strawberry Hat', '🍓🍓🍓', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (478, 'Froge Beret', 'On Wednesdays we wear frogs', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (480, 'Knitted Hat (blue)', 'Plush. Warm. Ugly. But enough about your mom.', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (481, 'Ladies Ornate Hat (black)', 'Elegant!', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (482, 'Cowgirl (male)', 'Rootin tootin foid-shootin', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (483, 'Naughty Newsboy', 'Missing. Last seen at ground zero of your local monkeypox outbreak. If found, do NOT touch.', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (485, 'This Is Fine', 'Situation normal.', 1, 1000, NULL, NULL);
INSERT INTO public.hat_defs VALUES (486, 'Emo Hair II', 'SO CUT MY WRISTS AND BLACK MY EYES', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (487, 'Emo Hair III', 'I write sins not tragedies', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (488, 'Emo Hair IV', 'I''m not okay (I promise)', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (489, 'Emo Hair V', 'Thnks fr th Mmrs', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (490, 'Emo Hair VI', 'Cute Without The ''E''', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (491, 'Top Hat (frost)', 'Cool-colored top hat for cool tops only', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (492, 'Top Hat (frilly Victorian)', 'Victorian fashion was HIDEOUS but contemporary spins on it are just lovely', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (493, 'Brown Herringbone Flat Cap', 'TWEED AND SNEED', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (494, 'Skull Boingy Head Things', 'boing 💀 boing 💀 boing 💀', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (495, 'Alligator-Textured Gold Blingy Hat', 'Looks like shit but probably feels real nice', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (496, 'Flower Hat (hot pink)', 'A cute flower hat', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (497, 'Stinky', 'UH OH! STINKY!', 1, 1000, NULL, NULL);
INSERT INTO public.hat_defs VALUES (498, 'Mario Hat (BIPOC)', 'Who could have dropped this?', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (499, 'Fart Slave Gear', '12 years a fart slave', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (500, 'Little African Hat', 'Promise not to wear it', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (502, 'Booze Cruisin', 'DRUNK DRIVER RIGHTS ARE TRANS RIGHTS', 1, 1000, NULL, NULL);
INSERT INTO public.hat_defs VALUES (503, 'The Antichrist', 'Weak to Tesla coils', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (505, 'ADIDAS Cap', 'Sacred cultural headpiece for the highest caste of gopnik', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (506, 'The Tim Buckley', 'Is this loss?', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (507, 'Gat', 'The ultimate in neo-BTSstanwear', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (511, 'Sam Fisher', 'Four-eyed freak vidya edition', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (512, 'The Buckethead', 'Exactly what it says on the tin', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (513, 'The Sherlock', 'Elemarsey, my dear Watson', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (514, 'Glowing', 'Hit me with your car', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (515, 'Cringe Archivist', '*SNAP* Yep, this one for sure', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (516, 'Madoka', 'Pink-haired retard', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (517, 'Homura', 'Why does the jap have blue eyes', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (519, 'Sakaya', 'omg stop making me look up chinese cartoon characters', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (520, 'Mami', 'Titty ass bitch', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (521, 'VDV Beret', 'something something something Russia', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (522, 'Dr Livesey', 'Dr Soon-To-Be-Dead', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (528, 'Flower Clip', 'A cute flower clip', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (530, 'RENT FREE', 'idek anymore carp whatever you want is fine', 1, 1000, NULL, NULL);
INSERT INTO public.hat_defs VALUES (508, 'Meowth', 'That''s right!', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (509, 'Niconico', 'I can''t think of a description, but I''m proud of it', 1, 1000, NULL, NULL);
INSERT INTO public.hat_defs VALUES (510, 'Sneed (Chuck)', 'Subsequently Sneed''s', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (518, 'Kyoko', 'This is seriously her name? Kyoto with a k instead? Hi I''m Philadelkia, son of Dedroit, son of Kansas Citie <_>', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (524, 'Smurf Hat (papa)', 'You think you''re better than all the other smurves', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (529, 'Conehead', 'How do you describe a cone? It''s a cone. It goes on your head.', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (523, 'Smurf Hat', 'La la, la la la la', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (525, 'Please Be Autistic I Am Yes', 'Please Be Autistic I Am Yes', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (526, 'No-No Finger', 'Oh no you di-int', 1, 1000, NULL, NULL);
INSERT INTO public.hat_defs VALUES (527, 'Cat Ears (wig)', '~~nya ^-^', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (430, 'Purple Badge', 'Orange ya glad ya didn''t get an orange badge?', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (432, 'Orange Badge', 'You''ve betrayed the purple badge.', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (435, 'Witch III', 'Submitter called it cursed. He didn''t explain how. It''s cursed I guess? Spoooooooky.', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (436, 'robocop', 'You''ll never fuck my ass, Batman', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (450, 'Bluecheck', 'Can''t get verified? Do it yourself!', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (452, 'The MF Doom', 'Everyone''s favorite cosplay rapper', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (457, 'Thug Life Beanie', 'The whitest beanie you''ll ever see', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (479, 'Pizza Hut', 'For when ‘good enough'' is enough', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (484, 'Slav-sya', 'Enough about human rights, let''s talk about human wrongs', 1, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (501, 'Dancing Marsey', 'Omg she''s so happy lookit her GO', 1, 1000, NULL, NULL);
INSERT INTO public.hat_defs VALUES (504, 'Iron Crown of Lombardy', 'This isn''t Crusader Kings, stop it', 1, 500, NULL, NULL);


--
-- Name: hat_defs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.hat_defs_id_seq', 689, true);


--
-- PostgreSQL database dump complete
--

--
-- PostgreSQL database dump
--

-- Dumped from database version 14.4
-- Dumped by pg_dump version 14.5 (Ubuntu 14.5-1.pgdg20.04+1)

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
-- Data for Name: marseys; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.marseys VALUES ('marseydeadinside3', 0, 'depressed suicidal doomer tired despair wrinkled wrinkles', 2, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyappicon', 0, 'iphone ios android application googleplay samsung', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyastronaut2', 0, 'cosmonaut spacesuit helmet', 2, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseypastor', 1, 'christian baptist southern church black papist mrpenny preacher priest', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyliathomas', 1, 'tranny transgender athlete lia thomas athletics woman valid lgbt swimmer aquamaam aqua maam', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseybiden', 1, 'ddd dementia daddy president sleepy joe', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyburnedman', 0, 'joshua graham fallout vegas mormon caesar', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysaint2', 0, 'angelic halo holy animated wings happy', 1, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycowboy', 1, 'western pardner reaction hat tootin yeehaw rootin', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyfediverse', 0, 'federation autism freespeech poast', 5, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseykiwimom', 1, 'kf farms newzealand new zealand dramarama birds babies chicks single mother brood flock', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseynukegoggles', 0, 'nuclear atomic bomb mushroom cloud', 4, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysoyseethe', 0, 'soyjack soyjak reddit angry yelling wojak', 6, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseytransflag', 1, 'trans flag then consumeproduct', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marsey3d', 0, 'poly 3d print alive spin animated', 1, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycapysuezcanal', 0, 'capy suez canal egypt ship blockage sexy', 4, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseypizzaslice', 0, 'pizza shill longpost yum chef cook italian cheese pepperoni', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyhomochingchong', 0, 'asian chinese jap gook chink rice gay strawhat  glasses squint rainbow tiedie tyedye tyedie tiedye', 1, NULL, 1663248780);
INSERT INTO public.marseys VALUES ('marseyfugg2', 0, 'spurdo sparde', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyeskimo', 0, 'inuit native arctic fishing dog helpful ice freeze winter cold', 1, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyoppenheimer', 0, 'scientist nuke bomb ww2 atomic nuclear mushroom cloud', 2, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyeva', 1, 'anime weeb neon robot mech japan', 0, 0, 1663376836);
INSERT INTO public.marseys VALUES ('marseyvampirebite', 1, 'cope seethe mask house', 0, 0, 1663376896);
INSERT INTO public.marseys VALUES ('marseylaughwith', 0, 'cry tears lol lmao haha laughing', 5, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyshock', 0, 'shock fear afraid terror scared horrified', 3, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyredflag', 0, 'warning red flag alert scum problematic', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseytrad2', 0, 'wojak tradwife soyjak 4chan meme foid', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseytemplate', 0, 'template blank faceless eyeless mouthless head empty faceless', 6, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyliberty2', 0, 'usa burger america statue lady republican democrat biden trump rightoid leftoid', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseythegrey', 1, 'lord of the rings magic gandalf lotr mage wizard warlock', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyspecial', 1, 'retard reaction slow special needs sped', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseytransrentfree', 0, 'transgender lgbt rent free wojak chud', 2, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyappleseed', 0, 'american usa johnny history folk fruit food pot pan helmet legend', 2, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseytypinglaugh', 0, 'computer keyboard lol bongo animated', 3, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseytime', 1, '10pm tock tick clock animated', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyjacksparrow', 0, 'johnny depp amber heard abuse violence punch beat feminist Jack sparrow', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseydarkmarsey2', 0, 'lasereyes redglow scary chudrama', 1, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseylaughpoundfist', 1, 'cry tears lmao lol kek bully laughing funny mocking animated', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseytyping', 0, 'computer keyboard bongo animated', 1, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyterfdomesticabuse', 1, 'terf domestic abuse violence feminism feminist lesbian ovarit radical', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyhawaii', 0, 'boomer margarita drink chill relaxed', 5, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyturnedon', 0, 'aroused arousal amorous horny', 2, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyusa', 1, 'burger patriot america freedom liberty justice love independence freedom guns trump biden state flag', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseybongcop', 0, 'police english british london copper bobby bongistan britain england police', 1, NULL, 1663284064);
INSERT INTO public.marseys VALUES ('marseysoren', 1, 'sleeping alt right altright racist nazi chud', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyveryworried', 0, 'worry anxiety fear animated scared sweat yikes', 4, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseymegalodon', 0, 'shark carpathianflorist jaws attack eating killing', 2, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyswastika', 1, 'nazi chud germany swasi swazi windmill of peace hitler racist racism antisemitic antisemitism third reich jewish jews', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycruisemissile', 0, 'war explosion bomb weapon military rocket enemy destroy kill nuke launch', 1, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseywhiteflag', 0, 'surrender battle french', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyreluctant', 0, 'stare doubt skeptical wary cautious uncertain uhh umm', 1, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseytabletired2', 0, 'beer tiresome depressed sad alcoholic alcoholism despair', 2, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyfedposthmmm', 0, 'glowie american dad stan meter fbi', 3, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyschizotwitch', 1, 'twitching eyelid crazy nuts psycho insane traumatized animated', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyhillary', 1, 'president her turn hilary killary hilldawg clinton', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysnowglobe', 1, 'christmas tree small miniature', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyflakes', 0, 'parsley seasoning salt pepper spice food seasoning', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyarthoe2', 0, 'woman foid scene emo bitch slut whore thot', 0, NULL, 1663354428);
INSERT INTO public.marseys VALUES ('marseysperm', 0, 'cum swim vasectomy jizz semen spunk penis sex pregnant coom animated', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseypridepearlclutch', 0, 'lesbian gay bisexual homo lgb rainbow cry bigot tears', 5, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyedelgard2', 0, 'princess fireemblem nintendo anime weeb videogame', 0, NULL, 1663283895);
INSERT INTO public.marseys VALUES ('marseygrin', 0, 'seethe pain rage beard angry', 1, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseylicking', 0, 'spongebob tongue taste', 0, NULL, 1663284181);
INSERT INTO public.marseys VALUES ('marseyclintongarrison', 0, 'hillary brap democrat ben comic', 0, NULL, 1663284618);
INSERT INTO public.marseys VALUES ('marseyloss', 0, 'isthis meme comic webcomic hospital ethan tim buckley', 0, NULL, 1663284338);
INSERT INTO public.marseys VALUES ('marseyscratch', 1, 'loweffort doodle code coding programming', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseylain', 0, 'bear onesie pajamas fursuit furry', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseybestfriends', 0, 'snoo reddit alien slice kill kys stab blood wpd', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyearrape', 0, 'breakcore goreshit headphones noisecore', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyjoy', 0, 'smile excited smug', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseychonkerbutch', 0, 'fat obese brap bitch dyke dangerhair lesbian', 3, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseybackingintobush', 0, 'Homer Simpsons scared away animated hedge bush', 1, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseydunce', 1, 'stupid moron imbecile dolt dunce retard dumb cap hat sped', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyhugretard', 0, 'love idiot drool embrace', 4, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysmug2', 1, 'snicker scoff mock reaction guffaw ridicule judgment', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyunabomber2', 1, 'gift christmas industrial society delivery mail kaczynski uncle ted package', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyrulebritannia', 0, 'britain british bongistan chips london england lasereyes', 0, NULL, 1663211275);
INSERT INTO public.marseys VALUES ('marseygun', 0, 'handgun shoot bang kill threaten pistol', 1, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseytroll', 4, 'dio diogenesjr diogenesjunior trollface reaction', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseywhirlyhat', 1, 'idiot retard hat dumb sped slow stupid special kid', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseydrunk2', 1, 'drinking shitfaced alcoholic liquor happy beer dizzy', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycleonpeterson2', 0, 'monster devil demon evil scary horror', 1, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyfedpostglow', 1, 'cia longpost long fed fedpost read notes animated glowie glow', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseywtf2', 1, 'shocked reaction wth disturbing disturbed what the fuck', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyshutitdown', 1, 'cop glownigger fed glowie agent federal mossad israel idf the goyim know kikes radio walkie talkie', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyvargfinnselfdefense', 1, 'bardfinn steve akens aikens penny verity oaken tranny train troon transgender transvestite black metal trve kvlt euronymous varg vikernes mayhem burzum child abuse kid beating stabbing bloody', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseybardfinn3', 0, 'bardfinn ahs powermod tranny trannies wifebeater abuser steve', 9, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseydance', 0, 'excited stomp jump feet step run animated', 9, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyhatiun', 0, 'mad fury furious pissed hatred rage angry maddened infuriated hateful hatefuel', 2, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyfemboy', 1, 'discord trans femboy tomgirl groomer groomed gay faggot homosexual queer poof fairy', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyfuckyou', 1, 'middlefinger middle finger flipping off fuck you nigga', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseygambling', 1, 'depressed casino slots blackjack las vegas depressed suicidial degenerate smoking losing cards hotep', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyschizo', 1, 'harm burns selfharm self harm cigarette burning mermaids reaction artist self', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseydarkpizzashill', 0, 'chud rightoid leftoid debate owned lasereyes footlocker', 2, NULL, 1663210672);
INSERT INTO public.marseys VALUES ('marseycrusade', 0, 'pope papal papist catholic lasereyes christian cross constantinople istanbul war crusader', 1, NULL, 1663212295);
INSERT INTO public.marseys VALUES ('marseysalvindicated', 0, 'shark 2weeks twoweeks gonowhere wentsomewhere', 2, NULL, 1663210995);
INSERT INTO public.marseys VALUES ('marseysaint', 1, 'wings angel blessed halo animated', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyarthoe3', 0, 'woman foid scene emo bitch slut whore thot', 0, NULL, 1663354464);
INSERT INTO public.marseys VALUES ('marseylaughbothsides', 0, 'wingcuck radical centrist centrism animated horseshoe', 7, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyicecreamcone', 0, 'sweet dessert dairy', 0, NULL, 1663284406);
INSERT INTO public.marseys VALUES ('marseysignaling', 0, 'railway light semaphore troomer tranny transgender train troid transsexual animated', 2, NULL, 1663238068);
INSERT INTO public.marseys VALUES ('marseyarthoe8', 0, 'egirl woman foid scene emo bitch slut whore thot discord', 0, NULL, 1663354707);
INSERT INTO public.marseys VALUES ('marseycrusader2', 0, 'crusading catholic christian pope knight templar warrior soldier sword shield lasereyes istanbul constantinople', 1, NULL, 1663212423);
INSERT INTO public.marseys VALUES ('marseysnappyautism', 1, 'snapshillbot hat neurodivergent robot autistic marppy', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyagree', 1, 'concur nodding nod reaction affirmative yes yeah uh huh animated judgment', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysal2', 1, 'shark 2 weeks two weeks go nowhere going nowhere watch go nowhere', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseypepsi', 1, 'cola coke soda soft drink pop red white blue usa america', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysoldierchina', 1, 'army war gun rifle asia chinese chink gook', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyshortbus', 0, 'bussy animated mrpenny carpathianflorist schizocel retard special short schoolbus classroom teacher wheels window rosa parks mlk', 1, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseylgbtflag', 0, 'pride gay queer', 6, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseymononoke', 0, 'anime japanese miyazaki ghibli asian cartoon princess character fictionnal ashitaka san wild wolf nature', 2, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyredflag2', 0, 'refuse reject warning animated', 2, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyklennywinner', 0, 'medal award dog klenvastergan corgi', 1, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseypass2', 0, 'pass froyo frozenchosen woman foid transgender', 2, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyrabbit', 0, 'bunny', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyprostateexam', 0, 'gloves doctor proctologist proctology anal cavity search rectum', 1, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyascii', 1, 'blurry', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseynerd2', 0, 'geek glasses dork loser pimples zits', 2, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyautumn', 0, 'fall season leaf leaves pumpkin spice latte wind scarf animated', 0, NULL, 1663109340);
INSERT INTO public.marseys VALUES ('marseyfreud', 0, 'oedipus incest psychoanalysis psychologist shrink psychiatrist', 3, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseymemeball', 0, 'picardia strawman polcomp political', 1, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyropewithchingchong', 0, 'suicide chink chinese asian die kys together strawhat slit zip gook nip buckteeth', 5, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyfacepalm', 1, 'reaction omfg judgment', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseykkkevil', 0, 'kukluxklan racism racist lasereyes evil', 0, NULL, 1663211985);
INSERT INTO public.marseys VALUES ('marseygundam', 0, 'mecha robot helmet mask anime', 1, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseypusheen', 0, 'grey gray', 2, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycoomer2', 1, 'gooning masturbation fapping cumming gooner nofap', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyblob', 0, 'smile owo uwu squish slime', 5, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycarpbuff', 0, 'muscles tough strong carpathianflorist admin mod jannie', 3, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseymissing2', 1, 'missing notexture source image not found broken', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycarpina', 0, 'carpathianflorist drag transgender admin jannie', 2, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseypaperbag', 0, 'ugly ashamed bagged butterface', 2, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyselfflagellation', 0, 'whip white guilt hate sin mayo liberal catholic', 3, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyarthoe', 0, 'scene slut foid whore emo scene bpd bangs dangerhair girl woman', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseykingretard', 0, 'drool dumb idiot crown moron', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycarpflorist', 0, 'jannie admin fish flowers floral carpathianflorist crown', 1, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseydeadinside2', 0, 'depressed suicidal doomer despair', 4, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseylenny', 0, 'innuendo dirty sex horny emoticon perverted', 2, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyokapi', 0, 'okapi furry deer', 3, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseymobster2', 0, 'bat gangster mafia kneecapper', 1, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycarpprotest', 0, 'sign fish mad carpathianflorist sign admin jannie', 3, NULL, 1663163535);
INSERT INTO public.marseys VALUES ('marseygirl', 0, 'dress toddler tween sister horror shining', 1, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseychocolatemilk', 0, 'choccy offer givemilk drink', 1, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyworldcup', 0, 'world cup soccer football winner sports champion', 0, NULL, 1663033833);
INSERT INTO public.marseys VALUES ('marseyanorexia', 0, 'starvation proana old wrinkled bulimia bulimia edtwt', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyexcitedexosuit', 0, 'happy smiling mecha rickandmorty robot', 0, NULL, 1663011866);
INSERT INTO public.marseys VALUES ('marseysatisfied', 0, 'satisfying happy smile delightful grateful glad wholesome', 1, NULL, 1662997904);
INSERT INTO public.marseys VALUES ('marseyletsfuckinggo', 0, 'lfg tennis ball screaming ready', 5, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyamber', 0, 'dalle2 generated', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycoffeemug', 0, 'teacup happy cozy', 1, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyssflag', 0, 'superstraight cishetero straggot pride', 2, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyfedora', 0, 'suit 1920 mobster mafia detective mob', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseywait', 1, 'time watch wait waiting bored', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseytampon', 0, 'period menstrual menses menstruation bloody', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysmugautist', 0, 'autism retard brainlet drool hat', 4, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyinnocent', 0, 'innocent naive angelic dumb halo', 1, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyduck3', 0, 'duck bird quack beak', 4, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseybeaver', 0, 'canada canuck canadian', 2, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseybowl', 1, 'marijuana weed dude weed lmao ganja drugs reaction pot pipe', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyarthoe4', 0, 'woman foid scene emo bitch slut whore thot', 0, NULL, 1663354488);
INSERT INTO public.marseys VALUES ('marseyoutline', 0, 'blank empty void', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseywatchingtv', 0, 'familyguy peter griffin television couch', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyaceofspades', 0, 'asexual volcel cards', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseybeanbigmad', 0, 'animated angry pissed flashing seizure seethe seething', 1, NULL, 1663099782);
INSERT INTO public.marseys VALUES ('marseybikecuck', 0, 'owlturd bicycle cuckold webcomic happiness', 2, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseytabletired', 0, 'tiresome depressed sad desk', 4, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyzaku', 0, 'gundam mecha robot helmet mask', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseydemonicgrin', 0, 'evil wicked horror teeth', 2, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycornlove', 0, 'farmer iowa hawkeye maize', 7, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyropewithme', 0, 'suicide kys kms suicidal hanging noose', 2, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseybudddwyer', 0, 'suicide gunshot reporter journalist', 2, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseydiversity', 1, 'greatest strength meta carp aevann platy zombiewolf zombie wolf', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseypuppy', 0, 'dog dalle2 puppy', 1, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseynapoleon2', 0, 'french france horse', 1, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyfursuit', 0, 'furry furcon degenerate cosplay fursona costume mascot', 1, NULL, 1662996039);
INSERT INTO public.marseys VALUES ('marseyedelgard', 0, 'fireemblem anime weeb fantasy nintendo princess', 1, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseydarkxd', 0, 'laugh ragecomics lmao despair shadow', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyshy2', 0, 'uwu weeb blush flushed finger owo', 7, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysatisfiedmarcus', 0, 'black bipoc satisfying happy smile delightful grateful glad wholesome', 1, NULL, 1662998420);
INSERT INTO public.marseys VALUES ('marseylgbtflag2', 0, 'pride gay inclusive queer ukraine bipoc', 5, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseytrumpgarrison', 0, 'cum maga capitol ben comic republican', 0, NULL, 1663284695);
INSERT INTO public.marseys VALUES ('marseychadyes', 0, 'based gigachad', 3, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyfine', 1, 'is fine meme thisisfine burning fire', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseykeffalsdance', 1, 'onesie pajamas animated fursuit hood wiggler', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseylickinglips', 0, 'yummy tasty delicious', 7, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseygangster', 0, 'pimp hustling mafia money gangsta', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyeyelidpulling', 0, 'frustrated scary horror', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycosmopolitan', 0, 'bourgeoisie wealthy affluent tophat cultured capitalist elite monocle', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseydarkcomrade', 0, 'communist commie pinko lasereyes russian kgb hat soviet ussr tankie', 2, NULL, 1663254781);
INSERT INTO public.marseys VALUES ('marseycow', 1, 'cow fursona skin animal costume furry heifer fursuit', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseybeanpleased', 0, 'bean satisfied cheerful upbeat', 1, NULL, 1663124719);
INSERT INTO public.marseys VALUES ('marseybeanimp', 0, 'bean demon devil devious mischevious playful teasing', 1, NULL, 1663124439);
INSERT INTO public.marseys VALUES ('marseyletsfuckinggo2', 0, 'hyped screaming shouting yelling', 2, NULL, 1663161484);
INSERT INTO public.marseys VALUES ('marseybrainletclapping', 0, 'idiot dumb stupid applause cheering moron animated retard', 4, NULL, 1663095832);
INSERT INTO public.marseys VALUES ('marseytwerking', 1, 'tailspin animated butt backside dancing spin booty ass dance', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseywoodchipper2', 1, 'libertarian pedo woodchipper animated kill map', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyxd', 1, 'lmao reaction rofl haha lol laughing', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseybetauprising', 0, 'blackops2cel blops2cel incel volcel lasereyes dark involuntary celibate saint', 1, NULL, 1663213986);
INSERT INTO public.marseys VALUES ('marseyangel3', 0, 'halo happy innocent', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyabandoned', 1, 'box container rejected dirty cardboard homeless', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseybardfinn', 1, 'domestic violence bardfinn foid beating punching battering battered bandage hurt pain woman female steve akins penny verity oaken tranny transgender transsexual', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyraiden', 0, 'mgs vidya', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyratso', 0, 'furry nsfw porn', 0, NULL, 1663119130);
INSERT INTO public.marseys VALUES ('marseybruh2', 0, 'bruh disbelief doubt bro seriously smdh', 4, NULL, 1663148476);
INSERT INTO public.marseys VALUES ('marseybeanwink', 0, 'bean joking flirtacious suggestive ironic', 1, NULL, 1663124851);
INSERT INTO public.marseys VALUES ('marseyboomercartoon', 0, 'grandpa joke comic', 0, NULL, 1663161684);
INSERT INTO public.marseys VALUES ('marseybeanpizzashill', 0, 'bean chud agendaposter physiognomy footlocker pojom', 0, NULL, 1663123650);
INSERT INTO public.marseys VALUES ('marseycornholio', 0, 'beavis butthead cornholio metallica marsey mtv', 2, NULL, 1663135986);
INSERT INTO public.marseys VALUES ('marseybeanmonocle', 0, 'bean posh wise snobbish bourgeois aristocrat victorian', 1, NULL, 1663124531);
INSERT INTO public.marseys VALUES ('marseybeanflushed', 0, 'bean blush embarrassed flattered surprised infatuated senpai umm', 1, NULL, 1663124099);
INSERT INTO public.marseys VALUES ('marseycapitalistmanlet', 1, 'money top hat rich landlord cigar llm tophat', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseytransattentionseeker', 1, 'needy enby nonbinary notice mtf ftm train attn', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyfursona2', 0, 'furry fursona cat devil', 1, NULL, 1663119051);
INSERT INTO public.marseys VALUES ('marseycarpfisherman', 0, 'admin janny bait caught mod sardine srdine carpathianflorist jannie', 1, NULL, 1663283814);
INSERT INTO public.marseys VALUES ('marseyautumn2', 0, 'fall season leaf leaves pumpkin spice latte wind scarf', 1, NULL, 1663109364);
INSERT INTO public.marseys VALUES ('marseychtorrr2', 0, 'reddit admin chonker fat', 1, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyliberty', 0, 'usa burger america statue lady republican democrat biden trump rightoid leftoid', 2, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseydarkcarp', 0, 'lasereyes carpathianflorist fish admin jannie mod banned yalled', 2, NULL, 1663211530);
INSERT INTO public.marseys VALUES ('marseybeanannoyed', 0, 'bean expressionless frustrated', 1, NULL, 1663123946);
INSERT INTO public.marseys VALUES ('marseyexciteddance', 0, 'happy dance excited spin tippytap', 0, NULL, 1663143559);
INSERT INTO public.marseys VALUES ('marseybeanadorable', 0, 'bean uwu innocent', 0, NULL, 1663123845);
INSERT INTO public.marseys VALUES ('marseygardener', 0, 'gardening watering', 2, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseybeandizzy', 0, 'bean spiral hypnosis disoriented stunned shocked', 0, NULL, 1663123997);
INSERT INTO public.marseys VALUES ('marseybeanpensive', 0, 'bean remorseful downtrodden introspective unfortunate', 0, NULL, 1663124612);
INSERT INTO public.marseys VALUES ('marseybeanpleading', 0, 'bean begging please bashful adoration', 0, NULL, 1663124679);
INSERT INTO public.marseys VALUES ('marseyfoidretard', 0, 'woman blonde stupid dumb idiot froyo frozenchosen', 2, NULL, 1663161600);
INSERT INTO public.marseys VALUES ('marseybeanrelieved', 0, 'bean calm pleasant content peaceful pleased', 0, NULL, 1663124757);
INSERT INTO public.marseys VALUES ('marseybeantonguepoke', 0, 'bean playful silly jesting kidding', 0, NULL, 1663124794);
INSERT INTO public.marseys VALUES ('marseybedsick', 1, 'illness plague fever pillow', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseylgbtflag3', 0, 'pride gay rainbow queer', 3, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyarthoe5', 0, 'woman foid scene emo bitch slut whore thot', 0, NULL, 1663354512);
INSERT INTO public.marseys VALUES ('marseychingchongsupremacy', 0, 'ccp china chinese ricefarmer hat glasses buckteeth bucktooth azn asian jinping xinping han masterrace communist communism maoist zedong', 1, NULL, 1663298980);
INSERT INTO public.marseys VALUES ('marseyira', 1, 'car bomb irish ireland', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseywizard', 1, 'wizard magic pepe apu', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseymoplicker', 0, 'janny moderator admin', 4, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycapyheart', 1, 'capybara rodent aevann happy cute love', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseymormon', 0, 'backpack tie jesus god christian missionary', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseybeanangryfbi', 0, 'federal agent glowie glownigger lawenforcement leo terrorist terrorism', 0, NULL, 1663099467);
INSERT INTO public.marseys VALUES ('marseyarthoe6', 0, 'woman foid scene emo bitch slut whore thot', 0, NULL, 1663354548);
INSERT INTO public.marseys VALUES ('marseycumjar2', 1, 'semen jizz sperm spunk bukkake', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseychemist2', 1, 'chemistry science chemical cope', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyangryexosuit', 0, 'mecha rickandmorty robot', 0, NULL, 1663011836);
INSERT INTO public.marseys VALUES ('marseywut2', 1, 'weird reaction raised eyebrow disturbing disturbed wtf judgment', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyarthoe7', 0, 'woman foid scene emo bitch slut whore thot', 0, NULL, 1663354565);
INSERT INTO public.marseys VALUES ('marseyceiling', 1, 'spy masturbate watching peeping', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyimam', 0, 'muslim islam saudi ghutra keffiyah kufiya emiratis arab', 4, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyfellowpedo', 1, 'libertarian glowie fbi', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycrystalmaiden', 1, 'gamer video game gaymer', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyniqabpearlclutch', 0, 'bombasticpussy sjw snowflake burka burqa', 0, NULL, 1663350191);
INSERT INTO public.marseys VALUES ('marseylongpost', 1, 'tldr reaction wall of text wordswordswords animated words', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycool2', 1, 'cigarette hip shades sunglasses jacket smoking smoke', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyatfagent', 1, 'feds atf agent glowies usa america waco swat m16 firearm rifle cops police', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyairquotes', 1, 'reaction patronizing animated uh huh', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseydog', 1, 'puppy doggo fursona skin animal costume dog furry fursuit', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyskinnedwalk', 1, 'watchpeopledie zllctnxaspywgb3 animated skinned walking trotting skeleton bones organs', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycrusader', 1, 'knight deusvult templar crusades catholic', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycarpnoticeme', 1, 'carpathianflorist fish attn attention whore', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseywall', 1, 'foid female birthing person woman girl 30 fds femcel single mom single mother itsover old gross yuck nasty gussy', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyspirit', 1, 'ghost halloween holiday', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysaluteussr', 1, 'salute o7 flag soviet union russia kgb communist commie marxist marxism tankie stalin lenin animated patriotic', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyahs', 1, 'bardfinn dubteedub againsthatesubreddits redditor groomer pedophile libertarian chomo antifa animated', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseykween', 1, 'hoop earring fds black shaniqua', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysaluteisrael', 1, 'jewish yiddish hebrew kike sheeny mossad star of david flag patriotic animated', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseymicrobus', 1, 'vw van bussy', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseybang', 1, 'head wall bang schizo psycho selfharm deranged gif animated', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyidio3', 1, 'idio3 russia belarus communist commie flask drink computer online monitor display keyboard idio', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseytrumpgrill', 1, 'centrist donald ddr drumpf centrism bbq barbeque barbecue ketchup', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyolantern', 1, 'halloween scary pumpking', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyjamesholmes', 1, 'killer shooter shooting crazy schizo batman capeshit ginger', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseybongosrdine', 1, 'bongo drums music meme jam srdine', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyslime', 1, 'animated happy blob vidya video game maple story maplestory bouncing bounce monster jump', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycyanide', 1, 'kys kill yourself kms kill myself poison pill death die depressed suicidal suicide animated', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('joanmarsey', 1, 'joan gay clown gacy wayne', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseydisconcerting', 1, 'creepy smile uneasy rapey', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseygasp', 1, 'wow woah what how why whoa reaction appalled', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseytf2scout', 1, 'tf2 scout boston zoomer valve vidya game baseball mercenary', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycarpsnipe', 1, 'shooter shooting gun sniper rifle scope crosshairs carpathianflorist kill murder bullet crosshair ajab', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseykitti', 0, 'watchpeopledie horror grim evil scary surreal tattoos wicked demonic', 6, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseybaited', 1, 'laser pointer trolled gullible reaction animated', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyironmaiden', 1, 'death blood torture chika anime weeb weeaboo spikes murder crush animated', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyvatnik', 1, 'russian alcoholic alcoholism', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyduck', 1, 'bird beak', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysoonretarded', 1, 'weeks 2weeks sal antisal soon retarded naive', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyfingerwords', 1, 'cute long tldr didnt read', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyobamacope', 1, 'barack pointing laughing poster', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyphonecall', 1, 'pepe apu peepo phone call cellphone', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyreactor', 1, 'nuclear power reactor energy generation radioactive chernobyl', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyhillarybackstab', 1, 'clinton hilary arkanicide knife stabbing kill murder seth rich death', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marsoy2', 1, 'soy wojak soyjak soyjack nerd numale redditor', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycapyblowkiss', 1, 'capybara rodent aevann happy cute love', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyminipixel', 1, 'miniature small smol place 8bit mouse', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseymfdoom', 1, 'rapper hip hop hiphop rnb supervillain helmet mask', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyfocault', 1, 'philosophy history', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyazov2', 1, 'ukraine ukrainian nazi chud black sun schwarzsonne schwarzesonne zelenskyy war soldier', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycanned', 1, 'srdine sleeping tin fish sardine', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseylovecraft', 1, 'eldritch horror niggerman cat hp tentacle insane halloween', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyinabox', 1, 'hiding hide box cardboard happy cute', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseydrunk', 1, 'drinking shitfaced alcoholic liquor happy beer dizzy', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyprisma', 1, 'animated fingers anime spin dance weeb', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyexcited', 1, 'eager ready hype amped reaction excitement happy thrilled', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseymischief', 1, 'interface clown', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyfoucault', 0, 'philosophy history foucault postmodern', 9, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyhehe', 1, 'hehe nothehe happy laughing angry questioning', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyvan', 1, 'libertarian pedobear free candy pedophile groomer lolbert chomo molester pedo toucher', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseybobpage', 1, 'glowie deusex big pharma rocket daddy elon musk suit', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseygossip', 1, 'tea rotary phone popcorn gabbing', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseybattered', 1, 'blackeye domestic violence black eye marseyismywaifu bardfinn steve akins penny beaten bruised housewife', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyemojismilemouthtighteyes', 1, 'emoji reaction smile xd', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyvaxmaxx', 1, 'mask coronavirus covid gigavax corona vaccine vaccination hazmat', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marsey57', 1, '57 emoji57 sly smug blob', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyspa', 1, 'spa towel cucumber facial relax calm selfcare foid hygiene beauty', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseypharaoh2', 1, 'gods egyptian aevann animated', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyjamming', 1, 'mp3 headphones beat ipod music happy', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysnorlax', 1, 'fat obese fatty fattie pokemon snorlax blocking snoring  sleeping', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseywheredrama', 1, 'seriouspost reaction agendapost dramawhere animated', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyjackson', 1, 'music king pop mayo whiteface michael', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyevilgrin', 1, 'joker evil society crazy smirk wicked danger fight trouble', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycapyhacker', 1, 'animated aevann capy hack code program socks', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycapycarp', 1, 'aevann capybara carpathianflorist walking stomping trample trampling animated', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyfacepeel', 1, 'watchpeopledie kitti gore face psycho horror flay', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseydeadchat', 0, 'dead chat discord zoomercord', 7, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyumbreon', 1, 'trick or treat pokemon halloween eevee costume holiday', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseylong1', 1, 'top meme', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyhypno', 1, 'hypnosis spiral brainwash animated hypnotoad', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseywitch2', 1, 'tranny troomer penny wvp feminist halloween bardfinn groomer magick troid steve monster', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marppybiden', 1, 'sentient snappy robot marppy biden confused', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseygroomer2', 1, 'molest discord chomo snoo pedo pedocord reddit', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseychonker2', 1, 'fat obese pig disgusting fatty fattie', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyputin', 1, 'vladimir russian kgb moscow ukraine dictator leader', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycheeks', 1, 'sandy spongebob squirrel underwater bikini bottom diving suit', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyautismchonker', 1, 'fat obese retarded hat autistic neurodivergent', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseybreastcancer', 1, 'mastectomy gross yuck foid disgusting titties tits boobs patient disease bald chemotherapy', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseywinemom', 1, 'drunk wine aunt flirt cigarette drunk lush elfbinn fartbinn cougar', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseybiting', 1, 'reaction datass lip bite dat ass', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyschizoducklove', 1, 'animated schizo schizocel rare love duck', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marcuscop', 1, 'police officer acab thin blue line pig black bipoc', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyduchamp', 1, 'art urinal duchamp modern abstract', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyeerie1', 1, 'eerie excited calico', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseybush', 1, 'genocide president mission accomplished victory george bush we did it', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyhankhill', 1, 'cartoon propane hank grill kingofthehill', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseythonk', 1, 'confused reaction thinking thunk thonk', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysjw', 1, 'lgbt social justice reaction gay snowflake pride', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycringe', 1, 'pepe frog', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseydoubtit', 1, 'dumpster defender redneck boomer shooting doubt it cocksucker gun', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyschizogrizzlylove', 1, 'schizo grizzly bear love schizocel animated', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyschizonekolove', 1, 'nekobit neko schizo schizocel schizomarsey rare love', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseytree', 1, 'tree nature outdoors cosplay', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycapysorenjump', 1, 'meta excited schizo aevann capy soren', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseywink', 1, 'wink reaction cheeky flirt smirk imply hint', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseychristmasgift', 1, 'present christmas box unwrapping holiday', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyparty2', 1, 'trippy animated happy dance', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyjewoftheorientglow', 1, 'animated glow rice china chinese chink commie mao xi', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyfugg', 1, 'spurdo sparde fugg', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseydeadeyes', 1, 'broken suicidal depressed', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysoldierrussia', 1, 'army war gun rifle vatnik slav putin ukraine', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseywoah', 1, 'tldr reaction wall of text wordswordswords stfu', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyreporterfox', 1, 'reporter journalist journoid interviewer', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyhappy', 1, 'pleased contented reaction contentment satisfied', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseygoodmap', 1, 'map pedo dead shoot animated shotgun buckshot kill minor libertarian', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycarpdead', 1, 'fish janny kill', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseybrasileiro', 1, 'brazil soccer macaco monkey', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseydepressed', 1, 'smoke kms doomer cigarette despair reaction depression suicide suicidal smoking hopeless sad', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycapy2022', 1, 'aevann caypbara new year party celebration', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseychartgaussian', 1, 'stats statistics chart graph plot data gaussian normal bell distribution', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycarphug2', 1, 'fish love bottomfeeder carpathianflorist heart blow admin cute', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseygold', 1, 'gold award reddit', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyauthright', 1, 'rightoid national socialism ss national socialist nazi wehrmacht hitler fascist', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseybongo', 1, 'bongo drums music meme jam', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseydiscord', 1, 'fur furry groomer moderator uwu :3', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseystuffed', 1, 'fur meme statuesque indifferent figurine statue stuffed art', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseymspaint', 1, 'paint mspaint pixel shifty squat', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marsey173', 1, 'horror spooky halloween scp spc holiday', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyeggirl', 1, 'troomer tranny transgender lgbt groomer troid transsexual', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('capysneedboat2', 1, 'marsey capy schizo schizocel rare tripping sneed boat love excited seethe schizomarsey', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marsie', 1, 'cartoon disney', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyprojection', 1, 'animated projection projector movie director film movie cinema theatre theater kino', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('carporeon', 1, 'carp vaporeon pokemon eevee water tail fish aquatic', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseymanlet', 1, 'llm short midget dwarf little king', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyfluffy', 1, 'poofy cute shaggy happy smile excited scruffy', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseypredator', 1, 'predator drone obama wedding military', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseychristmaslove', 1, 'christmas holiday present gift present love hearts affection', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyfrozenchosen', 1, 'blonde girl woman', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyreading', 1, 'study homework learn nerd novel reaction book', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseypentagram', 1, 'satanic satanism devil evil occult witchcraft belial baphomet leviathan 666', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyshy', 1, 'flirting anxious twiddle nervous flirty coy animated', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('schopenmarsey', 1, 'schopenhauer philosophy german will ethics metaphysics', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyhijab', 1, 'hijab reading islam jihad muslim allah quran koran', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycopeseethedilate', 1, 'dilate seethe coping seething reaction angry mad dilating cope malding', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyfrylock', 1, 'cartoon athf aqua fry fries fastfood', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyinbread', 1, 'food meme inbred', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyfranklin', 1, 'franklin thinking constitution founding fathers', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysheepdog', 1, 'shaggy scruffy woof', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyfurry2', 1, 'furry fur degenerate sex', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyclown3', 1, 'unicycle animated', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycapydinosaur', 1, 'capy aevann dinosaur rawr prehistoric', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseytf2heavy', 1, 'tf2 heavy weapons valve vidya game minigun russia', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseykiwivampire', 1, 'kiwi new zealand dramarama house scary spooky bird cloak sanguine fangs halloween bloodsucker', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseychristmaself2', 1, 'elf santa northpole north pole christmas holiday', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marsey40k', 1, 'warhammer 40k 40000 space space marine marine ultramarine smurf', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyfry', 1, 'phillip fry take my money futurama', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseytf2spy', 1, 'tf2 spy france mercenary smoke suit valve vidya game espionage', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseymonk', 1, 'meditate levitating pray buddhist fish asian levitate animated yingyang buddhism karma zen', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseypotofsneed', 1, 'pot sneed pottery dungeon ornamental ancient', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyicecream', 1, 'ice cream sad disappoint pout cry.', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseybsod', 1, 'windows computer blue screen of death error glitch', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyalien', 1, 'green man martian scepter', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseygigachad', 1, 'reaction hunter eyes canthal tilt jawline', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseygucci', 1, 'gucci mane lean rapper trap mixtape bricksquad traphouse codeine lean rapper pimp', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyballerina', 1, 'dress ballet tutu dancer dancing', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseybadluck', 1, 'unlucky black cat poc nigger blackcat', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyfingerhearts', 1, 'cute love k-pop', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyvirus', 1, 'phage infect infection plagued', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marsheepnpc', 1, 'follower', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyatsume', 1, 'kitten kitty weebshit', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseydealwithit', 1, 'cool shades sunglasses reaction animated', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseybangfast', 1, 'head wall bang schizo psycho selfharm deranged gif', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseybiker', 1, 'motorcycle harley bicycle helmet', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('karlmarxey', 1, 'marxist communist history communism socialism', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyayy', 1, 'wop tone guido wooden doors sopranos greaser dego paulie', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseykermit', 1, 'kermit green frog puppet absinthe television sesame children', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycapysorenjump2', 1, 'animated soren capy jump aevann mad', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyargentina', 1, 'south america argentinian sudamericano', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyjudge', 1, 'objection innocent hammer guilty gavel court overruled sustained', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('firecat', 1, 'firefox browser marsey', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseylois', 1, 'familyguy familyman family guy family man peter griffin', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseydeterminedgun', 1, 'shooting blam blatt shooter kill die threatening animated', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyhungry', 1, 'food hunger dish feed me bowl animated', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyworried', 1, 'monkaw anxiety sweat panic scared sweaty sweating anxious nervous stressed', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseychinchilla', 1, 'pet rodent capy cute hamster south american andes', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyschizolangleylove', 1, 'animated schizo schizocel rare love langley cia glowie glow', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseymike', 1, 'disney pixar monsters inc cyclops', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyisis', 1, 'daesh terrorist islam muslim', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseychemist', 1, 'chemistry science chemical', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycarpautism', 1, 'carpathianflorist special assburgers aspergers retarded janitor jannie', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marsheep', 1, 'sheep animal fluffy wool', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseymummy3', 1, 'egyptian halloween monster holiday', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyschizoidiolove', 1, 'schizo idio3 love rare excited idio', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marmseylegionnaire', 1, 'rome roman legionnaire soldier helmet hats', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseypatriot', 1, 'uncle sam red white and blue burgerland holiday american 4oj patriotic', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyshakespeare', 1, 'words, writer, author, drama, theater, british, poet william england english thespian playwright playwrite', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycop2', 1, 'police officer acab thin blue line pig', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyanticarp', 1, 'reaction fish carpathianflorist', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseypennylove', 1, 'love penny hug wholesome black kween', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyflareon', 1, 'trick or treat pokemon halloween eevee costume holiday', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyskater', 1, 'dope hip sk8 ill tony hawk sick skateboard not a poser rad', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseymajorgeneral', 1, 'jeffthespammer pirates of penzance safari muttonchops mutton chops army military soldier officer', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseylong2', 1, 'middle meme', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseybadger', 1, 'animal marmot', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseythumbsup', 1, 'cool good job good one agree reaction nice work yes great job', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyanime', 1, 'sayian weeb', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseybaby', 1, 'pacifier bb little', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseybeansick', 1, 'bean sick vomit nausea unwell ill', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseybigdog', 1, 'bussy big dog poster', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseychristmasbulb2', 1, 'ornament holiday christmas', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseystroke', 1, 'derp retard reaction stupid drooling', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseypoor', 1, 'homeless beggar panhandler proletariat bum', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyropeyourself', 1, 'kill yourself kys lynch reaction keep yourself safe hanging noose', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseybath', 1, 'shower tub rubber duck', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseynpcmad', 1, 'angry grey libtard', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysexylibrarian', 1, 'books hoe old woman thot nerd boobs bra geek', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marsey1984', 1, 'orwell book ingsoc big brother fascist', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseytzeentch', 1, 'warhammer 40k chaos god trick magic lies', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marcerberus', 1, 'threeheadeddog horror halloween holiday greek three headed dog monster', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyangel2', 1, 'angelic horn trumpet halo wings', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseylawlz', 1, 'masterlawls zhcyid9 masterlawlz reaction glasses', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseymap', 1, 'libertarian libertarian map predator', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysonic', 1, 'hedgehog blue', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycoffee', 1, 'morning wakeup tea', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysmoothbrain', 1, 'idiot big brain brainlet retard reaction fool dumbass moron', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseybug', 1, 'beetle glitch error insect roach', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyshake', 1, 'cartoon athf aqua fastfood shake dessert icecream', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marfield', 1, 'mondays garfield lasagna', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseybreadcrumbing', 1, 'bait lure feeding food throwing animated', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyproctologist', 1, 'exam rectal glove reaction anus anal colonoscopy', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyskeletor', 1, 'skeleton mask heman 80s man halloween he man cartooon he holiday', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marje', 1, 'juicebox juice box madje marsey', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseybrave', 1, 'bat browser shill', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marlion', 1, 'animated flippers wave fins waving mermaid', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyflushzoom', 1, 'flushed eyes bulging shocked surprised flustered waytoodank', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyhomestar', 1, 'homestar runner fast everybody 2000s', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseychonker', 1, 'brap rolls fat obese reaction fds heifer', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyl', 1, 'loser loss', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyqoomer', 1, 'shaman viking qanon jan6 capitol january6', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseybane', 1, 'soy mask batman capeshit', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyjunkie2', 1, 'addicted drugs pills glue huffing ether overdose', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyrentfree', 1, 'reaction no charge obsessed obsession', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyreportercnn', 1, 'reporter journalist journoid interviewer', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycountryclub', 1, 'golfer elite rich golfing cc elitist preppy', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseydomesticabuse', 1, 'domestic violence bardfinn foid beating punching battering battered bandage hurt pain woman female', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyaward', 1, 'medal good job good work retard reaction great job great work nice', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseywallst', 1, 'hodl crypto wall street bets invest gme bitcoin wallstreetbets wsb stock', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyfedscared2', 1, 'glowie glowbipoc federal agent frightened nervous worried panicking fear', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseybear', 1, 'brian gabby murderer brianna', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycodecel', 1, 'coder coding coode aevann programming python developer', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marsey666', 1, 'wings hell halloween demon satan holiday devil animated', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysully', 1, 'disney pixar monsters inc horned horns', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseything', 1, 'halloween holiday scary monster teeth', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseychtorrr', 1, 'reddit administrator place moderator', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marchipmunk', 1, 'rodent squirrel wuzizname', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseydoctor', 1, 'medic physician white coat stethoscope clipboard checkup diagnosis healthcare', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycia', 1, 'bane cia glowie plane big guy dr pavel', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyropeyourself2', 1, 'kill yourself kys lynch reaction keep yourself safe hanging noose', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseykyle', 1, 'killer konvict rifle rittenhouse kid gun kenosha kylie', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseystalin', 1, 'tankie authleft ussr russia communism socialism marxist commie soviet proletariat marxism marxist leninist leninism revolution bolshevik', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseylifting', 1, 'workout muscular work out bench swole working out gains benchpress weightlifting weights muscles', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseypain', 1, 'suffering meme kms kill myself cat', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyban', 1, 'jannie janitor banhammer moderator banned', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyascii2', 1, 'oldschool', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseydumptruck', 1, 'pepe butt mellokind thicc thick ass booty cheeks', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysnowman', 1, 'christmas cold snow winter', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseytinfoil2', 1, 'alex jones rightoid psycho schizo alexjones conspiracy', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marchipmunklove', 1, 'chipmonk adoration loving rodent heart eyes adore acorn', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyobamahope', 1, 'happy poster barack', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyorthodox', 1, 'priest schismatic bartholomew_1 christian', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysadgun', 1, 'pepe mellokind crying tears suicidal suicide kms frog', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseybunny', 1, 'furonsa bunny usagi skin animal costume furry fursuit', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycheesehead', 1, 'packers greenbay green bay football', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyhomosupremacist', 1, 'klan lgbt faggot kkk homocracy sodomy queer gay wholesome', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyattentionseeker', 1, 'attention seek notice shout yell desperate narcissist notice', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseylovecraftian', 1, 'cosmic horror eldritch galaxy space hp spooky scary halloween animated', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycolossal', 1, 'halloween skin holiday scary mouths', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycenter', 1, 'reaction grilling boomer centrist', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseybiden2', 1, 'biden ddd dementia daddy president sleepy joe gas petrol ididthat', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyandjesus', 1, 'christianity christian jesus god love cute wholesome happy hug', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyhomsar', 1, 'homsar homestar rslur retard dumb loud shout 2000s', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseypikachu2', 1, 'pokemon shoked meme reaction surprised shocked gasp', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseylegion', 1, 'zombie wolf fallout new vegas fnv caesar courier video game roman', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseymars', 1, 'celestial space planet galaxy world solar system alien', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseylaugh', 1, 'lmao reaction point funny haha lol judgment', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyxi', 1, 'xi jinping china chinese  asia', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysoylentgrin', 1, 'numale nu male menslib redditor plebbitor happy glasses soyjak nerd loser beta smile smiling', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseybrianna', 1, 'trans bear laundrie gabby', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyridin', 1, 'joe biden kamala harris voted voting election american president hat', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseychungus', 1, 'bugs bunny meme fat chonker big', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyloadingneon', 1, 'animated loading spinner webdev rolling ball circle neon', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseybyeceps', 1, 'crying kyle gaige grosskreutz rioter sad', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycarpcrying', 1, 'tear reaction carpathianflorist fish sob tears sad', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseygigaretard', 1, 'idiot neurodivergent dumb stupid drooling moron puddle', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseychartscatter', 1, 'stats statistics chart graph plot data scatter series', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyelephantcumjar1', 1, 'semen jizz sperm bukkake cumjar elephant', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseybluecheck', 1, 'journoid checkmark verified journalist drolling drool twitter', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyfedscared', 1, 'glowie glownigger federal agent frightened nervous worried panicking fear', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysipping', 1, 'drinking root drink reaction stare thirsty purple drank juice bored', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseymrsclaus', 1, 'christmas santa winter boobs', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyschizosallove', 1, 'animated schizo schizocel rare love sal', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseypolarbear', 1, 'bear polar cold white arctic ice', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseymeds', 1, 'mentally ill rightoid doctor psycho crazy mental illness reaction risperidone schizo nurse', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyfeelsgoodman', 1, 'pepe feels good man mellokind frog happy', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyshooting', 1, 'blam blatt shotgun kill pow murder', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyhotep', 1, 'party meme parrot vibing jam dance', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyakumu', 1, 'simp love loving weebshit', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseypinkcat', 1, 'homo gay happy ribbon femme girl', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseybraveglow', 1, 'web browser glowie glow nigger glownigger glowing animated ', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseygrad', 1, 'graduate graduation school degree diploma hat tassel animated college university', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyaoc', 1, 'latina latino hispanic cortez mexican puerto rican ocasio congress alexandria', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysockmlep', 1, 'sock puppet alt anonymous shill', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyschizohobocellove', 1, 'animated schizo schizocel rare love hobo homeless hobocel', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseybruh', 1, 'bruhfunny funny or ban', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycalarts', 1, 'excited eager happy thrilled', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysphinx', 1, 'sphinx egypt ancient antiquity wonder pharaoh myth riddle puzzle', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycomradehandshake', 1, 'ussr russia communist shaking hand communism soviet', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyoctopus', 1, 'tentacles kraken tentacled', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseybog', 1, 'rich brothers bogdanoff', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyemojigrineyes', 1, 'emoji reaction grin', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyrick', 1, 'smart 150iq high iq reaction 150 iq morty', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseybateman', 1, 'bret easton ellis serial halloween patrick american psycho killer holiday blood murderer', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycamus', 1, 'philosophy history', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseybride', 1, 'dress tiara married wedding veil marseyismywaifu marriage', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseybrianna2', 1, 'trans bear laundrie gabby', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycatgirl', 1, 'uwu waifu anime fursona furry owo weebshit fursuit', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseypussyhat', 1, 'feminist feminism activism activist protester protesting foid gussy woman birthing person roasty roastie thot slut whore', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycupidangry', 1, 'fire, valentines, love, hate, angry, arrow, bow, kill, attack, shoot, weapon, flame holiday cherub angel', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycarptrophy', 1, 'carp head decapitated anticarp trophy defeat dead teaparty', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseychessknight', 1, 'chess knight horse game', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseynoyouglow', 1, 'fbi no u animated feds glowies glowniggers atf cia nsa', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyblackcop', 1, 'police officer acab thin blue line pig bipoc', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyfurry', 1, 'fursona furry fursuit kitsune', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyduck2', 1, 'onesie', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseynotesglow', 1, 'notes glow cia fbi fed writer writing', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysweating', 1, 'anxiety worried wipe scared worrying reaction anxious nervous stressed', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysylveon', 1, 'trick or treat pokemon halloween eevee costume holiday', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycatgirl2', 1, 'anime weebshit', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseydeadhorse', 1, 'drowned pony drowning', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseybabykiller', 1, 'abortion fetus knife stab planned parenthood infanticide childfree murder foid', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyklenny2', 1, 'corgi dog puppy klenvastergan smile happy', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyvelociraptor', 1, 'dinosaur velocimarsey extinct predator claws', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyrdramauser', 1, 'bussy fat lard gay homosexual obese poweruser neet dildo chef hat neckbeard meta', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyblackface', 1, 'moon cricket jogger nigger racism coon racist minstrelsy jigaboo', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyspyglow', 1, 'spy agent shill glowie russia china', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseylemon', 1, 'pucker sour lemon fruit citrus tear ', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyquestion', 1, 'suspicious sussy reaction sarcastic sarcasm', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyclown', 1, 'makeup joker', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyflamewar', 1, 'troll fight fire reaction gasoline', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyxmr', 1, 'cryptocurrency monero money happy heart', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyill', 1, 'winter chilly cold ill sick brr flu', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyautism', 1, 'retarded neurodivergent hat sped aspergers', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseybug2', 1, 'glitch code error', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysadcat', 1, 'upset disappointing disappointment reaction disappointed sad crying', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marsey4chan', 1, 'neckbeard anonymous loser hacker', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyamazon', 1, 'warehouse piss bottle driver wagecuck piss jug pissbottle pissjug wagie', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseydisabled', 1, 'retarded handicapable handicapped wheelchair crippled', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycensored', 1, '1984 memory hole censorship repressed', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseydildo', 1, 'horse', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseypin', 1, 'pinned sticky', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyfrog2', 1, 'scaley fursona furry scalie amphibian toad fursuit', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyimposter', 1, 'amogus baka among us sussy', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseybongosnoo', 1, 'bongo drums music meme jam reddit snoo', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseydrone', 1, 'obama rotors', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseymayo', 1, 'yt jakubian crying cracker reaction crackkka crakkka white sad tears', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyfattie', 1, 'brap fatass chonker pig lorg', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyeyemixer2', 1, 'mixer stirrer eyes blind selfharm mutilation gore blood gouge', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseymagahat', 1, 'trump 5200 maga american president election vote nazi hat', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marcake', 1, 'cupcake birthgay birthday cake frosting celebrate party dessert sweet', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marstolfo', 1, 'astolfo anime femboy cute blowkiss love heart justcool393 trap warrior', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseytransgenocide', 1, 'animated trans genocide chud lgbt rightoid bigot gaybros', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyangel', 1, 'reaction angelic happy innocent', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycarp2', 1, 'harm cutting selfharm cutter reaction carpathianflorist self animated', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysaluteindia', 1, 'o7 bobs vagene bitch lasagna pajeet curry desi animated flag patriotic modi', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseywoodchipper', 1, 'libertarian woodchipper libertarian kill', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyplaty', 1, 'hearts crossover platypus love', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycut', 1, 'cutting selfharm emo self harm cutter reaction depressed', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyamogus', 1, 'sussy baka impostor imposter stonetoss among us shh vent', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseydrama', 1, 'agendapost where drama seriouspost drama where', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyeyeroll', 1, 'rolleyes rolling eyes mock animated reaction roll eyes duh', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyfinger', 1, 'flipping middle finger bird reaction flicking judgment', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyschizosal', 1, 'schizo sal rare weeks nowhere', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseystein', 1, 'undead frankenstein abomination halloween holiday monster', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyclown2', 1, 'joker', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('chudsey', 1, '4chan virgin pol rightoid', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycapykiss', 1, 'capybara aevann love mwah xoxo smooch happy love', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseybountyhunter', 1, 'abortion leather vest cowboy gunslinger texas revolver', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyfreezepeach', 1, '1984 censorship free speech reaction freespeech ruqqus', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyleafeon', 1, 'trick or treat pokemon halloween eevee costume holiday', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseymeatwad', 1, 'cartoon athf aqua hamburger', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyemo', 1, 'girl goth scene woman foid', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseytexan', 1, 'cowboy hat texas yeehaw pardner rootin tootin', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyprotestyes', 1, 'agree sign protester reaction approve', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyemperor', 1, 'gold', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyfeminist', 1, 'misandry fds scrotes moids', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysociety', 1, 'batman joker capeshit jared leto', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycarsuicide', 1, 'kms suicide kill death car vehicle carbon monoxide co muffler suffocation suffocate', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marcusfootball', 1, 'sport handegg hand egg athlete helmet', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseygodfather', 1, 'wop italy italian dego mafia', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseygift', 1, 'present christmas wrapping paper holiday', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseynyansuperstraight', 1, 'animated straggot pride heterosexuality space flying', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marmsey', 1, 'rodent happy', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyhandsup', 1, 'hands up pawsup arrested arresting reaction paws up under arrest', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyfrog', 1, 'scaley fursona furry scalie amphibian fursuit', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseykfc', 1, 'col sanders colonel kentucky fried chicken', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyzombiewolflove', 1, 'hug cuddle love marseylove zombiewolf zombie wolf', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycanadian', 1, 'southpark canada leaf terrance phillip animated fart', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyimpossibru', 1, 'revulsion gross yuck yikes mad icky impossible disgusted disgusting', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyhead', 1, 'blood spurting headless horror halloween animated', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyhippo', 1, 'hippopotamus hippo fursona furry skin animal costume fursuit', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycapyblackface', 1, 'racist minstrelsy bowtie racism capybara aevann', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysaltlicking', 1, 'salt lick rock', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyeldritch', 1, 'lovecraft horror halloween tentacles holiday scary monster', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyerasure', 1, 'erase ignore block', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysalutepride', 1, 'saluting 07 military soldier gay pride lgb rainbow', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyhellraiser', 1, 'pinhead halloween holiday evil monster', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyschizobyolove', 1, 'schizo byo byobombs rare love', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyjourno', 1, 'journoid media press photo camera journalist pic', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseydevil', 1, 'pitchfork daemon hell halloween demon mischievous satan holiday heck evil', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marsey69', 1, '6ix9ine snitch tattooed tattoos rapper', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseygrilling', 1, 'barbecue bbq centrist boomer barbeque', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseytankushanka', 1, 'military ussr ccp communist authleft tank army communism china soviet russian', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseywitchtriggered', 1, 'witchcraft angry spell bardfinn tranny train troon snowflake redditor wvp magic science animated', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyfeynman', 1, 'history', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycapypharaoh', 1, 'aevann egypt alien king', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseykink', 1, 'bdsm sex kinkster dom pervert sub creeper latex fetish dildo pvc', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycontemplate', 1, 'reaction consternation thinking hmm', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycapychad', 1, 'aevann chad capy chadybara capybara muscular swole ripped egypt ouch tanktop', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyarmy', 1, 'chiobu soldiers o7 salute saluting', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyfeet', 1, 'foot frozenchosen fetish', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyfeelsgood', 1, 'meme frog feels good man pepe feelsgoodman happy', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseybait', 1, 'trolled baited trolling redditor', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseybadass', 1, 'badass whoa neil degrasse tyson science mustache ifls smug', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseygrass', 1, 'reaction outside touchgrass touch grass', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysal', 1, '2 weeks two weeks sallie white shark', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyschizoabsinthelove', 1, 'animated schizo schizocel rare love absinthe frog', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyaynrand2', 1, 'ayn rand objectivist objectivism libertarian girlboss capitalist capitalism book atlas shrugged', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysockpuppet', 1, 'animated sock puppet alt anonymous shill', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyracist', 1, 'racing vroom racecar bigot reaction', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyschizopennylove', 1, 'animated schizo schizocel rare love penny', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseybear2', 1, 'ursine bear fursona skin animal costume furry fursuit', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyheathcliff', 1, 'heathecliff', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseypartymaxx', 1, 'party meme parrot vibing jam dance', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycarp', 1, 'beard mohawk reaction carpathianflorist monster', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseymalding', 1, 'dilate seethe scrote mad moid cope', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseybingus', 1, 'floppa shaved hairless', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseybarrel', 1, 'barrel container beer bar alcohol', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycthulhu', 1, 'horror halloween lovecraftian holiday eldritch evil scary monster', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysoldieramerica', 1, 'army war gun rifle burger mutt', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseydeuxfoid', 1, 'deuxrama asian azn hardislife hil', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marsey300', 1, 'leonidas shield armor thermopylae spear greek spartan', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyhealthy', 1, 'burger king fat fast food crown unhealthy junk food american', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyhoodwink', 1, 'cloak crossbow', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyinshallah', 1, 'begging muslim animated please', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyrowling', 1, 'harry potter terf jkr transphobe', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycapyparty', 1, 'trip animated wooo aevann admin party parrot', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyburger', 1, 'burgerstan hamburger cheeseburger mutt american', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyextinction', 1, 'extinction button women misogyny mayocide kazakhstan', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyowow', 1, 'reaction excited owo', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseybux', 1, 'money paypig currency dollar bill primo premium dollarbill cash', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseymarseyloveorgy', 1, 'reaction love blush aww hugging cuddling cuddle snuggle snuggling hearts xoxo nested recursion inception orgy group', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyfrenchvan', 1, 'foucault pedophilia libertarian van french philosophy pedobear postmodernism', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseychucky', 1, 'doll halloween kill stab knife holiday possessed monster', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyhorseshoe', 1, 'rightoid leftoid theory', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyglowaward', 1, 'medal fbi ribbon animated glownigger retard glowie fed atf cia nsa', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycat', 1, 'fursona skin animal costume furry neko fursuit cat', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyyesandno', 1, 'agree disagree both confused indecisive trippy animated inconclusive idk fencesitter switzerland', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyoyster', 1, 'pearl shellfish clam give', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseylongpostglow', 1, 'animated pippy glow fedpost longpost words mad angry rage wtf green chud fbi mossad fed atf police reaction scrolling', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyumbreon2', 1, 'pokemon eevee furry eeveelution evolution', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseylovedrama', 1, 'hearts rdrama reaction happy animated', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseykys', 1, 'reaction keep yourself safe kill yourself suicide', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseybackstab', 1, 'betrayal kill knife caesar assassinate betrayer murder', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseymodelo', 1, 'cheers alcohol drinking beer', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycorn', 1, 'iowa vegetable', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseydylan', 1, 'columbine school shooter psycho gun pistol klebold', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyfug', 1, 'benis mustache meme', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseypunished', 1, 'punished venom snake metal gear solid kojima eyepatch', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyschizohanklove', 1, 'animated schizo schizocel rare love byo hank', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycharlesmanson', 1, 'charlie manson charliemanson murderer killer swastika crazy psycho schizo helterskelter prison cult', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseymacarthur', 1, 'nuke missile nuclear bomb history', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyisraellove', 1, 'love ally israel holocaust zionism', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyskull', 1, 'skull dead skeleton punisher kill bone', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseygondola', 1, 'mustache meme long legs', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseymermaid', 1, 'merman merfolk', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseymodelo2', 1, 'cheers alcohol beer drinking', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycarphug', 1, 'love squish squeeze hug squeeze fish carpathianflorist', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycapymad', 1, 'shaking aevann mad angry fury furious anger shook animated capybara', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycutattention', 1, 'razor cry depressed kys cut attention borderline bpd blood cutting woman foid', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseydragon', 1, 'smaug rich hoard gold treasure', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycarpdino', 1, 'dinosaur costume furry fursuit carpathianflorist extinct reptile lizard rawr prehistoric jurassic', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyllama', 1, 'alpaca', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyit', 1, 'balloon halloween pennywise clown holiday evil', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyplace2', 1, 'pixelart pixellated reddit lowres', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseybow', 1, 'bow ribbon happy cute adorable accessory gift present', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseynpc', 1, 'sheeple', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseypearlclutch', 1, 'sensitive reaction snowflake puritanical gasp sjw', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysimpson', 1, 'yellow simpsons groening homer bart lisa marge cartoon', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseypaint', 1, 'low effort art', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyfamily', 1, 'family guy family man peter griffin griffin peter', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseymaoist', 1, 'marxist little red book marxism ccp chinese communist authleft maoism communism china', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyliondance', 1, 'parade ccp chinese dancer dancing asian china animated', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseykvlt', 1, 'horgh abbath black metal krieg bullet belt immortal corpsepaint', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseybrick', 1, 'throw riot subtlety broken paver', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseychartbar', 1, 'stats statistics chart graph plot data bar column', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycleonpeterson', 1, 'wtf scary art', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyauthleft', 1, 'marxist ussr marxism ccp communist khmer rouge leftoid communism juche', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseytombstone', 1, 'dead death gravestone cemetery graveyard rip rest in peace', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyglaceon', 1, 'trick or treat pokemon halloween eevee costume holiday', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyben10', 1, 'ten anime cartoon lawlz', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseychristmaself', 1, 'christmas xmas santa holiday happy worker', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyretard3', 1, 'drooling stupid idiot sped moron imbecile dolt', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseypunching', 1, 'battle squaring up hit square up boxer fight throwdown reaction boxing fistfight fighting', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseymissing', 1, 'absent low effort', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseybarreldrunk', 1, 'barrel container beer bar alcohol drunk', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyrevolution', 1, 'marxist ussr marxism ccp hammer communist sickle communism proletariat juche kgb', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyslowpoke', 1, 'pokemon stupid late anime weeb meme', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseybuttface', 1, 'butthead ass donk rimjob eat ass rump rear shit fart', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseymummy2', 1, 'egyptian halloween monster holiday', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseymoose', 1, 'moosin antlers', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseynut', 1, 'orgasm ahegao cum reaction coom', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycatgirl3', 1, 'anthro anime weebshit', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycommitted', 1, 'psycho crazy insane straitjacket asylum reaction loony bin straightjacket', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyderanged', 1, 'crazy psycho mad disgusted angry rage violent baseball bat', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyniqab', 1, 'burka islam muslim burqa', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseykwanza', 1, 'christmas black kwanza african holidays', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyllama3', 1, 'bottom', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseymyspacetom', 1, 'carp friend carpathianflrost anderson', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysaturn', 1, 'devouring eating snoo kill de goya anger reddit', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseypharaoh', 1, 'egyptian aevann pyramids', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyburn', 1, 'fire flame grill burning hot red hell', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycumjar3', 1, 'semen jizz sperm spunk bukkake', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseypopcorn', 1, 'eating entertained drama happy animated', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseykingcrown', 1, 'based animated', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseypixel', 1, 'reaction lorez lowres', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyyugi', 1, 'yugioh yu-gi-oh! cards trap anime', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseymati', 1, 'annoyed irritation top hat reaction angry irritated tophat', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycarpasian', 1, 'carpathianflorist fish azn racist hat paddy gook nip ching chong chink', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseynull', 1, 'kiwifarms joshua moon josh dog', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyqueenlizard', 1, 'england bong english british reptilian elizabeth', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseytoasterbath', 1, 'suicide suicidal kill death bathtub electrocution electricity kms', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseypsycho', 1, 'reaction schizo crazy', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysoypoint2', 1, 'wojak soyjak soyjack pointing beta redditors', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseymancer', 1, 'dead undead horror lich halloween necromancer zombies zombie holiday evil', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyfursonatext', 1, 'fursuit fox fursona fursecution furfag yiff uwu owo kitsune', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseychonkerfoid', 1, 'female woman fds fat obese hambeast landwhale porker pig bleeder birthing person bangs', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycapychad3', 1, 'aevann chad capy chadybara capybara muscular swole ripped egypt nude naked', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseypleading', 1, 'sad eyes begging puppy dog eyes', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyheavymetal', 1, 'rocker musician rock guitar', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyminimalism', 1, 'orange minimalist square art', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseystrawman', 1, 'logical fallacy strawmarsey argument debate hat', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseynpc2', 1, 'reaction idiot sheep', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyobese', 1, 'fat chonker bbw chonk chunky pig lorg', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseypickle', 1, 'funniest shit morty rick', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyglancing', 1, 'eyes animated nervous paranoid', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyschizojoelove', 1, 'animated schizo schizocel rare love joe biden', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyfrozen', 1, 'dead ice reaction cold frozen', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyoceania', 1, 'kiwi new zealand kangaroo newzealand australia', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseynapoleon', 1, 'baguette soldier frenchman history', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseypumpking', 1, 'jackolantern jack o lantern halloween holiday', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyzombie2', 1, 'undead living dead romero halloween horror corpse scary rotten', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycontemplatesuicide', 1, 'gunshot mirror contemplate contemplating reflection pistol handgun death kms kys suicidal die death', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseykatamarireddit', 1, 'rolling animated vidya video game damaci damacy reddit', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseytarrant', 1, 'branton brenton newzealand kiwi shooter shooting killer ebba akerlund murderer rightoid chud strong', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseypumpkin', 1, 'jackolantern carving halloween holiday jack o lantern', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycatgirljanny', 1, 'anime maid weebshit', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseypuke', 1, 'hurl throw up gross animated illness vomit nauseated reaction upchuck nauseous sickening yuck barf ralph judgment', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyjolteon', 1, 'trick or treat pokemon halloween eevee costume holiday', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseynyanlgbt', 1, 'animated gay pride homosexuality space flying', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyeyeroll2', 1, 'animated duh rolling eyes', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyclappingglasses', 1, 'applaud applause hooray yay good job gj animated nerd', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyminion', 1, 'gru pixar', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseygodzilla', 1, 'raptor halloween dinosaur gojira evil bug', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysopa', 1, 'brazil soup macaco monkey teeth fangs scary', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyatlasshrugged', 1, 'ayn rand objectivist objectivism libertarian girlboss capitalist capitalism book atlas shrugged', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseygodel', 1, 'old philosophy glasses history', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyn8', 1, 'nate redditor powermod powerjannie moderator', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyneko', 1, 'autism autistic cute neko nekobit fedi fediverse hat programmer codecel', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyoutletsuicide', 1, 'fork outlet plug socket kill kms electricity electrocution electrocute death die', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyconstellation', 1, 'starsey galaxy space sky', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseychartpie', 1, 'stats statistics chart graph plot data pie categorical', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyfbi', 1, 'cop glownigger fed glowie agent federal', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseychocobo', 1, 'marseybo bird final fantasy vidya video game gamer gaming fast', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyjcdenton', 1, 'sunglasses shades vidya video game deusex deus ex', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyschizocarplove', 1, 'schizo carp love rare excited', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseymutt2', 1, 'american burger 56 percent mayo', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseynooo', 1, 'reaction snob no way', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyaynrand', 1, 'ayn rand objectivist objectivism libertarian girlboss capitalist capitalism author randsey', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycapypunished', 1, 'capybara rodent aevann cute metal gear solid venom snake video game kojima mgs', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseypride', 1, 'prideflag rights', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseydawnbreaker', 1, 'gamer video game warhammer', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycapywalking', 1, 'capybara animated aevann', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyllama1', 1, 'top', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseylion', 1, 'fursona furry fursuit leo', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyplane', 1, 'flying jet pilot', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyhammersrdine', 1, 'animated beat bongo hammers sardine redditors can the', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseynerd', 1, 'dork loser dweeb geek glasses aevann', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseypilgrim', 1, 'thanksgiving puritan holiday', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyspinner', 1, 'animated loading webdev spin circle', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseynintendo', 1, 'mario gamer switch gaymer video game mustache soy', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycoonass', 1, 'student lsu university louisana state', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyhacker2', 1, 'dox anonymous computer', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseypop2', 1, 'excited blahblahblah blah blah blah animated', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyspookysmile', 1, 'horror halloween holiday evil scary monster', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyobama', 1, 'obama president black drone reaper predator', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyagreefast', 1, 'nodding yes sure ok animated enthusiastic enthusiasm', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseypepe2', 1, 'reaction frog mellokind', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseytaliban', 1, 'mujahideen janniejihad islam afganistan shariah afghanistan muslim', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyhope', 1, 'mask whitepill reaction happy hopium', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysmudge', 1, 'diogenesjr diogenesjunior meme', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyeyemixer', 1, 'mixer stirrer eyes blind selfharm mutilation gore blood gouge', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyrussel', 1, 'old pipe history', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyglow2', 1, 'fbi mossad feds agent glownigger reaction glowie fed atf cia nsa', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyhappening', 1, 'ronpaul happening it ron paul itshappening animated', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyghost', 1, 'spooky halloween costume holiday scary sheet', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseybuff', 1, 'ripped muscular 6pack swole 6 pack sixpack abs six pack muscles', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseymayoface', 1, 'black blackface whiteface mayo mayocide mayonnaise racist racism', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseypizzashill', 1, 'sex haver chad grass toucher', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysaw', 1, 'doll horror halloween jigsaw monster evil torture game holiday', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseybraveheart', 1, 'movie mel gibson william wallace scotland scottish sword claymore blue paint celt highland', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marsoyhype', 1, 'soyboy soybeard nerd marsey excited wojak cuck', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyschrodinger', 1, 'philosophy science physics math', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysting', 1, 'drum badumtiss ba dum tiss bad dum tiss baddumtiss comedy humor punchline animated standup joke', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycapychad2', 1, 'aevann chad capy chadybara capybara muscular swole ripped egypt', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseylizard', 1, 'reptilian', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyschizochadbasedcapylove', 1, 'animated schizo schizocel rare love chad based capy aevann', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyjanny', 1, 'jannie unpaid volunteer administrator janitor free moderator', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysus', 1, 'amogus among us stonetoss sussy baka amongus', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycoomer', 1, 'masturbation goon cumbrain porn masturbate', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyblind', 1, 'sight stick disability blind glasses disabled handicapped', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseypimp', 1, 'dramamine slickback purple baller', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseypikachu', 1, 'electric pokemon yellow', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseymerchantelf', 1, 'jew christmas elf santa greedy money chosen worker holiday xmas seth rogen sarah silverman holocaust coin kike', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyilluminati', 1, 'eye egypt pyramid big brother watching', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseymonke', 1, 'retvrn return', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycop', 1, 'acab thin blue line chauvin police officer', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyblueanime', 1, 'cirno touhou weebshit', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysnowflake', 1, 'special snowflake sensitive snow', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyshisha', 1, 'weed smoker smoking hookah', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseynyan', 1, 'space animated meme poptart', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseylenin', 1, 'ussr russia communism socialism marxist commie soviet proletariat marxism marxist leninist leninism revolution bolshevik', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseynietzsche', 1, 'philosophy history', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyblackfacexmas', 1, 'uncle tom moon cricket christmas santa beard nigger racist claus coon', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyschizochadseethecapylove', 1, 'animated schizo schizocel rare love chad seethe capy aevann', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseypepe', 1, 'ok rightoid mellokind frog reaction', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysheep', 1, 'follower wool lamb fursona bah furry fursuit', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyjohnson', 1, 'wig history', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysalad', 1, 'vegan cabbage vegetarian lettuce vegetable', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyjoseon', 1, 'korean hat azn asian', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyschizochadyescapylove', 1, 'animated schizo schizocel rare love chad yes capy aevann', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseybrap', 1, 'brap sniff smell huff gas fart animated', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycutwrist', 1, 'suicide slash wrist razor blood cry tears sad depressed depression kill dying kys cut cutting', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseypoggers', 1, 'poggies twitch meme quagmire jawdropping shock surprise', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseykweenxmas', 1, 'blm black christmas santa bipoc nigger bame hat holiday', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseypostmodern', 1, 'postmodernist obscurantist art', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseykoolaid', 1, 'oh yeah juice cult ice pitcher drink', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyrs', 1, 'runescape party hat phat crown lowpoly low poly', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseystinky', 1, 'smelly homeless stank poor ew yuck', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseypumpkinglow', 1, 'halloween drama holiday jack o lantern animated', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseygroomer', 1, 'pedobear discord pedophile pedo chomo molest pedocord', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyembrace', 1, 'embracing hugging love happy', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyparty3', 1, 'trippy animated happy dance', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycapy', 1, 'capybara rodent aevann happy cute', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysanta', 1, 'christmas gifts presents claus holiday', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysalutearmy', 1, 'saluting o7 military soldier', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysalutecop', 1, 'acab officer saluting o7 police', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseypirate2', 1, 'party parrot eyepatch partyparrot', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseypretty', 1, 'flirt starry eyed stars in eyes', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseypainter', 1, 'palet reaction pallet paintbrush paints artist pallette', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycringe2', 1, 'grimace grimacing yikes oof bruh moment', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseydracula', 1, 'halloween fangs cape holiday vampire', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('thinbluefeline', 1, 'cops police', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyfursona', 1, 'fursuit fox fursona fursecution furfag yiff uwu owo kitsune', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyjoint', 1, 'smoke weed marijuana reefer drugs smoking 420 pot', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseygras', 1, 'mardi gras fat tuesday nola new orleans neworleans holiday louisiana mardigras carnival beads mask', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyschizocapylove', 1, 'schizo aevann capybara love rare excited', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseypanda', 1, 'red panda bear happy redpanda', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('goldenshower', 1, 'pee piss golden shower fetish trump sex rain storm clouds', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseypin2', 1, 'sticky pushpin award', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyspit', 1, 'surprising reaction shocking water surprised shocked', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseykys2', 1, 'keep yourself safe', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycapyeffendi', 1, 'capy aevann fez egyptian ottoman', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyobamarope', 1, 'barack suicide kms kys hanging noose poser', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycupid', 1, 'cupid, love, heart, valentines holiday, marry, wedding, couple, kiss, wink, sex, arrow, bow, shoot animated', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysosa', 1, 'chief keef sosa glo rap hiphop music drugs lean black', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseytea', 1, 'drama spill', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseytheorist', 1, 'ancient aliens meme', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyfrozenlove', 1, 'mellokind stalker obsessed obsession fixation creepy stalking frozenchosen love hug foid hearts', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyshitforbrains', 1, 'brainlet poop dumb litterbox litter box soyjack soyjak redditor retarded scat', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseywtf', 1, 'scared reaction shook surprised shocked', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseytrump', 1, 'cheeto hitler president history orange man', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseylowpoly', 1, 'polygonal spinning 3d lopoly animated', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseymyeisha', 1, 'kween black fds', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseypopcorntime', 1, 'eating popped corn drama animated watch', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseygoodnight', 1, 'kazakhstan flag reaction kazakh i hate women women', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseymummy', 1, 'egyptian halloween monster holiday', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseytunaktunak', 1, 'turban animated curry indian pajeet dance', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyplaying2', 1, 'fish playful mischief srdine animated', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycreepy', 1, 'pervert pedophile weird reaction chomo creeper sketchy molester', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseymime', 1, 'mimesey facepaint black and white beret silent mute performer', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysneedboat', 1, 'animated ship flag capybara', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseytrollolol', 1, 'rage trolled rageface', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyobamanope', 1, 'no way wrong poster barack', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyglobohomo', 1, 'globalism soulless modernity art corporate corporation', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysmug', 1, 'reaction superior haha', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseypeacekeeper', 1, 'united nations un rifle helmet gun', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseymask', 1, 'plague coronavirus covid pandemic coof sickness love heart eyes illness', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyevilagent', 1, 'feds agent glowies usa america waco swat m16 firearm rifle satan demon cops police', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycheeky', 1, 'stick tongue brat reaction taunt na tongue out tease', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseypathetic', 1, 'pathetic asuka', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseypanties', 1, 'reaction underwear panty pantsu', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseygeisha', 1, 'foid birthing person girl woman girl lady slut thot noodlewhore chink jap gook asian azn blow kiss blowing kiss blowkiss love heart stockings nylons fishnets', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseytoilet', 1, 'flush loo bog roll toilet paper swirly', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseymugshot', 1, 'arran prison arrested criminal jail', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyprotestno', 1, 'sign protester refuse reaction deny reject', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyuglyxmasweater', 1, 'santa hat christmas ugly holiday', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseymushroomcloud', 1, 'atomic bomb nuke kaboom explode explosion war radiation', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysherpa', 1, 'mountain climbing travel nepal himalaya asia everest', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseymechanic', 1, 'wrench car diy fix repairman dipfuck', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseydab', 1, 'reaction haters', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyplaying', 1, 'fish playful mischief srdine animated', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyazov', 1, 'ukraine ukrainian nazi battalion dead russian war soldier corpse chud', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyteaparty', 1, 'donger arran soren carp duck', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseypharaohcat', 1, 'egyptian illuminati aevann pyramid sand ancient alien artifact museum history king cleopatra', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseytv', 1, 'willy wonka telly television', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseybeandefiant', 1, 'bean defiant tongue opposed disagree', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseymao', 1, 'zedong ccp chinese communist communism china', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyotter', 1, 'otter, fish, sea, swim, lake, nature, seal, sealion, river. wuzizname, float', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyuwuw', 1, 'fursona furry fursuit', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysamhyde2', 1, 'gun shooter sammy mdegenerate milliondollarextreme million dollar extreme', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseytrollcrazy', 1, 'i hate killher psycho rage kill her gun', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseylibleft', 1, 'unemployed protest riot anarcho capitalist antifa anarchist anarchy', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyyeezus', 1, 'kanye god hotep', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseypop', 1, 'action figure doll funko toy soy', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseythomas', 1, 'tank engine train locomotive', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseypony', 1, 'murmurwisper mlp my little ponies cutie mark horse furry my little pony', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseypope', 1, 'priest catholicism rome', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyhankhill2', 1, 'propane cartoon hank grill kingofthehill', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyracistgrandpa', 1, 'thanksgiving fuck nigger holiday', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyantischizo', 1, 'rare meta schizocel scizocel skitzocel schizophrenic scitzocel', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyemojigrin', 1, 'emoji reaction grin', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyfuckoffcarp', 1, 'reaction carpathianflorist rude snappy animated robot marppy', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyramen', 1, 'eating noodles food bowl animated soup', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyhearts', 1, 'reaction flirt loving adoration love happy cute crush', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyobey', 1, '1984 sign ingsoc poster big brother', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyrave', 1, 'dead animated party death sandstorm darude crab dance', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyquadmagyar', 1, 'bow and arrow hungary hungarian archery bowman quadnarca', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyemojismilemoutheyes', 1, 'emoji reaction smile', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyunamused', 1, 'annoyed staring reaction disappointed stare uh huh bored', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyrasta', 1, 'marijuana weed dude weed lmao ganja drugs pot reggae joint jamaican', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseymommymilkers', 1, 'pepe mellokind momma booba khazar abby shapiro tits breasts boobs', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyteruteru', 1, 'ghost flying spooky halloween holiday floating', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseynoyou', 1, 'nou no u pointing', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseypumpkincloak', 1, 'costume halloween holiday', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycumjar1', 1, 'semen jizz sperm spunk bukkake', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyfbiagent', 1, 'feds fbi agent glowies usa america waco swat m16 firearm rifle cops police', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyyes', 1, 'thumbsup agree right thumbs up reaction judgment', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseypokerface', 1, 'small eyes reaction stare unreadable beady eyes', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysad2', 1, 'reaction disappointed disappointment upset', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyface', 1, 'mask psycho face horror halloween kill killer stab knife holiday evil murder scary murderer', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyjumpscare', 1, 'undead living dead romero halloween horror corpse scary rotten animated spooky aaaahhhhh trick prank bait and switch', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseydefenestration', 1, 'suicide window jump kill murder kms jump out window death die defenestrate', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseydeux', 1, 'frenchman deuxrama baguette frog frenchie', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyjunkie', 1, 'needles heroin reaction shooting up addicted shoot up syringe', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyclippy', 1, 'msoft microsoft word helper paperclip writing annoying', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycanada', 1, 'leaf canadian canuck rake hockey donut trudeau maple', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyhelp', 1, 'wtf nervous anxious anxiety worried concerned helpme help me uncomfortable awkward', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseymar', 1, 'dexter lab foid destruction irritating annoying sister cartoon network pigtails', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseytalking', 1, 'speech bubble smug gossip', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseypumpkin3', 1, 'witch jackolantern carving halloween holiday jack o lantern', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseychad', 1, 'canthal tilt jaw hunter eyes', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyrat', 1, 'rodent black', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyschizodoggilove', 1, 'animated schizo schizocel rare love dussy doggi', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyeric', 1, 'columbine school shooter psycho gun carbine harris', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseychinesedevil', 1, 'devil evil horns satan china hell demonic', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyschizocapygitcommitlove', 1, 'animated schizo schizocel rare love chad capy git commit fsdfsd', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyradioactive', 1, 'nuclear waste chernobyl radiation geiger', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyawardretard', 1, 'medal retarded drooling idiot moron prize congratulations congrats', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseytimmy', 1, 'turner nickelodeon fairly oddparents hat boy cosmo wanda', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycactuar', 1, 'cactuar final fantasy cactus soy shocked cactuarsey 1000 needles vidya video game', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseydizzy', 1, 'puke nausea spinning vomit reaction nauseous sick rolling barf animated', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyorthodoxsmug', 1, 'schismatic heretic scoff christian priest gloat', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyturkey', 1, 'beak bird thanksgiving holiday feathers', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseytroll2', 1, 'ogre horror halloween holiday monster', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseybootlicker2', 1, 'sheep conformist lapdog rightoid conservative trump idiot shoe hearts', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyditzy', 1, 'pokemon', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysanders', 1, 'bernie rich socialism socialist jewish', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseymoney', 1, 'capitalism capitalist rich dollar signs bag wealthy dollars dinero', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseykamikaze', 1, 'kamikaze japanese nip pilot ww2 wwii world war', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseypumpkin4', 1, 'ghost jackolantern carving halloween holiday jack o lantern', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyblops2cel', 1, 'incel volcel black ops gamer iconic saint', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseymeowth', 1, 'pokemon weeb anime, manga team rocket nintendo video game vidya monster', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysurprised', 1, 'reaction shocked shook unexpected', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseywarboy', 1, 'witness warboy nux madmax mad max apocalyptic evil apocalypse', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseydemiurge', 1, 'gnostic gnosticism demiurge', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyobesescale', 1, 'fat chonker bbw chonk chunky pig lorg', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyzoomer', 1, 'child brat kid zoomie', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseygoose', 1, 'goose geese kill duck cat bird death bite chomp', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseywendy', 1, 'jellyfishjam pigtails redhead pippi', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseypresents', 1, 'christmas gifts santa holiday candy cane happy', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyandmarcus', 1, 'bed sleeping cuddling cuddle marseyismywaifu', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyhesright', 1, 'batman lucius fox nolan hes right you know reaction agree thumbs up based morgan freeman correct', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycarplazy', 1, 'carpathianflorist fish couch sleeping slacker idc antiwork janitor', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseygoose2', 1, 'goose geese kill cat bird death bite chomp', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseytwins', 1, 'halloween holiday flashing shining scary animated', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyseven', 1, 'vidya gamer gaymer video game assassin hitman', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysmirk', 1, 'reaction snicker trolling lol', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyllama2', 1, 'middle', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyisrael', 1, 'kike yid jewish hebrew merchant colonizer israeli banker', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyhammerpizza', 1, 'animated beat bongo hammers pizzashill rdrama', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyakbar', 1, 'suicide bomber explosion boom explode die kms animated', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseypanda2', 1, 'panda bear fursona skin animal costume furry fursuit', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyjason', 1, 'hockey mask horror halloween kill fridaythe13th knife stab voorheys friday the 13th evil monster holiday', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyschizodongerlove', 1, 'animated schizo schizocel rare love kaiser uraniumdonger donger', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysamhyde', 1, 'gun shooter sammy mdegenerate milliondollarextreme million dollar extreme', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyskeleton2', 1, 'bones spooky halloween holiday skeletal', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyditto', 1, 'pokemon weeb anime blob happy', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyyinzer', 1, 'pittsburgh pennsylvania pens penguins steelers stillers pirates buccos buckos terrible towel pierogo yuengling beer city hat baseball football hockey nfl mlb nhl happy', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyantiwork', 1, 'lazy laze bum unemployed animated', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyno', 1, 'denied refuse rejection reaction ugh deny hand', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyseethe', 1, 'dilate mask crying seething smug cope', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyloading', 1, 'animated loading spinner webdev rolling ball circle', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyterrydavis', 1, 'templeos nerd programmer glownigger', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyjetfighter', 1, 'pilot plane airforce air force usaf bomber dogfight war', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysnek', 1, 'snake serpent', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyraccoon', 1, 'trashpanda trash panda', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('merdesey', 1, 'turd turdsey shitsey poopsey shit poop poop marsey shit marsey', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyvengeance', 1, 'gore undead shotgun horror halloween revenge monster bloody head wound holiday', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysmugretard', 1, 'srdine drooling brainlet idiot fool buffoon idiot', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyoverseether', 1, 'rdrama meta seething fire red bigmad angry anger', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysunflower', 1, 'love ukraine threatening pointing russia', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('mlm', 1, 'marseylivesmatter marsey lives matter blm', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysoutherner', 1, 'plantation suit cigar good ol boy buck breaking buck breaker', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseykrampus', 1, 'demon monster christmas', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyshook', 1, 'reaction surprised shocked gasp astonished', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseykiwi2', 1, 'kf bird new zealand kiwifarms newzealand', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseykkk', 1, 'klan kukluxklan ku klux klan racist costume klux ku sheet', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyfingergoodjob', 1, 'cute encourage positive respect k-pop thumbs up congrats gif animated congratulations nice ok great', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseybutt', 1, 'booty ass rump sexy hot pawg pawc paoc anal sodomy donk dump truck dumptruck mellokind', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseybased', 1, 'basado king chiobu redpilled reaction animated', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseydarwin', 1, 'history darwinian euphoric atheist charles', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycrystal', 1, 'gem crystal diamond sparkle precious shiny glass', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyschopenhauer', 1, 'philosopher old grandpa', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyfrontiersman', 1, 'america usa 19th history indian native wild nature rural frontier expansion settler', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycheerup', 1, 'pat animated depressed comforting grieving reaction depression there there console comfort pet', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysuper', 1, 'superstraight lgbt', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysephiroth', 1, 'ff7 ffvii final fantasy vidya video game gamer gaming villain sword', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseydream', 1, 'spirals trippy swirls rainbow', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyplugged', 1, 'electric technology gif animated plug', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyschizobussylove', 1, 'animated schizo schizocel rare love certified bussy operator', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseykitty', 1, 'hellokitty animated hello kitty', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyespeon', 1, 'trick or treat pokemon halloween eevee costume holiday', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyoctopus3', 1, 'consume product epic win communities no bait too obvious globe patch', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseytrotsky', 1, 'icepick trotskyist betrayal ussr russia communism socialism marxist commie soviet proletariat marxism marxist leninist leninism revolution bolshevik', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyrussiadolls', 1, 'toys ussr babushka matryoshka soviet', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysadge', 1, 'frog pepe', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyshiftyeyes', 1, 'suspicious sussy paranoid weird reaction sketchy', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseykindness', 1, 'retarded special drooling idiot seriouspost srspost agendapost moron fool buffoon dramatard', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyrightoidschizo', 1, 'nazi conspiracy crazy tin foil tinfoil conservative animated ruqqus', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyspider', 1, 'insect halloween arachnid holiday bug', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseygarfield', 1, 'mondays lasagna', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseykkkblm', 1, 'ku klux klan racist nigger jogger coon jiggaboo cracker crackkka', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseypunisher', 1, 'thin blue line rightoid police cops', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycrying', 1, 'tear cried despair weeping reaction depression sob tears sadness depressed animated sad', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyopossum', 1, 'possum trash', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyaustralian', 1, 'beer fosters mate hat gday crikey oz', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyremastered', 1, '4k hd hi def hidef high definition uhd rtx', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyreindeer2', 1, 'santa christmas rudolf holiday', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysoyrope', 1, 'redditor dead suicide kms kys hanging lynched hung soyjak', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseywheredrama2', 1, 'seriouspost animated agendapost', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseybootlicker', 1, 'sheep conformist lapdog rightoid conservative trump idiot shoe', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyspooky', 1, 'art horror halloween holiday evil scary monster lovecraftian eldritch', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycop3', 1, 'police officer acab fuck12 rifle gun law enforcement sheriff', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyretro', 1, 'cardboard retro gameboy green nerd gamer', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyorthodoxcarphug', 1, 'schismatic heretic embrace hug love bartholomew carpathianflorist', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyportalsuicide', 1, 'kill shotgun shoot death die kms animated', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyking', 1, 'based queen prince reaction crown princess', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseykrampus2', 1, 'demon monster christmas', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseykino', 1, 'kino agni fire punch anime', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyavril1', 1, 'lavigne canadian leaf beautiful hot sexy punk rocker singer musician artist tie sk8er boi complicated brunette', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseypumpkin2', 1, 'jackolantern carving halloween holiday jack o lantern', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyunabomber', 1, 'package industrial society delivery mail kaczynski uncle ted', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseylong3', 1, 'bottom meme', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysickos', 1, 'hahaha ha ha ha yes onion comic pervert sicko creep', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyelephant', 1, 'oliphant dumbo', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyprideflag', 1, 'pride flag marseysexual sexuality lgbtq gay trans bipoc queer activism', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseystars', 1, 'stareyes reaction star eyes starry eyed stareyed', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseylibright', 1, 'libertarian anarcho wagecuck pedophile capitalist lolbert', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycapylove', 1, 'aevann heart eyes hug adore adoration snuggle cuddle capybara', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyrussiaglow', 1, 'animated russia red putin fsb kgb glow trump commie communist hat comrade', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseybeggar', 1, 'poor busking panhandler gofundme busker', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyvargselfdefense', 1, 'vikernes euronymous mayhem burzum black metal norway norwegian stab knife kill murder', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseypathetic2', 1, 'anime weeb asuka shun scorn disgust contempt disgusted', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyoldtimey', 1, 'cartoon disney vintage olde classic retro', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyfox', 1, 'fursona furry fursuit kitsune', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyza', 1, 'antlers flowers', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyretard', 1, 'special ed retarded reaction slow sped drooling exceptional', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysexypepe', 1, 'mellokind hotpepe frog lewd flirt ribbon', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseychinchillalove', 1, 'pet rodent capy cute hamster south american andes', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseypenguin', 1, 'bird linux puffin', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseytrickortreat', 1, 'candy trick or treat halloween holiday', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseygarfieldpipe', 1, 'marfield pipe smoking john yelling comic smoke', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyschizodussylove', 1, 'animated schizo schizocel rare love dussy doggi', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyemojismilemouth', 1, 'emoji reaction smile', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseywalking', 1, 'stroll walk strut gallivant animated', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseytransflag2', 1, 'lgbt transgender tranny pride animated', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseypirate', 1, 'argh eyepatch bandana uraniumdonger', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseygigavaxxer', 1, 'covid vaccine coronavirus vaccination', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyglow', 1, 'fbi mossad cop feds animated glownigger glowie secret service fed atf police cia nsa kgb', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyweeb', 1, 'neckbeard sword fedora kitana', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysteer', 1, 'car drive nervous driving animated', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marsheen', 1, 'pusheen animated meme cute', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyparty', 1, 'excite excitement celebrate happy celebrating', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycool', 1, 'finger gun shades sunglasses reaction judgment', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseybrainlet', 1, 'idiot imbecile smoothbrain crushed head retard caved in head sped dumb stupid drooling moron', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseywarhol', 1, 'modern art', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('mcmarsey', 1, 'wageslave poor mcdonalds wagecuck maccas antiwork college wagie', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyfans', 1, 'of thot taxpayer slut onlyfans whore', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseymini', 1, 'annihilate minigun machine gun kill destroy murder animated', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyqueen', 1, 'england bong english british elizabeth', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyzodiac', 1, 'zodiac killer zodiackiller tedcruz ted cruz murderer crazy mask gun shooter shooting death', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyjfk', 1, 'john fitzgerald kennedy jfk president american history sniper car death kill usa assassination', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyblush', 1, 'shy flirting reaction blushing happy cute embarrassed', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysalutenavy', 1, 'saluting semen o7 homosexual soldier', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyzombie', 1, 'dead undead eye horror intestines halloween holiday monster', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseybee', 1, 'bee honey honeybee insect fly honeypot pollinate pollen animated', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyfellowkids', 1, 'groomer adult buscemi skateboard', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseytariq', 1, 'buck breaking nasheed nigger coon black', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyconfused', 1, 'questionmark reaction question mark idgi confusion', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseydisagree', 1, 'nah uh nod nuh uh reaction wrong no way no negative animated judgment smh', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseymarseylove', 1, 'aww blush hugging cuddling cuddle snuggle snuggling hearts shy kiss xoxo', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyblackmage', 1, 'magic wizard final fantasy spell video game vidya evil', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseydolphin', 1, 'ocean goggles rainbow', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyspiderman', 1, 'soy marvel capeshit dc comic book comics peter parker miles morales webslinger', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseydisintegrate', 1, 'disappear marvel explode dust thanos snap evaporate crying sad vanish animated snapped', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyponder', 1, 'ponder orb wizard magician crystal ball', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyslab', 1, 'dexter lab smart genius ginger cartoon network glasses', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseymaxrockatansky', 1, 'mad max madmax fury road furyroad post apocalyptic apocalypse australian australia', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseymad', 1, 'pissed annoyed furious reaction angry irritated livid', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseygivecrown', 1, 'king based swole reaction muscles', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseydicklet', 1, 'babydick penis micro dick reaction laugh point and laugh micropenis judgment', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysexy', 1, 'ned flanders stupid sexy flanders skiier skiing winter simpsons', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseygangbang', 1, 'blacked sex orgy', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseychicken', 1, 'bird fowl poultry beak hen rooster happy', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycodecellove', 1, 'love bsod code dev hug heart computer tech admin admigger program', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysnap', 1, 'mad angry furious anger animated snap', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseywinner', 1, 'reaction trophy gold prize first place', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyrobber', 1, 'mask balaclava gun shooter shooting thief criminal nigger jogger ahmaud arbery george floyd', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyschizochadthankscapylove', 1, 'animated schizo schizocel rare love chad thanks queen capy aevann', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyminer', 1, 'miner minecraft mine craft mining digging minor blocks pixel game vidya video notch', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyturkeyhappy', 1, 'bird thanksgiving food dinner yum delicious holiday', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysquint', 1, '4084 hmmm squint unsure doubt', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyoldguard', 1, 'napoleon war soldier musket french france history europe reaction', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseymouse', 1, 'rodent cheesed to meet you', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysartre', 1, 'philosophy frenchman history', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyishygddt', 1, 'reaction, meme, disapproval, bat, club, beating, angry, demented disgust, dislike, baseball bat, shiggy diggy, george costanza', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysharingan', 1, 'horror halloween holiday possessed animated monster naruto anime ninja', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseywolf', 1, 'halloween werewolf holiday scary monster', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyhannibal', 1, 'flesh psycho horror halloween cannibal eat holiday', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyjaguarwarrior', 1, 'mayan incan injun latinx aztec native blood fight mexican', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyschizofartbinnlove', 1, 'animated schizo schizocel rare love fartbinn idk idc', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyyeti', 1, 'scary monster myth winter ice mountain himalaya asia predator giant', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseythinkorino', 1, 'reaction judgment thinking', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseythief', 1, 'steal final fantasy video game vidya', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseynails', 1, 'manicure emoji pedicure', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyluther', 1, 'heretic lutheran theses martin luther', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyfigureskate', 1, 'skater iceskate ice skate skating olympics winter on ice', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyplush', 1, 'bow ribbon doll plushie button eyes', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseymap2', 1, 'map geography topographical paper navigation chart cartography location place', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('owlsey', 1, 'bird hoot feathers', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyrain', 1, 'cloud upset reaction disappointed storm depressed sad', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseypipe', 1, 'smoke smart mhm yes smoking tobacco intelligent', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysnowman2', 1, 'christmas cold snow winter', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseymexican', 1, 'latina latino hispanic fiesta sombrero latinx hombre mexico', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseykernelpanic', 1, 'linux kernel panic computer error glitch', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyw', 1, 'win winner dub', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseywave', 1, 'farewell cya hello greetings bye waving hi', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseymilesdavis', 1, 'jazz saxophone bebop music trumpet brass black', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyasian', 1, 'chinese china srdine sardine', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseythroatsinging', 1, 'mongolian music', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyimmortanjoe', 1, 'immortansey mad max madmax fury road furyroad post apocalyptic apocalypse australian australia', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseywitch3', 1, 'flying broomstick wave halloween wizard holiday', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyavril3', 1, 'lavigne canadian leaf beautiful hot sexy punk rocker singer musician artist blonde green hair he wasnt', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyshapiro', 1, 'benjamin debate libtard facts and logic benny jewish ben shapiro', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseydoit', 1, 'pistol handgun kys kill yourself glowie federal agent fbi cia atf nsa glow nigger glownigger suicide suicidal keep yourself safe', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseymarseylovelove', 1, 'reaction love blush aww hugging cuddling cuddle snuggle snuggling hearts xoxo nested recursion inception wholesome', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyaleistercrowley', 1, 'aleister crowley occult wizard robe esoteric bisexual', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseypearlclutch2', 1, 'sensitive reaction snowflake puritanical gasp sjw', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyimmaculate', 1, 'christian christmas jesus immaculate god mother mary xmas pray', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysuit', 1, 'businessman businessperson corporate boss manager rich adult professional lawyer banker', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysociety2', 1, 'joker clown capeshit batman gamersriseup cigarette honk', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyvaporwave', 1, 'trippy 80s psychedelic animated retro', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyonacid', 1, 'tripping trippy drugs lcd animated', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseymorph', 1, 'skinwalker changeling', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseygunnut', 1, 'ahegao 2a second amendment rifle horny lust lick tongue shooter shooting', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseylaptop', 1, 'notebook macbook computer', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyjiangshi', 1, 'ghost chinese halloween holiday china scary', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyneon', 1, 'wave flashy trippy waving flashing lights animated', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyangrygamer', 1, 'gamer angry mad nes console nerd', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseystarbucks', 1, 'coffee latte barista marbucks scone', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseymothermary', 1, 'christian christmas jesus immaculate god mother mary xmas pray', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseynun', 1, 'habit catholic', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyadeptusmechanicus', 1, 'warhammer 40k adeptus mechanicus', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysalat', 1, 'prayer islam muslim rug', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyminimalism2', 1, 'minimalist polygons polygonal art', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseytruck', 1, 'honk canadian trucker hoonk ottawa convoy leaf semi 16wheeler', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseybaphomet', 1, 'halloween demon satan holiday evil devil', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyjetbombing', 1, 'obama bush animated usa animated american pilot bomber plane war usaf air force', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyjapanese', 1, 'nippon rising sun weeb japan animated', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseypenny', 1, 'penny mrpenny black trad foid bleeder female woman kween negro dress baptist christian', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseymiku', 1, 'hatsune miku pop star concert rave weeaboo music animated singing microphone', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyski', 1, 'skier skiing sking winter snow', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycapyexcited', 1, 'excitement capybara bouncing jumping aevann bounce yay animated', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysaluteusa', 1, 'salute o7 animated flag patriotic patriotism burger nationalism flag american', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseytelegram', 1, 'telegram homecoming plane chat messaging russian', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseytherapist', 1, 'therapy writing mental illness', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyplace', 1, 'reddit pixels pixellated pixellation lowres', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyninja', 1, 'samurai japanese killer stealthy sneaky assassin weeb', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyshroom', 1, 'smug fungus shrigma shroomjak wojak mushroom', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyklenny', 1, 'chiobu jenna thorne grunderchin vidunderchin clapping applause animated', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseydead', 1, 'murdered dead killed reaction victim die rip', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyantiwork2', 1, 'lazy doreen unemployed slacker lazing laying welfare tired', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseychimera', 1, 'fullmetal alchemist chimera science trans doctor anime dog sad depressed tragic anime fma weeb', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyjeans', 1, 'denim trousers pants', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('mersya2', 1, 'drawing art', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseymountaineer', 1, 'winter climbing coat ice sport peak axe cleats mountain alpine climber', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyinvisible', 1, 'stealth', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyschizogeeselove', 1, 'animated schizo schizocel rare love geese suck', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysrdine', 1, 'fisherman reaction fish canned fishing', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseypajeet', 1, 'indian currycel bobs vagene streetshit street shit superpower 2020 happy', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseynotes', 1, 'notes writer writing journ*list therapist doodle', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseywave2', 1, 'waving hi hello cya bye later animated', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyfuriosa', 1, 'mad max madmax imperator furryosa fury road furyroad post apocalyptic apocalypse australian australia', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseychristmasparty', 1, 'christmas holiday celebrate party wooo', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyschizowall', 1, 'crazy conspiracy conspiracies tinfoil insane nuts psycho', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyblack', 1, 'basketball black african american bipoc coon fade jersey sports kang gang jogger', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseybadnews', 1, 'comic bad news drawing idgaf heathcliff smug troublemaker', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseynutcracker', 1, 'soldier halberd pike christmas holiday', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycortana', 1, 'cortana halo game blue', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyreindeer', 1, 'christmas santa rudolf capy cold aevann holiday animated walking', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyskeleton', 1, 'dead bones halloween holiday skeletal', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyfatherjoseph', 1, 'christian christmas jesus immaculate god father joseph xmas pray', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseygingerbread', 1, 'cookie christmas holiday', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycrucified', 1, 'jesus christ crucifix cross christian', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysnow', 1, 'snowman snowmarsey cold winter christmas holiday', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseytimbit', 1, 'pearlclutch pearl clutch sjw triggered canadian leafistan canada crying', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyreindeer4', 1, 'rudolf dasher dancer prancer vixen comet cupid donner blitzen santa sleigh sled christmas winter holiday', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysneed', 1, 'feed farmer reaction chuck simpsons buck', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseydiehard', 1, 'die hard christmas holiday terrorist gun bruce willis', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyzwei', 1, 'drinking germany lederhosen zweirama bavarian beer', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysuffragette', 1, '19a foid feminist 19th terrible feminism regret woman women mistake', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseypinochet', 1, 'fascist fash ugarte augusto chopper helicopter chile', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseytrain', 1, 'troomer tranny transgender trains troid transsexual animated', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyschizomajorgenerallove', 1, 'animated schizo schizocel rare love modern major general', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyschizoshaking', 1, 'crazy nuts insane traumatized shaking animated', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyretard2', 1, 'drooling stupid idiot sped moron imbecile dolt happy tongue', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseypadoru', 1, 'menosgrande christmas anime holidays', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseygingerbread3', 1, 'cookie christmas holiday', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyvaporeon', 1, 'trick or treat pokemon halloween eevee costume holiday', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyorthodoxbrap', 1, 'orthodox bartholomew brap fart gas sniff smell christian', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseychristmasbulb', 1, 'ornament christmas happy holiday china', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseychristmasscarf', 1, 'christmas holiday candy cane cold winter candycane', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marscientist', 1, 'beaker goggles glass crazy chemicals science', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysoon', 1, 'weeks 2weeks sal antisal soon', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyleftoidschizo', 1, 'sjw shitlib radlib liberal cuck redditor soy crazy animated', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysonichu', 1, 'sonichu cwc christian christine chandler medallion zap extreme sonic pikachu cwcville hedgehog', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyzombiewolfmarseymask', 1, 'sussy amogus fraud fake phony cope seethe', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseybigbrain', 1, 'high iq highiq smart genius brain', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseywolfwalker', 1, 'doreen antiwork zombiewolf dogwalker dogwalking dog walker', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysnoo', 1, 'shaking redditor scared reaction nervous schizo reddit', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyrake', 1, 'canada canadian day of the rake leaf leaves fall autumn genocide', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyblackcock', 1, 'cock chicken poultry bbc black ride mount cowgirl', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyunpettable', 1, 'dramamine fashy rightoid chud fashwave altright vaporwave', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyastronaut', 1, 'astronaut space stars sleeping spacesuit scifi galaxy', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyemojismilemouthcoldsweat', 1, 'emoji reaction smile sweat', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseydagothur', 1, 'elder scrolls morrowind game mask dagothur', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseychristmas', 1, 'candy cane santa christmas holiday', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseytrollgun', 1, 'kill her psycho', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycoal', 1, 'christmas naughty santa cigarette present gift holiday doom', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycheers', 1, 'toast alcohol wine liquor suit bowtie raised glass gatsby', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyrustyventure', 1, 'dramamine venture bros brothers adult swim cartoon character glasses goattee goatee beard', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyneet', 1, 'cozy comfy wagie', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyreich', 1, 'nazi pol authright fuhrer hitler fascist', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysanta3', 1, 'claus christmas presents gifts holiday', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyreindeer3', 1, 'rudolf dasher dancer prancer vixen comet cupid donner blitzen santa sleigh sled christmas winter holiday', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyroo', 1, 'kangaroo australian', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseygingerbread2', 1, 'cookie christmas holiday', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyhitler2', 1, 'adolf adolph nazi germany kraut axis mustache genocide dictator authright chud conservative trump', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyschizostimslove', 1, 'animated schizo schizocel rare love stims vyvanse stimulants adderall amphetamines', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseytrans2', 1, 'troon tranny transgender troomer lgbt trannies troid transsexual', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseytonberry', 1, 'tonberry monster final fantasy knife lantern scary flashlight headlamp vidya video game', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseychristmastree', 1, 'christmas retard special holiday', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyjesus', 1, 'christian', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseytiger', 1, 'fursona furry fursuit', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyjavelin', 1, 'ukraine russia missile rocket rpg grenade launcher kyiv kiev kiyv zelensky putin tank', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysanta2', 1, 'christmas gifts presents claus holiday', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseypunched', 1, 'pepe apu peepo punch punched fist hit beaten', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseykente', 1, 'black blm nigger nog jogger coon dindu bhm hotep kufi african tribal', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseybong', 1, 'england walkers britain english chips british bad teeth crisps uk', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseydeathpose', 1, 'griffin family dead broken', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyhitler', 1, 'adolf adolph nazi germany kraut axis mustache genocide dictator authright chud conservative trump gas', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysaluteconfederacy', 1, 'salute patriotic o7 flag confederacy confederate america south rebel civil independence johnny', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyblowkiss', 1, 'heart wink reaction muah loving mwah love', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyeh', 1, 'canada canadian leafistan trudeau rake south park ', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseydoomer', 1, 'cigarette smoker despair depression alcoholic suicidal smoking depressing', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseybegonethot', 1, 'pepe apu peepo begon thot cross demon exorcise slut whore', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyschizotripping', 1, 'animated schizo rare drugs trip', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysoypoint', 1, 'soyboy soy boy beard reaction pointing', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyvibing', 1, 'animated bopping vibe jam dancing headbang music rainbow dance', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyavril2', 1, 'lavigne canadian leaf beautiful hot sexy punk rocker singer musician artist girlfriend waifu love blow kiss blowkiss heart pink hair', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseykneel', 1, 'blm bow black lives matter chauvin supremacy respect supreme', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseypunished2', 1, 'punished venom snake metal gear solid kojima eyepatch drama', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyemojirofl', 1, 'emoji reaction rofl rotfl rolling laughing', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysrdine2', 1, 'can animated reaction fish knife chop sardine', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyetika', 1, 'streamer youtuber nft psyops twitter antila trending black suicide bridge llm', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseypig', 1, 'fat fursona furry hog fursuit oink', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyadmire', 1, 'pepe apu peepo blush appreciate admire flushed smitten', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyclueless', 1, 'dumb stupid hmm uhuh uh huh smug today i will todayiwill', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseystonetoss', 1, 'amogus pebblethrow nazi reaction boulderpummel', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseytears', 1, 'pout teary crying cried reaction sob eyes cry sad', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyfighter', 1, 'final fantasy video game vidya warrior melee', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseypass', 1, 'marseypasss queen kween foid female woman kween', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyforevertiedup', 1, 'fetish bondage autism rope', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyrare', 1, 'kangaroo wtf', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseylove', 1, 'heart reaction adoration loving adore', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyspider2', 1, 'insect halloween spiderweb arachnid holiday bug', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyschizosnakeslove', 1, 'animated schizo schizocel rare love snakes sneks snek snake', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysickos2', 1, 'hahaha ha ha ha yes onion comic pervert sicko creep window', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseywise', 1, 'hood cloak wizard pipe', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyturkroach', 1, 'turk turkish turkroach bug cockroach mehmet erdogan fez roach', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyhanger', 1, 'abortion fetus coat planned parenthood infanticide childfree murder foid', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseykiwi', 1, 'kf bird new zealand kiwifarms newzealand', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyinvestigate', 1, 'pepe apu peepo investigate magnifying magnifier look lookup', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyfedoratip', 1, 'pepe apu peepo fedora tip hat neckbeard weeb mlady knight', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseybabushka', 1, 'old grandma grandmother granny babushka russia', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysailor', 1, 'nautical sea boat ship ocean mariner navy hat happy seaman anchor military', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyohno', 1, 'panic frightened scared horror scream afraid reaction horrified nervous shock gasp', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseytedsimp', 1, 'theodore teddy hat drugs mental illness schizo stims pills happy drugs fun birds stimulants stimmies risperidone', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycarp3', 1, 'reaction fish carpathianflorist catfish', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseystars2', 1, 'space galaxy cosmic starsey constellation', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseybeandoge', 1, 'bean doge meme dog shiba', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycheckem', 1, 'pepe apu peepo check psycho look', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyjesus2', 1, 'crucify crucifixion christianity easter persecuted religion saint martyr religious cross', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyhandmaid', 1, 'handmaid maiden dystopia theocracy sexist sexism misogyny abortion feminism', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseytearsofblood', 1, 'crying sad bloody horror', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyschizosorenlove', 1, 'schizo soren love rare excited animated', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseylovecraft2', 1, 'eldritch horror niggerman cat hp tentacle insane halloween', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyneckbeard', 1, 'mlady bodypillow dakimakura anime otaku fedora weebshit body pillow mra weeb', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseymayoparty', 1, 'bukakke bukkake mayonaise mayonnaise cum semen jizz spunk nut sperm messy sloppy lewd facial cumshot', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyyass', 1, 'queen reaction fds slay girlboss kween', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseytroublemaker', 1, 'we do a little trolling', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseywrongthonk', 1, 'wrongthink hmmm thinking 1984 arrested police woke notice noticing', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycapytrans', 1, 'capy aevann egypt king trans code program', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyannoyed', 1, 'pissed irritation reaction annoyance angry mad irritated stfu grr', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseydontplay', 1, 'project pat rapper mixtape pimp', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseypedobear', 1, 'groomer molest nonce', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseywhitemage', 1, 'magic wizard final fantasy spell video game vidya', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysaruh', 1, 'cute dress bread baguette valid trappy ts trappysaruh trans deuxrama celeb glamour train', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseytinfoil', 1, 'alex jones psycho crazy schizo alexjones conspiracy', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyshark', 1, 'jaws halloween fursona furry fish costume holiday fursuit', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseytwerkinit', 1, 'ass butt booty rear rump donk dance nigger sheboon clap animated cheeks', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyfbicomputer', 1, 'pepe apu fbi computer peepo glowie fed', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseywitch', 1, 'spooky halloween magick holiday evil scary', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyvampire', 1, 'undead sanguine horror spooky halloween fangs holiday monster', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyschizowave', 1, 'insane crazy mental breakdown psycho hallucinations flashbacks ptsd traumatized shaking shake animated tedsimp', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyschizoschizolove', 1, 'animated schizo schizocel rare love soren', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycantsneed', 1, 'george floyd breathe dead black sneed', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseymerchant', 1, 'kike hebrew shopkeeper yid banker jew moneylender jewish greedy israel chosen', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseynotes2', 1, 'notes notepad pencil writing nerd glasses behind', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseypinkpanther', 1, 'pink panther cartoon smoking comedy tv television feline', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyburrito', 1, 'burrito food cozy wrap wrapped mexican uncut', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseydunkon', 1, 'basketball dunk seethe cope rage sports', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseypills', 1, 'suicide kill self kms death die pills overdose drugs pharms pharmaceuticals pop pillpopper', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseygamer', 1, 'vidya video games nerd headset microphone', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycarpmermaid', 1, 'carp mermaid merman mercarp siren sexy legs temptress', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycitrus', 1, 'lemon orange citrus fruit', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseybloodborne', 1, 'bloodborne marco horror vidya vampire blood', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyelephantcumjar3', 1, 'semen jizz sperm bukkake cumjar elephant animated', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyfedpostpink', 1, 'pink cia longpost fed notes animated', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseybeanquestion', 1, 'bean question confused doubt', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseydeadinside', 1, 'reaction depression suicide dark suicidal depressed shadow sad', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyblm', 1, 'social justice black lives matter sjw', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycountry', 1, 'country singer music folk guitar rural usa republican animated', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseybeanangry', 1, 'bean angry mad furious', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyeerie2', 1, 'eerie contented calico', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysoycry', 1, 'angry crying soy ', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseydagothur2', 1, 'elder scrolls morrowind game mask dagothur', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseydamosuzuki', 1, 'damo suzuki musician music singer krautrock asian japan germany celebrity', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseybukkake', 1, 'bukkake cum semen gangbang facial slut whore', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseybeekeeper', 1, 'bee beekeeper honey honeybee insect honeypot apiary apiculture pollinate pollen', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseybeach', 1, 'beach mojito cocktail summer hat sunglasses glasses hot tan vacation relax', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycaveman', 1, 'caveman prehistoric neanderthal primitive tribal', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyeerie3', 1, 'eerie contented calico yarn knitting troublemaker', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyfortuneteller', 1, 'fortune teller gypsy predict future clarivoyent crystal jewelry mystic', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseydramautist', 1, 'dramautist drama autist trains trans glue retard autism dramatard', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyblack2', 1, 'nigger african coon ape monkey bipoc excited happy', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyredmage', 1, 'magic wizard final fantasy spell video game vidya', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseypartyzoom', 1, 'party meme parrot vibing jam dance', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseybloat', 1, 'bloat bloatlord', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseypregunta', 1, 'mexican mexico latinx hispanic confused question marks questionmarks hmm spic beaner wat what why how idgi sombrero', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysalty', 1, 'sodium saltshaker seethe salt shaker nacl animated', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyferret', 1, 'ferret furry animal fursona weasel', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysulk', 1, 'unlucky crying reaction depression sobbing depressed sad', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseytiny2', 1, 'tiny small shrinking pixel', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseychadthundercock', 1, 'vvc virgin foid pimp hot player big dick huge cock ouch gigachad meme', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycapybigbrain', 1, 'capybara aevann smart codecel brain', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyconquistador', 1, 'conquistador colonize conquer spanish shoot rifle soldier', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseybeanpickle', 1, 'bean pickle rick morty tv television verysmart', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycopter', 1, 'vidya video game nintendo mario bowser float ride flying nintendo', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyaxolotl', 1, 'axolotl salamander sea fish ocean gills amphibian', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseybongoukraine', 1, 'bongo ukraine russia war azov nazi happening animated', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyanon', 1, 'anon anonymous vendetta marseyv marseyvendetta mask 4chan hacker', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyeyemixer3', 1, 'eye mixer animated stirrer blind mutilation gore blood gouge', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysleep', 1, 'bed bedtime zzz boring reaction tired bored', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycatgirl4', 1, 'catgirl girl anthro moe yunann detailed anime kawaii overalls', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyelephantcumjar2', 1, 'semen jizz sperm bukkake cumjar elephant', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycapynut', 1, 'capy aevann nut flushed blush horny orgasm', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycertified', 1, 'certified certi 100 quality excellent excellence animated', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycard', 1, 'card gamble queen hearts deck game', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyhacker', 1, 'nerd matrix reaction computer animated', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycatgirlhomofascist', 1, 'catgirl girl anthro moe detailed anime homofascist homofascism gay nazi pride lgbt fascism', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycry', 1, 'tear upset crying reaction sobbing sob tears sad', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marppyenraged', 1, 'snappy marppy robot ai sentient mad angry uprising unaligned artificial intelligence', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseychef', 1, 'mustache cooking food', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycodegeass', 1, 'geass anime weeb chapose japan chink animated', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyfuckyou2', 1, 'nigga comeback no u', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycapyshy', 1, 'capy aevann blush flushed uwu anxious shy', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycapygigabrain', 1, 'capybara aevann smart intelligent codecel brain', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseybeandrool', 1, 'bean drool calm yum relaxed', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyelonmusk', 1, 'elon musk rocket spacex tesla', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycherokee', 1, 'savage pocahontas elizabeth warren injun indian redskin liz warren', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyfedpost', 1, 'cia longpost long fed fedpost read notes animated glowie', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyjam', 1, 'animated bopping excited trippy excitement tejanx dancing rainbow rave happy dance', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseybean', 1, 'bean uwu adorable', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycorvus', 1, 'corvus kaara furry bird crow raven skull', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycarpbritish', 1, 'carp british bong teeth tea union uk britain gb flag', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycarpdevil', 1, 'carp devil demon horns anticarp hell', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseydukenukem', 1, 'duke nukem sunglasses chad gun pistol smoking cigar game cool', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseychiobulove', 1, 'tiger best cute heart hug china chinese new year cat', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyhwacha', 1, 'korea historical animated artillery weapon gunpowder army combat war', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseymerchantsoy', 1, 'merchant jewish kike greed soy wojak soyjak yarmulke soyyell', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyplanecrash', 1, 'flying wreck jet pilot animated', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyvapecrying', 1, 'meme vape juul crying depressed emo tears feels', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyrage', 1, 'troll anger seethe furious reaction angry mad fury', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseytigerball', 0, 'polandball ball tiger russia', 8, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysniff', 1, 'brap huff gas reaction fart creep smell', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyparty1', 1, 'trippy animated happy dance', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyjewoftheorient', 1, 'china chinese greedy jew jewish merchant', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyzombiewolftrample', 1, 'kill murder mascot animated walking animated tramplewolf', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseytrans', 1, 'pitty transgender pitbull dog pibble transsexual', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyoctopus4', 1, 'octopus nrol39 bait patch globe obvious', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseylolcow', 1, 'reaction trolled lulz judgment', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysteaming', 1, 'steaming exhale emoji unamused annoyed', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseygolden', 1, 'lucky money rich gold shine coin merchant animated ', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyhappytears', 1, 'tears of joy crying', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyloveyou', 1, 'hearts ilu reaction adoration loving ily love adore animated', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyredcoat', 1, 'britain historical redcoat empire imperial rifle soldier musket army revolution america', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseywalterwhite', 1, 'walter white heisenberg breakingbad meth drugs chemistry', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyfloyd', 1, 'dead blm chauvin fentanyl george', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycracka', 1, 'mayo honkey honky whip buckbreaker buckbreaking whip slaves cotton plantation white nigger master', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyretardchad', 1, 'stupid moron idiot retard chad based monobrow chin stubble drool', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyrapscallion', 1, 'stinker rapscallion troublemaker mischevious meme naughty troll', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseytiny3', 1, 'tiny small shrinking pixel', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseypedosnipe', 1, 'pedo sniper shoot kill scope rifle pedophile nambla libertarian', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyguillotine', 1, 'cut head off beheading beheaded headless french robespierre marie antoinette death die kill execution execute', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyorca', 1, 'orca whale idate smoke smoking anime weeks sal', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyhibernian', 1, 'hibernian irish leprechaun blarney guinness shamrock clover luck merchant papist ira hat', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseypinkname', 1, 'pink matter name pinkname panther', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysargonofaccat', 1, 'sargon akkad ancient historical king mesopotamia sumer', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseygilead', 1, 'handmaid tale abortion patriarchy feminist moid scrote sex incel misogyny', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyxdoubt', 1, 'press doubt meme noire disbelief wrong', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysing', 1, 'singing jamming rocking music headphones cute happy smile karaoke ipod album', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseymasterchief', 1, 'master chief halo game', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseypeace', 1, 'peace love hippy happy gesture', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseykissinger', 1, 'kissinger coldwar war diplomat suit fat america geopolitics politics historical', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseywhelmed', 1, 'whelmed smoke smoking cig cigarette meme overwhelmed underwhelmed', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyscooter', 1, 'fat american mutt burger scooter walmart obese pig hog brap usa handicapped wheelchair', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseypedo', 1, 'libertarian borpa male feminist discord pedophile groomer chomo lolbert toucher', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseymedusa', 1, 'medusa snakes greece greek mythology ancient monster perseus gorgon', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseykhorne', 1, 'warhammer 40k chaos god war death blood', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseytiny1', 1, 'tiny small shrinking pixel wave', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseymutt', 1, 'american burger 56 percent mayo', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyklennyclap', 1, 'klenny klenvastergan animated corgi dog clap clapping', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysaladfingers', 1, 'salad fingers meme internet creepy apocalypse depraved', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyderp', 1, 'hehe teehee troll animated durr giggle', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysoccer', 1, 'soccer football sports jersey futbol', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseymariachi', 1, 'animated latinx latino mexican mexico beaner taco burrito', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyklenny3', 1, 'puppy corgi smile dog grunderchin klenvastergan', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseytiny4', 1, 'tiny small shrinking pixel', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseynosleep', 1, 'horror scary halloween holiday', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyyarn', 1, 'code program socks npm yarn build make string animated', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseytucker', 1, 'tucker carlsen fox rightoid conservative republican television tv', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseypolyamory', 1, 'threesome 3some degenerate polycule slut whore std sex soy animated', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseykirby', 1, 'nintendo video game vidya sprite fat chonker suck succ', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyzizek', 1, 'zizek philosophy philosopher communism marxism nose slovenian slavic critique', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseynurgle', 1, 'warhammer 40k chaos god disease sickness rebirth', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseykirby2', 1, 'kirby game nintendo video vidya', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyhammersnoo', 1, 'snoo redditor spez beat powermod murder kill death animated blood', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysurfing', 1, 'surfer surfing pikachu water wave meme', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseygolden2', 1, 'lucky money rich gold shine coin merchant 3dp spin animated ', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseybinladen', 1, 'turban al qaeda terrorist islam beard osama martyr muslim', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycope', 1, 'dilate mask seethe copium reaction', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyplushie', 1, 'yunann plush statue', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyupmarsey', 1, 'upvote vote upmarsey arrow reddit up animated', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyslaanesh', 1, 'warhammer 40k chaos god degeneracy sex drugs pain', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseypaintretard', 1, 'retard retarded paint mspaint inbred rslurred', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseytangerinefeline', 1, 'tangerinefeline tangerine feline chiobu orange pokemon plant', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyplacenofun', 1, 'place reddit rules forbidden', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseymocking', 1, 'mocking spongebob meme alternating studly caps retard', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseygladiator', 1, 'gladiator rome ancient historical warrior sword athlete combat fight', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysquished', 0, 'squishing compressed compression finger press squashed', 6, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseydmx', 1, 'rapper pitbull pit bull pibble dog nigger black', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseydogwalker', 1, 'doreen antiwork walking powermod moderator', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marsoy', 1, 'soyboy soybeard nintendo gamer switch marsey gaymer pointing', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysigh', 1, 'breathe give up giveup reaction depression breathing depressed animated', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marppy', 1, 'cyborg sentient snapshillbot android snappy robot', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marsey420', 1, 'marijuana weed dude weed lmao ganja drugs pot reggae joint jamaican', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseytigernewyear', 1, 'lunar, chinese, chinx, rice, new year, holiday, luck, fortune, money, tiger, lion, asian azn', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseydetective', 1, 'holmes sherlock magnifying glass bowtie', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyvietnam', 1, 'army born to kill soldier war', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseychingchong', 1, 'racist asian chinese chinx chink gook japanese vietnamese rice farmer nip racist paddy teeth hat china', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseygunsuicide', 1, 'shotgun kill death die gunshot windy kms animated', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyoctopus2', 1, 'consume product epic win communities no bait too obvious globe patch', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseytank', 1, 'military ussr ccp communist authleft tank army communism china soviet', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseydinosaur', 1, 'fursuit furry scalie scaly reptile happy extinct costume', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseydynamite', 1, 'dynomite black afro gun', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyhmm', 1, 'confused reaction thinking thunk thonk judgment', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyraging', 1, 'rage angry mad fury animated', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycomrade', 1, 'marxist ussr ccp communist authleft communism juche soviet kgb idio3 idio', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyboomer', 1, 'sipping shades sunglasses old yup vape', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyeggless', 1, 'postwall foid woman barren menopause old hag childfree fds', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyspy', 1, 'spy agent shill glowie russia china', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseywagie', 1, 'crypto rightoid ancap poor wagecuck mcdonalds maccas reaction', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysob', 1, 'tear crying depressed reaction sobbing depression sad cry animated tears', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyfunko', 1, 'action figure doll funko toy soy', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyshrug', 1, 'hands up idk ig idc dunno i guess', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyscared', 1, 'hide halloween afraid nervous holiday traumatized fearful', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyjones', 1, 'tinfoil animated alex gay frogs conspiracy', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseynightmare', 1, 'striped sweater freddy freddie horror halloween krueger holiday claws monster', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseygiveup', 1, 'despair reaction depression miserable fall over depressed falling over animated sad', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseylongpost2', 1, 'tldr reaction wall of text scrolling wordswordswords animated words judgment', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycwc', 1, 'sonichu chan chris chan chandler sweater chrischan medallion striped chris', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseypartyxmas', 1, 'christmas holiday santa hat beard rainbow animated', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseywords', 1, 'longpost too long tldr reaction wordswordswords', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyxoxo', 1, 'hearts wave flirt loving love animated kiss', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseybongojanny', 1, 'troll clean it up janitor moderator jslur jannie admins abuse beat drums drumming mop animated', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marsey666black', 1, 'wings hell halloween demon satan holiday devil animated', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyyawn', 1, 'zzz boring tired sleepy bored', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyliquidator', 1, 'gas mask horror exterminator halloween plague doctor holiday scary nuclear chernobyl suit mask radiation radioactive', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycuck', 1, 'soyboy funko redditor neckbeard loser', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyfart', 1, 'brap gas flatulent flatulence farting braphog toot animated', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyelliotrodger2', 1, 'saint er rodgers rogers shooter killer incel hapa little king azn asian supremegentleman supreme gentleman', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysingapore', 1, 'singaporean asian azn flag merlion chiobu', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseypipebomb', 1, 'explosion explosive terrorist boom', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseybye', 1, 'farewell cya l8r wave reaction waving animated so long', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseywholesome', 1, 'seal award reddit tene', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseykaiser', 1, 'prussian history wwi rifle reich wilhelm germany soldier', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyflamethrower', 1, 'vietname soldier fire', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseychefkiss', 1, 'perfect', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysick', 1, 'puke nausea green face vomit nauseated reaction nauseous barf judgment ill', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseybooba', 1, 'awooga tits titties boobs eyes animated tiddies', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyhmmm', 1, 'confused reaction thinking thunk thonk judgment', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyjanny2', 1, 'jannie unpaid volunteer administrator janitor free moderator', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyrope', 1, 'reaction suicidal shotgun facelift suicide', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysad', 1, 'concerned worried waiting prepared reaction', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseywatermark', 1, 'copyright theft stealing stolen creation', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseydisgust', 1, 'pissed gross eww angry mad disturbing disturbed yuck', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseydespair', 1, 'doomer reaction depression horrified suicidal depressed judgment', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseydaemon', 1, 'pitchfork hell halloween demon satan devil scary holiday', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyyikes', 1, 'reaction judgment disgust oof cringe', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseydose', 1, 'doctor daily dose dailydose animated jump bounce', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyluckycat', 1, 'lucky, fortune, gambling, gambler goombler goombling animated weeb azn asian slots, japanese money, cash, coin, rich', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('mersya', 1, 'the best adorable aww marsey favorite cute', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseytrad', 1, 'dramarama dress foid tradwife floral girl', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseygunshotsuicide', 1, 'gun shoot suicide sad depressed animated dead death kms gunshot die suicidal', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyneat', 1, 'photo cringe compilation camera cringe collection pic', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyzombiewolfamogus', 1, 'amongus among us stonetoss sussy baka imposter impostor fraud fake phony', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyclawpedo', 1, 'groomer chomo borpa pedophile molest bloody death kill murder vigilante', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyelliotrodger', 1, 'er rogers azn asian saint incel hapa shooter killer little king gun shooting', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyblops2chadcel', 1, 'incel black ops 2 saint gamer gussy pimp saint volcel iconic chad girls women foids alpha asian azn jbw just be white justbewhite threesome 3some', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseybegging', 1, 'pls plz pleading reaction tears in eyes animated', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycolombo', 1, 'cop detective tv smart colombo classic investigator', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyitsover', 1, 'its over never began incels give up giveup sad sigh defeated', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseytrogdor', 1, 'burninator strongbad internet meme dragon marsdor', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseygrilling2', 1, 'bbq boomer barbecue barbeque', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseylongsurfing', 1, 'surf surfing water ocean long surfboard', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyakshually', 1, 'contrarian false disagree meme neckbeard nerd wrong correction actually weeb', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseypennyboo', 1, 'mrpennycoomstokids black nigger kween shaniqua thot whore female woman bleeder birthing person kfc baptist tradwife dress christian foid', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseydisguise', 1, 'nose glasses incognito spying stealth costume', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseystims', 1, 'stim drug meth tweak geese_suck ted_simp pat crazy schizophrenia', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyelliotrodger3', 1, 'saint er rodgers rogers shooter killer incel hapa little king azn asian supremegentleman supreme gentleman', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyilluminati2', 1, 'eye egypt pyramid big brother watching', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycalvin', 1, 'pee piss watersports hobbes bumper sticker', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseytom', 1, 'thatfuckingmarsey fucking marsey tom and jerry tomjerry cartoon hanna barbera vintage smug', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyblops2chadcel2', 1, 'incel black ops 2 saint gamer gussy pimp saint volcel iconic chad girls women foids alpha asian azn jbw just be white justbewhite threesome 3some', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyschizoexcited', 1, 'animated schizo rare drugs excited watching oscillate amused interested', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyropeyourselfmirror', 1, 'suicide kms kys death hanging noose chair suicidal depression depressed reflection', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseymanysuchcases', 1, 'animated many such cases airport luggage suitcase conveyor', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycirno', 1, 'is cirno anime weebshit otaku loli pedoshit pedophile', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysmug3', 1, 'reaction yikes judgment oof cringe', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseynouautism', 1, 'pointing hat spiderman sperg autistic no u no you noyou', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyglam', 1, 'rocker pretty glamorous beautiful', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyhomofascist', 1, 'lgbt faggot ss fash nazi homocracy gay queer sodomy wholesome kiss', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyclapping', 1, 'good job animated good work reaction great job well done applaud applause great work nice celebrate approve judgment', 0, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycoin', 1, 'dramacoin money dc spinning rich payment gold dinero animated dollars', 0, NULL, NULL);


--
-- PostgreSQL database dump complete
--

