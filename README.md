# ai_tainment_demo

A collection of Flutter demo apps and a companion Node.js backend, built to explore
pagination, networking, and state management patterns.

## Projects

| Project | Stack | What it demonstrates |
| --- | --- | --- |
| [`ai_tainment_demo_backend`](ai_tainment_demo_backend) | Node.js, Express | Paginated REST API serving subjects and their nested topics |
| [`ai_tainment_demo_flutter`](ai_tainment_demo_flutter) | Flutter, GetX, `super_paging` | Paged subject/topic lists with offline and online repositories |
| [`dio_example`](dio_example) | Flutter, GetX, `dio` | A layered HTTP client: auth/refresh, caching, retry, and logging interceptors |
| [`tic_tac_toe_demo`](tic_tac_toe_demo) | Flutter | A minimal tic-tac-toe game |

## Getting started

Requires the Flutter SDK (Dart `^3.12.0`) and Node.js.

### Backend

```bash
cd ai_tainment_demo_backend
npm install
node server.js
```

It listens on `PORT` (default `3000`) and prints both a `localhost` and a LAN URL —
use the LAN one when running the Flutter app on a physical device.

Endpoints:

- `GET /api/subjects?page=1&limit=10`
- `GET /api/subjects/:subjectId/topics?page=1&limit=10`

### Flutter apps

Each app is a standalone Flutter project:

```bash
cd <project>
flutter pub get
flutter run
```

`ai_tainment_demo_flutter` expects the backend above to be reachable.
`dio_example` talks to the public [dummyjson.com](https://dummyjson.com) API, so it
needs no local server.
