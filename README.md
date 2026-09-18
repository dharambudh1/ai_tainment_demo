# ai_tainment_demo

A monorepo of three Flutter apps and the Node.js API that backs one of them. Each
project isolates one problem and solves it end to end — two-level pagination with
resumable progress, a production-shaped `dio` HTTP stack, and a minimal game.

## Projects

| Project | Stack | What it demonstrates |
| --- | --- | --- |
| [`ai_tainment_demo_backend`](ai_tainment_demo_backend) | Node.js 22, Express 5 | Paginated REST API over 50 subjects × 50 topics |
| [`ai_tainment_demo_flutter`](ai_tainment_demo_flutter) | Flutter, GetX, `super_paging`, `get_storage` | Bidirectional paging, swappable online/offline repositories, and per-subject progress that survives restarts |
| [`dio_example`](dio_example) | Flutter, GetX, `dio`, `fresh_dio` | A four-interceptor HTTP client: cache → auth/refresh → retry → logging |
| [`tic_tac_toe_demo`](tic_tac_toe_demo) | Flutter | A single-file game in plain `setState` |

## Repository layout

```
ai_tainment_demo/
├── render.yaml                 # Render Blueprint for the backend service
├── ai_tainment_demo_backend/   # Express API
├── ai_tainment_demo_flutter/   # Paging + progress-memory demo
├── dio_example/                # Networking demo
└── tic_tac_toe_demo/           # Game
```

The three Flutter projects are independent — each has its own `pubspec.yaml` and is
opened and run on its own. There is no workspace or shared package between them.

## Prerequisites

- **Flutter SDK** with Dart `^3.12.0` (developed against Flutter 3.44.0 stable)
- **Node.js 22+** for the backend

## Quick start

```bash
git clone https://github.com/dharambudh1/ai_tainment_demo.git
cd ai_tainment_demo
```

Then follow the README in whichever project you want to run. The fastest path with
no setup at all is `dio_example` — it talks to a public API and needs no local
server:

```bash
cd dio_example && flutter pub get && flutter run
```

## Shared conventions

All three Flutter projects share the same `analysis_options.yaml`: `flutter_lints`
plus ~180 explicitly enabled rules. Notably strict ones that shape how the code
reads:

- `always_specify_types` — no bare `var`; every type is written out, including
  generic arguments on literals (`<String>[]`).
- `always_use_package_imports` — no relative imports anywhere.
- `avoid_catches_without_on_clauses` — every `catch` names what it catches.
- `always_declare_return_types`, `always_put_control_body_on_new_line`,
  `avoid_dynamic_calls`.

Run the analyzer from any project root:

```bash
flutter analyze
```

Two of the apps (`ai_tainment_demo_flutter`, `dio_example`) use the same
architecture: GetX for routing and DI, one `GetPage` per screen with a `Bindings`
class that `lazyPut`s its controller, immutable models with
`fromJson`/`toJson`/`copyWith`, and a repository layer between controllers and the
network.

## Deployment

The backend deploys to Render from `render.yaml` in this repo root. See
[`ai_tainment_demo_backend/README.md`](ai_tainment_demo_backend#deploying-to-render)
for the setup steps and for how to point the Flutter client at your own instance.
