/* Creating test database for the feedback server */

/* Common functions */

/*  Managing arrays */

drop function if exists testdata.array_total;

create function testdata.array_total(numbers real array) returns real
language plpgsql
as
$$
declare
    total real;
    i int;
begin
    total = 0;
    for i in 1..coalesce(cardinality(numbers), 0)
    loop
        if numbers[i] is not null then
            total = total + numbers[i];
        end if;
    end loop;

    return total;
end
$$;


drop function if exists testdata.timestamp_rank;

create function testdata.timestamp_rank(tss timestamp array, ts timestamp) returns int
language plpgsql
as
$$
declare
    i int;
    rank int;
begin
    rank = 1;

    for i in 1..coalesce(cardinality(tss), 0)
    loop
        if ts > tss[i] then
            rank = rank + 1;
        end if;
    end loop;

    return rank;
end
$$;

select timestamp_rank(array['2022-04-03'::timestamp,'2022-02-03'::timestamp,'2022-01-03'::timestamp,'2022-06-03'::timestamp], '2022-02-03'::timestamp);

/* Randomization */

drop function if exists testdata.random_int;

create function testdata.random_int(min int, max int) returns int
    language plpgsql
as
$$
begin
    return min + (max - min)*random();
end
$$;


drop function if exists testdata.random_normal;

create function testdata.random_normal(min real, max real) returns real
    language plpgsql
as
$$
begin
    return min + (max - min)*(random() + random() + random() + random() + random() + random())/6.0;
end
$$;


drop function if exists testdata.random_normal_int;

create function testdata.random_normal_int(min int, max int) returns int
    language plpgsql
as
$$
begin
    return round(random_normal(min, max));
end
$$;


drop function if exists testdata.random_quasi_normal;

create function testdata.random_quasi_normal(min real, max real) returns real
    language plpgsql
as
$$
begin
    return min + (max - min)*(random() + random())/2.0;
end
$$;


drop function if exists testdata.random_quasi_normal_int;

create function testdata.random_quasi_normal_int(min int, max int) returns int
language plpgsql
as
$$
begin
    return round(random_quasi_normal(min, max));
end
$$;


drop function if exists testdata.random_hyper;

create function testdata.random_hyper(min real, max real) returns real
    language plpgsql
as
$$
begin
    return min + (max - min)*(1/random());
end
$$;


drop function if exists testdata.random_normal_20x80;

create function testdata.random_normal_20x80(
    share_high real, low_min real, low_max real, high_min real, high_max real) returns real
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


drop function if exists testdata.random_timestamp;

create function testdata.random_timestamp(ts_from timestamp, ts_to timestamp) returns timestamp
    language plpgsql
as
$$
begin
    return ts_from + (ts_to - ts_from)*random();
end
$$;


drop function if exists testdata.random_code;

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
    dice = random()*testdata.array_total(shares);

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


drop function if exists testdata.random_code_or_null;

create function testdata.random_code_or_null(
    codes varchar array, shares real array, null_probability real) returns varchar
language plpgsql
as
$$
declare
    random_code varchar;
    total real;
    null_share real;
    codes_with_null real array;
    shares_with_null real array;
begin
    random_code = null;

    if  (0 <= null_probability) and (null_probability < 1) then
        total = testdata.array_total(shares);
        null_share = null_probability*total/(1 - null_probability);
        codes_with_null = array_append(codes, null);
        shares_with_null = array_append(shares, null_share);
        random_code = testdata.random_code(codes_with_null, shares_with_null);
    end if;

    return random_code;
end
$$;


/* Assembling codes and titles */

drop function if exists testdata.code2;

create function testdata.code2(code1 varchar, code2 varchar) returns varchar
language plpgsql
as
$$
begin
    return concat(code1, '_', code2);
end
$$;


drop function if exists testdata.title2;

create function testdata.title2(title1 varchar, title2 varchar) returns varchar
language plpgsql
as
$$
begin
    return concat(title1, ' ', title2);
end
$$;


drop function if exists testdata.online_doc_title;

create function testdata.online_doc_title(subject_title varchar, genre_title varchar) returns varchar
language plpgsql
as
$$
begin
    return concat(subject_title, '. ', genre_title);
end
$$;


drop function if exists testdata.topic_title;

