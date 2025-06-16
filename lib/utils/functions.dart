import 'package:flutter/material.dart';

void showTopSnackBar(BuildContext context,
    {required String message,
    Color color = Colors.black,
    Color fontColor = Colors.white}) {
  final overlay = Overlay.of(context);
  late OverlayEntry overlayEntry;
  final animationController = AnimationController(
    vsync: Navigator.of(context),
    duration: Duration(milliseconds: 200),
  );
  final animation =
      Tween<double>(begin: -50, end: 50).animate(animationController);

  overlayEntry = OverlayEntry(
    builder: (context) => AnimatedBuilder(
      animation: animation,
      builder: (context, child) => Positioned(
        top: animation.value,
        left: 20,
        right: 20,
        child: Material(
          elevation: 5.0,
          borderRadius: BorderRadius.circular(10),
          color: color,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
            child: Text(
              message,
              style: TextStyle(color: fontColor, fontSize: 16),
            ),
          ),
        ),
      ),
    ),
  );

  overlay.insert(overlayEntry);

  // Iniciar la animación
  animationController.forward();

  // Remover el SnackBar después de unos segundos
  Future.delayed(Duration(seconds: 2), () {
    animationController.reverse().then((_) {
      overlayEntry.remove();
      animationController.dispose();
    });
  });
}
