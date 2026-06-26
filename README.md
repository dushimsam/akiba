# AKIBA - Mobile Money Platform

A modern mobile money transaction platform for Rwanda, enabling quick transactions, smart transaction history, spending analytics, and savings tracking.

## Project Structure

```
akiba/
├── client/                 # React frontend (Vite)
│   ├── src/
│   │   ├── App.jsx
│   │   ├── main.jsx
│   │   └── components/
│   ├── index.html
│   ├── package.json
│   └── vite.config.js
├── server/                 # Node.js backend (Express)
│   ├── src/
│   │   ├── index.js       # Server entry point
│   │   ├── db.js          # MongoDB connection
│   │   ├── models/        # Database models
│   │   │   └── Transaction.js
│   │   └── routes/        # API routes
│   │       └── transactions.js
│   └── package.json
├── .env.example           # Environment variables template
├── package.json           # Root workspace config
└── README.md
```

## Tech Stack

- **Frontend**: React 18 with Vite
- **Backend**: Node.js with Express
- **Database**: MongoDB Atlas
- **Package Manager**: npm with workspaces

## Setup Instructions

### Prerequisites
- Node.js (v16+)
- npm or yarn
- MongoDB Atlas account

### Installation

1. Clone the repository
2. Copy `.env.example` to `.env` and configure:
   ```bash
   cp .env.example .env
   ```
3. Install dependencies:
   ```bash
   npm install
   ```

### Running the Project

**Development mode:**
```bash
npm run dev              # Start both server and client
npm run dev:server      # Start server only
npm run dev:client      # Start client only
```

**Build:**
```bash
npm run build           # Build both
npm run build:server   # Build server
npm run build:client   # Build client
```

## API Endpoints

### Transactions
- `GET /api/transactions/:userId` - Get all transactions for a user
- `POST /api/transactions` - Create new transaction
- `GET /api/transactions/detail/:id` - Get transaction details

### Health
- `GET /api/health` - Check server status

## Environment Variables

```
PORT=3000
MONGODB_URI=your-mongodb-atlas-connection-string
NODE_ENV=development
```

## Features (In Development)

- ✅ Monorepo structure
- ✅ Backend API endpoints for transactions
- ✅ MongoDB integration
- ✅ React frontend setup
- 🔄 Transaction dashboard
- 🔄 Analytics & insights
- 🔄 Savings tracker
- 🔄 Offline support

## Author

DLOADIN

## License

MIT
