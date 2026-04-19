---
title: Cashflow
---

# Cashflow

Daily revenue vs. expenses across the last 90 days, plus category breakdown and month-over-month compare.

```sql daily_cashflow
select
  snapshot_date,
  revenue,
  expenses,
  (revenue - expenses) as net
from zivo_db.kpi_snapshots
where snapshot_date >= current_date - interval '90 days'
order by snapshot_date
```

```sql category_breakdown_30d
select
  category,
  sum(amount) as spend
from zivo_db.transactions
where created_at >= current_date - interval '30 days'
group by category
order by spend desc
```

```sql mtd_compare
with mtd as (
  select
    coalesce(sum(case when created_at >= date_trunc('month', current_date) then amount else 0 end), 0) as mtd_expenses,
    coalesce(sum(case when created_at >= date_trunc('month', current_date - interval '1 month')
                       and created_at <  date_trunc('month', current_date) then amount else 0 end), 0) as prior_mtd_expenses
  from zivo_db.transactions
)
select
  mtd_expenses,
  prior_mtd_expenses,
  case when prior_mtd_expenses > 0
       then (mtd_expenses - prior_mtd_expenses) / prior_mtd_expenses * 100.0
       else null end as pct_change
from mtd
```

<BigValue data={mtd_compare} value=mtd_expenses        title="MTD Expenses"        fmt=usd0 />
<BigValue data={mtd_compare} value=prior_mtd_expenses  title="Prior MTD Expenses"  fmt=usd0 />
<BigValue data={mtd_compare} value=pct_change          title="MoM Change"          fmt=pct1 />

## Daily revenue vs expenses (90 days)

<LineChart
    data={daily_cashflow}
    x=snapshot_date
    y={["revenue","expenses","net"]}
    yAxisTitle="USD"
    title="Cashflow"
    emptySet=pass
/>

## Spend by category (last 30 days)

<BarChart
    data={category_breakdown_30d}
    x=category
    y=spend
    title="Category spend"
    swapXY=true
    emptySet=pass
/>
