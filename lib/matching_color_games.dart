import 'dart:async';

import 'package:flutter/material.dart';
import 'package:square_game/source_grid.dart';

import 'color_picker.dart';
import 'config_file.dart';
import 'config_page.dart';

class ColorMatchGame extends StatefulWidget {
  const ColorMatchGame({super.key});

  @override
  State<ColorMatchGame> createState() => _ColorMatchGameState();
}

class _ColorMatchGameState extends State<ColorMatchGame> {
  Map<String, Color> droppedColors = {};
  GameConfig? gameConfig;

  late Timer _timer;
  String timerText = '00:00';
  int _seconds = 0;

  @override
  void initState() {
    super.initState(); // ✅ always call super first
    startTimer();
  }

  void startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _seconds++;
        final minutes = _seconds ~/ 60;
        final seconds = _seconds % 60;
        timerText = '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _checkAnswers() {
    final targets = gameConfig!.playGround.where((e) => e != null && e.colorHint == null);

    bool allCorrect = targets.every((e) => e != null && droppedColors[e.id] == e.targetColor);

    _timer.cancel();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(allCorrect ? '🎉 Correct! Time: $timerText' : '❌ Some answers are incorrect'),
        actions: [
          TextButton(
            onPressed: () {
              droppedColors.clear();
              Navigator.pop(context);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () async {
              GameConfig? g = await Navigator.of(context).push(MaterialPageRoute(builder: (c) => SettingsPage()));

              if (g != null) {
                timerText = '00:00';
                _seconds = 0;
                startTimer();
                setState(() {
                  gameConfig = g;
                });
              }
            },
            icon: Icon(Icons.settings),
          ),
        ],
      ),
      bottomNavigationBar: gameConfig == null
          ? Container()
          : Container(
              height: 90,
              padding: EdgeInsets.all(20),
              child: ElevatedButton(onPressed: (){
                print("Game config ${gameConfig!.toJson()}");
              }, child: Text('Check Answers')),
            ),
      body: gameConfig == null
          ? Center()
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(timerText),

                  // Grid Sample game
                  Container(
                    padding: EdgeInsets.all(20),
                    child: Center(child: SourceGrid(grid: gameConfig!.gridConfiguration, countAxis: 4)),
                  ),

                  Column(
                    children: [
                      // Where user puts his answers
                      playGround(),
                      SizedBox(height: 10),
                      Divider(),
                      SizedBox(height: 10),


                      //Suggestions
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Container(
                          color: Colors.grey[200],
                          padding: const EdgeInsets.symmetric(vertical: 10.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: gameConfig!.suggestions
                                .map((e) => Draggable<Color>(data: e, feedback: _colorBox(e), childWhenDragging: _emptyBox(), child: _colorBox(e)))
                                .toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  Widget playGround() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: GridView.builder(
        itemCount: gameConfig!.playGround.length,
        shrinkWrap: true,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4),
        itemBuilder: (c, index) {
          final e = gameConfig!.playGround[index];
          if (e == null) {
            return Container(width: 40, height: 40, decoration: BoxDecoration());
          }




          if (e.colorHint != null) {
            return Container(width: 40, height: 40, color: e.colorHint);




          } else {
            return DragTarget<Color>(
              onWillAcceptWithDetails: (details) {
                // return details.data == e.color; // correct match check
                print("onWillAcceptWithDetails");

                return true;

              },
              onAcceptWithDetails: (details) {
                setState(() {
                  droppedColors[e.id] = details.data;
                });

                int i = gameConfig!.playGround.where((e) => e != null && e.targetColor !=null).length;
               if(droppedColors.keys.length == i){
                 _checkAnswers();
               }

              },
              builder: (context, candidateData, rejectedData) {
                final dropped = droppedColors[e.id];
                final isHovering = candidateData.isNotEmpty;
                final isRejected = rejectedData.isNotEmpty;

                return Container(
                  width: 40,
                  height: 40,

                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey, width: isHovering || isRejected ? 2.5 : 1),
                    color: dropped == e.colorHint ? e.colorHint : Colors.grey.shade200,
                  ),
                  child: dropped == null ? Container(width: 40, height: 40) : Container(width: 40, height: 40, color: dropped),
                );
              },
            );
          }
        },
      ),
    );
  }

  Widget _colorBox(Color color) {
    return Container(width: 80, height: 80, color: color);
  }

  Widget _emptyBox() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
    );
  }
}
