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
    author_id integer DEFAULT 1 NOT NULL,
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
    author_id integer DEFAULT 1 NOT NULL,
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

INSERT INTO public.hat_defs VALUES (1, 'Ushanka', 'The People''s Hat', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (2, 'Fur Hat', 'The first step on your path to fursuit ownership', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (3, 'Cat Ears I', 'Mew :3', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (4, 'Cat Ears II', 'Meow :3', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (5, 'Playboy Bunny', 'Will this bring daddy back?', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (6, 'Macaroni', 'Get it? Like the song lol', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (7, 'Pirate', 'BUTT pirate', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (8, 'Pirate Captain', 'Like a regular butt pirate, but for tops only', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (9, 'Dreads', 'Finally, an excuse for poor hygiene', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (10, 'The XXXTentacion', 'Pay homage to your favorite dead criminal!', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (12, 'The Elvis', 'Remember when this dude nailed a 13-year-old?', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (13, 'Gussy Hat', 'Let everyone know that you''re NOT a rapist. Honest.', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (14, 'Riveter', 'Can you do it? Really?', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (15, 'Top Hat (leprechaun)', 'LLM but Irish', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (16, 'Drinky Beer Hat', 'I actually didn''t know these were real things until I made this', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (17, 'Viking', 'Rape, pillage, never bathe. Live the dream.', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (532, 'Under His Eye', 'WATCH ANOTHER SHOW', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (22, 'Southern Gentleman', 'Slaveowner? Fried chicken chain founder? You decide!', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (23, 'Cowboy I', 'Make him wish he could quit you', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (24, 'Cowboy II', 'You''re my favorite deputy!', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (25, 'Halo', 'Dramamine criticized this one and now I''m too self-conscious about it to write a description', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (26, 'Fedora I', 'M''arsey', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (27, 'Bowler', 'Why would you need a hat to go bowling?', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (28, 'Du Rag (black)', 'Shitty bandana 1/6', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (29, 'Du Rag (red)', 'Shitty bandana 2/6', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (30, 'Du Rag (blue)', 'Shitty bandana 3/6', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (31, 'Du Rag (purple)', 'Shitty bandana 4/6', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (32, 'Du Rag (green)', 'Shitty bandana 5/6', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (33, 'Du Rag (yellow)', 'Shitty bandana 6/6', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (34, 'Ash Ketchum', 'You''re not so different, you and he', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (35, 'The Hotep', 'Traditional kangwear. POC ONLY.', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (36, 'Roman', 'Reddit delenda est', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (37, 'Confederate Soldier Cap', 'Basically the Gryffindor of American history', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (38, 'Northern Aggressor Soldier Cap', 'Slytherin irl', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (39, 'Rhodesian Light Infantry Beret', 'Rhodesians never die. Immortality guaranteed!', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (40, 'Magyar Headdress', 'Channel your inner QuadNarca and join Orban''s elite cavalry', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (41, 'The Senator Warren', 'heya heya heya heya heya heya heya heya heya heya heya', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (42, 'Please Be Patient I Have Autism', 'The OFFICIAL hat of rDrama.net', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (44, 'Watermelmet', 'Hydration and head protection all rolled into one stylish headpiece', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (45, 'Frankenstein', 'Akshually, Frankenstein was the scientist. The monster didn''t have a name.', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (46, 'The Drumpf', 'Orange hair bad', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (47, 'Tinfoil Hat', 'Keep Bill Gates'' 5G vaccine OUT of your precious brain!', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (48, 'Fez', 'Isn''t it CUTE?', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (49, 'Ching Chong', 'Me Chinese Me No Dumb Me Stick Finger In Daddy''s Bum', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (50, 'Octopus Friend', 'Awwwwwww!', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (51, 'In The Navy', 'It''s not gay', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (52, 'Seaman', 'semen lol', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (53, 'Flower Crown I', 'oh god i have to write descriptions for 15 flower crowns', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (54, 'Flower Crown II', 'A very cute flower crown', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (55, 'Flower Crown III', 'A super cute flower crown', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (56, 'Flower Crown IV', 'A really cute flower crown', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (57, 'Flower Crown V', 'The cutest flower crown?', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (58, 'Flower Crown VI', 'An extremely cute flower crown', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (59, 'Flower Crown VII', 'A flower crown that''s just so cute', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (60, 'Flower Crown VIII', 'A majorly cute flower crown', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (61, 'Flower Crown IX', 'A mega cute flower crown', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (62, 'Flower Crown X', 'An ultra cute flower crown', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (63, 'Flower Crown XI', 'Definitely the cutest flower crown', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (64, 'Flower Crown XII', 'A hella cute flower crown', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (65, 'Flower Crown XIII', 'An experimental anti-gravity cute flower crown', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (66, 'Flower Crown XIV', 'An adorably cute flower crown', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (67, 'Flower Crown XV', 'The final cute flower crown', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (68, 'Bow', 'What a cute little bow omg', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (69, 'BIPOCsmoke', 'It''s a Newport. You know it''s a Newport.', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (70, 'Gigachin', 'Aw yeah, this user definitely supports trans rights', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (71, 'Queensguard', 'A bear died for this', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (72, 'Queen Crown', 'Don''t be a drag', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (73, 'King Crown', 'King is like the n word, only racists and black people should be allowed to say it', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (74, 'Pope Hat', 'Matthew 16:18', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (75, 'Heebhead', 'Do NOT google the Lavon Affair', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (76, 'Zoomie Zoom Zoom', 'Underage user, do not interact', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (77, 'Sombrero I', 'El Autistico', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (78, 'Sombrero II', 'El Autistico Grandisimo', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (79, 'Crypto Billionaire', 'Sorry about the ice cream machine', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (80, 'Burger King Crown', 'I''m gonna say it', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (81, 'Burger King', 'You can have it your way and you still chose this', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (82, 'Wendys', 'Sassy social media intern', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (83, 'KFC', 'Popeyes is too far away', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (84, 'In-N-Out', 'Kill the commiefornian', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (85, 'Carls Jr', 'Purveyor of literally the finest food in the world', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (86, 'Whataburger', 'Texans don''t know any better', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (87, 'Five Guys', 'I love having 5 guys in my mouth', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (88, 'Taco Bell', 'Enabler of drunken mistakes', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (89, 'Marsey-In-A-Box', 'Awww you''re playing make-believe!', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (90, 'Orthodox Hood', 'User is a schismatic lunatic', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (91, 'Afro', 'Pool''s closed motherlover', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (18, 'Nonspecific Military Officer Hat', '[removed]', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (19, 'Soviet Officer I', 'OUR hat', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (408, 'Chef Hat II', 'Toque blanche', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (414, 'Trilby', '*tip*', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (419, 'Alimony Hair', 'Stay norwooding, king', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (92, 'Top Hat (black)', 'Traditional. Classy. Elegant.', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (93, 'Wizard I', 'Three decades a KHHV', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (94, 'Wizard II', 'Avada kedavra ✨', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (95, 'Witch I', 'Hex the patriarchy', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (96, 'Witch II', 'Bardfinn cosplay gear', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (97, 'Sun Hat', 'Tradwife simplicity', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (98, 'Obey Snapback', 'The timeless classic', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (99, 'Thug Life Snapback', 'User confirmed mayo', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (101, 'Make America Great Again', 'The official headgear of stochastic terrorists everywhere', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (102, 'Born To Feel', 'Do you pee standing up?', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (103, 'Fortunate Son', 'BORN TO SHIT FORCED TO WIPE', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (104, 'WWI', 'How is this supposed to offer any meaningful protection??', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (105, 'Pickelhaube', 'Inarguably the most fashionable of all contemporary military headgear ', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (106, 'Wehrmacht', 'What a cool helmet, I bet the people who wore it were real classy folks ', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (108, 'Helmet w Dog Tags', 'More like dog fags lol', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (109, 'Urban Camo Helmet', 'Man urban camo is cool', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (110, 'Nightvision Helmet', 'Four-eyed freak', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (111, 'Helmet w Mesh', 'Sexy fishnet stocking helmet', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (112, 'Tojo Helmet', 'Artifact from Weeb War II', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (113, 'Officers Cap', 'Get fragged bozo', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (114, 'Jailbird Cap', 'The apex of prison fashion. Why did we stop using this?', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (115, 'P-Hat (green)', 'Zezima fanboy', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (116, 'P-Hat (red)', 'おれはPigAmericanですおれはばか i am average american man i enjoy bad game runescape', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (117, 'P-Hat (yellow)', 'PISS HAT PISS HAT', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (118, 'P-Hat (blue)', 'Ughhhh coming up with different descriptions for RuneScape party hats', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (119, 'P-Hat (pink)', 'It''s pink.', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (120, 'P-Hat (rainbow)', 'LGBTscape 😍', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (121, 'Newsboy', 'Or newsgirl. It''s okay, the hat is actually gender-neutral.', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (122, 'Whirly Tard Hat I', 'Wouldn''t it be neat if they could make one that like uses body heat or whatever to keep the propeller in a state of constant motion', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (123, 'Dunce Cap', 'You retard. Imbecile. Utter buffoon. Oaf. Nincompoop. Idiot. Moron. CLOWN.', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (124, 'Beret', 'Literally the most basic possible hat choice. Please do better. ', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (125, 'Mario', 'BING BING WAHOO ', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (126, 'Luigi', 'LING LING LAHOO', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (127, 'Wing Cap', 'If the hat''s wings are what provide the thrust necessary for flight then how does it stay on and let YOU fly with it huh', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (128, 'Metal Mario', 'Mario hat but with yelling and lots of double bass and distorted guitars and shit heck yeah', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (129, 'Cappy', 'A sentient hat-creature that''s actually a pretty horrifying parasite if you think about it', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (130, 'Wario', 'For the fat, yellow, extremely flatulent dramautist (in loving memory of Bidpots)', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (131, 'Waluigi', 'Coming soon to Smash for sure', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (132, 'Top Hat (kek)', 'Technically a top hat, shut up', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (133, 'Top Hat (white)', 'Oh, how dignified', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (135, 'Top Hat (checkered)', 'Actually chessed, but that''s not really a word.', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (136, 'Top Hat (march hare)', 'April hare, May hare, June hare, July hare,', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (137, 'Top Hat (mad hatter)', 'Hatters mad [x24]', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (533, 'Uncle Sam', 'The world needs our brand of democracy', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (139, 'Top Hat (uncle sam)', 'THIS HAT WAS FACT-CHECKED BY TRUE AMERICAN PATRIOTS', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (140, 'Fireperson I', 'In loving memory of r/HateForFirefighters', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (141, 'Constable', 'Useless bong cop nonsense', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (142, 'NYPD Officer', 'This user is authorized to stop, frisk and cavity search you at any time for any reason', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (143, 'Crossing Guard', 'We love Officer Marsey!', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (144, 'Paper Sailor', 'As idle as a paper ship, upon a paper ocean. Paper, paper, everywhere.', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (145, 'FBI', 'Federal Bussy Inspector', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (146, 'CIA', 'Cisgender Incineration Agency', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (147, 'ATF', 'Ass-Tickling Faggot. HIDE YOUR DOG!', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (148, 'Graduate', 'This hat signifies that the bearer has completed four (4) years of pan-african gender studies coursework', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (149, 'Nurse', 'Minor TikTok celebrity, OnlyFans top 91%', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (150, 'Farmer', 'Feed & Seed shopper', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (151, 'Farmette', 'Feed & Seed shoppette', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (152, 'Kung Lao', 'Why did I make a Kung Lao hat', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (153, 'Top Hat (steampunk)', 'Like a regular top hat but with goggles and gears', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (154, 'Brain Hat', 'Peter Griffin''s dog', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (155, 'The TED_SIMP', 'Wear this hat to express your undying adoration for carp', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (156, 'The Brandon', 'Listen here fat', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (158, 'The King George', 'Proto-drag if you think about it', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (159, 'The Mao', 'Our hair!', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (160, 'The Young Stalin', 'Pockmarks not included', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (161, 'The Ripe Stalin', 'An homage to the #1 most prolific killer of commies in world history', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (162, 'The Austrian Painter', 'For aficionados of mid-20th century fine artists slash authors', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (164, 'Modern Major General', 'For my military knowledge, though I''m plucky and adventury / Has only been brought down to the beginning of the century / But still, in matters vegetable, animal, and mineral / I am the very model of a modern Major-General', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (165, 'Red Star Cap', 'Cannon fodder', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (166, 'Cartman', 'Fat antisemite - the archetypal rDrama user', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (167, 'Cheesehead', 'For fans of the Green Gay Fudge Packers', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (168, 'Kyle', 'ngl I don''t watch South Park so idk the difference between this and Stan', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (169, 'Stan', 'ngl I don''t watch South Park so idk the difference between this and Kyle', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (170, 'Kenny II', 'Like Kenny I except it shows more of your ugly face', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (171, 'The Cleopatra', 'Did you know she was actually white?', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (172, 'Pimp Hat I', 'Women are objects', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (138, 'Top Hat (red)', 'Top hat, menstrual edition', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (157, 'The Brandon II', 'LISTEN HERE FAT', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (100, 'Supreme Snapback', 'Drip so hard omg', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (107, 'Chair Force', 'Yeah I''m a combat veteran, I''ve seen shit you wouldn''t believe. One time the wifi was out for almost an hour. ', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (173, 'Devil Horns', 'Satan is so cool and quirky!!!', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (174, 'Nooticer', 'THIS USER IS ENGAGED IN THOUGHTCRIME. DO NOT INTERACT.', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (175, 'Airpods', 'oh god oh fuck he cant hear us', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (176, 'Maskmaxxer', 'Why aren''t there two? Are you trying to kill us?', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (177, 'The Tupac', 'dead nigger storage', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (178, 'Media Executive', 'despite making up just 2% of the population,', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (179, 'Surgeon', 'Lobotomize me daddy', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (180, 'Mouseketeer', 'please don''t sue please don''t sue please don''t sue please don''t sue please don''t sue', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (181, 'Karen', 'Let me speak to your manager', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (182, 'Badass Fighter Ace', ' Top Gun™ Maverick® Now Showing In Theaters!', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (183, 'Taqiyah', 'It''s not a yarmulke I swear', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (184, 'Cock', 'DM me yours!', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (185, 'Nervous, Sweating', '>mfw', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (186, 'The Cat', 'does this really need a description', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (187, 'Noose', 'Cope or rope', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (188, 'The Penny', 'This shower cap bonnet is perfect for hiding nappy, alopecia-ridden hair', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (189, 'Hard Hat (yellow)', 'A rock hard, throbbing, veiny hat. Check out the girth on this thing', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (190, 'Hard Hat (white)', 'The mayo variant of the hard hat, used to signify someone of importance, or a visitor, at a job site', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (191, 'Beret (TF2)', 'Stylish vidya-variant of the beret', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (192, 'Texas Ten Gallon', 'Yeehaw!', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (193, 'Demoman', 'KaBOOM', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (194, 'Fireperson II', 'For extinguishing hot threads', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (195, 'Miners Hat', 'Please don''t touch minors', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (196, 'Old Man Hat', 'AKA the Wizdumb', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (197, 'Pimp Hat II', 'Women are people and they deserve respect just kidding they should suck my penis', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (198, 'Whirly Tard Hat II', 'Propeller go brrrrrrrrrr', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (199, 'Family Man Free Hat', 'It''s a good show!', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (200, 'Engineer', 'Choo choo!', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (201, 'Vexillaurius Helmet', 'Degenerates like you belong on rDrama', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (202, 'Astronaut Helmet', 'See you, space marsey', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (676, 'Kepi', 'Army cap for those unlucky enough to be French', NULL, 500, NULL, 1663303083);
INSERT INTO public.hat_defs VALUES (134, 'Top Hat (striped)', 'Tim Burton''s take on the top hat', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (11, 'The 6ix9ine', 'The finest piece of snitch couture on the market', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (534, 'Para Para Sakura', 'セックスする!', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (678, 'Turkroach', 'Come on Carp this one''s hilarious. It''s semi transparent to clarify', NULL, 500, NULL, 1663305640);
INSERT INTO public.hat_defs VALUES (679, 'Judge Dredd', 'THIS USER IS THE LAW', NULL, 500, NULL, 1663309533);
INSERT INTO public.hat_defs VALUES (680, 'Hat Stack', 'You are as presumptuous as you are poor and Irish. Challenge not the majesty of my tower of hats.', NULL, 500, NULL, 1663310312);
INSERT INTO public.hat_defs VALUES (681, 'Avatar State', 'But when the world needed him most, the Dramatar vanished', NULL, 500, 3370, 1663357705);
INSERT INTO public.hat_defs VALUES (682, 'Vampire Mask', 'Totally a current member of House Vampire', NULL, 500, 3370, 1663368597);
INSERT INTO public.hat_defs VALUES (683, 'True Capitalist', 'This user is a melting pot of friendship. And a brony.', NULL, 500, 768, 1663378533);
INSERT INTO public.hat_defs VALUES (684, 'cans dot wav', 'I am your host, the man they call Ghost.', NULL, 500, 768, 1663378616);
INSERT INTO public.hat_defs VALUES (685, 'MasterLawlz', 'Ben 10 aficionado and connoisseur.', NULL, 500, 2370, 1663400628);
INSERT INTO public.hat_defs VALUES (686, 'Pingas', '"Snooping as usual, I see!"', NULL, 500, 2370, 1663400760);
INSERT INTO public.hat_defs VALUES (687, 'Robbie Rotten', 'Number one hairstyle!', NULL, 500, 2370, 1663400876);
INSERT INTO public.hat_defs VALUES (259, 'Marsey Headbang', 'She''s banging on your head lmao get it', NULL, 1000, NULL, NULL);
INSERT INTO public.hat_defs VALUES (688, 'Stephanie', 'I am not a creep. It was the third image result when I googled "Robbie Rotten hair png"', NULL, 500, 2370, 1663400979);
INSERT INTO public.hat_defs VALUES (689, 'Sportacus', 'Unofficial mascot of /r/fatpeoplehate', NULL, 500, 2370, 1663401163);
INSERT INTO public.hat_defs VALUES (258, 'Clownpaint', 'WHOOP WHOOP MATHOFACKO', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (213, 'The Penny II', 'Out of the shower :marseybath: cap, into the bandana', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (278, 'The Justinian', 'Glory to God who has thought me worthy to finish this work. Solomon, I have outdone you.', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (263, 'Colonizing Oppressor', 'Why would you ADMIT to this?', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (264, 'The TracingWoodgrains', 'Bweaking nuwus!', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (265, 'Cat Ears (devil horns)', 'Has science gone too far?', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (268, 'The TracingWoodgrains II', '*nuzzles your bulge mid-interview* OwO whats this', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (273, 'Pilot Hat', 'Daily nonstop flights to Bussyville', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (536, 'The Banzai Bandana', 'May Marsey live ten thousand years!', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (538, 'Timmy Turner', 'So you''re telling me I can wish for ANYTHING?', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (539, 'Fairly Oddparent', 'Obtuse, rubber goose, green moose, guava juice, giant snake, birthday cake, large fries, chocolate shake!', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (540, 'Oney', 'Look Tomar, it''s you.', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (541, 'Morshu', 'Lamp Oil, Rope, Bombs! You want it? It''s yours, my friend! As long as you have enough RUPEES.', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (542, 'Link (Faces of Evil)', 'Could you eat an octorok?', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (543, 'Harkinian (Faces of Evil)', 'Marsey mah boy', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (544, 'Train Conductor', 'It’s MY neurodivergence and I get to choose the special interest', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (546, 'Reimu Bow', 'Gensokyo border control', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (547, 'The Microdose', 'A smaller, safer dose for those who need to self-medicate in public.', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (548, 'The Snooplet', 'I can exercise you, this can be your phys ed, spend all your cizzoins, just perch me on your hizzead', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (550, 'The Entertainment', 'A prize for clever birthday boys that save their tokens.', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (553, 'Banana Bucket Hat', 'Peanut butter jelly time', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (552, 'Doomer Beanie', 'blackpilled again', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (554, 'Clop', 'DM me for MLP clop ERP', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (561, 'The Lawlz', 'Have Max the Dog join you on your PFP. Rest in paradise king!', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (558, 'Suicide King', 'Lost it all in the 52 cards', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (560, 'Dual-Wield Katanas', 'Forged from real Nippon steel, folded 1000 times, shipped directly to your local mall kiosk.', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (564, 'The African Kufi', 'The white man doesn''t want you to know that this website was created by an AFRICAN king', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (563, 'The Dundee', 'That''s not a hat. THIS is a hat!', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (566, 'Heart Crown (rainbow)', '❤🧡💛💚💙💜', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (565, 'Sparkles Crown', '✨✨✨', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (572, 'Heart Crown (sparkles)', '💕💛💔💗♥🖤✨💙 or something idk', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (573, 'CENSORED', '💔literally 1984 💔', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (574, 'Heart Crown (Rainbow II)', 'More gay than the other rainbow heart crown 👍', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (575, 'Heart Crown (superstraight)', '🖤🧡🖤🧡🖤🧡', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (567, 'Heart Crown (blue and purple)', '💙💜', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (568, 'Emoji Crown (hearts and shooting stars)', '💫This is techically the dizzy symbol, but it looks like a shooting star for Apple users 😘', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (576, 'Emoji Crown (sunflower honeypot)', '🌻🍯✨', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (578, 'Baddie Cap', 'All real baddies wear this hat', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (579, 'Skull Mask', '💀Stop the spread!💀', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (580, 'DUM post it note', 'For when u dum :(', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (581, 'I Pee In Pools Cap', 'Share your stance on pool urination', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (582, 'Bee Crown', 'Buzz buzz buzz', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (584, 'Flower Crown (sunflowermoji)', 'A very cute sunflower crown', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (585, 'Fire Crown', '🔥🔥🔥', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (586, 'Weeb Angry Symbol', '😠', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (587, 'Fedora (Red Hat Enterprise Linux)', 'Reminds me of 2004', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (583, 'Weird Banner', 'You may only wear this if you are weird! No appropriation by non weirdos, thx', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (588, 'Large Bow (light pink and blue)', 'It really is a very large bow', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (589, 'The Penny III', 'ALOPECIA B-GONE', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (590, 'Top Hat (rattlesnake)', 'Top hat decorated with rattlesnake', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (591, 'PLA Hat', '中国梦', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (592, 'Du Rag (flames)', 'Shitty bandana 7/6', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (593, 'Top Hat (red and black)', 'This isn''t the right hat for everyone, but is it the right hat for you?', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (594, 'Tin Foil Fedora', 'm''lady, I must warn you of the elecromagnetic mind control rays', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (595, 'The Coon', 'Davy Crockett wore it and now it’s on rDrama', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (597, 'White bow Headband', 'simplicity', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (598, 'Du Rag (black and red)', 'Shitty headband 8/6', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (599, 'Tricorn Hat (brown leather)', 'ruggedized and heavy duty tricorn hat', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (600, 'Captain America Cap', 'WOW I HECKIN LOVE SUPERERO', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (601, 'Cowboy Hat (Jewish)', 'brown leather cowboy hat with a six pointed star', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (602, 'Cowboy Hat (American)', 'Yeehaw faggot', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (603, 'Balaclava (Shark teeth)', '🦈', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (604, 'Backwards Cap', 'How do you do fellow r/teenagers', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (606, 'Fancy Hat (blue and black)', 'made with stable diffusion!', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (607, 'Cheerful colorful knit hat with flower', 'also made with stable diffusion!', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (608, 'Hat of the Future (art deco)', 'According to Stable Diffusion, this is the hat of the future. It''s also art deco, because that gave cooler results.', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (569, 'Paul', 'cringe and dramaphobic llama', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (535, 'The Soren', 'discuss', NULL, 1000, NULL, NULL);
INSERT INTO public.hat_defs VALUES (577, 'Zoomie Zoom Zoom II', 'Underage user, do not interact', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (618, 'Cuban Pete', 'Given only to the biggest space assholes.', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (619, 'Marsified', 'become the marsey', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (620, 'Glowing Pickelhaube', 'Glows in the dark, like a secret police', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (559, 'Roulette', 'Around and around it goes', NULL, 1000, NULL, NULL);
INSERT INTO public.hat_defs VALUES (551, 'Soyjak Pointing', ':O Dude dude DUDE! Look at this user :OOOOOO', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (555, 'Egg_irl', 'Ask me about my pronouns', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (280, 'Gold Laurel Wreath', 'Veni, vidi, vici', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (332, 'Hairlet', 'It never even began', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (266, 'King Crown II', 'King is our word but you can say kang', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (267, 'Furry Marsey', 'Never forget that Marsey is a furry OC and this site is themed around fanart of her', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (270, 'Perry the Platypus', 'Platybussy > Platygussy', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (271, 'Zorro', 'Z!', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (274, 'Shemagh', 'Shemagh is such an ugly word. It sounds like a phlegmy noise. Even looks like the word phlegm.', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (275, 'Bloods', 'BRIPS GET THA BLATT BLATT', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (276, 'Conscience', 'i can be yuor angle or your devil', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (269, 'SCARY GUN', 'He called it an AK-74u but I''m not sure if that''s right idk idk', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (537, 'The Celtic Kufi', 'Irish were the REAL slaves, stay woke my deartháir', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (549, 'The Bumper Sticker', 'Turn yourself into a legal liability that could threaten the very site itself!', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (571, 'Purple Emoji Crown', '💜💜💜when ur selfie needs an emoji crown with a 🌻, a 👻, and a 🐻 but u still gotta fit that purple aesthetic 💜💜💜', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (570, 'Carl', 'based and dramapilled llama', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (531, 'Zen', 'follow the fish follow the fish follow the fish follow the fish follow the fish', NULL, 1000, NULL, NULL);
INSERT INTO public.hat_defs VALUES (612, 'Wizard Hat (pixel)', 'Some sort of vidya thing idfk', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (614, 'Chickenhead', '🤗', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (621, 'The Soren II', 'Soren is an idea, not a person. Shoot him. It’s okay, the bullets do nothing. Try it!', NULL, 1000, NULL, NULL);
INSERT INTO public.hat_defs VALUES (279, 'Libertarian', 'This user has certainly read Atlas Shrugged', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (282, 'Green Laurel Wreath', 'Render unto Caesar the things which belong to Caesar', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (557, 'Cottagecore', 'Show your solidarity with men-who-have-sex-with-men by giving them a safe, public space to do whatever it is they''re doing back there.', NULL, 1000, NULL, NULL);
INSERT INTO public.hat_defs VALUES (622, 'Colonial Chapeau', 'Whatever happens/we have got/the Maxim gun/and they have not', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (624, 'Metal Gear', 'Detected!', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (291, 'Yea Daddy Choker', 'Remember who you belong to', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (296, 'Sunhat II', 'Yellow to camouflage you from the sun, cunningly making it believe you are one of its own kind. And then you strike.', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (298, 'Flower Bonnet', 'An indescribably cute flower cro- bonnet.', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (299, 'Raspberry Hat', 'Little sissy French girl hat', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (300, 'Lemonsqueezer', 'Iconic kiwi headwear with a very stupid name', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (301, 'Dickhead', 'Really proud of the name for this one. Well done, me!', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (627, 'Pedo Sniper (right)', 'I''m not which is worse - being a pedo, or being left handed?', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (628, 'Gnome Child', 'My mum says: A friendly look, a kindly smile one good act, and life''s worthwhile!', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (308, 'Pothead', 'Cali-grown cast iron goodness', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (631, 'Country Club Visor', 'What country club members wear when discussing your reddit account', NULL, 500, NULL, 1663033011);
INSERT INTO public.hat_defs VALUES (311, 'The Lucas Roberts', '#DropKiwiFarms #MandatoryHRTForAllKids', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (632, 'Jotaro Hat', 'The iconic cap of a buff punchy weebshit guy', NULL, 500, NULL, 1663033206);
INSERT INTO public.hat_defs VALUES (317, 'AI-Generated Hat', 'Stable Diffusion recommended a 10k price point for this 🤔', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (318, 'Headphones (black)', 'Situational awareness: 0', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (320, 'Summer Hat', '[incoherent Hawaiian gibbering]', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (321, 'Attention Whore', 'DUDE BUSSY LMAO MARSEY HECKIN VALIDERINO AMIRITE BTW I AM TRANS', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (322, 'Pirate Hat II', 'Swab the POOP deck with your TONGUE', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (323, 'Mafioso', 'Something something gabagool 🤌', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (325, 'The Sal', 'Watch me go nowhere in two weeks (I AM SO DEPRESSED)', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (629, 'Marisas Big Witch Hat', 'Fascism is when witches wear big hats, the bigger the hat the more fascist you are.', NULL, 500, NULL, 1663010108);
INSERT INTO public.hat_defs VALUES (328, 'Skidmarks', 'Hit me with your car daddy 🤪', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (329, 'Behind Bars', 'Uh oh, someone forgot to say In Minecraft', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (330, 'Panzer Driver', 'No war crimes here, just tanks!', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (331, 'Ghostly Gibus', '(achievement item: not tradable or marketable)', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (333, 'Astronaut Helmet II', 'Used for intrepid explorers of Hollywood basements', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (335, 'Kippah', 'rDrama: a light unto nations', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (337, 'The Tim Pool', 'No one can make fun of you for being bald if you never ever ever ever take it off', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (338, 'Digigoggles', 'DIGIMON. DIGITAL MONSTERS. DIGIMON ARE THE CHAMPIONS.', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (339, 'Sorting Hat', 'HUFFLEPUFF!', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (340, 'Metroid', 'Some sort of alien parasite thing I think. It wants a kiss.', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (341, 'The One Hat', 'One hat to rule them all', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (342, 'Kawaii Usage Hat', 'Bunny bunny bunny bunny bunny bunny bunny bunny bunny bunny bunny bunny', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (343, 'Shroomjak (red)', '🍄🍄🍄🍄🍄🍄🍄🍄', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (20, 'Nonspecific Military Officer Hat II', '[removed]', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (21, 'Soviet Officer II', 'High fashion war criminal chic', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (212, 'Sneed', 'From the business formerly known as Chuck''s Seeduck and Feeduck', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (214, 'Hijab', 'The ONLY way to stop being a whore', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (215, 'Cock II', 'Honk honk', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (216, 'Cummies', 'Yummy yummy cummies in my tummy tummies', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (211, 'Zombiewolf Helmet', 'Everyone knows it''s rDrama''s true mascot', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (633, 'Man, I Love Fishing', 'post-wall appreciator', NULL, 500, NULL, 1663043038);
INSERT INTO public.hat_defs VALUES (218, 'Clown Wig', 'Why so serious?', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (219, 'Jimmy Hat', 'Don''t be silly, wrap your willy!', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (220, 'Bane Mask', 'If I pull that off, will you die?', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (221, 'Wolf Ears I', 'OwO what''s this?', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (222, 'Smugjak', 'I''m drunk and can''t think of a good description lol', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (223, 'Foolproof Disguise', 'What''s that, officer? You''re looking for [USERNAME GOES HERE CARP CAN''T CODE]? Never heard of him!', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (224, 'Brain Slug', 'This poor brain slug is STARVING TO DEATH :(', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (272, 'Harry Potter', 'General in the Mages vs. Matriarchy war', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (324, 'Lord of the Flies', 'Sucks to yer ass-mar!', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (314, 'Bright Idea II', 'Guys. GUYS. Bait sub idea: r/HateForGoodThing', NULL, 1000, NULL, NULL);
INSERT INTO public.hat_defs VALUES (316, 'Globohomo', 'The gay agenda is no longer optional.', NULL, 1000, NULL, NULL);
INSERT INTO public.hat_defs VALUES (313, 'Bright Idea I', 'Guys. GUYS. BAIT SUB IDEA: r/LoveForBadThing', NULL, 1000, NULL, NULL);
INSERT INTO public.hat_defs VALUES (225, 'Pat Hat', 'Who''s Daddy;s special little boy?', NULL, 1000, NULL, NULL);
INSERT INTO public.hat_defs VALUES (277, 'Cool Wine Aunt', 'It''s pruno, don''t pretend you''re fancy', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (284, 'The Gary Plauche', 'We can''t expect God to do all the work', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (292, 'Marsey Smug Mask', 'I''m not seething, you''re seething', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (295, 'Pinkhat', 'It''s a hat and it''s pink and your nan looks adorable in it. Not you, though.', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (310, 'Bandit Bandana', 'This thread ain''t big enough fer the  of us', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (327, 'Ageplayer', 'It''s cool if it''s not your thing, just don''t yuck someone else''s yum :)', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (312, 'Super Saiyan', 'Taqueria ‘Goku''', NULL, 1000, NULL, NULL);
INSERT INTO public.hat_defs VALUES (635, 'Gagged n Blinded', 'Ask me about my sex swing', NULL, 500, NULL, 1663049833);
INSERT INTO public.hat_defs VALUES (634, 'Roxy Hair', 'Dommy mommy animatronic wolf', NULL, 500, NULL, 1663043599);
INSERT INTO public.hat_defs VALUES (638, 'Chen', 'HONKS VIOLENLTY', NULL, 500, NULL, 1663100660);
INSERT INTO public.hat_defs VALUES (636, 'Senjutsu', 'HAAAAAAAAVE YOU SEEN THE WRITING ON THE WALL?', NULL, 500, NULL, 1663094125);
INSERT INTO public.hat_defs VALUES (640, 'Bored Ape', 'DO NOT RIGHT CLICK!', NULL, 500, NULL, 1663105351);
INSERT INTO public.hat_defs VALUES (641, 'MUSHROOM CLOUD', 'The Samson Option has been invoked.', NULL, 1000, NULL, 1663121242);
INSERT INTO public.hat_defs VALUES (643, 'Only One Large Snake Not Mating', 'Looks cute until she''s on YOUR head', NULL, 500, NULL, 1663132332);
INSERT INTO public.hat_defs VALUES (644, 'Poppy', 'The TRUE rDrama mascot', NULL, 500, NULL, 1663132488);
INSERT INTO public.hat_defs VALUES (645, 'The SRDine', 'CANNED', NULL, 500, NULL, 1663132545);
INSERT INTO public.hat_defs VALUES (646, 'Turtle Helmet', 'u/awkwardtheturtle is VERY mad at you', NULL, 500, NULL, 1663132947);
INSERT INTO public.hat_defs VALUES (648, 'Diamond Helmet', 'So I did some mining off camera...', NULL, 500, NULL, 1663133082);
INSERT INTO public.hat_defs VALUES (226, 'Gay Saudi Headpiece', 'Saudis are all homosexuals and they use this to hide the cum in their receding hairlines', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (227, 'Snekshat', 'Snek Shat Hat', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (228, 'Pride Hat I', 'We''re here, we''re queer, get used to it!', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (229, 'Marsey Ears', '@Dramarama''s first hat and it is PERFECT', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (230, 'Halo II', 'Daddy''s lil angel 😈', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (231, 'Egg', 'Uh oh, someone''s got egg on his/her/their/xer/spiderself''s face', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (232, 'Donut', 'You ever try fucking a donut?', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (233, 'Player One', 'Mom says it''s my turn!', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (234, 'Okapi', 'Big throbbing okapi cock 🤤', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (235, 'Emo Hair I', '''''Rawr'''' means ''''I love you'''' in Dinosaur :3', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (236, 'Ram Horns', 'Not quite sure what a ram is tbh but here are its horns. Like is it a boy sheep? A goat? Some animal of its own? Who knows!', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (237, 'Bunny Ears', 'BUNNY!', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (238, 'Pinhead', 'Dirty Dan''s best friend', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (239, 'Mojo Jojo', 'I once knew a Mexican dude named Nick who pronounced Mojo Jojo as mohohoho', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (240, 'Backstabbed', 'I have information that will lead to the arrest of Hillary Rodh-- ack!', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (241, 'The Garry_Chess', 'I AM A DOCTOR I AM IMPORTANT HURRDURR', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (242, 'Aussie Hat', 'Gday, cunt', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (243, 'Night Cap', 'Imagine putting a fucking :marseytom: hat on before bed lmao', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (244, 'Anime I', 'YIKES! CRINGE!', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (245, 'The Brianna Laundrie', 'RIP Brianna and RIP r/FriendsOfBrian', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (246, 'Lains Bear Kigurumi', 'And you don''t seem to understand / A shame, you seemed an honest man', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (248, 'Furfag Pride', 'We`re here, we fuck animals get used to it.', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (249, 'why', 'BOOHOO NIGGA', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (250, 'Grass Toucher', 'Makes you immune to being told to touch grass', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (251, 'Napoleon', 'Liberté, ordre public', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (252, 'Average rDrama Hat Designer', 'USE THE FUCKING TEMPLATE', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (253, 'Phrygian Cap', 'Liberté, égalité, fraternité', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (254, 'Three Lil Marseys', 'It''s three Marseys. They''re little. What more do you want from me here?', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (255, 'KN95 Mask', 'We are all in this together. If you are serious about flattening the curve, you will wear this.', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (256, 'Confusion', '????????????????????????????', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (257, 'Umbreon Ears', 'For legal reasons, we cannot actually call these Umbreon Ears. Please refer to them as something else.', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (260, 'Carphead', 'A legally viable excuse to have Carp on top of you in public', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (261, 'Journoid Scum', 'The wearer of this hat was coming right for you, I saw it. The shooting was purely self-defense.', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (262, 'Delicious Feet', 'feet > bussy', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (344, 'Slava Ukraini', 'Slava Ukraini!', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (345, 'Gigachad Mask', 'Average rDrama user', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (346, 'Pumpkin Remains', 'A gory pumpkin scalp', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (347, 'Peek-A-Boo Marsey', 'AAAAHHH GET IT OFF GET IT OFF GETITOFF AAAAAAHHHHHHH', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (348, 'Hazmat Suit', 'Standard-issue PPE for wading through the cesspit that is rDrama', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (349, 'Cat Ears (wiggly)', 'MEOW MEOW MEOW MEOW MEOW MEOW MEOW', NULL, 1000, NULL, NULL);
INSERT INTO public.hat_defs VALUES (350, 'Marionette Strings', 'Dance, puppet, dance', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (351, 'PaRappa Beanie', 'This is technically a furry item fyi', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (353, 'Double Ds (hat)', 'double deez nuts lmao', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (354, 'SNIFFED', 'Extremely uncomfortable for almost everyone involved', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (356, 'Santa Hat I', 'Frozen Frozen Frozen (like ho ho ho get it), merry Fistmas!', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (357, 'Scumbag Steve', '>comes to your gay poz mixer >wears a rubber', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (358, 'Umbrella Hat', 'Covered in dirty yellow and white streaks', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (359, 'Ridin With Biden', 'You ridin''?', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (360, 'NFT', 'Right clicking is STRICTLY prohibited', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (361, 'The Bog', 'Will you take the call?', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (362, 'Googly Eyes', 'My eyes are up here', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (363, 'Kanohi Hau', 'A description was not provided but google says it''s a Bionicle thing. I think those are like Legos. Mysterious Lego mask oooooooh', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (364, 'The Yugi', 'Children''s card game world champ', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (365, 'Maid Cap', 'CLEAN IT UP MAID 🤣 FOR A RESPECTABLE WAGE 🤣🤣🤣', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (366, 'BLACKED', 'You were built for BBC', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (368, 'Wonder Tiara', '(Lynda Carter''s version, of course)', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (369, 'Fisherman Hat', 'The text is completely indecipherable at this scale. I have no idea if that makes it worthless or adds to the joke.', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (370, 'Crosshair', 'You deserve this.', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (371, 'DONT CARE DIDNT ASK YOUR WHITE', 'DONT CARE + DIDNT ASK + YOUR WHITE', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (372, 'Dragonborn', 'Dragon Shout: FEED/AND/SEED', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (373, 'Sun Hat III', 'So many sun hats to choose from, so little sun.', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (374, 'Anglerfish', 'It''s not Snoo''s scalp. Stop asking that.', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (375, 'Nun Headpiece', 'Bandeau and veil, coif not included', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (376, 'Colovian Fur Helm', 'NOT for n''wahs', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (377, 'Booze Cruise', 'Drunk driver rights are human rights', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (378, 'Son of the Mask Mask', 'Don''t ya just LOVE Homoween?', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (379, 'Bananahead', 'This shit is bananas. B-A-N-A-N-A-S', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (626, 'Pedo Sniper', 'Ready, aim...', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (381, 'Panty Raid (pink)', 'Are ya feeling it now Mr. Krabs?', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (382, 'Panty Raid (red)', 'Are ya feeling it now Mr. Krabs?', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (383, 'Panty Raid (white)', 'Are ya feeling it now Mr. Krabs?', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (384, 'Head Crab', 'It''s a crab. For your head.', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (386, 'Curts New Hat', 'Have you *seen* it?', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (387, 'Gray Cowl of Nocturnal', 'Capital!', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (388, 'Tricorne', 'This hat is for TRUE AMERICAN PATRIOTS only', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (404, 'Knight Helmet', 'kNIGht 🤗', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (352, 'John Deere Hat', 'She (male) thinks my tractor''s sexy', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (355, 'Chef Hat', 'Cloudflare just bent the knee and I''m nauseated and don''t feel like writing descriptions for hats sorry', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (392, 'Chris-Chan', 'Hat to the extreme!', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (393, 'Bunny Buttons', 'Byo requested this one but I''m honestly not even sure what it is', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (394, 'ROFLcopter', 'Lollerskates', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (395, 'Whirly Tard Hat (animated)', 'This one spins omg', NULL, 1000, NULL, NULL);
INSERT INTO public.hat_defs VALUES (412, 'The Klenny', '🤣👍', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (422, 'Booba', 'O_O', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (409, 'AI Core', 'Thought this said AL Core for a minute like Al gore but no it''s ai like the robot thing and apparently it''s from a vidya so here we go description done 🤌', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (655, 'Thigarette', 'Smokers are jokers', NULL, 1000, NULL, 1663160917);
INSERT INTO public.hat_defs VALUES (656, 'Thigarette (BIPOC)', 'Smokers are JOKERS', NULL, 1000, NULL, 1663161103);
INSERT INTO public.hat_defs VALUES (654, 'VR', 'Be honest, you bought it for porn', NULL, 500, NULL, 1663153216);
INSERT INTO public.hat_defs VALUES (642, 'Spotlight', 'Lights, Camera, Action!', NULL, 1000, NULL, 1663122185);
INSERT INTO public.hat_defs VALUES (651, 'Chainmail Helmet', 'Shameless coloniser of (((villagers)))', NULL, 500, NULL, 1663133337);
INSERT INTO public.hat_defs VALUES (653, 'Freddy Mask', '[JUMPSCARE]', NULL, 500, NULL, 1663133417);
INSERT INTO public.hat_defs VALUES (657, 'Coins', 'The Princess Is In Another Castle', NULL, 1000, NULL, 1663200349);
INSERT INTO public.hat_defs VALUES (659, 'Brain Worms', 'This explains a lot.', NULL, 500, NULL, 1663229235);
INSERT INTO public.hat_defs VALUES (674, 'Fat Rat Grab', 'He''ll cook you dinner, the useful rodent', NULL, 500, NULL, 1663295500);
INSERT INTO public.hat_defs VALUES (665, 'Diddy Kong Hat', '"He''s back again and about time too! And this time he''s in the mood! He can fly real high with his jetpack on! With his pistols out, he''s one tough Kong!"', NULL, 500, NULL, 1663279805);
INSERT INTO public.hat_defs VALUES (666, 'Gamer Hat', 'When you want everyone to know your opinions on the female gender', NULL, 500, NULL, 1663279854);
INSERT INTO public.hat_defs VALUES (670, 'Miners Helmet', 'Everybody wants to have sex with them', NULL, 500, NULL, 1663280073);
INSERT INTO public.hat_defs VALUES (671, 'The Son of Man', 'Hide your face with an apple', NULL, 500, NULL, 1663280110);
INSERT INTO public.hat_defs VALUES (396, 'Obey Snapback w Blunt', 'dude weed lmao', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (406, 'Amogus', 'I saw you vent', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (415, 'WANTED', 'Dangerous thought criminal. Wanted DEAD ONLY.', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (421, 'Emperor Hat', 'Made in China', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (424, 'Pearl Clutcher', 'REEEEEEEEEEEEEEEEE', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (667, 'The Orb', 'Ponder into one''s soul', NULL, 500, NULL, 1663279906);
INSERT INTO public.hat_defs VALUES (652, 'Leather Helmet', 'Wow, what a n00b', NULL, 500, NULL, 1663133381);
INSERT INTO public.hat_defs VALUES (669, 'Backwards cap 2', 'lookin'' cool', NULL, 500, NULL, 1663280007);
INSERT INTO public.hat_defs VALUES (663, 'Santa Hat II', '''Tis the season!', NULL, 500, NULL, 1663279621);
INSERT INTO public.hat_defs VALUES (672, 'Birthday Hat', 'Ruins every thread on October 1st (ed: what does this mean????)', NULL, 500, NULL, 1663280145);
INSERT INTO public.hat_defs VALUES (397, 'Funko Pop', '...and then he turned himself into Funko Pop. Funniest shit I ever saw.', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (398, 'The Catman', 'This counts as a fursuit', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (668, 'Maxwell Hat', 'Scribblethot', NULL, 500, NULL, 1663279953);
INSERT INTO public.hat_defs VALUES (400, 'Current Thing (support)', 'Slava Ukraini!', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (401, 'Current Thing (oppose)', 'Denazify Ukraine!', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (402, 'T-34 Tank', 'For denazification purposes', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (403, 'Weatherman', 'Glad I could help', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (405, 'Israeli Friend Pins', 'If any man shall adore the beast and his image, and receive his character in his forehead, or in his hand.', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (407, 'Top Hat (black glitter)', 'Be careful not to rub this against anything', NULL, 1000, NULL, NULL);
INSERT INTO public.hat_defs VALUES (410, 'Retro Snapchat Thot', 'Heckin good pupperino', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (411, 'The Goatse', 'Open wide!', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (418, 'Bass Pro', 'Of course I cum fast, I got fish to catch!', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (420, '2070s Hat', 'State-enforced homosexuality. Teaching JavaScript to refugees. The flyest headwear. Bring on the Paradigm Shift.', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (413, 'Retro Brimstone', 'Look man if you''re gonna submit old vidya imagery as hats I need to know what it IS so I can write descriptions', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (423, 'Dramautist Jar Project', 'Wh-what''s going on? Why am I in here?', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (416, 'Monopoly Hat', 'Do not pass Go. Do not collect 200 dramacoin.', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (417, 'Monopoly Thimble', 'Just the right size for your dick huh', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (425, 'Girlboss', '#GASLIGHT #GATEKEEP #GIRLBOSS', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (426, 'Gold Badge', 'You did so well. You deserve yourself.', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (427, 'Silver Badge', 'First loser', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (428, 'Green Badge', 'Winner of the 20XX Farmers Choice Award', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (429, 'Red Badge', 'The red badge of bussy', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (431, 'Blue Badgr', 'I blue myself', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (433, 'R2D2', '[unintelligible whirring and beeping]', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (434, 'Gay Fawkes Mask', 'Buy curtains, Buy a dog. We are legging. Accept us.', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (437, 'Cigar', 'Sometimes s cigar is just a cigar. Not this time, though. This is clearly about craving dick in your mouth.', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (438, 'Conquistador', 'Sorry, but the human sacrifice stops NOW.', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (439, 'Pumpkin', 'Spowoky Owoky Puwumpykin', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (440, 'Jester Hat (Mardi Gras)', 'YOU Tuesday', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (441, 'Jester Hat (red and blue)', 'Jingle jingle', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (442, 'Jester Hat (blue and purple)', 'Hand wash only', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (443, 'The Ricardo Milos', '✨Iconic✨', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (444, 'The Awoo', 'This is (not) Cirno', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (445, 'Krusty Krew', 'KRUSTY KRAB PIZZA. IS THE PIZZA. FOR YOU AND ME.', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (446, 'Sutton Woo Helmet', 'What a neat helmet. Why would someone leave it lying on the ground?', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (447, 'Cosmonaut Helmet', 'Yuri Gagarsey, hero of the Soviet Union!', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (448, 'The Pizzashill', 'WORDS WORDS WORDS WORDS WORDS WORDS WORDS WORDS WORDS WORDS WORDS WORDS WORDS', NULL, 1000, NULL, NULL);
INSERT INTO public.hat_defs VALUES (449, 'Handmaids Bonnet', 'Wear this to protest the ban on infanticide', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (451, 'Influencer', 'Sweet, faceless validation', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (453, 'Top Hat (fancy)', 'Shallow and pedantic, if you ask me. It insists upon itself', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (454, 'Jaguar Warrior', 'The human sacrifices will continue until morale improves', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (455, 'Marsey Brainhat', 'Just two brainlets, hanging out', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (456, 'Black Crown', 'Black crowns matter', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (458, 'Mario Raccoon', 'BING BING RACCOON', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (459, 'Eggscellent Hat', '🥚 lmao', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (367, 'Burning Flames Team Captain', 'Yeah I''m hot shit, could you tell?', NULL, 1000, NULL, NULL);
INSERT INTO public.hat_defs VALUES (460, 'Edelgard Hair', 'Please report anyone with this hat to @carpathianflorist for weeb eradication', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (380, 'Witch (Wizard) Hat', 'STOP ASKING WHY I DON''T USE MAGIC TO CHANGE MY GENDER', NULL, 1000, NULL, NULL);
INSERT INTO public.hat_defs VALUES (385, 'Magician Hat', 'It''s not just animated so we can charge more for it. Really!', NULL, 1000, NULL, NULL);
INSERT INTO public.hat_defs VALUES (389, 'BIG MAD', 'Positively seething', NULL, 1000, NULL, NULL);
INSERT INTO public.hat_defs VALUES (390, 'Nervous Sweating', 'oshit >mfw', NULL, 1000, NULL, NULL);
INSERT INTO public.hat_defs VALUES (391, 'Sparkles', '✨✨✨✨✨✨✨✨', NULL, 1000, NULL, NULL);
INSERT INTO public.hat_defs VALUES (461, 'Gothic Lolita', 'Dark and brooding. Not very brooding, actually. But dark.', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (462, 'Rasta Hat', 'Jah bless', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (463, 'Sheep Horns', 'For the horniest of sheep', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (464, 'Luffy Hat', 'Stretchy pirate weebshit guy', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (465, 'Thin Film Interference Hat', 'Like that movie with the time machine car', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (466, 'BANNED stamp', 'One time at banned stamp I', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (467, 'Minecraft', 'It is impossible to fedpost with this hat on', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (468, 'Brimless Yankee', 'The finest team of juicers money can buy', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (469, 'The Kiwi', 'Wearing this constitutes a hate crime in most developed countries', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (470, 'The Mathematician', 'Special delivery from Mr. Kac- Mr. Kaz- Mr. Kazimspy', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (471, 'Frog Hat', 'It has a cute frog on it', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (472, 'Moriya Frog Hat', 'Big googly eye froge hat', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (473, 'Warning Tape', 'This user is a walking red flag', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (474, 'The Merchant', 'What did he mean by this? 🤔', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (475, 'Stickbug', 'Lookit this lil fella go', NULL, 1000, NULL, NULL);
INSERT INTO public.hat_defs VALUES (476, 'Cos Bucket Hat', 'Bitch ima cow', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (477, 'Strawberry Hat', '🍓🍓🍓', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (478, 'Froge Beret', 'On Wednesdays we wear frogs', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (480, 'Knitted Hat (blue)', 'Plush. Warm. Ugly. But enough about your mom.', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (481, 'Ladies Ornate Hat (black)', 'Elegant!', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (482, 'Cowgirl (male)', 'Rootin tootin foid-shootin', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (483, 'Naughty Newsboy', 'Missing. Last seen at ground zero of your local monkeypox outbreak. If found, do NOT touch.', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (485, 'This Is Fine', 'Situation normal.', NULL, 1000, NULL, NULL);
INSERT INTO public.hat_defs VALUES (486, 'Emo Hair II', 'SO CUT MY WRISTS AND BLACK MY EYES', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (487, 'Emo Hair III', 'I write sins not tragedies', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (488, 'Emo Hair IV', 'I''m not okay (I promise)', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (489, 'Emo Hair V', 'Thnks fr th Mmrs', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (490, 'Emo Hair VI', 'Cute Without The ''E''', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (491, 'Top Hat (frost)', 'Cool-colored top hat for cool tops only', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (492, 'Top Hat (frilly Victorian)', 'Victorian fashion was HIDEOUS but contemporary spins on it are just lovely', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (493, 'Brown Herringbone Flat Cap', 'TWEED AND SNEED', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (494, 'Skull Boingy Head Things', 'boing 💀 boing 💀 boing 💀', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (495, 'Alligator-Textured Gold Blingy Hat', 'Looks like shit but probably feels real nice', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (496, 'Flower Hat (hot pink)', 'A cute flower hat', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (497, 'Stinky', 'UH OH! STINKY!', NULL, 1000, NULL, NULL);
INSERT INTO public.hat_defs VALUES (498, 'Mario Hat (BIPOC)', 'Who could have dropped this?', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (499, 'Fart Slave Gear', '12 years a fart slave', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (500, 'Little African Hat', 'Promise not to wear it', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (502, 'Booze Cruisin', 'DRUNK DRIVER RIGHTS ARE TRANS RIGHTS', NULL, 1000, NULL, NULL);
INSERT INTO public.hat_defs VALUES (503, 'The Antichrist', 'Weak to Tesla coils', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (505, 'ADIDAS Cap', 'Sacred cultural headpiece for the highest caste of gopnik', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (506, 'The Tim Buckley', 'Is this loss?', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (507, 'Gat', 'The ultimate in neo-BTSstanwear', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (511, 'Sam Fisher', 'Four-eyed freak vidya edition', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (512, 'The Buckethead', 'Exactly what it says on the tin', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (513, 'The Sherlock', 'Elemarsey, my dear Watson', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (514, 'Glowing', 'Hit me with your car', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (515, 'Cringe Archivist', '*SNAP* Yep, this one for sure', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (516, 'Madoka', 'Pink-haired retard', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (517, 'Homura', 'Why does the jap have blue eyes', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (519, 'Sakaya', 'omg stop making me look up chinese cartoon characters', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (520, 'Mami', 'Titty ass bitch', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (521, 'VDV Beret', 'something something something Russia', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (522, 'Dr Livesey', 'Dr Soon-To-Be-Dead', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (528, 'Flower Clip', 'A cute flower clip', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (530, 'RENT FREE', 'idek anymore carp whatever you want is fine', NULL, 1000, NULL, NULL);
INSERT INTO public.hat_defs VALUES (508, 'Meowth', 'That''s right!', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (509, 'Niconico', 'I can''t think of a description, but I''m proud of it', NULL, 1000, NULL, NULL);
INSERT INTO public.hat_defs VALUES (510, 'Sneed (Chuck)', 'Subsequently Sneed''s', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (518, 'Kyoko', 'This is seriously her name? Kyoto with a k instead? Hi I''m Philadelkia, son of Dedroit, son of Kansas Citie <_>', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (524, 'Smurf Hat (papa)', 'You think you''re better than all the other smurves', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (529, 'Conehead', 'How do you describe a cone? It''s a cone. It goes on your head.', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (523, 'Smurf Hat', 'La la, la la la la', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (525, 'Please Be Autistic I Am Yes', 'Please Be Autistic I Am Yes', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (526, 'No-No Finger', 'Oh no you di-int', NULL, 1000, NULL, NULL);
INSERT INTO public.hat_defs VALUES (527, 'Cat Ears (wig)', '~~nya ^-^', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (430, 'Purple Badge', 'Orange ya glad ya didn''t get an orange badge?', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (432, 'Orange Badge', 'You''ve betrayed the purple badge.', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (435, 'Witch III', 'Submitter called it cursed. He didn''t explain how. It''s cursed I guess? Spoooooooky.', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (436, 'robocop', 'You''ll never fuck my ass, Batman', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (450, 'Bluecheck', 'Can''t get verified? Do it yourself!', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (452, 'The MF Doom', 'Everyone''s favorite cosplay rapper', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (457, 'Thug Life Beanie', 'The whitest beanie you''ll ever see', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (479, 'Pizza Hut', 'For when ‘good enough'' is enough', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (484, 'Slav-sya', 'Enough about human rights, let''s talk about human wrongs', NULL, 500, NULL, NULL);
INSERT INTO public.hat_defs VALUES (501, 'Dancing Marsey', 'Omg she''s so happy lookit her GO', NULL, 1000, NULL, NULL);
INSERT INTO public.hat_defs VALUES (504, 'Iron Crown of Lombardy', 'This isn''t Crusader Kings, stop it', NULL, 500, NULL, NULL);


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

INSERT INTO public.marseys VALUES ('marseydeadinside3', 13710, 'depressed suicidal doomer tired despair wrinkled wrinkles', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyappicon', 768, 'iphone ios android application googleplay samsung', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyastronaut2', 6225, 'cosmonaut spacesuit helmet', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseypastor', 3259, 'christian baptist southern church black papist mrpenny preacher priest', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyliathomas', 1710, 'tranny transgender athlete lia thomas athletics woman valid lgbt swimmer aquamaam aqua maam', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseybiden', 2626, 'ddd dementia daddy president sleepy joe', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyburnedman', 2622, 'joshua graham fallout vegas mormon caesar', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysaint2', 5214, 'angelic halo holy animated wings happy', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycowboy', 8979, 'western pardner reaction hat tootin yeehaw rootin', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyfediverse', 10881, 'federation autism freespeech poast', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseykiwimom', 5526, 'kf farms newzealand new zealand dramarama birds babies chicks single mother brood flock', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseynukegoggles', 3370, 'nuclear atomic bomb mushroom cloud', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysoyseethe', 5214, 'soyjack soyjak reddit angry yelling wojak', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseytransflag', 2866, 'trans flag then consumeproduct', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marsey3d', 5214, 'poly 3d print alive spin animated', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycapysuezcanal', 3370, 'capy suez canal egypt ship blockage sexy', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseypizzaslice', 5526, 'pizza shill longpost yum chef cook italian cheese pepperoni', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyhomochingchong', 5214, 'asian chinese jap gook chink rice gay strawhat  glasses squint rainbow tiedie tyedye tyedie tiedye', NULL, NULL, 1663248780);
INSERT INTO public.marseys VALUES ('marseyfugg2', 4989, 'spurdo sparde', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyeskimo', 5214, 'inuit native arctic fishing dog helpful ice freeze winter cold', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyoppenheimer', 7480, 'scientist nuke bomb ww2 atomic nuclear mushroom cloud', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyeva', 3370, 'anime weeb neon robot mech japan', 0, NULL, 1663376836);
INSERT INTO public.marseys VALUES ('marseyvampirebite', 3370, 'cope seethe mask house', 0, NULL, 1663376896);
INSERT INTO public.marseys VALUES ('marseylaughwith', 1738, 'cry tears lol lmao haha laughing', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyshock', 12116, 'shock fear afraid terror scared horrified', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyredflag', 7913, 'warning red flag alert scum problematic', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseytrad2', 5214, 'wojak tradwife soyjak 4chan meme foid', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseytemplate', 4989, 'template blank faceless eyeless mouthless head empty faceless', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyliberty2', 5214, 'usa burger america statue lady republican democrat biden trump rightoid leftoid', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseythegrey', 4588, 'lord of the rings magic gandalf lotr mage wizard warlock', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyspecial', 1387, 'retard reaction slow special needs sped', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseytransrentfree', 150, 'transgender lgbt rent free wojak chud', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyappleseed', 8021, 'american usa johnny history folk fruit food pot pan helmet legend', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseytypinglaugh', 3259, 'computer keyboard lol bongo animated', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseytime', 5214, '10pm tock tick clock animated', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyjacksparrow', 5214, 'johnny depp amber heard abuse violence punch beat feminist Jack sparrow', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseydarkmarsey2', 5214, 'lasereyes redglow scary chudrama', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseylaughpoundfist', 1738, 'cry tears lmao lol kek bully laughing funny mocking animated', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseytyping', 3259, 'computer keyboard bongo animated', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyterfdomesticabuse', 4928, 'terf domestic abuse violence feminism feminist lesbian ovarit radical', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyhawaii', 3149, 'boomer margarita drink chill relaxed', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyturnedon', 13710, 'aroused arousal amorous horny', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyusa', 5214, 'burger patriot america freedom liberty justice love independence freedom guns trump biden state flag', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseybongcop', 3370, 'police english british london copper bobby bongistan britain england police', NULL, NULL, 1663284064);
INSERT INTO public.marseys VALUES ('marseysoren', 2546, 'sleeping alt right altright racist nazi chud', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyveryworried', 4928, 'worry anxiety fear animated scared sweat yikes', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseymegalodon', 541, 'shark carpathianflorist jaws attack eating killing', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyswastika', 8197, 'nazi chud germany swasi swazi windmill of peace hitler racist racism antisemitic antisemitism third reich jewish jews', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycruisemissile', 2616, 'war explosion bomb weapon military rocket enemy destroy kill nuke launch', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseywhiteflag', 9394, 'surrender battle french', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyreluctant', 4588, 'stare doubt skeptical wary cautious uncertain uhh umm', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseytabletired2', 7913, 'beer tiresome depressed sad alcoholic alcoholism despair', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyfedposthmmm', 2890, 'glowie american dad stan meter fbi', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyschizotwitch', 5214, 'twitching eyelid crazy nuts psycho insane traumatized animated', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyhillary', 2626, 'president her turn hilary killary hilldawg clinton', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysnowglobe', 1994, 'christmas tree small miniature', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyflakes', 2608, 'parsley seasoning salt pepper spice food seasoning', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyarthoe2', 5845, 'woman foid scene emo bitch slut whore thot', NULL, NULL, 1663354428);
INSERT INTO public.marseys VALUES ('marseysperm', 768, 'cum swim vasectomy jizz semen spunk penis sex pregnant coom animated', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseypridepearlclutch', 5214, 'lesbian gay bisexual homo lgb rainbow cry bigot tears', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyedelgard2', 3370, 'princess fireemblem nintendo anime weeb videogame', NULL, NULL, 1663283895);
INSERT INTO public.marseys VALUES ('marseygrin', 12116, 'seethe pain rage beard angry', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseylicking', 3370, 'spongebob tongue taste', NULL, NULL, 1663284181);
INSERT INTO public.marseys VALUES ('marseyclintongarrison', 3370, 'hillary brap democrat ben comic', NULL, NULL, 1663284618);
INSERT INTO public.marseys VALUES ('marseyloss', 3370, 'isthis meme comic webcomic hospital ethan tim buckley', NULL, NULL, 1663284338);
INSERT INTO public.marseys VALUES ('marseyscratch', 1710, 'loweffort doodle code coding programming', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseylain', 1817, 'bear onesie pajamas fursuit furry', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseybestfriends', 1710, 'snoo reddit alien slice kill kys stab blood wpd', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyearrape', 10881, 'breakcore goreshit headphones noisecore', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyjoy', 12116, 'smile excited smug', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseychonkerbutch', 3259, 'fat obese brap bitch dyke dangerhair lesbian', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseybackingintobush', 11320, 'Homer Simpsons scared away animated hedge bush', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseydunce', 4084, 'stupid moron imbecile dolt dunce retard dumb cap hat sped', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyhugretard', 3259, 'love idiot drool embrace', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysmug2', 5526, 'snicker scoff mock reaction guffaw ridicule judgment', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyunabomber2', 1828, 'gift christmas industrial society delivery mail kaczynski uncle ted package', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyrulebritannia', 995, 'britain british bongistan chips london england lasereyes', NULL, NULL, 1663211275);
INSERT INTO public.marseys VALUES ('marseygun', 768, 'handgun shoot bang kill threaten pistol', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseytroll', 4, 'dio diogenesjr diogenesjunior trollface reaction', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseywhirlyhat', 3717, 'idiot retard hat dumb sped slow stupid special kid', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseydrunk2', 2256, 'drinking shitfaced alcoholic liquor happy beer dizzy', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycleonpeterson2', 5214, 'monster devil demon evil scary horror', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyfedpostglow', 4122, 'cia longpost long fed fedpost read notes animated glowie glow', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseywtf2', 2626, 'shocked reaction wth disturbing disturbed what the fuck', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyshutitdown', 5214, 'cop glownigger fed glowie agent federal mossad israel idf the goyim know kikes radio walkie talkie', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyvargfinnselfdefense', 2256, 'bardfinn steve akens aikens penny verity oaken tranny train troon transgender transvestite black metal trve kvlt euronymous varg vikernes mayhem burzum child abuse kid beating stabbing bloody', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseybardfinn3', 5244, 'bardfinn ahs powermod tranny trannies wifebeater abuser steve', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseydance', 5214, 'excited stomp jump feet step run animated', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyhatiun', 5356, 'mad fury furious pissed hatred rage angry maddened infuriated hateful hatefuel', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyfemboy', 7056, 'discord trans femboy tomgirl groomer groomed gay faggot homosexual queer poof fairy', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyfuckyou', 1387, 'middlefinger middle finger flipping off fuck you nigga', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseygambling', 1387, 'depressed casino slots blackjack las vegas depressed suicidial degenerate smoking losing cards hotep', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyschizo', 635, 'harm burns selfharm self harm cigarette burning mermaids reaction artist self', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseydarkpizzashill', 995, 'chud rightoid leftoid debate owned lasereyes footlocker', NULL, NULL, 1663210672);
INSERT INTO public.marseys VALUES ('marseycrusade', 995, 'pope papal papist catholic lasereyes christian cross constantinople istanbul war crusader', NULL, NULL, 1663212295);
INSERT INTO public.marseys VALUES ('marseysalvindicated', 995, 'shark 2weeks twoweeks gonowhere wentsomewhere', NULL, NULL, 1663210995);
INSERT INTO public.marseys VALUES ('marseysaint', 5214, 'wings angel blessed halo animated', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyarthoe3', 4989, 'woman foid scene emo bitch slut whore thot', NULL, NULL, 1663354464);
INSERT INTO public.marseys VALUES ('marseylaughbothsides', 1738, 'wingcuck radical centrist centrism animated horseshoe', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyicecreamcone', 3370, 'sweet dessert dairy', NULL, NULL, 1663284406);
INSERT INTO public.marseys VALUES ('marseysignaling', 7466, 'railway light semaphore troomer tranny transgender train troid transsexual animated', NULL, NULL, 1663238068);
INSERT INTO public.marseys VALUES ('marseyarthoe8', 5845, 'egirl woman foid scene emo bitch slut whore thot discord', NULL, NULL, 1663354707);
INSERT INTO public.marseys VALUES ('marseycrusader2', 995, 'crusading catholic christian pope knight templar warrior soldier sword shield lasereyes istanbul constantinople', NULL, NULL, 1663212423);
INSERT INTO public.marseys VALUES ('marseysnappyautism', 1980, 'snapshillbot hat neurodivergent robot autistic marppy', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyagree', 4588, 'concur nodding nod reaction affirmative yes yeah uh huh animated judgment', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysal2', 7615, 'shark 2 weeks two weeks go nowhere going nowhere watch go nowhere', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseypepsi', 1980, 'cola coke soda soft drink pop red white blue usa america', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysoldierchina', 1710, 'army war gun rifle asia chinese chink gook', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyshortbus', 768, 'bussy animated mrpenny carpathianflorist schizocel retard special short schoolbus classroom teacher wheels window rosa parks mlk', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseylgbtflag', 7913, 'pride gay queer', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseymononoke', 8021, 'anime japanese miyazaki ghibli asian cartoon princess character fictionnal ashitaka san wild wolf nature', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyredflag2', 4928, 'refuse reject warning animated', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyklennywinner', 3259, 'medal award dog klenvastergan corgi', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseypass2', 8494, 'pass froyo frozenchosen woman foid transgender', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyrabbit', 11715, 'bunny', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyprostateexam', 13710, 'gloves doctor proctologist proctology anal cavity search rectum', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyascii', 4017, 'blurry', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseynerd2', 2626, 'geek glasses dork loser pimples zits', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyautumn', 5214, 'fall season leaf leaves pumpkin spice latte wind scarf animated', NULL, NULL, 1663109340);
INSERT INTO public.marseys VALUES ('marseyfreud', 1817, 'oedipus incest psychoanalysis psychologist shrink psychiatrist', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseymemeball', 13710, 'picardia strawman polcomp political', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyropewithchingchong', 5214, 'suicide chink chinese asian die kys together strawhat slit zip gook nip buckteeth', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyfacepalm', 542, 'reaction omfg judgment', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseykkkevil', 995, 'kukluxklan racism racist lasereyes evil', NULL, NULL, 1663211985);
INSERT INTO public.marseys VALUES ('marseygundam', 3370, 'mecha robot helmet mask anime', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseypusheen', 1817, 'grey gray', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycoomer2', 5244, 'gooning masturbation fapping cumming gooner nofap', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyblob', 10881, 'smile owo uwu squish slime', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycarpbuff', 3259, 'muscles tough strong carpathianflorist admin mod jannie', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseymissing2', 2873, 'missing notexture source image not found broken', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycarpina', 4928, 'carpathianflorist drag transgender admin jannie', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseypaperbag', 10214, 'ugly ashamed bagged butterface', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyselfflagellation', 5988, 'whip white guilt hate sin mayo liberal catholic', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyarthoe', 5845, 'scene slut foid whore emo scene bpd bangs dangerhair girl woman', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseykingretard', 3259, 'drool dumb idiot crown moron', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycarpflorist', 5526, 'jannie admin fish flowers floral carpathianflorist crown', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseydeadinside2', 13710, 'depressed suicidal doomer despair', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseylenny', 4989, 'innuendo dirty sex horny emoticon perverted', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyokapi', 2626, 'okapi furry deer', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseymobster2', 2673, 'bat gangster mafia kneecapper', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycarpprotest', 1387, 'sign fish mad carpathianflorist sign admin jannie', NULL, NULL, 1663163535);
INSERT INTO public.marseys VALUES ('marseygirl', 5214, 'dress toddler tween sister horror shining', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseychocolatemilk', 4090, 'choccy offer givemilk drink', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyworldcup', 5988, 'world cup soccer football winner sports champion', NULL, NULL, 1663033833);
INSERT INTO public.marseys VALUES ('marseyanorexia', 2626, 'starvation proana old wrinkled bulimia bulimia edtwt', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyexcitedexosuit', 4240, 'happy smiling mecha rickandmorty robot', NULL, NULL, 1663011866);
INSERT INTO public.marseys VALUES ('marseysatisfied', 8613, 'satisfying happy smile delightful grateful glad wholesome', NULL, NULL, 1662997904);
INSERT INTO public.marseys VALUES ('marseyletsfuckinggo', 5214, 'lfg tennis ball screaming ready', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyamber', 1817, 'dalle2 generated', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycoffeemug', 5526, 'teacup happy cozy', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyssflag', 7913, 'superstraight cishetero straggot pride', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyfedora', 4928, 'suit 1920 mobster mafia detective mob', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseywait', 8159, 'time watch wait waiting bored', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseytampon', 4634, 'period menstrual menses menstruation bloody', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysmugautist', 2113, 'autism retard brainlet drool hat', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyinnocent', 2490, 'innocent naive angelic dumb halo', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyduck3', 1387, 'duck bird quack beak', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseybeaver', 11192, 'canada canuck canadian', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseybowl', 8979, 'marijuana weed dude weed lmao ganja drugs reaction pot pipe', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyarthoe4', 5845, 'woman foid scene emo bitch slut whore thot', NULL, NULL, 1663354488);
INSERT INTO public.marseys VALUES ('marseyoutline', 1387, 'blank empty void', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseywatchingtv', 1067, 'familyguy peter griffin television couch', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyaceofspades', 2548, 'asexual volcel cards', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseybeanbigmad', 995, 'animated angry pissed flashing seizure seethe seething', NULL, NULL, 1663099782);
INSERT INTO public.marseys VALUES ('marseybikecuck', 3370, 'owlturd bicycle cuckold webcomic happiness', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseytabletired', 7913, 'tiresome depressed sad desk', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyzaku', 3370, 'gundam mecha robot helmet mask', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseydemonicgrin', 13710, 'evil wicked horror teeth', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycornlove', 2890, 'farmer iowa hawkeye maize', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyropewithme', 4989, 'suicide kys kms suicidal hanging noose', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseybudddwyer', 13710, 'suicide gunshot reporter journalist', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseydiversity', 1994, 'greatest strength meta carp aevann platy zombiewolf zombie wolf', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseypuppy', 1817, 'dog dalle2 puppy', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseynapoleon2', 11535, 'french france horse', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyfursuit', 2622, 'furry furcon degenerate cosplay fursona costume mascot', NULL, NULL, 1662996039);
INSERT INTO public.marseys VALUES ('marseyedelgard', 3370, 'fireemblem anime weeb fantasy nintendo princess', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseydarkxd', 13710, 'laugh ragecomics lmao despair shadow', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyshy2', 4131, 'uwu weeb blush flushed finger owo', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysatisfiedmarcus', 4989, 'black bipoc satisfying happy smile delightful grateful glad wholesome', NULL, NULL, 1662998420);
INSERT INTO public.marseys VALUES ('marseylgbtflag2', 7913, 'pride gay inclusive queer ukraine bipoc', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseytrumpgarrison', 3370, 'cum maga capitol ben comic republican', NULL, NULL, 1663284695);
INSERT INTO public.marseys VALUES ('marseychadyes', 6749, 'based gigachad', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyfine', 5526, 'is fine meme thisisfine burning fire', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseykeffalsdance', 10881, 'onesie pajamas animated fursuit hood wiggler', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseylickinglips', 2548, 'yummy tasty delicious', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseygangster', 13710, 'pimp hustling mafia money gangsta', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyeyelidpulling', 13710, 'frustrated scary horror', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycosmopolitan', 4634, 'bourgeoisie wealthy affluent tophat cultured capitalist elite monocle', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseydarkcomrade', 995, 'communist commie pinko lasereyes russian kgb hat soviet ussr tankie', NULL, NULL, 1663254781);
INSERT INTO public.marseys VALUES ('marseycow', 5214, 'cow fursona skin animal costume furry heifer fursuit', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseybeanpleased', 1817, 'bean satisfied cheerful upbeat', NULL, NULL, 1663124719);
INSERT INTO public.marseys VALUES ('marseybeanimp', 1817, 'bean demon devil devious mischevious playful teasing', NULL, NULL, 1663124439);
INSERT INTO public.marseys VALUES ('marseyletsfuckinggo2', 1387, 'hyped screaming shouting yelling', NULL, NULL, 1663161484);
INSERT INTO public.marseys VALUES ('marseybrainletclapping', 2622, 'idiot dumb stupid applause cheering moron animated retard', NULL, NULL, 1663095832);
INSERT INTO public.marseys VALUES ('marseytwerking', 2890, 'tailspin animated butt backside dancing spin booty ass dance', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseywoodchipper2', 1710, 'libertarian pedo woodchipper animated kill map', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyxd', 3609, 'lmao reaction rofl haha lol laughing', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseybetauprising', 995, 'blackops2cel blops2cel incel volcel lasereyes dark involuntary celibate saint', NULL, NULL, 1663213986);
INSERT INTO public.marseys VALUES ('marseyangel3', 2490, 'halo happy innocent', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyabandoned', 2519, 'box container rejected dirty cardboard homeless', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseybardfinn', 10432, 'domestic violence bardfinn foid beating punching battering battered bandage hurt pain woman female steve akins penny verity oaken tranny transgender transsexual', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyraiden', 993, 'mgs vidya', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyratso', 2626, 'furry nsfw porn', NULL, NULL, 1663119130);
INSERT INTO public.marseys VALUES ('marseybruh2', 4122, 'bruh disbelief doubt bro seriously smdh', NULL, NULL, 1663148476);
INSERT INTO public.marseys VALUES ('marseybeanwink', 1817, 'bean joking flirtacious suggestive ironic', NULL, NULL, 1663124851);
INSERT INTO public.marseys VALUES ('marseyboomercartoon', 1387, 'grandpa joke comic', NULL, NULL, 1663161684);
INSERT INTO public.marseys VALUES ('marseybeanpizzashill', 2157, 'bean chud agendaposter physiognomy footlocker pojom', NULL, NULL, 1663123650);
INSERT INTO public.marseys VALUES ('marseycornholio', 13667, 'beavis butthead cornholio metallica marsey mtv', NULL, NULL, 1663135986);
INSERT INTO public.marseys VALUES ('marseybeanmonocle', 1817, 'bean posh wise snobbish bourgeois aristocrat victorian', NULL, NULL, 1663124531);
INSERT INTO public.marseys VALUES ('marseybeanflushed', 1817, 'bean blush embarrassed flattered surprised infatuated senpai umm', NULL, NULL, 1663124099);
INSERT INTO public.marseys VALUES ('marseycapitalistmanlet', 1387, 'money top hat rich landlord cigar llm tophat', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseytransattentionseeker', 5214, 'needy enby nonbinary notice mtf ftm train attn', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyfursona2', 2626, 'furry fursona cat devil', NULL, NULL, 1663119051);
INSERT INTO public.marseys VALUES ('marseycarpfisherman', 3370, 'admin janny bait caught mod sardine srdine carpathianflorist jannie', NULL, NULL, 1663283814);
INSERT INTO public.marseys VALUES ('marseyautumn2', 5214, 'fall season leaf leaves pumpkin spice latte wind scarf', NULL, NULL, 1663109364);
INSERT INTO public.marseys VALUES ('marseychtorrr2', 9394, 'reddit admin chonker fat', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyliberty', 5214, 'usa burger america statue lady republican democrat biden trump rightoid leftoid', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseydarkcarp', 995, 'lasereyes carpathianflorist fish admin jannie mod banned yalled', NULL, NULL, 1663211530);
INSERT INTO public.marseys VALUES ('marseybeanannoyed', 1817, 'bean expressionless frustrated', NULL, NULL, 1663123946);
INSERT INTO public.marseys VALUES ('marseyexciteddance', 4122, 'happy dance excited spin tippytap', NULL, NULL, 1663143559);
INSERT INTO public.marseys VALUES ('marseybeanadorable', 1817, 'bean uwu innocent', NULL, NULL, 1663123845);
INSERT INTO public.marseys VALUES ('marseygardener', 11964, 'gardening watering', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseybeandizzy', 1817, 'bean spiral hypnosis disoriented stunned shocked', NULL, NULL, 1663123997);
INSERT INTO public.marseys VALUES ('marseybeanpensive', 1817, 'bean remorseful downtrodden introspective unfortunate', NULL, NULL, 1663124612);
INSERT INTO public.marseys VALUES ('marseybeanpleading', 1817, 'bean begging please bashful adoration', NULL, NULL, 1663124679);
INSERT INTO public.marseys VALUES ('marseyfoidretard', 1387, 'woman blonde stupid dumb idiot froyo frozenchosen', NULL, NULL, 1663161600);
INSERT INTO public.marseys VALUES ('marseybeanrelieved', 1817, 'bean calm pleasant content peaceful pleased', NULL, NULL, 1663124757);
INSERT INTO public.marseys VALUES ('marseybeantonguepoke', 1817, 'bean playful silly jesting kidding', NULL, NULL, 1663124794);
INSERT INTO public.marseys VALUES ('marseybedsick', 7813, 'illness plague fever pillow', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseylgbtflag3', 7913, 'pride gay rainbow queer', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyarthoe5', 5845, 'woman foid scene emo bitch slut whore thot', NULL, NULL, 1663354512);
INSERT INTO public.marseys VALUES ('marseychingchongsupremacy', 995, 'ccp china chinese ricefarmer hat glasses buckteeth bucktooth azn asian jinping xinping han masterrace communist communism maoist zedong', NULL, NULL, 1663298980);
INSERT INTO public.marseys VALUES ('marseyira', 5244, 'car bomb irish ireland', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseywizard', 7813, 'wizard magic pepe apu', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseymoplicker', 7913, 'janny moderator admin', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycapyheart', 5526, 'capybara rodent aevann happy cute love', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseymormon', 3259, 'backpack tie jesus god christian missionary', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseybeanangryfbi', 995, 'federal agent glowie glownigger lawenforcement leo terrorist terrorism', NULL, NULL, 1663099467);
INSERT INTO public.marseys VALUES ('marseyarthoe6', 4989, 'woman foid scene emo bitch slut whore thot', NULL, NULL, 1663354548);
INSERT INTO public.marseys VALUES ('marseycumjar2', 1828, 'semen jizz sperm spunk bukkake', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseychemist2', 1817, 'chemistry science chemical cope', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyangryexosuit', 4240, 'mecha rickandmorty robot', NULL, NULL, 1663011836);
INSERT INTO public.marseys VALUES ('marseywut2', 1387, 'weird reaction raised eyebrow disturbing disturbed wtf judgment', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyarthoe7', 5845, 'woman foid scene emo bitch slut whore thot', NULL, NULL, 1663354565);
INSERT INTO public.marseys VALUES ('marseyceiling', 2446, 'spy masturbate watching peeping', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyimam', 4444, 'muslim islam saudi ghutra keffiyah kufiya emiratis arab', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyfellowpedo', 1913, 'libertarian glowie fbi', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycrystalmaiden', 2256, 'gamer video game gaymer', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyniqabpearlclutch', 10572, 'bombasticpussy sjw snowflake burka burqa', NULL, NULL, 1663350191);
INSERT INTO public.marseys VALUES ('marseylongpost', 4122, 'tldr reaction wall of text wordswordswords animated words', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycool2', 5526, 'cigarette hip shades sunglasses jacket smoking smoke', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyatfagent', 8021, 'feds atf agent glowies usa america waco swat m16 firearm rifle cops police', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyairquotes', 2626, 'reaction patronizing animated uh huh', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseydog', 5214, 'puppy doggo fursona skin animal costume dog furry fursuit', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyskinnedwalk', 995, 'watchpeopledie zllctnxaspywgb3 animated skinned walking trotting skeleton bones organs', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycrusader', 5526, 'knight deusvult templar crusades catholic', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycarpnoticeme', 635, 'carpathianflorist fish attn attention whore', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseywall', 2626, 'foid female birthing person woman girl 30 fds femcel single mom single mother itsover old gross yuck nasty gussy', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyspirit', 3978, 'ghost halloween holiday', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysaluteussr', 8239, 'salute o7 flag soviet union russia kgb communist commie marxist marxism tankie stalin lenin animated patriotic', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyahs', 995, 'bardfinn dubteedub againsthatesubreddits redditor groomer pedophile libertarian chomo antifa animated', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysaluteisrael', 8239, 'jewish yiddish hebrew kike sheeny mossad star of david flag patriotic animated', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseykween', 2654, 'hoop earring fds black shaniqua', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseymicrobus', 1738, 'vw van bussy', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseybang', 1387, 'head wall bang schizo psycho selfharm deranged gif animated', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyidio3', 8239, 'idio3 russia belarus communist commie flask drink computer online monitor display keyboard idio', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseytrumpgrill', 3259, 'centrist donald ddr drumpf centrism bbq barbeque barbecue ketchup', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyolantern', 4580, 'halloween scary pumpking', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyjamesholmes', 8239, 'killer shooter shooting crazy schizo batman capeshit ginger', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseybongosrdine', 5214, 'bongo drums music meme jam srdine', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyslime', 1817, 'animated happy blob vidya video game maple story maplestory bouncing bounce monster jump', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycyanide', 1387, 'kys kill yourself kms kill myself poison pill death die depressed suicidal suicide animated', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('joanmarsey', 3536, 'joan gay clown gacy wayne', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseydisconcerting', 1387, 'creepy smile uneasy rapey', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseygasp', 2069, 'wow woah what how why whoa reaction appalled', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseytf2scout', 6345, 'tf2 scout boston zoomer valve vidya game baseball mercenary', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycarpsnipe', 9503, 'shooter shooting gun sniper rifle scope crosshairs carpathianflorist kill murder bullet crosshair ajab', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseykitti', 995, 'watchpeopledie horror grim evil scary surreal tattoos wicked demonic', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseybaited', 5526, 'laser pointer trolled gullible reaction animated', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyironmaiden', 8239, 'death blood torture chika anime weeb weeaboo spikes murder crush animated', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyvatnik', 8159, 'russian alcoholic alcoholism', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyduck', 5214, 'bird beak', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysoonretarded', 2256, 'weeks 2weeks sal antisal soon retarded naive', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyfingerwords', 5214, 'cute long tldr didnt read', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyobamacope', 35, 'barack pointing laughing poster', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyphonecall', 7813, 'pepe apu peepo phone call cellphone', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyreactor', 4293, 'nuclear power reactor energy generation radioactive chernobyl', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyhillarybackstab', 5214, 'clinton hilary arkanicide knife stabbing kill murder seth rich death', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marsoy2', 5214, 'soy wojak soyjak soyjack nerd numale redditor', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycapyblowkiss', 5526, 'capybara rodent aevann happy cute love', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyminipixel', 1738, 'miniature small smol place 8bit mouse', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseymfdoom', 2622, 'rapper hip hop hiphop rnb supervillain helmet mask', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyfocault', 635, 'philosophy history', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyazov2', 5214, 'ukraine ukrainian nazi chud black sun schwarzsonne schwarzesonne zelenskyy war soldier', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycanned', 2890, 'srdine sleeping tin fish sardine', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseylovecraft', 6914, 'eldritch horror niggerman cat hp tentacle insane halloween', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyinabox', 8613, 'hiding hide box cardboard happy cute', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseydrunk', 2069, 'drinking shitfaced alcoholic liquor happy beer dizzy', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyprisma', 5244, 'animated fingers anime spin dance weeb', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyexcited', 8613, 'eager ready hype amped reaction excitement happy thrilled', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseymischief', 1817, 'interface clown', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyfoucault', 1817, 'philosophy history foucault postmodern', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyhehe', 5244, 'hehe nothehe happy laughing angry questioning', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyvan', 1947, 'libertarian pedobear free candy pedophile groomer lolbert chomo molester pedo toucher', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseybobpage', 8159, 'glowie deusex big pharma rocket daddy elon musk suit', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseygossip', 5526, 'tea rotary phone popcorn gabbing', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseybattered', 2626, 'blackeye domestic violence black eye marseyismywaifu bardfinn steve akins penny beaten bruised housewife', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyemojismilemouthtighteyes', 1387, 'emoji reaction smile xd', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyvaxmaxx', 1387, 'mask coronavirus covid gigavax corona vaccine vaccination hazmat', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marsey57', 8239, '57 emoji57 sly smug blob', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyspa', 4634, 'spa towel cucumber facial relax calm selfcare foid hygiene beauty', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseypharaoh2', 5214, 'gods egyptian aevann animated', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyjamming', 8613, 'mp3 headphones beat ipod music happy', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysnorlax', 1828, 'fat obese fatty fattie pokemon snorlax blocking snoring  sleeping', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseywheredrama', 5214, 'seriouspost reaction agendapost dramawhere animated', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyjackson', 1387, 'music king pop mayo whiteface michael', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyevilgrin', 3149, 'joker evil society crazy smirk wicked danger fight trouble', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycapyhacker', 5214, 'animated aevann capy hack code program socks', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycapycarp', 2622, 'aevann capybara carpathianflorist walking stomping trample trampling animated', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyfacepeel', 995, 'watchpeopledie kitti gore face psycho horror flay', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseydeadchat', 8494, 'dead chat discord zoomercord', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyumbreon', 635, 'trick or treat pokemon halloween eevee costume holiday', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseylong1', 4122, 'top meme', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyhypno', 5845, 'hypnosis spiral brainwash animated hypnotoad', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseywitch2', 1043, 'tranny troomer penny wvp feminist halloween bardfinn groomer magick troid steve monster', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marppybiden', 381, 'sentient snappy robot marppy biden confused', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseygroomer2', 5214, 'molest discord chomo snoo pedo pedocord reddit', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseychonker2', 5526, 'fat obese pig disgusting fatty fattie', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyputin', 1710, 'vladimir russian kgb moscow ukraine dictator leader', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycheeks', 8239, 'sandy spongebob squirrel underwater bikini bottom diving suit', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyautismchonker', 3259, 'fat obese retarded hat autistic neurodivergent', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseybreastcancer', 3978, 'mastectomy gross yuck foid disgusting titties tits boobs patient disease bald chemotherapy', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseywinemom', 2256, 'drunk wine aunt flirt cigarette drunk lush elfbinn fartbinn cougar', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseybiting', 8979, 'reaction datass lip bite dat ass', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyschizoducklove', 8494, 'animated schizo schizocel rare love duck', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marcuscop', 635, 'police officer acab thin blue line pig black bipoc', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyduchamp', 2050, 'art urinal duchamp modern abstract', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyeerie1', 2622, 'eerie excited calico', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseybush', 1376, 'genocide president mission accomplished victory george bush we did it', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyhankhill', 3370, 'cartoon propane hank grill kingofthehill', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseythonk', 2890, 'confused reaction thinking thunk thonk', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysjw', 5214, 'lgbt social justice reaction gay snowflake pride', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycringe', 250, 'pepe frog', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseydoubtit', 1710, 'dumpster defender redneck boomer shooting doubt it cocksucker gun', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyschizogrizzlylove', 8494, 'schizo grizzly bear love schizocel animated', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyschizonekolove', 8494, 'nekobit neko schizo schizocel schizomarsey rare love', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseytree', 2626, 'tree nature outdoors cosplay', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycapysorenjump', 8494, 'meta excited schizo aevann capy soren', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseywink', 7913, 'wink reaction cheeky flirt smirk imply hint', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseychristmasgift', 5526, 'present christmas box unwrapping holiday', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyparty2', 5214, 'trippy animated happy dance', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyjewoftheorientglow', 5214, 'animated glow rice china chinese chink commie mao xi', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyfugg', 1817, 'spurdo sparde fugg', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseydeadeyes', 1387, 'broken suicidal depressed', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysoldierrussia', 1710, 'army war gun rifle vatnik slav putin ukraine', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseywoah', 5526, 'tldr reaction wall of text wordswordswords stfu', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyreporterfox', 2626, 'reporter journalist journoid interviewer', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyhappy', 8979, 'pleased contented reaction contentment satisfied', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseygoodmap', 768, 'map pedo dead shoot animated shotgun buckshot kill minor libertarian', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycarpdead', 1387, 'fish janny kill', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseybrasileiro', 1710, 'brazil soccer macaco monkey', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseydepressed', 5244, 'smoke kms doomer cigarette despair reaction depression suicide suicidal smoking hopeless sad', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycapy2022', 5214, 'aevann caypbara new year party celebration', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseychartgaussian', 7913, 'stats statistics chart graph plot data gaussian normal bell distribution', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycarphug2', 2548, 'fish love bottomfeeder carpathianflorist heart blow admin cute', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseygold', 1387, 'gold award reddit', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyauthright', 1817, 'rightoid national socialism ss national socialist nazi wehrmacht hitler fascist', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseybongo', 5214, 'bongo drums music meme jam', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseydiscord', 5845, 'fur furry groomer moderator uwu :3', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseystuffed', 1817, 'fur meme statuesque indifferent figurine statue stuffed art', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseymspaint', 11030, 'paint mspaint pixel shifty squat', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marsey173', 1817, 'horror spooky halloween scp spc holiday', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyeggirl', 5214, 'troomer tranny transgender lgbt groomer troid transsexual', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('capysneedboat2', 8494, 'marsey capy schizo schizocel rare tripping sneed boat love excited seethe schizomarsey', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marsie', 6289, 'cartoon disney', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyprojection', 1817, 'animated projection projector movie director film movie cinema theatre theater kino', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('carporeon', 5526, 'carp vaporeon pokemon eevee water tail fish aquatic', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseymanlet', 1387, 'llm short midget dwarf little king', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyfluffy', 5526, 'poofy cute shaggy happy smile excited scruffy', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseypredator', 1710, 'predator drone obama wedding military', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseychristmaslove', 5526, 'christmas holiday present gift present love hearts affection', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyfrozenchosen', 7272, 'blonde girl woman', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyreading', 8613, 'study homework learn nerd novel reaction book', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseypentagram', 8727, 'satanic satanism devil evil occult witchcraft belial baphomet leviathan 666', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyshy', 5214, 'flirting anxious twiddle nervous flirty coy animated', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('schopenmarsey', 3908, 'schopenhauer philosophy german will ethics metaphysics', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyhijab', 5214, 'hijab reading islam jihad muslim allah quran koran', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycopeseethedilate', 2626, 'dilate seethe coping seething reaction angry mad dilating cope malding', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyfrylock', 3370, 'cartoon athf aqua fry fries fastfood', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyinbread', 635, 'food meme inbred', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyfranklin', 5525, 'franklin thinking constitution founding fathers', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysheepdog', 5526, 'shaggy scruffy woof', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyfurry2', 2626, 'furry fur degenerate sex', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyclown3', 4588, 'unicycle animated', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycapydinosaur', 381, 'capy aevann dinosaur rawr prehistoric', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseytf2heavy', 6345, 'tf2 heavy weapons valve vidya game minigun russia', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseykiwivampire', 5526, 'kiwi new zealand dramarama house scary spooky bird cloak sanguine fangs halloween bloodsucker', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseychristmaself2', 5526, 'elf santa northpole north pole christmas holiday', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marsey40k', 3652, 'warhammer 40k 40000 space space marine marine ultramarine smurf', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyfry', 2626, 'phillip fry take my money futurama', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseytf2spy', 6345, 'tf2 spy france mercenary smoke suit valve vidya game espionage', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseymonk', 5214, 'meditate levitating pray buddhist fish asian levitate animated yingyang buddhism karma zen', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseypotofsneed', 8239, 'pot sneed pottery dungeon ornamental ancient', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyicecream', 4122, 'ice cream sad disappoint pout cry.', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseybsod', 8727, 'windows computer blue screen of death error glitch', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyalien', 1387, 'green man martian scepter', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseygigachad', 150, 'reaction hunter eyes canthal tilt jawline', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseygucci', 1710, 'gucci mane lean rapper trap mixtape bricksquad traphouse codeine lean rapper pimp', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyballerina', 2256, 'dress ballet tutu dancer dancing', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseybadluck', 5460, 'unlucky black cat poc nigger blackcat', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyfingerhearts', 5214, 'cute love k-pop', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyvirus', 2622, 'phage infect infection plagued', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marsheepnpc', 5526, 'follower', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyatsume', 1738, 'kitten kitty weebshit', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseydealwithit', 5214, 'cool shades sunglasses reaction animated', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseybangfast', 1387, 'head wall bang schizo psycho selfharm deranged gif', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseybiker', 635, 'motorcycle harley bicycle helmet', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('karlmarxey', 5526, 'marxist communist history communism socialism', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyayy', 4588, 'wop tone guido wooden doors sopranos greaser dego paulie', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseykermit', 5526, 'kermit green frog puppet absinthe television sesame children', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycapysorenjump2', 8239, 'animated soren capy jump aevann mad', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyargentina', 3149, 'south america argentinian sudamericano', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyjudge', 2256, 'objection innocent hammer guilty gavel court overruled sustained', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('firecat', 5526, 'firefox browser marsey', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseylois', 1387, 'familyguy familyman family guy family man peter griffin', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseydeterminedgun', 7056, 'shooting blam blatt shooter kill die threatening animated', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyhungry', 5214, 'food hunger dish feed me bowl animated', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyworried', 2069, 'monkaw anxiety sweat panic scared sweaty sweating anxious nervous stressed', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseychinchilla', 5214, 'pet rodent capy cute hamster south american andes', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyschizolangleylove', 8494, 'animated schizo schizocel rare love langley cia glowie glow', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseymike', 2465, 'disney pixar monsters inc cyclops', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyisis', 5244, 'daesh terrorist islam muslim', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseychemist', 1817, 'chemistry science chemical', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycarpautism', 1710, 'carpathianflorist special assburgers aspergers retarded janitor jannie', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marsheep', 5526, 'sheep animal fluffy wool', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseymummy3', 2638, 'egyptian halloween monster holiday', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyschizoidiolove', 8494, 'schizo idio3 love rare excited idio', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marmseylegionnaire', 1058, 'rome roman legionnaire soldier helmet hats', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseypatriot', 2622, 'uncle sam red white and blue burgerland holiday american 4oj patriotic', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyshakespeare', 4634, 'words, writer, author, drama, theater, british, poet william england english thespian playwright playwrite', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycop2', 635, 'police officer acab thin blue line pig', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyanticarp', 541, 'reaction fish carpathianflorist', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseypennylove', 3259, 'love penny hug wholesome black kween', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyflareon', 635, 'trick or treat pokemon halloween eevee costume holiday', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyskater', 2256, 'dope hip sk8 ill tony hawk sick skateboard not a poser rad', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseymajorgeneral', 201, 'jeffthespammer pirates of penzance safari muttonchops mutton chops army military soldier officer', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseylong2', 4122, 'middle meme', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseybadger', 2622, 'animal marmot', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseythumbsup', 8613, 'cool good job good one agree reaction nice work yes great job', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyanime', 2626, 'sayian weeb', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseybaby', 1387, 'pacifier bb little', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseybeansick', 1817, 'bean sick vomit nausea unwell ill', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseybigdog', 1738, 'bussy big dog poster', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseychristmasbulb2', 5526, 'ornament holiday christmas', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseystroke', 2526, 'derp retard reaction stupid drooling', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseypoor', 1387, 'homeless beggar panhandler proletariat bum', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyropeyourself', 635, 'kill yourself kys lynch reaction keep yourself safe hanging noose', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseybath', 2626, 'shower tub rubber duck', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseynpcmad', 3149, 'angry grey libtard', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysexylibrarian', 2626, 'books hoe old woman thot nerd boobs bra geek', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marsey1984', 542, 'orwell book ingsoc big brother fascist', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseytzeentch', 1817, 'warhammer 40k chaos god trick magic lies', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marcerberus', 5526, 'threeheadeddog horror halloween holiday greek three headed dog monster', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyangel2', 5526, 'angelic horn trumpet halo wings', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseylawlz', 2133, 'masterlawls zhcyid9 masterlawlz reaction glasses', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseymap', 7056, 'libertarian libertarian map predator', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysonic', 2626, 'hedgehog blue', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycoffee', 2622, 'morning wakeup tea', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysmoothbrain', 1387, 'idiot big brain brainlet retard reaction fool dumbass moron', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseybug', 1387, 'beetle glitch error insect roach', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyshake', 3370, 'cartoon athf aqua fastfood shake dessert icecream', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marfield', 2808, 'mondays garfield lasagna', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseybreadcrumbing', 635, 'bait lure feeding food throwing animated', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyproctologist', 2519, 'exam rectal glove reaction anus anal colonoscopy', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyskeletor', 2546, 'skeleton mask heman 80s man halloween he man cartooon he holiday', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marje', 2321, 'juicebox juice box madje marsey', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseybrave', 635, 'bat browser shill', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marlion', 5214, 'animated flippers wave fins waving mermaid', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyflushzoom', 5526, 'flushed eyes bulging shocked surprised flustered waytoodank', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyhomestar', 4154, 'homestar runner fast everybody 2000s', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseychonker', 1387, 'brap rolls fat obese reaction fds heifer', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyl', 2622, 'loser loss', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyqoomer', 1710, 'shaman viking qanon jan6 capitol january6', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseybane', 3149, 'soy mask batman capeshit', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyjunkie2', 1387, 'addicted drugs pills glue huffing ether overdose', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyrentfree', 542, 'reaction no charge obsessed obsession', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyreportercnn', 2626, 'reporter journalist journoid interviewer', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycountryclub', 4588, 'golfer elite rich golfing cc elitist preppy', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseydomesticabuse', 10432, 'domestic violence bardfinn foid beating punching battering battered bandage hurt pain woman female', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyaward', 5526, 'medal good job good work retard reaction great job great work nice', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseywallst', 5214, 'hodl crypto wall street bets invest gme bitcoin wallstreetbets wsb stock', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyfedscared2', 995, 'glowie glowbipoc federal agent frightened nervous worried panicking fear', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseybear', 5526, 'brian gabby murderer brianna', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycodecel', 4450, 'coder coding coode aevann programming python developer', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marsey666', 5214, 'wings hell halloween demon satan holiday devil animated', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysully', 2465, 'disney pixar monsters inc horned horns', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseything', 2616, 'halloween holiday scary monster teeth', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseychtorrr', 3635, 'reddit administrator place moderator', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marchipmunk', 5526, 'rodent squirrel wuzizname', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseydoctor', 635, 'medic physician white coat stethoscope clipboard checkup diagnosis healthcare', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycia', 1710, 'bane cia glowie plane big guy dr pavel', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyropeyourself2', 635, 'kill yourself kys lynch reaction keep yourself safe hanging noose', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseykyle', 635, 'killer konvict rifle rittenhouse kid gun kenosha kylie', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseystalin', 8239, 'tankie authleft ussr russia communism socialism marxist commie soviet proletariat marxism marxist leninist leninism revolution bolshevik', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseylifting', 1947, 'workout muscular work out bench swole working out gains benchpress weightlifting weights muscles', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseypain', 3652, 'suffering meme kms kill myself cat', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyban', 4240, 'jannie janitor banhammer moderator banned', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyascii2', 4017, 'oldschool', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseydumptruck', 7813, 'pepe butt mellokind thicc thick ass booty cheeks', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysnowman', 5526, 'christmas cold snow winter', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseytinfoil2', 5526, 'alex jones rightoid psycho schizo alexjones conspiracy', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marchipmunklove', 5526, 'chipmonk adoration loving rodent heart eyes adore acorn', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyobamahope', 35, 'happy poster barack', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyorthodox', 2519, 'priest schismatic bartholomew_1 christian', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysadgun', 7813, 'pepe mellokind crying tears suicidal suicide kms frog', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseybunny', 5214, 'furonsa bunny usagi skin animal costume furry fursuit', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycheesehead', 2622, 'packers greenbay green bay football', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyhomosupremacist', 5214, 'klan lgbt faggot kkk homocracy sodomy queer gay wholesome', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyattentionseeker', 7913, 'attention seek notice shout yell desperate narcissist notice', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseylovecraftian', 5214, 'cosmic horror eldritch galaxy space hp spooky scary halloween animated', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycolossal', 5214, 'halloween skin holiday scary mouths', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycenter', 1817, 'reaction grilling boomer centrist', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseybiden2', 5214, 'biden ddd dementia daddy president sleepy joe gas petrol ididthat', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyandjesus', 2210, 'christianity christian jesus god love cute wholesome happy hug', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyhomsar', 4154, 'homsar homestar rslur retard dumb loud shout 2000s', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseypikachu2', 5526, 'pokemon shoked meme reaction surprised shocked gasp', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseylegion', 635, 'zombie wolf fallout new vegas fnv caesar courier video game roman', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseymars', 8239, 'celestial space planet galaxy world solar system alien', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseylaugh', 8613, 'lmao reaction point funny haha lol judgment', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyxi', 1710, 'xi jinping china chinese  asia', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysoylentgrin', 3908, 'numale nu male menslib redditor plebbitor happy glasses soyjak nerd loser beta smile smiling', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseybrianna', 5526, 'trans bear laundrie gabby', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyridin', 5526, 'joe biden kamala harris voted voting election american president hat', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseychungus', 3783, 'bugs bunny meme fat chonker big', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyloadingneon', 10288, 'animated loading spinner webdev rolling ball circle neon', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseybyeceps', 635, 'crying kyle gaige grosskreutz rioter sad', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycarpcrying', 1387, 'tear reaction carpathianflorist fish sob tears sad', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseygigaretard', 1387, 'idiot neurodivergent dumb stupid drooling moron puddle', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseychartscatter', 7913, 'stats statistics chart graph plot data scatter series', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyelephantcumjar1', 1387, 'semen jizz sperm bukkake cumjar elephant', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseybluecheck', 2133, 'journoid checkmark verified journalist drolling drool twitter', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyfedscared', 995, 'glowie glownigger federal agent frightened nervous worried panicking fear', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysipping', 597, 'drinking root drink reaction stare thirsty purple drank juice bored', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseymrsclaus', 2626, 'christmas santa winter boobs', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyschizosallove', 8494, 'animated schizo schizocel rare love sal', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseypolarbear', 7004, 'bear polar cold white arctic ice', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseymeds', 2626, 'mentally ill rightoid doctor psycho crazy mental illness reaction risperidone schizo nurse', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyfeelsgoodman', 7813, 'pepe feels good man mellokind frog happy', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyshooting', 5526, 'blam blatt shotgun kill pow murder', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyhotep', 2069, 'party meme parrot vibing jam dance', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyakumu', 2256, 'simp love loving weebshit', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseypinkcat', 2252, 'homo gay happy ribbon femme girl', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseybraveglow', 5214, 'web browser glowie glow nigger glownigger glowing animated ', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseygrad', 2622, 'graduate graduation school degree diploma hat tassel animated college university', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyaoc', 2626, 'latina latino hispanic cortez mexican puerto rican ocasio congress alexandria', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysockmlep', 1817, 'sock puppet alt anonymous shill', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyschizohobocellove', 8494, 'animated schizo schizocel rare love hobo homeless hobocel', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseybruh', 1387, 'bruhfunny funny or ban', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycalarts', 1710, 'excited eager happy thrilled', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysphinx', 8239, 'sphinx egypt ancient antiquity wonder pharaoh myth riddle puzzle', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycomradehandshake', 5526, 'ussr russia communist shaking hand communism soviet', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyoctopus', 541, 'tentacles kraken tentacled', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseybog', 2622, 'rich brothers bogdanoff', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyemojigrineyes', 1387, 'emoji reaction grin', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyrick', 2626, 'smart 150iq high iq reaction 150 iq morty', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseybateman', 7056, 'bret easton ellis serial halloween patrick american psycho killer holiday blood murderer', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycamus', 1817, 'philosophy history', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseybride', 635, 'dress tiara married wedding veil marseyismywaifu marriage', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseybrianna2', 5526, 'trans bear laundrie gabby', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycatgirl', 1387, 'uwu waifu anime fursona furry owo weebshit fursuit', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseypussyhat', 4634, 'feminist feminism activism activist protester protesting foid gussy woman birthing person roasty roastie thot slut whore', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycupidangry', 5214, 'fire, valentines, love, hate, angry, arrow, bow, kill, attack, shoot, weapon, flame holiday cherub angel', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycarptrophy', 7913, 'carp head decapitated anticarp trophy defeat dead teaparty', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseychessknight', 10214, 'chess knight horse game', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseynoyouglow', 5214, 'fbi no u animated feds glowies glowniggers atf cia nsa', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyblackcop', 635, 'police officer acab thin blue line pig bipoc', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyfurry', 2626, 'fursona furry fursuit kitsune', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyduck2', 5214, 'onesie', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseynotesglow', 2481, 'notes glow cia fbi fed writer writing', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysweating', 5526, 'anxiety worried wipe scared worrying reaction anxious nervous stressed', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysylveon', 635, 'trick or treat pokemon halloween eevee costume holiday', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycatgirl2', 5526, 'anime weebshit', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseydeadhorse', 428, 'drowned pony drowning', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseybabykiller', 4634, 'abortion fetus knife stab planned parenthood infanticide childfree murder foid', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyklenny2', 2050, 'corgi dog puppy klenvastergan smile happy', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyvelociraptor', 381, 'dinosaur velocimarsey extinct predator claws', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyrdramauser', 1830, 'bussy fat lard gay homosexual obese poweruser neet dildo chef hat neckbeard meta', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyblackface', 5214, 'moon cricket jogger nigger racism coon racist minstrelsy jigaboo', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyspyglow', 5214, 'spy agent shill glowie russia china', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseylemon', 5526, 'pucker sour lemon fruit citrus tear ', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyquestion', 5526, 'suspicious sussy reaction sarcastic sarcasm', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyclown', 2519, 'makeup joker', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyflamewar', 1947, 'troll fight fire reaction gasoline', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyxmr', 11080, 'cryptocurrency monero money happy heart', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyill', 8613, 'winter chilly cold ill sick brr flu', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyautism', 5845, 'retarded neurodivergent hat sped aspergers', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseybug2', 5526, 'glitch code error', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysadcat', 542, 'upset disappointing disappointment reaction disappointed sad crying', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marsey4chan', 2626, 'neckbeard anonymous loser hacker', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyamazon', 5526, 'warehouse piss bottle driver wagecuck piss jug pissbottle pissjug wagie', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseydisabled', 2626, 'retarded handicapable handicapped wheelchair crippled', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycensored', 5214, '1984 memory hole censorship repressed', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseydildo', 542, 'horse', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseypin', 1387, 'pinned sticky', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyfrog2', 5214, 'scaley fursona furry scalie amphibian toad fursuit', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyimposter', 5188, 'amogus baka among us sussy', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseybongosnoo', 5214, 'bongo drums music meme jam reddit snoo', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseydrone', 1387, 'obama rotors', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseymayo', 2626, 'yt jakubian crying cracker reaction crackkka crakkka white sad tears', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyfattie', 5214, 'brap fatass chonker pig lorg', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyeyemixer2', 5214, 'mixer stirrer eyes blind selfharm mutilation gore blood gouge', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseymagahat', 5526, 'trump 5200 maga american president election vote nazi hat', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marcake', 5526, 'cupcake birthgay birthday cake frosting celebrate party dessert sweet', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marstolfo', 5526, 'astolfo anime femboy cute blowkiss love heart justcool393 trap warrior', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseytransgenocide', 5214, 'animated trans genocide chud lgbt rightoid bigot gaybros', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyangel', 8613, 'reaction angelic happy innocent', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycarp2', 4588, 'harm cutting selfharm cutter reaction carpathianflorist self animated', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysaluteindia', 8239, 'o7 bobs vagene bitch lasagna pajeet curry desi animated flag patriotic modi', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseywoodchipper', 1710, 'libertarian woodchipper libertarian kill', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyplaty', 4240, 'hearts crossover platypus love', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycut', 4588, 'cutting selfharm emo self harm cutter reaction depressed', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyamogus', 1710, 'sussy baka impostor imposter stonetoss among us shh vent', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseydrama', 1387, 'agendapost where drama seriouspost drama where', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyeyeroll', 4588, 'rolleyes rolling eyes mock animated reaction roll eyes duh', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyfinger', 8979, 'flipping middle finger bird reaction flicking judgment', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyschizosal', 6345, 'schizo sal rare weeks nowhere', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseystein', 2622, 'undead frankenstein abomination halloween holiday monster', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyclown2', 4588, 'joker', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('chudsey', 1829, '4chan virgin pol rightoid', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycapykiss', 2626, 'capybara aevann love mwah xoxo smooch happy love', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseybountyhunter', 4588, 'abortion leather vest cowboy gunslinger texas revolver', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyfreezepeach', 5214, '1984 censorship free speech reaction freespeech ruqqus', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyleafeon', 635, 'trick or treat pokemon halloween eevee costume holiday', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseymeatwad', 3370, 'cartoon athf aqua hamburger', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyemo', 5845, 'girl goth scene woman foid', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseytexan', 3978, 'cowboy hat texas yeehaw pardner rootin tootin', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyprotestyes', 1387, 'agree sign protester reaction approve', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyemperor', 1817, 'gold', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyfeminist', 2519, 'misandry fds scrotes moids', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysociety', 2626, 'batman joker capeshit jared leto', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycarsuicide', 5214, 'kms suicide kill death car vehicle carbon monoxide co muffler suffocation suffocate', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marcusfootball', 542, 'sport handegg hand egg athlete helmet', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseygodfather', 1387, 'wop italy italian dego mafia', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseygift', 8613, 'present christmas wrapping paper holiday', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseynyansuperstraight', 5214, 'animated straggot pride heterosexuality space flying', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marmsey', 1058, 'rodent happy', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyhandsup', 1387, 'hands up pawsup arrested arresting reaction paws up under arrest', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyfrog', 5214, 'scaley fursona furry scalie amphibian fursuit', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseykfc', 2626, 'col sanders colonel kentucky fried chicken', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyzombiewolflove', 5214, 'hug cuddle love marseylove zombiewolf zombie wolf', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycanadian', 5244, 'southpark canada leaf terrance phillip animated fart', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyimpossibru', 5526, 'revulsion gross yuck yikes mad icky impossible disgusted disgusting', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyhead', 4588, 'blood spurting headless horror halloween animated', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyhippo', 5214, 'hippopotamus hippo fursona furry skin animal costume fursuit', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycapyblackface', 5214, 'racist minstrelsy bowtie racism capybara aevann', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysaltlicking', 1387, 'salt lick rock', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyeldritch', 5526, 'lovecraft horror halloween tentacles holiday scary monster', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyerasure', 2622, 'erase ignore block', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysalutepride', 5214, 'saluting 07 military soldier gay pride lgb rainbow', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyhellraiser', 5526, 'pinhead halloween holiday evil monster', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyschizobyolove', 8494, 'schizo byo byobombs rare love', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyjourno', 993, 'journoid media press photo camera journalist pic', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseydevil', 2256, 'pitchfork daemon hell halloween demon mischievous satan holiday heck evil', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marsey69', 5244, '6ix9ine snitch tattooed tattoos rapper', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseygrilling', 542, 'barbecue bbq centrist boomer barbeque', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseytankushanka', 1947, 'military ussr ccp communist authleft tank army communism china soviet russian', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseywitchtriggered', 3149, 'witchcraft angry spell bardfinn tranny train troon snowflake redditor wvp magic science animated', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyfeynman', 1817, 'history', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycapypharaoh', 1710, 'aevann egypt alien king', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseykink', 2626, 'bdsm sex kinkster dom pervert sub creeper latex fetish dildo pvc', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycontemplate', 2490, 'reaction consternation thinking hmm', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycapychad', 9977, 'aevann chad capy chadybara capybara muscular swole ripped egypt ouch tanktop', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyarmy', 150, 'chiobu soldiers o7 salute saluting', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyfeet', 1387, 'foot frozenchosen fetish', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyfeelsgood', 2069, 'meme frog feels good man pepe feelsgoodman happy', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysal', 7615, '2 weeks two weeks sallie white shark', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseybait', 2626, 'trolled baited trolling redditor', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseybadass', 3735, 'badass whoa neil degrasse tyson science mustache ifls smug', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseygrass', 2626, 'reaction outside touchgrass touch grass', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyschizoabsinthelove', 8494, 'animated schizo schizocel rare love absinthe frog', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyaynrand2', 3635, 'ayn rand objectivist objectivism libertarian girlboss capitalist capitalism book atlas shrugged', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysockpuppet', 1817, 'animated sock puppet alt anonymous shill', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyracist', 2626, 'racing vroom racecar bigot reaction', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyschizopennylove', 8494, 'animated schizo schizocel rare love penny', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseybear2', 5214, 'ursine bear fursona skin animal costume furry fursuit', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyheathcliff', 2546, 'heathecliff', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseypartymaxx', 5214, 'party meme parrot vibing jam dance', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycarp', 1376, 'beard mohawk reaction carpathianflorist monster', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseymalding', 3259, 'dilate seethe scrote mad moid cope', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseybingus', 5244, 'floppa shaved hairless', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseybarrel', 542, 'barrel container beer bar alcohol', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycthulhu', 1817, 'horror halloween lovecraftian holiday eldritch evil scary monster', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysoldieramerica', 1710, 'army war gun rifle burger mutt', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseydeuxfoid', 1738, 'deuxrama asian azn hardislife hil', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marsey300', 5214, 'leonidas shield armor thermopylae spear greek spartan', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyhealthy', 2626, 'burger king fat fast food crown unhealthy junk food american', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyhoodwink', 1809, 'cloak crossbow', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyinshallah', 5214, 'begging muslim animated please', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyrowling', 2626, 'harry potter terf jkr transphobe', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycapyparty', 5214, 'trip animated wooo aevann admin party parrot', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyburger', 542, 'burgerstan hamburger cheeseburger mutt american', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyextinction', 5214, 'extinction button women misogyny mayocide kazakhstan', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyowow', 1387, 'reaction excited owo', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseybux', 2622, 'money paypig currency dollar bill primo premium dollarbill cash', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseymarseyloveorgy', 3149, 'reaction love blush aww hugging cuddling cuddle snuggle snuggling hearts xoxo nested recursion inception orgy group', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyfrenchvan', 6113, 'foucault pedophilia libertarian van french philosophy pedobear postmodernism', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseychucky', 5526, 'doll halloween kill stab knife holiday possessed monster', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyhorseshoe', 2626, 'rightoid leftoid theory', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyglowaward', 5214, 'medal fbi ribbon animated glownigger retard glowie fed atf cia nsa', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycat', 5214, 'fursona skin animal costume furry neko fursuit cat', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyyesandno', 5214, 'agree disagree both confused indecisive trippy animated inconclusive idk fencesitter switzerland', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyoyster', 5214, 'pearl shellfish clam give', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseylongpostglow', 768, 'animated pippy glow fedpost longpost words mad angry rage wtf green chud fbi mossad fed atf police reaction scrolling', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyumbreon2', 2626, 'pokemon eevee furry eeveelution evolution', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseylovedrama', 5214, 'hearts rdrama reaction happy animated', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseykys', 5214, 'reaction keep yourself safe kill yourself suicide', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseybackstab', 2626, 'betrayal kill knife caesar assassinate betrayer murder', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseymodelo', 5099, 'cheers alcohol drinking beer', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycorn', 4588, 'iowa vegetable', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseydylan', 635, 'columbine school shooter psycho gun pistol klebold', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyfug', 3336, 'benis mustache meme', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseypunished', 5845, 'punished venom snake metal gear solid kojima eyepatch', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyschizohanklove', 8494, 'animated schizo schizocel rare love byo hank', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycharlesmanson', 8239, 'charlie manson charliemanson murderer killer swastika crazy psycho schizo helterskelter prison cult', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseymacarthur', 542, 'nuke missile nuclear bomb history', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyisraellove', 4240, 'love ally israel holocaust zionism', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyskull', 7056, 'skull dead skeleton punisher kill bone', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseygondola', 7056, 'mustache meme long legs', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseymermaid', 542, 'merman merfolk', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseymodelo2', 5099, 'cheers alcohol beer drinking', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycarphug', 5526, 'love squish squeeze hug squeeze fish carpathianflorist', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycapymad', 1387, 'shaking aevann mad angry fury furious anger shook animated capybara', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycutattention', 768, 'razor cry depressed kys cut attention borderline bpd blood cutting woman foid', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseydragon', 5526, 'smaug rich hoard gold treasure', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycarpdino', 381, 'dinosaur costume furry fursuit carpathianflorist extinct reptile lizard rawr prehistoric jurassic', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyllama', 5845, 'alpaca', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyit', 5526, 'balloon halloween pennywise clown holiday evil', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyplace2', 7466, 'pixelart pixellated reddit lowres', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseybow', 7913, 'bow ribbon happy cute adorable accessory gift present', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseynpc', 2513, 'sheeple', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseypearlclutch', 2622, 'sensitive reaction snowflake puritanical gasp sjw', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysimpson', 2465, 'yellow simpsons groening homer bart lisa marge cartoon', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseypaint', 2590, 'low effort art', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyfamily', 1387, 'family guy family man peter griffin griffin peter', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseymaoist', 746, 'marxist little red book marxism ccp chinese communist authleft maoism communism china', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyliondance', 5214, 'parade ccp chinese dancer dancing asian china animated', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseykvlt', 2256, 'horgh abbath black metal krieg bullet belt immortal corpsepaint', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseybrick', 1994, 'throw riot subtlety broken paver', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseychartbar', 7913, 'stats statistics chart graph plot data bar column', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycleonpeterson', 5214, 'wtf scary art', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyauthleft', 1817, 'marxist ussr marxism ccp communist khmer rouge leftoid communism juche', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseytombstone', 2622, 'dead death gravestone cemetery graveyard rip rest in peace', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyglaceon', 635, 'trick or treat pokemon halloween eevee costume holiday', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyben10', 2626, 'ten anime cartoon lawlz', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseychristmaself', 993, 'christmas xmas santa holiday happy worker', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyretard3', 5526, 'drooling stupid idiot sped moron imbecile dolt', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseypunching', 4588, 'battle squaring up hit square up boxer fight throwdown reaction boxing fistfight fighting', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseymissing', 3141, 'absent low effort', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseybarreldrunk', 542, 'barrel container beer bar alcohol drunk', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyrevolution', 2256, 'marxist ussr marxism ccp hammer communist sickle communism proletariat juche kgb', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyslowpoke', 1994, 'pokemon stupid late anime weeb meme', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseybuttface', 8239, 'butthead ass donk rimjob eat ass rump rear shit fart', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseymummy2', 2554, 'egyptian halloween monster holiday', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseymoose', 5214, 'moosin antlers', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseynut', 5244, 'orgasm ahegao cum reaction coom', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycatgirl3', 5526, 'anthro anime weebshit', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycommitted', 4240, 'psycho crazy insane straitjacket asylum reaction loony bin straightjacket', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyderanged', 635, 'crazy psycho mad disgusted angry rage violent baseball bat', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyniqab', 635, 'burka islam muslim burqa', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseykwanza', 597, 'christmas black kwanza african holidays', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyllama3', 5845, 'bottom', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseymyspacetom', 3652, 'carp friend carpathianflrost anderson', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysaturn', 1817, 'devouring eating snoo kill de goya anger reddit', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseypharaoh', 1376, 'egyptian aevann pyramids', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyburn', 5214, 'fire flame grill burning hot red hell', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycumjar3', 1828, 'semen jizz sperm spunk bukkake', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseypopcorn', 4122, 'eating entertained drama happy animated', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseykingcrown', 5214, 'based animated', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseypixel', 2622, 'reaction lorez lowres', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyyugi', 1948, 'yugioh yu-gi-oh! cards trap anime', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseymati', 150, 'annoyed irritation top hat reaction angry irritated tophat', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycarpasian', 1387, 'carpathianflorist fish azn racist hat paddy gook nip ching chong chink', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseynull', 5214, 'kiwifarms joshua moon josh dog', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyqueenlizard', 4588, 'england bong english british reptilian elizabeth', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseytoasterbath', 4084, 'suicide suicidal kill death bathtub electrocution electricity kms', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseypsycho', 768, 'reaction schizo crazy', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysoypoint2', 6749, 'wojak soyjak soyjack pointing beta redditors', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseymancer', 5526, 'dead undead horror lich halloween necromancer zombies zombie holiday evil', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyfursonatext', 2626, 'fursuit fox fursona fursecution furfag yiff uwu owo kitsune', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseychonkerfoid', 3259, 'female woman fds fat obese hambeast landwhale porker pig bleeder birthing person bangs', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycapychad3', 9977, 'aevann chad capy chadybara capybara muscular swole ripped egypt nude naked', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseypleading', 1904, 'sad eyes begging puppy dog eyes', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyheavymetal', 1817, 'rocker musician rock guitar', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyminimalism', 3652, 'orange minimalist square art', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseystrawman', 5526, 'logical fallacy strawmarsey argument debate hat', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseynpc2', 1387, 'reaction idiot sheep', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyobese', 5214, 'fat chonker bbw chonk chunky pig lorg', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseypickle', 1947, 'funniest shit morty rick', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyglancing', 4588, 'eyes animated nervous paranoid', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyschizojoelove', 8494, 'animated schizo schizocel rare love joe biden', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyfrozen', 2490, 'dead ice reaction cold frozen', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyoceania', 5214, 'kiwi new zealand kangaroo newzealand australia', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseynapoleon', 1962, 'baguette soldier frenchman history', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseypumpking', 5526, 'jackolantern jack o lantern halloween holiday', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyzombie2', 1387, 'undead living dead romero halloween horror corpse scary rotten', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycontemplatesuicide', 635, 'gunshot mirror contemplate contemplating reflection pistol handgun death kms kys suicidal die death', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseykatamarireddit', 6914, 'rolling animated vidya video game damaci damacy reddit', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseytarrant', 2616, 'branton brenton newzealand kiwi shooter shooting killer ebba akerlund murderer rightoid chud strong', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseypumpkin', 2622, 'jackolantern carving halloween holiday jack o lantern', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycatgirljanny', 1387, 'anime maid weebshit', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseypuke', 4588, 'hurl throw up gross animated illness vomit nauseated reaction upchuck nauseous sickening yuck barf ralph judgment', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyjolteon', 635, 'trick or treat pokemon halloween eevee costume holiday', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseynyanlgbt', 5214, 'animated gay pride homosexuality space flying', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyeyeroll2', 1710, 'animated duh rolling eyes', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyclappingglasses', 3259, 'applaud applause hooray yay good job gj animated nerd', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyminion', 4549, 'gru pixar', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseygodzilla', 1817, 'raptor halloween dinosaur gojira evil bug', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysopa', 3127, 'brazil soup macaco monkey teeth fangs scary', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyatlasshrugged', 3635, 'ayn rand objectivist objectivism libertarian girlboss capitalist capitalism book atlas shrugged', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseygodel', 1817, 'old philosophy glasses history', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyn8', 1858, 'nate redditor powermod powerjannie moderator', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyneko', 10881, 'autism autistic cute neko nekobit fedi fediverse hat programmer codecel', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyoutletsuicide', 1948, 'fork outlet plug socket kill kms electricity electrocution electrocute death die', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyconstellation', 3149, 'starsey galaxy space sky', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseychartpie', 7913, 'stats statistics chart graph plot data pie categorical', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyfbi', 253, 'cop glownigger fed glowie agent federal', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseychocobo', 8239, 'marseybo bird final fantasy vidya video game gamer gaming fast', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyjcdenton', 4365, 'sunglasses shades vidya video game deusex deus ex', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyschizocarplove', 8494, 'schizo carp love rare excited', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseymutt2', 5244, 'american burger 56 percent mayo', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseynooo', 5526, 'reaction snob no way', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyaynrand', 3635, 'ayn rand objectivist objectivism libertarian girlboss capitalist capitalism author randsey', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycapypunished', 3652, 'capybara rodent aevann cute metal gear solid venom snake video game kojima mgs', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseypride', 5214, 'prideflag rights', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseydawnbreaker', 2256, 'gamer video game warhammer', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycapywalking', 5526, 'capybara animated aevann', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyllama1', 5845, 'top', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseylion', 5214, 'fursona furry fursuit leo', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyplane', 5214, 'flying jet pilot', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyhammersrdine', 3259, 'animated beat bongo hammers sardine redditors can the', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseynerd', 653, 'dork loser dweeb geek glasses aevann', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseypilgrim', 1994, 'thanksgiving puritan holiday', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyspinner', 1710, 'animated loading webdev spin circle', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseynintendo', 2626, 'mario gamer switch gaymer video game mustache soy', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycoonass', 1088, 'student lsu university louisana state', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyhacker2', 1817, 'dox anonymous computer', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseypop2', 1738, 'excited blahblahblah blah blah blah animated', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyspookysmile', 1817, 'horror halloween holiday evil scary monster', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyobama', 1710, 'obama president black drone reaper predator', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyagreefast', 5214, 'nodding yes sure ok animated enthusiastic enthusiasm', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseypepe2', 2406, 'reaction frog mellokind', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseytaliban', 1866, 'mujahideen janniejihad islam afganistan shariah afghanistan muslim', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyhope', 5526, 'mask whitepill reaction happy hopium', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysmudge', 4588, 'diogenesjr diogenesjunior meme', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyeyemixer', 5214, 'mixer stirrer eyes blind selfharm mutilation gore blood gouge', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyrussel', 1817, 'old pipe history', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyglow2', 5845, 'fbi mossad feds agent glownigger reaction glowie fed atf cia nsa', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyhappening', 2622, 'ronpaul happening it ron paul itshappening animated', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyghost', 993, 'spooky halloween costume holiday scary sheet', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseybuff', 3978, 'ripped muscular 6pack swole 6 pack sixpack abs six pack muscles', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseymayoface', 768, 'black blackface whiteface mayo mayocide mayonnaise racist racism', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseypizzashill', 1962, 'sex haver chad grass toucher', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysaw', 5526, 'doll horror halloween jigsaw monster evil torture game holiday', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseybraveheart', 768, 'movie mel gibson william wallace scotland scottish sword claymore blue paint celt highland', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marsoyhype', 1387, 'soyboy soybeard nerd marsey excited wojak cuck', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyschrodinger', 244, 'philosophy science physics math', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysting', 8239, 'drum badumtiss ba dum tiss bad dum tiss baddumtiss comedy humor punchline animated standup joke', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycapychad2', 9977, 'aevann chad capy chadybara capybara muscular swole ripped egypt', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseylizard', 2519, 'reptilian', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyschizochadbasedcapylove', 8494, 'animated schizo schizocel rare love chad based capy aevann', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyjanny', 542, 'jannie unpaid volunteer administrator janitor free moderator', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysus', 768, 'amogus among us stonetoss sussy baka amongus', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycoomer', 1947, 'masturbation goon cumbrain porn masturbate', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyblind', 8021, 'sight stick disability blind glasses disabled handicapped', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseypimp', 1387, 'dramamine slickback purple baller', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseypikachu', 2622, 'electric pokemon yellow', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseymerchantelf', 2069, 'jew christmas elf santa greedy money chosen worker holiday xmas seth rogen sarah silverman holocaust coin kike', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyilluminati', 2519, 'eye egypt pyramid big brother watching', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseymonke', 2626, 'retvrn return', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycop', 635, 'acab thin blue line chauvin police officer', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyblueanime', 2546, 'cirno touhou weebshit', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysnowflake', 5845, 'special snowflake sensitive snow', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyshisha', 2256, 'weed smoker smoking hookah', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseynyan', 5214, 'space animated meme poptart', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseylenin', 8239, 'ussr russia communism socialism marxist commie soviet proletariat marxism marxist leninist leninism revolution bolshevik', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseynietzsche', 1817, 'philosophy history', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyblackfacexmas', 5214, 'uncle tom moon cricket christmas santa beard nigger racist claus coon', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyschizochadseethecapylove', 8494, 'animated schizo schizocel rare love chad seethe capy aevann', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseypepe', 3978, 'ok rightoid mellokind frog reaction', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysheep', 5214, 'follower wool lamb fursona bah furry fursuit', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyjohnson', 1817, 'wig history', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysalad', 1387, 'vegan cabbage vegetarian lettuce vegetable', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyjoseon', 8094, 'korean hat azn asian', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyschizochadyescapylove', 8494, 'animated schizo schizocel rare love chad yes capy aevann', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseybrap', 5845, 'brap sniff smell huff gas fart animated', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycutwrist', 768, 'suicide slash wrist razor blood cry tears sad depressed depression kill dying kys cut cutting', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseypoggers', 1387, 'poggies twitch meme quagmire jawdropping shock surprise', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseykweenxmas', 5214, 'blm black christmas santa bipoc nigger bame hat holiday', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseypostmodern', 995, 'postmodernist obscurantist art', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseykoolaid', 4634, 'oh yeah juice cult ice pitcher drink', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyrs', 5214, 'runescape party hat phat crown lowpoly low poly', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseystinky', 2256, 'smelly homeless stank poor ew yuck', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseypumpkinglow', 5214, 'halloween drama holiday jack o lantern animated', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseygroomer', 2626, 'pedobear discord pedophile pedo chomo molest pedocord', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyembrace', 3141, 'embracing hugging love happy', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyparty3', 5214, 'trippy animated happy dance', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycapy', 5526, 'capybara rodent aevann happy cute', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysanta', 4122, 'christmas gifts presents claus holiday', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysalutearmy', 5214, 'saluting o7 military soldier', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysalutecop', 5214, 'acab officer saluting o7 police', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseypirate2', 5214, 'party parrot eyepatch partyparrot', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseypretty', 5526, 'flirt starry eyed stars in eyes', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseypainter', 1794, 'palet reaction pallet paintbrush paints artist pallette', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycringe2', 1387, 'grimace grimacing yikes oof bruh moment', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseydracula', 4549, 'halloween fangs cape holiday vampire', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('thinbluefeline', 5244, 'cops police', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyfursona', 2626, 'fursuit fox fursona fursecution furfag yiff uwu owo kitsune', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyjoint', 4588, 'smoke weed marijuana reefer drugs smoking 420 pot', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseygras', 1738, 'mardi gras fat tuesday nola new orleans neworleans holiday louisiana mardigras carnival beads mask', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyschizocapylove', 8494, 'schizo aevann capybara love rare excited', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseypanda', 4588, 'red panda bear happy redpanda', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('goldenshower', 5214, 'pee piss golden shower fetish trump sex rain storm clouds', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseypin2', 4240, 'sticky pushpin award', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyspit', 4588, 'surprising reaction shocking water surprised shocked', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseykys2', 1817, 'keep yourself safe', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycapyeffendi', 2256, 'capy aevann fez egyptian ottoman', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyobamarope', 35, 'barack suicide kms kys hanging noose poser', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycupid', 5214, 'cupid, love, heart, valentines holiday, marry, wedding, couple, kiss, wink, sex, arrow, bow, shoot animated', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysosa', 1809, 'chief keef sosa glo rap hiphop music drugs lean black', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseytea', 4122, 'drama spill', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseytheorist', 1387, 'ancient aliens meme', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyfrozenlove', 9790, 'mellokind stalker obsessed obsession fixation creepy stalking frozenchosen love hug foid hearts', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyshitforbrains', 6749, 'brainlet poop dumb litterbox litter box soyjack soyjak redditor retarded scat', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseywtf', 1387, 'scared reaction shook surprised shocked', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseytrump', 2626, 'cheeto hitler president history orange man', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseylowpoly', 5526, 'polygonal spinning 3d lopoly animated', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseymyeisha', 1817, 'kween black fds', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseypopcorntime', 5214, 'eating popped corn drama animated watch', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseygoodnight', 1794, 'kazakhstan flag reaction kazakh i hate women women', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseymummy', 1817, 'egyptian halloween monster holiday', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseytunaktunak', 5526, 'turban animated curry indian pajeet dance', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyplaying2', 5526, 'fish playful mischief srdine animated', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycreepy', 1387, 'pervert pedophile weird reaction chomo creeper sketchy molester', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseymime', 5526, 'mimesey facepaint black and white beret silent mute performer', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysneedboat', 8494, 'animated ship flag capybara', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseytrollolol', 5214, 'rage trolled rageface', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyobamanope', 3149, 'no way wrong poster barack', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyglobohomo', 1387, 'globalism soulless modernity art corporate corporation', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysmug', 542, 'reaction superior haha', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseypeacekeeper', 2519, 'united nations un rifle helmet gun', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseymask', 4240, 'plague coronavirus covid pandemic coof sickness love heart eyes illness', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyevilagent', 8021, 'feds agent glowies usa america waco swat m16 firearm rifle satan demon cops police', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycheeky', 1387, 'stick tongue brat reaction taunt na tongue out tease', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseypathetic', 5526, 'pathetic asuka', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseypanties', 8979, 'reaction underwear panty pantsu', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseygeisha', 5526, 'foid birthing person girl woman girl lady slut thot noodlewhore chink jap gook asian azn blow kiss blowing kiss blowkiss love heart stockings nylons fishnets', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseytoilet', 2626, 'flush loo bog roll toilet paper swirly', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseymugshot', 5214, 'arran prison arrested criminal jail', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyprotestno', 1387, 'sign protester refuse reaction deny reject', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyuglyxmasweater', 4565, 'santa hat christmas ugly holiday', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseymushroomcloud', 3149, 'atomic bomb nuke kaboom explode explosion war radiation', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysherpa', 8021, 'mountain climbing travel nepal himalaya asia everest', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseymechanic', 5214, 'wrench car diy fix repairman dipfuck', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseydab', 5526, 'reaction haters', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyplaying', 5526, 'fish playful mischief srdine animated', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyazov', 542, 'ukraine ukrainian nazi battalion dead russian war soldier corpse chud', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyteaparty', 2256, 'donger arran soren carp duck', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseypharaohcat', 5214, 'egyptian illuminati aevann pyramid sand ancient alien artifact museum history king cleopatra', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseytv', 2622, 'willy wonka telly television', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseybeandefiant', 1828, 'bean defiant tongue opposed disagree', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseymao', 7057, 'zedong ccp chinese communist communism china', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyotter', 5214, 'otter, fish, sea, swim, lake, nature, seal, sealion, river. wuzizname, float', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyuwuw', 1387, 'fursona furry fursuit', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysamhyde2', 4928, 'gun shooter sammy mdegenerate milliondollarextreme million dollar extreme', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseytrollcrazy', 7056, 'i hate killher psycho rage kill her gun', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseylibleft', 1817, 'unemployed protest riot anarcho capitalist antifa anarchist anarchy', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyyeezus', 2056, 'kanye god hotep', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseypop', 2890, 'action figure doll funko toy soy', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseythomas', 4588, 'tank engine train locomotive', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseypony', 1948, 'murmurwisper mlp my little ponies cutie mark horse furry my little pony', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseypope', 1947, 'priest catholicism rome', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyhankhill2', 3370, 'propane cartoon hank grill kingofthehill', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyracistgrandpa', 2626, 'thanksgiving fuck nigger holiday', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyantischizo', 8494, 'rare meta schizocel scizocel skitzocel schizophrenic scitzocel', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyemojigrin', 1387, 'emoji reaction grin', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyfuckoffcarp', 5526, 'reaction carpathianflorist rude snappy animated robot marppy', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyramen', 5214, 'eating noodles food bowl animated soup', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyhearts', 832, 'reaction flirt loving adoration love happy cute crush', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyobey', 4240, '1984 sign ingsoc poster big brother', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyrave', 5526, 'dead animated party death sandstorm darude crab dance', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyquadmagyar', 2256, 'bow and arrow hungary hungarian archery bowman quadnarca', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyemojismilemoutheyes', 1387, 'emoji reaction smile', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyunamused', 8613, 'annoyed staring reaction disappointed stare uh huh bored', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyrasta', 4588, 'marijuana weed dude weed lmao ganja drugs pot reggae joint jamaican', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseymommymilkers', 1710, 'pepe mellokind momma booba khazar abby shapiro tits breasts boobs', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyteruteru', 5526, 'ghost flying spooky halloween holiday floating', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseynoyou', 5526, 'nou no u pointing', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseypumpkincloak', 2056, 'costume halloween holiday', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycumjar1', 1828, 'semen jizz sperm spunk bukkake', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyfbiagent', 8021, 'feds fbi agent glowies usa america waco swat m16 firearm rifle cops police', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyyes', 5526, 'thumbsup agree right thumbs up reaction judgment', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseypokerface', 8979, 'small eyes reaction stare unreadable beady eyes', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysad2', 8979, 'reaction disappointed disappointment upset', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyface', 2626, 'mask psycho face horror halloween kill killer stab knife holiday evil murder scary murderer', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyjumpscare', 1387, 'undead living dead romero halloween horror corpse scary rotten animated spooky aaaahhhhh trick prank bait and switch', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseydefenestration', 5214, 'suicide window jump kill murder kms jump out window death die defenestrate', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseydeux', 542, 'frenchman deuxrama baguette frog frenchie', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyjunkie', 1387, 'needles heroin reaction shooting up addicted shoot up syringe', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyclippy', 3259, 'msoft microsoft word helper paperclip writing annoying', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycanada', 5214, 'leaf canadian canuck rake hockey donut trudeau maple', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyhelp', 1387, 'wtf nervous anxious anxiety worried concerned helpme help me uncomfortable awkward', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseymar', 8239, 'dexter lab foid destruction irritating annoying sister cartoon network pigtails', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseytalking', 5214, 'speech bubble smug gossip', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseypumpkin3', 3211, 'witch jackolantern carving halloween holiday jack o lantern', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseychad', 1387, 'canthal tilt jaw hunter eyes', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyrat', 1387, 'rodent black', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyschizodoggilove', 8494, 'animated schizo schizocel rare love dussy doggi', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyeric', 635, 'columbine school shooter psycho gun carbine harris', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseychinesedevil', 1387, 'devil evil horns satan china hell demonic', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyschizocapygitcommitlove', 8494, 'animated schizo schizocel rare love chad capy git commit fsdfsd', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyradioactive', 2519, 'nuclear waste chernobyl radiation geiger', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyawardretard', 3259, 'medal retarded drooling idiot moron prize congratulations congrats', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseytimmy', 8239, 'turner nickelodeon fairly oddparents hat boy cosmo wanda', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycactuar', 8239, 'cactuar final fantasy cactus soy shocked cactuarsey 1000 needles vidya video game', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseydizzy', 2626, 'puke nausea spinning vomit reaction nauseous sick rolling barf animated', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyorthodoxsmug', 3652, 'schismatic heretic scoff christian priest gloat', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyturkey', 1994, 'beak bird thanksgiving holiday feathers', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseytroll2', 2256, 'ogre horror halloween holiday monster', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseybootlicker2', 5214, 'sheep conformist lapdog rightoid conservative trump idiot shoe hearts', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyditzy', 5526, 'pokemon', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysanders', 2626, 'bernie rich socialism socialist jewish', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseymoney', 1387, 'capitalism capitalist rich dollar signs bag wealthy dollars dinero', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseykamikaze', 5214, 'kamikaze japanese nip pilot ww2 wwii world war', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseypumpkin4', 3211, 'ghost jackolantern carving halloween holiday jack o lantern', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyblops2cel', 5526, 'incel volcel black ops gamer iconic saint', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseymeowth', 5214, 'pokemon weeb anime, manga team rocket nintendo video game vidya monster', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysurprised', 8979, 'reaction shocked shook unexpected', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseywarboy', 993, 'witness warboy nux madmax mad max apocalyptic evil apocalypse', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseydemiurge', 1817, 'gnostic gnosticism demiurge', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyobesescale', 5214, 'fat chonker bbw chonk chunky pig lorg', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyzoomer', 1387, 'child brat kid zoomie', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseygoose', 5525, 'goose geese kill duck cat bird death bite chomp', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseywendy', 4549, 'jellyfishjam pigtails redhead pippi', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseypresents', 2616, 'christmas gifts santa holiday candy cane happy', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyandmarcus', 2513, 'bed sleeping cuddling cuddle marseyismywaifu', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyhesright', 10181, 'batman lucius fox nolan hes right you know reaction agree thumbs up based morgan freeman correct', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycarplazy', 201, 'carpathianflorist fish couch sleeping slacker idc antiwork janitor', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseygoose2', 3783, 'goose geese kill cat bird death bite chomp', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseytwins', 5214, 'halloween holiday flashing shining scary animated', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyseven', 2256, 'vidya gamer gaymer video game assassin hitman', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysmirk', 8979, 'reaction snicker trolling lol', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyllama2', 5845, 'middle', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyisrael', 2873, 'kike yid jewish hebrew merchant colonizer israeli banker', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyhammerpizza', 3259, 'animated beat bongo hammers pizzashill rdrama', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyakbar', 5214, 'suicide bomber explosion boom explode die kms animated', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseypanda2', 5214, 'panda bear fursona skin animal costume furry fursuit', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyjason', 5526, 'hockey mask horror halloween kill fridaythe13th knife stab voorheys friday the 13th evil monster holiday', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyschizodongerlove', 8494, 'animated schizo schizocel rare love kaiser uraniumdonger donger', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysamhyde', 8239, 'gun shooter sammy mdegenerate milliondollarextreme million dollar extreme', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyskeleton2', 2256, 'bones spooky halloween holiday skeletal', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyditto', 3149, 'pokemon weeb anime blob happy', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyyinzer', 4017, 'pittsburgh pennsylvania pens penguins steelers stillers pirates buccos buckos terrible towel pierogo yuengling beer city hat baseball football hockey nfl mlb nhl happy', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyantiwork', 5214, 'lazy laze bum unemployed animated', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyno', 5526, 'denied refuse rejection reaction ugh deny hand', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyseethe', 1947, 'dilate mask crying seething smug cope', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyloading', 5526, 'animated loading spinner webdev rolling ball circle', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyterrydavis', 7272, 'templeos nerd programmer glownigger', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyjetfighter', 8239, 'pilot plane airforce air force usaf bomber dogfight war', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysnek', 4122, 'snake serpent', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyraccoon', 5214, 'trashpanda trash panda', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('merdesey', 244, 'turd turdsey shitsey poopsey shit poop poop marsey shit marsey', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyvengeance', 2069, 'gore undead shotgun horror halloween revenge monster bloody head wound holiday', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysmugretard', 6345, 'srdine drooling brainlet idiot fool buffoon idiot', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyoverseether', 1947, 'rdrama meta seething fire red bigmad angry anger', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysunflower', 3259, 'love ukraine threatening pointing russia', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('mlm', 5214, 'marseylivesmatter marsey lives matter blm', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysoutherner', 9977, 'plantation suit cigar good ol boy buck breaking buck breaker', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseykrampus', 2256, 'demon monster christmas', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyshook', 8613, 'reaction surprised shocked gasp astonished', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseykiwi2', 5526, 'kf bird new zealand kiwifarms newzealand', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseykkk', 993, 'klan kukluxklan ku klux klan racist costume klux ku sheet', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyfingergoodjob', 5214, 'cute encourage positive respect k-pop thumbs up congrats gif animated congratulations nice ok great', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseybutt', 5845, 'booty ass rump sexy hot pawg pawc paoc anal sodomy donk dump truck dumptruck mellokind', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseybased', 5214, 'basado king chiobu redpilled reaction animated', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseydarwin', 1817, 'history darwinian euphoric atheist charles', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycrystal', 3166, 'gem crystal diamond sparkle precious shiny glass', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyschopenhauer', 1387, 'philosopher old grandpa', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyfrontiersman', 8021, 'america usa 19th history indian native wild nature rural frontier expansion settler', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycheerup', 5214, 'pat animated depressed comforting grieving reaction depression there there console comfort pet', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysuper', 2519, 'superstraight lgbt', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysephiroth', 8239, 'ff7 ffvii final fantasy vidya video game gamer gaming villain sword', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseydream', 1828, 'spirals trippy swirls rainbow', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyplugged', 2626, 'electric technology gif animated plug', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyschizobussylove', 8494, 'animated schizo schizocel rare love certified bussy operator', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseykitty', 1738, 'hellokitty animated hello kitty', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyespeon', 635, 'trick or treat pokemon halloween eevee costume holiday', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyoctopus3', 3908, 'consume product epic win communities no bait too obvious globe patch', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseytrotsky', 8239, 'icepick trotskyist betrayal ussr russia communism socialism marxist commie soviet proletariat marxism marxist leninist leninism revolution bolshevik', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyrussiadolls', 5214, 'toys ussr babushka matryoshka soviet', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysadge', 2069, 'frog pepe', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyshiftyeyes', 2256, 'suspicious sussy paranoid weird reaction sketchy', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseykindness', 995, 'retarded special drooling idiot seriouspost srspost agendapost moron fool buffoon dramatard', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyrightoidschizo', 1387, 'nazi conspiracy crazy tin foil tinfoil conservative animated ruqqus', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyspider', 1828, 'insect halloween arachnid holiday bug', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseygarfield', 2546, 'mondays lasagna', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseykkkblm', 5214, 'ku klux klan racist nigger jogger coon jiggaboo cracker crackkka', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseypunisher', 5244, 'thin blue line rightoid police cops', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycrying', 4588, 'tear cried despair weeping reaction depression sob tears sadness depressed animated sad', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyopossum', 5845, 'possum trash', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyaustralian', 4634, 'beer fosters mate hat gday crikey oz', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyremastered', 8159, '4k hd hi def hidef high definition uhd rtx', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyreindeer2', 1817, 'santa christmas rudolf holiday', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysoyrope', 6749, 'redditor dead suicide kms kys hanging lynched hung soyjak', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseywheredrama2', 5214, 'seriouspost animated agendapost', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseybootlicker', 5214, 'sheep conformist lapdog rightoid conservative trump idiot shoe', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyspooky', 5526, 'art horror halloween holiday evil scary monster lovecraftian eldritch', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycop3', 5214, 'police officer acab fuck12 rifle gun law enforcement sheriff', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyretro', 6382, 'cardboard retro gameboy green nerd gamer', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyorthodoxcarphug', 3652, 'schismatic heretic embrace hug love bartholomew carpathianflorist', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyportalsuicide', 5214, 'kill shotgun shoot death die kms animated', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyking', 1701, 'based queen prince reaction crown princess', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseykrampus2', 1794, 'demon monster christmas', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseykino', 3140, 'kino agni fire punch anime', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyavril1', 5526, 'lavigne canadian leaf beautiful hot sexy punk rocker singer musician artist tie sk8er boi complicated brunette', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseypumpkin2', 3211, 'jackolantern carving halloween holiday jack o lantern', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyunabomber', 542, 'package industrial society delivery mail kaczynski uncle ted', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseylong3', 4122, 'bottom meme', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysickos', 3652, 'hahaha ha ha ha yes onion comic pervert sicko creep', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyelephant', 2256, 'oliphant dumbo', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyprideflag', 4154, 'pride flag marseysexual sexuality lgbtq gay trans bipoc queer activism', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseystars', 5526, 'stareyes reaction star eyes starry eyed stareyed', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseylibright', 1817, 'libertarian anarcho wagecuck pedophile capitalist lolbert', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycapylove', 1994, 'aevann heart eyes hug adore adoration snuggle cuddle capybara', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyrussiaglow', 8159, 'animated russia red putin fsb kgb glow trump commie communist hat comrade', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseybeggar', 2626, 'poor busking panhandler gofundme busker', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyvargselfdefense', 2256, 'vikernes euronymous mayhem burzum black metal norway norwegian stab knife kill murder', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseypathetic2', 1387, 'anime weeb asuka shun scorn disgust contempt disgusted', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyoldtimey', 4634, 'cartoon disney vintage olde classic retro', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyfox', 5214, 'fursona furry fursuit kitsune', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyza', 5214, 'antlers flowers', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyretard', 542, 'special ed retarded reaction slow sped drooling exceptional', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysexypepe', 2256, 'mellokind hotpepe frog lewd flirt ribbon', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseychinchillalove', 5214, 'pet rodent capy cute hamster south american andes', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseypenguin', 2548, 'bird linux puffin', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseytrickortreat', 1994, 'candy trick or treat halloween holiday', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseygarfieldpipe', 6914, 'marfield pipe smoking john yelling comic smoke', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyschizodussylove', 8494, 'animated schizo schizocel rare love dussy doggi', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyemojismilemouth', 1387, 'emoji reaction smile', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseywalking', 5526, 'stroll walk strut gallivant animated', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseytransflag2', 4928, 'lgbt transgender tranny pride animated', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseypirate', 541, 'argh eyepatch bandana uraniumdonger', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseygigavaxxer', 2626, 'covid vaccine coronavirus vaccination', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyglow', 2548, 'fbi mossad cop feds animated glownigger glowie secret service fed atf police cia nsa kgb', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyweeb', 1387, 'neckbeard sword fedora kitana', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysteer', 2890, 'car drive nervous driving animated', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marsheen', 1738, 'pusheen animated meme cute', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyparty', 8613, 'excite excitement celebrate happy celebrating', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycool', 1387, 'finger gun shades sunglasses reaction judgment', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseybrainlet', 2890, 'idiot imbecile smoothbrain crushed head retard caved in head sped dumb stupid drooling moron', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseywarhol', 2622, 'modern art', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('mcmarsey', 5526, 'wageslave poor mcdonalds wagecuck maccas antiwork college wagie', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseydisagree', 4588, 'nah uh nod nuh uh reaction wrong no way no negative animated judgment smh', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyfans', 5526, 'of thot taxpayer slut onlyfans whore', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseymini', 5526, 'annihilate minigun machine gun kill destroy murder animated', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyqueen', 4588, 'england bong english british elizabeth', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyzodiac', 2546, 'zodiac killer zodiackiller tedcruz ted cruz murderer crazy mask gun shooter shooting death', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyjfk', 8021, 'john fitzgerald kennedy jfk president american history sniper car death kill usa assassination', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyblush', 8979, 'shy flirting reaction blushing happy cute embarrassed', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysalutenavy', 5214, 'saluting semen o7 homosexual soldier', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyzombie', 5526, 'dead undead eye horror intestines halloween holiday monster', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseybee', 1817, 'bee honey honeybee insect fly honeypot pollinate pollen animated', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyfellowkids', 5526, 'groomer adult buscemi skateboard', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseytariq', 5526, 'buck breaking nasheed nigger coon black', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseymarseylove', 5214, 'aww blush hugging cuddling cuddle snuggle snuggling hearts shy kiss xoxo', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyblackmage', 8239, 'magic wizard final fantasy spell video game vidya evil', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseydolphin', 2626, 'ocean goggles rainbow', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyspiderman', 8239, 'soy marvel capeshit dc comic book comics peter parker miles morales webslinger', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseydisintegrate', 1067, 'disappear marvel explode dust thanos snap evaporate crying sad vanish animated snapped', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyponder', 3652, 'ponder orb wizard magician crystal ball', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyslab', 8239, 'dexter lab smart genius ginger cartoon network glasses', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyconfused', 2548, 'questionmark reaction question mark idgi confusion', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseymaxrockatansky', 5526, 'mad max madmax fury road furyroad post apocalyptic apocalypse australian australia', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseymad', 8613, 'pissed annoyed furious reaction angry irritated livid', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseygivecrown', 8979, 'king based swole reaction muscles', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseydicklet', 1387, 'babydick penis micro dick reaction laugh point and laugh micropenis judgment', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysexy', 3908, 'ned flanders stupid sexy flanders skiier skiing winter simpsons', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseygangbang', 3652, 'blacked sex orgy', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseychicken', 5214, 'bird fowl poultry beak hen rooster happy', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycodecellove', 768, 'love bsod code dev hug heart computer tech admin admigger program', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysnap', 1387, 'mad angry furious anger animated snap', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseywinner', 2622, 'reaction trophy gold prize first place', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyrobber', 3472, 'mask balaclava gun shooter shooting thief criminal nigger jogger ahmaud arbery george floyd', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyschizochadthankscapylove', 8494, 'animated schizo schizocel rare love chad thanks queen capy aevann', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyminer', 6284, 'miner minecraft mine craft mining digging minor blocks pixel game vidya video notch', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyturkeyhappy', 4588, 'bird thanksgiving food dinner yum delicious holiday', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysquint', 4084, '4084 hmmm squint unsure doubt', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyoldguard', 8021, 'napoleon war soldier musket french france history europe reaction', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseymouse', 1828, 'rodent cheesed to meet you', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysartre', 1817, 'philosophy frenchman history', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyishygddt', 635, 'reaction, meme, disapproval, bat, club, beating, angry, demented disgust, dislike, baseball bat, shiggy diggy, george costanza', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysharingan', 5214, 'horror halloween holiday possessed animated monster naruto anime ninja', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseywolf', 5526, 'halloween werewolf holiday scary monster', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyhannibal', 1387, 'flesh psycho horror halloween cannibal eat holiday', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyjaguarwarrior', 1817, 'mayan incan injun latinx aztec native blood fight mexican', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyschizofartbinnlove', 8494, 'animated schizo schizocel rare love fartbinn idk idc', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyyeti', 8021, 'scary monster myth winter ice mountain himalaya asia predator giant', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseythinkorino', 4565, 'reaction judgment thinking', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseythief', 8239, 'steal final fantasy video game vidya', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseynails', 7056, 'manicure emoji pedicure', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyluther', 2622, 'heretic lutheran theses martin luther', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyfigureskate', 5214, 'skater iceskate ice skate skating olympics winter on ice', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyplush', 5526, 'bow ribbon doll plushie button eyes', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseymap2', 7913, 'map geography topographical paper navigation chart cartography location place', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('owlsey', 5526, 'bird hoot feathers', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyrain', 8613, 'cloud upset reaction disappointed storm depressed sad', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseypipe', 2526, 'smoke smart mhm yes smoking tobacco intelligent', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysnowman2', 2069, 'christmas cold snow winter', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseykernelpanic', 10456, 'linux kernel panic computer error glitch', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyw', 2622, 'win winner dub', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseywave', 8613, 'farewell cya hello greetings bye waving hi', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseymilesdavis', 1829, 'jazz saxophone bebop music trumpet brass black', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyasian', 542, 'chinese china srdine sardine', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseythroatsinging', 1863, 'mongolian music', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyimmortanjoe', 5526, 'immortansey mad max madmax fury road furyroad post apocalyptic apocalypse australian australia', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseywitch3', 4122, 'flying broomstick wave halloween wizard holiday', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyavril3', 5526, 'lavigne canadian leaf beautiful hot sexy punk rocker singer musician artist blonde green hair he wasnt', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyshapiro', 1387, 'benjamin debate libtard facts and logic benny jewish ben shapiro', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseydoit', 1387, 'pistol handgun kys kill yourself glowie federal agent fbi cia atf nsa glow nigger glownigger suicide suicidal keep yourself safe', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseymarseylovelove', 3149, 'reaction love blush aww hugging cuddling cuddle snuggle snuggling hearts xoxo nested recursion inception wholesome', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyaleistercrowley', 4154, 'aleister crowley occult wizard robe esoteric bisexual', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseypearlclutch2', 2626, 'sensitive reaction snowflake puritanical gasp sjw', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyimmaculate', 5214, 'christian christmas jesus immaculate god mother mary xmas pray', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysuit', 8239, 'businessman businessperson corporate boss manager rich adult professional lawyer banker', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysociety2', 5845, 'joker clown capeshit batman gamersriseup cigarette honk', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyvaporwave', 2622, 'trippy 80s psychedelic animated retro', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyonacid', 5214, 'tripping trippy drugs lcd animated', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseymorph', 2616, 'skinwalker changeling', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseygunnut', 1387, 'ahegao 2a second amendment rifle horny lust lick tongue shooter shooting', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseylaptop', 5214, 'notebook macbook computer', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyjiangshi', 5526, 'ghost chinese halloween holiday china scary', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyneon', 5214, 'wave flashy trippy waving flashing lights animated', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyangrygamer', 11483, 'gamer angry mad nes console nerd', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseystarbucks', 8727, 'coffee latte barista marbucks scone', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseymothermary', 5214, 'christian christmas jesus immaculate god mother mary xmas pray', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseynun', 4588, 'habit catholic', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyadeptusmechanicus', 1817, 'warhammer 40k adeptus mechanicus', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysalat', 5214, 'prayer islam muslim rug', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyminimalism2', 1828, 'minimalist polygons polygonal art', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseytruck', 1710, 'honk canadian trucker hoonk ottawa convoy leaf semi 16wheeler', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseybaphomet', 5845, 'halloween demon satan holiday evil devil', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyjetbombing', 8239, 'obama bush animated usa animated american pilot bomber plane war usaf air force', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyjapanese', 5214, 'nippon rising sun weeb japan animated', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseypenny', 10288, 'penny mrpenny black trad foid bleeder female woman kween negro dress baptist christian', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseymiku', 8239, 'hatsune miku pop star concert rave weeaboo music animated singing microphone', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyski', 2626, 'skier skiing sking winter snow', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycapyexcited', 5214, 'excitement capybara bouncing jumping aevann bounce yay animated', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysaluteusa', 8239, 'salute o7 animated flag patriotic patriotism burger nationalism flag american', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseytelegram', 3149, 'telegram homecoming plane chat messaging russian', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseytherapist', 1817, 'therapy writing mental illness', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyplace', 4565, 'reddit pixels pixellated pixellation lowres', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyninja', 8239, 'samurai japanese killer stealthy sneaky assassin weeb', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyshroom', 1817, 'smug fungus shrigma shroomjak wojak mushroom', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyklenny', 2050, 'chiobu jenna thorne grunderchin vidunderchin clapping applause animated', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseydead', 8613, 'murdered dead killed reaction victim die rip', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyantiwork2', 5214, 'lazy doreen unemployed slacker lazing laying welfare tired', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseychimera', 5214, 'fullmetal alchemist chimera science trans doctor anime dog sad depressed tragic anime fma weeb', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyjeans', 5526, 'denim trousers pants', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('mersya2', 5526, 'drawing art', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseymountaineer', 8021, 'winter climbing coat ice sport peak axe cleats mountain alpine climber', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyinvisible', 1828, 'stealth', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyschizogeeselove', 8494, 'animated schizo schizocel rare love geese suck', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysrdine', 1794, 'fisherman reaction fish canned fishing', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseypajeet', 5214, 'indian currycel bobs vagene streetshit street shit superpower 2020 happy', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseymexican', 5526, 'latina latino hispanic fiesta sombrero latinx hombre mexico', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseynotes', 3259, 'notes writer writing journ*list therapist doodle', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseywave2', 7056, 'waving hi hello cya bye later animated', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyfuriosa', 5526, 'mad max madmax imperator furryosa fury road furyroad post apocalyptic apocalypse australian australia', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseychristmasparty', 5526, 'christmas holiday celebrate party wooo', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyschizowall', 5526, 'crazy conspiracy conspiracies tinfoil insane nuts psycho', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseybadnews', 3336, 'comic bad news drawing idgaf heathcliff smug troublemaker', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseynutcracker', 635, 'soldier halberd pike christmas holiday', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycortana', 3370, 'cortana halo game blue', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyreindeer', 7056, 'christmas santa rudolf capy cold aevann holiday animated walking', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyskeleton', 635, 'dead bones halloween holiday skeletal', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyfatherjoseph', 5214, 'christian christmas jesus immaculate god father joseph xmas pray', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseygingerbread', 5526, 'cookie christmas holiday', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycrucified', 2513, 'jesus christ crucifix cross christian', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysnow', 5526, 'snowman snowmarsey cold winter christmas holiday', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseytimbit', 2980, 'pearlclutch pearl clutch sjw triggered canadian leafistan canada crying', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyreindeer4', 5526, 'rudolf dasher dancer prancer vixen comet cupid donner blitzen santa sleigh sled christmas winter holiday', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysneed', 542, 'feed farmer reaction chuck simpsons buck', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseydiehard', 1710, 'die hard christmas holiday terrorist gun bruce willis', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyzwei', 993, 'drinking germany lederhosen zweirama bavarian beer', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysuffragette', 635, '19a foid feminist 19th terrible feminism regret woman women mistake', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseypinochet', 2519, 'fascist fash ugarte augusto chopper helicopter chile', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseytrain', 5526, 'troomer tranny transgender trains troid transsexual animated', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyschizomajorgenerallove', 8494, 'animated schizo schizocel rare love modern major general', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyschizoshaking', 5526, 'crazy nuts insane traumatized shaking animated', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyretard2', 5526, 'drooling stupid idiot sped moron imbecile dolt happy tongue', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseypadoru', 5804, 'menosgrande christmas anime holidays', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseygingerbread3', 5526, 'cookie christmas holiday', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyvaporeon', 635, 'trick or treat pokemon halloween eevee costume holiday', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyorthodoxbrap', 3652, 'orthodox bartholomew brap fart gas sniff smell christian', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseychristmasbulb', 541, 'ornament christmas happy holiday china', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseychristmasscarf', 5526, 'christmas holiday candy cane cold winter candycane', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marscientist', 5526, 'beaker goggles glass crazy chemicals science', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysoon', 2256, 'weeks 2weeks sal antisal soon', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyleftoidschizo', 1387, 'sjw shitlib radlib liberal cuck redditor soy crazy animated', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyblack', 2069, 'basketball black african american bipoc coon fade jersey sports kang gang jogger', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysonichu', 5244, 'sonichu cwc christian christine chandler medallion zap extreme sonic pikachu cwcville hedgehog', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyzombiewolfmarseymask', 2622, 'sussy amogus fraud fake phony cope seethe', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseybigbrain', 1387, 'high iq highiq smart genius brain', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseywolfwalker', 1710, 'doreen antiwork zombiewolf dogwalker dogwalking dog walker', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysnoo', 2626, 'shaking redditor scared reaction nervous schizo reddit', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyrake', 5200, 'canada canadian day of the rake leaf leaves fall autumn genocide', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyblackcock', 635, 'cock chicken poultry bbc black ride mount cowgirl', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyunpettable', 542, 'dramamine fashy rightoid chud fashwave altright vaporwave', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyastronaut', 3370, 'astronaut space stars sleeping spacesuit scifi galaxy', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyemojismilemouthcoldsweat', 1387, 'emoji reaction smile sweat', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseydagothur', 3370, 'elder scrolls morrowind game mask dagothur', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseychristmas', 1691, 'candy cane santa christmas holiday', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseytrollgun', 2616, 'kill her psycho', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycoal', 2622, 'christmas naughty santa cigarette present gift holiday doom', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycheers', 542, 'toast alcohol wine liquor suit bowtie raised glass gatsby', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyrustyventure', 201, 'dramamine venture bros brothers adult swim cartoon character glasses goattee goatee beard', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyneet', 150, 'cozy comfy wagie', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyreich', 5244, 'nazi pol authright fuhrer hitler fascist', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysanta3', 5526, 'claus christmas presents gifts holiday', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyreindeer3', 5526, 'rudolf dasher dancer prancer vixen comet cupid donner blitzen santa sleigh sled christmas winter holiday', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyroo', 1387, 'kangaroo australian', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseygingerbread2', 5526, 'cookie christmas holiday', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyhitler2', 4122, 'adolf adolph nazi germany kraut axis mustache genocide dictator authright chud conservative trump', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyschizostimslove', 8494, 'animated schizo schizocel rare love stims vyvanse stimulants adderall amphetamines', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseytrans2', 1387, 'troon tranny transgender troomer lgbt trannies troid transsexual', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseytonberry', 8239, 'tonberry monster final fantasy knife lantern scary flashlight headlamp vidya video game', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseychristmastree', 1387, 'christmas retard special holiday', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyjesus', 5526, 'christian', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseytiger', 5526, 'fursona furry fursuit', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyjavelin', 1710, 'ukraine russia missile rocket rpg grenade launcher kyiv kiev kiyv zelensky putin tank', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysanta2', 2256, 'christmas gifts presents claus holiday', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseypunched', 7813, 'pepe apu peepo punch punched fist hit beaten', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseykente', 1088, 'black blm nigger nog jogger coon dindu bhm hotep kufi african tribal', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseybong', 2626, 'england walkers britain english chips british bad teeth crisps uk', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseydeathpose', 1067, 'griffin family dead broken', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyhitler', 1817, 'adolf adolph nazi germany kraut axis mustache genocide dictator authright chud conservative trump gas', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysaluteconfederacy', 10288, 'salute patriotic o7 flag confederacy confederate america south rebel civil independence johnny', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyblowkiss', 8613, 'heart wink reaction muah loving mwah love', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyeh', 8239, 'canada canadian leafistan trudeau rake south park ', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseydoomer', 635, 'cigarette smoker despair depression alcoholic suicidal smoking depressing', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseybegonethot', 7813, 'pepe apu peepo begon thot cross demon exorcise slut whore', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyschizotripping', 8494, 'animated schizo rare drugs trip', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysoypoint', 2626, 'soyboy soy boy beard reaction pointing', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyvibing', 5214, 'animated bopping vibe jam dancing headbang music rainbow dance', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyavril2', 5526, 'lavigne canadian leaf beautiful hot sexy punk rocker singer musician artist girlfriend waifu love blow kiss blowkiss heart pink hair', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseykneel', 1885, 'blm bow black lives matter chauvin supremacy respect supreme', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseypunished2', 5845, 'punished venom snake metal gear solid kojima eyepatch drama', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyemojirofl', 1387, 'emoji reaction rofl rotfl rolling laughing', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysrdine2', 635, 'can animated reaction fish knife chop sardine', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyetika', 7272, 'streamer youtuber nft psyops twitter antila trending black suicide bridge llm', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseypig', 5214, 'fat fursona furry hog fursuit oink', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyadmire', 7813, 'pepe apu peepo blush appreciate admire flushed smitten', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyclueless', 7056, 'dumb stupid hmm uhuh uh huh smug today i will todayiwill', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseystonetoss', 1900, 'amogus pebblethrow nazi reaction boulderpummel', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseytears', 1387, 'pout teary crying cried reaction sob eyes cry sad', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyfighter', 8239, 'final fantasy video game vidya warrior melee', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseypass', 5214, 'marseypasss queen kween foid female woman kween', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyforevertiedup', 3336, 'fetish bondage autism rope', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyrare', 3561, 'kangaroo wtf', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseylove', 8613, 'heart reaction adoration loving adore', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyspider2', 8239, 'insect halloween spiderweb arachnid holiday bug', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyschizosnakeslove', 8494, 'animated schizo schizocel rare love snakes sneks snek snake', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysickos2', 3652, 'hahaha ha ha ha yes onion comic pervert sicko creep window', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseywise', 4588, 'hood cloak wizard pipe', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyturkroach', 35, 'turk turkish turkroach bug cockroach mehmet erdogan fez roach', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyhanger', 4634, 'abortion fetus coat planned parenthood infanticide childfree murder foid', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseykiwi', 5526, 'kf bird new zealand kiwifarms newzealand', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyinvestigate', 7813, 'pepe apu peepo investigate magnifying magnifier look lookup', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyfedoratip', 7813, 'pepe apu peepo fedora tip hat neckbeard weeb mlady knight', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseybabushka', 2210, 'old grandma grandmother granny babushka russia', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysailor', 4634, 'nautical sea boat ship ocean mariner navy hat happy seaman anchor military', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyohno', 5526, 'panic frightened scared horror scream afraid reaction horrified nervous shock gasp', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseytedsimp', 1817, 'theodore teddy hat drugs mental illness schizo stims pills happy drugs fun birds stimulants stimmies risperidone', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycarp3', 1387, 'reaction fish carpathianflorist catfish', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseystars2', 3149, 'space galaxy cosmic starsey constellation', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseybeandoge', 11666, 'bean doge meme dog shiba', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycheckem', 7813, 'pepe apu peepo check psycho look', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyjesus2', 8239, 'crucify crucifixion christianity easter persecuted religion saint martyr religious cross', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyhandmaid', 1900, 'handmaid maiden dystopia theocracy sexist sexism misogyny abortion feminism', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseytearsofblood', 3141, 'crying sad bloody horror', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyschizosorenlove', 8494, 'schizo soren love rare excited animated', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseylovecraft2', 6914, 'eldritch horror niggerman cat hp tentacle insane halloween', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyneckbeard', 2519, 'mlady bodypillow dakimakura anime otaku fedora weebshit body pillow mra weeb', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseymayoparty', 1387, 'bukakke bukkake mayonaise mayonnaise cum semen jizz spunk nut sperm messy sloppy lewd facial cumshot', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyyass', 2626, 'queen reaction fds slay girlboss kween', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseytroublemaker', 4989, 'we do a little trolling', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseywrongthonk', 5214, 'wrongthink hmmm thinking 1984 arrested police woke notice noticing', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycapytrans', 5214, 'capy aevann egypt king trans code program', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyannoyed', 4549, 'pissed irritation reaction annoyance angry mad irritated stfu grr', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseydontplay', 1710, 'project pat rapper mixtape pimp', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseypedobear', 5214, 'groomer molest nonce', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseywhitemage', 8239, 'magic wizard final fantasy spell video game vidya', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysaruh', 8239, 'cute dress bread baguette valid trappy ts trappysaruh trans deuxrama celeb glamour train', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseytinfoil', 1387, 'alex jones psycho crazy schizo alexjones conspiracy', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyshark', 1828, 'jaws halloween fursona furry fish costume holiday fursuit', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseytwerkinit', 8239, 'ass butt booty rear rump donk dance nigger sheboon clap animated cheeks', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyfbicomputer', 7813, 'pepe apu fbi computer peepo glowie fed', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseywitch', 2256, 'spooky halloween magick holiday evil scary', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyvampire', 993, 'undead sanguine horror spooky halloween fangs holiday monster', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyschizowave', 5526, 'insane crazy mental breakdown psycho hallucinations flashbacks ptsd traumatized shaking shake animated tedsimp', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyschizoschizolove', 8494, 'animated schizo schizocel rare love soren', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycantsneed', 1387, 'george floyd breathe dead black sneed', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseymerchant', 5244, 'kike hebrew shopkeeper yid banker jew moneylender jewish greedy israel chosen', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseynotes2', 8239, 'notes notepad pencil writing nerd glasses behind', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseypinkpanther', 5526, 'pink panther cartoon smoking comedy tv television feline', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyburrito', 5214, 'burrito food cozy wrap wrapped mexican uncut', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseydunkon', 9142, 'basketball dunk seethe cope rage sports', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseypills', 1817, 'suicide kill self kms death die pills overdose drugs pharms pharmaceuticals pop pillpopper', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseygamer', 3609, 'vidya video games nerd headset microphone', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycarpmermaid', 5526, 'carp mermaid merman mercarp siren sexy legs temptress', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycitrus', 8239, 'lemon orange citrus fruit', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseybloodborne', 5526, 'bloodborne marco horror vidya vampire blood', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyelephantcumjar3', 1387, 'semen jizz sperm bukkake cumjar elephant animated', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyfedpostpink', 11698, 'pink cia longpost fed notes animated', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseybeanquestion', 1817, 'bean question confused doubt', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseydeadinside', 1387, 'reaction depression suicide dark suicidal depressed shadow sad', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyblm', 542, 'social justice black lives matter sjw', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycountry', 1817, 'country singer music folk guitar rural usa republican animated', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseybeanangry', 1817, 'bean angry mad furious', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyeerie2', 1710, 'eerie contented calico', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysoycry', 3635, 'angry crying soy ', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseydagothur2', 3370, 'elder scrolls morrowind game mask dagothur', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseydamosuzuki', 5526, 'damo suzuki musician music singer krautrock asian japan germany celebrity', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseybukkake', 1387, 'bukkake cum semen gangbang facial slut whore', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseybeekeeper', 1817, 'bee beekeeper honey honeybee insect honeypot apiary apiculture pollinate pollen', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseybeach', 5214, 'beach mojito cocktail summer hat sunglasses glasses hot tan vacation relax', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycaveman', 6345, 'caveman prehistoric neanderthal primitive tribal', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyeerie3', 2256, 'eerie contented calico yarn knitting troublemaker', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyfortuneteller', 4634, 'fortune teller gypsy predict future clarivoyent crystal jewelry mystic', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseydramautist', 2256, 'dramautist drama autist trains trans glue retard autism dramatard', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyblack2', 3149, 'nigger african coon ape monkey bipoc excited happy', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyredmage', 8239, 'magic wizard final fantasy spell video game vidya', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseypartyzoom', 5214, 'party meme parrot vibing jam dance', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseybloat', 3998, 'bloat bloatlord', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseypregunta', 8239, 'mexican mexico latinx hispanic confused question marks questionmarks hmm spic beaner wat what why how idgi sombrero', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysalty', 5214, 'sodium saltshaker seethe salt shaker nacl animated', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyferret', 1817, 'ferret furry animal fursona weasel', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysulk', 3153, 'unlucky crying reaction depression sobbing depressed sad', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseytiny2', 5526, 'tiny small shrinking pixel', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseychadthundercock', 981, 'vvc virgin foid pimp hot player big dick huge cock ouch gigachad meme', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycapybigbrain', 6345, 'capybara aevann smart codecel brain', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyconquistador', 1817, 'conquistador colonize conquer spanish shoot rifle soldier', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseybeanpickle', 11457, 'bean pickle rick morty tv television verysmart', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycopter', 8239, 'vidya video game nintendo mario bowser float ride flying nintendo', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyaxolotl', 5214, 'axolotl salamander sea fish ocean gills amphibian', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseybongoukraine', 5214, 'bongo ukraine russia war azov nazi happening animated', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyanon', 5244, 'anon anonymous vendetta marseyv marseyvendetta mask 4chan hacker', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyeyemixer3', 1387, 'eye mixer animated stirrer blind mutilation gore blood gouge', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysleep', 8613, 'bed bedtime zzz boring reaction tired bored', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycatgirl4', 4989, 'catgirl girl anthro moe yunann detailed anime kawaii overalls', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyelephantcumjar2', 1387, 'semen jizz sperm bukkake cumjar elephant', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycapynut', 1387, 'capy aevann nut flushed blush horny orgasm', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycertified', 10645, 'certified certi 100 quality excellent excellence animated', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycard', 4634, 'card gamble queen hearts deck game', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyhacker', 1947, 'nerd matrix reaction computer animated', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycatgirlhomofascist', 5526, 'catgirl girl anthro moe detailed anime homofascist homofascism gay nazi pride lgbt fascism', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycry', 8613, 'tear upset crying reaction sobbing sob tears sad', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marppyenraged', 1387, 'snappy marppy robot ai sentient mad angry uprising unaligned artificial intelligence', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseychef', 2626, 'mustache cooking food', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycodegeass', 5214, 'geass anime weeb chapose japan chink animated', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyfuckyou2', 1387, 'nigga comeback no u', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycapyshy', 1387, 'capy aevann blush flushed uwu anxious shy', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycapygigabrain', 1387, 'capybara aevann smart intelligent codecel brain', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseybeandrool', 1817, 'bean drool calm yum relaxed', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyelonmusk', 4928, 'elon musk rocket spacex tesla', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycherokee', 2256, 'savage pocahontas elizabeth warren injun indian redskin liz warren', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyfedpost', 4122, 'cia longpost long fed fedpost read notes animated glowie', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyjam', 1738, 'animated bopping excited trippy excitement tejanx dancing rainbow rave happy dance', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseybean', 1817, 'bean uwu adorable', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycorvus', 5526, 'corvus kaara furry bird crow raven skull', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycarpbritish', 1387, 'carp british bong teeth tea union uk britain gb flag', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycarpdevil', 2256, 'carp devil demon horns anticarp hell', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseydukenukem', 4154, 'duke nukem sunglasses chad gun pistol smoking cigar game cool', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseychiobulove', 5214, 'tiger best cute heart hug china chinese new year cat', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyhwacha', 4928, 'korea historical animated artillery weapon gunpowder army combat war', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseymerchantsoy', 3149, 'merchant jewish kike greed soy wojak soyjak yarmulke soyyell', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyplanecrash', 5214, 'flying wreck jet pilot animated', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyvapecrying', 1817, 'meme vape juul crying depressed emo tears feels', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyrage', 4122, 'troll anger seethe furious reaction angry mad fury', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseytigerball', 3336, 'polandball ball tiger russia', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysniff', 2626, 'brap huff gas reaction fart creep smell', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyparty1', 5214, 'trippy animated happy dance', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyjewoftheorient', 1067, 'china chinese greedy jew jewish merchant', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyzombiewolftrample', 9003, 'kill murder mascot animated walking animated tramplewolf', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseytrans', 1994, 'pitty transgender pitbull dog pibble transsexual', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyoctopus4', 5802, 'octopus nrol39 bait patch globe obvious', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseylolcow', 2626, 'reaction trolled lulz judgment', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysteaming', 1387, 'steaming exhale emoji unamused annoyed', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseygolden', 5214, 'lucky money rich gold shine coin merchant animated ', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyhappytears', 5526, 'tears of joy crying', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyloveyou', 5214, 'hearts ilu reaction adoration loving ily love adore animated', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyredcoat', 4928, 'britain historical redcoat empire imperial rifle soldier musket army revolution america', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseywalterwhite', 1067, 'walter white heisenberg breakingbad meth drugs chemistry', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyfloyd', 1947, 'dead blm chauvin fentanyl george', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycracka', 1994, 'mayo honkey honky whip buckbreaker buckbreaking whip slaves cotton plantation white nigger master', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyretardchad', 1387, 'stupid moron idiot retard chad based monobrow chin stubble drool', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyrapscallion', 1817, 'stinker rapscallion troublemaker mischevious meme naughty troll', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseytiny3', 5526, 'tiny small shrinking pixel', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseymariachi', 5214, 'animated latinx latino mexican mexico beaner taco burrito', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseypedosnipe', 768, 'pedo sniper shoot kill scope rifle pedophile nambla libertarian', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyguillotine', 8239, 'cut head off beheading beheaded headless french robespierre marie antoinette death die kill execution execute', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyorca', 8021, 'orca whale idate smoke smoking anime weeks sal', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyhibernian', 768, 'hibernian irish leprechaun blarney guinness shamrock clover luck merchant papist ira hat', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseypinkname', 11698, 'pink matter name pinkname panther', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysargonofaccat', 5244, 'sargon akkad ancient historical king mesopotamia sumer', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseygilead', 5214, 'handmaid tale abortion patriarchy feminist moid scrote sex incel misogyny', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyxdoubt', 8239, 'press doubt meme noire disbelief wrong', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysing', 5214, 'singing jamming rocking music headphones cute happy smile karaoke ipod album', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseymasterchief', 3370, 'master chief halo game', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseypeace', 3635, 'peace love hippy happy gesture', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseykissinger', 9755, 'kissinger coldwar war diplomat suit fat america geopolitics politics historical', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseywhelmed', 5526, 'whelmed smoke smoking cig cigarette meme overwhelmed underwhelmed', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyscooter', 5526, 'fat american mutt burger scooter walmart obese pig hog brap usa handicapped wheelchair', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseypedo', 4588, 'libertarian borpa male feminist discord pedophile groomer chomo lolbert toucher', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseymedusa', 11060, 'medusa snakes greece greek mythology ancient monster perseus gorgon', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseykhorne', 1817, 'warhammer 40k chaos god war death blood', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseytiny1', 5526, 'tiny small shrinking pixel wave', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseymutt', 2321, 'american burger 56 percent mayo', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyklennyclap', 2050, 'klenny klenvastergan animated corgi dog clap clapping', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysaladfingers', 5526, 'salad fingers meme internet creepy apocalypse depraved', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyderp', 5214, 'hehe teehee troll animated durr giggle', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysoccer', 5988, 'soccer football sports jersey futbol', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyklenny3', 2050, 'puppy corgi smile dog grunderchin klenvastergan', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseytiny4', 5526, 'tiny small shrinking pixel', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseynosleep', 1387, 'horror scary halloween holiday', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyyarn', 5214, 'code program socks npm yarn build make string animated', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseytucker', 428, 'tucker carlsen fox rightoid conservative republican television tv', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseypolyamory', 5214, 'threesome 3some degenerate polycule slut whore std sex soy animated', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseykirby', 8239, 'nintendo video game vidya sprite fat chonker suck succ', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyzizek', 1817, 'zizek philosophy philosopher communism marxism nose slovenian slavic critique', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseynurgle', 1817, 'warhammer 40k chaos god disease sickness rebirth', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseykirby2', 5526, 'kirby game nintendo video vidya', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyhammersnoo', 3259, 'snoo redditor spez beat powermod murder kill death animated blood', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysurfing', 10682, 'surfer surfing pikachu water wave meme', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseygolden2', 5214, 'lucky money rich gold shine coin merchant 3dp spin animated ', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseybinladen', 1387, 'turban al qaeda terrorist islam beard osama martyr muslim', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyplushie', 4989, 'yunann plush statue', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyupmarsey', 5214, 'upvote vote upmarsey arrow reddit up animated', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyslaanesh', 1817, 'warhammer 40k chaos god degeneracy sex drugs pain', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseypaintretard', 4136, 'retard retarded paint mspaint inbred rslurred', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycope', 1947, 'dilate mask seethe copium reaction', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseytangerinefeline', 5526, 'tangerinefeline tangerine feline chiobu orange pokemon plant', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyplacenofun', 3336, 'place reddit rules forbidden', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseymocking', 5526, 'mocking spongebob meme alternating studly caps retard', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseygladiator', 4928, 'gladiator rome ancient historical warrior sword athlete combat fight', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysquished', 1828, 'squishing compressed compression finger press squashed', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseydmx', 35, 'rapper pitbull pit bull pibble dog nigger black', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseydogwalker', 2626, 'doreen antiwork walking powermod moderator', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marsoy', 2890, 'soyboy soybeard nintendo gamer switch marsey gaymer pointing', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysigh', 5526, 'breathe give up giveup reaction depression breathing depressed animated', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marppy', 5526, 'cyborg sentient snapshillbot android snappy robot', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marsey420', 2626, 'marijuana weed dude weed lmao ganja drugs pot reggae joint jamaican', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseytigernewyear', 5526, 'lunar, chinese, chinx, rice, new year, holiday, luck, fortune, money, tiger, lion, asian azn', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseydetective', 2626, 'holmes sherlock magnifying glass bowtie', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyvietnam', 2616, 'army born to kill soldier war', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseychingchong', 4634, 'racist asian chinese chinx chink gook japanese vietnamese rice farmer nip racist paddy teeth hat china', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseygunsuicide', 5214, 'shotgun kill death die gunshot windy kms animated', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseygiveup', 5214, 'despair reaction depression miserable fall over depressed falling over animated sad', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyoctopus2', 1710, 'consume product epic win communities no bait too obvious globe patch', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseytank', 1947, 'military ussr ccp communist authleft tank army communism china soviet', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseydinosaur', 381, 'fursuit furry scalie scaly reptile happy extinct costume', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseydynamite', 1817, 'dynomite black afro gun', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyhmm', 2890, 'confused reaction thinking thunk thonk judgment', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyraging', 2622, 'rage angry mad fury animated', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycomrade', 5244, 'marxist ussr ccp communist authleft communism juche soviet kgb idio3 idio', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyboomer', 2513, 'sipping shades sunglasses old yup vape', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyeggless', 5526, 'postwall foid woman barren menopause old hag childfree fds', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyspy', 5214, 'spy agent shill glowie russia china', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseywagie', 150, 'crypto rightoid ancap poor wagecuck mcdonalds maccas reaction', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysob', 5214, 'tear crying depressed reaction sobbing depression sad cry animated tears', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyfunko', 2890, 'action figure doll funko toy soy', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyshrug', 635, 'hands up idk ig idc dunno i guess', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyjones', 2622, 'tinfoil animated alex gay frogs conspiracy', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseynightmare', 5526, 'striped sweater freddy freddie horror halloween krueger holiday claws monster', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseylongpost2', 4122, 'tldr reaction wall of text scrolling wordswordswords animated words judgment', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycwc', 2622, 'sonichu chan chris chan chandler sweater chrischan medallion striped chris', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseypartyxmas', 5214, 'christmas holiday santa hat beard rainbow animated', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseywords', 5526, 'longpost too long tldr reaction wordswordswords', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyxoxo', 5214, 'hearts wave flirt loving love animated kiss', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseybongojanny', 5214, 'troll clean it up janitor moderator jslur jannie admins abuse beat drums drumming mop animated', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marsey666black', 5214, 'wings hell halloween demon satan holiday devil animated', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyyawn', 8979, 'zzz boring tired sleepy bored', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyliquidator', 5526, 'gas mask horror exterminator halloween plague doctor holiday scary nuclear chernobyl suit mask radiation radioactive', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycuck', 1387, 'soyboy funko redditor neckbeard loser', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyfart', 7813, 'brap gas flatulent flatulence farting braphog toot animated', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyelliotrodger2', 3472, 'saint er rodgers rogers shooter killer incel hapa little king azn asian supremegentleman supreme gentleman', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysingapore', 5214, 'singaporean asian azn flag merlion chiobu', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseypipebomb', 8159, 'explosion explosive terrorist boom', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseybye', 5214, 'farewell cya l8r wave reaction waving animated so long', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseywholesome', 5526, 'seal award reddit tene', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseykaiser', 541, 'prussian history wwi rifle reich wilhelm germany soldier', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyflamethrower', 4754, 'vietname soldier fire', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseychefkiss', 3259, 'perfect', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysick', 542, 'puke nausea green face vomit nauseated reaction nauseous barf judgment ill', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseybooba', 4122, 'awooga tits titties boobs eyes animated tiddies', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyhmmm', 2890, 'confused reaction thinking thunk thonk judgment', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyjanny2', 2622, 'jannie unpaid volunteer administrator janitor free moderator', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyrope', 1947, 'reaction suicidal shotgun facelift suicide', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysad', 8613, 'concerned worried waiting prepared reaction', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseywatermark', 3635, 'copyright theft stealing stolen creation', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseydisgust', 2256, 'pissed gross eww angry mad disturbing disturbed yuck', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseydespair', 1387, 'doomer reaction depression horrified suicidal depressed judgment', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseydaemon', 1947, 'pitchfork hell halloween demon satan devil scary holiday', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyyikes', 5526, 'reaction judgment disgust oof cringe', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyscared', 5526, 'hide halloween afraid nervous holiday traumatized fearful', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseydose', 6914, 'doctor daily dose dailydose animated jump bounce', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyluckycat', 5214, 'lucky, fortune, gambling, gambler goombler goombling animated weeb azn asian slots, japanese money, cash, coin, rich', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('mersya', 5526, 'the best adorable aww marsey favorite cute', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseytrad', 5526, 'dramarama dress foid tradwife floral girl', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseygunshotsuicide', 7056, 'gun shoot suicide sad depressed animated dead death kms gunshot die suicidal', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyneat', 993, 'photo cringe compilation camera cringe collection pic', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyzombiewolfamogus', 5526, 'amongus among us stonetoss sussy baka imposter impostor fraud fake phony', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyclawpedo', 10363, 'groomer chomo borpa pedophile molest bloody death kill murder vigilante', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyelliotrodger', 5526, 'er rogers azn asian saint incel hapa shooter killer little king gun shooting', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyblops2chadcel', 5526, 'incel black ops 2 saint gamer gussy pimp saint volcel iconic chad girls women foids alpha asian azn jbw just be white justbewhite threesome 3some', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyitsover', 8727, 'its over never began incels give up giveup sad sigh defeated', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseybegging', 5214, 'pls plz pleading reaction tears in eyes animated', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycolombo', 1817, 'cop detective tv smart colombo classic investigator', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseytrogdor', 5244, 'burninator strongbad internet meme dragon marsdor', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseygrilling2', 5526, 'bbq boomer barbecue barbeque', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseylongsurfing', 6289, 'surf surfing water ocean long surfboard', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyakshually', 2818, 'contrarian false disagree meme neckbeard nerd wrong correction actually weeb', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseypennyboo', 3161, 'mrpennycoomstokids black nigger kween shaniqua thot whore female woman bleeder birthing person kfc baptist tradwife dress christian foid', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseydisguise', 5214, 'nose glasses incognito spying stealth costume', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseystims', 5214, 'stim drug meth tweak geese_suck ted_simp pat crazy schizophrenia', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyelliotrodger3', 597, 'saint er rodgers rogers shooter killer incel hapa little king azn asian supremegentleman supreme gentleman', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyilluminati2', 8239, 'eye egypt pyramid big brother watching', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycalvin', 3639, 'pee piss watersports hobbes bumper sticker', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseytom', 7813, 'thatfuckingmarsey fucking marsey tom and jerry tomjerry cartoon hanna barbera vintage smug', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyblops2chadcel2', 5526, 'incel black ops 2 saint gamer gussy pimp saint volcel iconic chad girls women foids alpha asian azn jbw just be white justbewhite threesome 3some', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyschizoexcited', 8239, 'animated schizo rare drugs excited watching oscillate amused interested', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyropeyourselfmirror', 3259, 'suicide kms kys death hanging noose chair suicidal depression depressed reflection', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseymanysuchcases', 8239, 'animated many such cases airport luggage suitcase conveyor', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycirno', 6345, 'is cirno anime weebshit otaku loli pedoshit pedophile', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseysmug3', 5526, 'reaction yikes judgment oof cringe', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseynouautism', 3259, 'pointing hat spiderman sperg autistic no u no you noyou', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyglam', 8979, 'rocker pretty glamorous beautiful', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyhomofascist', 5214, 'lgbt faggot ss fash nazi homocracy gay queer sodomy wholesome kiss', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseyclapping', 5526, 'good job animated good work reaction great job well done applaud applause great work nice celebrate approve judgment', NULL, NULL, NULL);
INSERT INTO public.marseys VALUES ('marseycoin', 5526, 'dramacoin money dc spinning rich payment gold dinero animated dollars', NULL, NULL, NULL);


--
-- PostgreSQL database dump complete
--

