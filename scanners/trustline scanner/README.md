\# XRPL Trustline Scanner



\## Overview



The Trustline Scanner measures \*\*real holder adoption\*\* for XRPL-issued tokens by

safely counting non-zero trustlines per issuer.



This module is part of the \*\*XRPL Insight Engine\*\*, providing on-ledger analytics

for traders, analysts, and developers.



Unlike naive scans, this scanner is \*\*bounded, restart-safe, and production-hardened\*\*

to avoid XRPL node overload and runaway issuers.



---



\## What This Scanner Does



For each selected token:

\- Scans issuer trustlines via `AccountLines`

\- Counts \*\*unique accounts with non-zero balances\*\*

\- Updates:

&nbsp; - `token\_features` (latest state)

&nbsp; - `tokens` (fast-access fields)

&nbsp; - `token\_feature\_snapshots` (time-series analytics)



---



\## Safety \& Reliability Guarantees



This scanner is designed to \*\*never hang or overload XRPL nodes\*\*.



Built-in protections:

\- ⏱️ Hard wall-clock timeout per issuer

\- 📄 Maximum pagination limit per issuer

\- 🧮 Holder cap to stop runaway scans

\- 🔌 Automatic websocket reconnect safety

\- 🧊 Cooldown window to avoid re-scanning noise



These constraints make it suitable for \*\*continuous production operation\*\*.



---



\## Configuration



Secrets and environment-specific values are loaded via `.env`:



```env

XRPL\_WSS\_URL=wss://your-xrpl-node

DB\_HOST=localhost

DB\_PORT=5432

DB\_NAME=alpha\_tokens

DB\_USER=postgres

DB\_PASSWORD=your\_password



