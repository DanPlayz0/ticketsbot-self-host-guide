# Self Hosting Tickets Bot

Dieses unoffizielle guide zeigt dir wie man den [Tickets bot](https://discord.com/users/508391840525975553) selber hosten kann. Dieser bot wurde leider abgeschalted, [was am fünften märz geschehen sollte/ist](https://discord.com/channels/508392876359680000/508410703439462400/1325516916995129445) und in [dem support server](https://discord.gg/XX2TxVCq6g) angekündigt wurde. Dieses guide wird dir helfen, den bot auf deiner eigenen maschine oder einem server selber zu hosten, und zwar mit der hilfe von Docker. **Dieses ist kein offizielles guide weshalb auch kein support dafür bereit gestellt wird.**

## Vorraussetzungen

- Du musst Wissen, wie man container benutzt, bereitstellt und ausführt (speziell Docker)
- Du musst Wissen, wie man ein Terminal benutzt
- Du solltest ein basis wissen in GoLang, Rust, und Svelte haben
- Du solltest ein basis wissen haben, wie man eine datenbasis benutzt (speziell PostgreSQL)

## Wie funktioniert der bot?

Um ehrlich zu sein, weiß ich das selbst noch nicht. Das bild unten ist ein ungefähres diagram, dass zeigt, wie ich denke, das der bot funktioniert, nach etwas über einer woche an tüffteln mit der ticketsbot codebasis. Die gepunkteten boxen sind teile des bots, die ich nicht in die `docker-compose.yaml` datei, in diesem repository, eingefügt habe, weshalb sie fehlen.

![Excalidraw](./images/ticketsbot-2025-01-11T23_47_40_622Z.svg)
Das obrige Bild, wurde mit [Excalidraw](https://excalidraw.com/) erstellt.

## Setup

1. Öffne dein terminal, in dem ordner, in welchem du den bot installieren möchtest. (Oder erstelle einen ordner und öffne das terminal dort drinne)
2. Klone dieses repository in den ordner (`git clone https://github.com/DanPlayz0/ticketsbot-self-host-guide.git .`)
   - Der `.` am ende ist sehr wichtig, da mit ihm, das repository in den jetzigen ordner kopiert wird
3. Erstelle die `.env` datei durch kopieren der bereitgestellten `.env.example` datei.

   - `DISCORD_BOT_TOKEN`: dein bot token (z.B. `OTAyMzYyNTAxMDg4NDM2MjI0.YXdUkQ.TqZm7gNV2juZHXIvLdSvaAHKQCzLxgu9`)
   - `DISCORD_BOT_CLIENT_ID`: die client ID deines bots (z.B. `508391840525975553`)
   - `DISCORD_BOT_OAUTH_SECRET`: dein bot client secret (z.B. `AAlRmln88YpOr8H8j1VvFuidKLJxg9rM`)
   - `DISCORD_BOT_PUBLIC_KEY`: dein bot public key (z.B. `fcd10216ebbc818d7ef1408a5c3c5702225b929b53b0a265b82e82b96a9a8358`)
   - `ADMIN_USER_IDS`: ein komma separiert die liste mit benutzer IDs (z.B. `209796601357533184,585576154958921739,user_id,user_id`, eine einzelne ID wäre `209796601357533184`)
   - `DISCORD_SUPPORT_SERVER_INVITE`: der invite link zu deinem support server (z.B. `https://discord.gg/ticketsbot`)
   - `DASHBOARD_URL`: die URL deines dashboards (z.B. `http://localhost:5000`)
   - `LANDING_PAGE_URL`: die URL deiner home page (z.B. `https://tickets.bot`)
   - `API_URL`: die URL deiner API (z.B. `http://localhost:8082`)
   - `DATABASE_HOST`: dein PostgreSQL host (z.B. `postgres:5432`)
   - `DATABASE_PASSWORD`: dein PostgreSQL password (z.B. `password`)
   - `CACHE_DATABASE_HOST`: dein cache database host (z.B. `postgres-cache:5432`)
   - `CACHE_DATABASE_PASSWORD`: dein cache database password (z.B. `password`)
   - `S3_ENDPOINT`: der endpunkt von deinem S3 bucket (z.B. `minio:9000`)
   - `S3_ACCESS`: der access key von deinem S3 bucket (z.B. `AbCdEfFgHiJkLmNoPqRsTuVwXyZ`)
   - `S3_SECRET`: der secret key von deinem S3 bucket (z.B. `AbCdEfFgHiJkLmNoPqRsTuVwXyZ`)
   - `ARCHIVER_AES_KEY`: dein AES-128 key (z.B. `randomstring`)
     - Bash: `openssl rand -hex 16`
     - NodeJS: `node -e "console.log(require('crypto').randomBytes(16).toString('hex'))"`
   - `ARCHIVER_ADMIN_AUTH_TOKEN`: dein archiver admin auth token (z.B. `randomstring`)
   - `SENTRY_DSN`: dein Sentry DSN (z.B. `https://examplePublicKey@o0.ingest.sentry.io/0`)

4. Tausche die platzhalter in dem folgenden command und paste es ganz unten, in die `init-archive.sql` datei. Es gibt zwei platzhalter in dem command, `${S3_ARCHIVE_BUCKET}` und `${S3_ENDPOINT}`. Ersetze sie jeweils mit deinem bucket namen und deinem S3 endpunkt. Du kannst auch einfach die `init-archive.sql` datei editieren und musst einfach den command entkommentieren (durch entfernen der `--` am anfang der zeile) und ersetze die platzhalter hier.

   ```sql
   INSERT INTO buckets (id, endpoint_url, name, active) VALUES ('b77cc1a0-91ec-4d64-bb6d-21717737ea3c', 'https://${S3_ENDPOINT}', '${S3_ARCHIVE_BUCKET}', TRUE);
   ```

5. Führe folgenden command aus `docker compose up -d` , um die docker bilder zu ziehen und den bot zu starten.
6. Konfiguriere den Discord bot. ([siehe unten](#discord-bot-konfiguration))
7. Registriere die slash commands ([siehe unten](#registrierung-der-slash-commands-mithilfe-von-Docker-empfohlen))

## Discord Bot Konfiguration

Da dieser bot selbst-gehosted ist, musst du, denn bot selbst konfigurieren. Hier die schritte zum konfigurieren des bots:

1. Gehe zum [Discord Developer Portal](https://discord.com/developers/applications)
2. Klicke auf anwendung die du für den bot erstellt hast 
3. Setze die `Interactions Endpoint URL` zu `${HTTP_GATEWAY}/handle/${DISCORD_BOT_CLIENT_ID}`
   - Ersetzte `${HTTP_GATEWAY}` mit der URL deines HTTP Gateway (z.B. `https://gateway.example.com`, Du must eine [öffentlich erreichbare URL](./wiki/faq.md#6-i-want-anyone-to-be-able-to-use-the-dashboard-how-do-i-do-that) haben nicht localhost)
   - Ersetze `${DISCORD_BOT_CLIENT_ID}` mit deiner bot application/client ID (z.B. `508391840525975553`)
4. Gehe in das OAuth2 tab
5. Füge die redirect URL `${DASHBOARD_URL}/callback` zu den OAuth2 redirect URIs hinzu
   - Ersetze `${DASHBOARD_URL}` mit der URL deines Dashboards (z. B. `http://localhost:5000`, Stelle sicher das diese, mit der URL, die du, in dem [Setup](#setup) abschnitt gesetzt hast, überein stimmt)
6. Gehe in das Bot tab
7. Schalte die `Server Members Intent` und `Message Content Intent` schalter an

## Registrierung der slash commands mithilfe von Docker (Empfohlen)

1. Baue das register commands cli utility durch ausführung von `docker build -t ticketsbot/registercommands -f commands.Dockerfile .`
   - Hilfe gibt es mit `docker run --rm ticketsbot/registercommands --help`
2. Registrierung der commands
   - nur Globale commands: `docker run --rm ticketsbot/registercommands --token=your_bot_token`
   - Globale & Admin commands durch ausführung von `docker run --rm ticketsbot/registercommands --token=your_bot_token --admin-guild=your_admin_guild_id`

## Häufig gestellte Fragen

Für Häufig gestellte Fragen, bitte das [FAQ](./wiki/faq.md) dokument lesen. <sup>nur in englisch vorhanden</sup>

- [#1 Worauf kann ich den bot hosten?](./wiki/faq.md#1-what-can-i-host-this-on)
- [#2 Was sind die system vorausetzungen?](./wiki/faq.md#2-what-are-the-system-requirements)
- [#3 Kann ich die logs ausschalten?](./wiki/faq.md#3-can-i-turn-off-the-logging)
- [#4 Wie update ich den bot?](./wiki/faq.md#4-how-do-i-update-the-bot)
- [#5 Wie entferne ich das `ticketsbot.net` Branding?](./wiki/faq.md#5-how-do-i-get-rid-of-the-ticketsbotnet-branding)
- [#6 Ich möchte das jeder auf das dashboard zugriff hat, wie mache ich das?](./wiki/faq.md#6-i-want-anyone-to-be-able-to-use-the-dashboard-how-do-i-do-that)
- [#7 Das braucht S3, kann Ich auch ohne S3 hosten? (NICHT EMPFOHLEN)](./wiki/faq.md#7-this-requires-s3-can-i-host-this-without-s3-not-recommended)
- [#8 wie aktiviere ich premium features?](./wiki/faq.md#8-how-do-i-activate-premium-features)
- [#9 Wie führe ich sql commands in den datenbasis containern aus?](./wiki/faq.md#9-how-do-i-run-the-sql-commands-inside-the-database-containers)
- [#10 Wie importiere ich meine daten von ticketsbot.net?](./wiki/faq.md#10-how-do-i-import-data-from-ticketsbotnet)

## häufige Probleme

Für häufige Probleme, bitte das [Common Issues](./wiki/common-issues.md) dokument lesen. <sup>auch nur in englisch vorhanden</sup>

- [#1 Dort ist ein error. (`no active bucket`)](./wiki/common-issues.md#1-theres-an-error-no-active-bucket)
- [#2 Ich habe einen error beim setzen der interactions url bekommen. (`The specified interactions endpoint url could not be verified.`)](./wiki/common-issues.md#2-i-got-an-error-while-setting-the-interactions-url-the-specified-interactions-endpoint-url-could-not-be-verified)
- [#3 Ungültige OAuth2 redirect_uri](./wiki/common-issues.md#3-invalid-oauth2-redirect_uri)
- [#4 ERROR: column "last_seen" of relation does not exist](./wiki/common-issues.md#4-error-column-last_seen-of-relation-does-not-exist)
- [#5 Ich kann mich nicht in das dashboard einloggen. immer wenn ich versuche mich einzuloggen, wiederholt/leited es mich zur login seite zurück](./wiki/common-issues.md#5-i-cant-login-to-the-dashboard-every-time-i-try-to-login-it-loopsredirects-me-back-to-the-login-page)
- [#6 Wenn ich einen command ausführe, kriege ich einen error](./wiki/common-issues.md#6-when-i-run-a-command-i-get-an-error)
- [#7 ERROR: relation "import_logs" does not exist](./wiki/common-issues.md#7-error-relation-import_logs-does-not-exist)
- [#7 Failed to get import runs: An internal server error occurred](./wiki/common-issues.md#7-error-relation-import_logs-does-not-exist)
- [#8 ERROR: relation "panel_here_mentions" does not exist](./wiki/common-issues.md#8-error-relation-panel_here_mentions-does-not-exist)
- [#8 Error: Failed to load panels: An internal server error occurred](./wiki/common-issues.md#8-error-relation-panel_here_mentions-does-not-exist)
- [#8 Ticket Panels im dashboard geben mir einen internal server error](./wiki/common-issues.md#8-error-relation-panel_here_mentions-does-not-exist)
- [#9 Exited with code 132](./wiki/common-issues.md#9-exited-with-code-132)
- [#9 CPU unterstützt AVX2 nicht](./wiki/common-issues.md#9-exited-with-code-132)

## Migrationen

Falls du den bot früher schon mal aufgesetzt hast und zur neusten version upgraden möchtest, musst du die folgenden sachen machen, basierend auf wann du den bot aufgesetzt hast. (sortiert neustes zuerst)

- Falls deine repo nicht die `delete-mentions.sql` datei hat, führe es im `postgres` container aus, siehe [FAQ #9](./wiki/faq.md#9-how-do-i-run-the-sql-commands-inside-the-database-containers) for how to do this.
- vor [Guide PR#15](https://github.com/DanPlayz0/ticketsbot-self-host-guide/pull/15), siehe [Common Issue #8](./wiki/common-issues.md#8-error-relation-panel_here_mentions-does-not-exist)
- vor [Guide PR#14](https://github.com/DanPlayz0/ticketsbot-self-host-guide/pull/14), siehe [Common Issue #7](./wiki/common-issues.md#7-error-relation-import_logs-does-not-exist)
- vor [Guide PR#9](https://github.com/DanPlayz0/ticketsbot-self-host-guide/pull/9), siehe [Common Issue #4](./wiki/common-issues.md#4-error-column-last_seen-of-relation-does-not-exist)

<sub>Übersetzung bereitgestelt von [Chaoskjell44](https://linktr.ee/chaoskjell44).</sub>
