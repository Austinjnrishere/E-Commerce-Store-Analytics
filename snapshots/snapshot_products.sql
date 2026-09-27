{% snapshot snapshot_products %}

{{
    config(
      target_database='ECOMMERCE_DB',
      target_schema='SNAPSHOTS',
      unique_key='id',
      strategy='check',
      check_cols=['price', 'category'],
    )
}}

SELECT * FROM {{ source('ecommerce_source', 'PRODUCTS') }}

{% endsnapshot %}