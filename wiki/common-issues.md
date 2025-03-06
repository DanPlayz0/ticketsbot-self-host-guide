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

If have already started the bot once and you've changed the `DASHBOARD_URL` in the `.env` file, you will need to delete the `dashboard` image. The "easy way" is to turn off the bot and delete all the images which were pulled or built by the compose file, you can do this by running `docker compose down --rmi all`.

The hard way is to find the image name, use `docker image ls` to view a list of images, and then use `docker image rm -f {image_name}`, replacing `{image_name}` with the image name.
Assuming you cloned the repository into a folder named `ticketsbot-self-host-guide`, the image name would be `ticketsbot-self-host-guide_dashboard`.

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
