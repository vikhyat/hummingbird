--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- Name: pg_trgm; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_trgm WITH SCHEMA public;


--
-- Name: EXTENSION pg_trgm; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pg_trgm IS 'text similarity measurement and index searching based on trigrams';


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: anime; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE anime (
    id integer NOT NULL,
    title character varying(255),
    alt_title character varying(255),
    slug character varying(255),
    age_rating character varying(255),
    episode_count integer,
    episode_length integer,
    status character varying(255),
    synopsis text,
    youtube_video_id character varying(255),
    mal_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    cover_image_file_name character varying(255),
    cover_image_content_type character varying(255),
    cover_image_file_size integer,
    cover_image_updated_at timestamp without time zone,
    age_rating_tooltip character varying(255),
    wilson_ci double precision,
    user_count integer
);


--
-- Name: anime_genres; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE anime_genres (
    anime_id integer NOT NULL,
    genre_id integer NOT NULL
);


--
-- Name: anime_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE anime_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: anime_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE anime_id_seq OWNED BY anime.id;


--
-- Name: anime_producers; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE anime_producers (
    anime_id integer NOT NULL,
    producer_id integer NOT NULL
);


--
-- Name: castings; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE castings (
    id integer NOT NULL,
    anime_id integer,
    person_id integer,
    character_id integer,
    role character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    voice_actor boolean,
    featured boolean
);


--
-- Name: castings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE castings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: castings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE castings_id_seq OWNED BY castings.id;


--
-- Name: characters; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE characters (
    id integer NOT NULL,
    name character varying(255),
    description text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    mal_id integer
);


--
-- Name: characters_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE characters_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: characters_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE characters_id_seq OWNED BY characters.id;


