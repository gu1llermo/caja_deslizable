import 'package:flutter/material.dart';

class DraggableBoxesV5 extends StatefulWidget {
  const DraggableBoxesV5({super.key});

  @override
  State<DraggableBoxesV5> createState() => _DraggableBoxesV5State();
}

class _DraggableBoxesV5State extends State<DraggableBoxesV5>
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

  bool _checkCircleCollision(Offset pos1, Offset pos2) {
    final distance = (pos1 - pos2).distance;
    return distance < circleRadius * 2;
  }

  void _resolveCircleCollision(int movingIndex, int staticIndex) {
    final movingCenter = positions[movingIndex];
    final staticCenter = positions[staticIndex];

    // Vector desde el centro del círculo estático al círculo en movimiento
    final collisionVector = movingCenter - staticCenter;

    // Distancia actual entre los centros
    final distance = collisionVector.distance;

    if (distance < circleRadius * 2) {
      // Normalizar el vector de colisión
      final normalizedVector = collisionVector / distance;

      // Calcular cuánto necesitamos mover el círculo para evitar la superposición
      final overlap = (circleRadius * 2) - distance;

      // Mover el círculo en movimiento fuera de la colisión
      positions[movingIndex] =
          staticCenter + normalizedVector * (circleRadius * 2);
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

    // Aplicar límites de pantalla considerando el radio del círculo
    newX = newX.clamp(circleRadius, screenSize.width - circleRadius);
    newY = newY.clamp(
        circleRadius, screenSize.height - bottomPadding - circleRadius);

    // Posición propuesta
    final newPosition = Offset(newX, newY);

    setState(() {
      positions[movingCircleIndex] = newPosition;

      // Verificar colisión con el otro círculo
      if (_checkCircleCollision(newPosition, positions[otherCircleIndex])) {
        _resolveCircleCollision(movingCircleIndex, otherCircleIndex);
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
              left: positions[index].dx -
                  circleRadius, // Centrar el círculo en la posición
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
