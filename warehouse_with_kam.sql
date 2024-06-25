SELECT ifnull(am.AM,'XYZ') AS KAM,
       p.tenant AS tenant,
       p.month AS MONTH,
       p.year YEAR,
              coalesce(p.active_stores,0) active_stores,
              coalesce(p.active_dropship_panel,0) active_dropship_panels,
              coalesce(p.active_vendor_panel,0) active_vendor_panels,
              CASE
                  WHEN (coalesce(p.active_facility,0) - coalesce(p.active_vendor_panel,0) - coalesce(p.active_dropship_panel,0)- coalesce(p.active_stores,0) - coalesce(p.FBC_active_facility_channel_logic,0) - coalesce(p.only_ajio_orders_facility_count,0) - coalesce(p.srf_active_facility_count,0))  <= 0 THEN 1 else (coalesce(p.active_facility,0) - coalesce(p.active_vendor_panel,0) - coalesce(p.active_dropship_panel,0) - coalesce(p.active_stores,0) - coalesce(p.FBC_active_facility_channel_logic,0) - coalesce(p.only_ajio_orders_facility_count,0) - coalesce(p.srf_active_facility_count,0))
                
              END AS actual_active_warehouse
FROM
  (SELECT x.tenant,
          x.MONTH,
          x.YEAR,
          x.all_processing_facility,
          x.FBC_processing_facility_REGEX,
          x.FBC_processing_facility_channel_logic,
          case when exception2.tenant_code is not null then x.FBC_active_by_address else x.FBC_active_facility_channel_logic end as FBC_active_facility_channel_logic,
          x.disabled_warehouse,
          x.only_ajio_orders_facility_count,
          x.srf_active_facility_count,
          CASE
              WHEN exception.to_type = 'VENDOR_PANEL' THEN x.active_warehouse-1
              ELSE x.active_vendor_panel
          END AS active_vendor_panel,
          CASE
              WHEN exception.to_type = 'STORE' THEN x.active_warehouse-1
              WHEN exception.to_type = 'PROCESSING_STORES' THEN x.all_processing_facility - 1
              ELSE x.active_stores
          END AS active_stores,
          CASE
              WHEN exception.to_type = 'DROPSHIP_PANEL' THEN x.active_warehouse-1
              ELSE x.active_dropship_panel
          END AS active_dropship_panel,
          case when exception.to_type in ('VENDOR_PANEL','STORE','DROPSHIP_PANEL') then 1 
          when exception2.tenant_code is not null then  x.active_facility_by_address 
           WHEN exception.to_type = 'PROCESSING_STORES' THEN x.all_processing_facility
           else x.active_warehouse end AS active_facility
   FROM cached_query_4823 x
   LEFT JOIN query_3108 AS exception ON lower(exception.Tenant) = lower(x.tenant)
   LEFT JOIN query_3223 AS exception2 ON lower(exception2.tenant_code) = lower(x.tenant)
  ) AS p
LEFT JOIN query_1906 am ON lower(am.tenant_Y) = lower(p.tenant)
ORDER BY KAM,
         p.tenant;