    WITH final AS (

    SELECT
        CAST(campaign_id AS STRING)         AS campaign_id,
        CAST(campaign_product_id AS STRING) AS campaign_product_id, -- Should I bring it? I don't think it is needed
        CAST(product_id AS STRING)          AS product_id,
        CAST(forecast_quantity AS INT64)    AS forecast_quantity
    FROM {{ ref("campaign_product") }}

)

SELECT *
FROM final