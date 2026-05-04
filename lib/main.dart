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

class _GameScreenState extends State<GameScreen>
    with SingleTickerProviderStateMixin {
  List<String> display = List.filled(9, '');
  bool oTurn = true;
  String winnerMessage = "Turn O";
  String result = "no winner";
  int remainingSeconds = 15;
  Timer? timer;

  // Colors
  final Color colorX = const Color(0xFFE94560); // Neon Pink
  final Color colorO = const Color(0xFF00D2FF); // Neon Cyan
  final Color gridColor = const Color(0xFF1E293B);

  // Animation for the Winning Line
  late AnimationController _lineController;
  List<int>? winningIndices;

  @override
  void initState() {
    super.initState();
    _lineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
  }

  void startMoveTimer() {
    timer?.cancel();
    setState(() => remainingSeconds = 15);
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (remainingSeconds > 0) {
        setState(() => remainingSeconds--);
      } else {
        handleMove(-1); // Switch turn on timeout
      }
    });
  }

  bool gameStarted = false;

  void handleMove(int index) {
    if (result != "no winner") return;

    setState(() {
      if (index != -1 && display[index] == '') {
        gameStarted = true;
        display[index] = oTurn ? "O" : "X";
        oTurn = !oTurn;
      } else if (index == -1) {
        // This handles the timeout case
        oTurn = !oTurn;
      }

      var winData = checkWinnerData();
      if (winData != null) {
        timer?.cancel();
        gameStarted = false; // Stop the game state
        if (winData is List<int>) {
          winningIndices = [winData[0], winData[2]];
          result = display[winData[0]];
          winnerMessage = "Winner: $result";
          _lineController.forward();
        } else {
          result = "draw";
          winnerMessage = "It's a Draw!";
        }
      } else {
        winnerMessage = "Turn ${oTurn ? 'O' : 'X'}";

        // ONLY start the timer if a move has actually been made
        if (gameStarted) {
          startMoveTimer();
        }
      }
    });
  }

  dynamic checkWinnerData() {
    List<List<int>> lines = [
      [0, 1, 2], [3, 4, 5], [6, 7, 8], // Rows
      [0, 3, 6], [1, 4, 7], [2, 5, 8], // Cols
      [0, 4, 8], [2, 4, 6], // Diagonals
    ];
    for (var line in lines) {
      if (display[line[0]] != '' &&
          display[line[0]] == display[line[1]] &&
          display[line[0]] == display[line[2]]) {
        return line;
      }
    }
    if (!display.contains('')) return "draw";
    return null;
  }

  void resetGame() {
    timer?.cancel(); // Kill any running timer immediately
    setState(() {
      display = List.filled(9, '');
      result = "no winner";
      winnerMessage = "Turn O";
      oTurn = true;
      winningIndices = null;
      remainingSeconds = 15; // Set it back to 15
      gameStarted = false; // Set to false so it waits for the first tap
      _lineController.reset();
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    _lineController.dispose();
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
                    const SizedBox(height: 40),
                    _buildHeader(),
                    const Spacer(),
                    _buildPlayArea(maxWidth),
                    const Spacer(),
                    _buildStatusArea(),
                    const SizedBox(height: 40),
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
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: result == "no winner"
                  ? (oTurn ? colorO : colorX)
                  : Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlayArea(double width) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: AspectRatio(
        aspectRatio: 1,
        child: Stack(
          children: [
            GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 9,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemBuilder: (context, index) => GestureDetector(
                onTap: () => handleMove(index),
                child: Container(
                  decoration: BoxDecoration(
                    color: gridColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: AnimatedScale(
                      scale: display[index] == '' ? 0.0 : 1.0,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.elasticOut,
                      child: Text(
                        display[index],
                        style: TextStyle(
                          fontSize: width * 0.15,
                          fontWeight: FontWeight.bold,
                          color: display[index] == "X" ? colorX : colorO,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // The Winning Line Painter
            IgnorePointer(
              child: AnimatedBuilder(
                animation: _lineController,
                builder: (context, child) => CustomPaint(
                  size: Size.infinite,
                  painter: WinningLinePainter(
                    winningIndices?.first,
                    winningIndices?.last,
                    _lineController.value,
                    result == "X" ? colorX : colorO,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusArea() {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              height: 60,
              width: 60,
              child: CircularProgressIndicator(
                value: remainingSeconds / 15,
                strokeWidth: 5,
                color: remainingSeconds <= 5 ? Colors.redAccent : colorO,
              ),
            ),
            Text(
              "$remainingSeconds",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 30),
        ElevatedButton(
          onPressed: resetGame,
          style: ElevatedButton.styleFrom(
            backgroundColor: colorX,
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: Text(
            result == "no winner" ? "RESET" : "PLAY AGAIN",
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
}

class WinningLinePainter extends CustomPainter {
  final int? startIdx, endIdx;
  final double progress;
  final Color color;
  WinningLinePainter(this.startIdx, this.endIdx, this.progress, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    if (startIdx == null || endIdx == null) return;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 10.0
      ..strokeCap = StrokeCap.round;

    Offset getOffset(int i) {
      double x = (i % 3) * (size.width / 3) + (size.width / 6);
      double y = (i ~/ 3) * (size.height / 3) + (size.height / 6);
      return Offset(x, y);
    }

    Offset start = getOffset(startIdx!);
    Offset end = getOffset(endIdx!);
    canvas.drawLine(
      start,
      Offset(
        start.dx + (end.dx - start.dx) * progress,
        start.dy + (end.dy - start.dy) * progress,
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(WinningLinePainter old) => old.progress != progress;
}
