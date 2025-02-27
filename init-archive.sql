-- Found from https://github.com/TicketsBot/logarchiver/blob/master/migrations/0001-init-schema.sql
CREATE TABLE buckets
(
    "id"           uuid PRIMARY KEY      DEFAULT gen_random_uuid(),
    "endpoint_url" VARCHAR(255) NOT NULL,
    "name"         VARCHAR(255) NOT NULL,
    "active"       BOOLEAN      NOT NULL DEFAULT FALSE
);

CREATE TABLE objects
(
    "guild_id"  int8 NOT NULL,
    "ticket_id" int4 NOT NULL,
    "bucket_id" uuid NOT NULL,
    PRIMARY KEY ("guild_id", "ticket_id"),
    FOREIGN KEY ("bucket_id") REFERENCES "buckets" ("id")
);

CREATE INDEX objects_guid_id_idx ON objects ("guild_id");

-- INSERT INTO buckets (id, endpoint_url, name, active) VALUES ('b77cc1a0-91ec-4d64-bb6d-21717737ea3c', 'https://${S3_ENDPOINT}', '${S3_ARCHIVE_BUCKET}', TRUE);