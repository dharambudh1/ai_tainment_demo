# tic_tac_toe_demo

A two-player tic-tac-toe game in a single 119-line file, with no dependencies beyond
Flutter itself and no state management beyond `setState`. Included as the deliberate
counterweight to the other projects in this repo: the smallest thing that works.

Part of the [ai_tainment_demo](..) monorepo.

## Running

```bash
flutter pub get
flutter run
```

Two players share the device. X moves first. Tap an empty cell to claim it; the board
locks when someone wins or it fills up, and a SnackBar announces the result. **Reset
Game** clears it.

## Stack

Just `flutter`. `pubspec.yaml` lists no runtime dependencies — only `flutter_lints`
for analysis.

## How it works

The whole game is three fields on one `State`:

```dart
final List<String?> ticTacToeGrid = List<String?>.filled(9, null);
bool isXTurn = true;
bool isFrozen = false;
```

- **`ticTacToeGrid`** — nine cells, flat. `null` is empty, otherwise `"X"` or `"O"`.
  Fixed-length, and reset in place with `fillRange` rather than reallocated.
- **`isXTurn`** — whose move it is, flipped on every accepted tap.
- **`isFrozen`** — set once the game ends, so taps stop registering without needing
  to unmount anything.

The board is a `GridView.builder` with `crossAxisCount: 3`, so the flat list maps to
a 3×3 grid without any index arithmetic. Each cell is a `GestureDetector` that
rejects the tap outright if the game is over or the cell is taken:

```dart
if (isFrozen || ticTacToeGrid[index] != null) {
  return;
}
```

After a move it checks for a winner and for a full board, freezes if either is true,
and shows the result:

```dart
final String message = winner != null ? "$winner is winner" : "Match drawn";
```

Win detection compares against the eight lines declared as a `static const`:

```dart
static const List<List<int>> winPossibility = <List<int>>[
  <int>[0, 1, 2], <int>[3, 4, 5], <int>[6, 7, 8],   // rows
  <int>[0, 3, 6], <int>[1, 4, 7], <int>[2, 5, 8],   // columns
  <int>[0, 4, 8], <int>[2, 4, 6],                   // diagonals
];
```

Each line's three cells are joined into a string and compared against `"XXX"` /
`"OOO"` — which avoids three separate equality checks per line:

```dart
final String cells = line.map((int i) => ticTacToeGrid[i] ?? "").join();
```

## Known issues

**Only the top row is ever checked for a win.** In `checkWinner()`, the `return`
sits inside the `for` loop unconditionally, so the first iteration always returns and
the remaining seven lines are unreachable:

```dart
for (final List<int> line in winPossibility) {
  final String cells = /* ... */;
  return (cells == "XXX") ? "X" : (cells == "OOO") ? "O" : null;   // ← returns on line 1
}
```

In practice a win on any row but the top, any column, or either diagonal goes
undetected, and play continues until the board fills and reports a draw. The fix is
to only return on a match and let the loop continue otherwise:

```dart
String? checkWinner() {
  for (final List<int> line in winPossibility) {
    final String cells = line.map((int i) => ticTacToeGrid[i] ?? "").join();
    if (cells == "XXX") return "X";
    if (cells == "OOO") return "O";
  }
  return null;
}
```

Other rough edges, left as-is to keep the file minimal:

- No turn indicator — whose move it is isn't shown anywhere on screen.
- No score kept across resets.
- `MaterialApp` is constructed inside the stateful widget's `build`, rather than
  above it.
