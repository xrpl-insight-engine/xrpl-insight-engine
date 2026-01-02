import asyncio
import asyncpg
import math
import os
from dotenv import load_dotenv

load_dotenv("../../.env")

DB_DSN = (
    f"postgresql://{os.getenv('DB_USER')}:"
    f"{os.getenv('DB_PASSWORD')}@"
    f"{os.getenv('DB_HOST')}:"
    f"{os.getenv('DB_PORT')}/"
    f"{os.getenv('DB_NAME')}"
)

if "None" in DB_DSN:
    raise RuntimeError("Database environment variables not set correctly")

WINDOWS = {
    "15m": "15 minutes",
    "1h": "1 hour",
    "6h": "6 hours",
    "24h": "24 hours",
}

LIQUIDITY_CAP_MULTIPLIER = 3.0
MIN_CAP_FLOOR = 5_000.0
RATIO_CAP = 5.0


def safe_ratio(delta, baseline, cap=RATIO_CAP):
    if baseline <= 0:
        return 0.0
    return max(min(delta / baseline, cap), -cap)


def signed_log(x):
    if x == 0:
        return 0.0
    return math.copysign(math.log1p(abs(x)), x)


async def latest_snapshot(conn, token_id):
    return await conn.fetchrow("""
        SELECT liquidity_xrp, holders
        FROM token_feature_snapshots
        WHERE token_id = $1
        ORDER BY snapshot_time DESC
        LIMIT 1
    """, token_id)


async def snapshot_before(conn, token_id, window_sql):
    return await conn.fetchrow(f"""
        SELECT liquidity_xrp, holders
        FROM token_feature_snapshots
        WHERE token_id = $1
          AND snapshot_time <= NOW() - INTERVAL '{window_sql}'
        ORDER BY snapshot_time DESC
        LIMIT 1
    """, token_id)


def effective_market_cap(base_liquidity):
    return max(base_liquidity * LIQUIDITY_CAP_MULTIPLIER, MIN_CAP_FLOOR)


async def update_token(conn, token_id):
    latest = await latest_snapshot(conn, token_id)
    if not latest:
        return False

    base = await snapshot_before(conn, token_id, WINDOWS["24h"])
    if not base:
        return False

    cap_baseline = effective_market_cap(base["liquidity_xrp"] or 0)

    def delta(w):
        snap = asyncio.run(snapshot_before(conn, token_id, WINDOWS[w]))
        if not snap:
            return 0.0, 0
        return (
            (latest["liquidity_xrp"] or 0) - (snap["liquidity_xrp"] or 0),
            (latest["holders"] or 0) - (snap["holders"] or 0)
        )

    liq_15m, _ = delta("15m")
    liq_1h, _ = delta("1h")
    liq_6h, _ = delta("6h")

    _, h_1h = delta("1h")
    _, h_6h = delta("6h")
    _, h_24h = delta("24h")

    momentum = (
        signed_log(safe_ratio(liq_15m, cap_baseline)) * 0.35 +
        signed_log(safe_ratio(liq_1h, cap_baseline)) * 0.30 +
        signed_log(safe_ratio(liq_6h, cap_baseline)) * 0.15 +
        signed_log(safe_ratio(h_1h, 50)) * 0.10 +
        signed_log(safe_ratio(h_6h, 50)) * 0.05 +
        signed_log(safe_ratio(h_24h, 50)) * 0.05
    )

    await conn.execute("""
        INSERT INTO token_momentum (
            token_id, momentum_score, last_updated
        )
        VALUES ($1,$2,NOW())
        ON CONFLICT (token_id)
        DO UPDATE SET
            momentum_score = EXCLUDED.momentum_score,
            last_updated = NOW()
    """, token_id, momentum)

    return True


async def main():
    print("🧠 MomentumUpdater started")
    conn = await asyncpg.connect(DB_DSN)

    rows = await conn.fetch("SELECT DISTINCT token_id FROM token_feature_snapshots")
    for r in rows:
        await update_token(conn, r["token_id"])

    await conn.close()


if __name__ == "__main__":
    asyncio.run(main())
