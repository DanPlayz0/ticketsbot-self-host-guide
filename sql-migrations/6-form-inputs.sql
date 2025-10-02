ALTER TABLE form_input ADD COLUMN type integer default 4;
CREATE TABLE IF NOT EXISTS form_input_option(
    "id" SERIAL NOT NULL UNIQUE,
    "form_input_id" int NOT NULL,
    "position" int NOT NULL,
    "label" VARCHAR(100) NOT NULL,
    "description" VARCHAR(255) NULL,
    "value" VARCHAR(100) NOT NULL,
    FOREIGN KEY("form_input_id") REFERENCES form_input("id") ON DELETE CASCADE,
    UNIQUE("form_input_id", "position") DEFERRABLE INITIALLY DEFERRED,
    CHECK(position >= 1),
    CHECK(position <= 25),
    PRIMARY KEY("id")
);
CREATE INDEX IF NOT EXISTS form_input_option_form_input_id ON form_input_option("form_input_id");