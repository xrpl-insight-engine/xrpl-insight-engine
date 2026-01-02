\# XRPL Full Discovery Scanner



\## Overview



The \*\*XRPL Full Discovery Scanner\*\* continuously indexes \*\*all issued tokens on the XRP Ledger\*\* by scanning validated ledgers for token-creating activity.



It is designed to be:



\* \*\*Complete\*\* (captures all issued currencies)

\* \*\*Restart-safe\*\*

\* \*\*Production-grade\*\*

\* \*\*Node-friendly\*\*



This scanner forms the \*\*foundation layer\*\* of the \*\*XRPL Insight Engine\*\*, enabling downstream analytics, APIs, and ecosystem transparency tools.



---



\## What This Scanner Discovers



The scanner extracts issued tokens by inspecting the following XRPL transaction types:



\* \*\*TrustSet\*\* — issuer-defined trustlines

\* \*\*Issued Payments\*\* — real token usage

\* \*\*AMMCreate\*\* — liquidity pool creation (critical for meme and DeFi assets)

\* \*\*OfferCreate\*\* — DEX listings and order book activity



For each discovery event, it records:



\* `currency`

\* `issuer`

\* `first\_seen` (derived from ledger progression)



⚠️ \*\*XRP is explicitly excluded\*\* — only issued tokens are indexed.



---



\## Data Model Impact



This scanner writes \*\*only minimal, canonical data\*\* into the database:



\### Tables used



\* `tokens`

\* `scanner\_state`



\### Guarantees



\* No duplicate tokens (conflict-safe inserts)

\* No destructive updates

\* Stateless reprocessing avoided via persisted ledger state



---



\## Restart Safety \& Reliability



The scanner is \*\*fully restart-safe\*\*.



\* Last processed ledger is stored in `scanner\_state`

\* On restart, scanning resumes from the correct ledger

\* A rolling \*\*ledger lookback window\*\* ensures no missed data during outages



This makes the scanner suitable for:



\* Continuous operation

\* Crash recovery

\* Infrastructure restarts



---



\## Configuration



All environment-specific values are loaded from a `.env` file at the project root.



\### Required `.env` variables



```env

XRPL\_WSS\_URL=wss://your-xrpl-node

DB\_HOST=localhost

DB\_PORT=5432

DB\_NAME=alpha\_tokens

DB\_USER=postgres

DB\_PASSWORD=your\_password

```



⚠️ \*\*Never commit `.env` files to GitHub\*\*



---



\## Installation



```bash

npm install

```



This installs:



\* `xrpl` — official XRPL JavaScript SDK

\* `pg` — PostgreSQL client

\* `dotenv` — secure environment loading



---



\## Running the Scanner



```bash

node index.js

```



Expected console output:



\* Startup confirmation

\* Ledger scan range

\* Continuous scan loop activity

\* Error recovery without process termination



---



\## Performance \& Node Safety



Built-in safeguards include:



\* Controlled scan interval (default: 5 minutes)

\* Bounded ledger lookback window

\* Graceful handling of XRPL node request failures

\* Stateless transaction processing



The scanner is safe to run against:



\* Paid nodes

\* Public infrastructure

\* Dedicated XRPL indexer nodes



---



\## Intended Use Cases



This scanner enables:



\* Token discovery APIs

\* Ecosystem analytics dashboards

\* Research and compliance tooling

\* Developer insight platforms

\* Early-stage asset monitoring



It is intentionally designed as \*\*infrastructure\*\*, not a trading bot.



---



\## Role in XRPL Insight Engine



This module is the \*\*entry point\*\* of the Insight Engine pipeline:



```

Ledger → Token Discovery → Trustline Analytics → Momentum Models → Public APIs

```



All higher-level analytics depend on the correctness and completeness of this scanner.



---



\## License



MIT



