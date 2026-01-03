# XRPL Insights Engine

> Open-source analytics infrastructure for XRPL-issued assets

XRPL Insights Engine is a modular, open-source analytics pipeline that transforms raw XRPL ledger activity into structured, queryable, and real-time insights for issued assets on the XRP Ledger.

The project is designed as shared ecosystem infrastructure that can be consumed by wallets, explorers, dashboards, researchers, and developers building on XRPL.

---

## Overview

While XRPL data is fully public, meaningful asset-level analytics require significant indexing, aggregation, and normalization work. XRPL Insights Engine addresses this gap by scanning validated ledgers directly and maintaining a continuously updated analytics store for all XRPL-issued tokens.

Key capabilities include:

- Universal token discovery via direct ledger scanning  
- Trustline-based holder analytics with strict safety limits  
- Time-series feature storage for historical analysis  
- Momentum and trend detection across multiple windows  
- Curated discovery feeds for downstream consumption  

All data is derived exclusively from public XRPL ledger transactions.

---

## Core Components

- Ledger Scanner – discovers all issued tokens directly from XRPL ledgers  
- Trustline Scanner – safe holder-count analytics  
- Feature Store – latest-state + time-series analytics  
- Momentum Engine – market-cap–aware trend detection  
- Feed Ranker – ranked discovery feed for applications  

---

## Status

🚧 Active Development  
**Current milestone:** Public API Development

---

## Documentation

- Architecture – docs/ARCHITECTURE.md  
- API Reference – docs/API_REFERENCE.md  
- Contributing – CONTRIBUTING.md  

---

## License

MIT License – see LICENSE

---

## Funding

Supported by the XRPL Grants Program  
https://xrplgrants.org
