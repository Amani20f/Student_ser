import 'package:flutter/material.dart';

class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;

  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: cs.surface.withAlpha(180),
            child: Center(child: CircularProgressIndicator(color: cs.primary)),
          ),
      ],
    );
  }
}
