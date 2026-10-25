WITH final AS (

    SELECT
        *
    FROM {{ ref("src_campaign") }}
    WHERE DATE_DIFF(end_date, start_date, DAY) < 14

)

SELECT *
FROM final