import mongoose from 'mongoose'

const transactionSchema = new mongoose.Schema({
  userId: {
    type: String,
    required: true,
  },
  type: {
    type: String,
    enum: ['airtime', 'bundle', 'transfer', 'bill', 'savings'],
    required: true,
  },
  amount: {
    type: Number,
    required: true,
  },
  recipient: {
    type: String,
  },
  description: {
    type: String,
  },
  status: {
    type: String,
    enum: ['pending', 'completed', 'failed'],
    default: 'pending',
  },
  createdAt: {
    type: Date,
    default: Date.now,
  },
})

export default mongoose.model('Transaction', transactionSchema)
