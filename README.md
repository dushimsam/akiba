# AKIBA - Mobile Money Platform

A modern mobile money transaction platform for Rwanda, enabling quick transactions, smart transaction history, spending analytics, and savings tracking.

## 📚 Documentation

- **[README.md](README.md)** - Project overview and structure
- **[QUICKSTART.md](QUICKSTART.md)** - Get started in 5 minutes
- **[API.md](API.md)** - Complete API documentation
- **[CONTRIBUTING.md](CONTRIBUTING.md)** - Contribution guidelines
- **[SECURITY.md](SECURITY.md)** - Security guidelines and roadmap

## Project Structure

```
akiba/
├── client/                 # React frontend (Vite)
│   ├── src/
│   │   ├── App.jsx
│   │   ├── main.jsx
│   │   ├── api.js         # API service client
│   │   └── components/
│   ├── index.html
│   ├── package.json
│   ├── vite.config.js
│   └── Dockerfile
├── server/                 # Node.js backend (Express)
│   ├── src/
│   │   ├── index.js       # Server entry point
│   │   ├── db.js          # MongoDB connection
│   │   ├── seed.js        # Mock data seeder
│   │   ├── constants.js   # Transaction constants
│   │   ├── models/        # Database models
│   │   │   └── Transaction.js
│   │   └── routes/        # API routes
│   │       └── transactions.js
│   ├── package.json
│   └── Dockerfile
├── docker-compose.yml     # Docker orchestration
├── .env.example           # Environment variables template
├── .gitignore
├── .dockerignore
├── package.json           # Root workspace config
└── README.md
```

## Tech Stack

- **Frontend**: React 18 with Vite
- **Backend**: Node.js with Express
- **Database**: MongoDB Atlas
- **Deployment**: Docker & Docker Compose
- **Package Manager**: npm with workspaces

## Quick Start

### Option 1: Local Development

```bash
# 1. Clone & install
git clone https://github.com/dushimsam/akiba.git
cd akiba
npm install

# 2. Configure environment
cp .env.example .env
# Edit .env with your MongoDB connection

# 3. Start development
npm run dev              # Both server and client
npm run dev:server      # Server only
npm run dev:client      # Client only
```

### Option 2: Docker

```bash
# 1. Configure environment
cp .env.example .env

# 2. Start services
docker-compose up --build
```

**Access Points:**
- Frontend: http://localhost:5173
- Backend: http://localhost:3000
- API Base: http://localhost:3000/api

See [QUICKSTART.md](QUICKSTART.md) for detailed setup instructions.

## API Endpoints

### Transactions
- `GET /api/transactions/:userId` - Get all transactions for a user
- `POST /api/transactions` - Create new transaction
- `GET /api/transactions/detail/:id` - Get transaction details

### Health
- `GET /api/health` - Check server status

Full API documentation available in [API.md](API.md)

## Environment Variables

```
PORT=3000
MONGODB_URI=your-mongodb-atlas-connection-string
NODE_ENV=development
VITE_API_URL=http://localhost:3000/api
```

See `.env.example` for template.

## Features (Planned)

### Phase 1: Foundation ✅ (In Progress)
- [x] Monorepo structure
- [x] Backend API endpoints for transactions
- [x] MongoDB integration with Mongoose
- [x] React frontend with Vite
- [x] Docker containerization
- [x] Documentation

### Phase 2: Core Features 🔄 (Upcoming)
- [ ] Transaction dashboard
- [ ] Smart transaction history with filtering
- [ ] Spending analytics & insights
- [ ] Mokash savings tracker
- [ ] Authentication & authorization

### Phase 3: Advanced Features 📋 (Future)
- [ ] Offline transaction support
- [ ] Advanced analytics & reports
- [ ] Multiple payment methods
- [ ] User profile management
- [ ] Mobile app version

## Development Workflow

### Building
```bash
npm run build           # Build both
npm run build:server   # Backend only
npm run build:client   # Frontend only
```

### Code Standards

- Follow [CONTRIBUTING.md](CONTRIBUTING.md) guidelines
- Use conventional commits for messages
- Ensure code passes linting
- Add tests for new features
- Update documentation