create function testdata.topic_title(subject_title varchar, aspect_title varchar) returns varchar
language plpgsql
as
$$
begin
    return concat(aspect_title, ' ', subject_title);
end
$$;


/* Tables */

drop table if exists testdata.model_params;
drop table if exists testdata.countries;
drop table if exists testdata.langs;
drop table if exists testdata.countries__langs;
drop table if exists testdata.oss;
drop table if exists testdata.browsers;
drop table if exists testdata.oss__browsers;
drop table if exists testdata.genres;
drop table if exists testdata.product_groups;
drop table if exists testdata.product_subgroups;
drop table if exists testdata.technologies;
drop table if exists testdata.products;
drop table if exists testdata.aspects;
drop table if exists testdata.genres__aspects;
drop table if exists testdata.subjects;
drop table if exists testdata.gtopics__subjects;
drop index if exists testdata.gtopics__subjects__topic_code__subject_code__idx;
drop table if exists testdata.locals;
drop table if exists testdata.online_docs;
drop table if exists testdata.online_doc_vers;
drop table if exists testdata.topics;
drop index if exists testdata.topics__code__lang_code__idx;
drop table if exists testdata.topic_vers;
drop table if exists testdata.readers;
drop table if exists testdata.readers__products;
drop table if exists testdata.reader_activities;

create table testdata.model_params (
    code                            varchar,
    n_readers                       int,
    period_of_modeling              interval,
    max_subjects_per_topic          int,
    share_of_topics_with_subjects   real,
    max_vers_per_online_doc         int,
    new_topic_ver_probability       real,
    max_sessions_per_reader         int,
    max_topics_per_session          int,
    topic_view_probability          real,
    bounce_probability              real,
    dislike_probability             real,
    message_probability             real,
    source_lang_code                varchar,
    simulation_start                timestamp,
    simulation_final                timestamp,
    is_active                       boolean
);

create table testdata.countries (
    code        varchar,
    title       varchar,
    pop_size    int);

create table testdata.langs (
    code    varchar,
    title   varchar);

