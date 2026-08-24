# Data Dictionary

| Object | Grain | Purpose |
|---|---|---|
| `raw_*` | Source CSV row | Untouched Olist source preservation. |
| `dim_date` | Calendar date | Time intelligence. |
| `dim_customer` | `customer_id` | Customer/order delivery geography and `customer_unique_id` repeat behavior. |
| `dim_product` | `product_id` | Translated category and product attributes. |
| `dim_seller` | `seller_id` | Seller location and performance. |
| `dim_geography` | role/state/city | Geography lookup; customer and seller roles are intentionally distinct. |
| `fact_orders` | `order_id` | Lifecycle timestamps, status, delivery metrics, cancellation flag. |
| `fact_order_items` | `order_id` + `order_item_id` | Item GMV and freight. |
| `fact_payments` | `order_id` + `payment_sequential` | Payment method, installments, payment value. |
| `fact_reviews` | selected `order_id` review | Latest deterministic review per order for non-duplicated order-level satisfaction metrics. |

GMV means sum of item prices. Freight is separately summed from order items. Payment Value means sum of payment transactions and must not be summed after an item-level join.
