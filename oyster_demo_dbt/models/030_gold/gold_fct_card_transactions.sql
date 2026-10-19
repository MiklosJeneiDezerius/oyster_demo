{{ config(materialized='table') }}
select * from {{ ref('silver_fct_transactions') }}
