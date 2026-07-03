---- Add Additional Settings for Support Hours (https://github.com/TicketsBot-cloud/database/pull/27):
CREATE TABLE IF NOT EXISTS panel_support_hours_settings (
    "panel_id" INTEGER NOT NULL PRIMARY KEY,
    "out_of_hours_behaviour" VARCHAR(50) NOT NULL DEFAULT 'block_creation',
    "out_of_hours_title" VARCHAR(100) NOT NULL DEFAULT 'Support is currently unavailable',
    "out_of_hours_message" TEXT NOT NULL DEFAULT '',
    "out_of_hours_colour" int4 NOT NULL DEFAULT 0,
    FOREIGN KEY ("panel_id") REFERENCES panels("panel_id") ON DELETE CASCADE
);

---- Add cooldown to opening tickets (https://github.com/TicketsBot-cloud/database/pull/28):
ALTER TABLE panels ADD COLUMN "cooldown_seconds" int NOT NULL DEFAULT 0;

---- Per panel ticket limit (https://github.com/TicketsBot-cloud/database/pull/24):
ALTER TABLE panels ADD COLUMN IF NOT EXISTS "ticket_limit" int2 DEFAULT NULL;

---- Ability to hide close / close with reason buttons (https://github.com/TicketsBot-cloud/database/pull/29):
ALTER TABLE settings ADD COLUMN IF NOT EXISTS "hide_close_button" bool DEFAULT 'f';
ALTER TABLE settings ADD COLUMN IF NOT EXISTS "hide_close_with_reason_button" bool DEFAULT 'f';
ALTER TABLE panels ADD COLUMN IF NOT EXISTS "hide_close_button" bool NOT NULL DEFAULT false;
ALTER TABLE panels ADD COLUMN IF NOT EXISTS "hide_close_with_reason_button" bool NOT NULL DEFAULT false;
ALTER TABLE panels ADD COLUMN IF NOT EXISTS "hide_claim_button" bool NOT NULL DEFAULT false;

---- Add support for labels on tickets & transcripts (https://github.com/TicketsBot-cloud/database/pull/31):
-- ticketlabelassignments.go
CREATE TABLE IF NOT EXISTS ticket_label_assignments(
	"guild_id" int8 NOT NULL,
	"ticket_id" int4 NOT NULL,
	"label_id" int4 NOT NULL,
	FOREIGN KEY("guild_id", "ticket_id") REFERENCES tickets("guild_id", "id") ON DELETE CASCADE,
	FOREIGN KEY("guild_id", "label_id") REFERENCES ticket_labels("guild_id", "label_id") ON DELETE CASCADE,
	PRIMARY KEY("guild_id", "ticket_id", "label_id")
);
CREATE INDEX IF NOT EXISTS tkla_guild_ticket_idx ON ticket_label_assignments("guild_id", "ticket_id");
CREATE INDEX IF NOT EXISTS tkla_guild_label_idx ON ticket_label_assignments("guild_id", "label_id");

-- ticketlabels.go
CREATE TABLE IF NOT EXISTS ticket_labels(
	"guild_id" int8 NOT NULL,
	"label_id" SERIAL,
	"name" varchar(32) NOT NULL,
	"colour" int4 NOT NULL DEFAULT 4869178,
	PRIMARY KEY("guild_id", "label_id"),
	UNIQUE("guild_id", "name")
);
CREATE INDEX IF NOT EXISTS ticket_labels_guild_id_idx ON ticket_labels("guild_id");

---- Add owner and real owner to blacklist server (https://github.com/TicketsBot-cloud/database/pull/25):
ALTER TABLE server_blacklist
ADD COLUMN IF NOT EXISTS "owner_id" INT8,
ADD COLUMN IF NOT EXISTS "real_owner_id" int8;

---- Ability to change the close reason (https://github.com/TicketsBot-cloud/database/pull/30):
CREATE TABLE IF NOT EXISTS archive_dm_messages (
    guild_id int8 NOT NULL,
    ticket_id int4 NOT NULL,
    message_id int8 NOT NULL,
    FOREIGN KEY (guild_id, ticket_id) REFERENCES tickets(guild_id, id) ON DELETE CASCADE,
    PRIMARY KEY (guild_id, ticket_id)
);

---- Add team permissions (https://github.com/TicketsBot-cloud/database/pull/):
CREATE TABLE IF NOT EXISTS support_team_permissions(
	"team_id" int NOT NULL,
	"add_reactions" bool NOT NULL DEFAULT 't',
	"send_messages" bool NOT NULL DEFAULT 't',
	"send_tts_messages" bool NOT NULL DEFAULT 't',
	"embed_links" bool NOT NULL DEFAULT 't',
	"attach_files" bool NOT NULL DEFAULT 't',
	"mention_everyone" bool NOT NULL DEFAULT 'f',
	"use_external_emojis" bool NOT NULL DEFAULT 't',
	"use_application_commands" bool NOT NULL DEFAULT 't',
	"use_external_stickers" bool NOT NULL DEFAULT 't',
	"send_voice_messages" bool NOT NULL DEFAULT 't',
	FOREIGN KEY("team_id") REFERENCES support_team("id") ON DELETE CASCADE ON UPDATE CASCADE,
	PRIMARY KEY("team_id")
);

---- Add more ticket permission (https://github.com/TicketsBot-cloud/database/pull/35):
ALTER TABLE ticket_permissions
   ADD COLUMN IF NOT EXISTS "send_voice_messages"   bool NOT NULL DEFAULT 't',
   ADD COLUMN IF NOT EXISTS "send_tts_messages"     bool NOT NULL DEFAULT 't',
   ADD COLUMN IF NOT EXISTS "use_external_emojis"   bool NOT NULL DEFAULT 't',
   ADD COLUMN IF NOT EXISTS "use_external_stickers" bool NOT NULL DEFAULT 't';

CREATE TABLE IF NOT EXISTS panel_ticket_permissions(
	"panel_id" int8 NOT NULL,
	"add_reactions" bool NOT NULL DEFAULT false,
	"send_tts_messages" bool NOT NULL DEFAULT false,
	"embed_links" bool NOT NULL DEFAULT false,
	"attach_files" bool NOT NULL DEFAULT false,
	"use_external_emojis" bool NOT NULL DEFAULT false,
	"use_external_stickers" bool NOT NULL DEFAULT false,
	"send_voice_messages" bool NOT NULL DEFAULT false,
	PRIMARY KEY("panel_id")
);