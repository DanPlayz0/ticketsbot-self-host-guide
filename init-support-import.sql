-- Below copied from https://github.com/TicketsBot-cloud/database/blob/master/sql/import_logs/schema.sql
CREATE TABLE IF NOT EXISTS import_logs (
    guild_id BIGINT NOT NULL,
    log_type VARCHAR(255) NOT NULL,
    run_type VARCHAR(255) NOT NULL DEFAULT 'DATA',
    run_id INT NOT NULL,
    run_log_id INT NOT NULL,
    entity_type VARCHAR(255),
    message VARCHAR(255),
    date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (guild_id, run_id, run_log_id) -- Ensures uniqueness per (guild_id, run_id)
);

CREATE OR REPLACE FUNCTION set_run_log_id()
RETURNS TRIGGER AS $$
BEGIN
    -- Get the next run_log_id for the (guild_id, run_id) pair
    SELECT COALESCE(MAX(run_log_id), 0) + 1 INTO NEW.run_log_id
    FROM import_logs
    WHERE guild_id = NEW.guild_id AND run_id = NEW.run_id;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER before_insert_import_logs
BEFORE INSERT ON import_logs
FOR EACH ROW
WHEN (NEW.run_log_id IS NULL)
EXECUTE FUNCTION set_run_log_id();

-- Below copied from https://github.com/TicketsBot-cloud/database/blob/master/sql/import_mapping/schema.sql
CREATE TYPE mapping_area AS ENUM ('ticket', 'form', 'form_input', 'panel');

CREATE TABLE IF NOT EXISTS import_mapping
(
    guild_id   int8 NOT NULL,
    area mapping_area NOT NULL,
    source_id int4 NOT NULL,
    target_id int4 NOT NULL,
    UNIQUE NULLS NOT DISTINCT (guild_id, area, source_id, target_id)
);