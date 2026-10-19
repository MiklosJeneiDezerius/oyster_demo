{{ config(materialized='table') }}

with t0 as (select 1 as c union all select 1), 
t1 as (select 1 as c from t0 as a cross join t0 as b), 
t2 as (select 1 as c from t1 as a cross join t1 as b), 
t3 as (select 1 as c from t2 as a cross join t2 as b), 
t4 as (select 1 as c from t3 as a cross join t3 as b), 
numbers as (
    select row_number() over (order by (select null)) - 1 as row_num
    from t4
),
date_spine as (
    select 
        dateadd(day, row_num, cast('2020-01-01' as date)) as date_day
    from numbers
    where dateadd(day, row_num, cast('2020-01-01' as date)) <= cast('2030-12-31' as date)
)
select
    date_day as date_actual,
    cast(format(date_day, 'yyyyMMdd') as integer) as date_key,
    year(date_day) as year_number,
    -- Explicitly cast concatenated text strings to VARCHAR to avoid inferred NVARCHAR output
    cast('CY ' + cast(year(date_day) as varchar(4)) as varchar(10)) as year_name,
    datepart(quarter, date_day) as quarter_number,
    cast('Q' + cast(datepart(quarter, date_day) as varchar(1)) as varchar(5)) as quarter_name,
    month(date_day) as month_number,
    -- CRITICAL FIX: Cast the implicit NVARCHAR returned by FORMAT() to a standard Fabric-supported VARCHAR
    cast(format(date_day, 'MMMM') as varchar(20)) as month_name,
    datepart(week, date_day) as week_of_year,
    case when datepart(dw, date_day) in (1, 7) then 1 else 0 end as is_weekend
from date_spine
