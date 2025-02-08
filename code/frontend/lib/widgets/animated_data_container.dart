import 'package:flutter/material.dart';

class AnimatedDataContainer extends StatelessWidget {
  final Widget child;
  final bool isVisible;

  const AnimatedDataContainer({
    Key? key,
    required this.child,
    required this.isVisible,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: isVisible ? 1.0 : 0.0,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 300),
        scale: isVisible ? 1.0 : 0.8,
        child: child,
      ),
    );
  }
}
