\# Database Requirements – XRPL Insight Engine



This document describes the software requirements for running the

XRPL Insight Engine PostgreSQL database.



This database stores \*\*only public XRPL-derived data\*\* and contains

no secrets, private keys, or user information.



---



\## Required Software



\- PostgreSQL \*\*14 or higher\*\*  

&nbsp; (Tested on PostgreSQL 18.x)



\- PostgreSQL command-line tools:

&nbsp; - `psql`

&nbsp; - `pg\_dump`



---



\## Supported Clients



The database is designed to be accessed directly using:



\- Node.js (`pg`)

\- Python (`psycopg2`)

\- Any PostgreSQL-compatible client or ORM



No ORM is required.



---



\## Optional (Recommended)



\- Read replica for analytics or API workloads

\- Regular logical backups using `pg\_dump`

\- Connection pooling (PgBouncer) for production API usage



---



\## Notes for XRPL Grant Reviewers



\- Schema is fully reproducible from `schema/schema.sql`

\- No application state is stored outside the database

\- All data originates from public XRPL ledger activity



See `database/schema/schema.sql` for full table definitions.



