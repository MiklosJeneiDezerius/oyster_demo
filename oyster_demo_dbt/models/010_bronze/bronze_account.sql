select AccountID, CustomerID, AccountNumber, 
Type as AccountType, cast(Balance as decimal(18,2)) as current_balance, Currency as CurrencyCode 
from {{ source('landing_delta', 'account') }}
