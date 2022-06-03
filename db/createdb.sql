drop table if exists auth.sessions;

create table auth.sessions (
    uuid            uuid not null primary key,
    user_name       varchar,
    user_host       varchar,
    started_at      timestamp,
    expires_at      timestamp,
    terminated_at   timestamp
);

