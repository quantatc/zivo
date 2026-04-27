-- =============================================================================
-- Atlas Operations demo seed
-- Loaded after init.sql by Postgres' /docker-entrypoint-initdb.d/ init runner.
-- Idempotent: safe to re-apply against an existing database.
--
-- Postgres only runs init scripts on a fresh data directory. To apply this
-- file to an already-initialized database (e.g., production), use:
--   docker compose exec postgres psql -U $POSTGRES_USER -d $POSTGRES_DB \
--     -f /docker-entrypoint-initdb.d/seed_atlas.sql
-- =============================================================================

-- ---------- Vendors ----------------------------------------------------------
CREATE TABLE IF NOT EXISTS vendors (
    id            BIGSERIAL PRIMARY KEY,
    name          TEXT NOT NULL UNIQUE,
    category      TEXT NOT NULL,
    contact_email TEXT,
    on_watchlist  BOOLEAN NOT NULL DEFAULT FALSE,
    created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ---------- Customers --------------------------------------------------------
CREATE TABLE IF NOT EXISTS customers (
    id         BIGSERIAL PRIMARY KEY,
    name       TEXT NOT NULL UNIQUE,
    segment    TEXT NOT NULL,
    mrr        NUMERIC(18, 4) NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ---------- Extend the existing transactions table --------------------------
-- The base table comes from init.sql. We add Atlas-specific columns here.
ALTER TABLE transactions ADD COLUMN IF NOT EXISTS vendor_id        BIGINT REFERENCES vendors(id);
ALTER TABLE transactions ADD COLUMN IF NOT EXISTS customer_id      BIGINT REFERENCES customers(id);
ALTER TABLE transactions ADD COLUMN IF NOT EXISTS description      TEXT;
ALTER TABLE transactions ADD COLUMN IF NOT EXISTS policy_violation TEXT;
ALTER TABLE transactions ADD COLUMN IF NOT EXISTS reviewed_by      TEXT;
ALTER TABLE transactions ADD COLUMN IF NOT EXISTS review_note      TEXT;

CREATE INDEX IF NOT EXISTS idx_transactions_created_at ON transactions(created_at);
CREATE INDEX IF NOT EXISTS idx_transactions_flagged    ON transactions(flagged) WHERE flagged = TRUE;
CREATE INDEX IF NOT EXISTS idx_transactions_vendor     ON transactions(vendor_id);
CREATE INDEX IF NOT EXISTS idx_transactions_customer   ON transactions(customer_id);

-- ---------- Investigation cases ---------------------------------------------
CREATE TABLE IF NOT EXISTS investigation_cases (
    id             BIGSERIAL PRIMARY KEY,
    transaction_id BIGINT NOT NULL REFERENCES transactions(id) ON DELETE CASCADE,
    status         TEXT NOT NULL DEFAULT 'open'
                    CHECK (status IN ('open', 'under_review', 'resolved', 'dismissed')),
    opened_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    resolved_at    TIMESTAMPTZ,
    opened_by      TEXT NOT NULL DEFAULT 'system',
    notes          TEXT
);

CREATE INDEX IF NOT EXISTS idx_cases_status   ON investigation_cases(status);
CREATE INDEX IF NOT EXISTS idx_cases_opened   ON investigation_cases(opened_at);

-- ---------- KPI snapshots (daily) -------------------------------------------
CREATE TABLE IF NOT EXISTS kpi_snapshots (
    snapshot_date  DATE PRIMARY KEY,
    revenue        NUMERIC(18, 4) NOT NULL DEFAULT 0,
    expenses       NUMERIC(18, 4) NOT NULL DEFAULT 0,
    flagged_count  INTEGER NOT NULL DEFAULT 0,
    open_cases     INTEGER NOT NULL DEFAULT 0,
    generated_at   TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- =============================================================================
-- Seed data
-- All seed steps gated on "table is empty" so the file is idempotent.
-- =============================================================================

-- ---------- Seed vendors -----------------------------------------------------
INSERT INTO vendors (name, category, contact_email, on_watchlist)
SELECT v.name, v.category, v.email, v.watch
FROM (VALUES
    ('Acme Office Supplies',     'office_supplies', 'ap@acmeoffice.example',    FALSE),
    ('CloudForge',               'software_saas',   'billing@cloudforge.example', FALSE),
    ('Bluepine Travel',          'travel',          'invoices@bluepine.example', FALSE),
    ('Atlas Catering',           'meals',           'orders@atlascatering.example', FALSE),
    ('PowerNet Utilities',       'utilities',       'ar@powernet.example',      TRUE),
    ('Nova Consulting Group',    'consulting',      'pm@novaconsult.example',   FALSE),
    ('Pulse Digital Marketing',  'marketing',       'ar@pulsedigital.example',  FALSE),
    ('Ironclad Equipment',       'equipment',       'sales@ironclad.example',   FALSE),
    ('SwiftShip Logistics',      'shipping',        'ap@swiftship.example',     FALSE),
    ('Skyline Fuel Co',          'fuel',            'fleet@skylinefuel.example', FALSE),
    ('PrintPro Services',        'office_supplies', 'invoice@printpro.example', FALSE),
    ('DevTools Hub',             'software_saas',   'billing@devtoolshub.example', FALSE),
    ('Cascade Hotels',           'travel',          'corp@cascadehotels.example', FALSE),
    ('Greenbrier Coffee',        'meals',           'wholesale@greenbrier.example', FALSE),
    ('Metro Power Co-op',        'utilities',       'service@metropower.example', FALSE),
    ('Apex Strategy Partners',   'consulting',      'invoices@apexstrategy.example', FALSE),
    ('Northwind Ad Agency',      'marketing',       'ar@northwindads.example',  TRUE),
    ('Stellar Hardware Supply',  'equipment',       'sales@stellarhw.example',  FALSE),
    ('Quickfreight Express',     'shipping',        'billing@quickfreight.example', FALSE),
    ('Riverstone Energy',        'fuel',            'fleet@riverstone.example', FALSE),
    ('PaperTrail Inc',           'office_supplies', 'ap@papertrail.example',    FALSE),
    ('ZenithOps Software',       'software_saas',   'finance@zenithops.example', FALSE),
    ('Lakeside Conferences',     'travel',          'events@lakeside.example',  FALSE),
    ('Bistro Ventures',          'meals',           'catering@bistroventures.example', TRUE),
    ('Silvermark Consulting',    'consulting',      'invoices@silvermark.example', FALSE)
) AS v(name, category, email, watch)
WHERE NOT EXISTS (SELECT 1 FROM vendors LIMIT 1);

-- ---------- Seed customers ---------------------------------------------------
INSERT INTO customers (name, segment, mrr)
SELECT
    'Customer ' || lpad(g::text, 3, '0') || ' - ' ||
        (ARRAY['Holdings','Group','Labs','Industries','Partners','Studios','Solutions','Systems','Ventures','Works'])[1 + ((g * 7) % 10)],
    (ARRAY['SMB','Mid-Market','Enterprise'])[1 + (g % 3)],
    CASE (g % 3)
        WHEN 0 THEN round((1500 + (g * 37) % 3500)::numeric, 2)     -- SMB
        WHEN 1 THEN round((6000 + (g * 53) % 14000)::numeric, 2)    -- Mid-Market
        ELSE         round((25000 + (g * 91) % 60000)::numeric, 2)  -- Enterprise
    END
FROM generate_series(1, 50) AS g
WHERE NOT EXISTS (SELECT 1 FROM customers LIMIT 1);

-- ---------- Reseed transactions for the demo --------------------------------
-- The base init.sql inserts 100 random rows with NULL Atlas columns. For a
-- coherent demo we wipe and reseed once Atlas tables are in place.
DO $$
DECLARE
    needs_reseed BOOLEAN;
BEGIN
    SELECT
        EXISTS (SELECT 1 FROM transactions WHERE vendor_id IS NULL LIMIT 1)
        OR (SELECT count(*) FROM transactions) < 1500
        OR COALESCE((SELECT max(snapshot_date) < CURRENT_DATE FROM kpi_snapshots), TRUE)
    INTO needs_reseed;

    IF needs_reseed THEN
        TRUNCATE transactions, investigation_cases, kpi_snapshots RESTART IDENTITY CASCADE;

        PERFORM setseed(0.42);

        INSERT INTO transactions (
            amount, category, flagged, created_at,
            vendor_id, customer_id, description, policy_violation
        )
        SELECT
            t.amount,
            v.category,
            t.flagged,
            t.created_at,
            v.id,
            c.id,
            CASE
                WHEN v.category = 'software_saas' THEN 'Monthly subscription - ' || v.name
                WHEN v.category = 'travel'        THEN 'Business travel booking - ' || v.name
                WHEN v.category = 'meals'         THEN 'Team meal / catering - ' || v.name
                WHEN v.category = 'utilities'     THEN 'Utility service charge - ' || v.name
                WHEN v.category = 'consulting'    THEN 'Professional services - ' || v.name
                WHEN v.category = 'marketing'     THEN 'Campaign spend - ' || v.name
                WHEN v.category = 'equipment'     THEN 'Equipment purchase - ' || v.name
                WHEN v.category = 'shipping'      THEN 'Freight / shipping - ' || v.name
                WHEN v.category = 'fuel'          THEN 'Fleet fuel - ' || v.name
                ELSE 'Office supplies - ' || v.name
            END,
            CASE
                WHEN t.flagged AND (t.amount > 4000) THEN 'amount_exceeds_threshold'
                WHEN t.flagged AND v.on_watchlist     THEN 'vendor_on_watchlist'
                WHEN t.flagged                         THEN 'unusual_pattern'
                ELSE NULL
            END
        FROM (
            SELECT
                round((random() * 4900 + 50)::numeric, 2) AS amount,
                random() > 0.88                            AS flagged,
                NOW() - (interval '1 day' * (random() * 90)::int)
                      - (interval '1 hour' * (random() * 23)::int) AS created_at,
                1 + (floor(random() * 25))::int            AS vendor_idx,
                1 + (floor(random() * 50))::int            AS customer_idx
            FROM generate_series(1, 2000)
        ) t
        JOIN vendors   v ON v.id = t.vendor_idx
        JOIN customers c ON c.id = t.customer_idx;

        -- Seed investigation cases for a sample of flagged transactions
        INSERT INTO investigation_cases (transaction_id, status, opened_at, resolved_at, opened_by, notes)
        SELECT
            tx.id,
            (ARRAY['open','under_review','resolved','dismissed'])[1 + ((tx.id * 7) % 4)],
            tx.created_at + interval '1 hour',
            CASE WHEN ((tx.id * 7) % 4) >= 2
                 THEN tx.created_at + interval '2 days'
                 ELSE NULL END,
            (ARRAY['maya.chen','priya.patel','sam.ortiz','system'])[1 + ((tx.id * 3) % 4)],
            'Auto-opened by fraud-policy-check workflow. Reason: ' ||
                COALESCE(tx.policy_violation, 'unspecified')
        FROM transactions tx
        WHERE tx.flagged
        ORDER BY tx.id
        LIMIT 30;

        -- Seed daily KPI snapshots derived from transactions
        INSERT INTO kpi_snapshots (snapshot_date, revenue, expenses, flagged_count, open_cases)
        SELECT
            d::date AS snapshot_date,
            -- Synthetic revenue: ~$8k-$22k/day with a slight upward trend
            round((8000 + (random() * 14000) + (extract(day FROM (d - (NOW() - interval '90 days'))) * 30))::numeric, 2),
            COALESCE(SUM(tx.amount), 0),
            COALESCE(SUM(CASE WHEN tx.flagged THEN 1 ELSE 0 END), 0),
            COALESCE((
                SELECT count(*) FROM investigation_cases ic
                WHERE ic.opened_at::date <= d::date
                  AND (ic.resolved_at IS NULL OR ic.resolved_at::date > d::date)
            ), 0)
        FROM generate_series(
            (NOW() - interval '90 days')::date,
            NOW()::date,
            interval '1 day'
        ) AS d
        LEFT JOIN transactions tx ON tx.created_at::date = d::date
        GROUP BY d;
    END IF;
END $$;
