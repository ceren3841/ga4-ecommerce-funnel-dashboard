SELECT
  -- Zaman Filtresi İçin
  TIMESTAMP_MICROS(event_timestamp) AS event_timestamp,
  PARSE_DATE('%Y%m%d', event_date) AS event_date,
  
  -- Oturum & Kullanıcı Kimlikleri (Benzersiz Ziyaretçi Sayısı İçin)
  user_pseudo_id,
  (SELECT value.int_value FROM UNNEST(event_params) WHERE key = 'ga_session_id') AS session_id,
  CONCAT(user_pseudo_id, '-', (SELECT value.int_value FROM UNNEST(event_params) WHERE key = 'ga_session_id')) AS unique_session_id,
  
  -- Etkinlik Adı (7 Adımlı Huni)
  event_name,
  
  -- Filtre 1: Oturum Açılış Sayfası (Landing Page)
  (SELECT value.string_value FROM UNNEST(event_params) WHERE key = 'page_location') AS page_location,
  
  -- Filtre 2: Trafik Kaynağı, Mecra ve Kampanya 
  traffic_source.source AS traffic_source,
  traffic_source.medium AS traffic_medium,
  traffic_source.name AS traffic_campaign,
  
  -- Filtre 3: Cihaz Kategorisi
  device.category AS device_category,
  
  -- Filtre 4: Cihaz Dili
  device.language AS device_language,
  
  -- Filtre 5: İşletim Sistemi
  device.operating_system AS device_os,

  -- Satış & Sipariş Metrikleri
  ecommerce.purchase_revenue AS purchase_revenue,
  ecommerce.total_item_quantity AS total_item_quantity

FROM
  `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
WHERE
  event_name IN (
    'session_start',
    'view_item',
    'add_to_cart',
    'begin_checkout',
    'add_shipping_info',
    'add_payment_info',
    'purchase'
  )
