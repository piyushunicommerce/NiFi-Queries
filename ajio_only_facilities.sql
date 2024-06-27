-- select y.tenant, count(y.facility_name) as only_ajio_orders_facility_count,string_agg(y.facility_name,',') as only_ajio_orders_facility_name from (SELECT x.tenant,
--       x.facility_name,
--       string_agg(x.channel_source_code, ',')
-- FROM
--   (SELECT td.tenant,
--           sum(td.sale_order_item_count) soi_count,
--           td.facility_name,
--           td.channel_source_code
--   FROM transaction__daily_v2 AS td
--   JOIN tenant_info ti ON ti.tenant = td.tenant
--   WHERE td.sale_order_created_date > now() - interval '5 day'
--      AND ti.product_code = 'ENTERPRISE'
--   GROUP BY td.facility_name,
--             td.channel_source_code,
--             td.tenant) as x
-- GROUP BY x.tenant,
--          x.facility_name) AS y where y.string_agg in ('AJIO','AJIO_B2B','AJIO,AJIO_B2B','AJIO_B2B,AJIO') group by y.tenant;
         
         
WITH start_date as (select  date(date_trunc('month',now() - interval '30 day'))),
end_date as (select  date(date_trunc('month',now() + interval '3 day')))

select
  y.tenant,
  count(y.facility_name) as only_ajio_orders_facility_count,
  string_agg(y.facility_name, ',') as only_ajio_orders_facility_name
from
      (SELECT
          td.tenant,
          td.facility_name,
          string_agg(distinct td.channel_source_code,',')
        FROM
          transaction__daily_v2 AS td
          JOIN tenant_info ti ON ti.tenant = td.tenant
        WHERE
          td.sale_order_created_date >= (select * from start_date)
          and td.sale_order_created_date <  (select * from end_date)
          AND ti.product_code = 'ENTERPRISE'
        GROUP BY
          td.facility_name,
          td.tenant) y 
where
  y.string_agg in (
    'AJIO',
    'AJIO_B2B',
    'AJIO,AJIO_B2B',
    'AJIO_B2B,AJIO'
  )
group by
  y.tenant;