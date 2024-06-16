with source_data as (
  select *
  from {{ ref('your_raw_table') }}
)
select *
from source_data
where column_to_filter = 'value_to_filter'
