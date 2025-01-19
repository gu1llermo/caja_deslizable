import 'dart:math';

import 'package:flutter/material.dart';

class DraggableBoxesV6 extends StatefulWidget {
  const DraggableBoxesV6({super.key});

  @override
  State<DraggableBoxesV6> createState() => _DraggableBoxesV6State();
}

class _DraggableBoxesV6State extends State<DraggableBoxesV6>
    with SingleTickerProviderStateMixin {
  static const double circleRadius = 50.0;

  List<Offset> positions = [
    Offset(100, 100),
    Offset(250, 100),
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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double _getBottomPadding(BuildContext context) {
    return MediaQuery.of(context).padding.vertical;
  }

  bool _checkCollision(Offset pos1, Offset pos2) {
    final dx = pos1.dx - pos2.dx;
    final dy = pos1.dy - pos2.dy;
    final distance = (dx * dx + dy * dy);
    return distance < (circleRadius * 2) * (circleRadius * 2);
  }

  Offset _getConstrainedPosition(
      Offset position, Size screenSize, double bottomPadding) {
    return Offset(
        position.dx.clamp(circleRadius, screenSize.width - circleRadius),
        position.dy.clamp(
            circleRadius, screenSize.height - bottomPadding - circleRadius));
  }

  void _handleCollision(
      int movingIndex, int staticIndex, DragUpdateDetails details) {
    final screenSize = MediaQuery.of(context).size;
    final bottomPadding = _getBottomPadding(context);

    // Calcular el vector de dirección entre los círculos
    final dx = positions[staticIndex].dx - positions[movingIndex].dx;
    final dy = positions[staticIndex].dy - positions[movingIndex].dy;
    final distance = sqrt(dx * dx + dy * dy);

    if (distance < circleRadius * 2) {
      // Calcular la dirección normalizada
      final dirX = dx / distance;
      final dirY = dy / distance;

      // Calcular las nuevas posiciones manteniendo la distancia mínima
      final minDistance = circleRadius * 2;
      final correction = (minDistance - distance) / 2;

      // Mover ambos círculos en direcciones opuestas
      final moveX = dirX * correction;
      final moveY = dirY * correction;

      // Aplicar el movimiento con restricciones de pantalla
      var newMovingPos = Offset(
          positions[movingIndex].dx - moveX, positions[movingIndex].dy - moveY);

      var newStaticPos = Offset(
          positions[staticIndex].dx + moveX, positions[staticIndex].dy + moveY);

      // Aplicar restricciones de pantalla a ambas posiciones
      newMovingPos =
          _getConstrainedPosition(newMovingPos, screenSize, bottomPadding);
      newStaticPos =
          _getConstrainedPosition(newStaticPos, screenSize, bottomPadding);

      setState(() {
        positions[movingIndex] = newMovingPos;
        positions[staticIndex] = newStaticPos;
      });
    }
  }

  void _updatePosition(
      int movingCircleIndex, DragUpdateDetails details, BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);
    final bottomPadding = _getBottomPadding(context);
    final otherCircleIndex = 1 - movingCircleIndex;

    // Calcular nueva posición propuesta
    double newX = positions[movingCircleIndex].dx + details.delta.dx;
    double newY = positions[movingCircleIndex].dy + details.delta.dy;

    // Aplicar límites de pantalla
    newX = newX.clamp(circleRadius, screenSize.width - circleRadius);
    newY = newY.clamp(
        circleRadius, screenSize.height - bottomPadding - circleRadius);

    setState(() {
      // Mover el círculo activo
      positions[movingCircleIndex] = Offset(newX, newY);

      // Verificar y manejar colisión
      if (_checkCollision(
          positions[movingCircleIndex], positions[otherCircleIndex])) {
        _handleCollision(movingCircleIndex, otherCircleIndex, details);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: List.generate(2, (index) {
            return Positioned(
              left: positions[index].dx - circleRadius,
              top: positions[index].dy - circleRadius,
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
                    return _CircleWidget(
                      index: index,
                      isPressed: isPressed,
                      colorAnimation: _colorAnimation,
                      shadowAnimation: _shadowAnimation,
                      radius: circleRadius,
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

class _CircleWidget extends StatelessWidget {
  const _CircleWidget({
    required this.isPressed,
    required this.colorAnimation,
    required this.shadowAnimation,
    required this.index,
    required this.radius,
  });

  final List<bool> isPressed;
  final Animation<Color?> colorAnimation;
  final Animation<double> shadowAnimation;
  final int index;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        color: isPressed[index] ? colorAnimation.value : Colors.blue,
        shape: BoxShape.circle,
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
          '${index + 1}',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
