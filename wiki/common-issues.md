# Common Issues

## 1. There's an error. (`no active bucket`)

This error is caused by you skipping step #4 in the [Setup](#setup) section. You need to add the bucket to the database before starting the bot.

To fix this error you will either need to either:

1. Delete the `pgarchivedata` folder and restart with an updated `init-archive.sql` file.
2. Run the following SQL command in the `pgarchivedata` database (and replace the placeholders with your bucket name and S3 endpoint):

   ```sql
   INSERT INTO buckets (id, endpoint_url, name, active) VALUES ('b77cc1a0-91ec-4d64-bb6d-21717737ea3c', 'https://${S3_ENDPOINT}', '${S3_ARCHIVE_BUCKET}', TRUE);
   ```

## 2. I got an error while setting the interactions url. (`The specified interactions endpoint url could not be verified.`)

The most common error is that the URL you inputted is not publicly accessible (aka you tried `localhost` or [a private IP Address](https://en.wikipedia.org/wiki/Private_network)). 
**You need to have a publicly accessible URL for the interactions endpoint.** Refer to [FAQ #6](#6-i-want-anyone-to-be-able-to-use-the-dashboard-how-do-i-do-that) for more information on a reverse proxy setup.

## 3. Invalid OAuth2 redirect_uri

> :warning: If you set up a [reverse proxy](#6-i-want-anyone-to-be-able-to-use-the-dashboard-how-do-i-do-that), you should use the dashboard domain (e.g. `https://dashboard.example.com`) you set instead of `http://localhost:5000`.

This error is caused by you not setting the OAuth2 redirect URI in the [Discord Bot Configuration](#discord-bot-configuration) section. You need to set the redirect URI to `${DASHBOARD_URL}/callback`. Replace `${DASHBOARD_URL}` with the URL of your dashboard (e.g. `http://localhost:5000`).

If have already started the bot once and you've changed the `DASHBOARD_URL` in the `.env` file, you will need to delete the `dashboard` image. The "easy way" is to run `docker compose up dashboard -d --force-recreate --build` to force the dashboard to rebuild. This will not delete the images, but it will recreate the container with the new environment variables.

If you want to delete all images that were built by you. you can run `docker compose down dashboard --rmi local` to shutdown and delete the dashboard. **This will not delete the images that were pulled from GitHub.** If you want to delete those as well, you can run `docker compose down --rmi all` to delete **all images and shutdown** the bot instance. This will delete all images that were pulled from GitHub and all images that were built by you.

To bring it back up, you can run `docker compose up -d` to start the bot again. This will recreate all containers and images that were deleted. If you want to just start the dashboard, you can run `docker compose up dashboard -d` to start the dashboard again.

## 4. ERROR: column "last_seen" of relation does not exist

This error was caused by the `init-cache.sql` file being incorrect which was fixed in [Guide PR#9](https://github.com/DanPlayz0/ticketsbot-self-host-guide/pull/9).

If you had setup the bot before this PR was merged, you will need to run the following SQL command in the `postgres-cache` database:

```sql
ALTER TABLE users ADD COLUMN last_seen TIMESTAMPTZ;
ALTER TABLE members ADD COLUMN last_seen TIMESTAMPTZ;
```

As this is just a cache database, you may also choose to stop the bot, delete the `pgcachedata` folder and re-run the bot with the updated `init-cache.sql` file.

## 5. I can't login to the dashboard. Every time I try to login, it loops/redirects me back to the login page

This issue is caused by the bot not being able to find any servers that you own or have admin for. You must first invite the bot into a server and run `/setup auto` in that server. Once you've done that, you should be able to login to the dashboard.

## 6. When I run a command, I get an error

If you see the bot online and when running a command you get an error, it's likely you messed up the [Interactions Endpoint URL](https://discord.com/developers/docs/interactions/overview#configuring-an-interactions-endpoint-url), you can fix this by following the steps in the [Discord Bot Configuration](#discord-bot-configuration) section. Specifically step 3.

## 7. ERROR: relation "import_logs" does not exist

Related issue: Failed to get import runs: An internal server error occurred

This error only occurs for users who have previously setup the bot before importing was supported.

> :warning: Make sure you have the latest version of the bot before running the following command. As the `init-support-import.sql` file was added as a bind mount to `postgres` in the `docker-compose.yaml` file. Making the following command possible.

To fix this error you will need to run the following command in the `postgres` container:

```bash
docker compose exec postgres psql -U postgres -d ticketsbot -f /docker-entrypoint-initdb.d/init-support-import.sql
```

## 8. ERROR: relation "panel_here_mentions" does not exist

Related issue: Error: Failed to load panels: An internal server error occurred
Related issue: Ticket Panels in dashboard gives me an internal server error

This error only occurs for users who have previously setup the bot before `@ here` was supported in ticket panels.

You will need to run the following command in the `postgres` container:

```bash
docker compose exec postgres psql -U postgres -d ticketsbot -f /docker-entrypoint-initdb.d/panel-here-mentions.sql
```

## 9. Exited with code 132

This error is caused by your CPU not supporting the `AVX2` instruction set. You can check if your CPU supports this by running the following command:

Linux:

```bash
cat /proc/cpuinfo | grep avx
```

If you see `avx2` in the output, your CPU supports it. If not, you will need to run the bot on a different CPU that does support it.

## 10. The database was created using collation version 2.36, but the operating system provides version 2.41

This issue stems from a minor patch to the `postgres:15` image tag. To fix the error message, use [FAQ #9](./faq.md#9-how-do-i-run-the-sql-commands-inside-the-database-containers) and run the following:

For the `postgres` "main" database:

```sql
ALTER DATABASE ticketsbot REFRESH COLLATION VERSION;
```

For the `pgarchivedata` "archive" database:

```sql
ALTER DATABASE archive REFRESH COLLATION VERSION;
```

For the `pgcachedata` "cache" database:

```sql
ALTER DATABASE botcache REFRESH COLLATION VERSION;
```