create table testdata.countries__langs (
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

create table testdata.oss__browsers (
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

create table testdata.technologies (
    code    varchar,
    title   varchar);

create table testdata.products (
    code                varchar,
    title               varchar,
    pg_code             varchar,
    ps_code             varchar,
    technology_code     varchar,
    demand              real,
    clarity             real);

create table testdata.aspects (
    code                varchar,
    title               varchar,
    infotype            varchar,
    scope               varchar);

create table testdata.genres__aspects(
    genre_code          varchar,
    aspect_code         varchar);

create table testdata.subjects (
    code                varchar,
    title               varchar,
    subject_share       real);

create table testdata.gtopics__subjects (
    topic_code          varchar,
    subject_code        varchar
);

create unique index
    gtopics__subjects__topic_code__subject_code__idx
    on testdata.gtopics__subjects(topic_code, subject_code);

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
    technology_code     varchar,
    genre_code          varchar);

create table testdata.online_doc_vers (
    uuid                uuid default gen_random_uuid() not null primary key,
    online_doc_code     varchar,
    lang_code           varchar,
    released_at         timestamp,
    ver_no              int);

create table testdata.topics (
    uuid                uuid default gen_random_uuid() not null primary key,
    code                varchar,
    lang_code           varchar,
    title               varchar,
    product_code        varchar,
    pg_code             varchar,
    ps_code             varchar,
    technology_code     varchar,
    aspect_code         varchar,
    initial_quality     real,
    quality_trend       real,
    demand_trend        real);

create unique index
    topics__code__lang_code__idx
    on testdata.topics(code, lang_code);

create table testdata.topic_vers (
    uuid                uuid default gen_random_uuid() not null primary key,
    topic_code          varchar,
    lang_code           varchar,
    ver_no              int,
    released_at         timestamp);

create table testdata.readers (
    uuid                uuid default gen_random_uuid() not null primary key,
    country_code        varchar,
    lang_code           varchar,
    os_code             varchar,
    browser_code        varchar,
    intension           real,
    intelligence        real,
    irritability        real);

create table testdata.readers__products (
    reader_uuid         uuid,
    product_code        varchar);

create table testdata.reader_activities (
    uuid                    uuid default gen_random_uuid() not null primary key,
    online_doc_code         varchar,
    online_doc_lang_code    varchar,
    online_doc_ver_no       int,
    topic_code              varchar,
    topic_ver_no            int,
    reader_country_code     varchar,
    reader_lang_code        varchar,
    reader_os_code          varchar,
    reader_browser_code     varchar,
    accepted_at             timestamp,
    activity_type_code      varchar,
    message_type_code       varchar,
    message_text            varchar);


/* Data */

truncate table testdata.model_params;
truncate table testdata.genres;
truncate table testdata.product_groups;
truncate table testdata.product_subgroups;
truncate table testdata.technologies;
truncate table testdata.aspects;
truncate table testdata.genres__aspects;
truncate table testdata.locals;
truncate table testdata.online_docs;
truncate table testdata.online_doc_vers;
truncate table testdata.topics;
truncate table testdata.topic_vers;
truncate table testdata.readers;
truncate table testdata.readers__products;
truncate table testdata.reader_activities;

/* Configuring parameters of the model */

insert
    into testdata.model_params (
        code, n_readers,
        max_subjects_per_topic, share_of_topics_with_subjects,
        max_vers_per_online_doc, new_topic_ver_probability,
        max_sessions_per_reader, max_topics_per_session, topic_view_probability,
        bounce_probability, dislike_probability, message_probability,
        source_lang_code,
        simulation_start, simulation_final,
        is_active)
    values (
        'default', 10000,
        2, 0.2,
        5, 0.2,
        10, 5, 0.2,
        0.1, 0.05, 0.01,
        'en',
        '2022-01-01', '2022-05-30',
        true);


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

insert into testdata.countries__langs (country_code, lang_code, lang_share) values ('ar', 'es', 1);
insert into testdata.countries__langs (country_code, lang_code, lang_share) values ('es', 'es', 1);
insert into testdata.countries__langs (country_code, lang_code, lang_share) values ('de', 'de', 0.95);
insert into testdata.countries__langs (country_code, lang_code, lang_share) values ('gh', 'en', 1);
insert into testdata.countries__langs (country_code, lang_code, lang_share) values ('il', 'de', 0.05);
insert into testdata.countries__langs (country_code, lang_code, lang_share) values ('il', 'he', 0.5);
insert into testdata.countries__langs (country_code, lang_code, lang_share) values ('il', 'ru', 0.2);
insert into testdata.countries__langs (country_code, lang_code, lang_share) values ('il', 'sp', 0.1);
insert into testdata.countries__langs (country_code, lang_code, lang_share) values ('jp', 'jp', 1);
insert into testdata.countries__langs (country_code, lang_code, lang_share) values ('kr', 'kr', 1);
insert into testdata.countries__langs (country_code, lang_code, lang_share) values ('ru', 'ru', 1);
insert into testdata.countries__langs (country_code, lang_code, lang_share) values ('ua', 'ru', 0.5);
insert into testdata.countries__langs (country_code, lang_code, lang_share) values ('ua', 'ua', 0.5);
insert into testdata.countries__langs (country_code, lang_code, lang_share) values ('uk', 'en', 1);
insert into testdata.countries__langs (country_code, lang_code, lang_share) values ('us', 'en', 0.7);
insert into testdata.countries__langs (country_code, lang_code, lang_share) values ('us', 'es', 0.2);
insert into testdata.countries__langs (country_code, lang_code, lang_share) values ('us', 'ru', 0.1);
insert into testdata.countries__langs (country_code, lang_code, lang_share) values ('za', 'ar', 0.3);

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

insert into testdata.oss__browsers (os_code, browser_code, browser_share) values ('android', 'chrome', 0.8);
insert into testdata.oss__browsers (os_code, browser_code, browser_share) values ('android', 'ffox', 0.1);
insert into testdata.oss__browsers (os_code, browser_code, browser_share) values ('android', 'opera', 0.1);
insert into testdata.oss__browsers (os_code, browser_code, browser_share) values ('ios', 'chrome', 0.3);
insert into testdata.oss__browsers (os_code, browser_code, browser_share) values ('ios', 'ffox', 0.3);
insert into testdata.oss__browsers (os_code, browser_code, browser_share) values ('ios', 'safari', 0.4);
insert into testdata.oss__browsers (os_code, browser_code, browser_share) values ('linux', 'chrome', 0.2);
insert into testdata.oss__browsers (os_code, browser_code, browser_share) values ('linux', 'ffox', 0.6);
insert into testdata.oss__browsers (os_code, browser_code, browser_share) values ('linux', 'opera', 0.2);
insert into testdata.oss__browsers (os_code, browser_code, browser_share) values ('macos', 'chrome', 0.3);
insert into testdata.oss__browsers (os_code, browser_code, browser_share) values ('macos', 'ffox', 0.1);
insert into testdata.oss__browsers (os_code, browser_code, browser_share) values ('macos', 'safari', 0.6);
insert into testdata.oss__browsers (os_code, browser_code, browser_share) values ('windows', 'chrome', 0.5);
insert into testdata.oss__browsers (os_code, browser_code, browser_share) values ('windows', 'edge', 0.1);
insert into testdata.oss__browsers (os_code, browser_code, browser_share) values ('windows', 'ffox', 0.3);
insert into testdata.oss__browsers (os_code, browser_code, browser_share) values ('windows', 'opera', 0.1);

insert into testdata.genres (code, title) values ('ug', 'Quick Operation Guide');
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

insert into testdata.genres__aspects(genre_code, aspect_code) values ('ug', 'understanding');
insert into testdata.genres__aspects(genre_code, aspect_code) values ('ug', 'intro');
insert into testdata.genres__aspects(genre_code, aspect_code) values ('ug', 'basics');
insert into testdata.genres__aspects(genre_code, aspect_code) values ('ug', 'planning');
insert into testdata.genres__aspects(genre_code, aspect_code) values ('ug', 'fun');
insert into testdata.genres__aspects(genre_code, aspect_code) values ('ug', 'safety');
insert into testdata.genres__aspects(genre_code, aspect_code) values ('ug', 'appending');
insert into testdata.genres__aspects(genre_code, aspect_code) values ('ug', 'activating');
insert into testdata.genres__aspects(genre_code, aspect_code) values ('ug', 'using');
insert into testdata.genres__aspects(genre_code, aspect_code) values ('ug', 'deactivating');
insert into testdata.genres__aspects(genre_code, aspect_code) values ('ug', 'removing');
insert into testdata.genres__aspects(genre_code, aspect_code) values ('ug', 'configuring');
insert into testdata.genres__aspects(genre_code, aspect_code) values ('ug', 'sharing');
insert into testdata.genres__aspects(genre_code, aspect_code) values ('mg', 'basics');
insert into testdata.genres__aspects(genre_code, aspect_code) values ('mg', 'safety');
insert into testdata.genres__aspects(genre_code, aspect_code) values ('mg', 'verifying');
insert into testdata.genres__aspects(genre_code, aspect_code) values ('mg', 'updating');
insert into testdata.genres__aspects(genre_code, aspect_code) values ('mg', 'troubleshooting');
insert into testdata.genres__aspects(genre_code, aspect_code) values ('mg', 'protecting');
insert into testdata.genres__aspects(genre_code, aspect_code) values ('mg', 'respassw');
insert into testdata.genres__aspects(genre_code, aspect_code) values ('mg', 'repairing');
insert into testdata.genres__aspects(genre_code, aspect_code) values ('mg', 'maintaining');
insert into testdata.genres__aspects(genre_code, aspect_code) values ('mg', 'supressing');
insert into testdata.genres__aspects(genre_code, aspect_code) values ('mg', 'resuming');
insert into testdata.genres__aspects(genre_code, aspect_code) values ('mg', 'resetting');

insert into testdata.technologies (code, title) values ('biotech', 'Biotech');
insert into testdata.technologies (code, title) values ('robotic', 'Robotic');
insert into testdata.technologies (code, title) values ('shared', 'Shared');
insert into testdata.technologies (code, title) values ('virtual', 'Virtual');

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

insert into testdata.subjects(code, title, subject_share) values ('green', 'Green practice', 0.8);
insert into testdata.subjects(code, title, subject_share) values ('gndeq', 'Gender equality', 0.1);
insert into testdata.subjects(code, title, subject_share) values ('mlhlt', 'Mental health', 0.3);
insert into testdata.subjects(code, title, subject_share) values ('socmb', 'Social mobility', 0.1);
insert into testdata.subjects(code, title, subject_share) values ('wrklf', 'Work-life balance', 0.8);


/* Producing products */

insert into
    products (
        code, title,
        pg_code, ps_code, technology_code,
        demand, clarity)
    select
        testdata.code2(k.code, ps.code), testdata.title2(k.title,  ps.title),
        pg.code, ps.code, k.code,
        testdata.random_hyper(0, 1), testdata.random_normal(0, 1)
        from
            testdata.product_groups pg,
            testdata.product_subgroups ps,
            testdata.technologies k
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
        product_code, pg_code, ps_code, technology_code,
        genre_code)
    select
        testdata.code2(p.code, g.code), l.lang_code,
        testdata.online_doc_title(p.title, g.title),
        p.code, p.pg_code, p.ps_code, p.technology_code,
        g.code
        from
            testdata.products p,
            testdata.genres g,
            locals l;


