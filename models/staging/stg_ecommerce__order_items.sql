WITH source AS (
    SELECT * FROM {{ source('ecommerce_source', 'ORDER_ITEMS') }}
)

SELECT
    id AS order_item_id,
    order_id,
    product_id,
    price AS item_price,
    COALESCE(discount, 0.00) AS item_discount,
    ROUND(price - COALESCE(discount, 0.00), 2) AS net_item_amount
FROM source