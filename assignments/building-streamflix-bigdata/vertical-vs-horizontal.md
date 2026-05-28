# Week 3: Big Data Scaling Strategy

StreamFlix went viral. Now what?

---

## Vertical Scaling (Scale Up)

This is the obvious first move. Your database is struggling, so you throw more hardware at it. More CPU cores, more RAM, faster disks, same machine.

Say your Supabase PostgreSQL instance is falling behind on writes. You bump it from 2 cores / 8 GB RAM to 16 cores / 64 GB RAM. Same server, just bigger.

This works fine up to a point. The problem is there's always a ceiling. You can only make one machine so big before the cost explodes, and you still have a single point of failure. If that server goes down, everything goes down.

---

## Horizontal Scaling (Scale Out)

Instead of one big machine, you use a lot of smaller ones that split the work between them.

Apache Spark is built for this. A Spark cluster can have 10 nodes, 50 nodes, 500 nodes. Each node handles a slice of the data in parallel. You can add more nodes as traffic grows, and if one node dies the others keep running.

The tradeoff is that it's a lot more complex to set up and run than a single PostgreSQL instance.

---

## Where PostgreSQL Runs Out of Road

PostgreSQL is a single-node database. Every INSERT is synchronous: the row gets validated, written to disk, and acknowledged before the next one starts. That's the right behavior for transactional data. It's a problem for high-velocity event streams.

| Constraint | Practical limit |
|---|---|
| Write throughput | ~10,000 to 50,000 rows/second, well-tuned |
| Concurrent connections | Starts degrading above ~500 |
| Dataset size | Workable up to ~1-10 TB |
| Streaming ingestion | Not what it was built for |

---

## The 500 Million Events/Hour Problem

500 million play/pause events per hour works out to about **138,000 events per second**.

PostgreSQL tops out around 50,000 writes/second in ideal conditions. At 138,000/second, the write queue backs up faster than it clears. Read performance tanks. The dashboard slows down. Eventually the whole instance struggles.

That is the threshold. When event velocity is too high for a single node to absorb in real time, vertical scaling stops helping and you need to scale out.

---

## PostgreSQL vs Spark

| Factor | PostgreSQL | Apache Spark |
|---|---|---|
| Architecture | Single node | Distributed cluster |
| Scaling model | Vertical | Horizontal |
| Write model | Synchronous, row by row | Batch or streaming, parallel |
| Schema | Schema-on-Write | Schema-on-Read |
| Fault tolerance | Single point of failure | Survives node loss |
| Sweet spot | Under 10M events/hour | Over 100M events/hour |

---

## When to Make the Switch

A few signs you have crossed the line:

- Event rate is above ~50M/hour and climbing
- Write queue is backing up under load
- Analytics queries are slowing down production reads
- You need to ingest first and figure out schema later
- A single node going down would take out the whole stream

---

## What the Architecture Looks Like

```
500M events/hour
       |
       v
 [ Kafka / Kinesis ]     <-- buffer the incoming stream
       |
       v
 [ Spark Cluster ]       <-- N nodes processing in parallel
       |
       +---> [ Data Lake ]      raw archive (S3, HDFS)
       |
       +---> [ PostgreSQL ]     aggregated results only
```

PostgreSQL does not disappear. It stays in the stack for structured data like movie records, user accounts, and pre-aggregated stats. It just stops being the place where raw events land.

---

## Summary

Vertical scaling buys time. At 500M events/hour, that time has run out. Spark handles the stream, PostgreSQL handles the clean data that comes out of it.
