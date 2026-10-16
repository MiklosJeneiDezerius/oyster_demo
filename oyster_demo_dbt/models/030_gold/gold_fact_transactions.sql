with base_transactions as (
    SELECT 
        CAST([TransactionID] AS VARCHAR(50)) as transaction_id
        ,CAST([CardID] AS VARCHAR(50)) as card_id
        ,CAST([Amount] AS DECIMAL(18,4)) as amount
        ,CAST([Timestamp] AS DATETIME2(6)) as transaction_timestamp -- Fix: Adjusted precision to 6 to match system limits
        ,CAST([Counterparty] AS VARCHAR(255)) as counterparty
        ,CAST([Status] AS VARCHAR(20)) as transaction_status
    FROM {{ source('landing_delta', 'transactions') }}
    WHERE [Status] = 'approved'
),

rolling_spend_calculation as (
    select
        t.transaction_id
        ,t.card_id
        ,t.amount
        ,t.transaction_timestamp
        ,t.counterparty
        ,t.transaction_status
        ,(
            SELECT SUM(sub.amount)
            FROM base_transactions sub
            WHERE sub.card_id = t.card_id
              AND sub.transaction_timestamp <= t.transaction_timestamp
              AND sub.transaction_timestamp >= DATEADD(day, -30, t.transaction_timestamp)
         ) as rolling_30_day_spend
    from base_transactions t
)

select
    {{ dbt_utils.generate_surrogate_key(['r.transaction_id']) }} as transaction_pk
    ,c.card_sk as card_fk 
    ,r.transaction_id
    ,r.amount
    ,r.transaction_timestamp
    ,r.counterparty
    ,r.transaction_status
    ,r.rolling_30_day_spend
    ,case 
        when r.rolling_30_day_spend < 2000 then 'Standard Tier'
        when r.rolling_30_day_spend >= 2000 and r.rolling_30_day_spend <= 5000 then 'Gold Tier'
        else 'Platinum Tier'
     end as computed_spending_tier
from rolling_spend_calculation r
left join {{ ref('gold_dim_cards') }} c 
    on r.card_id = c.card_id
    and r.transaction_timestamp >= c.valid_from 
    and r.transaction_timestamp < c.valid_to
