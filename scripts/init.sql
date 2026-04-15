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

-- Seed 100 demo transactions so Evidence reports render data on first run.
INSERT INTO transactions (amount, category, flagged, created_at)
SELECT
    round((random() * 9999 + 1)::numeric, 4),
    (ARRAY['food', 'travel', 'electronics', 'clothing', 'utilities'])[floor(random() * 5 + 1)::int],
    random() > 0.8,
    NOW() - interval '1 day' * (random() * 90)::int
FROM generate_series(1, 100)
WHERE NOT EXISTS (SELECT 1 FROM transactions LIMIT 1);
