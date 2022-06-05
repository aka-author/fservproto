drop table if exists auth.sessions;
drop index if exists sessions__token__idx;

create table auth.sessions (
    uuid            uuid default gen_random_uuid() not null primary key,
    token           varchar,
    login           varchar,
    host            varchar,
    started_at      timestamp,
    expires_at      timestamp,
    terminated_at   timestamp
);

create unique index sessions__token__idx on auth.sessions(token);
