WITH sessions_info AS (
  SELECT
    CONCAT(user_pseudo_id, CAST((SELECT value.int_value FROM UNNEST(event_params) WHERE key = 'ga_session_id') AS STRING)) AS user_session_id,
    REGEXP_EXTRACT((SELECT value.string_value FROM UNNEST(event_params) WHERE key = 'page_location'), r'^([^?]+)') AS landing_page_location,
    traffic_source.source AS source,
    traffic_source.medium AS medium,
    traffic_source.name AS campaign,
    device.category AS device_category,
    device.operating_system AS operating_system,
    device.language AS device_language,
    geo.country AS country
  FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
  WHERE event_name = 'session_start'
),

events_info AS (
  SELECT
    TIMESTAMP_MICROS(event_timestamp) AS event_time,
    event_name,
    CONCAT(user_pseudo_id, CAST((SELECT value.int_value FROM UNNEST(event_params) WHERE key = 'ga_session_id') AS STRING)) AS user_session_id,
    ecommerce.purchase_revenue
  FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
  WHERE event_name IN (
    'session_start',
    'view_item',
    'add_to_cart',
    'begin_checkout',
    'add_shipping_info',
    'add_payment_info',
    'purchase'
  )
)

SELECT
  e.event_time,
  e.event_name,
  s.user_session_id,
  e.purchase_revenue,
  s.landing_page_location,
  s.source,
  s.medium,
  s.campaign,
  s.device_category,
  s.operating_system,
  s.device_language,
  s.country
FROM sessions_info s
LEFT JOIN events_info e
  USING (user_session_id)