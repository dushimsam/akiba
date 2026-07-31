# AKIBA - Mobile Money Platform

A modern mobile money transaction platform for Rwanda, enabling quick transactions, smart transaction history, spending analytics, and savings tracking.

## African Context

Mobile money is the main way people move money in Rwanda, yet most of it still runs through USSD menus. These menus are slow to navigate, easy to get wrong, and give users no view of their transaction history or spending habits. Foreigners living in Rwanda struggle with them even more since the menus assume local knowledge.

AKIBA addresses this by putting common mobile money operations behind a simple app interface: quick transactions, a searchable history, spending analytics, and Mokash savings tracking. The value is not replacing mobile money but making it visible and easier to use for everyday users.

## Team Members

- Samuel Dushimimana ([@dushimsam](https://github.com/dushimsam)) - Team Lead & DevOps
- David M. ([@DLOADIN](https://github.com/DLOADIN)) - Backend & Docker
- John Obure ([@obure1always](https://github.com/obure1always)) - Repository Configuration & Documentation
- Kelvin Chirchir ([@kenchirchir](https://github.com/kenchirchir)) - Frontend & Testing

## 📚 Documentation

- **[README.md](README.md)** - Project overview and structure
- **[QUICKSTART.md](QUICKSTART.md)** - Get started in 5 minutes
- **[API.md](API.md)** - Complete API documentation
- **[CONTRIBUTING.md](CONTRIBUTING.md)** - Contribution guidelines
- **[SECURITY.md](SECURITY.md)** - Security guidelines and roadmap
- **[CHANGELOG.md](CHANGELOG.md)** - F1 → F2 → Summative changes
- **[Project Board](https://github.com/dushimsam/akiba/projects)** - Kanban board with backlog, in progress and done columns

## Architecture

```text
  Developer
      |
      | push / PR
      v
  GitHub Actions
   ├─ ci.yml            lint + test + docker build  (feature branches / PRs)
   ├─ security-scan.yml npm audit + Trivy + Checkov (PRs + main)
   └─ cd.yml            full checks → ECR → Ansible  (main only)
                              |
                              v
                         AWS ECR (akiba)
                              |
                              v
                     Ansible (via bastion jump)
                              |
              +---------------+----------------+
              |                                |
              v                                v
     Bastion (public)                   App VM (private)
     nginx :80  --------------------->  docker-compose
     (public URL)                       akiba container :3000
                                              |
                                              v
                                         AWS RDS (Postgres)
```

## Live application

After a successful CD run the app is reachable at:

**http://3.84.131.80**

(Health: `http://3.84.131.80/api/health`)

That IP is the bastion. nginx there proxies to the private app VM. If Terraform recreates the bastion, update this URL from `terraform output live_app_url`.

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
│   │   ├── db.js          # PostgreSQL connection
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
- **Database**: PostgreSQL (managed via AWS RDS in production)
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
# Edit .env with your PostgreSQL connection

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
DATABASE_URL=postgres://user:password@host:5432/akiba
DATABASE_SSL=false   # set to true for managed databases such as AWS RDS
NODE_ENV=development
VITE_API_URL=http://localhost:3000/api
```

See `.env.example` for template.

## Features (Planned)

### Phase 1: Foundation ✅ (In Progress)
- [x] Monorepo structure
- [x] Backend API endpoints for transactions
- [x] PostgreSQL integration with node-postgres (pg)
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

## Branch Protection

The `main` branch is protected with the following rules, so that every change is reviewed and main always stays in a working state:

- **Pull request required before merging** - nobody can push directly to main, all changes go through a PR.
- **At least 1 approving review** - a second team member has to read and approve every change.
- **Stale approvals dismissed on new commits** - if new commits are pushed after approval, the PR has to be reviewed again so approvals always match the code being merged.
- **Status checks must pass** - the CI pipeline (lint, tests, Docker build) has to succeed before a PR can be merged.
- **Branch must be up to date before merging** - avoids merging code that was never tested against the latest main.
- **Conversations must be resolved** - review comments cannot be ignored or forgotten.
- **Rules apply to administrators** - everyone on the team follows the same workflow, including repo admins.

## Testing

```bash
# Run tests
npm test

# Watch mode
npm test -- --watch
```

## Troubleshooting

### PostgreSQL Connection Issues
1. Check `DATABASE_URL` in `.env`
2. Verify the security group / firewall allows the app to reach the DB port (5432)
3. Ensure the database user has proper permissions and `DATABASE_SSL` matches the server (RDS requires `true`)

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

### How CD works

Pushing to `main` runs [`.github/workflows/cd.yml`](.github/workflows/cd.yml):

1. Lint, test, `npm audit` (prod, high+)
2. Build the production image + Trivy (HIGH/CRITICAL)
3. Auth to AWS and push to ECR (`akiba`)
4. Ansible `deploy.yml` over the bastion → pull image → `docker-compose up -d`
5. Smoke check `http://$BASTION_HOST/api/health`

### Secrets the CD workflow expects

Set these under repo **Settings → Secrets and variables → Actions**:

| Secret | What it is |
|--------|------------|
| `AWS_ACCESS_KEY_ID` | IAM user that can push/pull ECR |
| `AWS_SECRET_ACCESS_KEY` | matching secret |
| `AWS_REGION` | e.g. `us-east-1` |
| `SSH_PRIVATE_KEY` | key that can jump bastion → app |
| `BASTION_HOST` | bastion public IP (`terraform output bastion_public_ip`) |
| `APP_HOST` | app private IP (`terraform output app_private_ip`) |
| `DATABASE_URL` | Postgres URL the container should use (usually RDS) |

### Setup another engineer can follow

```bash
# 1. App locally
git clone https://github.com/dushimsam/akiba.git
cd akiba
cp .env.example .env
npm install
npm run lint && npm test
docker compose up --build   # local stack

# 2. Infra (needs AWS creds + SSH pubkeys at the paths in ec2.tf)
cd terraform
terraform init
terraform plan -var="db_password=YOUR_DB_PASSWORD"
terraform apply -var="db_password=YOUR_DB_PASSWORD"
terraform output

# 3. First-time host setup (Docker on the app VM)
cd ../ansible
ansible-playbook playbook.yml -i inventory.ini

# 4. Wire GitHub secrets from the terraform outputs, then merge to main
#    CD builds, pushes to ECR, and runs deploy.yml
```

Production compose file used on the VM: `docker-compose.prod.yml` (image from ECR).  
Day-to-day local compose stays in `docker-compose.yml`.

### Production Checklist

- [x] Environment variables configured (via Ansible `.env` on the VM)
- [x] PostgreSQL (RDS) secured (private subnets + SG)
- [ ] HTTPS enabled
- [ ] Rate limiting enabled
- [x] Logging configured
- [x] Backups scheduled (Ansible cron on the app host)
- [ ] Monitoring active
- [x] Security scans in CI (see SECURITY.md)

See [SECURITY.md](SECURITY.md) for detailed security checklist.

## Support & Resources

- 📖 [React Documentation](https://react.dev)
- 📖 [Express.js Guide](https://expressjs.com)
- 📖 [PostgreSQL Docs](https://www.postgresql.org/docs/)
- 📖 [Vite Guide](https://vitejs.dev)
- 🐛 [Report Issues](https://github.com/dushimsam/akiba/issues)
- 💬 [GitHub Discussions](https://github.com/dushimsam/akiba/discussions)

## Authors & Contributors

See [Team Members](#team-members).

## License

MIT License - see LICENSE file for details

## Acknowledgments

- Rwanda tech community
- Contributors and testers
- PostgreSQL community
- React and Node.js communities

---

**Status**: Summative / DevSecOps deploy pipeline  
**Last Updated**: 2026-07-31  
**Next Phase**: Core product features (auth, analytics UI)

**Questions?** Check the [QUICKSTART.md](QUICKSTART.md) or open an [issue](https://github.com/dushimsam/akiba/issues).


## Docker Development Environment

### Prerequisites
- Docker Engine 24+
- Docker Compose v2 (bundled as `docker compose`)

### Configure environment
```bash
cp .env.example .env
# edit .env if you want non-default credentials/ports
```

### Start the full stack
```bash
docker compose up --build
```
This starts PostgreSQL, the Express server, and the Vite client, wired together
on a private `akiba-network`. The server waits for Postgres to report healthy
before starting, and the client waits for the server's `/api/health` check
before starting.

- Frontend: http://localhost:5173
- Backend:  http://localhost:3000
- Postgres: localhost:5432 (credentials from `.env`)

### Run in the background
```bash
docker compose up -d --build
```

### View logs
```bash
docker compose logs -f
```

### Stop the stack
```bash
docker compose down
```

### Stop and remove data volumes (fresh DB next start)
```bash
docker compose down -v
```
