import 'package:flutter/material.dart';

class DraggableBoxesV3 extends StatefulWidget {
  const DraggableBoxesV3({super.key});

  @override
  State<DraggableBoxesV3> createState() => _DraggableBoxesV3State();
}

class _DraggableBoxesV3State extends State<DraggableBoxesV3>
    with SingleTickerProviderStateMixin {
  List<Offset> positions = [
    Offset(0, 0),
    Offset(150, 0),
  ];

  List<bool> isPressed = [false, false];

  // Controladores y animaciones
  late AnimationController _controller;
  // late Animation<double> _scaleAnimation;
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
    final padding = MediaQuery.of(context).padding.vertical;
    //final viewPadding = MediaQuery.of(context).viewPadding;
    // Obtenemos el alto total de la pantalla
    //final screenHeight = MediaQuery.sizeOf(context).height;

    // Usamos kBottomNavigationBarHeight como base y añadimos un poco más de espacio
    // para asegurarnos de que las cajas sean completamente visibles
    return padding;
    // return kBottomNavigationBarHeight + 16.0;

    // Alternativa: usar un porcentaje de la altura de la pantalla
    // return screenHeight * 0.1; // 10% de la altura de la pantalla
  }

  void _updatePosition(
      int index, DragUpdateDetails details, BuildContext context) {
    setState(() {
      final screenSize = MediaQuery.sizeOf(context);
      final boxSize = 100.0;
      final bottomPadding = _getBottomPadding(context);

      double newX = positions[index].dx + details.delta.dx;
      double newY = positions[index].dy + details.delta.dy;

      newX = newX.clamp(0, screenSize.width - boxSize);
      newY = newY.clamp(0, screenSize.height - bottomPadding - boxSize);

      positions[index] = Offset(newX, newY);
    });
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
