# Frequently Asked Questions

## 1. What can I host this on?

You should be able to host this on any* machine that can run Docker containers.

> \* The docker images don't support ARM architecture out of the box, so not exactly "any" machine.

## 2. What are the system requirements?

I cannot recommend any specific requirements, but I can give you some information on the resources used by the bot (CPU metrics are out of 1200% as i was using a 6 core CPU with 12 logical processors):

- Starting up the bot the peak was around 475.44MB of RAM and 43.21% CPU. (This was on a fresh start, it may vary)
- After using the bot for a while, the bot was using around 1.5GB of RAM and 18% of a CPU.
- Your CPU must support AVX

Linux:

```bash
cat /proc/cpuinfo | grep avx
```

If not your output is blank you will need to run the bot on a different CPU that does support it.

## 3. Can I turn off the logging?

Kinda of, in certain containers there are environment variables, like the ones below which you can remove:

```yaml
RUST_BACKTRACE: 1
RUST_LOG: trace
```

## 4. How do I update the bot?

There are environment variables used in the `docker-compose.yaml` file that allows you to change which image the bot runs on. The current `docker-compose.yaml` file already using the latest available images of the bot's containers.

You might be able to find a newer image for the respective repositories/packages on the [TicketsBot Packages](https://github.com/orgs/TicketsBot/packages) page but it's highly unlikely.

If you instead look in the [TicketsBot v2 Packages](https://github.com/orgs/TicketsBot-cloud/packages) page and you'll probably find some newer images, this guide already uses one of them (aka `ghcr.io/ticketsbot-cloud/worker:v2.8.0`) as it supports the "branding" environment variables without asking you to recompile the bot yourself.

If neither of those have newer images, you will have to fork the respective repositories, compile and update the `docker-compose.yaml` or `.env` to those compiled images.

## 5. How do I get rid of the `ticketsbot.net` branding?

This shouldn't be a problem now as this guide has been updated to use a newer image that already allows you to change the branding.

Prior to [V2 PR#4](https://github.com/TicketsBot-cloud/worker/pull/4) and [Guide PR#8](https://github.com/DanPlayz0/ticketsbot-self-host-guide/pull/8), the only way to remove the original branding, required that you have knowledge of how to compile GoLang, Rust, and Svelte. Allowing you to change the branding in the bot's [source code](https://github.com/TicketsBot) and recompile the bot and update those image hashes in `docker-compose.yaml` or `.env` file and then re-run the bot.

## 6. I want anyone to be able to use the dashboard, how do I do that?

You have to setup a reverse proxy (examples being; [NginX](https://nginx.org/), [Caddy](https://caddyserver.com/), [Traefik](https://traefik.io/traefik/)) with the following routes:

> :warning: I assume you are using the default ports from the compose file, if you are not, you will have to change the ports in the examples below.

- `api.example.com` -> `http://localhost:8082` (api container)
- `dashboard.example.com` -> `http://localhost:5000` (dashboard container)
- `gateway.example.com` -> `http://localhost:8080` (http-gateway container)

## 7. This requires S3, can I host this without S3? (NOT recommended)

Yes you can but know this bot requires an S3 bucket to store transcripts. You can use [MinIO](https://min.io/) to create a local S3 bucket.

If you really don't want to use S3, you will have to edit the `docker-compose.yaml` file.

> :warning: This will cause the bot to break! As the bot requires the S3 bucket to store transcripts.

Here are the steps to remove S3 and transcripts.

1. Remove the `logarchiver` and `postgres-archive` services from the `docker-compose.yaml` file.
2. In the `worker-interactions` service, remove the two environment variables that reference the archiver (aka `WORKER_ARCHIVER_URL` and `WORKER_ARCHIVER_AES_KEY`).
3. In the `api` service, remove the two environment variables that reference the archiver (aka `LOG_ARCHIVER_URL` and `LOG_AES_KEY`).

Once you've done that, you will also have to open the dashboard and disable "Store Ticket Transcripts" in the settings of every server the bot is setup in, otherwise you won't be able to close tickets.

## 8. How do I activate premium features?

The following steps will allow you to activate premium features on your self-hosted bot. In these steps, I will be using the UUID `a924e567-bc50-4bf9-bd8f-9fb6bf91f374` as an example.

If you'd prefer to use a different UUID, you can generate one using [this website](https://www.uuidgenerator.net/version4). Just make sure to replace the UUID in each of the following steps.

To activate premium features, you will need to [run the following SQL command](#9-how-do-i-run-the-sql-commands-inside-the-database-containers) in the `postgres` database:

```sql
INSERT INTO skus (id, label, type) VALUES ('a924e567-bc50-4bf9-bd8f-9fb6bf91f374', 'Premium Monthly', 'subscription');
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

## 9. How do I run the sql commands inside the database containers?

There are a few ways to run SQL commands inside a database.

The first way is to use a GUI tool like [pgAdmin](https://www.pgadmin.org/) or [HeidiSQL](https://www.heidisql.com/). You can connect to the database using the credentials in the `.env` file and run the SQL commands. (Note: This requires you to uncomment the `ports` section in the `postgres` service in the `docker-compose.yaml` file)

The second way is to use the `psql` command line tool. You can run the following command to execute the SQL commands, replacing `SQL_COMMAND` with the SQL command you want to run.

If you prefer an interactive shell where you can paste multiple commands you can omit the `-c "SQL_COMMAND"` part.

For the `postgres` "main" database:

```bash
docker compose exec postgres psql -U postgres -d ticketsbot -c "SQL_COMMAND"
```

For the `pgarchivedata` "archive" database:

```bash
docker compose exec postgres-archive psql -U postgres -d archive -c "SQL_COMMAND"
```

For the `pgcachedata` "cache" database:

```bash
docker compose exec postgres-cache psql -U postgres -d botcache -c "SQL_COMMAND"
```

## 10. How do I import data from ticketsbot.net?

You first will need to have the exports from [export.ticketsbot.net](https://export.ticketsbot.net). Then you will need to open the self-hosted bot's dashboard and go to the import page and upload the exports.

You must upload the data export first, wait for it to import, then after data is imported, you can upload the transcript export.

The way the self hosted import works, you _*should** be able to import both data and transcripts at the same time, and it may work, but it is not recommended.
