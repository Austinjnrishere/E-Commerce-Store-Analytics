# 🛒 E-Commerce Store Analytics & Dimensional Modeling (dbt + Snowflake)

An end-to-end, Kimball-style star schema data pipeline built on Snowflake and dbt Core. This project transforms synthetic relational e-commerce transactions into optimized dimensional models (`fct_orders`, `dim_customers`, and `dim_products`) for downstream retail analytics and business intelligence.

---

## 📌 Project Overview

E-Commerce transactional databases capture highly normalized, multi-table records (customers, products, header orders, and line items). 

This pipeline cleans landed transactional tables and applies dimensional modeling techniques to answer core business questions:
- **Order Financials:** Revenue, discounts, net basket value, and delivery turnaround times.
- **Customer Dynamics:** Lifetime order count, lifetime net spend, and acquisition milestones.
- **Product Performance:** Unit economics and category-level rollups.

---

## 🏗️ Data Architecture & Lineage

[ Snowflake RAW Schema ]
│
├── RAW_CUSTOMERS ──► stg_ecommerce__customers ───────────────┐
│                                                              │
├── RAW_PRODUCTS  ──► stg_ecommerce__products  ─────────┐     │
│                                                        │     │
├── RAW_ORDER_ITEMS ─► stg_ecommerce__order_items ┐      │     │
│                                                 │      │     │
└── RAW_ORDERS ──────► stg_ecommerce__orders ─────┴┐     │     │
│     │     │
▼     ▼     ▼
int_orders_joined_items │
│     │     │
┌─────────────────┴─┐   │     │
▼                   ▼   ▼     ▼
fct_orders           dim_products dim_customers

---

## 📂 Model Architecture & Layering

| Layer | Model Name | Materialization | Key Function & Business Logic |
| :--- | :--- | :--- | :--- |
| **Staging** | `stg_ecommerce__customers` | `view` | Casts signup dates, normalizes email strings, and standardizes primary keys (`customer_id`). |
| **Staging** | `stg_ecommerce__products` | `view` | Cleans product names, maps pricing, and categorizes catalog items. |
| **Staging** | `stg_ecommerce__orders` | `view` | Normalizes order lifecycle status (`pending`, `cancelled`, `returned`, `delivered`) and cleans order timestamps. |
| **Staging** | `stg_ecommerce__order_items` | `view` | Calculates net item prices (`price - discount`) and standardizes line-item primary keys (`order_item_id`). |
| **Intermediate** | `int_orders_joined_items` | `ephemeral / view` | **Pre-aggregates line items** to header order level (item counts, total discounts, net revenue) to prevent fan-out before joining to orders. |
| **Marts (Fact)** | `fct_orders` | `table` | Header-level fact table containing surrogate keys, financial metrics, and fulfillment turnaround time (`days_to_deliver`). |
| **Marts (Dim)** | `dim_customers` | `table` | Customer dimension table enriched with Lifetime Spend (`lifetime_spend`) and total non-cancelled order counts. |
| **Marts (Dim)** | `dim_products` | `table` | Product dimension catalog with surrogate keys (`product_key`) and unit pricing. |

---

## 🛡️ Data Quality & Automated CI/CD Testing

### 1. Schema Assertions (`schema.yml`)
- **Primary & Foreign Key Integrity:** Uniqueness and non-null tests on surrogate keys (`order_key`, `customer_key`, `product_key`).
- **Referential Integrity:** `relationships` tests enforcing that every `customer_id` in `fct_orders` exists in `dim_customers`.
- **Domain Constraints:** `accepted_values` test verifying valid order statuses (`['pending', 'cancelled', 'returned', 'delivered']`).

### 2. Automated Multi-Project CI/CD Workflow (`.github/workflows/dbt_ci.yml`)
Every Pull Request to `main` triggers a GitHub Actions pipeline that executes:
- **Environment Setup:** Python 3.12 with pip caching and RSA Private Key profile generation.
- **Isolated Target Execution:** `dbt run --target ci` and `dbt test --target ci` run sequentially across both Web3 and E-Commerce project models.

---

## 🚀 Quickstart Guide

### 1. Prerequisites & Environment Setup
```bash
# Clone the repository
git clone [https://github.com/your-username/dbt-multi-project-portfolio.git](https://github.com/your-username/dbt-multi-project-portfolio.git)
cd dbt-multi-project-portfolio

# Activate virtual environment and install dbt-snowflake
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
pip install dbt-core==1.9.4 dbt-snowflake==1.9.4

# Install project dependencies (dbt-utils)
dbt deps
