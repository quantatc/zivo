---
title: Case Tracker
---

# Case Tracker

Investigation cases opened from flagged transactions, by status, age, and assignee.

```sql cases_by_status
select
  status,
  count(*) as cases
from zivo_db.investigation_cases
group by status
order by cases desc
```

```sql open_cases_age
select
  id,
  transaction_id,
  status,
  opened_by,
  opened_at,
  age_hours,
  vendor_name,
  transaction_amount,
  policy_violation
from zivo_db.investigation_cases
where status in ('open', 'under_review')
order by age_hours desc
limit 25
```

```sql resolution_time
select
  date_trunc('day', opened_at)::date as opened_day,
  avg(age_hours) as avg_resolution_hours
from zivo_db.investigation_cases
where status in ('resolved', 'dismissed')
  and opened_at >= current_date - interval '30 days'
group by 1
order by 1
```

```sql by_owner
select
  opened_by,
  count(*) filter (where status in ('open','under_review')) as open_cases,
  count(*) filter (where status in ('resolved','dismissed')) as closed_cases,
  count(*) as total
from zivo_db.investigation_cases
group by opened_by
order by total desc
```

## Cases by status

<BarChart
    data={cases_by_status}
    x=status
    y=cases
    title="Investigation cases by status"
    swapXY=true
    emptySet=pass
/>

## Open cases by age

<DataTable data={open_cases_age} search=true rowNumbers=true emptySet=pass>
  <Column id=id title="Case #" />
  <Column id=transaction_id title="TX #" />
  <Column id=status />
  <Column id=opened_by  title="Owner" />
  <Column id=opened_at />
  <Column id=age_hours  title="Age (hrs)" fmt=num1 />
  <Column id=vendor_name title="Vendor" />
  <Column id=transaction_amount title="Amount" fmt=usd0 />
  <Column id=policy_violation title="Reason" />
</DataTable>

## Average time to resolution

<LineChart
    data={resolution_time}
    x=opened_day
    y=avg_resolution_hours
    yAxisTitle="hours"
    title="Average resolution time (last 30 days)"
    emptySet=pass
/>

## By owner

<DataTable data={by_owner} rowNumbers=true emptySet=pass>
  <Column id=opened_by    title="Owner" />
  <Column id=open_cases   title="Open"   fmt=num0 />
  <Column id=closed_cases title="Closed" fmt=num0 />
  <Column id=total        title="Total"  fmt=num0 />
</DataTable>
