WITH final AS (

    SELECT
        CAST(FORMAT_DATE('%Y%m%d',CAST(d AS DATE)) AS INT64)      AS date_id,
        d                                                         AS date,
        CAST(FORMAT_DATE('%a, %b %d %Y', d) AS STRING)            AS date_name,
        -- Day
        EXTRACT(DAY FROM d)                                       AS day_of_month,
        CAST(FORMAT_DATE('%u', d) AS INT64)                       AS day_of_week_number,
        FORMAT_DATE('%A', d)                                      AS day_of_week_name,
        -- Month
        EXTRACT(MONTH FROM d)                                     AS month_number,
        CAST(FORMAT_DATE('%B', d) AS STRING)                      AS month_name,
        -- Year
        EXTRACT(YEAR FROM d)                                      AS year,
        EXTRACT(ISOYEAR FROM d)                                   AS iso_year,
        -- Week
        FORMAT_DATE('%G-W%V', d)                                  AS iso_week_label,
        EXTRACT(ISOWEEK FROM d)                                   AS iso_week_number,  
        --Quarter
        EXTRACT(QUARTER FROM d)                                   AS quarter
    FROM UNNEST(GENERATE_DATE_ARRAY('2025-01-01', '2027-12-31', INTERVAL 1 DAY)) AS d
)

SELECT *
FROM final