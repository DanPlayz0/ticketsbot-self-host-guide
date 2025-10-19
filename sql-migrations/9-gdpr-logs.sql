-- Related to database update (https://github.com/TicketsBot-cloud/database/commit/7f9567e1aeab85b6510bd9390b9c4b7d60b06114)
CREATE TABLE IF NOT EXISTS gdpr_logs (
	id SERIAL PRIMARY KEY,
	requester VARCHAR(256) NOT NULL,
	request_type VARCHAR(256) NOT NULL,
	request_date TIMESTAMPTZ NOT NULL DEFAULT NOW(),
	status TEXT NOT NULL
);