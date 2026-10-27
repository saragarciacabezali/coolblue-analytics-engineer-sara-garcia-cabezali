WITH final AS (

    SELECT
        CAST(product_id AS STRING)      AS product_id,
        CAST(product_type_id AS STRING) AS product_type_id,
        CAST(product_name AS STRING)    AS product_name
    FROM {{ ref("product") }}

)

SELECT *
FROM final