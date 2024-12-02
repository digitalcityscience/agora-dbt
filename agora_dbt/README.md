Welcome to your new dbt project!

### Using the starter project

Try running the following commands:
- dbt run
- dbt test


## Materialization Types in DBT

DBT supports different materialization types that define how your models are created and stored in the database. Each type has specific use cases, advantages, and disadvantages. Below is a summary:

| Materialization | Use Case                                                                                 | Advantages                            | Disadvantages                                  |
|-----------------|------------------------------------------------------------------------------------------|---------------------------------------|-----------------------------------------------|
| `view`          | Small datasets, frequently changing data (staging).                                      | Lightweight, always up-to-date.       | Performance degradation with large datasets.  |
| `table`         | Medium-sized datasets, analytical or reporting-focused tables.                           | Fast querying, provides static data.  | Costly to rebuild with large datasets.        |
| `incremental`   | Large datasets, cases requiring historical data addition or change tracking.             | High performance, processes only new data. | Complex setup, potential synchronization issues. |

### Key Takeaways
- Use **`view`** for staging or frequently updated data that needs to remain lightweight and fresh.
- Use **`table`** for stable datasets or analytics where performance is critical but data changes infrequently.
- Use **`incremental`** for large, continuously growing datasets where processing only new or changed data improves efficiency.

### Example Configurations
To specify the materialization type in DBT, use the `config` macro in your model file:



### Resources:
- Learn more about dbt [in the docs](https://docs.getdbt.com/docs/introduction)
- Check out [Discourse](https://discourse.getdbt.com/) for commonly asked questions and answers
- Join the [chat](https://community.getdbt.com/) on Slack for live discussions and support
- Find [dbt events](https://events.getdbt.com) near you
- Check out [the blog](https://blog.getdbt.com/) for the latest news on dbt's development and best practices
