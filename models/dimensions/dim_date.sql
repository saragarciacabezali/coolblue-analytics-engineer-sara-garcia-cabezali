WITH final AS (

    SELECT
        CAST(FORMAT_DATE('%Y%m%d',CAST(d AS DATE)) AS INTEGER)    AS date_id,
        d                                                         AS date,
        CAST(FORMAT_DATE('%a, %b %d %Y', d) AS STRING)            AS date_name,
        -- Day
        EXTRACT(DAY FROM d)                                       AS day_of_month,
        FORMAT_DATE('%u', d)                                      AS day_of_week_id,
        FORMAT_DATE('%A', d)                                      AS day_of_week_name,
        -- Month
        EXTRACT(MONTH FROM d)                                     AS month_id,
        CAST(FORMAT_DATE('%B', d) AS STRING)                      AS month_name,
        -- Year
        EXTRACT(YEAR FROM d)                                      AS year_id,
        EXTRACT(ISOYEAR FROM d)                                   AS iso_year_id,
        -- Week
        FORMAT_DATE('%G-W%V', d)                                  AS iso_week_id,
        EXTRACT(ISOWEEK FROM d)                                   AS iso_week_of_year,  
        --Quarter
        EXTRACT(QUARTER FROM d)                                   AS quarter
    FROM UNNEST(GENERATE_DATE_ARRAY('2025-01-01', '2027-12-31', INTERVAL 1 DAY)) AS d
)

SELECT *
FROM final