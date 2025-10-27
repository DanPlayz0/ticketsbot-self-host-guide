# Server Counter

## Prerequisites

You will need to have a fully setup and working version of this guide up and running.

## Installation

Copy the following to the **top** of your docker-compose.yaml. **Make sure this is above the `services:` section!**

```yaml
include:
  - path:
    - ./addons/packages/gdpr-worker/docker-compose.yaml
```

## After Installation

After you have installed this package with one of the above ways do `docker compose down && docker compose up -d` in the root directory.
