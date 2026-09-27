WITH products AS (
    SELECT * FROM {{ ref('stg_ecommerce__products') }}
)

SELECT
    -- Primary Key
    {{ dbt_utils.generate_surrogate_key(['product_id']) }} AS product_key,

    -- Product Attributes
    product_id,
    product_name,
    product_category,
    unit_price

FROM products