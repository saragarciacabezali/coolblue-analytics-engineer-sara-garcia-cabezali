-- One row per order line, linked to the store and product versions valid on the order date
-- and to the campaign the product belonged to on that day ('-1' = No campaign).

WITH order_lines AS (

    SELECT
        ol.order_line_id,
        ol.order_id,
        ol.product_id,
        ol.quantity,
        o.order_date,
        o.store_id
    FROM {{ ref("src_order_line") }} AS ol
    INNER JOIN {{ ref("src_order") }} AS o
        ON ol.order_id = o.order_id

), final AS (

    SELECT
        ol.order_line_id,
        ol.order_id,
        CAST(FORMAT_DATE('%Y%m%d', ol.order_date) AS INT64)     AS date_id,
        ds.store_key,
        ol.store_id,
        dp.product_key,
        ol.product_id,
        COALESCE(cm.campaign_id, '-1')                          AS campaign_id,
        ol.quantity
    FROM order_lines AS ol
    -- Store and product versions valid on the order date (Type 2)
    LEFT JOIN {{ ref("dim_store") }} AS ds
        ON  ol.store_id = ds.store_id
        AND ol.order_date >= ds.valid_from
        AND (ol.order_date < ds.valid_to OR ds.valid_to IS NULL)
    LEFT JOIN {{ ref("dim_product") }} AS dp
        ON  ol.product_id = dp.product_id
        AND ol.order_date >= dp.valid_from
        AND (ol.order_date < dp.valid_to OR dp.valid_to IS NULL)
    -- Campaign the product belonged to on the order date, if any
    LEFT JOIN {{ ref("int_campaign_membership") }} AS cm
        ON  ol.product_id = cm.product_id
        AND ol.order_date >= cm.valid_from
        AND ol.order_date < cm.valid_to

)

SELECT *
FROM final
