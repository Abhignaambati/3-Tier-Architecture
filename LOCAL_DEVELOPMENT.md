# Local Development Setup

This project runs three local services with Docker Compose:

- `frontend`: React/Vite application
- `backend`: Flask API
- `db`: PostgreSQL database

No worker service is required for this application.

## Prerequisites

- Docker Desktop
- Docker Compose
- Git

Verify Docker:

```bash
docker info
docker compose version
```

## Configuration

Create the private local environment file from the safe example:

```bash
cp .env.example .env
```

Open `.env` and replace:

```text
POSTGRES_PASSWORD=replace-with-your-local-password
```

with your local database password.

The `.env` file contains local secrets and is excluded from Git. Never commit it or include it in screenshots.

Docker Compose automatically reads `.env`. The backend connects to PostgreSQL using the Compose service name `db` and container port `5432`.

## Start the application

The main command a new learner should run is:

```bash
docker compose up -d --build
```

This builds the frontend and backend images, starts PostgreSQL, waits for the database health check, and starts the application services.

## Check service status

```bash
docker compose ps
```

Expected local endpoints:

- Frontend: http://127.0.0.1:5173
- Backend health: http://127.0.0.1:5000/api/health
- Backend claims: http://127.0.0.1:5000/api/claims
- PostgreSQL host port: `127.0.0.1:15432`

## Verify the application

```bash
curl -i http://127.0.0.1:5000/api/health
curl -i http://127.0.0.1:5000/api/claims
curl -I http://127.0.0.1:5173
```

## Verify database connectivity

```bash
docker compose exec -T db sh -lc \
'psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c "SELECT current_user, current_database();"'
```

## View logs

```bash
docker compose logs --tail=50 backend
docker compose logs --tail=50 db
docker compose logs --tail=50 frontend
```

Follow logs continuously:

```bash
docker compose logs -f backend
```

Press `Control+C` to stop following logs. This does not stop the container.

## Stop and restart

Stop the containers while preserving database data:

```bash
docker compose down
```

Restart the application:

```bash
docker compose up -d
```

Do not use `docker compose down -v` unless the database data should be deleted.

## Troubleshooting example

A controlled test used the incorrect database port `5999`. The claims endpoint returned HTTP `500` with a connection-refused error.

The backend was recovered by recreating it with the correct configuration from `.env`:

```bash
docker compose up -d --no-deps --force-recreate backend
```

After recovery, the health and claims endpoints returned HTTP `200`.

## Evidence

Use Case 3 command output is stored in:

```text
usecase3-evidence/
```

The evidence includes service status, runtime configuration without passwords, database connectivity, the controlled failure, and successful recovery.