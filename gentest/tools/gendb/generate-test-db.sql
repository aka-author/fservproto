/* Creating test database for the feedback server */

/* Functions */

drop function if exists testdata.random_normal;
drop function if exists testdata.random_normal_int;
drop function if exists testdata.random_quasi_normal;
drop function if exists testdata.random_quasi_normal_int;
drop function if exists random_normal_20x80;
drop function if exists testdata.random_timestamp;
drop function if exists testdata.code2;
drop function if exists testdata.title2;
drop function if exists testdata.online_doc_title;
drop function if exists testdata.topic_title;
drop function if exists testdata.random_code;
drop function if exists testdata.random_lang_code;
drop function if exists testdata.random_browser_code;
drop function if exists testdata.produce_users;
drop function if exists testdata.random_product_code;


create function testdata.random_normal(min real, max real) returns real
    language plpgsql
as
$$
begin
    return min + (max - min)*(random() + random() + random() + random() + random() + random())/6.0;
end
$$;

create function testdata.random_normal_int(min int, max int) returns int
    language plpgsql
as
$$
begin
    return round(random_normal(min, max));
end
$$;

create function testdata.random_quasi_normal(min real, max real) returns real
    language plpgsql
as
$$
begin
    return min + (max - min)*(random() + random())/2.0;
end
$$;

create function testdata.random_quasi_normal_int(min int, max int) returns int
    language plpgsql
as
$$
begin
    return round(random_quasi_normal(min, max));
end
$$;

create function testdata.random_normal_20x80(
    share_high, low_min real, low_max real, high_min real, high_max real) returns int
language plpgsql
as
$$
begin
    if random() < share_high then
        return random_normal(high_min, high_max);
    else 
        return random_normal(low_min, low_max);
    end if;
end
$$;

/*
create function testdata.random_timestamp(ts_from timestamp, ts_to timestamp) returns timestamp
    language plpgsql
as
$$
begin
    return round(random_quasi_normal(min, max));
end
$$;*/


create function testdata.code2(code1 varchar, code2 varchar) returns varchar
    language plpgsql
as
$$
begin
    return concat(code1, '_', code2);
end
$$;

create function testdata.title2(title1 varchar, title2 varchar) returns varchar
    language plpgsql
as
$$
begin
    return concat(title1, ' ', title2);
end
$$;

create function testdata.online_doc_title(subject_title varchar, genre_title varchar) returns varchar
    language plpgsql
as
$$
begin
    return concat(subject_title, '. ', genre_title);
end
$$;

create function testdata.topic_title(subject_title varchar, aspect_title varchar) returns varchar
    language plpgsql
as
$$
begin
    return concat(aspect_title, ' ', subject_title);
end
$$;


/* Tables */

drop table if exists testdata.model_parms;
drop table if exists testdata.countries;
drop table if exists testdata.langs;
drop table if exists testdata.countries_langs;
drop table if exists testdata.oss;
drop table if exists testdata.browsers;
drop table if exists testdata.oss_browsers;
drop table if exists testdata.genres;
drop table if exists testdata.product_groups;
drop table if exists testdata.product_subgroups;
drop table if exists testdata.kinds;
drop table if exists testdata.products;
drop table if exists testdata.aspects;
drop table if exists testdata.genres_aspects;
drop table if exists testdata.subjects;
drop table if exists testdata.locals;
drop table if exists testdata.online_docs;
drop table if exists testdata.online_doc_vers;
drop table if exists testdata.topics;
drop table if exists testdata.topic_vers;
drop table if exists testdata.users;
drop table is exists testdata.users_products;

create table testdata.model_parms (
    code                varchar,
    n_users             int,
    period_of_modeling  interval,
    is_active           boolean
);

create table testdata.countries (
    code        varchar,
    title       varchar,
    pop_size    int);

create table testdata.langs (
    code    varchar,
    title   varchar);

create table testdata.countries_langs (
    country_code    varchar,
    lang_code       varchar,
    lang_share      real);

create table testdata.oss (
    code        varchar,
    title       varchar,
    os_share    real);

create table testdata.browsers (
    code    varchar,
    title   varchar);

create table testdata.oss_browsers (
    os_code             varchar,
    browser_code        varchar,
    browser_share       real);

