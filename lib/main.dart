import 'package:flutter/material.dart';
import 'dart:async';

void main() {
  runApp(const TicTacToeApp());
}

class TicTacToeApp extends StatelessWidget {
  const TicTacToeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0F172A), // Deep Midnight
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.cyanAccent,
          brightness: Brightness.dark,
        ),
      ),
      home: const GameScreen(),
    );
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  // --- Game Logic State ---
  List<String> display = List.filled(9, '');
  bool oTurn = true;
  String winnerMessage = "Your Move!";
  String result = "no winner";
  int remainingSeconds = 15;
  Timer? timer;

  final Color colorX = const Color(0xFFE94560); // Neon Pink/Red
  final Color colorO = const Color(0xFF00D2FF); // Neon Cyan
  final Color gridColor = const Color(0xFF1E293B); // Slate Blue

  void startMoveTimer() {
    timer?.cancel();
    setState(() => remainingSeconds = 15);
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (remainingSeconds > 0) {
        setState(() => remainingSeconds--);
      } else {
        handleMove(-1); // Timeout move
      }
    });
  }

  void handleMove(int index) {
    if (result != "no winner") return;

    setState(() {
      if (index != -1 && display[index] == '') {
        display[index] = oTurn ? "O" : "X";
        oTurn = !oTurn;
      } else if (index == -1) {
        // Switch turn on timeout
        oTurn = !oTurn;
      }

      result = checkWinner();
      if (result != "no winner") {
        timer?.cancel();
        winnerMessage = result == "draw" ? "It's a Draw!" : "Winner: $result";
      } else {
        winnerMessage = "Player ${oTurn ? 'O' : 'X'}'s Turn";
        startMoveTimer();
      }
    });
  }

  String checkWinner() {
    List<List<int>> winConditions = [
      [0, 1, 2], [3, 4, 5], [6, 7, 8], // Rows
      [0, 3, 6], [1, 4, 7], [2, 5, 8], // Cols
      [0, 4, 8], [2, 4, 6], // Diagonals
    ];

    for (var condition in winConditions) {
      if (display[condition[0]] != '' &&
          display[condition[0]] == display[condition[1]] &&
          display[condition[0]] == display[condition[2]]) {
        return display[condition[0]];
      }
    }
    if (!display.contains('')) return "draw";
    return "no winner";
  }

  void resetGame() {
    setState(() {
      display = List.filled(9, '');
      result = "no winner";
      winnerMessage = "Your Move!";
      oTurn = true;
      remainingSeconds = 15;
    });
    timer?.cancel();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            double maxWidth = constraints.maxWidth > 500
                ? 500
                : constraints.maxWidth;

            return Center(
              child: SizedBox(
                width: maxWidth,
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    // Header Section
                    _buildHeader(),
                    const Spacer(),
                    // The Game Grid
                    _buildGrid(maxWidth),
                    const Spacer(),
                    // Bottom Section (Timer & Reset)
                    _buildStatusArea(),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        const Text(
          "TIC TAC TOE",
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w900,
            letterSpacing: 4,
          ),
        ),
        const SizedBox(height: 10),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Text(
            winnerMessage,
            key: ValueKey(winnerMessage),
            style: TextStyle(
              fontSize: 20,
              color: result == "no winner"
                  ? Colors.white70
                  : (result == "draw"
                        ? Colors.orange
                        : (result == "X" ? colorX : colorO)),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGrid(double width) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: AspectRatio(
        aspectRatio: 1,
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 9,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () => handleMove(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                decoration: BoxDecoration(
                  color: gridColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Center(
                  child: AnimatedScale(
                    scale: display[index] == '' ? 0.0 : 1.0,
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.elasticOut,
                    child: Text(
                      display[index],
                      style: TextStyle(
                        fontSize: width * 0.15,
                        fontWeight: FontWeight.w900,
                        color: display[index] == "X" ? colorX : colorO,
                        shadows: [
                          Shadow(
                            color: (display[index] == "X" ? colorX : colorO)
                                .withOpacity(0.5),
                            blurRadius: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatusArea() {
    return Column(
      children: [
        // Modern Timer
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              height: 70,
              width: 70,
              child: CircularProgressIndicator(
                value: remainingSeconds / 15,
                strokeWidth: 6,
                backgroundColor: Colors.white10,
                color: remainingSeconds <= 5
                    ? Colors.redAccent
                    : Colors.cyanAccent,
              ),
            ),
            Text(
              "$remainingSeconds",
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 30),
        ElevatedButton(
          onPressed: resetGame,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFE94560),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            elevation: 10,
          ),
          child: Text(result == "no winner" ? "RESET GAME" : "PLAY AGAIN"),
        ),
      ],
    );
  }
}
