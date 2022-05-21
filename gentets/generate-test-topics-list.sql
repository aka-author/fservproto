create function random_normal(min real, max real) returns real
    language plpgsql
as
$$
begin
    return min + (max - min)*(random() + random() + random() + random() + random() + random())/6.0;
end
$$;

create function random_normal_int(min int, max int) returns int
    language plpgsql
as
$$
begin
    return round(random_normal(min, max));
end
$$;

create function random_quasi_normal(min real, max real) returns real
    language plpgsql
as
$$
begin
    return min + (max - min)*(random() + random())/2.0;
end
$$;

create function random_quasi_normal_int(min int, max int) returns int
    language plpgsql
as
$$
begin
    return round(random_quasi_normal(min, max));
end
$$;

create table genres (
    code    varchar,
    title   varchar
);

create table product_groups (
    code    varchar,
    title   varchar
);

create table subjects (
    code     varchar,
    title    varchar,
    pg_code  varchar  
);

create table predicates (
    code    varchar,
    title   varchar
);

create table aspects (
    code    varchar,
    title   varchar,
    scope   varchar
)

create table online_docs (
    uuid            uuid default gen_random_uuid() not null primary key,
    online_doc_id   varchar,    
    title           varchar
)

create table topics (
    uuid        uuid default gen_random_uuid() not null primary key,
    topic_id    varchar,    
    title       varchar,
    quality     int,
    demand      int
)

insert into genres (code, title) values ('ug', 'Quick Oparation Guide');
insert into genres (code, title) values ('mg', 'Maintenance Guide');

insert into product_groups (code, title) values ('animals', 'Animals');
insert into product_groups (code, title) values ('persons', 'Persons');
insert into product_groups (code, title) values ('things', 'Things');

insert into aspects (code, title, scope) values ('understanding', 'Understanding', 'product_group')
insert into aspects (code, title, scope) values ('intro', 'Basics of', 'product_subgroup')
insert into aspects (code, title, scope) values ('basics', 'Meet', 'product');
insert into aspects (code, title, scope) values ('planning', 'Planning Your', 'product');
insert into aspects (code, title, scope) values ('fun', 'Having Fun with', 'product');
insert into aspects (code, title, scope) values ('safety', 'Feeling Safe Near', 'product');
insert into aspects (code, title, scope) values ('creating', 'Creating', 'product');
insert into aspects (code, title, scope) values ('viewing', 'Viewing', 'product');
insert into aspects (code, title, scope) values ('editing', 'Editing', 'product');
insert into aspects (code, title, scope) values ('deleting', 'Deleting', 'product');
insert into aspects (code, title, scope) values ('configuring', 'Configuring', 'product');
insert into aspects (code, title, scope) values ('verifying', 'Verifying', 'product');
insert into aspects (code, title, scope) values ('updating', 'Updating', 'product');
insert into aspects (code, title, scope) values ('troubleshooting', 'Troubleshooting', 'product');
insert into aspects (code, title, scope) values ('protecting', 'Protecting', 'product');
insert into aspects (code, title, scope) values ('sharing', 'Sharing', 'product');
insert into aspects (code, title, scope) values ('repairing', 'Repairing', 'product');
insert into aspects (code, title, scope) values ('maintaining', 'Maintaining', 'product');
insert into aspects (code, title, scope) values ('supressing', 'Supressing', 'product');
insert into aspects (code, title, scope) values ('resuming', 'Resuming', 'product');
insert into aspects (code, title, scope) values ('resetting', 'Resetting', 'product');

insert into predicates (code, title) values ('biotech', 'Biotech');
insert into predicates (code, title) values ('robotic', 'Robotic');
insert into predicates (code, title) values ('shared', 'Shared');
insert into predicates (code, title) values ('virtual', 'Virtual');

insert into subjects (code, title, pg_code) values ('rabbits', 'Rabbits', 'animals');
insert into subjects (code, title, pg_code) values ('wombats', 'Wombats', 'animals');
insert into subjects (code, title, pg_code) values ('cows', 'Cows', 'animals');
insert into subjects (code, title, pg_code) values ('cats', 'Cats', 'animals');
insert into subjects (code, title, pg_code) values ('dogs', 'Dogs', 'animals');
insert into subjects (code, title, pg_code) values ('horses', 'Horses', 'animals');
insert into subjects (code, title, pg_code) values ('elephants', 'Elephants', 'animals');
insert into subjects (code, title, pg_code) values ('Rhinoceroses', 'Rhinoceros', 'animals');
insert into subjects (code, title, pg_code) values ('hamsters', 'Hamsters', 'animals');
insert into subjects (code, title, pg_code) values ('platypuses', 'Platypuses', 'animals');

