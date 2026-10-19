{{ config(materialized='table') }}

with customer_info as (
    select * from {{ ref('gold_dim_customers') }}
), 
      metrics as (
    select 
        account_id, 
        count(transaction_id) as total_approved_tx, 
        sum(cast(transaction_amount as decimal(18,2))) as total_spent_amount
    from {{ ref('gold_fct_card_transactions') }}
    where transaction_status = 'Approved'
    group by account_id 
)

select 
    -- FIXED: Changed from customer_id to CustomerID
    c.CustomerID, 
    c.FirstName + ' ' + c.LastName as full_name, 
    -- FIXED: Changed from customer_type to CustomerType
    c.CustomerType, 
    -- FIXED: Changed from account_number to AccountNumber
    c.AccountNumber, 
    coalesce(m.total_approved_tx, 0) as total_transactions, 
    coalesce(m.total_spent_amount, 0.00) as total_spent
from customer_info c 
-- Match the exact casing from gold_dim_customers
left join metrics m on c.AccountID = m.account_id
