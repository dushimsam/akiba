# Contributing to AKIBA

Thank you for your interest in contributing to AKIBA! This guide explains how to contribute to the project.

## Code of Conduct

Please be respectful and professional when contributing. We value all contributions regardless of experience level.

## Getting Started

1. Fork the repository
2. Clone your fork: `git clone https://github.com/YOUR_USERNAME/akiba.git`
3. Create a feature branch: `git checkout -b feature/your-feature-name`
4. Make your changes
5. Commit with clear messages: `git commit -m "feat: describe your changes"`
6. Push to your branch: `git push origin feature/your-feature-name`
7. Open a Pull Request

## Branch Naming Convention

Use descriptive branch names:
- `feature/` - New features
- `fix/` - Bug fixes
- `docs/` - Documentation updates
- `chore/` - Maintenance tasks
- `test/` - Test additions

Example: `feature/transaction-analytics`

## Commit Message Format

Follow conventional commits:

```
<type>: <description>

<optional body>
<optional footer>
```

**Types:**
- `feat:` - New feature
- `fix:` - Bug fix
- `docs:` - Documentation
- `style:` - Code style (formatting, missing semicolons, etc.)
- `refactor:` - Code refactoring
- `test:` - Adding or updating tests
- `chore:` - Build process, dependencies, etc.

**Examples:**
- `feat: add transaction filtering by date range`
- `fix: resolve MongoDB connection timeout issue`
- `docs: update API documentation with examples`

## Code Style Guidelines

### JavaScript/Node.js
- Use ES6+ syntax
- Use `const` and `let`, avoid `var`
- Use arrow functions where appropriate
- Add comments for complex logic
- Use meaningful variable names

### React/Frontend
- Use functional components with hooks
- Keep components small and focused
- Use PropTypes or TypeScript for type checking
- Keep styling modular (CSS modules or styled-components)

### MongoDB/Data
- Use meaningful field names
- Add proper indexing
- Document schema structure
- Include validation in schemas

## Setup for Development

```bash
# Install dependencies
npm install

# Set up environment
cp .env.example .env
# Edit .env with your configuration

# Start development servers
npm run dev:server
npm run dev:client
```

## Testing

```bash
# Run tests (to be implemented)
npm test

# Run tests in watch mode
npm test -- --watch
```

## Code Review Process

1. **Automated Checks**: GitHub Actions runs linters and tests
2. **Code Review**: At least one maintainer reviews your code
3. **Improvements**: Address any feedback or suggestions
4. **Merge**: Once approved, your PR will be merged

## Pull Request Guidelines

When submitting a PR:

1. **Title**: Use a clear, descriptive title following conventional commits
2. **Description**: Explain:
   - What changes you made
   - Why you made them
   - Any related issues
   - How to test the changes

3. **Tests**: Include tests for new features
4. **Documentation**: Update docs if needed
5. **No Breaking Changes**: Unless discussed and approved

### PR Template

```markdown
## Description
Briefly describe your changes.

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## How to Test
Steps to test your changes.

## Checklist
- [ ] My code follows the project's code style
- [ ] I have updated documentation
- [ ] I have added tests (if applicable)
- [ ] All tests pass
- [ ] My changes don't break existing functionality
```

## Issues and Bug Reports

### Reporting Bugs

When reporting a bug, include:
1. Clear, descriptive title
2. Steps to reproduce
3. Expected vs. actual behavior
4. Screenshots/logs if applicable
5. Your environment (OS, Node version, etc.)

### Feature Requests

For feature requests:
1. Clear description of the feature
2. Use case and why it's needed
3. Possible implementation approach
4. Examples or mockups if applicable

## Project Structure

```
akiba/
├── client/              # React frontend
├── server/              # Node.js backend
├── docs/                # Documentation
├── README.md
├── API.md
├── QUICKSTART.md
└── package.json         # Root workspace
```

## Key Technologies

- **Frontend**: React 18, Vite, Axios
- **Backend**: Node.js, Express, MongoDB
- **Database**: MongoDB Atlas
- **Deployment**: Docker, Docker Compose

## Common Tasks

### Adding a New API Endpoint

1. Create a route handler in `server/src/routes/`
2. Add MongoDB model if needed in `server/src/models/`
3. Update API documentation
4. Test with cURL or Postman
5. Update client API service in `client/src/api.js`

### Adding a New Frontend Component

1. Create component in `client/src/components/`
2. Use React hooks for state management
3. Call backend API using `api.js`
4. Add component to appropriate page
5. Style using CSS modules or inline styles

### Database Schema Changes

1. Update MongoDB schema in `server/src/models/`
2. Add migration logic if needed
3. Update API documentation
4. Test data consistency

## Performance Guidelines

- Minimize re-renders in React components
- Use proper indexing in MongoDB
- Implement pagination for large datasets
- Cache frequently accessed data
- Optimize images and assets

## Security Guidelines

- Never commit `.env` files or secrets
- Validate all user inputs
- Use environment variables for sensitive data
- Keep dependencies up to date
- Run security audits: `npm audit`

## Documentation

All changes should include:
- Code comments for complex logic
- Updated README if changing setup
- API documentation updates
- JSDoc comments for functions (where applicable)

## Getting Help

- Check existing issues and PRs
- Ask questions in PRs or discussions
- Review documentation files
- Check server/client logs for debugging

## Recognition

Contributors will be:
- Listed in the project README
- Credited in release notes
- Recognized for significant contributions

## License

By contributing to AKIBA, you agree that your contributions will be licensed under the MIT License.

## Questions?

Feel free to ask questions by:
- Opening a GitHub Discussion
- Commenting on relevant issues
- Reaching out to maintainers

Thank you for contributing to AKIBA! 🚀
