select
  snapshot_date,
  revenue,
  expenses,
  (revenue - expenses) as net,
  flagged_count,
  open_cases,
  generated_at
from kpi_snapshots
order by snapshot_date desc
