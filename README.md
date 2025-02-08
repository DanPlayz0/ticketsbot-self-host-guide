# Self Hosting Tickets Bot

This is a guide to self host the [Tickets bot](https://discord.com/users/508391840525975553). Which was [announced to sunset on the 5th of March 2025](https://discord.com/channels/508392876359680000/508410703439462400/1325516916995129445) in [their support server](https://discord.gg/XX2TxVCq6g). This guide will help you set up the bot on your own machine using Docker. **This is not an official guide and I will not provide support.**

## Pre-requisites

- You must have knowledge of how to use, deploy and run containers (specifically Docker)
- You must have an idea of how to use a terminal
- You should have a basic understanding of GoLang, Rust, and Svelte
- You should have a basic understanding of how to use a database (specifically PostgreSQL)

## How does the bot work?

To be completely honest, I still don't know. The image below is a rough diagram of how I think the bot works after nearly a week of tinkering with the TicketsBot codebase. The dotted boxes are the containers that I did not implement into the `docker-compose.yaml` in this repository.

![Excalidraw](./images/ticketsbot-2025-01-11T23_47_40_622Z.svg)
The image above was made using [Excalidraw](https://excalidraw.com/).

## Setup

1. Open a terminal in the folder you want to install the bot in. (Or create a folder and open a terminal in that folder)
2. Clone this repository into that folder (`git clone https://github.com/DanPlayz0/ticketsbot-self-host-guide.git .`)
   - The `.` at the end is important as it clones the repository into the current folder
3. Create an `.env` file by copying the provided `.env.example` file.

   - `DISCORD_BOT_TOKEN`: your bot token (e.g. `OTAyMzYyNTAxMDg4NDM2MjI0.YXdUkQ.TqZm7gNV2juZHXIvLdSvaAHKQCzLxgu9`)
   - `DISCORD_BOT_CLIENT_ID`: your bot's client ID (e.g. `508391840525975553`)
   - `DISCORD_BOT_OAUTH_SECRET`: your bot's client secret (e.g. `AAlRmln88YpOr8H8j1VvFuidKLJxg9rM`)
   - `DISCORD_BOT_PUBLIC_KEY`: your bot's public key (e.g. `fcd10216ebbc818d7ef1408a5c3c5702225b929b53b0a265b82e82b96a9a8358`)
   - `ADMIN_USER_IDS`: a comma-separated list of user IDs (e.g. `209796601357533184,585576154958921739,user_id,user_id`, a single id would be `209796601357533184`)
   - `DISCORD_SUPPORT_SERVER_INVITE`: the invite link to your support server (e.g. `https://discord.gg/ticketsbot`)
   - `DASHBOARD_URL`: the URL of your dashboard (e.g. `http://localhost:5000`)
   - `LANDING_PAGE_URL`: the URL of your landing page (e.g. `https://ticketsbot.cloud`)
   - `API_URL`: the URL of your API (e.g. `http://localhost:8082`)
   - `DATABASE_HOST`: your PostgreSQL host (e.g. `postgres:5432`)
   - `DATABASE_PASSWORD`: your PostgreSQL password (e.g. `password`)
   - `CACHE_DATABASE_HOST`: your cache database host (e.g. `postgres-cache:5432`)
   - `CACHE_DATABASE_PASSWORD`: your cache database password (e.g. `password`)
   - `S3_ENDPOINT`: the endpoint of your S3 bucket (e.g. `minio:9000`)
   - `S3_ACCESS`: the access key of your S3 bucket (e.g. `AbCdEfFgHiJkLmNoPqRsTuVwXyZ`)
   - `S3_SECRET`: the secret key of your S3 bucket (e.g. `AbCdEfFgHiJkLmNoPqRsTuVwXyZ`)
   - `ARCHIVER_AES_KEY`: your AES-128 key (e.g. `randomstring`)
     - Bash: `openssl rand -hex 16`
     - NodeJS: `node -e "console.log(require('crypto').randomBytes(16).toString('hex'))"`
   - `ARCHIVER_ADMIN_AUTH_TOKEN`: your archiver admin auth token (e.g. `randomstring`)
   - `SENTRY_DSN`: your Sentry DSN (e.g. `https://examplePublicKey@o0.ingest.sentry.io/0`)

4. Replace the placeholders in the following command and paste it at the bottom of `init-archive.sql`. There are 2 placeholders in the command, `${BUCKET_NAME}` and `${S3_ENDPOINT}`. Replace them with your bucket name and S3 endpoint respectively. You can also just edit the `init-archive.sql` file too, you just have to uncomment it (by removing the `--` at the start of the line) and replace variables there.

   ```sql
   INSERT INTO buckets (id, endpoint_url, name, active) VALUES ('b77cc1a0-91ec-4d64-bb6d-21717737ea3c', 'https://${S3_ENDPOINT}', '${BUCKET_NAME}', TRUE);
   ```

5. Run `docker compose up -d` to pull the images and start the bot.
6. Configure the Discord bot. ([see below](#discord-bot-configuration))
7. Register the slash commands ([see below](#registering-the-slash-commands-using-docker-recommended))

## Discord Bot Configuration

As this bot is self-hosted, you will need to configure the bot yourself. Here are the steps to configure the bot:

1. Go to the [Discord Developer Portal](https://discord.com/developers/applications)
2. Click on the application you created for the bot
3. Set the `Interactions Endpoint URL` to `${HTTP_GATEWAY}/handle/${DISCORD_BOT_CLIENT_ID}`
   - Replace `${HTTP_GATEWAY}` with the URL of your HTTP Gateway (e.g. `http://localhost:8080`, you must have a [publicly accessible URL](#6-i-want-anyone-to-be-able-to-use-the-dashboard-how-do-i-do-that) not localhost)
   - Replace `${DISCORD_BOT_CLIENT_ID}` with your bot's application/client ID (e.g. `508391840525975553`)
4. Go to the OAuth2 tab
5. Add the redirect URL `${DASHBOARD_URL}/callback` to the OAuth2 redirect URIs
   - Replace `${DASHBOARD_URL}` with the URL of your API (e.g. `http://localhost:8080`, make sure this matches what you set in the [Setup](#setup) section)

## Registering the slash commands using Docker (Recommended)

1. Build the register commands cli utility using `docker build -t ticketsbot/registercommands -f commands.Dockerfile .`
   - Get help by running `docker run --rm ticketsbot/registercommands --help`
2. Register the commands
   - Global commands only: `docker run --rm ticketsbot/registercommands --token=your_bot_token --id=your_client_id`
   - Global & Admin commands by running `docker run --rm ticketsbot/registercommands --token=your_bot_token --id=your_client_id --admin-guild=your_admin_guild_id`

## Registering the slash commands using GoLang

1. Clone the [worker repository](https://github.com/TicketsBot/worker) (`git clone https://github.com/TicketsBot/worker.git`)
2. Change directory to the `worker` folder (`cd worker`)
3. Run `go run cmd/registercommands/main.go --token=your_bot_token --id=your_client_id`

   - If you want to register the admin commands, add `--admin-guild=your_admin_guild_id` to the command

4. If you get errors related to zlib (`undefined: Zstream`, `undefined: NewZstream`, `undefined: zNoFlush`, `undefined: zSyncFlush`, etc)
   - You are missing the zlib package and [GDL](https://github.com/rxdn/gdl/) uses it.
   - You can install it by running one of the following (depending on your package manager)
     - Ubuntu: `apt-get install zlib1g-dev`
     - CentOS: `yum install zlib-devel`

## Frequently Asked Questions

### 1. What can I host this on?

You should be able to host this on any* machine that can run Docker containers.

> \* The docker images don't support ARM architecture out of the box, so not exactly "any" machine.

### 2. What are the system requirements?

I cannot recommend any specific requirements, but I can give you some information on the resources used by the bot (CPU metrics are out of 1200% as i was using a 6 core CPU with 12 logical processors):

- Starting up the bot the peak was around 475.44MB of RAM and 43.21% CPU. (This was on a fresh start, it may vary)
- After using the bot for a while, the bot was using around 1.5GB of RAM and 18% of a CPU.

### 3. Can I turn off the logging?

Kinda of, in certain containers there are environment variables, like the ones below which you can remove:

```yaml
RUST_BACKTRACE: 1
RUST_LOG: trace
```

### 4. How do I update the bot?

There are environment variables used in the `docker-compose.yaml` file that allows you to change which image the bot runs on. The current `docker-compose.yaml` file already using the latest available images of the bot's containers.

You might be able to find a newer image for the respective repositories/packages on the [TicketsBot Packages](https://github.com/orgs/TicketsBot/packages) page but it's highly unlikely.

If you instead look in the [TicketsBot v2 Packages](https://github.com/orgs/TicketsBot-cloud/packages) page and you'll probably find some newer images, this guide already uses one of them (aka `ghcr.io/ticketsbot-cloud/worker:v2.8.0`) as it supports the "branding" environment variables without asking you to recompile the bot yourself.

If neither of those have newer images, you will have to fork the respective repositories, compile and update the `docker-compose.yaml` or `.env` to those compiled images.

### 5. How do I get rid of the `ticketsbot.net` branding?

This shouldn't be a problem now as this guide has been updated to use a newer image that already allows you to change the branding.

Prior to [V2 PR#4](https://github.com/TicketsBot-cloud/worker/pull/4) and [Guide PR#8](https://github.com/DanPlayz0/ticketsbot-self-host-guide/pull/8), the only way to remove the original branding, required that you have knowledge of how to compile GoLang, Rust, and Svelte. Allowing you to change the branding in the bot's [source code](https://github.com/TicketsBot) and recompile the bot and update those image hashes in `docker-compose.yaml` or `.env` file and then re-run the bot.

### 6. I want anyone to be able to use the dashboard, how do I do that?

You have to setup a reverse proxy (examples being; [NginX](https://nginx.org/), [Caddy](https://caddyserver.com/), [Traefik](https://traefik.io/traefik/)) with the following routes:

> :warning: I assume you are using the default ports from the compose file, if you are not, you will have to change the ports in the examples below.

- `api.example.com` -> `http://localhost:8082` (api container)
- `dashboard.example.com` -> `http://localhost:5000` (dashboard container)
- `gateway.example.com` -> `http://localhost:8080` (http-gateway container)

### 7. This requires S3, can I host this without S3? (NOT recommended)

Yes you can but know this bot requires an S3 bucket to store transcripts. You can use [MinIO](https://min.io/) to create a local S3 bucket.

If you really don't want to use S3, you will have to edit the `docker-compose.yaml` file.

> :warning: This will cause the bot to break! As the bot requires the S3 bucket to store transcripts.

Here are the steps to remove S3 and transcripts.

1. Remove the `logarchiver` and `postgres-archive` services from the `docker-compose.yaml` file.
2. In the `worker-interactions` service, remove the two environment variables that reference the archiver (aka `WORKER_ARCHIVER_URL` and `WORKER_ARCHIVER_AES_KEY`).
3. In the `api` service, remove the two environment variables that reference the archiver (aka `LOG_ARCHIVER_URL` and `LOG_AES_KEY`).

Once you've done that, you will also have to open the dashboard and disable "Store Ticket Transcripts" in the settings of every server the bot is setup in, otherwise you won't be able to close tickets.

### 8. How do I activate premium features?

The following steps will allow you to activate premium features on your self-hosted bot. In these steps, I will be using the UUID `a924e567-bc50-4bf9-bd8f-9fb6bf91f374` as an example.

If you'd prefer to use a different UUID, you can generate one using [this website](https://www.uuidgenerator.net/version4). Just make sure to replace the UUID in each of the following steps.

To activate premium features, you will need to run the following SQL command in the `postgres` database:

```sql
INSERT INTO skus (id, label, type) VALUES ('a924e567-bc50-4bf9-bd8f-9fb6bf91f374', 'Premium Monthly', 'subscription', true);
INSERT INTO subscription_skus (sku_id, tier, priority) VALUES ('a924e567-bc50-4bf9-bd8f-9fb6bf91f374', 'premium', 0);
```

Once you've run those SQL commands, you will need to generate a "giveaway key" using the following command (this requires you to [publish the admin commands](#registering-the-slash-commands-using-docker-recommended)):

```text
/admin genpremium sku:a924e567-bc50-4bf9-bd8f-9fb6bf91f374 length:99999
```

You will then receive a message in the bot's DMs with a "giveaway key". Copy that key and go to the server you want to activate premium on and run the following command:

```text
/premium
```

It will ask you to `Select which method you used to obtain premium` and then you need to select `Giveaway Key` and then paste the key you received in the bot's DMs into the modal that opens.

Click `Submit` and you should have premium activated on that server for *__length__* (provided above, as 99999) days

## Common Issues

### 1. There's an error. (`no active bucket`)

This error is caused by you skipping step #4 in the [Setup](#setup) section. You need to add the bucket to the database before starting the bot.

To fix this error you will either need to either:

1. Delete the `pgarchivedata` folder and restart with an updated `init-archive.sql` file.
2. Run the following SQL command in the `pgarchivedata` database (and replace the placeholders with your bucket name and S3 endpoint):

   ```sql
   INSERT INTO buckets (id, endpoint_url, name, active) VALUES ('b77cc1a0-91ec-4d64-bb6d-21717737ea3c', 'https://${S3_ENDPOINT}', '${BUCKET_NAME}', TRUE);
   ```

### 2. I got an error while setting the interactions url. (`The specified interactions endpoint url could not be verified.`)

The most common error is that the URL you inputted is not publicly accessible (aka you tried `localhost` or [a private IP Address](https://en.wikipedia.org/wiki/Private_network)). 
**You need to have a publicly accessible URL for the interactions endpoint.** Refer to [FAQ #6](#6-i-want-anyone-to-be-able-to-use-the-dashboard-how-do-i-do-that) for more information on a reverse proxy setup.

### 3. Invalid OAuth2 redirect_uri

> :warning: If you set up a reverse proxy, you should use the dashboard domain you set instead of `localhost`.

This error is caused by you not setting the OAuth2 redirect URI in the [Discord Bot Configuration](#discord-bot-configuration) section. You need to set the redirect URI to `${DASHBOARD_URL}/callback`. Replace `${DASHBOARD_URL}` with the URL of your dashboard (e.g. `http://localhost:5000`).

### 4. ERROR: column "last_seen" of relation does not exist

This error was caused by the `init-cache.sql` file being incorrect which was fixed in [Guide PR#9](https://github.com/DanPlayz0/ticketsbot-self-host-guide/pull/9).

If you had setup the bot before this PR was merged, you will need to run the following SQL command in the `postgres-cache` database:

```sql
ALTER TABLE users ADD COLUMN last_seen TIMESTAMPTZ;
ALTER TABLE members ADD COLUMN last_seen TIMESTAMPTZ;
```

As this is just a cache database, you may also choose to stop the bot, delete the `pgcachedata` folder and re-run the bot with the updated `init-cache.sql` file.
