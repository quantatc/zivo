select
  ic.id,
  ic.transaction_id,
  ic.status,
  ic.opened_at,
  ic.resolved_at,
  ic.opened_by,
  ic.notes,
  t.amount as transaction_amount,
  t.category as transaction_category,
  t.policy_violation,
  v.name as vendor_name,
  case
    when ic.resolved_at is not null
      then extract(epoch from (ic.resolved_at - ic.opened_at)) / 3600.0
    else extract(epoch from (now() - ic.opened_at)) / 3600.0
  end as age_hours
from investigation_cases ic
left join transactions t on t.id = ic.transaction_id
left join vendors v      on v.id = t.vendor_id
order by ic.opened_at desc
