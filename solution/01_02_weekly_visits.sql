-- Use the following command to run on terminal
-- duckdb {db_name}.duckdb -c ".read solution/01_02_weekly_visits.sql"  

--      FIRST ATTEMPT
WITH unnested AS (
    SELECT
        local_date,
        fk_places,
        UNNEST(visits) AS unnested_visits,
        DENSE_RANK() OVER(      -- Dense rank somehow keeps the ordering of the UNNEST function
            ORDER BY
                fk_places,
                local_date
        )   AS dense_rank
    FROM
        visits
),
y_unnested AS (
    SELECT
        local_date,
        fk_places,
        unnested_visits,
        ROW_NUMBER() OVER (PARTITION BY fk_places)
        AS day_in_year
    FROM unnested
    ORDER BY fk_places
),
w_unnested AS (
    SELECT
        local_date,
        fk_places,
        unnested_visits,
        CASE            -- Assign week number 1, 2, 3, ...
            WHEN day_in_year < 7 THEN 1
            WHEN day_in_year % 7 = 0 THEN (day_in_year + 1) // 7
            ELSE (day_in_year // 7) + 1
        END AS week_num
    FROM y_unnested
), final AS (
    SELECT
        fk_places,
        week_num,
        SUM(unnested_visits) AS weekly_visits
    FROM w_unnested
    GROUP BY
        week_num,
        fk_places,
    ORDER BY
        week_num,
        fk_places
)
SELECT
    p.fk_brands,
    f.week_num,
    SUM(weekly_visits)
FROM final f
JOIN places p ON
    f.fk_places = p.pid
GROUP BY
    p.fk_brands,
    f.week_num
ORDER BY f.week_num, p.fk_brands;




--          SECOND ATTEMPT
WITH unnested AS (
    SELECT
        local_date,
        fk_places,
        UNNEST(visits) AS dayly_visits,
        ( EXTRACT(YEAR FROM local_date) || '-' ||
            EXTRACT(MONTH FROM local_date) || '-' ||
            UNNEST(RANGE(1, LENGTH(visits) + 1))        -- to get day in month
        )::DATE AS full_date
    FROM visits
    -- We know every place contains exactly one entry for each day in a year, hence there can't be more than 366 entries for
    -- each place
),
weekly_visits AS (
    SELECT 
        fk_places,
        CASE 
            WHEN EXTRACT(MONTH FROM full_date) = 12 AND 
                EXTRACT(WEEK FROM full_date) = 1
                THEN 53
            ELSE EXTRACT(WEEK FROM full_date) 
        END AS week_num,
        SUM(dayly_visits) AS weekly_visits
    FROM unnested
    GROUP BY week_num, fk_places
    ORDER BY week_num, fk_places
)
SELECT
    p.fk_brands,
    wv.week_num,
    SUM(wv.weekly_visits)
FROM weekly_visits wv
JOIN places p ON
    wv.fk_places = p.pid
GROUP BY
    p.fk_brands,
    wv.week_num
ORDER BY wv.week_num, p.fk_brands; 



/*
                        OUTPUT

First script:
┌──────────────────────────────────────┬──────────┬────────────────────┐
│              fk_brands               │ week_num │ sum(weekly_visits) │
│               varchar                │  int64   │       int128       │
├──────────────────────────────────────┼──────────┼────────────────────┤
│ 21a37c4b-d0b6-4732-b74d-f771b3f09c91 │        1 │            1778641 │
│ 39246a0e-deb9-449b-8635-1d3bd5f27f59 │        1 │            1709967 │
│ 3fb66558-f861-422e-88d6-b347c1105bf6 │        1 │            1757292 │
│ 21a37c4b-d0b6-4732-b74d-f771b3f09c91 │        2 │            1746442 │
│ 39246a0e-deb9-449b-8635-1d3bd5f27f59 │        2 │            1676129 │
│ 3fb66558-f861-422e-88d6-b347c1105bf6 │        2 │            1788359 │
│ 21a37c4b-d0b6-4732-b74d-f771b3f09c91 │        3 │            1712765 │
│ 39246a0e-deb9-449b-8635-1d3bd5f27f59 │        3 │            1774972 │
│ 3fb66558-f861-422e-88d6-b347c1105bf6 │        3 │            1781131 │
│ 21a37c4b-d0b6-4732-b74d-f771b3f09c91 │        4 │            1753179 │
│ 39246a0e-deb9-449b-8635-1d3bd5f27f59 │        4 │            1696869 │
│ 3fb66558-f861-422e-88d6-b347c1105bf6 │        4 │            1780218 │
│ 21a37c4b-d0b6-4732-b74d-f771b3f09c91 │        5 │            1698474 │
│ 39246a0e-deb9-449b-8635-1d3bd5f27f59 │        5 │            1756648 │
│ 3fb66558-f861-422e-88d6-b347c1105bf6 │        5 │            1775738 │
│ 21a37c4b-d0b6-4732-b74d-f771b3f09c91 │        6 │            1844967 │
│ 39246a0e-deb9-449b-8635-1d3bd5f27f59 │        6 │            1706426 │
│ 3fb66558-f861-422e-88d6-b347c1105bf6 │        6 │            1792575 │
│ 21a37c4b-d0b6-4732-b74d-f771b3f09c91 │        7 │            1717786 │
│ 39246a0e-deb9-449b-8635-1d3bd5f27f59 │        7 │            1790937 │
│                  ·                   │        · │               ·    │
│                  ·                   │        · │               ·    │
│                  ·                   │        · │               ·    │
│ 39246a0e-deb9-449b-8635-1d3bd5f27f59 │       47 │            1769262 │
│ 3fb66558-f861-422e-88d6-b347c1105bf6 │       47 │            1747057 │
│ 21a37c4b-d0b6-4732-b74d-f771b3f09c91 │       48 │            1723677 │
│ 39246a0e-deb9-449b-8635-1d3bd5f27f59 │       48 │            1625565 │
│ 3fb66558-f861-422e-88d6-b347c1105bf6 │       48 │            1750459 │
│ 21a37c4b-d0b6-4732-b74d-f771b3f09c91 │       49 │            1757731 │
│ 39246a0e-deb9-449b-8635-1d3bd5f27f59 │       49 │            1726577 │
│ 3fb66558-f861-422e-88d6-b347c1105bf6 │       49 │            1741423 │
│ 21a37c4b-d0b6-4732-b74d-f771b3f09c91 │       50 │            1718379 │
│ 39246a0e-deb9-449b-8635-1d3bd5f27f59 │       50 │            1785110 │
│ 3fb66558-f861-422e-88d6-b347c1105bf6 │       50 │            1736621 │
│ 21a37c4b-d0b6-4732-b74d-f771b3f09c91 │       51 │            1767996 │
│ 39246a0e-deb9-449b-8635-1d3bd5f27f59 │       51 │            1767545 │
│ 3fb66558-f861-422e-88d6-b347c1105bf6 │       51 │            1730272 │
│ 21a37c4b-d0b6-4732-b74d-f771b3f09c91 │       52 │            1709263 │
│ 39246a0e-deb9-449b-8635-1d3bd5f27f59 │       52 │            1840399 │
│ 3fb66558-f861-422e-88d6-b347c1105bf6 │       52 │            1711348 │
│ 21a37c4b-d0b6-4732-b74d-f771b3f09c91 │       53 │             514406 │
│ 39246a0e-deb9-449b-8635-1d3bd5f27f59 │       53 │             507740 │
│ 3fb66558-f861-422e-88d6-b347c1105bf6 │       53 │             484179 │
├──────────────────────────────────────┴──────────┴────────────────────┤
│ 159 rows (40 shown)                                        3 columns │
└──────────────────────────────────────────────────────────────────────┘


Second script:
┌──────────────────────────────────────┬──────────┬────────────────────┐
│              fk_brands               │ week_num │ sum(weekly_visits) │
│               varchar                │  int64   │       int128       │
├──────────────────────────────────────┼──────────┼────────────────────┤
│ 21a37c4b-d0b6-4732-b74d-f771b3f09c91 │        1 │            1778641 │
│ 39246a0e-deb9-449b-8635-1d3bd5f27f59 │        1 │            1709967 │
│ 3fb66558-f861-422e-88d6-b347c1105bf6 │        1 │            1756421 │
│ 21a37c4b-d0b6-4732-b74d-f771b3f09c91 │        2 │            1746442 │
│ 39246a0e-deb9-449b-8635-1d3bd5f27f59 │        2 │            1676129 │
│ 3fb66558-f861-422e-88d6-b347c1105bf6 │        2 │            1788617 │
│ 21a37c4b-d0b6-4732-b74d-f771b3f09c91 │        3 │            1712765 │
│ 39246a0e-deb9-449b-8635-1d3bd5f27f59 │        3 │            1774972 │
│ 3fb66558-f861-422e-88d6-b347c1105bf6 │        3 │            1777378 │
│ 21a37c4b-d0b6-4732-b74d-f771b3f09c91 │        4 │            1753179 │
│ 39246a0e-deb9-449b-8635-1d3bd5f27f59 │        4 │            1696869 │
│ 3fb66558-f861-422e-88d6-b347c1105bf6 │        4 │            1776049 │
│ 21a37c4b-d0b6-4732-b74d-f771b3f09c91 │        5 │            1698474 │
│ 39246a0e-deb9-449b-8635-1d3bd5f27f59 │        5 │            1756648 │
│ 3fb66558-f861-422e-88d6-b347c1105bf6 │        5 │            1778398 │
│ 21a37c4b-d0b6-4732-b74d-f771b3f09c91 │        6 │            1844967 │
│ 39246a0e-deb9-449b-8635-1d3bd5f27f59 │        6 │            1706426 │
│ 3fb66558-f861-422e-88d6-b347c1105bf6 │        6 │            1789075 │
│ 21a37c4b-d0b6-4732-b74d-f771b3f09c91 │        7 │            1717786 │
│ 39246a0e-deb9-449b-8635-1d3bd5f27f59 │        7 │            1790937 │
│                  ·                   │        · │               ·    │
│                  ·                   │        · │               ·    │
│                  ·                   │        · │               ·    │
│ 39246a0e-deb9-449b-8635-1d3bd5f27f59 │       47 │            1769262 │
│ 3fb66558-f861-422e-88d6-b347c1105bf6 │       47 │            1749273 │
│ 21a37c4b-d0b6-4732-b74d-f771b3f09c91 │       48 │            1723677 │
│ 39246a0e-deb9-449b-8635-1d3bd5f27f59 │       48 │            1625565 │
│ 3fb66558-f861-422e-88d6-b347c1105bf6 │       48 │            1752814 │
│ 21a37c4b-d0b6-4732-b74d-f771b3f09c91 │       49 │            1757731 │
│ 39246a0e-deb9-449b-8635-1d3bd5f27f59 │       49 │            1726577 │
│ 3fb66558-f861-422e-88d6-b347c1105bf6 │       49 │            1744249 │
│ 21a37c4b-d0b6-4732-b74d-f771b3f09c91 │       50 │            1718379 │
│ 39246a0e-deb9-449b-8635-1d3bd5f27f59 │       50 │            1785110 │
│ 3fb66558-f861-422e-88d6-b347c1105bf6 │       50 │            1734099 │
│ 21a37c4b-d0b6-4732-b74d-f771b3f09c91 │       51 │            1767996 │
│ 39246a0e-deb9-449b-8635-1d3bd5f27f59 │       51 │            1767545 │
│ 3fb66558-f861-422e-88d6-b347c1105bf6 │       51 │            1730192 │
│ 21a37c4b-d0b6-4732-b74d-f771b3f09c91 │       52 │            1709263 │
│ 39246a0e-deb9-449b-8635-1d3bd5f27f59 │       52 │            1840399 │
│ 3fb66558-f861-422e-88d6-b347c1105bf6 │       52 │            1719549 │
│ 21a37c4b-d0b6-4732-b74d-f771b3f09c91 │       53 │             514406 │
│ 39246a0e-deb9-449b-8635-1d3bd5f27f59 │       53 │             507740 │
│ 3fb66558-f861-422e-88d6-b347c1105bf6 │       53 │             482925 │
├──────────────────────────────────────┴──────────┴────────────────────┤
│ 159 rows (40 shown)                                        3 columns │
└──────────────────────────────────────────────────────────────────────┘
*/