# AKIBA Quick Start Guide

## Prerequisites

- Node.js v16 or higher
- MongoDB Atlas account (free tier available)
- Docker & Docker Compose (optional)

## Option 1: Local Development (Recommended for beginners)

### Step 1: Clone & Install

```bash
# Clone repository
git clone https://github.com/dushimsam/akiba.git
cd akiba

# Install dependencies
npm install
```

### Step 2: Configure Environment

```bash
# Copy environment template
cp .env.example .env

# Edit .env with your MongoDB Atlas connection string
nano .env
```

**Environment variables needed:**
```
PORT=3000
MONGODB_URI=******cluster.mongodb.net/akiba?retryWrites=true&w=majority
NODE_ENV=development
```

### Step 3: Start Development Servers

```bash
# Terminal 1: Start backend server
npm run dev:server

# Terminal 2: Start client (Vite dev server)
npm run dev:client
```

**Access:**
- Frontend: http://localhost:5173
- Backend: http://localhost:3000
- API: http://localhost:3000/api

## Option 2: Docker Development (Recommended for consistency)

### Step 1: Configure Environment

```bash
cp .env.example .env
# Update .env with your MongoDB connection string
```

### Step 2: Start All Services

```bash
# Build and run all services
docker-compose up --build

# Or run in background
docker-compose up -d
```

**Services running:**
- MongoDB: localhost:27017
- Backend: localhost:3000
- Frontend: localhost:5173

### Step 3: Stop Services

```bash
docker-compose down
```

## Testing the API

### Health Check

```bash
curl http://localhost:3000/api/health
```

### Get Transactions

```bash
curl http://localhost:3000/api/transactions/user123
```

### Create Transaction

```bash
curl -X POST http://localhost:3000/api/transactions \
  -H "Content-Type: application/json" \
  -d '{
    "userId": "user123",
    "type": "airtime",
    "amount": 5000,
    "recipient": "MTN",
    "description": "5000 RWF airtime"
  }'
```

## Building for Production

```bash
# Build both frontend and backend
npm run build

# Build individual packages
npm run build:server
npm run build:client
```

## Troubleshooting

### MongoDB Connection Error
- Verify connection string in `.env`
- Check MongoDB Atlas IP whitelist includes your IP
- Ensure database user has correct permissions

### Port Already in Use
```bash
# Kill process on port 3000
lsof -ti:3000 | xargs kill -9

# Kill process on port 5173
lsof -ti:5173 | xargs kill -9
```

### Dependencies Installation Issues
```bash
# Clear npm cache
npm cache clean --force

# Reinstall
rm -rf node_modules package-lock.json
npm install
```

## Next Steps

1. Create MongoDB Atlas account: https://www.mongodb.com/cloud/atlas
2. Set up connection string in `.env`
3. Start development servers
4. Explore API endpoints
5. Begin developing features

## Additional Resources

- [Express.js Documentation](https://expressjs.com/)
- [React Documentation](https://react.dev/)
- [Vite Documentation](https://vitejs.dev/)
- [MongoDB Atlas Guide](https://docs.atlas.mongodb.com/)

## Support

For issues or questions:
1. Check troubleshooting section above
2. Review API documentation in README.md
3. Check server logs: `npm run dev:server`
4. Check client logs: Browser DevTools Console
