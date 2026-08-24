# Power BI Data Model

Import all CSVs from `data/processed/`. Use a star-style, single-direction model:

| From | To | Cardinality | Active |
|---|---|---|---|
| `dim_date[date_key]` | `fact_orders[purchase_date]` | 1:* | Yes |
| `dim_customer[customer_id]` | `fact_orders[customer_id]` | 1:* | Yes |
| `dim_product[product_id]` | `fact_order_items[product_id]` | 1:* | Yes |
| `dim_seller[seller_id]` | `fact_order_items[seller_id]` | 1:* | Yes |
| `fact_orders[order_id]` | `fact_order_items[order_id]` | 1:* | Yes |
| `fact_orders[order_id]` | `fact_payments[order_id]` | 1:* | Yes |
| `fact_orders[order_id]` | `fact_reviews[order_id]` | 1:1 | Yes |

Do not set relationships to Both. `dim_geography` is an optional lookup for mapped customer/seller location roles; retain separate role keys to avoid ambiguous paths. Mark `dim_date` as the model Date table using `date_key` after converting it to Date.

## Grain rule

Never put `fact_payments[payment_value]` and `fact_order_items[item_revenue]` into a visual using a raw joined table. Measures aggregate each fact independently and use order context only when needed.
