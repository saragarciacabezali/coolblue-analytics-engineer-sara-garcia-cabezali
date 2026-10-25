WITH final AS (
    
    SELECT
        CAST(order_line_id AS STRING)    AS order_line_id,
        CAST(order_id AS STRING)         AS order_id,
        CAST(product_id AS STRING)       AS product_id,
        CAST(quantity AS INT64)         AS quantity
    FROM {{ ref("order_line") }}

)

SELECT *
FROM final
