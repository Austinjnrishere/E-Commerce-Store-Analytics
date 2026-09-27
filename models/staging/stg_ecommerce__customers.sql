WITH source AS (
    SELECT * FROM {{ source('ecommerce_source', 'CUSTOMERS') }}
)

SELECT
    id AS customer_id,
    first_name,
    last_name,
    LOWER(email) AS email,
    created_at AS customer_created_at,
    DATE(created_at) AS signup_date
FROM source