insert into subjects (code, title, pg_code) values ('teapots', 'Teapots', 'things');
insert into subjects (code, title, pg_code) values ('vcleaners', 'Vacuum Cleaners', 'things');
insert into subjects (code, title, pg_code) values ('fridges', 'Refrigerators', 'things');
insert into subjects (code, title, pg_code) values ('routers', 'Routers', 'things');
insert into subjects (code, title, pg_code) values ('phones', 'Cell Phones', 'things');
insert into subjects (code, title, pg_code) values ('wmachines', 'Washing Machines', 'things');
insert into subjects (code, title, pg_code) values ('aconds', 'Air Conditioners', 'things');
insert into subjects (code, title, pg_code) values ('toasters', 'Toasters', 'things');
insert into subjects (code, title, pg_code) values ('hookahs', 'Hookahs', 'things');
insert into subjects (code, title, pg_code) values ('mgrinders', 'Meat Grinders', 'things');

insert into subjects (code, title, pg_code) values ('relatives', 'Relatives', 'persons');
insert into subjects (code, title, pg_code) values ('friends', 'Friends', 'persons');
insert into subjects (code, title, pg_code) values ('classmates', 'Classmates', 'persons');
insert into subjects (code, title, pg_code) values ('neighbours', 'Neighbours', 'persons');
insert into subjects (code, title, pg_code) values ('сolleagues', 'Сolleagues', 'persons');
insert into subjects (code, title, pg_code) values ('adherents', 'Adherents', 'persons');
insert into subjects (code, title, pg_code) values ('psychos', 'Psychotherapists', 'persons');
insert into subjects (code, title, pg_code) values ('enemies', 'Enemies', 'persons');
insert into subjects (code, title, pg_code) values ('partners', 'Partners', 'persons');
insert into subjects (code, title, pg_code) values ('strangers', 'Strangers', 'persons');

with
    online_doc_protos
        as
    (select
        concat(p.code, '_', s.code, '_', g.code) as online_doc_id,
        concat(p.title, ' ', s.title, '. ', g.title) as title
        from
            testdata.predicates p, testdata.subjects s, testdata.genres g)
    insert into
        online_docs (online_doc_id, title)
    select
        od.online_doc_id,
        od.title
    from
        online_doc_protos od;            

with
    product_demands (predicate_code, subject_code, product_demand)
        as
    (select p.code, s.code, random_quasi_normal_int(1, 10)
        from
            predicates p, subjects s),
    aspect_demands (aspect_code, aspect_demand)
        as
    (select code, random_quasi_normal_int(1, 10)
        from
            aspects),
    product_group_topics (topic_id, title, quality, demand)
        as
    (select
        concat(a.code, '_', pg.code),
        concat(a.title, ' ', pg.title),
        random_quasi_normal_int(1, 100),
        random_normal_int(1, 100)
        from
            aspects a,
            product_groups pg
        where
            a.scope = 'product_group'),
    product_subgroup_topics (topic_id, title, quality, demand)
        as
    (select
        concat(a.code, '_', s.code),
        concat(a.title, ' ', s.title),
        random_quasi_normal_int(1, 100),
        random_normal_int(1, 100)
        from
            testdata.aspects a,
            testdata.subjects s
        where
            a.scope = 'product_subgroup'),
    product_topics (topic_id, title, quality, demand)
        as
    (select
        concat(aspects.code, '_', predicates.code, '_', subjects.code),
        concat(aspects.title, ' ', predicates.title, ' ', subjects.title),
        random_quasi_normal_int(1, 100),
        aspect_demands.aspect_demand*product_demands.product_demand
        from
            testdata.aspects,
            testdata.predicates,
            testdata.subjects,
            aspect_demands,
            product_demands
        where
            aspects.scope = 'product'
                and
            aspects.code = aspect_demands.aspect_code
                and
            predicates.code = product_demands.predicate_code
                and
            subjects.code = product_demands.subject_code),
    topic_protos
        as
    (select * from product_group_topics
        union all
    select * from product_subgroup_topics
            union all
    select * from product_topics)
    insert into
        topics (topic_id, title, quality, demand)
        select
            tp.topic_id,
            tp.title,
            tp.quality,
            tp.demand
        from
            topic_protos tp;         


