select
  t.id,
  t.amount,
  t.category,
  t.flagged,
  t.created_at,
  t.vendor_id,
  t.customer_id,
  t.description,
  t.policy_violation,
  t.reviewed_by,
  t.review_note,
  v.name as vendor_name,
  v.on_watchlist as vendor_on_watchlist,
  c.name as customer_name,
  c.segment as customer_segment
from transactions t
left join vendors  v on v.id = t.vendor_id
left join customers c on c.id = t.customer_id
order by t.created_at desc
