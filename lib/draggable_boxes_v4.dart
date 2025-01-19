import 'package:flutter/material.dart';

class DraggableBoxesV4 extends StatefulWidget {
  const DraggableBoxesV4({super.key});

  @override
  State<DraggableBoxesV4> createState() => _DraggableBoxesV4State();
}

class _DraggableBoxesV4State extends State<DraggableBoxesV4>
    with SingleTickerProviderStateMixin {
  static const double boxSize = 100.0;

  List<Offset> positions = [
    Offset(0, 0),
    Offset(150, 0),
  ];

  List<bool> isPressed = [false, false];

  late AnimationController _controller;
  late Animation<double> _shadowAnimation;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _controller.addListener(listener);

    _shadowAnimation = Tween<double>(
      begin: 4.0,
      end: 8.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _colorAnimation = ColorTween(
      begin: Colors.blue,
      end: Colors.blue.shade700,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));
  }

  void listener() {
    debugPrint(_controller.status.toString());
  }

  @override
  void dispose() {
    _controller.removeListener(listener);
    _controller.dispose();
    super.dispose();
  }

  double _getBottomPadding(BuildContext context) {
    return MediaQuery.of(context).padding.vertical;
  }

  bool _checkCollision(Offset pos1, Offset pos2) {
    return (pos1.dx < pos2.dx + boxSize &&
        pos1.dx + boxSize > pos2.dx &&
        pos1.dy < pos2.dy + boxSize &&
        pos1.dy + boxSize > pos2.dy);
  }

  void _updatePosition(
      int movingBoxIndex, DragUpdateDetails details, BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);
    final bottomPadding = _getBottomPadding(context);

    // Calcular la nueva posición propuesta para la caja que se está moviendo
    double newX = positions[movingBoxIndex].dx + details.delta.dx;
    double newY = positions[movingBoxIndex].dy + details.delta.dy;

    // Aplicar límites de pantalla
    newX = newX.clamp(0, screenSize.width - boxSize);
    newY = newY.clamp(0, screenSize.height - bottomPadding - boxSize);

    // Crear una posición temporal para verificar colisiones
    Offset newPosition = Offset(newX, newY);

    // Verificar colisión con la otra caja
    int otherBoxIndex = 1 - movingBoxIndex; // Alterna entre 0 y 1
    if (_checkCollision(newPosition, positions[otherBoxIndex])) {
      // Calcular la dirección del empuje
      double pushDx = details.delta.dx;
      double pushDy = details.delta.dy;

      // Calcular nueva posición para la otra caja
      double otherNewX = positions[otherBoxIndex].dx + pushDx;
      double otherNewY = positions[otherBoxIndex].dy + pushDy;

      // Aplicar límites de pantalla a la otra caja
      otherNewX = otherNewX.clamp(0, screenSize.width - boxSize);
      otherNewY =
          otherNewY.clamp(0, screenSize.height - bottomPadding - boxSize);

      // Si la otra caja puede moverse, actualizar ambas posiciones
      if (otherNewX != positions[otherBoxIndex].dx ||
          otherNewY != positions[otherBoxIndex].dy) {
        setState(() {
          positions[otherBoxIndex] = Offset(otherNewX, otherNewY);
          // Ajustar la posición de la caja en movimiento para mantener el contacto
          positions[movingBoxIndex] = newPosition;
        });
      } else {
        // Si la otra caja no puede moverse (está contra un borde),
        // ajustar la posición de la caja en movimiento
        setState(() {
          if (details.delta.dx != 0) {
            newX = details.delta.dx > 0
                ? positions[otherBoxIndex].dx - boxSize
                : positions[otherBoxIndex].dx + boxSize;
          }
          if (details.delta.dy != 0) {
            newY = details.delta.dy > 0
                ? positions[otherBoxIndex].dy - boxSize
                : positions[otherBoxIndex].dy + boxSize;
          }
          positions[movingBoxIndex] = Offset(newX, newY);
        });
      }
    } else {
      // Si no hay colisión, actualizar normalmente
      setState(() {
        positions[movingBoxIndex] = newPosition;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: List.generate(2, (index) {
            return Positioned(
              left: positions[index].dx,
              top: positions[index].dy,
              child: GestureDetector(
                onPanStart: (_) {
                  setState(() {
                    isPressed[index] = true;
                  });
                  _controller.forward();
                },
                onPanEnd: (_) {
                  setState(() {
                    isPressed[index] = false;
                  });
                  _controller.reverse();
                },
                onPanUpdate: (details) =>
                    _updatePosition(index, details, context),
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return _BoxWidget(
                      index: index,
                      isPressed: isPressed,
                      colorAnimation: _colorAnimation,
                      shadowAnimation: _shadowAnimation,
                    );
                  },
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _BoxWidget extends StatelessWidget {
  const _BoxWidget({
    required this.isPressed,
    required this.colorAnimation,
    required this.shadowAnimation,
    required this.index,
  });

  final List<bool> isPressed;
  final Animation<Color?> colorAnimation;
  final Animation<double> shadowAnimation;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: isPressed[index] ? colorAnimation.value : Colors.blue,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(51),
            blurRadius: isPressed[index] ? shadowAnimation.value : 4.0,
            spreadRadius: isPressed[index] ? 2 : 1,
            offset: Offset(0, isPressed[index] ? 2 : 4),
          ),
        ],
      ),
      child: Center(
        child: Text(
          'Box ${index + 1}',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
