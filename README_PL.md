# Self Hosting Tickets Bot

Ten przewodnik przeprowadzi Cię przez proces samodzielnego hostowania bota [Tickets bot](https://discord.com/users/508391840525975553), którego zakończenie [zostało ogłoszone 5 marca 2025 roku](https://discord.com/channels/508392876359680000/508410703439462400/1325516916995129445) na [ich serwerze discord](https://discord.gg/XX2TxVCq6g). Ten przewodnik pomoże Ci uruchomić bota na własnym serwerze przy użyciu Dockera. **To nie jest oficjalny przewodnik i nie oferujemy wsparcia.** 

## Wstępne wymagania

- Musisz posiadać wiedzę na temat używania, wdrażania i uruchamiania kontenerów (w szczególności Dockera)
- Musisz wiedzieć, jak korzystać z terminala
- Powinieneś mieć podstawową znajomość języków GoLang, Rust i Svelte
- Powinieneś umieć korzystać z baz danych (w szczególności z PostgreSQL)

## W jaki sposób  działa bot?

Prawdę mówiąc, nadal nie jestem pewien. Obrazek poniżej to uproszczony diagram przedstawiający, jak sądzę, że ten bot działa po prawie tygodniu analizowania kodu źródłowego. Pola z przerywaną linią oznaczają kontenery, które nie zostały uwzględnione w pliku `docker-compose.yaml` tego repozytorium. 

![Excalidraw](./images/ticketsbot-2025-01-11T23_47_40_622Z.svg)
Obrazek powyżej został wykonany przy użyciu [Excalidraw](https://excalidraw.com/).

## Instalacja i konfiguracja

1. Otwórz terminal w folderze, w którym chcesz zainstalować bota. (Lub utwórz folder i otwórz w nim terminal.)
2. Sklonuj repozytorium do tego folderu (`git clone https://github.com/DanPlayz0/ticketsbot-self-host-guide.git .`)
   - Kropka `.` na końcu polecenia jest ważna, ponieważ powoduje sklonowanie repozytorium do bieżącego folderu.
3. Utwórz plik `.env`, kopiując znajdujący się w repozytorium plik `.env.example`.

   - `DISCORD_BOT_TOKEN`: token Twojego bota (np. `OTAyMzYyNTAxMDg4NDM2MjI0.YXdUkQ.TqZm7gNV2juZHXIvLdSvaAHKQCzLxgu9`)
   - `DISCORD_BOT_CLIENT_ID`: ID Twojego bota (np. `508391840525975553`)
   - `DISCORD_BOT_OAUTH_SECRET`: client secret* Twojego bota (np. `AAlRmln88YpOr8H8j1VvFuidKLJxg9rM`)
   - `DISCORD_BOT_PUBLIC_KEY`: public key* Twojego bota (np. `fcd10216ebbc818d7ef1408a5c3c5702225b929b53b0a265b82e82b96a9a8358`)
   - `ADMIN_USER_IDS`: ID administratorów oddzielone przecinkami (np. `209796601357533184,585576154958921739,user_id,user_id`; w przypadku jednego użytkownika: `209796601357533184`)
   - `DISCORD_SUPPORT_SERVER_INVITE`: zaproszenie do Twojego serwera (np. `https://discord.gg/ticketsbot`)
   - `DASHBOARD_URL`: adres URL dashboardu* (np. `http://localhost:5000`)
   - `LANDING_PAGE_URL`: adres URL strony internetowej (landing page*) (np. `https://tickets.bot`)
   - `API_URL`: URL Twojego API (e.g. `http://localhost:8082`)
   - `DATABASE_HOST`: adres hosta bazy danych PostgreSQL (np. `postgres:5432`)
   - `DATABASE_PASSWORD`: hasło do bazy danych PostgreSQL (np. `password`)
   - `CACHE_DATABASE_HOST`: adres hosta bazy danych pamięci podręcznej (np. `postgres-cache:5432`)
   - `CACHE_DATABASE_PASSWORD`: hasło do bazy danych pamięci podręcznej (np. `password`)
   - `S3_ENDPOINT`: adres punktu końcowego (endpoint*) Twojego S3 bucket* (np. `minio:9000`)
   - `S3_ACCESS`: klucz dostępu do S3 bucket* (np. `AbCdEfFgHiJkLmNoPqRsTuVwXyZ`)
   - `S3_SECRET`: sekretny klucz (secret key*) Twojego S3 bucket* (np. `AbCdEfFgHiJkLmNoPqRsTuVwXyZ`)
   - `ARCHIVER_AES_KEY`: twój klucz AES-128 (np. `randomstring`)
     - Bash: `openssl rand -hex 16`
     - NodeJS: `node -e "console.log(require('crypto').randomBytes(16).toString('hex'))"`
   - `ARCHIVER_ADMIN_AUTH_TOKEN`:  token uwierzytelniający administratora archiwizatora (np. `randomstring`)
   - `SENTRY_DSN`: twój DSN do Sentry (np. `https://examplePublicKey@o0.ingest.sentry.io/0`)

4. Zamień elementy zastępcze (placeholders*) w poniższym poleceniu, a następnie wklej je na koniec pliku `sql-migrations/0-init-archive.sql`. W poleceniu znajdują się dwa elementy zastępcze: `${S3_ARCHIVE_BUCKET}` i `${S3_ENDPOINT}`. Zamień je odpowiednio nazwą swojego bucketu* i adresem endpointu* S3. Możesz też po prostu edytować plik `sql-migrations/0-init-archive.sql`. Wystarczy, że usuniesz `--` na początku linii, a następnie zamienisz elementy zastępcze. 

   ```sql
   INSERT INTO buckets (id, endpoint_url, name, active) VALUES ('b77cc1a0-91ec-4d64-bb6d-21717737ea3c', 'https://${S3_ENDPOINT}', '${S3_ARCHIVE_BUCKET}', TRUE);
   ```

5. Uruchom `docker compose up -d` aby pobrać obrazy kontenerów i uruchomić bota. 
6. Skonfiguruj bota na Discordzie. ([Zobacz niżej](#konfiguracja-bota-na-discord)) 
7. Zarejestruj komendy slash*. ([Zobacz niżej](#rejestracja-komend-slash-przy-użyciu-dockera-zalecane)) 

## Konfiguracja bota na Discord

Ze względu na to, że samodzielnie hostujesz bota, musisz go samodzielnie skonfigurować. Oto kroki, jak to zrobić:
<sub>Uwaga: Discord Developer Portal nie posiada polskiej wersji językowej</sub>

1. Udaj się na [Discord Developer Portal*](https://discord.com/developers/applications)
2. Wybierz aplikację (application*) utworzoną dla bota
3. Ustaw `Interactions Endpoint URL` na `${HTTP_GATEWAY}/handle/${DISCORD_BOT_CLIENT_ID}`
   - Zamień `${HTTP_GATEWAY}` na adres URL Twojego HTTP Gateway* (np. `https://gateway.example.com`. Musisz mieć [publicznie dostępny adres URL,](./wiki/faq.md#6-i-want-anyone-to-be-able-to-use-the-dashboard-how-do-i-do-that) nie localhost)
   - Zamień `${DISCORD_BOT_CLIENT_ID}` na ID klienta/aplikacji (application/client ID*) Twojego bota (np. `508391840525975553`)
4. Udaj się do zakładki OAuth2
5. Dodaj redirect URL* `${DASHBOARD_URL}/callback` do OAuth2 redirect URIs*
   - Zamień `${DASHBOARD_URL}` na adres URL Twojego dashboardu* (np. `http://localhost:5000`. Upewnij się, że adres zgadza się z tym co zostało ustawione w sekcji [Instalacja i konfiguracja](#Instalacja-i-konfiguracja))
6. Udaj się do sekcji Bot
7. Włącz `Server Members Intent` i `Message Content Intent`

## Rejestracja komend slash przy użyciu Dockera (zalecane)

1. Zbuduj narzędzie CLI (Command Line Interface*) do rejestracji komend, wykonując polecenie: `docker build -t ticketsbot/registercommands -f commands.Dockerfile .`
   - Pomoc: `docker run --rm ticketsbot/registercommands --help`
2. Zarejestruj komendy
   - Tylko komendy globalne: `docker run --rm ticketsbot/registercommands --token=token_twojego_bota`
   - Komendy globalne,  oraz administracyjne: `docker run --rm ticketsbot/registercommands --token=token_twojego_bota --admin-guild=ID_serwera_admin`

## Często zadawane pytania
<sub>Uwaga: Sekcja tylko w języku angielskim</sub>
Często zadawane pytania znajdują się w dokumencie [FAQ](./wiki/faq.md).

- [#1 Na czym mogę to hostować?](./wiki/faq.md#1-what-can-i-host-this-on)
- [#2 Jakie są wymagania systemowe?](./wiki/faq.md#2-what-are-the-system-requirements)
- [#3 Czy mogę wyłączyć logowanie?](./wiki/faq.md#3-can-i-turn-off-the-logging)
- [#4 Jak zaktualizować bota?](./wiki/faq.md#4-how-do-i-update-the-bot)
- [#5 Jak pozbyć się napisu `ticketsbot.net`?](./wiki/faq.md#5-how-do-i-get-rid-of-the-ticketsbotnet-branding)
- [#6 Chcę, aby każdy mógł korzystać z dashboardu. Jak to zrobić?](./wiki/faq.md#6-i-want-anyone-to-be-able-to-use-the-dashboard-how-do-i-do-that)
- [#7 Ten bot wymaga S3. Czy mogę to hostować bez S3? (Niezalecane)](./wiki/faq.md#7-this-requires-s3-can-i-host-this-without-s3-not-recommended)
- [#8 Jak aktywować funkcje premium?](./wiki/faq.md#8-how-do-i-activate-premium-features)
- [#9 Jak uruchomić polecenia SQL wewnątrz kontenerów bazy danych?](./wiki/faq.md#9-how-do-i-run-the-sql-commands-inside-the-database-containers)
- [#10 Jak przenieść dane z ticketsbot.net?](./wiki/faq.md#10-how-do-i-import-data-from-ticketsbotnet)

## Częste problemy
<sub>Uwaga: Sekcja tylko w języku angielskim</sub>
Częste problemy znajdują się w dokumencie [Common Issues](./wiki/common-issues.md).

- [#1 Występuje błąd (error*): (`no active bucket`)](./wiki/common-issues.md#1-theres-an-error-no-active-bucket)
- [#2 Występuje błąd podczas ustawiania interactions url*: (`The specified interactions endpoint url could not be verified.`)](./wiki/common-issues.md#2-i-got-an-error-while-setting-the-interactions-url-the-specified-interactions-endpoint-url-could-not-be-verified)
- [#3 Invalid OAuth2 redirect_uri*](./wiki/common-issues.md#3-invalid-oauth2-redirect_uri)
- [#4 ERROR: column "last_seen" of relation does not exist](./wiki/common-issues.md#4-error-column-last_seen-of-relation-does-not-exist)
- [#5 Nie mogę zalogować się do dashboardu. Za każdym razem, gdy próbuję się zalogować przekierowuje mnie z powrotem na stronę logowania](./wiki/common-issues.md#5-i-cant-login-to-the-dashboard-every-time-i-try-to-login-it-loopsredirects-me-back-to-the-login-page)
- [#6 Gdy używam komendę, występuje błąd](./wiki/common-issues.md#6-when-i-run-a-command-i-get-an-error)
- [#7 ERROR: relation "import_logs" does not exist](./wiki/common-issues.md#7-error-relation-import_logs-does-not-exist)
- [#7 Failed to get import runs: An internal server error occurred](./wiki/common-issues.md#7-error-relation-import_logs-does-not-exist)
- [#8 ERROR: relation "panel_here_mentions" does not exist](./wiki/common-issues.md#8-error-relation-panel_here_mentions-does-not-exist)
- [#8 Error: Failed to load panels: An internal server error occurred](./wiki/common-issues.md#8-error-relation-panel_here_mentions-does-not-exist)
- [#8 Ticket Panels* w dashboardzie powodują błąd: internal server error](./wiki/common-issues.md#8-error-relation-panel_here_mentions-does-not-exist)
- [#9 Exited with code 132](./wiki/common-issues.md#9-exited-with-code-132)
- [#9 CPU does not support AVX2](./wiki/common-issues.md#9-exited-with-code-132)

## Aktualizacje

Jeśli wcześniej skonfigurowałeś bota i chcesz zaktualizować go do najnowszej wersji, musisz wykonać poniższe kroki w zależności od tego, kiedy go instalowałeś. (Posortowane od najnowszych)

- Przed [Guide PR#30](https://github.com/DanPlayz0/ticketsbot-self-host-guide/pull/30) (czyli brakującym `sql-migrations/5-modal-labels.sql`), uruchom go wewnątrz kontenera `postgres`. Zobacz [FAQ #9](./wiki/faq.md#9-how-do-i-run-the-sql-commands-inside-the-database-containers) aby dowiedzieć się jak to zrobić.
- Jeśli w Twoim repozytorium brakowało pliku `sql-migrations/4-ticket-counters.sql`, uruchom go wewnątrz kontenera `postgres`. Zobacz [FAQ #9](./wiki/faq.md#9-how-do-i-run-the-sql-commands-inside-the-database-containers), aby dowiedzieć się jak to zrobić.
- Jeśli twoje repozytorium nie zawierało folderu `sql-migrations/`, pobierz najnowsze zmiany, a następnie zaktualizuj plik `sql-migrations/0-init-archive.sql` uwzględniając zmiany z oryginalnego pliku `init-archive.sql`.
- Jeśli Twoje repozytorium nie zawierało pliku `delete-mentions.sql`, uruchom go wewnątrz kontenera `postgres`. Zobacz [FAQ #9](./wiki/faq.md#9-how-do-i-run-the-sql-commands-inside-the-database-containers), aby dowiedzieć się jak to zrobić.
- Jeśli używasz wersji sprzed [Guide PR#15](https://github.com/DanPlayz0/ticketsbot-self-host-guide/pull/15) (czyli brak `panel-here-mentions.sql`), zobacz [Common Issue #8](./wiki/common-issues.md#8-error-relation-panel_here_mentions-does-not-exist)
- Jeśli używasz wersji sprzed [Guide PR#14](https://github.com/DanPlayz0/ticketsbot-self-host-guide/pull/14) (czyli brak `init-support-import.sql`), zobacz [Common Issue #7](./wiki/common-issues.md#7-error-relation-import_logs-does-not-exist)
- Jeśli używasz wersji sprzed [Guide PR#9](https://github.com/DanPlayz0/ticketsbot-self-host-guide/pull/9), zobacz [Common Issue #4](./wiki/common-issues.md#4-error-column-last_seen-of-relation-does-not-exist)


Uwaga: Niektóre elementy nie mają bezpośrednich odpowiedników w języku polskim, dlatego tłumaczenie może nie oddawać w pełni oryginalnego znaczenia. Nie ponoszę odpowiedzialności za ewentualne błędy ani ich skutki.

`*` Brak możliwości przetłumaczenia



Autorem tłumaczenia jest [Adam](https://github.com/4Adam)
