import { getPool } from '../db.js'

// Map a raw database row (snake_case, string numerics) to the camelCase shape
// the API has always returned, so the HTTP contract is unchanged.
const toTransaction = (row) => ({
  id: row.id,
  userId: row.user_id,
  type: row.type,
  amount: Number(row.amount),
  recipient: row.recipient,
  description: row.description,
  status: row.status,
  createdAt: row.created_at,
})

// All transactions for a user, newest first.
export const findByUserId = async (userId) => {
  const { rows } = await getPool().query(
    'SELECT * FROM transactions WHERE user_id = $1 ORDER BY created_at DESC',
    [userId],
  )
  return rows.map(toTransaction)
}

// A single transaction by its id, or null if not found.
export const findById = async (id) => {
  const { rows } = await getPool().query('SELECT * FROM transactions WHERE id = $1', [id])
  return rows.length ? toTransaction(rows[0]) : null
}

// Insert a transaction and return the stored row.
export const create = async ({ userId, type, amount, recipient, description, status = 'pending' }) => {
  const { rows } = await getPool().query(
    `INSERT INTO transactions (user_id, type, amount, recipient, description, status)
     VALUES ($1, $2, $3, $4, $5, $6)
     RETURNING *`,
    [userId, type, amount, recipient, description, status],
  )
  return toTransaction(rows[0])
}

// Delete every transaction belonging to a user (used by the seeder).
export const deleteByUserId = async (userId) => {
  await getPool().query('DELETE FROM transactions WHERE user_id = $1', [userId])
}

// Bulk insert, preserving explicit created_at values when provided.
export const insertMany = async (transactions) => {
  for (const t of transactions) {
    await getPool().query(
      `INSERT INTO transactions (user_id, type, amount, recipient, description, status, created_at)
       VALUES ($1, $2, $3, $4, $5, $6, COALESCE($7, now()))`,
      [t.userId, t.type, t.amount, t.recipient, t.description, t.status ?? 'pending', t.createdAt ?? null],
    )
  }
}
