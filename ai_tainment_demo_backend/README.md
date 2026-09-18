# ai_tainment_demo_backend

A small Express 5 API that serves a paginated, two-level dataset: 50 subjects, each
holding 50 topics. It exists to give [`ai_tainment_demo_flutter`](../ai_tainment_demo_flutter)
a real server to page against, so the client's paging logic is exercised over HTTP
rather than against a local list.

Part of the [ai_tainment_demo](..) monorepo.

## Stack

- **Express 5** (`^5.2.1`)
- **cors** (`^2.8.6`) — wide open, so a Flutter web build or a device on the LAN can call it
- CommonJS, no build step, no database

## Running locally

```bash
npm install
npm start          # node server.js
npm run dev        # node --watch server.js — restarts on save
```

The server binds `0.0.0.0` on `PORT` (default `3000`) and prints both URLs on boot:

```
🚀 Backend server running:
   ➜  Local:   http://localhost:3000
   ➜  Network: http://192.168.1.5:3000 (use this for physical phone)
```

The LAN address comes from the first non-internal IPv4 interface. Use it when
running the Flutter app on a **physical device** — `localhost` there resolves to the
phone itself, not your machine.

## The dataset

Built once at startup, held in memory:

```js
const subjectsData = Array.from({ length: 50 }, (_, i) => ({
  subjectId: `subject_${i + 1}`,
  subjectTitle: `Subject ${i + 1}`,
  topicCount: 50,
  topics: [ /* 50 × { topicId, topicTitle } */ ],
}));
```

Nothing is persisted; every restart regenerates identical data. `server.js` marks the
spot where a real datastore (PostgreSQL, MongoDB, Prisma) would replace it.

## Endpoints

### `GET /`

Health check. Returns the string `Hello World!`. Used as Render's health check path.

### `GET /api/subjects?page=1&limit=10`

A page of subjects. **`topics` is deliberately returned empty** — the list view only
needs the count, and shipping 50 nested topics per subject would make the payload
~50× larger for data the screen never draws. Clients fetch topics separately.

| Param | Default | Notes |
| --- | --- | --- |
| `page` | `1` | 1-based |
| `limit` | `10` | items per page |

```jsonc
[
  { "subjectId": "subject_1", "subjectTitle": "Subject 1", "topicCount": 50, "topics": [] },
  { "subjectId": "subject_2", "subjectTitle": "Subject 2", "topicCount": 50, "topics": [] }
]
```

Paging past the end returns `[]` rather than an error — which is how the client
detects the last page (a short page means no `nextKey`).

### `GET /api/subjects/:subjectId/topics?page=1&limit=10`

A page of topics within one subject. Returns `404 {"error":"Subject not found"}` for
an unknown `subjectId`.

```jsonc
[
  { "topicId": "subject_1_topic_1", "topicTitle": "Topic 1" },
  { "topicId": "subject_1_topic_2", "topicTitle": "Topic 2" }
]
```

### Try it

```bash
curl "http://localhost:3000/api/subjects?page=1&limit=3"
curl "http://localhost:3000/api/subjects/subject_1/topics?page=2&limit=5"
curl -i "http://localhost:3000/api/subjects/nope/topics"   # 404
```

## Configuration

| Variable | Default | Purpose |
| --- | --- | --- |
| `PORT` | `3000` | Listen port. Render sets this automatically. |

## Deploying to Render

This service lives in a subdirectory of a monorepo, so Render needs to be told where
it is. [`render.yaml`](../render.yaml) at the repo root already declares that:

```yaml
services:
  - type: web
    name: ai-tainment-backend
    runtime: node
    rootDir: ai_tainment_demo_backend   # commands run from here
    buildCommand: npm install
    startCommand: npm start
    healthCheckPath: /
    buildFilter:
      paths:
        - ai_tainment_demo_backend/**   # repo-root-relative, unlike the commands above
```

**Via Blueprint (recommended).** In the Render dashboard: **New → Blueprint**, pick
this repository, and Render reads `render.yaml`. Everything below is set for you.

**Via the dashboard manually.** New → Web Service, then under **Settings → Build &
Deploy**:

| Setting | Value |
| --- | --- |
| Root Directory | `ai_tainment_demo_backend` |
| Build Command | `npm install` |
| Start Command | `npm start` |
| Health Check Path | `/` |
| Build Filters → Included Paths | `ai_tainment_demo_backend/**` |

Two things worth knowing about monorepos on Render:

- **`rootDir` changes where commands run.** `buildCommand` and `startCommand` are
  resolved inside it, which is why they are plain `npm install` / `npm start` and not
  `cd ai_tainment_demo_backend && ...`.
- **Build filter paths are *not* relative to `rootDir`** — they are always relative to
  the repository root. Without the filter, every commit to a Flutter project in this
  monorepo would trigger a pointless API redeploy.

No code changes are needed for Render: `server.js` already reads `process.env.PORT`
and binds `0.0.0.0`, which is what Render requires.

### Pointing the Flutter client at your instance

[`ai_tainment_demo_flutter`](../ai_tainment_demo_flutter) hardcodes the base URL in
`lib/repository/mock_repository_online.dart`:

```dart
final String baseURL = "https://ai-tainment-backend.onrender.com/";
```

If your Render service gets a different name, update that string to match — or point
it at your machine's LAN address to develop against a local server.

> **Free tier note:** Render spins free services down after inactivity. The first
> request after an idle period can take 50+ seconds while the instance cold-starts,
> which the client surfaces as a slow first page load.
