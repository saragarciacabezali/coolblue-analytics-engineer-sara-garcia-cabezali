WITH final AS (

    SELECT
        product_type_id,
        product_type_name,
        team_id
    FROM {{ ref("src_product_type") }}

)

SELECT *
FROM final
