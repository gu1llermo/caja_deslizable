import 'package:flutter/material.dart';

import 'draggable_box.dart';
import 'draggable_boxes.dart';
import 'draggable_boxes_v2.dart';
import 'draggable_boxes_v3.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DraggableBoxesV3(),
    );
  }
}
