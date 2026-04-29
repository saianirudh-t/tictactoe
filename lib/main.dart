import 'package:flutter/material.dart';

void main() {
  runApp(const Game());
}

List<String> display = ['', '', '', '', '', '', '', '', ""];
String winner = "The game is not done yet";
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
  }
  return "no winner";
}

class Game extends StatefulWidget {
  const Game({super.key});
  @override
  State<Game> createState() => _GameState();
}

class _GameState extends State<Game> {
  bool oTurn = true;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
              Expanded(
                flex: 2,
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
                      onPressed: display[index] == ''
                          ? () {
                              print(display);
                              setState(() {
                                display[index] = oTurn ? "O" : "X";
                                oTurn = !oTurn;
                              });
                              String result = checkwinner();
                              if (result != "no winner" && result != "") {
                                setState(() {
                                  display = [
                                    '',
                                    '',
                                    '',
                                    '',
                                    '',
                                    '',
                                    '',
                                    '',
                                    "",
                                  ];
                                  winner = "The winner of the game is $result";
                                });
                              }
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
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                  ),
                  child: Text(
                    winner,
                    style: TextStyle(fontSize: 40),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
