#!/usr/bin/env python3
"""
Feature Store
• Maintains latest token features
• Appends time-series snapshots for ML
"""

import asyncio
import asyncpg
import os
from dotenv import load_dotenv

load_dotenv("../../.env")

INGEST_INTERVAL_SECONDS = 60

POSTGRES_DSN = (
    f"postgresql://{os.getenv('DB_USER')}:"
    f"{os.getenv('DB_PASSWORD')}@"
    f"{os.getenv('DB_HOST')}:"
    f"{os.getenv('DB_PORT')}/"
    f"{os.getenv('DB_NAME')}"
)

if "None" in POSTGRES_DSN:
    raise RuntimeError("Database environment variables not set correctly")


async def main():
    print("🚀 Feature Store started")

    pool = await asyncpg.create_pool(POSTGRES_DSN)
    total_snapshots = 0

    while True:
        try:
            async with pool.acquire() as conn:
                rows = await conn.fetch("""
                    SELECT
                        id,
                        liquidity_xrp,
                        holders,
                        alpha_score,
                        canonical_confidence,
                        EXTRACT(EPOCH FROM (NOW() - first_seen)) AS age_seconds
                    FROM tokens
                    WHERE is_canonical = true
                      AND rejected = false
                """)

                if not rows:
                    print("⚠️ FeatureStore: no canonical tokens yet")
                    await asyncio.sleep(INGEST_INTERVAL_SECONDS)
                    continue

                for r in rows:
                    await conn.execute("""
                        INSERT INTO token_features (
                            token_id,
                            liquidity_xrp,
                            holders,
                            alpha_score,
                            age_seconds,
                            canonical_confidence,
                            last_updated
                        )
                        VALUES ($1,$2,$3,$4,$5,$6,NOW())
                        ON CONFLICT (token_id)
                        DO UPDATE SET
                            liquidity_xrp = EXCLUDED.liquidity_xrp,
                            holders = EXCLUDED.holders,
                            alpha_score = EXCLUDED.alpha_score,
                            age_seconds = EXCLUDED.age_seconds,
                            canonical_confidence = EXCLUDED.canonical_confidence,
                            last_updated = NOW()
                    """,
                        r["id"],
                        r["liquidity_xrp"],
                        r["holders"],
                        r["alpha_score"],
                        r["age_seconds"],
                        r["canonical_confidence"]
                    )

                    await conn.execute("""
                        INSERT INTO token_feature_snapshots (
                            token_id,
                            liquidity_xrp,
                            holders,
                            alpha_score,
                            age_seconds,
                            canonical_confidence
                        )
                        VALUES ($1,$2,$3,$4,$5,$6)
                    """,
                        r["id"],
                        r["liquidity_xrp"],
                        r["holders"],
                        r["alpha_score"],
                        r["age_seconds"],
                        r["canonical_confidence"]
                    )

                total_snapshots += len(rows)
                print(f"📊 FeatureStore: ingested {len(rows)} snapshots "
                      f"(total {total_snapshots})")

        except Exception as e:
            print(f"❌ FeatureStore error: {repr(e)}")

        await asyncio.sleep(INGEST_INTERVAL_SECONDS)


if __name__ == "__main__":
    asyncio.run(main())
