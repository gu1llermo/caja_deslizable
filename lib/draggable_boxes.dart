import 'package:flutter/material.dart';

class DraggableBoxes extends StatefulWidget {
  const DraggableBoxes({super.key});

  @override
  State<DraggableBoxes> createState() => _DraggableBoxesState();
}

class _DraggableBoxesState extends State<DraggableBoxes> {
  // Posiciones para ambas cajas
  List<Offset> positions = [
    Offset(0, 0),
    Offset(150, 0),
  ];

  List<bool> isPressed = [false, false];

  void _updatePosition(
      int index, DragUpdateDetails details, BuildContext context) {
    setState(() {
      // Obtener el tamaño de la pantalla
      final screenSize = MediaQuery.sizeOf(context);
      final boxSize = 100.0;

      // Calcular nueva posición
      double newX = positions[index].dx + details.delta.dx;
      double newY = positions[index].dy + details.delta.dy;

      // Aplicar límites
      newX = newX.clamp(0, screenSize.width - boxSize);
      newY = newY.clamp(0, screenSize.height - boxSize);

      positions[index] = Offset(newX, newY);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: List.generate(2, (index) {
          return Positioned(
            left: positions[index].dx,
            top: positions[index].dy,
            child: GestureDetector(
              onPanStart: (_) {
                setState(() {
                  isPressed[index] = true;
                });
              },
              onPanEnd: (_) {
                setState(() {
                  isPressed[index] = false;
                });
              },
              onPanUpdate: (details) =>
                  _updatePosition(index, details, context),
              child: AnimatedContainer(
                duration: Duration(milliseconds: 150),
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: isPressed[index] ? Colors.blue.shade700 : Colors.blue,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(51),
                      blurRadius: isPressed[index] ? 8 : 4,
                      spreadRadius: isPressed[index] ? 2 : 1,
                      offset: Offset(0, isPressed[index] ? 2 : 4),
                    ),
                  ],
                ),
                transform: Matrix4.identity()
                  ..scale(isPressed[index] ? 1.1 : 1.0),
              ),
            ),
          );
        }),
      ),
    );
  }
}
