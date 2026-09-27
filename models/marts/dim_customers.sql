WITH customers AS (
    SELECT * FROM {{ ref('stg_ecommerce__customers') }}
),

orders AS (
    SELECT * FROM {{ ref('int_orders_joined_items') }}
),

customer_orders_summary AS (
    SELECT
        customer_id,
        MIN(order_created_at) AS first_order_at,
        MAX(order_created_at) AS most_recent_order_at,
        COUNT(order_id) AS total_orders,
        SUM(net_order_amount) AS lifetime_spend
    FROM orders
    WHERE order_status != 'cancelled'
    GROUP BY 1
)

SELECT
    -- Primary Key
    {{ dbt_utils.generate_surrogate_key(['c.customer_id']) }} AS customer_key,

    -- Customer Profile Attributes
    c.customer_id,
    c.first_name,
    c.last_name,
    c.email,
    c.signup_date,

    -- Customer Lifetime Metrics
    COALESCE(s.total_orders, 0) AS total_orders,
    COALESCE(s.lifetime_spend, 0.00) AS lifetime_spend,
    s.first_order_at,
    s.most_recent_order_at

FROM customers c
LEFT JOIN customer_orders_summary s
    ON c.customer_id = s.customer_id