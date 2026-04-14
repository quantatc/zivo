---
title: Fraud Summary
---

# Fraud Summary

This page tracks flagged transactions from the shared `transactions` table.

```sql flagged_total
select
  count(*) as flagged_count
from zivo_db.transactions
where flagged = true
```

```sql flagged_by_category
select
  category,
  count(*) as flagged_transactions
from zivo_db.transactions
where flagged = true
group by category
order by flagged_transactions desc, category asc
```

```sql recent_flagged
select
  id,
  amount,
  category,
  flagged,
  created_at
from zivo_db.transactions
where flagged = true
order by created_at desc
limit 20
```

Flagged transactions recorded: <Value data={flagged_total} column=flagged_count fmt=num0 emptySet=pass />

<BarChart
    data={flagged_by_category}
    x=category
    y=flagged_transactions
    title="Flagged Transactions by Category"
    swapXY=true
    emptySet=pass
/>

<DataTable data={recent_flagged} search=true rowNumbers=true emptySet=pass />
