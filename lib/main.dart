import 'package:flutter/material.dart';
import 'dart:async';

void main() {
  runApp(const Game());
}

Timer? timer;
int remainingSeconds = 15; // Start at 30
bool oTurn = false;

List<String> display = List.filled(9, '');
String winner = "The game is not done yet";
String result = "no winner";
String checkwinner() {
  List<List<int>> winConditions = [
    [0, 1, 2],
    [3, 4, 5],
    [6, 7, 8],
    [0, 3, 6],
    [1, 4, 7],
    [2, 5, 8],
    [0, 4, 8],
    [2, 4, 6],
  ];
  for (var condition in winConditions) {
    if (display[condition[0]] != '' &&
        display[condition[0]] == display[condition[1]] &&
        display[condition[0]] == display[condition[2]]) {
      print('${display[condition[0]]} is the winner of the game');

      return display[condition[0]];
    }
    if (!display.contains('')) {
      return "draw";
    }
  }
  return "no winner";
}

bool firstmove = display.every((ele) => ele == '');

class Game extends StatefulWidget {
  const Game({super.key});
  @override
  State<Game> createState() => _GameState();
}

class _GameState extends State<Game> {
  bool oTurn = false;
  void startMoveTimer() {
    timer?.cancel(); // Cancel any existing timer before starting a new one
    setState(() => remainingSeconds = 15);

    timer = Timer.periodic(Duration(seconds: 1), (t) {
      setState(() {
        if (remainingSeconds > 0) {
          remainingSeconds--;
        } else {
          // TIME EXCEEDED: Switch turns automatically
          oTurn = !oTurn;
          startMoveTimer(); // Restart clock for the next player
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text("tictactoe"),
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
        ),
        body: Padding(
          padding: EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Turn ${oTurn ? "O" : "X"}",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Expanded(
                flex: 3,
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                  ),
                  itemCount: 9,
                  itemBuilder: (BuildContext context, int index) {
                    return ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        side: const BorderSide(color: Colors.black, width: 1.0),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                        ),
                      ),
                      onPressed: (display[index] == '' && result == "no winner")
                          ? () {
                              setState(() {
                                // 1. Place the move
                                display[index] = oTurn ? "O" : "X";
                                oTurn = !oTurn;
                                // 2. Check for winner
                                result = checkwinner();
                                // 3. Handle Timer and Messages
                                if (result == "X" || result == "O") {
                                  winner = "The Winner is $result!";
                                  timer?.cancel(); // Game over, stop timer
                                } else if (result == "draw") {
                                  winner = "It's a Draw!";
                                  timer?.cancel(); // Game over, stop timer
                                } else {
                                  winner = "The game is not done yet";
                                  // RESET TIMER HERE: Calling this again restarts it at 30s
                                  startMoveTimer();
                                }
                              });
                            }
                          : null,

                      child: Text(
                        display[index],
                        style: TextStyle(
                          fontSize: 80,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  },
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    // 1. Stop the current timer completely
                    timer?.cancel();
                    // 2. Clear the board and reset state
                    display = List.filled(9, '');
                    result = "no winner";
                    winner = "The game is not done yet";
                    oTurn = true;
                    remainingSeconds = 15; // Reset visual clock to default
                    // 3. Reset your 'firstmove' flag
                    firstmove = true;
                  });
                },
                child: Text(result == "no winner" ? "Reset Game" : "New Game"),
              ),

              Expanded(
                flex: 2,
                child: Text(
                  winner,
                  style: TextStyle(fontSize: 40),
                  textAlign: TextAlign.center,
                ),
              ),
              Text(
                "Time left: $remainingSeconds",
                style: TextStyle(
                  fontSize: 20,
                  color: remainingSeconds <= 5
                      ? Colors.red
                      : Colors.black, // Turn red at 5s
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
