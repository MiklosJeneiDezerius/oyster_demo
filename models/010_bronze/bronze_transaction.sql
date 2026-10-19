select TransactionID, CardID
, cast(Amount as decimal(18,2)) as Amount, 
cast(Timestamp as datetime2(6)) as transaction_at
, Counterparty, Status 
from {{ source('landing_delta', 'transaction') }}
