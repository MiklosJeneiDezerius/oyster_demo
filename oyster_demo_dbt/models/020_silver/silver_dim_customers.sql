SELECT 
    {{ dbt_utils.generate_surrogate_key(['CustomerID']) }} as customer_sk -- Fix: Explicitly prepend dbt_utils.
    ,CAST([CustomerID] AS VARCHAR(50)) as customer_id
    ,CAST([FirstName] AS VARCHAR(100)) as first_name
    ,CAST([LastName] AS VARCHAR(100)) as last_name
    ,CAST([TaxID] AS VARCHAR(20)) as tax_id 
    ,CAST([CustomerType] AS VARCHAR(50)) as customer_type
    ,CAST([DoB] AS DATE) as date_of_birth
FROM {{ ref('bronze_customers') }}
