import express from 'express'
import cors from 'cors'
import bodyParser from 'body-parser'
import dotenv from 'dotenv'
import path from 'path'
import { fileURLToPath } from 'url'
import connectDB from './db.js'
import transactionRoutes from './routes/transactions.js'

dotenv.config()

const app = express()
const PORT = process.env.PORT || 3000
const __filename = fileURLToPath(import.meta.url)
const __dirname = path.dirname(__filename)
const clientDistPath = path.resolve(__dirname, '../client/dist')

// Middleware
app.use(cors())
app.use(bodyParser.json())
app.use(bodyParser.urlencoded({ extended: true }))

// Connect to PostgreSQL
connectDB()

// Routes
app.get('/api/health', (req, res) => {
  res.json({ status: 'Server is running' })
})

app.use('/api/transactions', transactionRoutes)

// Serve the built frontend in production containers.
app.use(express.static(clientDistPath))
app.get('*', (req, res, next) => {
  if (req.path.startsWith('/api')) {
    return next()
  }

  res.sendFile(path.join(clientDistPath, 'index.html'))
})

// Start server
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`)
})
