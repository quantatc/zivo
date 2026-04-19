---
title: Atlas Operations
---

# Atlas Operations Dashboard

Live operational view across spend, fraud signals, and open investigations for **Atlas Operations**, the Zivo demo workspace.

```sql kpi_30d
select
  coalesce(sum(revenue), 0)              as revenue_30d,
  coalesce(sum(expenses), 0)             as expenses_30d,
  coalesce(sum(revenue - expenses), 0)   as net_30d,
  coalesce(sum(flagged_count), 0)        as flagged_30d
from zivo_db.kpi_snapshots
where snapshot_date >= current_date - interval '30 days'
```

```sql open_cases_now
select count(*) as open_cases
from zivo_db.investigation_cases
where status in ('open', 'under_review')
```

```sql daily_trend
select
  snapshot_date,
  revenue,
  expenses,
  (revenue - expenses) as net
from zivo_db.kpi_snapshots
where snapshot_date >= current_date - interval '30 days'
order by snapshot_date
```

<BigValue data={kpi_30d} value=revenue_30d title="Revenue (30d)" fmt=usd0 />
<BigValue data={kpi_30d} value=expenses_30d title="Expenses (30d)" fmt=usd0 />
<BigValue data={kpi_30d} value=net_30d title="Net (30d)" fmt=usd0 />
<BigValue data={kpi_30d} value=flagged_30d title="Flagged Transactions (30d)" fmt=num0 />
<BigValue data={open_cases_now} value=open_cases title="Open Investigations" fmt=num0 />

## Revenue vs expenses

<LineChart
    data={daily_trend}
    x=snapshot_date
    y={["revenue","expenses"]}
    yAxisTitle="USD"
    title="Daily revenue vs expenses (last 30 days)"
    emptySet=pass
/>

## Drilldowns

- [Cashflow](./cashflow) — daily revenue vs expense trend, category breakdown, MTD compare
- [Fraud Summary](./fraud-summary) — flagged transactions by category, vendor, recency
- [Vendor Watch](./vendor-watch) — top vendors by spend, watchlist, anomalies
- [Case Tracker](./case-tracker) — open investigations by status & age

_Data refreshed at build time from the shared Postgres instance._
