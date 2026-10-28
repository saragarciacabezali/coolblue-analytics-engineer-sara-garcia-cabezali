WITH final AS (

    SELECT
        campaign_id,
        product_type_id,
        forecast_quantity
    FROM {{ ref("src_campaign_product_type") }}

)

SELECT *
FROM final
