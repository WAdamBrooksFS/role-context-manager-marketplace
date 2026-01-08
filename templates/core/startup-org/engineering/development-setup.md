# Development Setup

**Status:** Living | **Update Frequency:** When setup changes
**Primary Roles:** Technical Co-founder, All Engineers  
**Related Documents:** `/engineering/tech-stack.md`, `/engineering/contributing.md`

## Prerequisites

**Required:**
- [e.g., Node.js 20+ LTS]
- [e.g., pnpm 8+]
- Git
- [Your database, e.g., PostgreSQL 15+]

**Optional:**
- Docker (if using)
- [IDE of choice - VS Code recommended]

## Quick Start (First Time Setup)

```bash
# 1. Clone repository
git clone [repo-url]
cd [repo-name]

# 2. Install dependencies
pnpm install  # or npm install, yarn install

# 3. Copy environment variables
cp .env.example .env
# Edit .env with your local values

# 4. Set up database
pnpm db:setup  # or npm run db:setup

# 5. Run development server
pnpm dev  # or npm run dev

# 6. Open browser
# http://localhost:3000 (or configured port)
```

## Environment Variables

Required variables in `.env`:
```bash
DATABASE_URL="postgresql://..." 
API_KEY="..."
# ... other required env vars
```

## Common Commands

```bash
# Development
pnpm dev              # Start dev server

# Testing
pnpm test             # Run tests
pnpm test:watch       # Watch mode

# Database
pnpm db:migrate       # Run migrations
pnpm db:seed          # Seed data
pnpm db:reset         # Reset database

# Linting/Formatting
pnpm lint             # Run linter
pnpm format           # Format code

# Build
pnpm build            # Production build
```

## Troubleshooting

**Database connection fails:**
- Check DATABASE_URL in .env
- Ensure PostgreSQL is running

**Port already in use:**
- Change PORT in .env
- Or kill process: `lsof -ti:[port] | xargs kill`

**Dependencies won't install:**
- Clear cache: `pnpm store prune`
- Delete node_modules, reinstall

## IDE Setup (VS Code)

**Recommended Extensions:**
- ESLint
- Prettier
- [Language-specific extensions]

**Settings:**
```json
{
  "editor.formatOnSave": true,
  "editor.codeActionsOnSave": {
    "source.fixAll.eslint": true
  }
}
```

---

**Last Updated:** [Date]
**Document Owner:** Technical Co-founder
