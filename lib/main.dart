import 'package:flutter/material.dart';

import 'draggable_boxes_v6.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DraggableBoxesV6(),
    );
  }
}
