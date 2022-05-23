/* Creating test database for the feedback server */

/* Functions */

drop function if exists testdata.random_normal;
drop function if exists testdata.random_normal_int;
drop function if exists testdata.random_quasi_normal;
drop function if exists testdata.random_quasi_normal_int;

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


/* Tables */

drop table if exists testdata.countries;
drop table if exists testdata.langs;
drop table if exists testdata.countries_langs;
drop table if exists testdata.oss;
drop table if exists testdata.browsers;
drop table if exists testdata.oss_browsers;
drop table if exists testdata.genres;
drop table if exists testdata.product_groups;
drop table if exists testdata.product_subgroups;
drop table if exists testdata.predicates;
drop table if exists testdata.aspects;
drop table if exists testdata.genres_aspects;
drop table if exists testdata.online_docs;
drop table if exists testdata.topics;
drop table if exists testdata.users;

create table testdata.countries (
    code        varchar,
    title       varchar,
    pop_size    varchar
);

create table testdata.langs (
    code    varchar,
    title   varchar
);

create table testdata.countries_langs (
    country_code    varchar,
    lang_code       varchar,
    lang_share      real
);

create table testdata.oss (
    code        varchar,
    title       varchar,
    os_share    real
);

create table testdata.browsers (
    code    varchar,
    title   varchar
)

create table testdata.oss_browsers (
    os_code             varchar,
    browser_code        varchar,
    browser_share       real
)

create table testdata.genres (
    code    varchar,
    title   varchar
);

create table testdata.product_groups (
    code    varchar,
    title   varchar
);

create table testdata.product_subgroups (
    code     varchar,
    title    varchar,
    pg_code  varchar
);

create table testdata.predicates (
    code    varchar,
    title   varchar
);

create table testdata.aspects (
    code        varchar,
    title       varchar,
    infotype    varchar,
    scope       varchar
);

create table testdata.genres_aspects(
    genre_code  varchar,
    aspect_code varchar
);

create table testdata.online_docs (
    uuid                uuid default gen_random_uuid() not null primary key,
    online_doc_code     varchar,
    pg_code             varchar,
    predicate_code      varchar,
    ps_code             varchar,
    product_code        varchar,
    genre_code          varchar,
    title               varchar
);

create table testdata.topics (
    uuid                uuid default gen_random_uuid() not null primary key,
    topic_id            varchar,
    pg_code             varchar,
    predicate_code      varchar,
    ps_code             varchar,
    product_code        varchar,
    aspect_code         varchar,
    title               varchar,
    quality             int,
    demand              int
);

create table users (
    uuid                uuid default gen_random_uuid() not null primary key,
    country_code        varchar,
    lang_code           varchar,
    os_code             varchar,
    browser_code        varchar,
    iq                  int,
    iw                  int
)


/* Data */

truncate table testdata.genres;
truncate table testdata.product_groups;
truncate table testdata.product_subgroups;
truncate table testdata.predicates;
truncate table testdata.aspects;
truncate table testdata.genres_aspects;
truncate table testdata.online_docs;
truncate table testdata.topics;


/* Producing directories */

insert into testdata.countries (code, title, pop_size) values ('ar', 'Argentina', 40);
insert into testdata.countries (code, title, pop_size) values ('gh', 'Ghana', 24);
insert into testdata.countries (code, title, pop_size) values ('de', 'Germany', 82);
insert into testdata.countries (code, title, pop_size) values ('il', 'Israel', 8);
insert into testdata.countries (code, title, pop_size) values ('jp', 'Japan', 128);
insert into testdata.countries (code, title, pop_size) values ('ru', 'Russia', 145);
insert into testdata.countries (code, title, pop_size) values ('kr', 'South Korea', 50);
insert into testdata.countries (code, title, pop_size) values ('es', 'Spain', 46);
insert into testdata.countries (code, title, pop_size) values ('ua', 'Ukrane', 80);
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

insert into testdata.countries_langs (country_code, lang_code, lang_share) values ('gh', 'en', 1);
insert into testdata.countries_langs (country_code, lang_code, lang_share) values ('de', 'de', 0.95);
insert into testdata.countries_langs (country_code, lang_code, lang_share) values ('il', 'de', 0.05);
insert into testdata.countries_langs (country_code, lang_code, lang_share) values ('il', 'he', 0.5);
insert into testdata.countries_langs (country_code, lang_code, lang_share) values ('il', 'ru', 0.2);
insert into testdata.countries_langs (country_code, lang_code, lang_share) values ('il', 'sp', 0.1);
insert into testdata.countries_langs (country_code, lang_code, lang_share) values ('jp', 'jp', 1);
insert into testdata.countries_langs (country_code, lang_code, lang_share) values ('ru', 'ru', 1);
insert into testdata.countries_langs (country_code, lang_code, lang_share) values ('kr', 'kr', 1);
insert into testdata.countries_langs (country_code, lang_code, lang_share) values ('es', 'es', 1);
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

