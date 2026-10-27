    WITH final AS (

    SELECT
        CAST(campaign_product_id AS STRING) AS campaign_product_id, -- Keep them for snapshot purposes
        CAST(campaign_id AS STRING)         AS campaign_id,
        CAST(product_id AS STRING)          AS product_id,
        CAST(forecast_quantity AS INT64)    AS forecast_quantity
    FROM {{ ref("campaign_product") }}

)

SELECT *
FROM final