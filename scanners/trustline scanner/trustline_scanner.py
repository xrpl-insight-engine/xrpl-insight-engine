import os
import time
import psycopg2
from xrpl.clients import WebsocketClient
from xrpl.models.requests import AccountLines
from dotenv import load_dotenv

# =========================
# ENV
# =========================

load_dotenv()  # reads .env locally (never committed)

XRPL_URL = os.getenv("XRPL_WSS_URL")

DB_CONFIG = {
    "dbname": os.getenv("DB_NAME"),
    "user": os.getenv("DB_USER"),
    "password": os.getenv("DB_PASSWORD"),
    "host": os.getenv("DB_HOST"),
    "port": int(os.getenv("DB_PORT", 5432)),
}

# =========================
# SCAN PARAMETERS
# =========================

MAX_TOKENS_PER_RUN = 40
SCAN_COOLDOWN_HOURS = 6

# Safety limits (CRITICAL)
MAX_PAGES_PER_ISSUER = 12        # prevents gateway lockups
MAX_SCAN_SECONDS = 25            # hard wall-clock cutoff
MAX_HOLDERS_CAP = 20_000         # stop runaway issuers

# =========================
# TOKEN SELECTION
# =========================

def fetch_tokens_to_scan(conn):
    """
    Scan ONLY high-probability tokens.
    Avoids gateways and old noise.
    """
    with conn.cursor() as cur:
        cur.execute(
            """
            SELECT
                t.id,
                t.currency,
                t.issuer
            FROM tokens t
            LEFT JOIN token_features f ON f.token_id = t.id
            WHERE
                t.rejected = false
                AND (
                    f.last_updated IS NULL
                    OR f.last_updated < NOW() - INTERVAL %s
                )
                AND (
                    t.meme_score >= 0.4
                    OR t.alpha_score >= 0.4
                    OR t.first_seen >= NOW() - INTERVAL '48 hours'
                )
            ORDER BY f.last_updated NULLS FIRST
            LIMIT %s;
            """,
            (f"{SCAN_COOLDOWN_HOURS} hours", MAX_TOKENS_PER_RUN),
        )
        return cur.fetchall()

# =========================
# TRUSTLINE SCAN (SAFE)
# =========================

def count_trustline_holders(currency, issuer):
    """
    Bounded, reconnect-safe AccountLines scan.
    Never hangs.
    """
    holders = set()
    marker = None
    pages = 0
    start_time = time.time()

    while True:
        if pages >= MAX_PAGES_PER_ISSUER:
            break

        if time.time() - start_time > MAX_SCAN_SECONDS:
            break

        try:
            with WebsocketClient(XRPL_URL) as client:
                req = AccountLines(
                    account=issuer,
                    limit=400,
                    marker=marker
                )
                resp = client.request(req)

                if not resp.is_successful():
                    break

                result = resp.result

                for line in result.get("lines", []):
                    if line.get("currency") == currency:
                        try:
                            balance = float(line.get("balance", 0))
                        except ValueError:
                            continue

                        if balance != 0:
                            holders.add(line.get("account"))

                            if len(holders) >= MAX_HOLDERS_CAP:
                                return MAX_HOLDERS_CAP

                marker = result.get("marker")
                pages += 1

                if not marker:
                    break

        except Exception:
            # XRPL socket instability → exit safely
            break

    return len(holders)

# =========================
# DATABASE UPDATES
# =========================

def update_holder_count(conn, token_id, holders):
    with conn.cursor() as cur:
        cur.execute(
            """
            INSERT INTO token_features (
                token_id,
                holders,
                last_updated,
                source
            )
            VALUES (%s, %s, NOW(), 'trustline_scanner')
            ON CONFLICT (token_id)
            DO UPDATE SET
                holders = EXCLUDED.holders,
                last_updated = NOW(),
                source = 'trustline_scanner';
            """,
            (token_id, holders),
        )

        cur.execute(
            """
            UPDATE tokens
            SET holders = %s,
                last_scanned = NOW()
            WHERE id = %s;
            """,
            (holders, token_id),
        )

        cur.execute(
            """
            INSERT INTO token_feature_snapshots (
                token_id,
                snapshot_time,
                holders
            )
            VALUES (%s, NOW(), %s);
            """,
            (token_id, holders),
        )

    conn.commit()

# =========================
# MAIN RUNNER
# =========================

def run():
    print("🔍 Trustline Scanner started (safe mode)")
    conn = psycopg2.connect(**DB_CONFIG)

    tokens = fetch_tokens_to_scan(conn)
    print(f"📦 Tokens queued: {len(tokens)}")

    scanned = 0

    for token_id, currency, issuer in tokens:
        try:
            holders = count_trustline_holders(currency, issuer)
            update_holder_count(conn, token_id, holders)
            scanned += 1
            print(f"✅ {currency}: {holders} holders")
            time.sleep(1.1)

        except Exception as e:
            print(f"⚠️ {currency} failed: {e}")
            time.sleep(1.5)

    conn.close()
    print(f"🏁 Trustline scan complete — {scanned} tokens updated")

# =========================
# ENTRY
# =========================

if __name__ == "__main__":
    run()