/* Producing topics */

with
    product_group_topics (
        code, title,
        product_code, pg_code, ps_code, technology_code,
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
        product_code, pg_code, ps_code, technology_code,
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
        product_code, pg_code, ps_code, technology_code,
        aspect_code,
        initial_quality, quality_trend, demad_trend)
        as
    (select
        testdata.code2(a.code, p.code), testdata.topic_title(p.title, a.title),
        p.code, p.pg_code, p.ps_code, p.technology_code,
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
        product_code, pg_code, ps_code, technology_code,
        aspect_code,
        initial_quality, quality_trend,
        demand_trend)
    select
        code, l.lang_code,
        title,
        product_code, pg_code, ps_code, technology_code,
        aspect_code,
        tp.initial_quality*l.initial_quality, tp.quality_trend*l.quality_trend,
        demand_trend
    from
        topic_protos tp,
        locals l;


/* Associating global topics with subjects */

drop function if exists assign_subjects_to_topics;

create or replace function testdata.assign_subjects_to_topics() returns void
language plpgsql
as
$$
declare
    target_gtopic_codes varchar array;
    subject_codes varchar array;
    subject_shares real array;
    mspt int;
    stws real;
    slc varchar;
    n_subjects int;
    target_subject_code varchar;
    count_duplicated int;
    gtopic_idx int;
    subject_idx int;
