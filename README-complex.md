# Setup (Complex)

1. Create a folder somewhere (it will be where the bot will be installed), and open a terminal in that folder.
2. Download the `schema.sql` (postgres dump file) from [#self-hosting](https://discord.com/channels/508392876359680000/1325513300892581898) channel in the [Tickets Support Discord server](https://discord.gg/NHz6G3qv55).

   - Rename `schema.sql` to `init.sql`.
   - Add the following lines to the top of `init.sql` dump file:

     ```sql
     -- Create the roles
     CREATE ROLE backup;
     CREATE ROLE clickhouse;
     CREATE ROLE peerdb;
     CREATE ROLE tickets;
     CREATE ROLE votelistener;
     ```

   - Move it to the root of the folder you created.

3. Download [`0001-init-schema.sql`](https://github.com/TicketsBot/logarchiver/blob/master/migrations/0001-init-schema.sql) and rename it to `init-archive.sql`.
4. Create a `init-cache.sql` and copy the SQL lines

   - For those being lazy, here's the SQL lines:

     ```sql
     -- Downloaded from https://github.com/rxdn/gdl/blob/master/cache/pgcache.go#L122-L138 (only include the SQL lines, not the GoLang code (aka batch.Queue))
     CREATE TABLE IF NOT EXISTS guilds("guild_id" int8 NOT NULL UNIQUE, "data" jsonb NOT NULL, PRIMARY KEY("guild_id"));
     CREATE TABLE IF NOT EXISTS channels("channel_id" int8 NOT NULL UNIQUE, "guild_id" int8 NOT NULL, "data" jsonb NOT NULL, PRIMARY KEY("channel_id", "guild_id"));
     CREATE TABLE IF NOT EXISTS users("user_id" int8 NOT NULL UNIQUE, "data" jsonb NOT NULL, PRIMARY KEY("user_id"));
     CREATE TABLE IF NOT EXISTS members("guild_id" int8 NOT NULL, "user_id" int8 NOT NULL, "data" jsonb NOT NULL, PRIMARY KEY("guild_id", "user_id"));
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
     ```

5. Create the `dashboard.Dockerfile` and copy the following code block (this compiles the Svelte frontend with your bot's client ID, API URL and Websocket URL)

   ```dockerfile
   FROM node:lts-alpine AS build

   # Install packages
   USER root
   RUN apk add --no-cache git

   # Create the directory!
   RUN mkdir -p /tmp && chown -R node:node /tmp
   WORKDIR /tmp
   USER node

   # Clone the repository to /tmp
   RUN git clone https://github.com/TicketsBot/dashboard.git /tmp

   # Switch directories to the frontend
   WORKDIR /tmp/frontend

   # Install node_modules (including development/build)
   RUN npm install

   # Build the frontend (and include the env variables required during buildtime)
   ARG CLIENT_ID
   ARG REDIRECT_URI
   ARG API_URL
   ARG WS_URL

   RUN npm run build

   # Remove development node_modules
   RUN npm prune --production

   # Production container
   FROM node:lts-alpine AS prod

   RUN mkdir -p /app && chown -R node:node /app
   WORKDIR /app
   USER node

   COPY --from=build --chown=node:node /tmp/frontend/package*.json /app/
   COPY --from=build --chown=node:node /tmp/frontend/node_modules /app/node_modules
   COPY --from=build --chown=node:node /tmp/frontend/public /app/public

   ENV NODE_ENV=production
   CMD ["npm", "run", "start"]
   ```

6. Download the `docker-compose.yaml`
