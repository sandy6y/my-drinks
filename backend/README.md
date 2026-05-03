# Caffeinate Backend (FastAPI + SQLite)

This backend is isolated in `/backend` and does not change the existing SwiftUI frontend.

## Stack

- FastAPI
- SQLite (file database at `backend/data/caffeinate.db`)
- SQLAlchemy ORM

## Run Locally

```bash
cd backend
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
uvicorn app.main:app --reload
```

Server starts at `http://127.0.0.1:8000`.

## Deploy to Render

Create a new **Web Service** in Render and point it at this repository.

Recommended settings:

- **Root Directory**: `backend`
- **Runtime**: Python 3
- **Build Command**: `pip install -r requirements.txt`
- **Start Command**: `uvicorn app.main:app --host 0.0.0.0 --port $PORT`

Render provides the `PORT` environment variable automatically. The backend creates its SQLite database at `backend/data/caffeinate.db` on startup when running locally or on the service filesystem.

For a production app, consider using a managed database instead of Render's ephemeral service filesystem. The local SQLite database and virtual environment are ignored by git and should not be deployed.

### CORS

CORS is enabled for local/browser testing. Native iOS apps are not restricted by browser CORS, but the API also accepts browser requests from local development clients.

## API Endpoints

### 1) Health

- `GET /health`

Response:

```json
{ "status": "ok" }
```

### 2) List Logs

- `GET /v1/logs`
- Optional query params: `from`, `to`, `limit`

Response shape matches frontend fetch expectation: **raw array of logs**.

```json
[
  {
    "id": "6f3cd4de-0327-4971-9ad7-f1fc8be7e7d5",
    "name": "Vanilla Latte",
    "time": "2026-04-20T09:15:00Z",
    "type": "latte",
    "size": "medium",
    "temperature": "iced",
    "caffeine": 75,
    "sugar": 10,
    "price": 6.0,
    "rating": 3,
    "note": null
  }
]
```

### 3) Create Log

- `POST /v1/logs`

Request:

```json
{
  "name": "Vanilla Latte",
  "time": "2026-04-20T09:15:00Z",
  "type": "latte",
  "size": "medium",
  "temperature": "iced",
  "caffeine": 75,
  "sugar": 10,
  "price": 6.0,
  "rating": 3,
  "note": null
}
```

Response `201` returns a single log object (with generated `id`).

### 4) Update Log

- `PATCH /v1/logs/{log_id}`

Request (partial):

```json
{
  "rating": 4,
  "note": "Better than last time"
}
```

Response `200` returns the updated log object.

### 5) Delete Log

- `DELETE /v1/logs/{log_id}`

Response: `204 No Content`

## Notes for Frontend Integration

- Enum values are intentionally aligned with Swift `Log.swift`:
  - `type`: `espresso`, `americano`, `latte`, `mocha`, `flatWhite`, `cappuccino`, `matcha`, `tea`, `boba`, `energydrink`, `other`
  - `size`: `small`, `medium`, `large`, `XL`
  - `temperature`: `hot`, `iced`
- `time` is returned as ISO-8601 datetime.