create table testdata.genres (
    code    varchar,
    title   varchar);

create table testdata.product_groups (
    code    varchar,
    title   varchar);

create table testdata.product_subgroups (
    code     varchar,
    title    varchar,
    pg_code  varchar);

create table testdata.kinds (
    code    varchar,
    title   varchar);

create table testdata.products (
    code        varchar,
    title       varchar,
    pg_code     varchar,
    ps_code     varchar,
    kind_code   varchar,
    demand      real,
    clarity     real);

create table testdata.aspects (
    code        varchar,
    title       varchar,
    infotype    varchar,
    scope       varchar);

create table testdata.genres_aspects(
    genre_code  varchar,
    aspect_code varchar);

create table testdata.subjects (
    code        varchar,
    title       varchar);

create table testdata.locals (
    lang_code           varchar,
    initial_quality     real,
    quality_trend       real);

create table testdata.online_docs (
    uuid                uuid default gen_random_uuid() not null primary key,
    code                varchar,
    lang_code           varchar,
    title               varchar,
    product_code        varchar,
    pg_code             varchar,
    ps_code             varchar,
    kind_code           varchar,
    genre_code          varchar);

create table testdata.online_doc_vers (
    uuid                uuid default gen_random_uuid() not null primary key,
    online_doc_uuid     uuid,
    ver_no              int,
    ver_date            timestamp);

create table testdata.topics (
    uuid                uuid default gen_random_uuid() not null primary key,
    code                varchar,
    lang_code           varchar,
    title               varchar,
    product_code        varchar,
    pg_code             varchar,
    ps_code             varchar,
    kind_code           varchar,
    aspect_code         varchar,
    initial_quality     real,
    quality_trend       real,
    demand_trend        real);

create table testdata.topic_vers (
    uuid                uuid default gen_random_uuid() not null primary key,
    topic_uuid          uuid,
    ver_no              int,
    ver_date            timestamp);

create table users (
    uuid                uuid default gen_random_uuid() not null primary key,
    country_code        varchar,
    lang_code           varchar,
    os_code             varchar,
    browser_code        varchar,
    iq                  int,
    iw                  int);

create table users_products (
    user_uuid       uuid,
    product_code    varchar
);    


/* Data */

truncate table testdata.model_parms;
truncate table testdata.genres;
truncate table testdata.product_groups;
truncate table testdata.product_subgroups;
truncate table testdata.kinds;
truncate table testdata.aspects;
truncate table testdata.genres_aspects;
truncate table testdata.locals;
truncate table testdata.online_docs;
truncate table testdata.online_doc_vers;
truncate table testdata.topics;
truncate table testdata.topic_vers;
truncate table users;

/* Cinfiguring parameters of the model */
insert 
    into testdata.model_parms (code, n_users, period_of_modeling, is_active) 
    values ('default', 10000, '6 months', true);


/* Producing directories */

insert into testdata.countries (code, title, pop_size) values ('ar', 'Argentina', 40);
insert into testdata.countries (code, title, pop_size) values ('gh', 'Ghana', 24);
insert into testdata.countries (code, title, pop_size) values ('de', 'Germany', 82);
insert into testdata.countries (code, title, pop_size) values ('il', 'Israel', 8);
insert into testdata.countries (code, title, pop_size) values ('jp', 'Japan', 128);
insert into testdata.countries (code, title, pop_size) values ('ru', 'Russia', 145);
insert into testdata.countries (code, title, pop_size) values ('kr', 'South Korea', 50);
insert into testdata.countries (code, title, pop_size) values ('es', 'Spain', 46);
insert into testdata.countries (code, title, pop_size) values ('ua', 'Ukrane', 40);
insert into testdata.countries (code, title, pop_size) values ('uk', 'United Kingdom', 62);
insert into testdata.countries (code, title, pop_size) values ('us', 'USA', 311);
insert into testdata.countries (code, title, pop_size) values ('za', 'South Africa', 50);

