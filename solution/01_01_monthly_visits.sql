-- Use the following command to run on terminal
-- duckdb {db_name}.duckdb -c ".read solution/01_01_monthly_visits.sql"  


-- First Solution
-- Uses a subquery to find the sum of visits array in each row, ensuring the sum is calculated in-place.
SELECT
    local_date,
    fk_places,
    (
        WITH visits_unnested AS (
            SELECT UNNEST(visits) AS unnested
            -- UNNEST function turns an array like this [1,2,3] to rows of individual elements. This is required 
            -- if an aggregate function like SUM is to be used, as aggregate functions do not work on arrays in sql.
        )
        SELECT SUM(unnested) FROM visits_unnested
    ) AS monthly_visits
FROM
    visits
ORDER BY
    local_date,
    fk_places;


--      Another Solution
--  This is less preferred as it assumes SQL will keep the visits in order from day 1 - 366 of the year
WITH unnested AS (
    SELECT
        local_date,
        fk_places,
        UNNEST(visits) AS unnested_visits
        /* Using UNNEST(array) will colaspe the array element, creating one row for each element, and duplicating
            selected values for it. For instance:
            SELECT 'A', 'B', UNNEST([1,2,3]);  ==>
            ┌─────────┬─────────┬──────────────────────────────────┐
            │   'A'   │   'B'   │ unnest(main.list_value(1, 2, 3)) │
            │ varchar │ varchar │              int32               │
            ├─────────┼─────────┼──────────────────────────────────┤
            │ A       │ B       │                                1 │
            │ A       │ B       │                                2 │
            │ A       │ B       │                                3 │
            └─────────┴─────────┴──────────────────────────────────┘
        */
    FROM
        visits
)
SELECT 
    local_date,
    fk_places,
    SUM(unnested_visits) AS monthly_visits
FROM unnested
GROUP BY local_date, fk_places
ORDER BY
    local_date,
    fk_places;


