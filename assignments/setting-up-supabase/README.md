# Week 1: Your First Cloud Database

## Assignment Overview
Provision a cloud-hosted PostgreSQL instance on Supabase and execute a status check query to verify connectivity.

## Tasks Completed

### Task 1: Project Setup
- Created Supabase account using GitHub authentication
- Provisioned new project: `DB-Tech-Week-1`
- Selected region: West US (Oregon)
- Database instance: us-west-2 · t4g.nano
- Status: Healthy ✓

### Task 2: SQL Version Check
Executed the following query in Supabase SQL Editor:

```sql-- This query checks the version of your PostgreSQL database
SELECT version();

**Result:**PostgreSQL 17.6 on aarch64-unknown-linux-gnu, compiled by gcc (GCC)

### Task 3: Reflection
**Question:** Based on our lecture on "Cloud vs. Traditional Databases," what is one advantage you noticed about setting up your database this way compared to installing software on your own computer?

**Answer:** Supabase eliminates the longer setup times, has scalability at the click of a button, and doesn't require your own hardware to keep it accessible.

## What I Learned

### Technical Skills
- How to provision a PostgreSQL instance on Supabase
- Navigating the Supabase dashboard and SQL Editor
- Executing basic SQL queries for database health checks
- Understanding PostgreSQL version information

### Key Concepts
- **Cloud Database Advantages:**
  - Zero local installation required
  - Instant provisioning (seconds vs hours)
  - Built-in scalability without hardware management
  - Accessible from anywhere with internet connection
  - Automatic backups and monitoring

- **Supabase Platform Features:**
  - Integrated SQL Editor for quick queries
  - Real-time status monitoring
  - Regional deployment options for latency optimization
  - GitHub-based authentication

## Project Details

**Database Information:**
- Project Name: DB-Tech-Week-1
- PostgreSQL Version: 17.6
- Architecture: aarch64-unknown-linux-gnu
- Region: us-west-2 (West US - Oregon)
- Instance Type: t4g.nano
- Status: Healthy
- Connection URL: `https://qpnxyuugnmkghuvsidmj.supabase.co`

## Key Takeaways

1. **Setup Efficiency:** Cloud databases eliminate installation complexity. No need to download PostgreSQL, configure environment variables, or manage server processes.

2. **Instant Scalability:** Supabase allows upgrading database resources with a single click, unlike local installations that require hardware purchases and reconfiguration.

3. **Infrastructure Abstraction:** The platform handles backups, security patches, and monitoring automatically, letting developers focus on building applications rather than managing infrastructure.

4. **Accessibility:** Cloud-hosted databases are accessible from any device with internet, enabling collaborative development and remote work.

## Time Breakdown

- **Total Hours:** 2 hours
  - Supabase account setup and project creation: 0.5 hours
  - SQL Editor exploration and query execution: 0.5 hours
  - Screenshot capture and documentation: 0.5 hours
  - PDF compilation and submission: 0.5 hours

## Deliverables

- ✅ Screenshot of Supabase dashboard showing project name
- ✅ Screenshot of `SELECT version();` query results
- ✅ Reflection on cloud vs traditional database advantages
- ✅ Submitted PDF: `First_Cloud_Database.pdf`

## Files in This Directory
