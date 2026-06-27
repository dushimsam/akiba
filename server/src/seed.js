import Transaction from '../models/Transaction.js'

const mockTransactions = [
  {
    userId: 'user123',
    type: 'airtime',
    amount: 5000,
    recipient: 'MTN',
    description: 'Airtime purchase - MTN 5000 RWF',
    status: 'completed',
    createdAt: new Date(Date.now() - 86400000 * 3),
  },
  {
    userId: 'user123',
    type: 'transfer',
    amount: 15000,
    recipient: 'John Doe',
    description: 'Money transfer to John',
    status: 'completed',
    createdAt: new Date(Date.now() - 86400000 * 2),
  },
  {
    userId: 'user123',
    type: 'bill',
    amount: 8000,
    recipient: 'EWSA',
    description: 'Electricity bill payment',
    status: 'completed',
    createdAt: new Date(Date.now() - 86400000 * 1),
  },
  {
    userId: 'user123',
    type: 'bundle',
    amount: 3000,
    recipient: 'MTN Data',
    description: 'Data bundle - 1GB',
    status: 'completed',
    createdAt: new Date(),
  },
  {
    userId: 'user123',
    type: 'savings',
    amount: 25000,
    recipient: 'Mokash Savings',
    description: 'Monthly savings deposit',
    status: 'completed',
    createdAt: new Date(),
  },
]

export const seedDatabase = async () => {
  try {
    await Transaction.deleteMany({ userId: 'user123' })
    await Transaction.insertMany(mockTransactions)
    console.log('Mock data seeded successfully')
  } catch (error) {
    console.error('Error seeding database:', error.message)
  }
}
