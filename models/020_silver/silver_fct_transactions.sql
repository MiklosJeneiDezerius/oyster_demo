{{ config(
    materialized='table'
) }}

with silver_transactions as (
    select 
        TransactionID as transaction_id, 
        CardID as card_id,
        cast(Amount as decimal(18,2)) as transaction_amount, 
        cast(Timestamp as datetime2(6)) as transaction_at, --todo I need a load timestamp 
        Counterparty as counterparty, 
        Status as transaction_status
    from {{ source('landing_delta', 'transaction') }}
),

-- Reference your cleaned Silver Dimension for Debit Cards
dim_debitcard as (
    select 
        CardID as card_id,
        AccountID as account_id
    from {{ ref('silver_dim_debit_card') }}
),

-- Reference your denormalized Silver Dimension for Customer & Account
dim_customer_account as (
    select 
        AccountID as account_id,
        CustomerID as customer_id
    from {{ ref('silver_dim_customer') }}
),

-- Reference your Date Spine Dimension
dim_date as (
    select 
        date_actual,
        date_key as transaction_date_key
    from {{ ref('silver_dim_date') }}
)

select
    -- Primary Key
    t.transaction_id,

    -- Dimensional & Foreign Keys
    t.card_id,
    dc.account_id,
    ca.customer_id,
    d.transaction_date_key,

    -- Attributes / Degenerate Dimensions
    t.counterparty,
    t.transaction_status,

    -- Measures & Timestamps
    t.transaction_amount,
    t.transaction_at,
    cast(getdate() as datetime2(6)) as loaded_at

from silver_transactions t
left join dim_debitcard dc 
    on t.card_id = dc.card_id
left join dim_customer_account ca 
    on dc.account_id = ca.account_id
left join dim_date d 
    on cast(t.transaction_at as date) = d.date_actual
