/**
 * XRPL FULL DISCOVERY SCANNER
 * --------------------------
 * Discovers ALL XRPL-issued tokens by scanning:
 *  - TrustSet
 *  - Issued Payments
 *  - AMMCreate
 *  - OfferCreate
 *
 * Writes ONLY (currency, issuer, first_seen) into tokens
 * Restart-safe via scanner_state
 * CommonJS compatible
 */

/* =========================
   ENV (MUST BE FIRST)
========================= */

require("dotenv").config({ path: "../../.env" });

/* =========================
   IMPORTS
========================= */

const xrpl = require("xrpl");
const { Pool } = require("pg");

/* =========================
   CONFIG
========================= */

const XRPL_URL = process.env.XRPL_WSS_URL;
const RUN_INTERVAL_MS = 5 * 60 * 1000; // 5 minutes
const LEDGER_LOOKBACK = 1500;          // ~2 hours safety window

if (!XRPL_URL) {
  throw new Error(
    "XRPL_WSS_URL is not set. Check your .env file at project root."
  );
}

const DB = new Pool({
  host: process.env.DB_HOST,
  port: Number(process.env.DB_PORT),
  database: process.env.DB_NAME,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
});

/* =========================
   SCANNER STATE
========================= */

async function getLastLedger() {
  const res = await DB.query(
    `SELECT value FROM scanner_state WHERE key = 'last_scanned_ledger'`
  );
  return res.rows.length ? Number(res.rows[0].value) : null;
}

async function setLastLedger(ledgerIndex) {
  await DB.query(
    `
    INSERT INTO scanner_state (key, value)
    VALUES ('last_scanned_ledger', $1)
    ON CONFLICT (key)
    DO UPDATE SET value = EXCLUDED.value, updated_at = NOW()
    `,
    [String(ledgerIndex)]
  );
}

/* =========================
   HELPERS
========================= */

function isIssuedCurrency(obj) {
  return obj && typeof obj === "object" && obj.currency && obj.issuer;
}

function isValidXRPLCurrency(currency) {
  if (!currency) return false;
  if (currency === "XRP") return false;
  return true;
}

async function insertToken(currency, issuer) {
  if (!isValidXRPLCurrency(currency)) return;

  await DB.query(
    `
    INSERT INTO tokens (currency, issuer)
    VALUES ($1, $2)
    ON CONFLICT (currency, issuer) DO NOTHING
    `,
    [currency, issuer]
  );
}

/* =========================
   EXTRACTION LOGIC
========================= */

function extractFromTransaction(tx) {
  const found = [];

  // 1️⃣ TrustSet
  if (tx.TransactionType === "TrustSet" && isIssuedCurrency(tx.LimitAmount)) {
    found.push(tx.LimitAmount);
  }

  // 2️⃣ Issued Payment
  if (tx.TransactionType === "Payment" && isIssuedCurrency(tx.Amount)) {
    found.push(tx.Amount);
  }

  // 3️⃣ AMMCreate
  if (tx.TransactionType === "AMMCreate") {
    if (isIssuedCurrency(tx.Amount)) found.push(tx.Amount);
    if (isIssuedCurrency(tx.Amount2)) found.push(tx.Amount2);
  }

  // 4️⃣ OfferCreate
  if (tx.TransactionType === "OfferCreate") {
    if (isIssuedCurrency(tx.TakerGets)) found.push(tx.TakerGets);
    if (isIssuedCurrency(tx.TakerPays)) found.push(tx.TakerPays);
  }

  return found;
}

/* =========================
   CORE SCAN
========================= */

async function runScan() {
  const client = new xrpl.Client(XRPL_URL);
  await client.connect();

  const info = await client.request({ command: "server_info" });
  const latestLedger = info.result.info.validated_ledger.seq;

  let lastLedger = await getLastLedger();
  if (!lastLedger) {
    lastLedger = latestLedger - LEDGER_LOOKBACK;
  }

  const fromLedger = Math.max(
    lastLedger + 1,
    latestLedger - LEDGER_LOOKBACK
  );

  console.log(`🔍 Scanning ledgers ${fromLedger} → ${latestLedger}`);

  for (let i = fromLedger; i <= latestLedger; i++) {
    let ledger;
    try {
      ledger = await client.request({
        command: "ledger",
        ledger_index: i,
        transactions: true,
        expand: true,
      });
    } catch {
      continue;
    }

    const txs = ledger.result?.ledger?.transactions || [];

    for (const tx of txs) {
      const currencies = extractFromTransaction(tx);
      for (const { currency, issuer } of currencies) {
        await insertToken(currency, issuer);
      }
    }
  }

  await setLastLedger(latestLedger);
  await client.disconnect();
}

/* =========================
   MAIN LOOP
========================= */

async function main() {
  console.log("🚀 XRPL Full Discovery Scanner started");

  while (true) {
    try {
      await runScan();
    } catch (err) {
      console.error("⚠️ Scanner error:", err.message);
    }

    await new Promise((r) => setTimeout(r, RUN_INTERVAL_MS));
  }
}

main();