/*
                    OUTPUT

First Script:
┌────────────┬──────────────────────────────────────┬────────────────┐
│ local_date │              fk_places               │ monthly_visits │
│    date    │               varchar                │     int128     │
├────────────┼──────────────────────────────────────┼────────────────┤
│ 2024-01-01 │ 022569b7-ce4e-4d1f-9fb5-1da8cfd60e68 │          83665 │
│ 2024-01-01 │ 043a571a-dca5-463b-9a5e-62e48bc36c37 │          76148 │
│ 2024-01-01 │ 0600c7ad-6f65-4a18-954c-c7d67c9df4af │          77708 │
│ 2024-01-01 │ 062cf61f-22d7-4bbb-8bcd-1af7a454b307 │          72096 │
│ 2024-01-01 │ 074a8195-3d7c-441b-8f1c-2ab9b208be88 │          75494 │
│ 2024-01-01 │ 07e01d85-a29e-4cc1-9223-d58316789f55 │          86138 │
│ 2024-01-01 │ 090cd7d4-9b7d-481f-957c-6fd47956d88c │          70783 │
│ 2024-01-01 │ 0cbfd1f6-fd7d-4d8a-89d5-d0ff6afb764b │          67877 │
│ 2024-01-01 │ 0d28a573-4cdf-48b1-aa27-6d13eed9250b │          81513 │
│ 2024-01-01 │ 0ede191a-4876-49c2-a756-a45dd2a97b09 │          73415 │
│ 2024-01-01 │ 0f2baf02-3544-4170-9849-5d61db4e1b75 │          73521 │
│ 2024-01-01 │ 0f790e12-d9bd-446f-a447-23ae4478a997 │          73338 │
│ 2024-01-01 │ 0f8e1bfe-1708-40a2-8748-cc68135662c2 │          71863 │
│ 2024-01-01 │ 10356abb-e667-4c28-b0fe-521ce9418c25 │          84645 │
│ 2024-01-01 │ 10378ba3-4f3c-44b9-adef-19b43501872d │          83710 │
│ 2024-01-01 │ 124d4c3c-edf2-4d92-874c-9e37ad454626 │          80856 │
│ 2024-01-01 │ 125b26c6-bb1c-4896-95ff-79ff75c49c63 │          84137 │
│ 2024-01-01 │ 127c647d-7dca-44bd-bb7d-80943d66981b │          80786 │
│ 2024-01-01 │ 134d3233-be16-459e-bab9-8e51d492d941 │          74847 │
│ 2024-01-01 │ 15cd8b8f-0ece-4e44-b993-164091c8baa0 │          79217 │
│     ·      │                  ·                   │            ·   │
│     ·      │                  ·                   │            ·   │
│     ·      │                  ·                   │            ·   │
│ 2024-12-01 │ e822bdcb-6ed6-4a51-b124-a91885b82f8d │          82167 │
│ 2024-12-01 │ e87f0491-f33f-4376-bad0-fa2d4ba11a8f │          73634 │
│ 2024-12-01 │ ea53da69-b592-44dc-aa63-0c08450fc592 │          74717 │
│ 2024-12-01 │ eda2034d-6414-4acc-80ec-36349606d0b4 │          76718 │
│ 2024-12-01 │ edb6e39d-92ab-4d03-a3c4-8610c11a8312 │          69582 │
│ 2024-12-01 │ f152f1c8-8f73-4d85-aa5c-baba02a5e17d │          88675 │
│ 2024-12-01 │ f1a90df3-a198-4f98-b3c8-d4715039a2b4 │          73026 │
│ 2024-12-01 │ f28d5553-2c73-4275-9b34-1a3c519449c1 │          84502 │
│ 2024-12-01 │ f3664c4a-7018-4b1b-91b5-ac73b28dfbdf │          85729 │
│ 2024-12-01 │ f4022fda-5cdc-4de9-a6e9-695b93c4f056 │          75730 │
│ 2024-12-01 │ f47b13f2-82d5-4bf5-9ea7-bb83cdfa6b57 │          77998 │
│ 2024-12-01 │ f527c4ef-4812-4c2f-992e-3b1c1279af0f │          77421 │
│ 2024-12-01 │ f61fab66-8b4f-4431-b44c-d83a9da126d0 │          73988 │
│ 2024-12-01 │ f7c12be7-0647-48d5-ad37-7e3422753518 │          85469 │
│ 2024-12-01 │ f871f4f1-5e55-4464-b887-4d09d22da0d0 │          69211 │
│ 2024-12-01 │ f88ebd96-1e57-4c3a-ad69-61033b22d9c1 │          67964 │
│ 2024-12-01 │ f985d062-dddf-4ffd-8540-ea0cb6ae3d24 │          69596 │
│ 2024-12-01 │ fa874ad9-8961-4b9e-80ab-2cf215a751a7 │          65979 │
│ 2024-12-01 │ facb8cb1-4195-4566-8c15-d804214112bc │          83223 │
│ 2024-12-01 │ fffd18c5-704a-4aaf-abad-71e4da4843e3 │          81367 │
├────────────┴──────────────────────────────────────┴────────────────┤
│ 3600 rows (40 shown)                                     3 columns │
└────────────────────────────────────────────────────────────────────┘



Second Script:
┌────────────┬──────────────────────────────────────┬────────────────┐
│ local_date │              fk_places               │ monthly_visits │
│    date    │               varchar                │     int128     │
├────────────┼──────────────────────────────────────┼────────────────┤
│ 2024-01-01 │ 022569b7-ce4e-4d1f-9fb5-1da8cfd60e68 │          83665 │
│ 2024-01-01 │ 043a571a-dca5-463b-9a5e-62e48bc36c37 │          76148 │
│ 2024-01-01 │ 0600c7ad-6f65-4a18-954c-c7d67c9df4af │          77708 │
│ 2024-01-01 │ 062cf61f-22d7-4bbb-8bcd-1af7a454b307 │          72096 │
│ 2024-01-01 │ 074a8195-3d7c-441b-8f1c-2ab9b208be88 │          75494 │
│ 2024-01-01 │ 07e01d85-a29e-4cc1-9223-d58316789f55 │          86138 │
│ 2024-01-01 │ 090cd7d4-9b7d-481f-957c-6fd47956d88c │          70783 │
│ 2024-01-01 │ 0cbfd1f6-fd7d-4d8a-89d5-d0ff6afb764b │          67877 │
│ 2024-01-01 │ 0d28a573-4cdf-48b1-aa27-6d13eed9250b │          81513 │
│ 2024-01-01 │ 0ede191a-4876-49c2-a756-a45dd2a97b09 │          73415 │
│ 2024-01-01 │ 0f2baf02-3544-4170-9849-5d61db4e1b75 │          73521 │
│ 2024-01-01 │ 0f790e12-d9bd-446f-a447-23ae4478a997 │          73338 │
│ 2024-01-01 │ 0f8e1bfe-1708-40a2-8748-cc68135662c2 │          71863 │
│ 2024-01-01 │ 10356abb-e667-4c28-b0fe-521ce9418c25 │          84645 │
│ 2024-01-01 │ 10378ba3-4f3c-44b9-adef-19b43501872d │          83710 │
│ 2024-01-01 │ 124d4c3c-edf2-4d92-874c-9e37ad454626 │          80856 │
│ 2024-01-01 │ 125b26c6-bb1c-4896-95ff-79ff75c49c63 │          84137 │
│ 2024-01-01 │ 127c647d-7dca-44bd-bb7d-80943d66981b │          80786 │
│ 2024-01-01 │ 134d3233-be16-459e-bab9-8e51d492d941 │          74847 │
│ 2024-01-01 │ 15cd8b8f-0ece-4e44-b993-164091c8baa0 │          79217 │
│     ·      │                  ·                   │            ·   │
│     ·      │                  ·                   │            ·   │
│     ·      │                  ·                   │            ·   │
│ 2024-12-01 │ e822bdcb-6ed6-4a51-b124-a91885b82f8d │          82167 │
│ 2024-12-01 │ e87f0491-f33f-4376-bad0-fa2d4ba11a8f │          73634 │
│ 2024-12-01 │ ea53da69-b592-44dc-aa63-0c08450fc592 │          74717 │
│ 2024-12-01 │ eda2034d-6414-4acc-80ec-36349606d0b4 │          76718 │
│ 2024-12-01 │ edb6e39d-92ab-4d03-a3c4-8610c11a8312 │          69582 │
│ 2024-12-01 │ f152f1c8-8f73-4d85-aa5c-baba02a5e17d │          88675 │
│ 2024-12-01 │ f1a90df3-a198-4f98-b3c8-d4715039a2b4 │          73026 │
│ 2024-12-01 │ f28d5553-2c73-4275-9b34-1a3c519449c1 │          84502 │
│ 2024-12-01 │ f3664c4a-7018-4b1b-91b5-ac73b28dfbdf │          85729 │
│ 2024-12-01 │ f4022fda-5cdc-4de9-a6e9-695b93c4f056 │          75730 │
│ 2024-12-01 │ f47b13f2-82d5-4bf5-9ea7-bb83cdfa6b57 │          77998 │
│ 2024-12-01 │ f527c4ef-4812-4c2f-992e-3b1c1279af0f │          77421 │
│ 2024-12-01 │ f61fab66-8b4f-4431-b44c-d83a9da126d0 │          73988 │
│ 2024-12-01 │ f7c12be7-0647-48d5-ad37-7e3422753518 │          85469 │
│ 2024-12-01 │ f871f4f1-5e55-4464-b887-4d09d22da0d0 │          69211 │
│ 2024-12-01 │ f88ebd96-1e57-4c3a-ad69-61033b22d9c1 │          67964 │
│ 2024-12-01 │ f985d062-dddf-4ffd-8540-ea0cb6ae3d24 │          69596 │
│ 2024-12-01 │ fa874ad9-8961-4b9e-80ab-2cf215a751a7 │          65979 │
│ 2024-12-01 │ facb8cb1-4195-4566-8c15-d804214112bc │          83223 │
│ 2024-12-01 │ fffd18c5-704a-4aaf-abad-71e4da4843e3 │          81367 │
├────────────┴──────────────────────────────────────┴────────────────┤
│ 3600 rows (40 shown)                                     3 columns │
└────────────────────────────────────────────────────────────────────┘

*/