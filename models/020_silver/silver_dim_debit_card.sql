select
    CardID
    ,[AccountID]
    ,[CardNumber]
    ,[Tier]
    ,[Status]
    ,[Expiry] as ExpiryDate
    ,CAST(GETDATE() AS DATETIME2(6)) as IngestedTS
from {{ ref('bronze_debitcard') }}
