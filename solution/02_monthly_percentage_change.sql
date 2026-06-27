-- Use the following command to run on terminal
-- duckdb {db_name}.duckdb -c ".read solution/02/02_monthly_percentage_change.sql"  

WITH monthly_visits AS (
    SELECT
        v.local_date,
        v.fk_places,
        p.fk_city,
        (
            WITH visits_unnested AS (
                SELECT UNNEST(visits) AS unnested
            )
            SELECT SUM(unnested) FROM visits_unnested
        ) AS monthly_visits
    FROM
        visits v
    JOIN places p
        ON p.pid = v.fk_places
    WHERE p.fk_city = 2
    ORDER BY
        local_date,
        fk_places
)
SELECT
    local_date,
    fk_places,
    monthly_visits,
    CASE 
        WHEN LAG(monthly_visits) OVER(PARTITION BY fk_places) IS NULL THEN 0
        ELSE ROUND((
                (monthly_visits - (LAG(monthly_visits) OVER(PARTITION BY fk_places))) /
                LAG(monthly_visits) OVER(PARTITION BY fk_places) ) * 100,
            2)
    END AS percentage_change
FROM monthly_visits
ORDER BY
    fk_places,
    local_date;


/*
                    OUTPUT

┌────────────┬──────────────────────────────────────┬────────────────┬───────────────────┐
│ local_date │              fk_places               │ monthly_visits │ percentage_change │
│    date    │               varchar                │     int128     │      double       │
├────────────┼──────────────────────────────────────┼────────────────┼───────────────────┤
│ 2024-01-01 │ 043a571a-dca5-463b-9a5e-62e48bc36c37 │          76148 │               0.0 │
│ 2024-02-01 │ 043a571a-dca5-463b-9a5e-62e48bc36c37 │          66157 │             -18.3 │
│ 2024-03-01 │ 043a571a-dca5-463b-9a5e-62e48bc36c37 │          87481 │              8.37 │
│ 2024-04-01 │ 043a571a-dca5-463b-9a5e-62e48bc36c37 │          83306 │             17.72 │
│ 2024-05-01 │ 043a571a-dca5-463b-9a5e-62e48bc36c37 │          74407 │             -2.29 │
│ 2024-06-01 │ 043a571a-dca5-463b-9a5e-62e48bc36c37 │          70765 │             -6.71 │
│ 2024-07-01 │ 043a571a-dca5-463b-9a5e-62e48bc36c37 │          75852 │              5.91 │
│ 2024-08-01 │ 043a571a-dca5-463b-9a5e-62e48bc36c37 │          71616 │             -3.13 │
│ 2024-09-01 │ 043a571a-dca5-463b-9a5e-62e48bc36c37 │          73928 │            -15.49 │
│ 2024-10-01 │ 043a571a-dca5-463b-9a5e-62e48bc36c37 │          80723 │             43.56 │
│ 2024-11-01 │ 043a571a-dca5-463b-9a5e-62e48bc36c37 │          56231 │             -15.0 │
│ 2024-12-01 │ 043a571a-dca5-463b-9a5e-62e48bc36c37 │          80980 │              8.83 │
│ 2024-01-01 │ 0ede191a-4876-49c2-a756-a45dd2a97b09 │          73415 │               0.0 │
│ 2024-02-01 │ 0ede191a-4876-49c2-a756-a45dd2a97b09 │          76505 │              4.21 │
│ 2024-03-01 │ 0ede191a-4876-49c2-a756-a45dd2a97b09 │          74965 │             -2.01 │
│ 2024-04-01 │ 0ede191a-4876-49c2-a756-a45dd2a97b09 │          87621 │             16.88 │
│ 2024-05-01 │ 0ede191a-4876-49c2-a756-a45dd2a97b09 │          72146 │            -17.66 │
│ 2024-06-01 │ 0ede191a-4876-49c2-a756-a45dd2a97b09 │          69527 │             -3.63 │
│ 2024-07-01 │ 0ede191a-4876-49c2-a756-a45dd2a97b09 │          73408 │              5.58 │
│ 2024-08-01 │ 0ede191a-4876-49c2-a756-a45dd2a97b09 │          76809 │              4.63 │
│     ·      │                  ·                   │            ·   │                ·  │
│     ·      │                  ·                   │            ·   │                ·  │
│     ·      │                  ·                   │            ·   │                ·  │
│ 2024-05-01 │ f985d062-dddf-4ffd-8540-ea0cb6ae3d24 │          70261 │             -3.51 │
│ 2024-06-01 │ f985d062-dddf-4ffd-8540-ea0cb6ae3d24 │          71022 │              1.08 │
│ 2024-07-01 │ f985d062-dddf-4ffd-8540-ea0cb6ae3d24 │          75285 │               6.0 │
│ 2024-08-01 │ f985d062-dddf-4ffd-8540-ea0cb6ae3d24 │          71434 │             -5.12 │
│ 2024-09-01 │ f985d062-dddf-4ffd-8540-ea0cb6ae3d24 │          82046 │             14.86 │
│ 2024-10-01 │ f985d062-dddf-4ffd-8540-ea0cb6ae3d24 │          69921 │            -14.78 │
│ 2024-11-01 │ f985d062-dddf-4ffd-8540-ea0cb6ae3d24 │          65912 │             -5.73 │
│ 2024-12-01 │ f985d062-dddf-4ffd-8540-ea0cb6ae3d24 │          69596 │              5.59 │
│ 2024-01-01 │ fffd18c5-704a-4aaf-abad-71e4da4843e3 │          75600 │            -11.55 │
│ 2024-02-01 │ fffd18c5-704a-4aaf-abad-71e4da4843e3 │          83255 │              29.1 │
│ 2024-03-01 │ fffd18c5-704a-4aaf-abad-71e4da4843e3 │          58861 │            -27.66 │
│ 2024-04-01 │ fffd18c5-704a-4aaf-abad-71e4da4843e3 │          86601 │             26.52 │
│ 2024-05-01 │ fffd18c5-704a-4aaf-abad-71e4da4843e3 │          64489 │            -18.16 │
│ 2024-06-01 │ fffd18c5-704a-4aaf-abad-71e4da4843e3 │          82381 │               0.0 │
│ 2024-07-01 │ fffd18c5-704a-4aaf-abad-71e4da4843e3 │          85474 │              2.67 │
│ 2024-08-01 │ fffd18c5-704a-4aaf-abad-71e4da4843e3 │          82486 │             -4.75 │
│ 2024-09-01 │ fffd18c5-704a-4aaf-abad-71e4da4843e3 │          68450 │             -2.21 │
│ 2024-10-01 │ fffd18c5-704a-4aaf-abad-71e4da4843e3 │          69998 │             18.92 │
│ 2024-11-01 │ fffd18c5-704a-4aaf-abad-71e4da4843e3 │          78796 │             -4.47 │
│ 2024-12-01 │ fffd18c5-704a-4aaf-abad-71e4da4843e3 │          81367 │             -1.23 │
├────────────┴──────────────────────────────────────┴────────────────┴───────────────────┤
│ 384 rows (40 shown)                                                          4 columns │
└────────────────────────────────────────────────────────────────────────────────────────┘
*/