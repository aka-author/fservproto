
drop table if exists auth.users;

create table auth.users (
    uuid            uuid default gen_random_uuid() not null primary key,
    login           varchar,
    password_hash   varchar,
    role            varchar,
    created_at      timestamp,
    changed_at      timestamp,
    blocked_at      timestamp,
    deleted_at      timestamp
);

drop table if exists auth.sessions;
drop index if exists sessions__expire_at__idx;
drop index if exists sessions__closed_at__idx;

create table auth.sessions (
    uuid            uuid not null primary key,
    login           varchar,
    host            varchar,
    opened_at       timestamp,
    expire_at       timestamp,
    closed_at       timestamp
);

create index sessions__expire_at__idx on auth.sessions(expire_at);
create index sessions__closed_at__idx on auth.sessions(closed_at);

