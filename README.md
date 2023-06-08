# Data-warehouse-adventure
Educational project

This project was about to analyse of retail business data. There are more than 1M records so far.
There are two sources of data - online and offline sales. The data source is csv files with transactions for a certain period. These sources have a different structure. 
We used the Bill Inmon approach in the development of this data warehouse. All data has been normalized. The data warehouse was modeled as a star schema.
The process of initial loading of data into the data warehouse and incremental loading of updates has been developed. There are tables in the data warehouse with both the first and the second slow change dimension types.
There were created ETL processes to cleanse and normalize data, also created ETL processes for incremental loading and testing data warehouse.
Bash scripts have also been created, for ease of restoring the date of the warehouse.
