# ai_tainment_demo_flutter

A two-level paginated browser — subjects, then topics within a subject — that
**remembers where you were**. Close the app mid-list and reopen it: the subject list
opens on the page you left, the row you last touched scrolls itself into view, and
every topic you tapped is still marked complete.

Part of the [ai_tainment_demo](..) monorepo. Backed by
[`ai_tainment_demo_backend`](../ai_tainment_demo_backend).

## What it demonstrates

- **Bidirectional pagination** with [`super_paging`](https://pub.dev/packages/super_paging) — pages load in both directions, so a list can open in the *middle* of the dataset and grow upward as well as downward.
- **Resumable position** — the page index and item index of the last interaction are persisted and fed back as the pager's `initialKey`.
- **Swappable data sources** — the same `PagingSource` runs against either a live HTTP repository or a local generator, behind one boolean.
- **Per-subject progress** — completion percentage and a progress bar derived from persisted state.

## Stack

| Package | Role |
| --- | --- |
| [`get`](https://pub.dev/packages/get) `4.7.3` | Routing (`GetMaterialApp`/`GetPage`), DI (`lazyPut`/`Get.find`), reactivity (`Obx`/`Rx`) |
| [`super_paging`](https://pub.dev/packages/super_paging) `^0.2.0` | `Pager`, `PagingSource`, `BidirectionalPagingListView` |
| [`get_storage`](https://pub.dev/packages/get_storage) `^2.1.1` | Local persistence of progress |

## Running

```bash
flutter pub get
flutter run
```

Out of the box it calls the deployed backend at
`https://ai-tainment-backend.onrender.com/`. **No backend? No problem** — see
[Going offline](#going-offline) to run entirely on generated data.

## Architecture

```
main.dart
  └─ registers StorageService, MockRepositoryOffline, MockRepositoryOnline (lazyPut, fenix)
       │
AppRoutes ─────────────┬──────────────────────┐
  "/"        SubjectScreen + SubjectBinding   │
  "/topic"   TopicScreen   + TopicBinding     │
                           │                  │
              SubjectController      TopicController
                           │                  │
                        Pager<int, SubjectModel> / Pager<int, TopicModel>
                           │
              SubjectPaginationFactory / TopicPaginationFactory   (PagingSource)
                           │
              ┌────────────┴────────────┐
    MockRepositoryOnline        MockRepositoryOffline
    (GetConnect → HTTP)         (generated, 500 ms fake latency)
```

```
lib/
├── main.dart                        # bootstrap: GetStorage.init, DI, GetMaterialApp
├── config/page_config.dart          # PagingConfig + dataset constants
├── utils/app_routes.dart            # route table
├── bindings/                        # one Bindings per screen, lazyPut its controller
├── controllers/                     # pager construction + progress math
├── factory/pagination_factory.dart  # the two PagingSource implementations
├── models/                          # SubjectModel, TopicModel, MemoryModel
├── repository/                      # online (HTTP) and offline (generated)
├── screens/                         # SubjectScreen, TopicScreen
├── services/storage_service.dart    # get_storage read/write of MemoryModel list
└── widgets/                         # AutoScrollItem, shared list-state builders
```

### Paging

Configuration is one shared constant (`config/page_config.dart`):

```dart
const PagingConfig config = PagingConfig(pageSize: 10, initialLoadSize: 10);
```

Each `PagingSource.load` returns the page plus its neighbours' keys. `prevKey` is
non-null whenever `page > 1` — that's what makes upward paging work when the list
opens mid-dataset:

```dart
return LoadResult<int, SubjectModel>.page(
  items: items,
  prevKey: page > 1 ? page - 1 : null,
  nextKey: hasNextPage ? page + 1 : null,
);
```

End-of-list detection differs between the two sources, because they know different
things. Subjects infer it from a short page:

```dart
final bool hasNextPage = items.length == params.loadSize;
```

Topics also have `subject.topicCount` available, so they can stop without a wasted
round trip for an empty page:

```dart
final bool hasNextPage = items.length == params.loadSize &&
    (subject.topicCount <= 0 || page * params.loadSize < subject.topicCount);
```

`Pager` instances are cached per subject in a map and disposed in the controller's
`onClose`, so navigating back into a subject reuses its loaded pages instead of
refetching from page 1.

### Progress memory

One `MemoryModel` per subject, persisted as a JSON list under a single `get_storage`
key:

| Field | Meaning |
| --- | --- |
| `subjectId` | which subject this record is for |
| `subjectPageIndex`, `subjectItemIndex` | where that subject sat in the subject list |
| `topicPageIndex`, `topicItemIndex` | the last topic touched inside it |
| `topicIds` | every topic tapped — the completion set |
| `updated` | ISO 8601 timestamp, used for "most recent" ordering |

Tapping a topic **toggles** it in `topicIds` and rewrites the record with a fresh
timestamp:

```dart
(!rememberedIds.contains(topic.topicId))
    ? rememberedIds.add(topic.topicId)
    : rememberedIds.remove(topic.topicId);
```

Because `rememberedItems` is an `RxList`, the subject list's percentage and progress
bar update the moment a topic is tapped two screens away — no manual refresh.

### How "resume" is assembled

Three pieces cooperate:

1. **Which page to open on.** `StorageService.sortByLatestToLeastLatest()` orders
   records by `updated`, and the most recent one's `subjectPageIndex` becomes the
   subject pager's `initialKey`. Within a subject, `topicPageIndex` does the same for
   the topic pager.
2. **Which row to scroll to.** `AutoScrollItem` wraps the row that
   `isLatestSubject`/`isLatestTopic` identifies as most recent. On mount it waits one
   second — long enough for the page to lay out — then walks up to the enclosing
   `Scrollable` and calls `position.ensureVisible(...)`.
3. **What's already done.** `topicIds` drives both the per-topic checkmark and the
   subject's percentage:

   ```dart
   return ((countBySubjectId(subject) / subject.topicCount) * 100).clamp(0.0, 100.0);
   ```

### Going offline

Both `PagingSource` implementations take a `useOnline` flag that defaults to `true`.
`MockRepositoryOffline` generates the same 50 × 50 shape locally with a deliberate
500 ms delay so loading states still appear:

```dart
// factory/pagination_factory.dart
final List<SubjectModel> items = useOnline
    ? await Get.find<MockRepositoryOnline>().getSubjects(page, params.loadSize)
    : await Get.find<MockRepositoryOffline>().getSubjects(page, params.loadSize);
```

To switch, pass the flag where the controllers build their factories — in
`controllers/subject_controller.dart` and `controllers/topic_controller.dart`:

```dart
pagingSourceFactory: () => SubjectPaginationFactory(useOnline: false),
```

Dataset size for the offline generator lives in `config/page_config.dart`
(`totalSubjects`, `topicsPerSubject`).

### Pointing at a different server

`lib/repository/mock_repository_online.dart`:

```dart
final String baseURL = "https://ai-tainment-backend.onrender.com/";
```

Swap in `http://localhost:3000/` for a local backend, or your machine's LAN IP (which
the backend prints on boot) when running on a physical device.

`MockRepositoryOnline` extends GetX's `GetConnect` and validates defensively before
parsing — non-2xx, null body, and "expected a List but got something else" each throw
a described `Exception` that the `PagingSource` converts into
`LoadResult.error`, which `super_paging` renders through the shared error builder.

### Models

`SubjectModel`, `TopicModel`, and `MemoryModel` are hand-written and `@immutable`,
each with `fromJson`, `toJson`, `copyWith`, and `==`/`hashCode`. Equality is
**identity-only** — `SubjectModel` compares `subjectId`, `TopicModel` compares
`topicId`:

```dart
@override
bool operator ==(Object other) =>
    identical(this, other) ||
    other is SubjectModel && runtimeType == other.runtimeType && subjectId == other.subjectId;
```

That is what lets a subject fetched in a list view (with `topics: []`) compare equal
to the same subject fetched in detail, so the pager treats them as one item rather
than a duplicate.

### Shared list states

`widgets/common_states.dart` centralises every paging state so the two screens stay
declarative: a `CupertinoActivityIndicator` while loading, `"List is currently
empty"` when empty, an error icon on failure, and prepend/append builders that
`switch` exhaustively over `super_paging`'s sealed `LoadState`
(`NotLoading` / `Loading` / `Error`).

## Notes

- `enableLog: false` and `debugShowCheckedModeBanner: false` are set on
  `GetMaterialApp`; repositories and paging sources log through `dart:developer`'s
  `log()` with error and stack trace attached.
- Services are registered with `fenix: true`, so they are rebuilt on demand if GetX
  ever disposes them.
- The UI is intentionally plain — `Card.outlined`, `LinearProgressIndicator`, no
  theming — to keep the paging and persistence logic in the foreground.
