# Week 4: Data Warehouse vs Data Lake

---

## Schema-on-Write

Data gets formatted and validated before it is stored. The schema exists first, and every row has to fit it on the way in.

PostgreSQL works this way. You define columns, types, and constraints upfront. An INSERT that does not match the schema gets rejected. This keeps the data clean and queries fast, but it means ingestion is slower and you have to know your data structure before you start collecting it.

Good for: structured business data you will query repeatedly. Movie records, user accounts, ratings.

Not good for: anything high-velocity or messy where you cannot afford to validate every event before writing it.

---

## Schema-on-Read

Raw data gets stored immediately in whatever format it arrives. Structure is applied later, at query time.

S3 with raw JSON logs works this way. You dump everything in as-is. When you actually need to analyze it, you write a query that interprets the structure at read time. Ingestion is fast because there is no validation step. The tradeoff is that data quality is your problem at query time, not storage time.

Good for: high-velocity streams, messy or evolving data, things you want to capture now and figure out later.

Not good for: data you need to query consistently with guaranteed structure.

---

## Comparison

| Factor | Data Warehouse (PostgreSQL) | Data Lake |
|---|---|---|
| Schema model | Schema-on-Write | Schema-on-Read |
| When schema is defined | Before storage | At query time |
| Data quality | Enforced on insert | Variable, checked at read |
| Ingestion speed | Slower | Fast |
| Structure flexibility | Rigid | Flexible |
| Best for | Structured, relational data | Raw, high-velocity, exploratory |
| Example | Movies, ratings, user accounts | Click logs, event streams, raw API responses |

---

## The Click-Stream Scenario

StreamFlix is logging every play, pause, scrub, and buffer event from every user. That is millions of raw events per hour in whatever format the client sends them.

**Where does this go: PostgreSQL or a Data Lake?**

Data Lake.

A few reasons:

- The volume is too high for synchronous PostgreSQL inserts. Each event would have to be validated and written to disk before the next one starts.
- The logs are messy. Client events rarely arrive in a perfectly consistent format.
- The schema will probably change. New event types get added, fields get renamed, clients send unexpected data.
- You do not need to query this data immediately. You want to capture it now and analyze it later when you know what questions you are asking.

Trying to force raw click logs into PostgreSQL creates a write bottleneck and a schema maintenance problem. The Data Lake takes everything in fast, and you define structure only when you are ready to use it.

---

## Real-World Examples

**PostgreSQL (Schema-on-Write):**
- The StreamFlix movies catalog
- User account records
- Ratings and reviews
- Anything that feeds a dashboard or a JOIN query

**Data Lake (Schema-on-Read):**
- Raw play/pause event logs
- Server access logs
- Mobile app crash reports
- Third-party API responses cached for later processing

---

## Summary

Schema-on-Write trades ingestion speed for data quality and query simplicity. Schema-on-Read trades data quality guarantees for ingestion speed and flexibility. For StreamFlix, structured catalog data belongs in PostgreSQL and raw event streams belong in the Data Lake.
