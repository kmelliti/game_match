import 'package:flutter/material.dart';

import 'config_file.dart';

class SourceGrid extends StatelessWidget {
  const SourceGrid({super.key, required this.grid, required this.countAxis});

 final  List<Color?> grid;
 final int countAxis;
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: grid.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: countAxis), itemBuilder: (c,index){

          return Container(
            color: grid[index]??Colors.white,
          );

    });
  }
}
