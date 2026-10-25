WITH final AS (

    SELECT
        CAST(order_id AS STRING)         AS order_id,
        CAST(order_date AS DATE)        AS order_date,
        CAST(store_id AS STRING)         AS store_id
    FROM {{ ref("order") }}
)

SELECT *
FROM final