### Commit Convention

```
<type>: <description>

feat:   New feature
fix:    Bug fix
docs:   Documentation
chore:  Build/maintenance
style:  Code style
test:   Tests
```

Example: `feat: add transaction filtering by date`

## Security

This project handles financial transactions. See [SECURITY.md](SECURITY.md) for:
- Current security status
- Known issues and fixes
- Security roadmap
- Best practices for contributors
- Compliance considerations

⚠️ **Status**: Foundation phase - Rate limiting and authentication to be added in Phase 2

## Testing

```bash
# Run tests
npm test

# Watch mode
npm test -- --watch
```

## Troubleshooting

### MongoDB Connection Issues
1. Check connection string in `.env`
2. Verify IP whitelist on MongoDB Atlas
3. Ensure database user has proper permissions

### Port Conflicts
```bash
# Kill process on port 3000 or 5173
lsof -ti:3000 | xargs kill -9
lsof -ti:5173 | xargs kill -9
```

### Dependency Issues
```bash
npm cache clean --force
rm -rf node_modules package-lock.json
npm install
```

See [QUICKSTART.md](QUICKSTART.md) for more troubleshooting.

## Contributing

We welcome contributions! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for:
- How to set up development environment
- Code style guidelines
- PR process
- Branch naming conventions
- Commit message format

### Quick Contribution Steps
1. Fork the repository
2. Create a feature branch: `git checkout -b feature/your-feature`
3. Make changes with clear commit messages
4. Push to your fork
5. Open a Pull Request

## Project Goals

AKIBA aims to solve mobile money accessibility challenges in Rwanda by providing:

1. **Quick Transactions** - One-click access to common operations
2. **Transaction Visibility** - Clear history and search
3. **Financial Insights** - Spending analytics and trends
4. **Savings Tracking** - Mokash savings management
5. **Offline Support** - Works with limited data (future)

### Target Users

- Foreigners living in Rwanda unfamiliar with USSD
- Local users preferring app over USSD
- Users wanting transaction transparency
- Mokash savers seeking savings visibility
- Data-conscious users

## Roadmap

### Q3 2024
- [x] Project initialization
- [x] Monorepo setup
- [ ] Basic authentication

### Q4 2024
- [ ] Transaction dashboard UI
- [ ] Analytics implementation
- [ ] Advanced filtering

### Q1 2025
- [ ] Mobile app (React Native)
- [ ] Enhanced security
- [ ] Performance optimization

## Performance & Monitoring

Current implementation prioritizes:
- Clean architecture
- Clear separation of concerns
- Scalable structure

Future improvements:
- Caching layer (Redis)
- Advanced indexing
- Performance monitoring
- Load testing

## Deployment

### Production Checklist

- [ ] Environment variables configured
- [ ] MongoDB Atlas secured
- [ ] HTTPS enabled
- [ ] Rate limiting enabled
- [ ] Logging configured
- [ ] Backups scheduled
- [ ] Monitoring active
- [ ] Security audit completed

See [SECURITY.md](SECURITY.md) for detailed security checklist.

## Support & Resources

- 📖 [React Documentation](https://react.dev)
- 📖 [Express.js Guide](https://expressjs.com)
- 📖 [MongoDB Docs](https://docs.mongodb.com)
- 📖 [Vite Guide](https://vitejs.dev)
- 🐛 [Report Issues](https://github.com/dushimsam/akiba/issues)
- 💬 [GitHub Discussions](https://github.com/dushimsam/akiba/discussions)

## Authors & Contributors

- **DLOADIN** - Project Lead & Initial Development

## License

MIT License - see LICENSE file for details

## Acknowledgments

- Rwanda tech community
- Contributors and testers
- MongoDB Atlas free tier
- React and Node.js communities

---

**Status**: Foundation Phase (v1.0.0)  
**Last Updated**: 2024-06-26  
**Next Phase**: Core Features Development

**Questions?** Check the [QUICKSTART.md](QUICKSTART.md) or open an [issue](https://github.com/dushimsam/akiba/issues).