insert into testdata.predicates (code, title) values ('biotech', 'Biotech');
insert into testdata.predicates (code, title) values ('robotic', 'Robotic');
insert into testdata.predicates (code, title) values ('shared', 'Shared');
insert into testdata.predicates (code, title) values ('virtual', 'Virtual');

insert into testdata.product_subgroups (code, title, pg_code) values ('rabbits', 'Rabbits', 'animals');
insert into testdata.product_subgroups (code, title, pg_code) values ('wombats', 'Wombats', 'animals');
insert into testdata.product_subgroups (code, title, pg_code) values ('cows', 'Cows', 'animals');
insert into testdata.product_subgroups (code, title, pg_code) values ('cats', 'Cats', 'animals');
insert into testdata.product_subgroups (code, title, pg_code) values ('dogs', 'Dogs', 'animals');
insert into testdata.product_subgroups (code, title, pg_code) values ('horses', 'Horses', 'animals');
insert into testdata.product_subgroups (code, title, pg_code) values ('elephants', 'Elephants', 'animals');
insert into testdata.product_subgroups (code, title, pg_code) values ('Rhinoceroses', 'Rhinoceros', 'animals');
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


/* Producing online documents */

with
    online_doc_protos
        as
    (select
        concat(p.code, '_', s.code, '_', g.code) as online_doc_code,
        pg.code as pg_code,
        p.code as predicate_code,
        s.code as ps_code,
        concat(p.code, '_', s.code) as product_code,
        g.code as genre_code,
        concat(p.title, ' ', s.title, '. ', g.title) as title
        from
            testdata.predicates p,
            testdata.product_subgroups s,
            testdata.genres g,
            testdata.product_groups pg
        where
            s.pg_code = pg.code)
    insert into
        online_docs (
            online_doc_code,
            pg_code,
            predicate_code,
            ps_code,
            product_code,
            genre_code,
            title
        )
    select
        online_doc_code,
        pg_code,
        predicate_code,
        ps_code,
        product_code,
        genre_code,
        title
    from
        online_doc_protos;


/* Producing topics */

with
    product_demands (predicate_code, ps_code, product_demand)
        as
    (select p.code, s.code, random_quasi_normal_int(1, 10)
        from
            predicates p, product_subgroups s),
    aspect_demands (aspect_code, aspect_demand)
        as
    (select code, random_quasi_normal_int(1, 10)
        from
            aspects),
    product_group_topics (topic_id,
        pg_code, predicate_code, ps_code, product_code, aspect_code,
        title, quality, demand)
        as
    (select
        concat(a.code, '_', pg.code),
        pg.code, null, null, null, a.code,
        concat(a.title, ' ', pg.title),
        random_quasi_normal_int(1, 100),
        random_normal_int(1, 100)
        from
            testdata.product_groups pg,
            testdata.aspects a

        where
            a.scope = 'product_group'),
    product_subgroup_topics (topic_id,
        pg_code, predicate_code, ps_code, product_code, aspect_code,
        title, quality, demand)
        as
    (select concat(a.code, '_', s.code),
        pg.code, null, s.code, null, a.code,
        concat(a.title, ' ', s.title),
        random_quasi_normal_int(1, 100),
        random_normal_int(1, 100)
        from
            testdata.aspects a,
            testdata.product_subgroups s,
            testdata.product_groups pg
        where
            a.scope = 'product_subgroup'
                and
            s.pg_code = pg.code),
    product_topics (topic_id,
        pg_code, predicate_code, ps_code, product_code, aspect_code,
        title, quality, demand)
        as
    (select
        concat(a.code, '_', p.code, '_', s.code),
        pg.code, p.code, s.code, concat(p.code, '_', s.code), a.code,
        concat(a.title, ' ', p.title, ' ', s.title),
        random_quasi_normal_int(1, 100),
        ad.aspect_demand*pd.product_demand
        from
            testdata.aspects a,
            testdata.predicates p,
            testdata.product_subgroups s,
            testdata.product_groups pg,
            aspect_demands ad,
            product_demands pd
        where
            a.scope = 'product'
                and
            a.code = ad.aspect_code
                and
            p.code = pd.predicate_code
                and
            s.code = pd.ps_code
                and
            s.pg_code = pg.code),
    topic_protos
        as
    (select * from product_group_topics
        union all
    select * from product_subgroup_topics
            union all
    select * from product_topics)
    insert into
        topics (topic_id,
            pg_code, predicate_code, ps_code, product_code, aspect_code,
            title, quality, demand)
        select
            topic_id,
            pg_code, predicate_code, ps_code, product_code, aspect_code,
            title, quality, demand
        from
            topic_protos;


