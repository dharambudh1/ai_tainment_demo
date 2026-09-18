import "package:flutter/material.dart";

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  static const List<List<int>> winPossibility = <List<int>>[
    <int>[0, 1, 2],
    <int>[3, 4, 5],
    <int>[6, 7, 8],
    <int>[0, 3, 6],
    <int>[1, 4, 7],
    <int>[2, 5, 8],
    <int>[0, 4, 8],
    <int>[2, 4, 6],
  ];

  final List<String?> ticTacToeGrid = List<String?>.filled(9, null);
  bool isXTurn = true;
  bool isFrozen = false;

  void reset() {
    ticTacToeGrid.fillRange(0, ticTacToeGrid.length, null);
    isXTurn = true;
    isFrozen = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: SafeArea(
          child: Column(
            children: <Widget>[
              Expanded(child: ticTacToeBoard()),
              ElevatedButton(onPressed: reset, child: const Text("Reset Game")),
            ],
          ),
        ),
      ),
    );
  }

  Widget ticTacToeBoard() {
    return GridView.builder(
      itemCount: ticTacToeGrid.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
      ),
      itemBuilder: (BuildContext context, int index) {
        return GestureDetector(
          onTap: () {
            if (isFrozen || ticTacToeGrid[index] != null) {
              return;
            }

            ticTacToeGrid[index] = isXTurn ? "X" : "O";
            isXTurn = !isXTurn;
            setState(() {});

            final String? winner = checkWinner();
            final bool isBoardFull = !ticTacToeGrid.contains(null);

            if (winner != null || isBoardFull) {
              isFrozen = true;
              setState(() {});

              final String message = winner != null
                  ? "$winner is winner"
                  : "Match drawn";

              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(message)));
            }
          },
          child: DecoratedBox(
            decoration: BoxDecoration(border: Border.all()),
            child: Center(
              child: Text(
                ticTacToeGrid[index] ?? "",
                style: const TextStyle(fontSize: 24),
              ),
            ),
          ),
        );
      },
    );
  }

  String? checkWinner() {
    for (final List<int> line in winPossibility) {
      /// Combining the value of the cells in the line
      final String cells = line.map((int i) {
        return ticTacToeGrid[i] ?? "";
      }).join();

      /// A match ends the search; anything else must fall through to the
      /// next line, or only the first line would ever be checked.
      if (cells == "XXX") {
        return "X";
      }

      if (cells == "OOO") {
        return "O";
      }
    }

    return null;
  }
}
