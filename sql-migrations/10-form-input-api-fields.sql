-- https://github.com/TicketsBot-cloud/database/blob/1c1920978196ded46d4f6c59e3f62547ea8f0bbe/forminputapiconfig.go#L34-L47
CREATE TABLE IF NOT EXISTS form_input_api_config(
  "id" SERIAL NOT NULL UNIQUE,
  "form_input_id" INT NOT NULL UNIQUE,
  "endpoint_url" VARCHAR(500) NOT NULL,
  "method" VARCHAR(10) NOT NULL DEFAULT 'GET',
  "cache_duration_seconds" INT DEFAULT 300,
  "created_at" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  "updated_at" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY("form_input_id") REFERENCES form_input("id") ON DELETE CASCADE,
  CHECK(method IN ('GET', 'POST', 'PUT', 'PATCH', 'DELETE')),
  CHECK(cache_duration_seconds >= 0),
  PRIMARY KEY("id")
);
CREATE INDEX IF NOT EXISTS form_input_api_config_form_input_id ON form_input_api_config("form_input_id");

-- https://github.com/TicketsBot-cloud/database/blob/1c1920978196ded46d4f6c59e3f62547ea8f0bbe/forminputapiheaders.go#L31-L41
CREATE TABLE IF NOT EXISTS form_input_api_headers(
  "id" SERIAL NOT NULL UNIQUE,
  "api_config_id" INT NOT NULL,
  "header_name" VARCHAR(255) NOT NULL,
  "header_value" TEXT NOT NULL,
  "is_secret" BOOLEAN DEFAULT FALSE,
  FOREIGN KEY("api_config_id") REFERENCES form_input_api_config("id") ON DELETE CASCADE,
  UNIQUE("api_config_id", "header_name"),
  PRIMARY KEY("id")
);
CREATE INDEX IF NOT EXISTS form_input_api_headers_api_config_id ON form_input_api_headers("api_config_id");