WITH final AS (

    SELECT
        campaign_id,
        product_id,
        forecast_quantity
    FROM {{ ref("src_campaign_product") }}

)

SELECT *
FROM final
