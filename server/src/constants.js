// Transaction types
export const TRANSACTION_TYPES = {
  AIRTIME: 'airtime',
  BUNDLE: 'bundle',
  TRANSFER: 'transfer',
  BILL: 'bill',
  SAVINGS: 'savings',
}

// Transaction statuses
export const TRANSACTION_STATUS = {
  PENDING: 'pending',
  COMPLETED: 'completed',
  FAILED: 'failed',
}

// Transaction categories for analytics
export const TRANSACTION_CATEGORIES = {
  [TRANSACTION_TYPES.AIRTIME]: 'Airtime',
  [TRANSACTION_TYPES.BUNDLE]: 'Bundles',
  [TRANSACTION_TYPES.TRANSFER]: 'Transfers',
  [TRANSACTION_TYPES.BILL]: 'Bills',
  [TRANSACTION_TYPES.SAVINGS]: 'Savings',
}
