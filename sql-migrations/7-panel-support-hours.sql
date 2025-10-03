CREATE TABLE IF NOT EXISTS panel_support_hours (
    "id" SERIAL PRIMARY KEY,
    "panel_id" INTEGER NOT NULL,
    "day_of_week" INTEGER NOT NULL CHECK (day_of_week >= 0 AND day_of_week <= 6),
    "start_time" TIME NOT NULL,
    "end_time" TIME NOT NULL,
    "enabled" BOOLEAN NOT NULL DEFAULT true,
    FOREIGN KEY ("panel_id") REFERENCES panels("panel_id") ON DELETE CASCADE,
    UNIQUE("panel_id", "day_of_week")
);

CREATE INDEX IF NOT EXISTS panel_support_hours_panel_id ON panel_support_hours("panel_id");
CREATE INDEX IF NOT EXISTS panel_support_hours_enabled ON panel_support_hours("panel_id", "enabled");