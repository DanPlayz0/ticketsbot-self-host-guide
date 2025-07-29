# Self Hosting Tickets Bot

Ten przewodnik przeprowadzi Cię przez proces samodzielnego hostowania bota [Tickets bot](https://discord.com/users/508391840525975553), którego zakończenie [zostało ogłoszone 5 marca 2025 roku](https://discord.com/channels/508392876359680000/508410703439462400/1325516916995129445) na [ich serwerze discord](https://discord.gg/XX2TxVCq6g). Ten przewodnik pomoże Ci uruchomić bota na własnym serwerze przy użyciu Dockera. **To nie jest oficjalny przewodnik i nie oferujemy wsparcia.** 

## Wstępne wymagania

- Musisz posiadać wiedzę na temat używania, wdrażania i uruchamiania kontenerów (w szczególności Dockera)
- Musisz wiedzieć jak korzystać z terminala
- Powinieneś mieć podstawową znajomość języków GoLang, Rust i Svelte
- Powinieneś umieć korzystać z baz danych (w szczególności z PostgreSQLYou)

## W jaki sposób  działa bot?

Prawdę mówiąc, nadal nie jestem pewien. Obrazek poniżej to uproszczony diagram przedstawiający, jak sądzę, że ten bot działa po prawie tygodniu analizowania kodu źródłowego. Pola z przerywaną linią oznaczają kontenery, które nie zostały uwzględnione w pliku `docker-compose.yaml` tego repozytorium. 

![Excalidraw](./images/ticketsbot-2025-01-11T23_47_40_622Z.svg)
Obrazek powyżej został wykonany przy użyciu [Excalidraw](https://excalidraw.com/).

## Instalacja i konfiguracja

1. Otwórz terminal w folderze, w którym chcesz zainstalować bota. (Lub utwórz folder i otwórz w nim terminal.)
2. Sklonuj repozytorium do tego folderu (`git clone https://github.com/DanPlayz0/ticketsbot-self-host-guide.git .`)
   - Kropka `.` na końcu polecenia jest ważna, ponieważ powoduje sklonowanie repozytorium do bieżącego folderu.
3. Utwórz plik `.env`, kopiując znajdujący się w repozytorium plik `.env.example`.

   - `DISCORD_BOT_TOKEN`: token twojego bota (np. `OTAyMzYyNTAxMDg4NDM2MjI0.YXdUkQ.TqZm7gNV2juZHXIvLdSvaAHKQCzLxgu9`)
   - `DISCORD_BOT_CLIENT_ID`: ID twojego bota (np. `508391840525975553`)
   - `DISCORD_BOT_OAUTH_SECRET`: client secret* twojego bota (np. `AAlRmln88YpOr8H8j1VvFuidKLJxg9rM`)
   - `DISCORD_BOT_PUBLIC_KEY`: public key* twojego bota (np. `fcd10216ebbc818d7ef1408a5c3c5702225b929b53b0a265b82e82b96a9a8358`)
   - `ADMIN_USER_IDS`: ID administratorów oddzielone przecinkami (np. `209796601357533184,585576154958921739,user_id,user_id`; w przypadku jednego użytkownika: `209796601357533184`)
   - `DISCORD_SUPPORT_SERVER_INVITE`: zaproszenie do twojego serwera (np. `https://discord.gg/ticketsbot`)
   - `DASHBOARD_URL`: adres URL dashboardu* (np. `http://localhost:5000`)
   - `LANDING_PAGE_URL`: adres URL strony internetowej (landing page*) (np. `https://tickets.bot`)
   - `API_URL`: URL twojego API (e.g. `http://localhost:8082`)
   - `DATABASE_HOST`: adres hosta bazy danych PostgreSQL (np. `postgres:5432`)
   - `DATABASE_PASSWORD`: hasło do bazy danych PostgreSQL (np. `password`)
   - `CACHE_DATABASE_HOST`: adres hosta bazy danych pamięci podręcznej (np. `postgres-cache:5432`)
   - `CACHE_DATABASE_PASSWORD`: hasło do bazy danych pamięci podręcznej (np. `password`)
   - `S3_ENDPOINT`: adres punktu końcowego (endpoint*) twojego S3 bucket* (np. `minio:9000`)
   - `S3_ACCESS`: klucz dostępu do S3 bucket* (np. `AbCdEfFgHiJkLmNoPqRsTuVwXyZ`)
   - `S3_SECRET`: sekretny klucz (secret key*) twojego S3 bucket* (np. `AbCdEfFgHiJkLmNoPqRsTuVwXyZ`)
   - `ARCHIVER_AES_KEY`: twój klucz AES-128 (np. `randomstring`)
     - Bash: `openssl rand -hex 16`
     - NodeJS: `node -e "console.log(require('crypto').randomBytes(16).toString('hex'))"`
   - `ARCHIVER_ADMIN_AUTH_TOKEN`:  token uwierzytelniający administratora archiwizatora (np. `randomstring`)
   - `SENTRY_DSN`: twój DNS do Sentry (np. `https://examplePublicKey@o0.ingest.sentry.io/0`)

4. Zamień elementy zastępcze (placeholders*) w poniższym poleceniu, a następnie wklej je na koniec pliku `sql-migrations/0-init-archive.sql`. W poleceniu znajdują się dwa elementy zastępcze: `${S3_ARCHIVE_BUCKET}` i `${S3_ENDPOINT}`. Zamień je odpowiednio nazwą swojego bucketu* i adresem endpointu* S3. Możesz też po prostu edytować plik `sql-migrations/0-init-archive.sql`. Wystarczy, że usuniesz `--` na początku linii, a następnie zamienisz elementy zastępcze. 

   ```sql
   INSERT INTO buckets (id, endpoint_url, name, active) VALUES ('b77cc1a0-91ec-4d64-bb6d-21717737ea3c', 'https://${S3_ENDPOINT}', '${S3_ARCHIVE_BUCKET}', TRUE);
   ```

5. Uruchom `docker compose up -d` aby pobrać obrazy kontenerów i uruchomić bota.
6. Skonfiguruj bota na Discordzie. ([Zobacz niżej](#konfiguracja-bota-na-discord)) 
7. Zarejestruj komendy slash*. ([Zobacz niżej](#rejestracja-komend-slash-przy-użyciu-dockera-zalecane)) 

## Konfiguracja bota na Discord

Ze względu na to, że samodzielnie hostujesz bota, musisz go samodzielnie skonfigurować. Oto kroki, jak to zrobić:
<sub>Uwaga: Discord Developer Portal nie posiada polskiej wersji językowej<sub>

1. Udaj się na [Discord Developer Portal*](https://discord.com/developers/applications)
2. Wybierz aplikację (application*) utworzoną dla bota
3. Ustaw `Interactions Endpoint URL` na `${HTTP_GATEWAY}/handle/${DISCORD_BOT_CLIENT_ID}`
   - Zamień `${HTTP_GATEWAY}` na adres URL twojego HTTP Gateway* (np. `https://gateway.example.com`. Musisz mieć [publicznie dostępny adres URL,](./wiki/faq.md#6-i-want-anyone-to-be-able-to-use-the-dashboard-how-do-i-do-that) nie localhost)
   - Zamień `${DISCORD_BOT_CLIENT_ID}` na ID klienta/aplikacji (application/client ID*) twojego bota (np. `508391840525975553`)
4. Udaj się do zakładki OAuth2
5. Dodaj redirect URL* `${DASHBOARD_URL}/callback` do OAuth2 redirect URIs*
   - Zamień `${DASHBOARD_URL}` na adres URL twojego dashboardu* (np. `http://localhost:5000`. Upewnij się, że adres zgadza się z tym co zostało ustawione w sekcji [Instalacja i konfiguracja](#Instalacja-i-konfiguracja))
6. Udaj się do sekcji Bot
7. Włącz `Server Members Intent` i `Message Content Intent`

## Rejestracja komend slash przy użyciu Dockera (zalecane)

1. Zbuduj narzędzie CLI (Command Line Interface*) do rejestracji komend, wykonując polecenie: `docker build -t ticketsbot/registercommands -f commands.Dockerfile .`
   - Pomoc: `docker run --rm ticketsbot/registercommands --help`
2. Zarejestruj komendy
   - Tylko komendy globalne: `docker run --rm ticketsbot/registercommands --token=token_twojego_bota`
   - Komendy globalne oraz administracyjne: `docker run --rm ticketsbot/registercommands --token=token_twojego_bota --admin-guild=ID_serwera_admin`

## Często zadawane pytania
<sub>Uwaga: Skecja tylko w języku angielskim<sub>
For frequently asked questions, please refer to the [FAQ](./wiki/faq.md) document.

- [#1 What can I host this on?](./wiki/faq.md#1-what-can-i-host-this-on)
- [#2 What are the system requirements?](./wiki/faq.md#2-what-are-the-system-requirements)
- [#3 Can I turn off the logging?](./wiki/faq.md#3-can-i-turn-off-the-logging)
- [#4 How do I update the bot?](./wiki/faq.md#4-how-do-i-update-the-bot)
- [#5 How do I get rid of the `ticketsbot.net` branding?](./wiki/faq.md#5-how-do-i-get-rid-of-the-ticketsbotnet-branding)
- [#6 I want anyone to be able to use the dashboard, how do I do that?](./wiki/faq.md#6-i-want-anyone-to-be-able-to-use-the-dashboard-how-do-i-do-that)
- [#7 This requires S3, can I host this without S3? (NOT recommended)](./wiki/faq.md#7-this-requires-s3-can-i-host-this-without-s3-not-recommended)
- [#8 How do I activate premium features?](./wiki/faq.md#8-how-do-i-activate-premium-features)
- [#9 How do I run the sql commands inside the database containers?](./wiki/faq.md#9-how-do-i-run-the-sql-commands-inside-the-database-containers)
- [#10 How do I import data from ticketsbot.net?](./wiki/faq.md#10-how-do-i-import-data-from-ticketsbotnet)

## Częste problemy
<sub>Uwaga: Skecja tylko w języku angielskim<sub>
For common issues, please refer to the [Common Issues](./wiki/common-issues.md) document.

- [#1 There's an error. (`no active bucket`)](./wiki/common-issues.md#1-theres-an-error-no-active-bucket)
- [#2 I got an error while setting the interactions url. (`The specified interactions endpoint url could not be verified.`)](./wiki/common-issues.md#2-i-got-an-error-while-setting-the-interactions-url-the-specified-interactions-endpoint-url-could-not-be-verified)
- [#3 Invalid OAuth2 redirect_uri](./wiki/common-issues.md#3-invalid-oauth2-redirect_uri)
- [#4 ERROR: column "last_seen" of relation does not exist](./wiki/common-issues.md#4-error-column-last_seen-of-relation-does-not-exist)
- [#5 I can't login to the dashboard. Every time I try to login, it loops/redirects me back to the login page](./wiki/common-issues.md#5-i-cant-login-to-the-dashboard-every-time-i-try-to-login-it-loopsredirects-me-back-to-the-login-page)
- [#6 When I run a command, I get an error](./wiki/common-issues.md#6-when-i-run-a-command-i-get-an-error)
- [#7 ERROR: relation "import_logs" does not exist](./wiki/common-issues.md#7-error-relation-import_logs-does-not-exist)
- [#7 Failed to get import runs: An internal server error occurred](./wiki/common-issues.md#7-error-relation-import_logs-does-not-exist)
- [#8 ERROR: relation "panel_here_mentions" does not exist](./wiki/common-issues.md#8-error-relation-panel_here_mentions-does-not-exist)
- [#8 Error: Failed to load panels: An internal server error occurred](./wiki/common-issues.md#8-error-relation-panel_here_mentions-does-not-exist)
- [#8 Ticket Panels in dashboard gives me an internal server error](./wiki/common-issues.md#8-error-relation-panel_here_mentions-does-not-exist)
- [#9 Exited with code 132](./wiki/common-issues.md#9-exited-with-code-132)
- [#9 CPU does not support AVX2](./wiki/common-issues.md#9-exited-with-code-132)

## Migrations

If you have previously setup the bot and want to update to the latest version, you will need to run the following based on when you set this up. (Sorted newest first)

- If your repo was missing `sql-migrations/4-ticket-counters.sql`, run it within the `postgres` container, see [FAQ #9](./wiki/faq.md#9-how-do-i-run-the-sql-commands-inside-the-database-containers) for how to do this.
- If your repo did not have the `sql-migrations/` folder. Pull the latest changes then make sure to update the `sql-migrations/0-init-archive.sql` file with your changes from the original `init-archive.sql` file.
- If your repo did not have `delete-mentions.sql`, run it within the `postgres` container, see [FAQ #9](./wiki/faq.md#9-how-do-i-run-the-sql-commands-inside-the-database-containers) for how to do this.
- Before [Guide PR#15](https://github.com/DanPlayz0/ticketsbot-self-host-guide/pull/15) (aka missing `panel-here-mentions.sql`), use [Common Issue #8](./wiki/common-issues.md#8-error-relation-panel_here_mentions-does-not-exist)
- Before [Guide PR#14](https://github.com/DanPlayz0/ticketsbot-self-host-guide/pull/14) (aka missing `init-support-import.sql`), use [Common Issue #7](./wiki/common-issues.md#7-error-relation-import_logs-does-not-exist)
- Before [Guide PR#9](https://github.com/DanPlayz0/ticketsbot-self-host-guide/pull/9), use [Common Issue #4](./wiki/common-issues.md#4-error-column-last_seen-of-relation-does-not-exist)

`*` Brak możliwości przetłumaczenia
