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