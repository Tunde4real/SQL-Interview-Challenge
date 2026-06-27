/* After installing duckdb and veryfying it works on the terminal, create the database to use with the command ->
    duckdb {db_name}.duckdb -c ""

    Use the following command to run on terminal ->
    duckdb {db_name}.duckdb -c ".read solution/00/00_prep.sql"  
*/

-- Droping tables for idempotency
-- Droping must be in order of one with the most dependants (i.e foreign key(s)) to the one with none.
DROP TABLE IF EXISTS visits;
DROP TABLE IF EXISTS places;
DROP TABLE IF EXISTS brands;

-- Tables must be created from the order of the one with no dependants (i.e foreign key),
-- to the table it depends on, and like that.

-- Create and insert into brands table
SELECT '=== Creating brands table ===' AS info;
CREATE TABLE brands(
    pid     VARCHAR     PRIMARY KEY,
    name    VARCHAR
);
SELECT '=== Inserting data into brands table ===' AS info;
INSERT INTO brands(
    pid,
    name
)
SELECT
    pid, name
FROM read_csv('pby-ce-de-test/data/brands.csv',
    AUTO_DETECT=true,
    HEADER=true);


-- Create and insert into places table
SELECT '=== Creating places table ===' AS info;
CREATE TABLE places(
    pid         VARCHAR     PRIMARY KEY,
    fk_brands   VARCHAR,
    fk_city     INTEGER,
    FOREIGN KEY (fk_brands) REFERENCES brands(pid)
);
SELECT '=== Inserting data into places table ===' AS info;
INSERT INTO places(
    pid,
    fk_brands,
    fk_city
)
SELECT
    pid,
    fk_brands,
    fk_city
FROM read_csv('pby-ce-de-test/data/places.csv',
    AUTO_DETECT=true,
    HEADER=true);


-- Create and insert into visits table
SELECT '=== Creating visits table ===' AS info;
CREATE TABLE visits(
    local_date  DATE,
    fk_places   VARCHAR,
    visits      INTEGER[],
    FOREIGN KEY (fk_places) REFERENCES places(pid)
);
SELECT '=== Inserting data into visits table ===' AS info;
INSERT INTO visits(
    local_date,
    fk_places,
    visits
)
SELECT
    local_date,
    fk_places,
    visits
FROM read_csv('pby-ce-de-test/data/visits.csv',
    AUTO_DETECT=true,
    HEADER=true);


SELECT '=== Creation and Insertion of all tables done ===' AS info;



--          DATA VALIDATION CHECKS
SELECT 'brands' AS table_name, COUNT(*) AS row_count FROM brands
UNION ALL
SELECT 'places' AS table_name, COUNT(*) AS row_count FROM places
UNION ALL
SELECT 'visits' AS table_name, COUNT(*) AS row_count FROM visits;



/*
                    OUTPUT

┌───────────────────────────────┐
│             info              │
│            varchar            │
├───────────────────────────────┤
│ === Creating brands table === │
└───────────────────────────────┘
┌──────────────────────────────────────────┐
│                   info                   │
│                 varchar                  │
├──────────────────────────────────────────┤
│ === Inserting data into brands table === │
└──────────────────────────────────────────┘
┌───────────────────────────────┐
│             info              │
│            varchar            │
├───────────────────────────────┤
│ === Creating places table === │
└───────────────────────────────┘
┌──────────────────────────────────────────┐
│                   info                   │
│                 varchar                  │
├──────────────────────────────────────────┤
│ === Inserting data into places table === │
└──────────────────────────────────────────┘
┌───────────────────────────────┐
│             info              │
│            varchar            │
├───────────────────────────────┤
│ === Creating visits table === │
└───────────────────────────────┘
┌──────────────────────────────────────────┐
│                   info                   │
│                 varchar                  │
├──────────────────────────────────────────┤
│ === Inserting data into visits table === │
└──────────────────────────────────────────┘
┌───────────────────────────────────────────────────┐
│                       info                        │
│                      varchar                      │
├───────────────────────────────────────────────────┤
│ === Creation and Insertion of all tables done === │
└───────────────────────────────────────────────────┘
┌────────────┬───────────┐
│ table_name │ row_count │
│  varchar   │   int64   │
├────────────┼───────────┤
│ brands     │         3 │
│ places     │       300 │
│ visits     │      3600 │
└────────────┴───────────┘
*/