begin
    select
        max_subjects_per_topic, share_of_topics_with_subjects, source_lang_code
        into mspt, stws, slc
        from testdata.model_params
        where is_active;

    select
        array_agg(code)
        into target_gtopic_codes
        from testdata.topics
        where lang_code = slc;

    select
        array_agg(code), array_agg(subject_share)
        into subject_codes, subject_shares
        from testdata.subjects;

    for gtopic_idx in 1..coalesce(cardinality(target_gtopic_codes), 0)
    loop

        if random() < stws then

            n_subjects = testdata.random_int(1, mspt);
            subject_idx = 1;
            while subject_idx <= n_subjects
            loop
                target_subject_code = testdata.random_code(subject_codes, subject_shares);
                select count(gt.topic_code)
                    into count_duplicated
                    from testdata.gtopics__subjects gt
                    where gt.topic_code = target_gtopic_codes[gtopic_idx] and gt.subject_code = target_subject_code;
                if count_duplicated = 0 then
                    insert
                        into testdata.gtopics__subjects (topic_code, subject_code)
                        values (target_gtopic_codes[gtopic_idx], target_subject_code);
                    subject_idx = subject_idx + 1;
                end if;
            end loop;

        end if;

    end loop;
end
$$;

select  testdata.assign_subjects_to_topics();


/* Producing versions for source online documents */

drop function if exists testdata.produce_source_online_doc_vers;

create or replace function testdata.produce_source_online_doc_vers() returns void
language plpgsql
as
$$
declare
    slc varchar;
    mvpod int;
    sma timestamp;
    fma timestamp;
    online_doc_codes varchar array;
    online_doc_idx int;
    n_vers int;
    ver_ats timestamp array;
    ver_idx int;
    new_released_at timestamp;
    new_ver_no int;