insert into testdata.langs (code, title) values ('af', 'Afrikaans');
insert into testdata.langs (code, title) values ('de', 'German');
insert into testdata.langs (code, title) values ('en', 'English');
insert into testdata.langs (code, title) values ('he', 'Hebrew');
insert into testdata.langs (code, title) values ('jp', 'Japanese');
insert into testdata.langs (code, title) values ('kr', 'Korean');
insert into testdata.langs (code, title) values ('ru', 'Russian');
insert into testdata.langs (code, title) values ('es', 'Spainish');
insert into testdata.langs (code, title) values ('ua', 'Ukrainian');

insert into testdata.countries_langs (country_code, lang_code, lang_share) values ('ar', 'es', 1);
insert into testdata.countries_langs (country_code, lang_code, lang_share) values ('es', 'es', 1);
insert into testdata.countries_langs (country_code, lang_code, lang_share) values ('de', 'de', 0.95);
insert into testdata.countries_langs (country_code, lang_code, lang_share) values ('gh', 'en', 1);
insert into testdata.countries_langs (country_code, lang_code, lang_share) values ('il', 'de', 0.05);
insert into testdata.countries_langs (country_code, lang_code, lang_share) values ('il', 'he', 0.5);
insert into testdata.countries_langs (country_code, lang_code, lang_share) values ('il', 'ru', 0.2);
insert into testdata.countries_langs (country_code, lang_code, lang_share) values ('il', 'sp', 0.1);
insert into testdata.countries_langs (country_code, lang_code, lang_share) values ('jp', 'jp', 1);
insert into testdata.countries_langs (country_code, lang_code, lang_share) values ('kr', 'kr', 1);
insert into testdata.countries_langs (country_code, lang_code, lang_share) values ('ru', 'ru', 1);
insert into testdata.countries_langs (country_code, lang_code, lang_share) values ('ua', 'ru', 0.5);
insert into testdata.countries_langs (country_code, lang_code, lang_share) values ('ua', 'ua', 0.5);
insert into testdata.countries_langs (country_code, lang_code, lang_share) values ('uk', 'en', 1);
insert into testdata.countries_langs (country_code, lang_code, lang_share) values ('us', 'en', 0.7);
insert into testdata.countries_langs (country_code, lang_code, lang_share) values ('us', 'es', 0.2);
insert into testdata.countries_langs (country_code, lang_code, lang_share) values ('us', 'ru', 0.1);
insert into testdata.countries_langs (country_code, lang_code, lang_share) values ('za', 'ar', 0.3);

insert into testdata.oss (code, title, os_share) values ('android', 'Android', 0.3);
insert into testdata.oss (code, title, os_share) values ('ios', 'iOS', 0.1);
insert into testdata.oss (code, title, os_share) values ('linux', 'Linux', 0.1);
insert into testdata.oss (code, title, os_share) values ('macos', 'macOS', 0.2);
insert into testdata.oss (code, title, os_share) values ('windows', 'Windows', 0.3);

insert into testdata.browsers (code, title) values ('chrome', 'Chrome');
insert into testdata.browsers (code, title) values ('edge', 'Edge');
insert into testdata.browsers (code, title) values ('ffox', 'FireFox');
insert into testdata.browsers (code, title) values ('opera', 'Opera');
insert into testdata.browsers (code, title) values ('safari', 'Safari');

insert into testdata.oss_browsers (os_code, browser_code, browser_share) values ('android', 'chrome', 0.8);
insert into testdata.oss_browsers (os_code, browser_code, browser_share) values ('android', 'ffox', 0.1);
insert into testdata.oss_browsers (os_code, browser_code, browser_share) values ('android', 'opera', 0.1);
insert into testdata.oss_browsers (os_code, browser_code, browser_share) values ('ios', 'chrome', 0.3);
insert into testdata.oss_browsers (os_code, browser_code, browser_share) values ('ios', 'ffox', 0.3);
insert into testdata.oss_browsers (os_code, browser_code, browser_share) values ('ios', 'safari', 0.4);
insert into testdata.oss_browsers (os_code, browser_code, browser_share) values ('linux', 'chrome', 0.2);
insert into testdata.oss_browsers (os_code, browser_code, browser_share) values ('linux', 'ffox', 0.6);
insert into testdata.oss_browsers (os_code, browser_code, browser_share) values ('linux', 'opera', 0.2);
insert into testdata.oss_browsers (os_code, browser_code, browser_share) values ('macos', 'chrome', 0.3);
insert into testdata.oss_browsers (os_code, browser_code, browser_share) values ('macos', 'ffox', 0.1);
insert into testdata.oss_browsers (os_code, browser_code, browser_share) values ('macos', 'safari', 0.6);
insert into testdata.oss_browsers (os_code, browser_code, browser_share) values ('windows', 'chrome', 0.5);
insert into testdata.oss_browsers (os_code, browser_code, browser_share) values ('windows', 'edge', 0.1);
insert into testdata.oss_browsers (os_code, browser_code, browser_share) values ('windows', 'ffox', 0.3);
insert into testdata.oss_browsers (os_code, browser_code, browser_share) values ('windows', 'opera', 0.1);

