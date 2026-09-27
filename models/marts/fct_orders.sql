WITH intermediate_orders AS (
    SELECT * FROM {{ ref('int_orders_joined_items') }}
)

SELECT
    -- Primary Key
    {{ dbt_utils.generate_surrogate_key(['order_id']) }} AS order_key,

    -- Attributes & Foreign Keys
    order_id,
    customer_id,
    order_status,

    -- Dates & Timestamps
    order_created_at,
    order_shipped_at,
    order_delivered_at,
    order_date,

    -- Order Metrics
    total_items,
    total_unique_products,
    gross_order_amount,
    total_order_discount,
    net_order_amount,

    -- Derived Fulfillment Metric
    DATEDIFF('day', order_created_at, order_delivered_at) AS days_to_deliver

FROM intermediate_orders