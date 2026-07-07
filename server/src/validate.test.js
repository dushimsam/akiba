import { validateNewTransaction } from './validate.js'

test('accepts a valid transaction', () => {
  expect(validateNewTransaction({ userId: 'u1', type: 'transfer', amount: 500 })).toBeNull()
})

test('rejects a transaction with missing fields', () => {
  expect(validateNewTransaction({ type: 'transfer', amount: 500 })).toBe('Missing required fields')
  expect(validateNewTransaction({ userId: 'u1', amount: 500 })).toBe('Missing required fields')
  expect(validateNewTransaction({})).toBe('Missing required fields')
})

test('rejects an unknown transaction type', () => {
  expect(validateNewTransaction({ userId: 'u1', type: 'crypto', amount: 500 })).toBe('Invalid transaction type')
})

test('rejects non-positive or non-numeric amounts', () => {
  expect(validateNewTransaction({ userId: 'u1', type: 'bill', amount: 0 })).toBe('Amount must be a positive number')
  expect(validateNewTransaction({ userId: 'u1', type: 'bill', amount: -100 })).toBe('Amount must be a positive number')
  expect(validateNewTransaction({ userId: 'u1', type: 'bill', amount: '500' })).toBe('Amount must be a positive number')
})
