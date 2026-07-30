import pg from 'pg'

const { Pool } = pg

let pool

// A single shared connection pool for the whole process.
export const getPool = () => {
  if (!pool) {
    const connectionString = process.env.DATABASE_URL

    if (!connectionString) {
      throw new Error('DATABASE_URL is not defined in environment variables')
    }

    pool = new Pool({
      connectionString,
      // RDS (and most managed Postgres) require TLS. Enable it when
      // DATABASE_SSL=true; rejectUnauthorized is relaxed because RDS uses
      // its own CA that isn't in the default trust store.
      ssl: process.env.DATABASE_SSL === 'true' ? { rejectUnauthorized: false } : false,
    })
  }

  return pool
}

// Create the transactions table (and its index) if they don't exist yet, so a
// fresh database is usable without a separate migration step.
const initSchema = async () => {
  await getPool().query(`
    CREATE TABLE IF NOT EXISTS transactions (
      id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
      user_id     TEXT NOT NULL,
      type        TEXT NOT NULL CHECK (type IN ('airtime', 'bundle', 'transfer', 'bill', 'savings')),
      amount      NUMERIC(14, 2) NOT NULL CHECK (amount > 0),
      recipient   TEXT,
      description TEXT,
      status      TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'completed', 'failed')),
      created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
    );
  `)

  await getPool().query(`
    CREATE INDEX IF NOT EXISTS idx_transactions_user_created
      ON transactions (user_id, created_at DESC);
  `)
}

const connectDB = async () => {
  try {
    // Fail fast if the database is unreachable or misconfigured.
    await getPool().query('SELECT 1')
    await initSchema()
    console.log('PostgreSQL connected successfully')
  } catch (error) {
    console.error('PostgreSQL connection error:', error.message)
    process.exit(1)
  }
}

export default connectDB