begin

    select
        source_lang_code,
        max_vers_per_online_doc,
        simulation_start, simulation_final
        into
            slc,
            mvpod,
            sma, fma
        from testdata.model_params
        where is_active;

    select
        array_agg(code)
        into online_doc_codes
        from testdata.online_docs
        where lang_code = slc;

    for online_doc_idx in 1..coalesce(cardinality(online_doc_codes), 0)
    loop
        n_vers = testdata.random_int(1, mvpod);

        ver_ats = array[]::timestamp[];
        for ver_idx in 1..n_vers
        loop
            ver_ats[ver_idx] = testdata.random_timestamp(sma, fma);
        end loop;

        for ver_idx in 1..n_vers
        loop
            insert
                into online_doc_vers (online_doc_code, lang_code, released_at, ver_no)
                values (online_doc_codes[online_doc_idx], slc, ver_ats[ver_idx], timestamp_rank(ver_ats, ver_ats[ver_idx]));
        end loop;

    end loop;

end
$$;

select testdata.produce_source_online_doc_vers();


/* Producing versions for translated versions of online documents */

with
    sources
         as
    (select
        online_doc_code, l.lang_code as translation_lang_code, released_at, ver_no
        from
             testdata.online_doc_vers o,
             testdata.locals l,
             testdata.model_params mp
        where
              l.lang_code <> mp.source_lang_code)
insert
    into
        testdata.online_doc_vers (online_doc_code, lang_code, released_at, ver_no)
        select
            online_doc_code, translation_lang_code, released_at, ver_no
            from
                sources;


/* Producing topic versions */

with
    online_docs__topics
        as
    (select o.code as online_doc_code, t.code as topic_code, o.lang_code, o.product_code
        from
            testdata.online_docs o,
            testdata.topics t,
            testdata.genres__aspects ga
        where
            t.product_code = o.product_code
                and
            t.aspect_code = ga.aspect_code
                and
            o.genre_code = ga.genre_code
                and
            t.lang_code = o.lang_code),
    online_doc_vers__topics
            as
    (select odv.online_doc_code, odt.topic_code, odv.lang_code, odv.released_at, odv.ver_no, random() as dice
        from
            online_docs__topics odt,
            online_doc_vers odv
        where
            odt.online_doc_code = odv.online_doc_code
                and
            odt.lang_code = odv.lang_code),
    topic_vers_protos
        as
    (select *
        from
            online_doc_vers__topics odt,
            testdata.model_params mp
        where
            odt.ver_no = 1 or dice < mp.new_topic_ver_probability)
insert
    into
        testdata.topic_vers (topic_code, lang_code, released_at)
    select
        topic_code, lang_code, released_at
    from
        topic_vers_protos;


/* Assinginin numbers to topic versions */

with
    topic_ver_no_protos
        as
    (select
        tv1.uuid as leading_uuid,
        tv1.topic_code, tv1.lang_code, tv1.released_at,
        tv2.topic_code, tv2.lang_code, tv2.released_at
        from
            testdata.topic_vers tv1,
            testdata.topic_vers tv2
        where
            tv1.topic_code = tv2.topic_code
                and
            tv1.lang_code = tv2.lang_code
                and
            tv1.released_at >= tv2.released_at),
    topic_ver_nos
        as
    (select
        leading_uuid, count(leading_uuid) as calculated_ver_no
        from
            topic_ver_no_protos
        group by
            leading_uuid)
update
    testdata.topic_vers
    set
        ver_no = topic_ver_nos.calculated_ver_no
    from
        topic_ver_nos
    where
        uuid = topic_ver_nos.leading_uuid;


/* Producing readers */

drop function if exists testdata.random_lang_code;

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
            testdata.countries__langs cl
        where
            cl.country_code = target_country_code;

    return random_code(lang_codes, lang_shares);
end
$$;


drop function if exists testdata.random_browser_code;

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
             testdata.oss__browsers ob
        where
              ob.os_code = target_os_code;

    return random_code(browser_codes, browser_shares);
end
$$;


drop function if exists testdata.produce_readers;

create function produce_readers(n_readers int) returns boolean
language plpgsql
as
$$
declare
    country_code varchar;
    lang_code varchar;
    os_code varchar;
    browser_code varchar;
begin
    for i in 1..n_readers
    loop
        select
            testdata.random_code(array_agg(code), array_agg(pop_size))
            into
                country_code
            from
                testdata.countries;

        select
            random_lang_code(country_code)
            into
                lang_code;

        select
            testdata.random_code(array_agg(code), array_agg(os_share))
            into
                os_code
            from
                testdata.oss;

        select
            random_browser_code(os_code)
            into
                browser_code;

        insert
            into testdata.readers (
                country_code, lang_code,
                os_code, browser_code,
                intension, intelligence, irritability)
            values (
                country_code, lang_code,
                os_code, browser_code,
                random_normal(0, 1), random_normal(0, 1), random_normal(0, 1));
    end loop;

    return true;
