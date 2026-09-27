WITH source AS (
    SELECT * FROM {{ source('ecommerce_source', 'PRODUCTS') }}
)

SELECT
    id AS product_id,
    name AS product_name,
    category AS product_category,
    price AS unit_price
FROM source