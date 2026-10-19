/*
it is possible to denormalize customer and account data into a single view for 
easier analysis because it is one-one-one relation*/
with customers as (select * from {{ ref('bronze_customer') }}),
     accounts as (select * from {{ ref('bronze_account') }})
select c.CustomerID, c.FirstName, c.LastName, c.CustomerType, a.AccountID, a.AccountNumber, a.AccountType as account_type, a.CurrencyCode as currency_code
from customers c left join accounts a on c.CustomerID = a.CustomerID

