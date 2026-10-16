SELECT 
    {{ dbt_utils.generate_surrogate_key(['card_id', 'dbt_valid_from']) }} as card_sk -- Fix: Explicitly prepend dbt_utils.
    ,card_id
    ,account_id
    ,card_number
    ,card_tier
    ,card_status
    ,expiry_date
    ,dbt_valid_from as valid_from
    ,coalesce(dbt_valid_to, CAST('9999-12-31' AS DATETIME2(6))) as valid_to
    ,case when dbt_valid_to is null then 1 else 0 end as is_current
FROM {{ ref('snap_silver_debit_cards') }}
