-- Create the n8n schema so n8n's DB_POSTGRESDB_SCHEMA works out of the box
CREATE SCHEMA IF NOT EXISTS n8n;

-- Minimal transactions table used by Evidence fraud-summary reports.
-- Add columns or extend this as your application grows.
CREATE TABLE IF NOT EXISTS transactions (
    id          BIGSERIAL PRIMARY KEY,
    amount      NUMERIC(18, 4)  NOT NULL DEFAULT 0,
    category    TEXT            NOT NULL DEFAULT '',
    flagged     BOOLEAN         NOT NULL DEFAULT FALSE,
    created_at  TIMESTAMPTZ     NOT NULL DEFAULT NOW()
);