insert into testdata.genres (code, title) values ('ug', 'Quick Oparation Guide');
insert into testdata.genres (code, title) values ('mg', 'Maintenance Guide');

insert into testdata.product_groups (code, title) values ('animals', 'Animals');
insert into testdata.product_groups (code, title) values ('persons', 'Persons');
insert into testdata.product_groups (code, title) values ('things', 'Things');

insert into testdata.aspects (code, title, infotype, scope) values ('understanding', 'Understanding', 'concept', 'product_group');
insert into testdata.aspects (code, title, infotype, scope) values ('intro', 'Basics of', 'concept', 'product_subgroup');
insert into testdata.aspects (code, title, infotype, scope) values ('basics', 'Meet', 'concept', 'product');
insert into testdata.aspects (code, title, infotype, scope) values ('planning', 'Planning Your', 'concept', 'product');
insert into testdata.aspects (code, title, infotype, scope) values ('fun', 'Having Fun with', 'concept', 'product');
insert into testdata.aspects (code, title, infotype, scope) values ('safety', 'Feeling Safe Near', 'concept', 'product');
insert into testdata.aspects (code, title, infotype, scope) values ('appending', 'Appending', 'task', 'product');
insert into testdata.aspects (code, title, infotype, scope) values ('activating', 'Activating', 'task', 'product');
insert into testdata.aspects (code, title, infotype, scope) values ('using', 'Using', 'task', 'product');
insert into testdata.aspects (code, title, infotype, scope) values ('deactivating', 'Deactivating', 'task', 'product');
insert into testdata.aspects (code, title, infotype, scope) values ('removing', 'Deleting', 'task', 'product');
insert into testdata.aspects (code, title, infotype, scope) values ('configuring', 'Configuring', 'task', 'product');
insert into testdata.aspects (code, title, infotype, scope) values ('verifying', 'Verifying', 'task', 'product');
insert into testdata.aspects (code, title, infotype, scope) values ('updating', 'Updating', 'task', 'product');
insert into testdata.aspects (code, title, infotype, scope) values ('troubleshooting', 'Troubleshooting', 'task', 'product');
insert into testdata.aspects (code, title, infotype, scope) values ('protecting', 'Protecting', 'task', 'product');
insert into testdata.aspects (code, title, infotype, scope) values ('respassw', 'Resetting a Password to', 'task', 'product');
insert into testdata.aspects (code, title, infotype, scope) values ('sharing', 'Sharing', 'task', 'product');
insert into testdata.aspects (code, title, infotype, scope) values ('repairing', 'Repairing', 'task', 'product');
insert into testdata.aspects (code, title, infotype, scope) values ('maintaining', 'Maintaining', 'task', 'product');
insert into testdata.aspects (code, title, infotype, scope) values ('supressing', 'Supressing', 'task', 'product');
insert into testdata.aspects (code, title, infotype, scope) values ('resuming', 'Resuming', 'task', 'product');
insert into testdata.aspects (code, title, infotype, scope) values ('resetting', 'Resetting', 'task', 'product');

