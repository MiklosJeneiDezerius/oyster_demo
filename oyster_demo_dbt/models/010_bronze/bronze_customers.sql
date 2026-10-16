SELECT 
    [CustomerID]
    ,[Name]
    ,[TaxID]
    ,[CustomerType]
    ,[FirstName]
    ,[LastName]
    ,[DoB]
    ,CAST(GETDATE() AS DATETIME2(6)) as IngestedTS -- Fix: Explicitly set precision to 6
FROM {{ source('landing_delta', 'customers') }}