end
$$;

select produce_readers(n_readers) from model_params;


drop function if exists testdata.random_product_code;

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
    readers__products (reader_uuid, product_code)
    select
        u.uuid, random_product_code() from readers u;

select product_code, count(reader_uuid) from readers__products group by product_code;


/* Simulation */

drop function if exists testdata.random_question;

create function testdata.random_question() returns varchar
language plpgsql
as
$$
declare
    dice real;
    question varchar;
begin
    dice = random();
    if dice < 0.2 then
        question = 'Why this feature is not working?';
    elseif dice < 0.4 then
        question = 'Is it legal to use this function in USA?';
    elseif dice < 0.6 then
        question = 'My product version is 4.21, is it obsolete today?';
    elseif dice < 0.8 then
        question = 'How to prevent my kids from accessing this feature?';
    else
        question = 'Could you please provide more helpful info on this feature?';
    end if;

    return question;
end;
$$;


drop function if exists testdata.commit_reader_activity;

create function testdata.commit_reader_activity(
    reader testdata.readers,
    online_doc testdata.online_docs, online_doc_ver_no int,
    topic testdata.topics, topic_ver_no int,
    accepted_at timestamp, activity_type_code varchar, message_type_code varchar, message_text varchar) returns void
language plpgsql
as
$$
begin
    insert into testdata.reader_activities (
        online_doc_code, online_doc_lang_code, online_doc_ver_no,
        topic_code, topic_ver_no,
        reader_country_code, reader_lang_code, reader_os_code, reader_browser_code,
        accepted_at, activity_type_code, message_type_code, message_text)
    values (
        online_doc.code, online_doc.lang_code, online_doc_ver_no,
        topic.code, topic_ver_no,
        reader.country_code, reader.lang_code, reader.os_code, reader.browser_code,
        accepted_at, activity_type_code, message_type_code, message_text);
end;
$$;


drop function if exists testdata.simulate_reader_topic_session;

create or replace function testdata.simulate_reader_topic_session(
    reader testdata.readers,
    online_doc testdata.online_docs, online_doc_ver_no int, topic testdata.topics,
    session_start timestamp,
    mp testdata.model_params) returns timestamp
language plpgsql
as
$$
declare
    session_final timestamp;
    topic_ver_no int;
    question varchar;

begin
    session_final = session_start;

    select ver_no into topic_ver_no
        from testdata.topic_vers v
        where
            v.topic_code = topic.code
                and
            v.lang_code = topic.lang_code
                and
            v.released_at < session_final
        order by v.released_at desc limit 1;

    /* Confirming a visit */
    perform testdata.commit_reader_activity(
        reader, online_doc, online_doc_ver_no, topic, topic_ver_no,
        session_final, 'LOAD', null, null);

    /* Bounce? */
    if random() < mp.bounce_probability then
        session_final = session_final + '10 sec'::interval;
        perform testdata.commit_reader_activity(
            reader, online_doc, online_doc_ver_no, topic, topic_ver_no,
            session_final, 'BOUNCE', null, null);
    else
        /* Dislake? */
        if random() < mp.dislike_probability then
            session_final = session_final + '30 sec'::interval;
            perform testdata.commit_reader_activity(
                reader, online_doc, online_doc_ver_no, topic, topic_ver_no,
                session_final, 'DISLIKE', null, null);
        end if;

        /* Ask question? */
        if random() < mp.message_probability then
            session_final = session_final + '1 min'::interval;
            question = random_question();
            perform testdata.commit_reader_activity(
                reader, online_doc, online_doc_ver_no, topic, topic_ver_no,
                session_final, 'MESSAGE', 'QIESTION', question);
        end if;

        session_final = session_final + '2 min'::interval;

        perform testdata.commit_reader_activity(
            reader, online_doc, online_doc_ver_no, topic, topic_ver_no,
            session_final, 'LEAVE', null, null);

    end if;

    return session_final;
end;
$$;


drop function if exists testdata.simulate_reader_online_doc_session;

