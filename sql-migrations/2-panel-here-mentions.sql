-- Taken from PR https://github.com/TicketsBot-cloud/database/pull/1
-- Direct: https://github.com/TicketsBot-cloud/database/blob/e4915520c1abb12be4893fe01185f1748f57b955/panelmentionhere.go#L22-L27 
CREATE TABLE IF NOT EXISTS panel_here_mentions(
	"panel_id" int NOT NULL,
	"should_mention_here" bool NOT NULL,
	FOREIGN KEY("panel_id") REFERENCES panels("panel_id") ON DELETE CASCADE ON UPDATE CASCADE,
	PRIMARY KEY("panel_id")
);