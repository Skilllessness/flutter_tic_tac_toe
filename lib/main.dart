import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var tiles = List.filled(9, 0);

  GameState get currentState {
    return isWinning(1, tiles)
        ? GameState.playerWon
        : isWinning(2, tiles)
            ? GameState.aiWon
            : tiles.any((element) => element == 0)
                ? GameState.playing
                : GameState.draw;
  }

  bool isPlayersTurn = true;

  @override
  Widget build(BuildContext context) {
    String gameStateText;
    switch (currentState) {
      case GameState.playerWon:
        gameStateText = 'You Won';
        break;
      case GameState.aiWon:
        gameStateText = 'You Lost!';
        break;
      case GameState.playing:
        gameStateText = 'Your move';
        break;
      case GameState.draw:
        gameStateText = 'Game Drawn';
        break;
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Skilllessness Tic Tac Toe",
        ),
      ),
      body: OrientationBuilder(
        builder: (context, orientation) {
          final children = [
            AspectRatio(
              aspectRatio: 1,
              child: GridView.count(
                crossAxisCount: 3,
                children: [
                  for (var i = 0; i < 9; i++)
                    Material(
                      color: tiles[i] == 0
                          ? Colors.white
                          : tiles[i] == 1
                              ? Colors.green
                              : Colors.yellow,
                      child: InkWell(
                        onTap:
                            (currentState == GameState.playing && tiles[i] == 0)
                                ? () {
                                    if (isPlayersTurn) {
                                      setState(() {
                                        tiles[i] = 1;
                                        if (!isWinning(1, tiles)) {
                                          runAi();
                                        }
                                      });
                                    }
                                  }
                                : null,
                        child: Center(
                          child: Text(
                            tiles[i] == 0
                                ? ''
                                : tiles[i] == 1
                                    ? 'X'
                                    : 'O',
                            style: const TextStyle(fontSize: 40),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Flexible(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(gameStateText),
                  OutlinedButton(
                    onPressed: () {
                      setState(() {
                        tiles = List.filled(9, 0);
                      });
                    },
                    child: const Text("Restart"),
                  )
                ],
              ),
            )
          ];
          if (orientation == Orientation.landscape) {
            return Row(
              children: children,
            );
          }
          return Column(
            children: children,
          );
        },
      ),
    );
  }

  void runAi() async {
    isPlayersTurn = false;
    await Future.delayed(const Duration(milliseconds: 200));
    int? winning;
    int? blocking;
    int? normal;

    for (var i = 0; i < 9; i++) {
      var val = tiles[i];

      if (val > 0) {
        continue;
      }

      // assign potential future cpu's move
      var future = [...tiles];
      future[i] = 2;
      // If we/AI is winning
      if (isWinning(2, future)) {
        winning = i;
      }

      // assign potential future player's move
      future[i] = 1;

      // If Player is winning.
      if (isWinning(1, future)) {
        blocking = i;
      }

      normal = i;
    }

    var move = winning ?? blocking ?? normal;
    if (move != null) {
      setState(() {
        tiles[move] = 2;
      });
    }

    isPlayersTurn = true;
  }

  bool isWinning(int who, List<int> future) {
    return (future[0] == who && future[1] == who && future[2] == who) ||
        (future[3] == who && future[4] == who && future[5] == who) ||
        (future[6] == who && future[7] == who && future[8] == who) ||
        (future[0] == who && future[4] == who && future[8] == who) ||
        (future[2] == who && future[4] == who && future[6] == who) ||
        (future[0] == who && future[3] == who && future[6] == who) ||
        (future[1] == who && future[4] == who && future[7] == who) ||
        (future[2] == who && future[5] == who && future[8] == who);
  }
}

enum GameState {
  playing,
  draw,
  playerWon,
  aiWon,
}
