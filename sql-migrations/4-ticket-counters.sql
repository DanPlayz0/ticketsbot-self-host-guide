-- Related to database update (https://github.com/TicketsBot-cloud/database/commit/5bc8d5b0265016530c666360a1a171b8e4e3208f)
-- Table creation
CREATE TABLE guild_ticket_counters (
    guild_id bigint PRIMARY KEY,
    last_ticket_id integer NOT NULL DEFAULT 0
);

-- Create records for existing setups
INSERT INTO guild_ticket_counters (guild_id, last_ticket_id)
SELECT guild_id, COALESCE(MAX(id), 0) as last_ticket_id
FROM tickets
GROUP BY guild_id;