insert into testdata.genres_aspects(genre_code, aspect_code) values ('ug', 'understanding');
insert into testdata.genres_aspects(genre_code, aspect_code) values ('ug', 'intro');
insert into testdata.genres_aspects(genre_code, aspect_code) values ('ug', 'basics');
insert into testdata.genres_aspects(genre_code, aspect_code) values ('ug', 'planning');
insert into testdata.genres_aspects(genre_code, aspect_code) values ('ug', 'fun');
insert into testdata.genres_aspects(genre_code, aspect_code) values ('ug', 'safety');
insert into testdata.genres_aspects(genre_code, aspect_code) values ('ug', 'appending');
insert into testdata.genres_aspects(genre_code, aspect_code) values ('ug', 'activating');
insert into testdata.genres_aspects(genre_code, aspect_code) values ('ug', 'using');
insert into testdata.genres_aspects(genre_code, aspect_code) values ('ug', 'deactivating');
insert into testdata.genres_aspects(genre_code, aspect_code) values ('ug', 'removing');
insert into testdata.genres_aspects(genre_code, aspect_code) values ('ug', 'configuring');
insert into testdata.genres_aspects(genre_code, aspect_code) values ('ug', 'sharing');
insert into testdata.genres_aspects(genre_code, aspect_code) values ('mg', 'basics');
insert into testdata.genres_aspects(genre_code, aspect_code) values ('mg', 'safety');
insert into testdata.genres_aspects(genre_code, aspect_code) values ('mg', 'verifying');
insert into testdata.genres_aspects(genre_code, aspect_code) values ('mg', 'updating');
insert into testdata.genres_aspects(genre_code, aspect_code) values ('mg', 'troubleshooting');
insert into testdata.genres_aspects(genre_code, aspect_code) values ('mg', 'protecting');
insert into testdata.genres_aspects(genre_code, aspect_code) values ('mg', 'respassw');
insert into testdata.genres_aspects(genre_code, aspect_code) values ('mg', 'repairing');
insert into testdata.genres_aspects(genre_code, aspect_code) values ('mg', 'maintaining');
insert into testdata.genres_aspects(genre_code, aspect_code) values ('mg', 'supressing');
insert into testdata.genres_aspects(genre_code, aspect_code) values ('mg', 'resuming');
insert into testdata.genres_aspects(genre_code, aspect_code) values ('mg', 'resetting');

insert into testdata.kinds (code, title) values ('biotech', 'Biotech');
insert into testdata.kinds (code, title) values ('robotic', 'Robotic');
insert into testdata.kinds (code, title) values ('shared', 'Shared');
insert into testdata.kinds (code, title) values ('virtual', 'Virtual');

insert into testdata.product_subgroups (code, title, pg_code) values ('rabbits', 'Rabbits', 'animals');
insert into testdata.product_subgroups (code, title, pg_code) values ('wombats', 'Wombats', 'animals');
insert into testdata.product_subgroups (code, title, pg_code) values ('cows', 'Cows', 'animals');
insert into testdata.product_subgroups (code, title, pg_code) values ('cats', 'Cats', 'animals');
insert into testdata.product_subgroups (code, title, pg_code) values ('dogs', 'Dogs', 'animals');
insert into testdata.product_subgroups (code, title, pg_code) values ('horses', 'Horses', 'animals');
insert into testdata.product_subgroups (code, title, pg_code) values ('elephants', 'Elephants', 'animals');
insert into testdata.product_subgroups (code, title, pg_code) values ('rhinoceroses', 'Rhinoceros', 'animals');
insert into testdata.product_subgroups (code, title, pg_code) values ('hamsters', 'Hamsters', 'animals');
insert into testdata.product_subgroups (code, title, pg_code) values ('platypuses', 'Platypuses', 'animals');

insert into testdata.product_subgroups (code, title, pg_code) values ('teapots', 'Teapots', 'things');
insert into testdata.product_subgroups (code, title, pg_code) values ('vcleaners', 'Vacuum Cleaners', 'things');
insert into testdata.product_subgroups (code, title, pg_code) values ('fridges', 'Refrigerators', 'things');
insert into testdata.product_subgroups (code, title, pg_code) values ('routers', 'Routers', 'things');
insert into testdata.product_subgroups (code, title, pg_code) values ('phones', 'Cell Phones', 'things');
insert into testdata.product_subgroups (code, title, pg_code) values ('wmachines', 'Washing Machines', 'things');
insert into testdata.product_subgroups (code, title, pg_code) values ('aconds', 'Air Conditioners', 'things');
insert into testdata.product_subgroups (code, title, pg_code) values ('toasters', 'Toasters', 'things');
insert into testdata.product_subgroups (code, title, pg_code) values ('hookahs', 'Hookahs', 'things');
insert into testdata.product_subgroups (code, title, pg_code) values ('mgrinders', 'Meat Grinders', 'things');

