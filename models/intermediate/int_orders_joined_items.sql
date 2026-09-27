WITH orders AS (
    SELECT * FROM {{ ref('stg_ecommerce__orders') }}
),

order_items AS (
    SELECT * FROM {{ ref('stg_ecommerce__order_items') }}
),

-- Aggregate line items up to the order level
order_items_aggregated AS (
    SELECT
        order_id,
        COUNT(order_item_id) AS total_items,
        COUNT(DISTINCT product_id) AS total_unique_products,
        SUM(item_price) AS gross_order_amount,
        SUM(item_discount) AS total_order_discount,
        SUM(net_item_amount) AS net_order_amount
    FROM order_items
    GROUP BY 1
)

SELECT
    -- Order Identifiers & Attributes
    o.order_id,
    o.customer_id,
    o.order_status,
    
    -- Timestamps & Dates
    o.order_created_at,
    o.order_shipped_at,
    o.order_delivered_at,
    o.order_date,

    -- Item Aggregations (handle orders that might have 0 items)
    COALESCE(ia.total_items, 0) AS total_items,
    COALESCE(ia.total_unique_products, 0) AS total_unique_products,
    COALESCE(ia.gross_order_amount, 0.00) AS gross_order_amount,
    COALESCE(ia.total_order_discount, 0.00) AS total_order_discount,
    COALESCE(ia.net_order_amount, 0.00) AS net_order_amount

FROM orders o
LEFT JOIN order_items_aggregated ia
    ON o.order_id = ia.order_id