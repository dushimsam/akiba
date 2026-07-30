import express from 'express'
import { findByUserId, findById, create } from '../models/Transaction.js'
import { validateNewTransaction } from '../validate.js'

const router = express.Router()

// Get all transactions for user
router.get('/:userId', async (req, res) => {
  try {
    const transactions = await findByUserId(req.params.userId)
    res.json(transactions)
  } catch (error) {
    res.status(500).json({ error: error.message })
  }
})

// Create new transaction
router.post('/', async (req, res) => {
  try {
    const { userId, type, amount, recipient, description } = req.body

    const validationError = validateNewTransaction(req.body)
    if (validationError) {
      return res.status(400).json({ error: validationError })
    }

    const transaction = await create({
      userId,
      type,
      amount,
      recipient,
      description,
      status: 'completed',
    })

    res.status(201).json(transaction)
  } catch (error) {
    res.status(500).json({ error: error.message })
  }
})

// Get transaction by ID
router.get('/detail/:id', async (req, res) => {
  try {
    const transaction = await findById(req.params.id)
    if (!transaction) {
      return res.status(404).json({ error: 'Transaction not found' })
    }
    res.json(transaction)
  } catch (error) {
    res.status(500).json({ error: error.message })
  }
})

export default router
