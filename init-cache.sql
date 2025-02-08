-- Found from https://github.com/rxdn/gdl/blob/master/cache/pgcache.go#L122-L138
CREATE TABLE IF NOT EXISTS guilds("guild_id" int8 NOT NULL UNIQUE, "data" jsonb NOT NULL, PRIMARY KEY("guild_id"));
CREATE TABLE IF NOT EXISTS channels("channel_id" int8 NOT NULL UNIQUE, "guild_id" int8 NOT NULL, "data" jsonb NOT NULL, PRIMARY KEY("channel_id", "guild_id"));
CREATE TABLE IF NOT EXISTS users("user_id" int8 NOT NULL UNIQUE, "data" jsonb NOT NULL, "last_seen" timestamp with time zone, PRIMARY KEY("user_id"));
CREATE TABLE IF NOT EXISTS members("guild_id" int8 NOT NULL, "user_id" int8 NOT NULL, "data" jsonb NOT NULL, "last_seen" timestamp with time zone, PRIMARY KEY("guild_id", "user_id"));
CREATE TABLE IF NOT EXISTS roles("role_id" int8 NOT NULL UNIQUE, "guild_id" int8 NOT NULL, "data" jsonb NOT NULL, PRIMARY KEY("role_id", "guild_id"));
CREATE TABLE IF NOT EXISTS emojis("emoji_id" int8 NOT NULL UNIQUE, "guild_id" int8 NOT NULL, "data" jsonb NOT NULL, PRIMARY KEY("emoji_id", "guild_id"));
CREATE TABLE IF NOT EXISTS voice_states("guild_id" int8 NOT NULL, "user_id" INT8 NOT NULL, "data" jsonb NOT NULL, PRIMARY KEY("guild_id", "user_id"));

-- create index
CREATE INDEX CONCURRENTLY IF NOT EXISTS channels_guild_id ON channels("guild_id");
CREATE INDEX CONCURRENTLY IF NOT EXISTS members_guild_id ON members("guild_id");
CREATE INDEX CONCURRENTLY IF NOT EXISTS member_user_id ON members("user_id");
CREATE INDEX CONCURRENTLY IF NOT EXISTS roles_guild_id ON roles("guild_id");
CREATE INDEX CONCURRENTLY IF NOT EXISTS emojis_guild_id ON emojis("guild_id");
CREATE INDEX CONCURRENTLY IF NOT EXISTS voice_states_guild_id ON voice_states("guild_id");
CREATE INDEX CONCURRENTLY IF NOT EXISTS voice_states_user_id ON voice_states("user_id");
