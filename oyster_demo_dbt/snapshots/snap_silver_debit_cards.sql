{% snapshot snap_silver_debit_cards %}

{{
    config(
      target_schema='dbo',
      unique_key='card_id',
      strategy='check',
      check_cols=['card_tier', 'card_status', 'expiry_date'],
      invalidate_hard_deletes=True
    )
}}

SELECT 
    CAST([CardID] AS VARCHAR(50)) as card_id
    ,CAST([AccountID] AS VARCHAR(50)) as account_id
    ,CAST([CardNumber] AS VARCHAR(50)) as card_number
    ,CAST([Tier] AS VARCHAR(50)) as card_tier
    ,CAST([Status] AS VARCHAR(20)) as card_status
    ,CAST([Expiry] AS VARCHAR(10)) as expiry_date
    ,CAST(IngestedTS AS DATETIME2(6)) as IngestedTS -- Enforced to Fabric spec limits
FROM {{ ref('bronze_cards') }}

{% endsnapshot %}
