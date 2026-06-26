import express from 'express'
import Transaction from '../models/Transaction.js'

const router = express.Router()

// Get all transactions for user
router.get('/:userId', async (req, res) => {
  try {
    const transactions = await Transaction.find({ userId: req.params.userId }).sort({ createdAt: -1 })
    res.json(transactions)
  } catch (error) {
    res.status(500).json({ error: error.message })
  }
})

// Create new transaction
router.post('/', async (req, res) => {
  try {
    const { userId, type, amount, recipient, description } = req.body

    if (!userId || !type || !amount) {
      return res.status(400).json({ error: 'Missing required fields' })
    }

    const transaction = new Transaction({
      userId,
      type,
      amount,
      recipient,
      description,
      status: 'completed',
    })

    await transaction.save()
    res.status(201).json(transaction)
  } catch (error) {
    res.status(500).json({ error: error.message })
  }
})

// Get transaction by ID
router.get('/detail/:id', async (req, res) => {
  try {
    const transaction = await Transaction.findById(req.params.id)
    if (!transaction) {
      return res.status(404).json({ error: 'Transaction not found' })
    }
    res.json(transaction)
  } catch (error) {
    res.status(500).json({ error: error.message })
  }
})

export default router
