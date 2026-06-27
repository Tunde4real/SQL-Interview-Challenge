# Data Engineering Technical Assessment

## General Instructions

### Background
This assessment is designed to evaluate your data engineering skills using realistic scenarios involving places, brands, and visits data. You will work with simulated datasets that represent actual business data.

### Data Preparation
- The datasets you'll receive are dummy versions of real data
- These datasets are representative of what our team would typically serve

### Submission Guidelines
- Use SQL for all data transformations and analysis
- Provide clear, well-commented code
- Include any assumptions or notes about your approach
- You have 1 week to complete the assignment
- Prepare to discuss your solution in detail during the follow-up interview


## The Problem

### Available Datasets
You will be provided with the following datasets:

1. `brands`
   - Contains information about 2-3 specific brands
   - Includes relevant brand metadata and identifiers

2. `places`
   - Contains information about places/points of interest (POIs)

3. `visits`
   - Contains monthly aggregated daily visits
   - Each month's data is stored as a string array of daily visit values
   - Example structure:
     - Column for date (e.g., `2024-01-01`)
     - Identifier for POI (e.g., `276412cd-ebb3-4548-b4c4-53ab984a26d5`)
     - A string array with 31 values representing daily visits for January (e.g., `[4408,1455,4322,663,2688,4272,3914,947,3940,4022,2104,3812,448,1496,2133,2406,4184,3347,3339,2502,2457,4502,2836,1905,1802,268,1604,3843,4669,1456,4249]`)
   - Array length corresponds to the number of days in the month
   - Provides a compact representation of daily visit data

### Tasks

#### Task 1: Data Aggregation

Required Outputs:
- Create a table of monthly visits per point of interest (POI)
- Create a table of weekly visits per brand

#### Task 2: Advanced SQL Operations

Required Outputs:
- Create a table showing the percentage change in total visits to each brand in for `fk_city = '2'` from month to month throughout 2024

#### Task 3: Data Update Scenario

Scenario:
- A member of the business team has identified an issue in the data.
- The brand `Sansom` do not open any of their stores on Sundays, however the data is showing visits for Sundays.
- You are required to update the visits table to reflect this information.

Required Outputs:
- Create a copy of the visits table that correctly shows 0 visits to `Sansom` POIs on Sundays.
