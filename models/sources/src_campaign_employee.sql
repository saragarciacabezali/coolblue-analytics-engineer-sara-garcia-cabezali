    WITH final AS (

    SELECT
        CAST(employee_id AS STRING)     AS employee_id,
        CAST(employee_name AS STRING)   AS employee_name,
    FROM {{ ref("campaign_manager") }}

)

SELECT *
FROM final