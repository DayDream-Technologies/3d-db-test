# Local restaurant test project

Node.js + Express + **SQLite** (`better-sqlite3`) with a **vanilla** static UI. Intended for **local use only** (no authentication, no production hardening).

## Quick start

```bash
npm install
npm start
```

Open [http://localhost:3000](http://localhost:3000). The API is under `/api`.

## Reset the database

Stop the server, delete `data/restaurant.db`, then run `npm start` again. On first boot, `db/schema.sql` and `db/seed.sql` are applied automatically.

## Project layout

- `server.js` — HTTP server and database path
- `db/schema.sql`, `db/seed.sql`, `db/init.js` — schema and seed
- `routes/` — JSON REST handlers
- `public/` — static HTML/CSS/JS
- `queries/` — example SQL for reports and joins

## API (summary)

| Method | Path | Purpose |
|--------|------|---------|
| GET | `/api/summary` | Open orders, today’s reservations, waitlist count |
| GET | `/api/menu?available=1` | Menu by category |
| GET | `/api/tables` | Active tables |
| GET | `/api/customers?q=` | Search customers (max 20) |
| POST | `/api/customers` | Create customer |
| POST | `/api/orders` | Create order (transaction: lines, promo, pending payment) |
| GET | `/api/orders?status=open` | List orders |
| GET | `/api/orders/:id` | Order detail |
| PATCH | `/api/orders/:id/status` | Set status; `closed` fills sample card payment |
| GET | `/api/reservations?from=&to=` | List reservations in window |
| POST | `/api/reservations` | Book (overlap check per table) |
| GET | `/api/waitlist` | List waitlist |
| POST | `/api/waitlist` | Add entry |

Default port: **3000** (override with `PORT`).
