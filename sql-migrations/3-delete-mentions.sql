-- Based off commit: https://github.com/TicketsBot-cloud/database/commit/aabca063df41fd07f6d17ab6f050c352f5cbfe68
ALTER TABLE panels ADD COLUMN delete_mentions bool NOT NULL DEFAULT 'f';