create or replace function testdata.simulate_reader_online_doc_session(
    reader testdata.readers, online_doc testdata.online_docs,
    session_start timestamp,
    mp testdata.model_params) returns void
language plpgsql
as
$$
declare
    topic_uuids uuid array;
    topic_idx int;
    topic testdata.topics;
    topic_session_start timestamp;
    online_doc_ver_no int;

begin
    select ver_no into online_doc_ver_no
        from testdata.online_doc_vers v
        where
            v.online_doc_code = online_doc.code
                and
            v.lang_code = online_doc.lang_code
                and
            v.released_at < session_start
        order by v.released_at desc limit 1;

    if online_doc_ver_no is not null then

        select array_agg(t.uuid)
            into topic_uuids
            from
                online_docs o,
                genres__aspects ga,
                testdata.topics t
            where
                o.uuid = online_doc.uuid
                    and
                o.product_code = t.product_code
                    and
                o.genre_code = ga.genre_code
                    and
                t.aspect_code = ga.aspect_code
                    and
                o.lang_code = t.lang_code;

        topic_session_start = session_start;

        for topic_idx in 1..coalesce(cardinality(topic_uuids), 0)
        loop
            if random() < mp.topic_view_probability then
                select * into topic from testdata.topics where uuid = topic_uuids[topic_idx];
                topic_session_start = testdata.simulate_reader_topic_session(
                    reader, online_doc, online_doc_ver_no, topic, topic_session_start, mp);
            end if;
        end loop;

    end if;
end;
$$;


drop function if exists testdata.detect_reader_preferred_lang_code;

create function testdata.detect_reader_preferred_lang_code(reader_uuid uuid) returns varchar
language plpgsql
as
$$
declare
    lc varchar;
begin
    select
        r.lang_code into lc
    from
        testdata.readers r, testdata.locals l
    where
        r.uuid = reader_uuid
            and
        r.lang_code = l.lang_code;


    if lc is null then
        select
            source_lang_code into lc
        from
            testdata.model_params
        where
            is_active;
    end if;

    return lc;
end;
$$;


drop function if exists testdata.simulate_reader_behavior;

create or replace function testdata.simulate_reader_behavior(
    reader testdata.readers, mp testdata.model_params) returns void
language plpgsql
as
$$
declare
    n_sessions int;
    session_idx int;
    reader_preferred_lang_code varchar;
    online_doc_uuids varchar array;
    n_online_docs int;
    session_start timestamp;
    online_doc_uuid uuid;
    online_doc testdata.online_docs;

begin
    n_sessions = testdata.random_int(1, mp.max_sessions_per_reader);

    reader_preferred_lang_code = testdata.detect_reader_preferred_lang_code(reader.uuid);

    for session_idx in 1..n_sessions
    loop
        select array_agg(o.uuid)
            into online_doc_uuids
            from
                testdata.readers__products rp,
                testdata.online_docs o
            where
                rp.reader_uuid = reader.uuid
                    and
                o.product_code = rp.product_code
                    and
                o.lang_code = reader_preferred_lang_code;

        session_start = testdata.random_timestamp(mp.simulation_start, mp.simulation_final);

        n_online_docs = coalesce(cardinality(online_doc_uuids), 0);
        if n_online_docs > 0 then
            online_doc_uuid = online_doc_uuids[testdata.random_int(1, n_online_docs)];
            select * into online_doc from testdata.online_docs where uuid = online_doc_uuid;
            perform testdata.simulate_reader_online_doc_session(reader, online_doc, session_start, mp);
        end if;

    end loop;
end
$$;


drop function if exists testdata.simulate_readers;

create or replace function testdata.simulate_readers() returns void
language plpgsql
as
$$
declare
    mp testdata.model_params%rowtype;
    reader_uuids uuid array;
    reader_idx int;
    reader testdata.readers%rowtype;

begin
    select *
        into mp
        from testdata.model_params
        where is_active;

    select array_agg(uuid)
        into reader_uuids
        from testdata.readers;

    for reader_idx in 1..coalesce(cardinality(reader_uuids), 0)
    loop
        select * into reader from testdata.readers where readers.uuid = reader_uuids[reader_idx];
        perform testdata.simulate_reader_behavior(reader, mp);
    end loop;
end;
$$;

truncate reader_activities;
select testdata.simulate_readers();