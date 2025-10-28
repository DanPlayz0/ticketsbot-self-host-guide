# Clean-up Services

## Prerequisites

You will need to have a fully setup and working version of the guide up and running.

## Installation

There are 2 ways you can install this package.

### 1: EASY WAY: Snipped installation

Copy the following to the **top** of your docker-compose.yaml. **Make sure this is above the `services:` section!**

```yaml
include:
  - path:
    - ./addons/packages/clean-up-services/docker-compose.yaml
```

Then copy the contents of the provided [.env.example](./.env.example) file into your .env file from the guide.

Optionally change the settings of the services to use production mode by setting the vars for it to true.

### 2: COMPLICATED WAY: Copying everything manually

Copy the following at the **bottom** of your docker-compose.yaml. **Make sure this is above the `networks:` section!**

```yaml
  data-removal-service:
    image: ${DATA_REMOVAL_IMAGE:-ghcr.io/ticketsbot-cloud/data-removal-service:635d718130b13575d5cd28843483548d57d0ebda}
    container_name: ticketsbot-data-removal-service
    environment:
      PRODUCTION_MODE: ${DATA_REMOVAL_PROD_MODE:-false}
      DAEMON_MODE: ${DATA_REMOVAL_DAEMON_MODE:-false}
      DAEMON_EXECUTION_FREQUENCY: ${DATA_REMOVAL_DAEMON_FREQUENCY:-1h}
      CACHE_URI: postgres://postgres:${CACHE_DATABASE_PASSWORD:-null}@postgres-cache/botcache
      DATABASE_URI: 'postgres://postgres:${DATABASE_PASSWORD:-null}@postgres/ticketsbot'
      QUERY_TIMEOUT: ${DATA_REMOVAL_TIMEOUT:-10m}
      PURGE_THRESHOLD_DAYS: ${DATA_REMOVAL_THRESHOLD:-30}
    user: "${UID:-}:${GID:-}"
    depends_on:
      postgres:
        condition: service_healthy
        restart: true
      postgres-cache:
        condition: service_healthy
    networks:
    - app-network

  clean-up-daemon:
    image: ${CLEANUPDAEMON_IMAGE:-ghcr.io/ticketsbot-cloud/cleanupdaemon:1266ddeac31c626cfa64561b38a5cbeaeb9b475c}
    container_name: ticketsbot-clean-up-daemon
    environment:
      DB_URI: 'postgres://postgres:${DATABASE_PASSWORD:-null}@postgres/ticketsbot'
      LOG_ARCHIVER_URI: http://logarchiver:4000
      ONESHOT: ${CLEANUPDAEMON_ONESHOT:-false}
      PRODUCTION_MODE: ${CLEANUPDAEMON_PROD_MODE:-false}
      SENTRY_DNS: ${SENTRY_DSN}
      MAIN_BOT_TOKEN: '${DISCORD_BOT_TOKEN}'
      DISCORD_PROXY_URL: http-proxy:80
    user: "${UID:-}:${GID:-}"
    depends_on:
      postgres:
        condition: service_healthy
        restart: true
    networks:
    - app-network
```

Then copy the contents of the provided [.env.example](./.env.example) file into your `.env` file from the guide.

Optionally change the settings of the services to use production mode by setting the vars for it to true.

## After Installation

After you have installed this package with one of the above ways do `docker compose down && docker compose up -d` in your bot's directory.

You should now have working clean-up services.