insert into testdata.product_subgroups (code, title, pg_code) values ('relatives', 'Relatives', 'persons');
insert into testdata.product_subgroups (code, title, pg_code) values ('friends', 'Friends', 'persons');
insert into testdata.product_subgroups (code, title, pg_code) values ('classmates', 'Classmates', 'persons');
insert into testdata.product_subgroups (code, title, pg_code) values ('neighbours', 'Neighbours', 'persons');
insert into testdata.product_subgroups (code, title, pg_code) values ('сolleagues', 'Сolleagues', 'persons');
insert into testdata.product_subgroups (code, title, pg_code) values ('adherents', 'Adherents', 'persons');
insert into testdata.product_subgroups (code, title, pg_code) values ('psychos', 'Psychotherapists', 'persons');
insert into testdata.product_subgroups (code, title, pg_code) values ('enemies', 'Enemies', 'persons');
insert into testdata.product_subgroups (code, title, pg_code) values ('partners', 'Partners', 'persons');
insert into testdata.product_subgroups (code, title, pg_code) values ('strangers', 'Strangers', 'persons');


/* Producing products */

insert into
    products (
        code, title,
        pg_code, ps_code, kind_code,
        demand, clarity)
    select
        testdata.code2(k.code, ps.code), testdata.title2(k.title,  ps.title),
        pg.code, ps.code, k.code,
        testdata.random_normal_20x80(0.1, 0.0, 0.8, 0.8, 1.0), testdata.random_normal(0, 1)
        from
            testdata.product_groups pg,
            testdata.product_subgroups ps,
            testdata.kinds k
        where
             ps.pg_code = pg.code;

/* Producing locals */

insert into testdata.locals (lang_code, initial_quality, quality_trend) values ('en', 0.95,  0.0);
insert into testdata.locals (lang_code, initial_quality, quality_trend) values ('es', 0.70,  0.2);
insert into testdata.locals (lang_code, initial_quality, quality_trend) values ('de', 0.70,  0.1);
insert into testdata.locals (lang_code, initial_quality, quality_trend) values ('jp', 0.30,  0.5);
insert into testdata.locals (lang_code, initial_quality, quality_trend) values ('kr', 0.30,  0.5);
insert into testdata.locals (lang_code, initial_quality, quality_trend) values ('ru', 0.90, -0.1);


/* Producing online documents */

insert into
    online_docs (
        code, lang_code,
        title,
        product_code, pg_code, ps_code, kind_code,
        genre_code)
    select
        testdata.code2(p.code, g.code), l.lang_code,
        testdata.online_doc_title(p.title, g.title),
        p.code, p.pg_code, p.ps_code, p.kind_code,
        g.code
        from
            testdata.products p,
            testdata.genres g,
            locals l;


/* Producing topics */

with
    product_group_topics (
        code, title,
        product_code, pg_code, ps_code, kind_code,
        aspect_code,
        initial_quality, quality_trend, demand_trend)
        as
    (select
        testdata.code2(a.code, pg.code), testdata.topic_title(pg.title, a.title),
        null, pg.code, null, null,
        a.code,
        testdata.random_normal(0, 1), testdata.random_normal(-1, 1), testdata.random_normal(-1, 1)
        from
            testdata.product_groups pg,
            testdata.aspects a
        where
            a.scope = 'product_group'),
    product_subgroup_topics (
        code, title,
        product_code, pg_code, ps_code, kind_code,
        aspect_code,
        initial_quality, quality_trend, demad_trend)
        as
    (select
        testdata.code2(a.code, ps.code), testdata.topic_title(ps.title, a.title),
        null, ps.pg_code, ps.code, null,
        a.code,
        testdata.random_normal(0, 1), testdata.random_normal(-1, 1), testdata.random_normal(-1, 1)
        from
            testdata.aspects a,
            testdata.product_subgroups ps
        where
            a.scope = 'product_subgroup'),
    product_topics (
        code, title,
        product_code, pg_code, ps_code, kind_code,
        aspect_code,
        initial_quality, quality_trend, demad_trend)
        as
    (select
        testdata.code2(a.code, p.code), testdata.topic_title(p.title, a.title),
        p.code, p.pg_code, p.ps_code, p.kind_code,
        a.code,
        testdata.random_normal(0, 1), testdata.random_normal(-1, 1), testdata.random_normal(-1, 1)
        from
            testdata.products p,
            testdata.aspects a
        where
            a.scope = 'product'),
    topic_protos
        as
    (select * from product_group_topics
        union all
    select * from product_subgroup_topics
        union all
    select * from product_topics)
