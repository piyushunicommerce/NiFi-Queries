  SELECT p1.tenant,
       p1.month,
       p1.year,
       p1.all_processing_facility,
       pz.fbc_active_by_address,
       p1.fbc_processing_facility_regex,
       p1.fbc_processing_facility_channel_logic,
       p2.fbc_active_facility_channel_logic,
       p2.active_warehouse,
       p2.disabled_warehouse,
       p2.vendor_panel active_vendor_panel,
       p2.store as active_stores, p2.dropship_panel active_dropship_panel,p1.all_processing_stores
FROM
  (SELECT t.code tenant,
          t.product_code,
          month(soi.created) MONTH,
                             year(soi.created) YEAR,
                                               count(DISTINCT f.id) all_processing_facility,
                                              count(distinct (case when f.type = 'STORE' or f.operational_type = 'STORE' then f.id end)) as all_processing_stores,
                                               count(distinct(CASE
                                                                  WHEN f.display_name REGEXP '${channel_regex_expression}' THEN f.display_name
                                                              END) )AS FBC_processing_facility_REGEX, 
                                                count(distinct(CASE
                                                                  WHEN c.source_code REGEXP '${channel_regex_expression}'  THEN c.code
                                                              END) )AS FBC_processing_facility_channel_logic        
   FROM `",SCHEMA_NAME,"`.`sale_order_item` soi
   join `",SCHEMA_NAME,"`.`facility` f on soi.facility_id = f.id
   JOIN `",SCHEMA_NAME,"`.`party` p on p.id = f.id
   JOIN `",SCHEMA_NAME,"`.`tenant` t ON t.id = p.tenant_id
   join `",SCHEMA_NAME,"`.`sale_order` so on soi.sale_order_id = so.id
   JOIN `",SCHEMA_NAME,"`.`channel` c ON so.channel_id = c.id
   WHERE soi.created >= LAST_DAY(CURDATE() - INTERVAL 2 MONTH) + INTERVAL 1 DAY
     AND soi.created < LAST_DAY(CURDATE() - INTERVAL 1 MONTH) + INTERVAL 1 DAY
   GROUP BY 1,2,3,4) AS p1
LEFT JOIN
  (SELECT t.code tenant,
          sum(CASE
                  WHEN p.enabled=1 THEN 1
                  ELSE 0
              END) active_warehouse,
          sum(CASE
                  WHEN p.enabled=0 THEN 1
                  ELSE 0
              END) disabled_warehouse,
              count(distinct(CASE WHEN c.source_code REGEXP '${channel_regex_expression}' and p.enabled=1 THEN c.code
                END) ) AS FBC_active_facility_channel_logic,
                sum(case when p.enabled = 1 and (f.type = 'STORE' or f.operational_type = 'STORE') then 1 else 0 end) as store,
                sum(case when p.enabled = 1 and (f.type = 'VENDOR_PANEL' or f.operational_type = 'VENDOR_PANEL') then 1 else 0 end) as vendor_panel,
                sum(case when p.enabled = 1 and (f.type = 'DROPSHIP' or f.operational_type = 'DROPSHIP') then 1 else 0 end) as dropship_panel
                
   FROM `",SCHEMA_NAME,"`.`facility` f
    join    `",SCHEMA_NAME,"`.`party` p on f.id = p.id
     join   `",SCHEMA_NAME,"`.`tenant` t on p.tenant_id=t.id
     left join `",SCHEMA_NAME,"`.`channel` c on c.associated_facility_id = p.id
   GROUP BY 1) p2 ON p1.tenant = p2.tenant
  left join
   (SELECT t.code tenant,
          count(distinct(CASE
                 WHEN (c.source_code REGEXP '${channel_regex_expression}') and p.enabled=1 THEN soundex(REPLACE(concat(coalesce(c.code,0),coalesce(pa.address_line1,0),coalesce(pa.address_line2,0),coalesce(pa.pincode,0),coalesce(pa.city,0)),' ','')) 
                END) )AS FBC_active_by_address
   FROM `",SCHEMA_NAME,"`.`facility` f
    join    `",SCHEMA_NAME,"`.`party` p on f.id=p.id
    join    `",SCHEMA_NAME,"`.`party_address` pa on pa.party_id = p.id
     join   `",SCHEMA_NAME,"`.`party_address_type` pat on pat.id = pa.party_address_type_id
     join   `",SCHEMA_NAME,"`.`tenant` t on p.tenant_id=t.id
     join   `",SCHEMA_NAME,"`.`channel` c on c.associated_facility_id = p.id
   WHERE p.enabled = 1 and pat.code = 'SHIPPING'
   GROUP BY 1 ) pz ON p1.tenant = pz.tenant  