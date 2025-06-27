# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Mindari is a Phoenix web application built with Elixir. It follows the standard Phoenix project structure with a web layer (`MindariWeb`) and application layer (`Mindari`), using Ecto for database operations and PostgreSQL as the database.

## Essential Commands

### Development Setup
```bash
mix setup                    # Install dependencies, setup database, and build assets
mix phx.server              # Start the development server
iex -S mix phx.server       # Start server in interactive Elixir shell
```

### Testing
```bash
mix test                    # Run all tests
mix test test/path/to/specific_test.exs  # Run specific test file
mix test --cover            # Run tests with coverage
```

### Database Operations
```bash
mix ecto.create             # Create database
mix ecto.migrate            # Run migrations
mix ecto.rollback           # Rollback last migration
mix ecto.reset              # Drop, create, and migrate database
```

### Asset Management
```bash
mix assets.setup            # Install Tailwind and esbuild
mix assets.build            # Build assets for development
mix assets.deploy           # Build and optimize assets for production
```

### Production Build
```bash
./build.sh                  # Complete production build script
./localprodtest.sh          # Run production build locally for testing
```

## Architecture

### Application Structure
- **Mindari.Application**: Main OTP application supervisor
- **MindariWeb.Endpoint**: Phoenix endpoint handling HTTP requests
- **MindariWeb.Router**: Request routing with browser and API pipelines
- **Mindari.Repo**: Ecto repository for database operations
- **MindariWeb.Telemetry**: Application metrics and monitoring

### Key Technologies
- Phoenix Framework (~> 1.8) with LiveView
- Ecto with PostgreSQL
- Tailwind CSS for styling
- esbuild for JavaScript bundling
- Bandit as the HTTP adapter

### Web Layer Structure
- Controllers in `lib/mindari_web/controllers/`
- Templates in `lib/mindari_web/controllers/*/` (HTML modules)
- Core components in `lib/mindari_web/components/`
- Layouts in `lib/mindari_web/components/layouts/`

### Testing Setup
- Tests use ExUnit with Ecto SQL Sandbox for database isolation
- `ConnCase` for controller/integration tests
- `DataCase` for database-related tests
- Test support modules in `test/support/`

### Configuration
- Main config in `config/config.exs`
- Environment-specific configs in `config/{dev,test,prod}.exs`
- Runtime configuration in `config/runtime.exs`

## Development Notes

### Asset Pipeline
The application uses Tailwind CSS and esbuild. Assets are configured in `config/config.exs` and built to `priv/static/assets/`. The development server includes live reloading for both Elixir code and assets.

### Database
PostgreSQL is used with Ecto. The repository is configured as `Mindari.Repo` and migrations are in `priv/repo/migrations/`.

### Production Deployment
- `build.sh` handles complete production builds
- `localprodtest.sh` runs production builds locally with test database credentials
- Uses Mix releases for deployment