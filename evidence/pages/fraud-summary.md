---
title: Fraud Summary
---

# Fraud Summary

Flagged transactions for Atlas Operations, joined against vendors and open investigations.

```sql flagged_total
select count(*) as flagged_count
from zivo_db.transactions
where flagged = true
```

```sql flagged_30d
select count(*) as flagged_count
from zivo_db.transactions
where flagged = true
  and created_at >= current_date - interval '30 days'
```

```sql flagged_by_category
select
  category,
  count(*) as flagged_transactions,
  sum(amount) as flagged_amount
from zivo_db.transactions
where flagged = true
group by category
order by flagged_transactions desc, category asc
```

```sql flagged_trend
select
  date_trunc('day', created_at)::date as day,
  count(*) as flagged_transactions
from zivo_db.transactions
where flagged = true
  and created_at >= current_date - interval '30 days'
group by 1
order by 1
```

```sql top_flagged_vendors
select
  v.name as vendor_name,
  v.category,
  v.on_watchlist,
  count(*) as flagged_transactions,
  sum(t.amount) as flagged_amount
from zivo_db.transactions t
join zivo_db.vendors v on v.id = t.vendor_id
where t.flagged = true
group by 1, 2, 3
order by flagged_transactions desc
limit 10
```

```sql recent_flagged
select
  t.id,
  t.created_at,
  t.amount,
  t.category,
  v.name as vendor_name,
  t.policy_violation,
  case when ic.id is not null then ic.status else null end as case_status
from zivo_db.transactions t
left join zivo_db.vendors v on v.id = t.vendor_id
left join zivo_db.investigation_cases ic on ic.transaction_id = t.id
where t.flagged = true
order by t.created_at desc
limit 25
```

<BigValue data={flagged_total} value=flagged_count title="Flagged (all-time)" fmt=num0 />
<BigValue data={flagged_30d}   value=flagged_count title="Flagged (last 30d)" fmt=num0 />

## Trend

<LineChart
    data={flagged_trend}
    x=day
    y=flagged_transactions
    title="Flagged transactions per day (last 30 days)"
    emptySet=pass
/>

## By category

<BarChart
    data={flagged_by_category}
    x=category
    y=flagged_transactions
    title="Flagged transactions by category"
    swapXY=true
    emptySet=pass
/>

## Top flagged vendors

<DataTable data={top_flagged_vendors} rowNumbers=true emptySet=pass>
  <Column id=vendor_name />
  <Column id=category />
  <Column id=on_watchlist title="Watchlist" />
  <Column id=flagged_transactions title="Flagged" fmt=num0 />
  <Column id=flagged_amount      title="Amount"  fmt=usd0 />
</DataTable>

## Recent flagged transactions

<DataTable data={recent_flagged} search=true rowNumbers=true emptySet=pass />
