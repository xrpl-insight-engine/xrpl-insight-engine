import psycopg2
import os
from dotenv import load_dotenv

load_dotenv("../../.env")

DB_CONFIG = {
    "dbname": os.getenv("DB_NAME"),
    "user": os.getenv("DB_USER"),
    "password": os.getenv("DB_PASSWORD"),
    "host": os.getenv("DB_HOST"),
    "port": int(os.getenv("DB_PORT")),
}

if None in DB_CONFIG.values():
    raise RuntimeError("Database environment variables not set correctly")

MAX_FEED_SIZE = 200
MIN_ALPHA = 0.25
MIN_MEME = 0.30

W_ALPHA = 0.45
W_MEME = 0.35
W_MOMENTUM = 0.20


def run():
    print("🧮 Feed Ranker started")
    conn = psycopg2.connect(**DB_CONFIG)
    conn.autocommit = True

    with conn.cursor() as cur:
        cur.execute("DELETE FROM shortlisted_tokens;")

        cur.execute("""
            SELECT
                t.id,
                t.alpha_score,
                t.meme_score,
                m.momentum_score,
                EXTRACT(EPOCH FROM (NOW() - t.first_seen)) / 3600
            FROM tokens t
            LEFT JOIN token_momentum m ON m.token_id = t.id
            WHERE t.rejected = false
        """)

        rows = cur.fetchall()
        scored = []

        for token_id, alpha, meme, momentum, age_hours in rows:
            score = (
                (alpha or 0) * W_ALPHA +
                (meme or 0) * W_MEME +
                (momentum or 0) * W_MOMENTUM
            )

            if score > 0:
                scored.append((token_id, score, []))

        scored.sort(key=lambda x: x[1], reverse=True)
        scored = scored[:MAX_FEED_SIZE]

        for token_id, score, reasons in scored:
            cur.execute("""
                INSERT INTO shortlisted_tokens (
                    token_id, shortlist_score, reasons, last_updated
                )
                VALUES (%s,%s,%s,NOW())
            """, (token_id, score, reasons))

    conn.close()
    print("✅ Feed Ranker complete")


if __name__ == "__main__":
    run()
