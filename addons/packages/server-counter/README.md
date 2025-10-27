# Server Counter

## Prerequisites

You will need to have a fully setup and working version of this guide up and running.

## Installation

There are 2 ways you can install this package.

### 1: EASY WAY: Snipped installation

Copy the following to the **top** of your docker-compose.yaml. **Make sure this is above the `services:` section!**

```yaml
include:
  - path:
    - ./addons/packages/server-counter/docker-compose.yaml
```

Then copy the contents of the provided [.env.example](./.env.example) file into your .env file from the guide.

Fill out the Required variables of the .env file with the part they require.

Optionally if you want to have the server counter accessible from everywhere you will need to forward the `https://localhost:8089` uri via a reverse proxy like Caddy or Traefik.

### 2: COMPLICATED WAY: Copying everything manually

Copy the following at the **bottom** of your docker-compose.yaml. **Make sure this is above the `networks:` section!**

```yaml
  server-counter:
    image: ${SERVER_COUNTER_IMAGE:-ghcr.io/ticketsbot-cloud/server-counter:82473c78811a26bba07da982e7e5637733a22e00}
    container_name: server-counter
    ports:
      - '8089:8089'
    environment:
      SERVER_ADDR: 0.0.0.0:8089
      CACHE_URI: postgres://postgres:${CACHE_DATABASE_PASSWORD:-null}@postgres-cache/botcache
    user: "${UID:-}:${GID:-}"
    depends_on:
      postgres-cache:
        condition: service_healthy
    networks:
    - app-network

  stats-channel-updater:
    image: ${STATS_CHANNEL_UPDATER_IMAGE:-ghcr.io/ticketsbot/statschannelupdater:latest}
    container_name: stats-channel-updater
    environment:
      SERVER_COUNTER_URL: ${STATS_CHANNEL_COUNTER_URL:-http://localhost:8089/total}
      DISCORD_TOKEN: ${DISCORD_BOT_TOKEN}
      CHANNEL_ID:  ${STATS_CHANNEL_ID}
    user: "${UID:-}:${GID:-}"
    networks:
      - app-network
```

Then copy the contents of the provided [.env.example](./.env.example) file into your .env file from the guide.

Fill out the required variables of the .env file with the part they require.

Optionally if you want to have the server counter accessible from everywhere you will need to forward the `https://localhost:8089` uri via a reverse proxy like Caddy or Traefik.

## After Installation

After you have installed this package with one of the above ways do `docker compose down && docker compose up -d` in your bot's directory.

You should now have a working server counter.
