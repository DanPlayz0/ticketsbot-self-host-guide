# Zelf Hosting TicketsBot

Dit is een handleiding om de [TicketsBot](https://discord.com/users/508391840525975553) zelf te hosten. dat was [bekendgemaakt om zonsondergang op de 5 maart 2025](https://discord.com/channels/508392876359680000/508410703439462400/1325516916995129445) op [hun ondersteuningsserver](https://discord.gg/XX2TxVCq6g). Deze handleiding helpt je om de bot op je eigen machine op te zetten met behulp van Docker. **Dit is geen officiële handleiding en ik bied geen ondersteuning.**

## vereisten

- Je moet kennis hebben van het gebruik, deployen en uitvoeren van containers (specifiek Docker)
- Je moet enigszins weten hoe je een terminal gebruikt.
- Je moet een basisbegrip hebben van GoLang, Rust en Svelte
- Je moet een basiskennis hebben van het werken met een database (specifiek PostgreSQL)

## Hoe werkt de bot?

Om heel eerlijk te zijn, weet ik het nog steeds niet precies. De afbeelding hieronder is een ruwe schematische weergave van hoe ik denk dat de bot werkt, na bijna een week puzzelen met de TicketsBot-codebase. De gestippelde vakken zijn de containers die ik niet heb opgenomen in het `docker-compose.yaml` bestand in deze repository.

![Excalidraw](./images/ticketsbot-2025-01-11T23_47_40_622Z.svg)
De bovenstaande afbeelding is gemaakt met [Excalidraw](https://excalidraw.com/).

## opstelling

1. Open een terminal in de map waar je de bot wilt installeren. (Of maak een map aan en open een terminal in die map)
2. Clone deze repository naar die map (`git clone https://github.com/DanPlayz0/ticketsbot-self-host-guide.git .`)
   - Te `.` Clone deze repository naar die map, dit is belangrijk omdat het de repository in de huidige map kloont
3. Maak een `.env` bestand door het opgegeven bestand te kopiëren `.env.example` map.

   - `DISCORD_BOT_TOKEN`: jou bot-token (e.g. `OTAyMzYyNTAxMDg4NDM2MjI0.YXdUkQ.TqZm7gNV2juZHXIvLdSvaAHKQCzLxgu9`)
   - `DISCORD_BOT_CLIENT_ID`: de client van je bot ID (e.g. `508391840525975553`)
   - `DISCORD_BOT_OAUTH_SECRET`: de client van je bot geheim (e.g. `AAlRmln88YpOr8H8j1VvFuidKLJxg9rM`)
   - `DISCORD_BOT_PUBLIC_KEY`: de openbare sleutel van je bot (e.g. `fcd10216ebbc818d7ef1408a5c3c5702225b929b53b0a265b82e82b96a9a8358`)
   - `ADMIN_USER_IDS`: een komma-gescheiden lijst van gebruikers IDs (e.g. `209796601357533184,585576154958921739,user_id,user_id`, een enkele id zou zijn `209796601357533184`)
   - `DISCORD_SUPPORT_SERVER_INVITE`: de uitnodigingslink naar je ondersteuningsserver (e.g. `https://discord.gg/ticketsbot`)
   - `DASHBOARD_URL`: de URL van je dashboard (e.g. `http://localhost:5000`)
   - `LANDING_PAGE_URL`: de URL van je landingspagina (e.g. `https://ticketsbot.cloud`)
   - `API_URL`: de URL van je API (e.g. `http://localhost:8082`)
   - `DATABASE_HOST`: je PostgreSQL-host (e.g. `postgres:5432`)
   - `DATABASE_PASSWORD`: je PostgreSQL-wachtwoord (e.g. `password`)
   - `CACHE_DATABASE_HOST`: je cache-database-host (e.g. `postgres-cache:5432`)
   - `CACHE_DATABASE_PASSWORD`: je cache-database-wachtwoord (e.g. `password`)
   - `S3_ENDPOINT`: de endpoint van je S3-bucket (e.g. `minio:9000`)
   - `S3_ACCESS`: de toegangssleutel van je S3-bucket (e.g. `AbCdEfFgHiJkLmNoPqRsTuVwXyZ`)
   - `S3_SECRET`: de geheime sleutel van je S3-bucket (e.g. `AbCdEfFgHiJkLmNoPqRsTuVwXyZ`)
   - `ARCHIVER_AES_KEY`: je AES-128-sleutel (e.g. `randomstring`)
     - Bash: `openssl rand -hex 16`
     - NodeJS: `node -e "console.log(require('crypto').randomBytes(16).toString('hex'))"`
   - `ARCHIVER_ADMIN_AUTH_TOKEN`: je archiver admin-authenticatietoken (e.g. `randomstring`)
   - `SENTRY_DSN`: je Sentry DSN (e.g. `https://examplePublicKey@o0.ingest.sentry.io/0`)

4. Vervang de tijdelijke aanduidingen in de volgende opdracht en plak deze onderaan
 `init-archive.sql`. Er zijn 2 tijdelijke aanduidingen in de opdracht, `${S3_ARCHIVE_BUCKET}` en `${S3_ENDPOINT}`. Vervang ze respectievelijk met de naam van je bucket en de S3-endpoint. Je kunt ook gewoon de `init-archive.sql` bestand ook, je hoeft het alleen maar te decommentariëren (by removing the `--` at the start of the line) en vervang daar de variabelen.

   ```sql
    INSERT INTO buckets (id, endpoint_url, name, active) VALUES ('b77cc1a0-91ec-4d64-bb6d-21717737ea3c', 'https://${S3_ENDPOINT}', '${S3_ARCHIVE_BUCKET}', TRUE);
   ```

5. Uitvoeren `docker compose up -d` om de afbeeldingen te downloaden en de bot te starten.
6. Configureer de Discord-bot. ([kijk beneden](#discord-bot-configuratie))
7. Registreer de slash-commando's ([kijk beneden](#het-registreren-van-de-slash-commandos-met-docker-aanbevolen))

## Discord Bot Configuratie

Aangezien deze bot zelf gehost wordt, zul je de bot zelf moeten configureren. Hier zijn de stappen om de bot te configureren:

1. ga naar de [Discord ontwikkelaar portaal](https://discord.com/developers/applications)
2. Klik op de applicatie die je voor de bot hebt aangemaakt
3. zet te `Interactions Endpoint URL` naar `${HTTP_GATEWAY}/handle/${DISCORD_BOT_CLIENT_ID}`
   - vervang `${HTTP_GATEWAY}` met de URL van je HTTP-gateway (e.g. `https://gateway.example.com`, Je moet wel een [openbaar URL](./wiki/faq.md#6-i-want-anyone-to-be-able-to-use-the-dashboard-how-do-i-do-that) Geen localhost)
   - vervangen `${DISCORD_BOT_CLIENT_ID}` met de applicatie-/client-ID van je bot (e.g. `508391840525975553`)
4. ga naar te OAuth2 tab
5. Voeg de redirect-URL toe `${DASHBOARD_URL}/callback` aan de OAuth2-redirect-URI's
   - vervang `${DASHBOARD_URL}` met de URL van je API (e.g. `http://localhost:8080`,  zorg ervoor dat dit overeenkomt met wat je hebt ingesteld in de [opstelling](#opstelling) section)
6. Ga naar het tabblad 'Bot
7. Schakel de wisselknoppen `Server Members Intent` en `Message Content Intent` in

## Het registreren van de slash-commando's met Docker (Aanbevolen)

1. Bouw het CLI-hulpprogramma voor het registreren van commando's met behulp van `docker build -t ticketsbot/registercommands -f commands.Dockerfile .`
   - Krijg hulp door het uitvoeren van `docker run --rm ticketsbot/registercommands --help`
2. Registreer de commando's
   - Alleen globale commando's: `docker run --rm ticketsbot/registercommands --token=your_bot_token --id=your_client_id`
   - Globale en admin-commando's door het uitvoeren van `docker run --rm ticketsbot/registercommands --token=your_bot_token --id=your_client_id --admin-guild=your_admin_guild_id`

## Veelgestelde Vragen

Voor veelgestelde vragen, verwijs alstublieft naar de [veelgestelde vragen](./wiki/faq.md) document.

- [#1 Op welk platform kan ik dit hosten?](./wiki/faq.md#1-what-can-i-host-this-on)
- [#2 Wat zijn de systeemvereisten?](./wiki/faq.md#2-what-are-the-system-requirements)
- [#3 Kan ik de logging uitschakelen?](./wiki/faq.md#3-can-i-turn-off-the-logging)
- [#4 Hoe can ik de bot updaten?](./wiki/faq.md#4-how-do-i-update-the-bot)
- [#5 Hoe verwijder ik de `ticketsbot.net` branding?](./wiki/faq.md#5-how-do-i-get-rid-of-the-ticketsbotnet-branding)
- [#6 Ik wil dat iedereen het dashboard kan gebruiken, hoe stel ik dat in?](./wiki/faq.md#6-i-want-anyone-to-be-able-to-use-the-dashboard-how-do-i-do-that)
- [#7 Hiervoor is S3 vereist, kan ik dit ook zonder S3 hosten? (NOT recommended)](./wiki/faq.md#7-this-requires-s3-can-i-host-this-without-s3-not-recommended)
- [#8 Hoe activeer ik de premiumfuncties?](./wiki/faq.md#8-how-do-i-activate-premium-features)
- [#9 Hoe voer ik de SQL-commando's uit binnen de databasecontainer?](./wiki/faq.md#9-how-do-i-run-the-sql-commands-inside-the-database-containers)
- [#10 Hoe kan ik data importeren van ticketsbot.net?](./wiki/faq.md#10-how-do-i-import-data-from-ticketsbotnet)

## veelvoorkomende problemen

 Voor veelvoorkomende problemen, verwijs alstublieft naar de [Veelvoorkomende problemen](./wiki/common-issues.md) document.

- [#1 Er is een fout. (`no active bucket`)](./wiki/common-issues.md#1-theres-an-error-no-active-bucket)
- [#2 Ik kreeg een fout tijdens het instellen van de interacties-url. (`The specified interactions endpoint url could not be verified.`)](./wiki/common-issues.md#2-i-got-an-error-while-setting-the-interactions-url-the-specified-interactions-endpoint-url-could-not-be-verified)
- [#3 ongeldige OAuth2 redirect_uri](./wiki/common-issues.md#3-invalid-oauth2-redirect_uri)
- [#4 FOUT: kolom "last_seen" van de relatie bestaat niet](./wiki/common-issues.md#4-error-column-last_seen-of-relation-does-not-exist)
- [#5 Ik kan niet inloggen op het dashboard. Elke keer als ik probeer in te loggen, komt het in een lus terecht/word ik doorgestuurd naar de inlogpagina](./wiki/common-issues.md#5-i-cant-login-to-the-dashboard-every-time-i-try-to-login-it-loopsredirects-me-back-to-the-login-page)
- [#6 Wanneer ik een commando uitvoer, krijg ik een fout.](./wiki/common-issues.md#6-when-i-run-a-command-i-get-an-error)
- [#7 FOUT: relatie "import_logs" bestaat niet](./wiki/common-issues.md#7-error-relation-import_logs-does-not-exist)
- [#7 Kon importruns niet ophalen: Er is een interne serverfout opgetreden](./wiki/common-issues.md#7-error-relation-import_logs-does-not-exist)
- [#8 FOUT: relatie "panel_here_mentions" bestaat niet](./wiki/common-issues.md#8-error-relation-panel_here_mentions-does-not-exist)
- [#8 Fout: Panels konden niet worden geladen: Er is een interne serverfout opgetreden](./wiki/common-issues.md#8-error-relation-panel_here_mentions-does-not-exist)
- [#8 Ticketpanelen in het dashboard geven een interne serverfout](./wiki/common-issues.md#8-error-relation-panel_here_mentions-does-not-exist)
- [#9 Afgesloten met code 132](./wiki/common-issues.md#9-exited-with-code-132)
- [#9 CPU ondersteunt AVX2 niet](./wiki/common-issues.md#9-exited-with-code-132)

## Migraties

Als je de bot eerder hebt ingesteld en naar de nieuwste versie wilt updaten, moet je het volgende uitvoeren, afhankelijk van wanneer je dit hebt ingesteld. (Sorteer op nieuwste eerst)

- Als je repository dit niet had `delete-mentions.sql`, voer het uit binnen de `postgres` container, kijk [veelgestelde vragen #9](./wiki/faq.md#9-how-do-i-run-the-sql-commands-inside-the-database-containers) voor hoe je dit moet doen.
- voor [Guide PR#15](https://github.com/DanPlayz0/ticketsbot-self-host-guide/pull/15), gebruik [Common Issue #8](./wiki/common-issues.md#8-error-relation-panel_here_mentions-does-not-exist)
- voor [Guide PR#14](https://github.com/DanPlayz0/ticketsbot-self-host-guide/pull/14), gebruik [Common Issue #7](./wiki/common-issues.md#7-error-relation-import_logs-does-not-exist)
- voor [Guide PR#9](https://github.com/DanPlayz0/ticketsbot-self-host-guide/pull/9), gebruik [Common Issue #4](./wiki/common-issues.md#4-error-column-last_seen-of-relation-does-not-exist)

<sub>vertaling verzorgd door [chaoskjell44](https://linktr.ee/chaoskjell44)</sub>
