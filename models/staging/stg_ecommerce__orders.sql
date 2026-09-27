WITH source AS (
    SELECT * FROM {{ source('ecommerce_source', 'ORDERS') }}
)

SELECT
    order_id,
    user_id AS customer_id,
    LOWER(status) AS order_status,
    created_at AS order_created_at,
    shipped_at AS order_shipped_at,
    delivered_at AS order_delivered_at,
    DATE(created_at) AS order_date
FROM source