---- Multi-Panel POSITION FIELDS (https://github.com/TicketsBot-cloud/database/pull/13):
-- Add position column if it doesn't exist
ALTER TABLE multi_panel_targets
ADD COLUMN IF NOT EXISTS position int NOT NULL DEFAULT 0;

-- Update existing records to set position based on panel_id order
-- This is a best-effort ordering for existing data
WITH ranked_panels AS (
    SELECT
        multi_panel_id,
        panel_id,
        ROW_NUMBER() OVER (PARTITION BY multi_panel_id ORDER BY panel_id) - 1 AS new_position
    FROM multi_panel_targets
)
UPDATE multi_panel_targets
SET position = ranked_panels.new_position
FROM ranked_panels
WHERE multi_panel_targets.multi_panel_id = ranked_panels.multi_panel_id
  AND multi_panel_targets.panel_id = ranked_panels.panel_id
  AND multi_panel_targets.position <> ranked_panels.new_position;

-- Add unique constraint to ensure each position is unique within a multi-panel
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE conname = 'multi_panel_targets_multi_panel_id_position_key'
    ) THEN
        ALTER TABLE multi_panel_targets
        ADD CONSTRAINT multi_panel_targets_multi_panel_id_position_key
        UNIQUE (multi_panel_id, position);
    END IF;
END $$;

---- PANEL TICKET NOTIFICATION CHANNEL (https://github.com/TicketsBot-cloud/database/pull/17):
ALTER TABLE panels ADD COLUMN IF NOT EXISTS ticket_notification_channel int8 DEFAULT NULL;

---- PANEL CUSTOMIZATION (https://github.com/TicketsBot-cloud/database/pull/15):
ALTER TABLE multi_panel_targets
    ADD COLUMN IF NOT EXISTS custom_label VARCHAR(80) NULL,
    ADD COLUMN IF NOT EXISTS description VARCHAR(100) NULL,
    ADD COLUMN IF NOT EXISTS custom_emoji_name VARCHAR(32) NULL,
    ADD COLUMN IF NOT EXISTS custom_emoji_id int8 NULL;

---- CLAIMER SWITCH BEHAVIOR (https://github.com/TicketsBot-cloud/database/pull/22):
ALTER TABLE claim_settings ADD COLUMN IF NOT EXISTS "switch_panel_claim_behavior" int2 NOT NULL DEFAULT 0;

---- AUDIT LOGS (https://github.com/TicketsBot-cloud/database/pull/26): 
CREATE TABLE IF NOT EXISTS audit_logs (
    "id"            BIGSERIAL       PRIMARY KEY,
    "guild_id"      INT8            DEFAULT NULL,
    "user_id"       INT8            NOT NULL,
    "action_type"   INT2            NOT NULL,
    "resource_type" INT2            NOT NULL,
    "resource_id"   TEXT            DEFAULT NULL,
    "old_data"      JSONB           DEFAULT NULL,
    "new_data"      JSONB           DEFAULT NULL,
    "metadata"      JSONB           DEFAULT NULL,
    "created_at"    TIMESTAMPTZ     NOT NULL DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS audit_logs_guild_id_created_at_idx ON audit_logs("guild_id", "created_at" DESC);
CREATE INDEX IF NOT EXISTS audit_logs_user_id_idx ON audit_logs("user_id");
CREATE INDEX IF NOT EXISTS audit_logs_action_type_idx ON audit_logs("action_type");
CREATE INDEX IF NOT EXISTS audit_logs_resource_type_idx ON audit_logs("resource_type");
CREATE INDEX IF NOT EXISTS audit_logs_created_at_idx ON audit_logs("created_at" DESC);