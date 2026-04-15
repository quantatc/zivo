select
  id,
  amount,
  category,
  flagged,
  created_at
from transactions
order by created_at desc
