# SQL Interview Challenge

This challenge is designed to test SQL skills for data transformation and analysis. It models an environment with heavy SQL workloads, where only SQL is allowed for data transformation, and not python for instance, as well as data analysis, using dummy versions of real world data.


## 📂 Repository Structure
```text
challenge/
├── data/           # contains csv files of dummy data
├── ERD.png         # Schema diagram
├── README.md       # Readme file for challenge

solution/
├── 00_prep.sql     # Data preparation - tables creation with schema implementation
├── ...             # The rest are files containing solutions numbered to the respective problems given in the challenge.

README.md       # You're here
```


## 🧠 Knowledge required to scale this challenge
This challenge touches on:
- Dealing with compact data design, slowly changing dimensions.
- Advanced SQL operations; nested data types, window functions, joins, subqueries, CTEs.


## 🛠️ Setup
I used VS-Code, and duckdb for it's ease in integration with VS-Code. Since it's an embedded, lightweight database, it allows running SQL code in the terminal, without connecting to external services like docker, or a separate database server.

You can install duckdb by following instructions on the [official DuckDB install page](https://duckdb.org/install/?platform=macos&environment=cli).
