import { TRANSACTION_TYPES } from './constants.js'

export function validateNewTransaction(body = {}) {
  const { userId, type, amount } = body

  if (!userId || !type || amount === undefined) {
    return 'Missing required fields'
  }
  if (!Object.values(TRANSACTION_TYPES).includes(type)) {
    return 'Invalid transaction type'
  }
  if (typeof amount !== 'number' || Number.isNaN(amount) || amount <= 0) {
    return 'Amount must be a positive number'
  }
  return null
}