insert into
    topics (
        code, lang_code,
        title,
        product_code, pg_code, ps_code, kind_code,
        aspect_code,
        initial_quality, quality_trend,
        demand_trend)
    select
        code, lang_code,
        title,
        product_code, pg_code, ps_code, kind_code,
        aspect_code,
        tp.initial_quality*l.initial_quality, tp.quality_trend*l.quality_trend,
        demand_trend
    from
        topic_protos tp,
        locals l;

/* TBD */
/*
create function testdata.produce_online_doc_vers(online_doc_code varchar, ts_from timestamp) returns boolean
    language plpgsql
as
$$
begin
    nvers = random(1, 10);
    for i in 1..nvers
    loop
        ts_ver = ts_from + testdata.random_duration(7, 30);
        insert into testdata.online_doc_vers (
            online_doc_code, ver_timestamp)
        values (
            online_doc_code, ts_ver);
    end loop;
    return true;
end
$$;*/


/* Producing users */

create function testdata.random_code(codes varchar array, shares real array) returns varchar
    language plpgsql
as
$$
    declare
        max_total real;
        dice real;
        total real;
        i int;
        random_code varchar;
begin
    max_total = 0;
    for i in 1..coalesce(cardinality(shares), 0)
    loop
        if shares[i] is not null then
            max_total = max_total + shares[i];
        end if;
    end loop;

    dice = random()*max_total;

    i = 1;
    total = shares[1];
    while total < dice
    loop
        i = i + 1;
        total = total + shares[i];
    end loop;

    random_code = codes[i];

    return random_code;
end
$$;

create function testdata.random_lang_code(target_country_code varchar) returns varchar
    language plpgsql
as
$$
    declare
        lang_codes varchar array;
        lang_shares real array;
begin
    select array_agg(lang_code), array_agg(lang_share) 
        into
            lang_codes, lang_shares 
        from 
            testdata.countries_langs cl 
        where 
            cl.country_code = target_country_code;

    return random_code(lang_codes, lang_shares);
end
$$

create function testdata.random_browser_code(target_os_code varchar) returns varchar
    language plpgsql
as
$$
    declare
        browser_codes varchar array;
        browser_shares real array;
begin
    select
           array_agg(browser_code), array_agg(browser_share)
        into
            browser_codes, browser_shares
        from
             testdata.oss_browsers ob
        where
              ob.os_code = target_os_code;

    return random_code(browser_codes, browser_shares);
end
$$;

create function produce_users(n_users int) returns boolean
    language plpgsql
as
$$
declare
    country_code varchar;
    lang_code varchar;
    os_code varchar;
    browser_code varchar;
begin
    for i in 1..n_users
    loop
        select testdata.random_code(array_agg(code), array_agg(pop_size)) into country_code from testdata.countries;
        select random_lang_code(country_code) into lang_code;

        select testdata.random_code(array_agg(code), array_agg(os_share)) into os_code from testdata.oss;
        select random_browser_code(os_code) into browser_code;

        insert
            into testdata.users (
                country_code, lang_code, 
                os_code, browser_code,
                iq, iw)
            values (
                country_code, lang_code, 
                os_code, browser_code,
                random_normal(0, 200), random_normal(0, 200));        
    end loop;

    return true;
end
$$;

select produce_users(n_users) from model_parms;

create function testdata.random_product_code() returns varchar
    language plpgsql
as
$$
declare
    product_codes varchar array;
    product_demands real array;
begin
    select
           array_agg(code), array_agg(demand)
        into
            product_codes, product_demands
        from
            testdata.products;

    return random_code(product_codes, product_demands);
end
$$;

insert into
    users_products (user_uuid, product_code)
select
    u.uuid, random_product_code() from users u;

