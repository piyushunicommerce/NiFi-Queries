SELECT p.tenant,
       p.month,
       p.year,
      sum(p.all_processing_facility) AS all_processing_facility,
      sum(p.FBC_active_by_address) AS FBC_active_by_address,
      sum(p.FBC_processing_facility_REGEX) FBC_processing_facility_REGEX,
      sum(p.FBC_processing_facility_channel_logic) FBC_processing_facility_channel_logic,
      sum(p.FBC_active_facility_channel_logic) FBC_active_facility_channel_logic,
      sum(p.active_warehouse) active_warehouse,
      sum(p.disabled_warehouse) disabled_warehouse,
       sum(p.vendor_panel) active_vendor_panel,
       sum(p.store) active_stores,
       sum(p.dropship_panel) active_dropship_panel,
      sum(p.active_facility_by_address) active_facility_by_address,
      sum(p.all_processing_stores) all_processing_stores,
       p.only_ajio_orders_facility_count,
       p.only_ajio_orders_facility_name
      p.srf_active_facility_count,
        p.srf_active_facility
FROM
  (SELECT CASE
              
              WHEN t.tenant LIKE 'HEALTHKART%%' THEN 'healthkart'
              WHEN t.tenant LIKE 'PharmEasy%%' THEN 'pharmeasy'
              when t.tenant LIKE 'Cred%%' THEN 'cred'
              WHEN t.tenant IN ('trustbasket','aent','anubhutee','hubberholme','helea','dennislingo','dazzlecollectionz','villain','bulfyss2','karagiri',
'lilpickscouture','acc','mensabrand','prettykrafts2','pebblecart','partypropz','exim','myfitness') THEN 'mensabrands'
              WHEN t.tenant IN ('querz',
                              'namhah',
                              'lpanache',
                              'lp',
'tealandterra','prmretail','reliance','minimalist','mars','wbn','neocor','unilever') THEN 'maersk'
              WHEN t.tenant IN ('b2blk',
                              'lenskart',
                              'lenskartmp'
                              ) THEN 'lenskart'
              ELSE t.tenant
          END AS tenant,
          t.*,
          x.*,
          y.*,
          z.*
   FROM
     (
     select * from cached_query_4822

    ) t
   LEFT JOIN
     (SELECT *
      FROM cached_query_2862) AS y ON lower(y.tenant) = lower(t.tenant) --  ajio facility

   )p 
     GROUP BY 
     p.tenant, p.tenant;