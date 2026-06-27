# AKIBA API Documentation

## Base URL

```
http://localhost:3000/api
```

## Authentication

Currently, API endpoints do not require authentication. Authentication will be implemented in future updates.

## Response Format

All responses are in JSON format.

### Success Response

```json
{
  "status": "success",
  "data": {}
}
```

### Error Response

```json
{
  "error": "Error message describing what went wrong"
}
```

## Endpoints

### Health Check

#### `GET /health`

Check if the server is running.

**Response:**
```json
{
  "status": "Server is running"
}
```

---

### Transactions

#### `GET /transactions/:userId`

Get all transactions for a specific user.

**Parameters:**
- `userId` (path): User identifier

**Query Parameters:**
- `type` (optional): Filter by transaction type (airtime, bundle, transfer, bill, savings)
- `status` (optional): Filter by status (pending, completed, failed)

**Response:**
```json
[
  {
    "_id": "507f1f77bcf86cd799439011",
    "userId": "user123",
    "type": "airtime",
    "amount": 5000,
    "recipient": "MTN",
    "description": "5000 RWF airtime purchase",
    "status": "completed",
    "createdAt": "2024-06-26T10:30:00Z"
  },
  {
    "_id": "507f1f77bcf86cd799439012",
    "userId": "user123",
    "type": "transfer",
    "amount": 15000,
    "recipient": "John Doe",
    "description": "Money transfer",
    "status": "completed",
    "createdAt": "2024-06-25T14:20:00Z"
  }
]
```

---

#### `POST /transactions`

Create a new transaction.

**Request Body:**
```json
{
  "userId": "user123",
  "type": "airtime",
  "amount": 5000,
  "recipient": "MTN",
  "description": "5000 RWF airtime purchase"
}
```

**Required Fields:**
- `userId`: User identifier
- `type`: Transaction type (airtime | bundle | transfer | bill | savings)
- `amount`: Transaction amount in RWF

**Optional Fields:**
- `recipient`: Transaction recipient
- `description`: Transaction description

**Response:** (201 Created)
```json
{
  "_id": "507f1f77bcf86cd799439013",
  "userId": "user123",
  "type": "airtime",
  "amount": 5000,
  "recipient": "MTN",
  "description": "5000 RWF airtime purchase",
  "status": "completed",
  "createdAt": "2024-06-26T11:45:00Z"
}
```

**Error Response:** (400 Bad Request)
```json
{
  "error": "Missing required fields"
}
```

---

#### `GET /transactions/detail/:id`

Get details of a specific transaction by ID.

**Parameters:**
- `id` (path): Transaction ID (MongoDB ObjectId)

**Response:**
```json
{
  "_id": "507f1f77bcf86cd799439011",
  "userId": "user123",
  "type": "airtime",
  "amount": 5000,
  "recipient": "MTN",
  "description": "5000 RWF airtime purchase",
  "status": "completed",
  "createdAt": "2024-06-26T10:30:00Z"
}
```

**Error Response:** (404 Not Found)
```json
{
  "error": "Transaction not found"
}
```

---

## Transaction Types

| Type | Description |
|------|-------------|
| `airtime` | Mobile phone airtime purchase |
| `bundle` | Mobile data bundle purchase |
| `transfer` | Money transfer to another user |
| `bill` | Bill payment (utilities, etc.) |
| `savings` | Savings deposit |

## Transaction Status

| Status | Description |
|--------|-------------|
| `pending` | Transaction is being processed |
| `completed` | Transaction completed successfully |
| `failed` | Transaction failed |

## Error Codes

| Code | Message | Description |
|------|---------|-------------|
| 400 | Missing required fields | Request is missing required fields |
| 404 | Transaction not found | Specified transaction ID does not exist |
| 500 | Server error | Internal server error |

## Rate Limiting

Rate limiting is not currently implemented. It will be added in future updates.

## Pagination

Pagination is not currently implemented. All transactions are returned. Pagination will be added in future updates.

## Filtering & Sorting

- Transactions are automatically sorted by `createdAt` in descending order (newest first)
- Filtering by type and status can be implemented in future updates

## Future Enhancements

- [ ] Authentication & Authorization
- [ ] Pagination support
- [ ] Advanced filtering
- [ ] Rate limiting
- [ ] Analytics endpoints
- [ ] Transaction search
- [ ] Batch operations
- [ ] Webhook support

## Examples

### Using cURL

```bash
# Get all transactions for a user
curl -X GET http://localhost:3000/api/transactions/user123

# Create a new transaction
curl -X POST http://localhost:3000/api/transactions \
  -H "Content-Type: application/json" \
  -d '{
    "userId": "user123",
    "type": "transfer",
    "amount": 10000,
    "recipient": "Jane Smith",
    "description": "Payment for services"
  }'

# Get transaction details
curl -X GET http://localhost:3000/api/transactions/detail/507f1f77bcf86cd799439011
```

### Using JavaScript/Fetch

```javascript
// Get transactions
const response = await fetch('http://localhost:3000/api/transactions/user123');
const transactions = await response.json();

// Create transaction
const newTransaction = await fetch('http://localhost:3000/api/transactions', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    userId: 'user123',
    type: 'airtime',
    amount: 5000,
    recipient: 'MTN'
  })
});
```

### Using Python

```python
import requests

# Get transactions
response = requests.get('http://localhost:3000/api/transactions/user123')
transactions = response.json()

# Create transaction
data = {
    'userId': 'user123',
    'type': 'transfer',
    'amount': 15000,
    'recipient': 'John Doe'
}
response = requests.post('http://localhost:3000/api/transactions', json=data)
```

## Support

For API issues or questions, please refer to:
- Server logs for debugging
- QUICKSTART.md for setup help
- README.md for project overview