--
-- Name: episodes; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE episodes (
    id integer NOT NULL,
    anime_id integer,
    number integer,
    title character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: episodes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE episodes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: episodes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE episodes_id_seq OWNED BY episodes.id;


--
-- Name: episodes_watchlists; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE episodes_watchlists (
    episode_id integer NOT NULL,
    watchlist_id integer NOT NULL
);


--
-- Name: gallery_images; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE gallery_images (
    id integer NOT NULL,
    anime_id integer,
    description text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    image_file_name character varying(255),
    image_content_type character varying(255),
    image_file_size integer,
    image_updated_at timestamp without time zone
);


--
-- Name: gallery_images_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE gallery_images_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: gallery_images_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE gallery_images_id_seq OWNED BY gallery_images.id;


--
-- Name: genres; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE genres (
    id integer NOT NULL,
    name character varying(255),
    slug character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    description text
);


--
-- Name: genres_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE genres_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: genres_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE genres_id_seq OWNED BY genres.id;


--
-- Name: people; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE people (
    id integer NOT NULL,
    name character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    mal_id integer
);


--
-- Name: people_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE people_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: people_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE people_id_seq OWNED BY people.id;


--
-- Name: producers; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE producers (
    id integer NOT NULL,
    name character varying(255),
    slug character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: producers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE producers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: producers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE producers_id_seq OWNED BY producers.id;


--
-- Name: quotes; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE quotes (
    id integer NOT NULL,
    anime_id integer,
    content text,
    character_name character varying(255),
    user_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: quotes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE quotes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: quotes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE quotes_id_seq OWNED BY quotes.id;


--
-- Name: rails_admin_histories; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE rails_admin_histories (
    id integer NOT NULL,
    message text,
    username character varying(255),
    item integer,
    "table" character varying(255),
    month integer,
    year integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: rails_admin_histories_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE rails_admin_histories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: rails_admin_histories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE rails_admin_histories_id_seq OWNED BY rails_admin_histories.id;


--
-- Name: recommendations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE recommendations (
    id integer NOT NULL,
    user_id integer,
    anime_id integer,
    score double precision,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: recommendations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE recommendations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: recommendations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE recommendations_id_seq OWNED BY recommendations.id;


--
-- Name: reviews; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE reviews (
    id integer NOT NULL,
    user_id integer,
    anime_id integer,
    positive boolean,
    content text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    rating integer
);


--
-- Name: reviews_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE reviews_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: reviews_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE reviews_id_seq OWNED BY reviews.id;


--
-- Name: rs_evaluations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE rs_evaluations (
    id integer NOT NULL,
    reputation_name character varying(255),
    source_id integer,
    source_type character varying(255),
    target_id integer,
    target_type character varying(255),
    value double precision DEFAULT 0.0,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: rs_evaluations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE rs_evaluations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: rs_evaluations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE rs_evaluations_id_seq OWNED BY rs_evaluations.id;


--
-- Name: rs_reputation_messages; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE rs_reputation_messages (
    id integer NOT NULL,
    sender_id integer,
    sender_type character varying(255),
    receiver_id integer,
    weight double precision DEFAULT 1.0,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: rs_reputation_messages_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE rs_reputation_messages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: rs_reputation_messages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE rs_reputation_messages_id_seq OWNED BY rs_reputation_messages.id;


--
-- Name: rs_reputations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE rs_reputations (
    id integer NOT NULL,
    reputation_name character varying(255),
    value double precision DEFAULT 0.0,
    aggregated_by character varying(255),
    target_id integer,
    target_type character varying(255),
    active boolean DEFAULT true,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: rs_reputations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE rs_reputations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: rs_reputations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE rs_reputations_id_seq OWNED BY rs_reputations.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE schema_migrations (
    version character varying(255) NOT NULL
);


--
-- Name: staged_imports; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE staged_imports (
    id integer NOT NULL,
    user_id integer,
    data text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: staged_imports_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE staged_imports_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: staged_imports_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE staged_imports_id_seq OWNED BY staged_imports.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE users (
    id integer NOT NULL,
    email character varying(255) DEFAULT ''::character varying NOT NULL,
    name character varying(255),
    encrypted_password character varying(255) DEFAULT ''::character varying NOT NULL,
    reset_password_token character varying(255),
    reset_password_sent_at timestamp without time zone,
    remember_created_at timestamp without time zone,
    sign_in_count integer DEFAULT 0,
    current_sign_in_at timestamp without time zone,
    last_sign_in_at timestamp without time zone,
    current_sign_in_ip character varying(255),
    last_sign_in_ip character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    watchlist_hash character varying(255),
    recommendations_up_to_date boolean,
    avatar_file_name character varying(255),
    avatar_content_type character varying(255),
    avatar_file_size integer,
    avatar_updated_at timestamp without time zone,
    facebook_id character varying(255),
    bio text,
    sfw_filter boolean DEFAULT true,
    star_rating boolean,
    mal_username character varying(255),
    life_spent_on_anime integer,
    about text
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE users_id_seq OWNED BY users.id;


--
-- Name: watchlists; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE watchlists (
    id integer NOT NULL,
    user_id integer,
    anime_id integer,
    status character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    episodes_watched integer DEFAULT 0,
    rating integer,
    last_watched timestamp without time zone
);


--
-- Name: watchlists_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE watchlists_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: watchlists_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE watchlists_id_seq OWNED BY watchlists.id;


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY anime ALTER COLUMN id SET DEFAULT nextval('anime_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY castings ALTER COLUMN id SET DEFAULT nextval('castings_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY characters ALTER COLUMN id SET DEFAULT nextval('characters_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY episodes ALTER COLUMN id SET DEFAULT nextval('episodes_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY gallery_images ALTER COLUMN id SET DEFAULT nextval('gallery_images_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY genres ALTER COLUMN id SET DEFAULT nextval('genres_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY people ALTER COLUMN id SET DEFAULT nextval('people_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY producers ALTER COLUMN id SET DEFAULT nextval('producers_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY quotes ALTER COLUMN id SET DEFAULT nextval('quotes_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY rails_admin_histories ALTER COLUMN id SET DEFAULT nextval('rails_admin_histories_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY recommendations ALTER COLUMN id SET DEFAULT nextval('recommendations_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY reviews ALTER COLUMN id SET DEFAULT nextval('reviews_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY rs_evaluations ALTER COLUMN id SET DEFAULT nextval('rs_evaluations_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY rs_reputation_messages ALTER COLUMN id SET DEFAULT nextval('rs_reputation_messages_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY rs_reputations ALTER COLUMN id SET DEFAULT nextval('rs_reputations_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY staged_imports ALTER COLUMN id SET DEFAULT nextval('staged_imports_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY users ALTER COLUMN id SET DEFAULT nextval('users_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY watchlists ALTER COLUMN id SET DEFAULT nextval('watchlists_id_seq'::regclass);


--
-- Name: anime_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY anime
    ADD CONSTRAINT anime_pkey PRIMARY KEY (id);


--
-- Name: castings_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY castings
    ADD CONSTRAINT castings_pkey PRIMARY KEY (id);


--
-- Name: characters_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY characters
    ADD CONSTRAINT characters_pkey PRIMARY KEY (id);


--
-- Name: episodes_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY episodes
    ADD CONSTRAINT episodes_pkey PRIMARY KEY (id);


--
-- Name: gallery_images_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY gallery_images
    ADD CONSTRAINT gallery_images_pkey PRIMARY KEY (id);


--
-- Name: genres_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY genres
    ADD CONSTRAINT genres_pkey PRIMARY KEY (id);


--
-- Name: people_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY people
    ADD CONSTRAINT people_pkey PRIMARY KEY (id);


--
-- Name: producers_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY producers
    ADD CONSTRAINT producers_pkey PRIMARY KEY (id);


--
-- Name: quotes_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY quotes
    ADD CONSTRAINT quotes_pkey PRIMARY KEY (id);


--
-- Name: rails_admin_histories_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY rails_admin_histories
    ADD CONSTRAINT rails_admin_histories_pkey PRIMARY KEY (id);


--
-- Name: recommendations_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY recommendations
    ADD CONSTRAINT recommendations_pkey PRIMARY KEY (id);


--
-- Name: reviews_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY reviews
    ADD CONSTRAINT reviews_pkey PRIMARY KEY (id);


--
-- Name: rs_evaluations_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY rs_evaluations
    ADD CONSTRAINT rs_evaluations_pkey PRIMARY KEY (id);


--
-- Name: rs_reputation_messages_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY rs_reputation_messages
    ADD CONSTRAINT rs_reputation_messages_pkey PRIMARY KEY (id);


--
-- Name: rs_reputations_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY rs_reputations
    ADD CONSTRAINT rs_reputations_pkey PRIMARY KEY (id);


--
-- Name: staged_imports_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY staged_imports
    ADD CONSTRAINT staged_imports_pkey PRIMARY KEY (id);


--
-- Name: users_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: watchlists_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY watchlists
    ADD CONSTRAINT watchlists_pkey PRIMARY KEY (id);


--
-- Name: anime_search_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX anime_search_index ON anime USING gin ((((COALESCE((title)::text, ''::text) || ' '::text) || COALESCE((alt_title)::text, ''::text))) gin_trgm_ops);


--
-- Name: anime_simple_search_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX anime_simple_search_index ON anime USING gin (((to_tsvector('simple'::regconfig, COALESCE((title)::text, ''::text)) || to_tsvector('simple'::regconfig, COALESCE((alt_title)::text, ''::text)))));


--
-- Name: character_mal_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX character_mal_id ON characters USING btree (mal_id);


--
-- Name: index_anime_on_mal_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_anime_on_mal_id ON anime USING btree (mal_id);


--
-- Name: index_anime_on_wilson_ci; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_anime_on_wilson_ci ON anime USING btree (wilson_ci DESC);


--
-- Name: index_castings_on_anime_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_castings_on_anime_id ON castings USING btree (anime_id);


--
-- Name: index_castings_on_character_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_castings_on_character_id ON castings USING btree (character_id);


--
-- Name: index_castings_on_person_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_castings_on_person_id ON castings USING btree (person_id);


--
-- Name: index_characters_on_mal_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_characters_on_mal_id ON characters USING btree (mal_id);


--
-- Name: index_episodes_on_anime_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_episodes_on_anime_id ON episodes USING btree (anime_id);


--
-- Name: index_episodes_watchlists_on_episode_id_and_watchlist_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_episodes_watchlists_on_episode_id_and_watchlist_id ON episodes_watchlists USING btree (episode_id, watchlist_id);


--
-- Name: index_gallery_images_on_anime_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_gallery_images_on_anime_id ON gallery_images USING btree (anime_id);


--
-- Name: index_people_on_mal_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_people_on_mal_id ON people USING btree (mal_id);


--
-- Name: index_staged_imports_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_staged_imports_on_user_id ON staged_imports USING btree (user_id);


--
-- Name: person_mal_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX person_mal_id ON people USING btree (mal_id);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


--
-- PostgreSQL database dump complete
--

INSERT INTO schema_migrations (version) VALUES ('20130129153309');

INSERT INTO schema_migrations (version) VALUES ('20130129160306');

INSERT INTO schema_migrations (version) VALUES ('20130129160719');

INSERT INTO schema_migrations (version) VALUES ('20130129160916');

INSERT INTO schema_migrations (version) VALUES ('20130129200416');

INSERT INTO schema_migrations (version) VALUES ('20130130114735');

INSERT INTO schema_migrations (version) VALUES ('20130130124651');

INSERT INTO schema_migrations (version) VALUES ('20130130211028');

INSERT INTO schema_migrations (version) VALUES ('20130130211236');

INSERT INTO schema_migrations (version) VALUES ('20130130221825');

INSERT INTO schema_migrations (version) VALUES ('20130130221914');

INSERT INTO schema_migrations (version) VALUES ('20130131113813');

INSERT INTO schema_migrations (version) VALUES ('20130131124309');

INSERT INTO schema_migrations (version) VALUES ('20130131124541');

INSERT INTO schema_migrations (version) VALUES ('20130131125336');

INSERT INTO schema_migrations (version) VALUES ('20130131211433');

INSERT INTO schema_migrations (version) VALUES ('20130201115714');

INSERT INTO schema_migrations (version) VALUES ('20130201130558');

INSERT INTO schema_migrations (version) VALUES ('20130201201120');

INSERT INTO schema_migrations (version) VALUES ('20130201203506');

INSERT INTO schema_migrations (version) VALUES ('20130201211530');

INSERT INTO schema_migrations (version) VALUES ('20130201213650');

INSERT INTO schema_migrations (version) VALUES ('20130201213910');

INSERT INTO schema_migrations (version) VALUES ('20130202124409');

INSERT INTO schema_migrations (version) VALUES ('20130202183927');

INSERT INTO schema_migrations (version) VALUES ('20130202184202');

INSERT INTO schema_migrations (version) VALUES ('20130203043003');

INSERT INTO schema_migrations (version) VALUES ('20130203044353');

INSERT INTO schema_migrations (version) VALUES ('20130203123847');

INSERT INTO schema_migrations (version) VALUES ('20130204104825');

INSERT INTO schema_migrations (version) VALUES ('20130205102136');

INSERT INTO schema_migrations (version) VALUES ('20130205120013');

INSERT INTO schema_migrations (version) VALUES ('20130205203649');

INSERT INTO schema_migrations (version) VALUES ('20130206033352');

INSERT INTO schema_migrations (version) VALUES ('20130206033532');

INSERT INTO schema_migrations (version) VALUES ('20130206041446');

INSERT INTO schema_migrations (version) VALUES ('20130206044249');

INSERT INTO schema_migrations (version) VALUES ('20130206044250');

INSERT INTO schema_migrations (version) VALUES ('20130206044251');

INSERT INTO schema_migrations (version) VALUES ('20130206044252');

INSERT INTO schema_migrations (version) VALUES ('20130206044253');

INSERT INTO schema_migrations (version) VALUES ('20130206044254');

INSERT INTO schema_migrations (version) VALUES ('20130206044255');

INSERT INTO schema_migrations (version) VALUES ('20130206190932');

INSERT INTO schema_migrations (version) VALUES ('20130206190933');

INSERT INTO schema_migrations (version) VALUES ('20130206190934');

INSERT INTO schema_migrations (version) VALUES ('20130206190935');

INSERT INTO schema_migrations (version) VALUES ('20130206190936');

INSERT INTO schema_migrations (version) VALUES ('20130206190937');

INSERT INTO schema_migrations (version) VALUES ('20130206190938');

INSERT INTO schema_migrations (version) VALUES ('20130206190939');

INSERT INTO schema_migrations (version) VALUES ('20130206190940');

INSERT INTO schema_migrations (version) VALUES ('20130206190941');

INSERT INTO schema_migrations (version) VALUES ('20130206190942');

INSERT INTO schema_migrations (version) VALUES ('20130206190943');

INSERT INTO schema_migrations (version) VALUES ('20130206190944');

INSERT INTO schema_migrations (version) VALUES ('20130206190945');

INSERT INTO schema_migrations (version) VALUES ('20130206190946');

INSERT INTO schema_migrations (version) VALUES ('20130206190947');

INSERT INTO schema_migrations (version) VALUES ('20130206190948');

INSERT INTO schema_migrations (version) VALUES ('20130206190949');

INSERT INTO schema_migrations (version) VALUES ('20130206190950');

INSERT INTO schema_migrations (version) VALUES ('20130206190951');

INSERT INTO schema_migrations (version) VALUES ('20130206190952');

INSERT INTO schema_migrations (version) VALUES ('20130206190953');

INSERT INTO schema_migrations (version) VALUES ('20130206190954');

INSERT INTO schema_migrations (version) VALUES ('20130206190955');

INSERT INTO schema_migrations (version) VALUES ('20130206190956');

INSERT INTO schema_migrations (version) VALUES ('20130206190957');

INSERT INTO schema_migrations (version) VALUES ('20130206190958');

INSERT INTO schema_migrations (version) VALUES ('20130206190959');

INSERT INTO schema_migrations (version) VALUES ('20130206190960');

INSERT INTO schema_migrations (version) VALUES ('20130207115242');

INSERT INTO schema_migrations (version) VALUES ('20130207120507');

INSERT INTO schema_migrations (version) VALUES ('20130207182552');

INSERT INTO schema_migrations (version) VALUES ('20130207204819');

INSERT INTO schema_migrations (version) VALUES ('20130209015709');

INSERT INTO schema_migrations (version) VALUES ('20130209021809');

INSERT INTO schema_migrations (version) VALUES ('20130209060246');

INSERT INTO schema_migrations (version) VALUES ('20130210015622');

INSERT INTO schema_migrations (version) VALUES ('20130210060436');

INSERT INTO schema_migrations (version) VALUES ('20130210174247');

INSERT INTO schema_migrations (version) VALUES ('20130210194104');

INSERT INTO schema_migrations (version) VALUES ('20130211143138');

INSERT INTO schema_migrations (version) VALUES ('20130211160513');

INSERT INTO schema_migrations (version) VALUES ('20130211160533');

INSERT INTO schema_migrations (version) VALUES ('20130211201937');

INSERT INTO schema_migrations (version) VALUES ('20130212194720');

INSERT INTO schema_migrations (version) VALUES ('20130212195213');

INSERT INTO schema_migrations (version) VALUES ('20130212195307');

INSERT INTO schema_migrations (version) VALUES ('20130212201230');

INSERT INTO schema_migrations (version) VALUES ('20130212201303');

INSERT INTO schema_migrations (version) VALUES ('20130212203850');

INSERT INTO schema_migrations (version) VALUES ('20130212210145');

INSERT INTO schema_migrations (version) VALUES ('20130214052459');

INSERT INTO schema_migrations (version) VALUES ('20130214054215');

INSERT INTO schema_migrations (version) VALUES ('20130214055141');

INSERT INTO schema_migrations (version) VALUES ('20130214212717');

INSERT INTO schema_migrations (version) VALUES ('20130214232033');

INSERT INTO schema_migrations (version) VALUES ('20130214232840');

INSERT INTO schema_migrations (version) VALUES ('20130217152544');

INSERT INTO schema_migrations (version) VALUES ('20130220183447');

INSERT INTO schema_migrations (version) VALUES ('20130221172813');

INSERT INTO schema_migrations (version) VALUES ('20130225171241');

INSERT INTO schema_migrations (version) VALUES ('20130227044350');

INSERT INTO schema_migrations (version) VALUES ('20130227142433');

INSERT INTO schema_migrations (version) VALUES ('20130227185901');

INSERT INTO schema_migrations (version) VALUES ('20130227192935');

INSERT INTO schema_migrations (version) VALUES ('20130227194841');

INSERT INTO schema_migrations (version) VALUES ('20130227195132');

INSERT INTO schema_migrations (version) VALUES ('20130301170219');

INSERT INTO schema_migrations (version) VALUES ('20130301182309');

INSERT INTO schema_migrations (version) VALUES ('20130302062704');

INSERT INTO schema_migrations (version) VALUES ('20130302080631');

INSERT INTO schema_migrations (version) VALUES ('20130302100724');

INSERT INTO schema_migrations (version) VALUES ('20130302101826');
