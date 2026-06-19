import 'package:flutter/material.dart';
import 'package:square_game/config_file.dart';

import 'color_picker.dart';

class SettingsPage extends StatefulWidget {
  SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  List<Color> gridColors = [];
  List<Color> draggableColors = [];



  ValueNotifier<List<PlayGroundItems?>?> pGrid = ValueNotifier(null);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      bottomNavigationBar: Container(
        height: 100,
        padding: EdgeInsets.all(20),
        child: ElevatedButton(
          onPressed: () {
            GameConfig gameConfig = GameConfig(
              playGround: pGrid.value!,
              gridConfiguration:  gridColors,
              suggestions: draggableColors,
            );
            Navigator.pop(context, gameConfig);
          },
          style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.blue)),
          child: Text("SUBMIT", style: TextStyle(color: Colors.white)),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.black12),
              ),
              child: ListTile(
                onTap: () async {
                  final List<ColorEntry?>? _colors = await showModalBottomSheet(
                    isScrollControlled: true,
                    context: context,
                    builder: (c) {
                      return Padding(padding: const EdgeInsets.only(top: 40.0), child: ColorPickerPage());
                    },
                  );

                  if (_colors != null) {
                    setState(() {
                      gridColors = _colors!.map((c) => c?.color ?? Colors.white).toList();
                    });
                  }
                },
                title: Text("Select grid colors"),
                subtitle: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: gridColors
                        .map(
                          (e) => Container(
                            width: 30,
                            height: 30,
                            margin: EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              color: e,
                              shape: BoxShape.circle,

                              border: Border.all(color: Colors.black12),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
            ),

            Container(
              margin: EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.black12),
              ),
              child: ListTile(
                title: Text("Select Draggable colors"),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: gridColors
                            .map(
                              (e) => InkWell(
                                onTap: () {
                                  if (draggableColors.length < 5) {
                                    setState(() {
                                      draggableColors.add(e);
                                    });
                                  }
                                },

                                child: Container(
                                  width: 30,
                                  height: 30,
                                  margin: EdgeInsets.all(3),
                                  decoration: BoxDecoration(
                                    color: e,
                                    shape: BoxShape.circle,

                                    border: Border.all(color: Colors.black12),
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: presets
                            .map(
                              (e) => InkWell(
                                onTap: () {
                                  setState(() {
                                    draggableColors.add(e);
                                  });
                                },

                                child: Container(
                                  width: 30,
                                  height: 30,
                                  margin: EdgeInsets.all(3),
                                  decoration: BoxDecoration(
                                    color: e,
                                    shape: BoxShape.circle,

                                    border: Border.all(color: Colors.black12),
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 50),

            Text("Draggable Boxes"),
            SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                children: draggableColors
                    .map(
                      (e) => Column(
                        children: [
                          // TextButton(
                          //   onPressed: () {
                          //     setState(() {
                          //       playGround.add(PlayGroundItems(isHint: false, color: e));
                          //     });
                          //   },
                          //   child: Text("Target"),
                          // ),
                          InkWell(
                            onTap: () {
                              setState(() {
                                draggableColors.remove(e);
                              });
                            },
                            child: Container(
                              width: 70,
                              height: 70,
                              margin: EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                color: e,
                                shape: BoxShape.rectangle,

                                border: Border.all(color: Colors.black12),
                              ),
                            ),
                          ),
                          // TextButton(
                          //   onPressed: () {
                          //     setState(() {
                          //       playGround.add(PlayGroundItems(isHint: true, color: e));
                          //     });
                          //   },
                          //   child: Text("Hint"),
                          // ),
                        ],
                      ),
                    )
                    .toList(),
              ),
            ),
            SizedBox(height: 30),
            ListTile(title: Text("Play Ground")),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {

                        pGrid.value = List.generate(2 * 4, (generator) {
                          return null;
                        });
                      },
                      child: Text("2x4 Grid"),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {

                        pGrid.value = List.generate(3 * 4, (generator) {
                          return null;
                        });
                      },
                      child: Text("3x4 Grid"),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
             ValueListenableBuilder(
               valueListenable: pGrid,
               builder: (context,grid,_) {
                 return grid == null ? SizedBox() : Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: GridView.builder(
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, childAspectRatio: 1.1),
                          itemCount: grid.length,
                          shrinkWrap: true,
                          itemBuilder: (c, index) {
                            return InkWell(
                              onTap: () async {
                                PlayGroundItems? pItem = await showModalBottomSheet(
                                  context: context,
                                  builder: (c) {
                                    return Container(
                                      padding: EdgeInsets.all(10),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                            child: Row(
                                              children: draggableColors
                                                  .map(
                                                    (e) => Column(
                                                      children: [
                                                        TextButton(
                                                          onPressed: () {
                                                            Navigator.pop(context, PlayGroundItems(colorHint: null, targetColor: e, id: DateTime.now().millisecondsSinceEpoch.toString()));
                                                          },
                                                          child: Text("Target"),
                                                        ),

                                                        InkWell(
                                                          // onTap: () {
                                                          //   setState(() {
                                                          //     draggableColors.remove(e);
                                                          //   });
                                                          // },
                                                          child: Container(
                                                            width: 70,
                                                            height: 70,
                                                            margin: EdgeInsets.all(3),
                                                            decoration: BoxDecoration(
                                                              color: e,
                                                              shape: BoxShape.rectangle,

                                                              border: Border.all(color: Colors.black12),
                                                            ),
                                                          ),
                                                        ),
                                                        TextButton(
                                                          onPressed: () {
                                                            Navigator.pop(context, PlayGroundItems(colorHint: e, id: DateTime.now().millisecondsSinceEpoch.toString()));
                                                          },
                                                          child: Text("Hint"),
                                                        ),
                                                      ],
                                                    ),
                                                  )
                                                  .toList(),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                );
                                if (pItem != null) {
                                  List<PlayGroundItems?> copy = pGrid.value!;
                                  copy[index] = pItem;

                                    pGrid.value = [...copy];
                                    print("${copy[index]}");

                                }
                              },
                              child: Container(
                                margin: EdgeInsets.all(5),
                                height: 30,
                                width: 30,

                                decoration: BoxDecoration(border: Border.all(color: Colors.black),color: grid[index]?.colorHint??grid[index]?.targetColor),
                                child: Center(
                                  child: grid[index] == null ? SizedBox() : Text(grid[index]!.colorHint != null ? "H" : "T", style: TextStyle(color: Colors.white)),
                                ),
                              ),
                            );
                          },
                        ),
                      );
               }
             ),

            // Padding(
            //   padding: const EdgeInsets.symmetric(horizontal: 15.0),
            //   child: Row(
            //     children: playGround.map((e){
            //       return Container(
            //         width: 80,
            //         height: 80,
            //         color: e.color,
            //         child: Center(child: Container(
            //             padding: EdgeInsets.all(7),
            //             decoration: BoxDecoration(
            //               shape: BoxShape.circle,
            //               color: Colors.black12,
            //             ),
            //             child: Text(e.isHint?"H":"T",style: TextStyle(color: Colors.white),))),
            //       );
            //     }).toList(),
            //   ),
            // )
          ],
        ),
      ),
    );
  }
}
