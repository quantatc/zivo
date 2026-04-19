---
title: Vendor Watch
---

# Vendor Watch

Top vendors by 30-day spend, watchlist status, and recent flag activity.

```sql top_vendors_30d
select
  v.id,
  v.name,
  v.category,
  v.on_watchlist,
  count(t.id) as transactions,
  sum(t.amount) as spend_30d,
  sum(case when t.flagged then 1 else 0 end) as flagged_count
from zivo_db.vendors v
left join zivo_db.transactions t
  on t.vendor_id = v.id
 and t.created_at >= current_date - interval '30 days'
group by v.id, v.name, v.category, v.on_watchlist
having count(t.id) > 0
order by spend_30d desc
limit 15
```

```sql watchlist
select
  v.name,
  v.category,
  count(t.id) filter (where t.created_at >= current_date - interval '30 days') as transactions_30d,
  sum(t.amount) filter (where t.created_at >= current_date - interval '30 days') as spend_30d,
  sum(case when t.flagged and t.created_at >= current_date - interval '30 days' then 1 else 0 end) as flagged_30d
from zivo_db.vendors v
left join zivo_db.transactions t on t.vendor_id = v.id
where v.on_watchlist = true
group by v.id, v.name, v.category
order by flagged_30d desc, spend_30d desc
```

```sql vendor_anomalies
with vendor_avg as (
  select
    vendor_id,
    avg(amount) as avg_amount,
    stddev(amount) as std_amount
  from zivo_db.transactions
  where created_at >= current_date - interval '90 days'
  group by vendor_id
)
select
  t.id,
  t.created_at,
  v.name as vendor_name,
  t.amount,
  va.avg_amount,
  case when va.std_amount > 0
       then (t.amount - va.avg_amount) / va.std_amount
       else 0 end as z_score
from zivo_db.transactions t
join zivo_db.vendors v on v.id = t.vendor_id
join vendor_avg va on va.vendor_id = t.vendor_id
where t.created_at >= current_date - interval '14 days'
  and va.std_amount > 0
  and abs((t.amount - va.avg_amount) / va.std_amount) > 2.0
order by abs((t.amount - va.avg_amount) / va.std_amount) desc
limit 20
```

## Top vendors (last 30 days)

<DataTable data={top_vendors_30d} rowNumbers=true emptySet=pass>
  <Column id=name title="Vendor" />
  <Column id=category />
  <Column id=on_watchlist title="Watchlist" />
  <Column id=transactions  title="Txns"   fmt=num0 />
  <Column id=spend_30d     title="Spend"  fmt=usd0 />
  <Column id=flagged_count title="Flagged" fmt=num0 />
</DataTable>

## Vendors on watchlist

<DataTable data={watchlist} rowNumbers=true emptySet=pass>
  <Column id=name title="Vendor" />
  <Column id=category />
  <Column id=transactions_30d title="Txns (30d)" fmt=num0 />
  <Column id=spend_30d        title="Spend (30d)" fmt=usd0 />
  <Column id=flagged_30d      title="Flagged (30d)" fmt=num0 />
</DataTable>

## Recent anomalies (|z-score| > 2)

<DataTable data={vendor_anomalies} search=true rowNumbers=true emptySet=pass>
  <Column id=id title="TX#" />
  <Column id=created_at />
  <Column id=vendor_name title="Vendor" />
  <Column id=amount    fmt=usd0 />
  <Column id=avg_amount title="Vendor Avg" fmt=usd0 />
  <Column id=z_score    fmt=num1 />
</DataTable>
