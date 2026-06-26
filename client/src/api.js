import axios from 'axios'

const API_BASE_URL = process.env.VITE_API_URL || 'http://localhost:3000/api'

const apiClient = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    'Content-Type': 'application/json',
  },
})

// Transaction endpoints
export const transactionAPI = {
  getTransactions: (userId) => apiClient.get(`/transactions/${userId}`),
  createTransaction: (data) => apiClient.post('/transactions', data),
  getTransactionDetails: (id) => apiClient.get(`/transactions/detail/${id}`),
}

// Health check
export const healthCheck = () => apiClient.get('/health')

export default apiClient
