import 'package:flutter/material.dart';

/// Hareket süreleri; kısa ve sakin.
abstract final class Motion {
  static const short = Duration(milliseconds: 160);
  static const medium = Duration(milliseconds: 320);
  static const long = Duration(milliseconds: 600);

  /// Sırayla belirmede iki öğe arası gecikme ve en fazla gecikmeli öğe.
  static const stagger = Duration(milliseconds: 50);
  static const maxStaggered = 6;

  static const curve = Curves.easeOutCubic;

  /// Cihazda "hareketi azalt" açıksa `true`.
  static bool reduced(BuildContext context) =>
      MediaQuery.maybeDisableAnimationsOf(context) ?? false;
}

/// Çocuğunu ilk çizildiğinde aşağıdan hafifçe kayarak ve belirerek
/// gösterir. [index] sırayla belirmede gecikmeyi belirler.
class Reveal extends StatefulWidget {
  const Reveal({super.key, required this.child, this.index = 0});

  final Widget child;
  final int index;

  @override
  State<Reveal> createState() => _RevealState();
}

class _RevealState extends State<Reveal> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _progress;

  @override
  void initState() {
    super.initState();
    final delay = Motion.stagger * widget.index.clamp(0, Motion.maxStaggered);
    final total = delay + Motion.medium;
    _controller = AnimationController(vsync: this, duration: total);
    _progress = CurvedAnimation(
      parent: _controller,
      curve: Interval(
        delay.inMicroseconds / total.inMicroseconds,
        1,
        curve: Motion.curve,
      ),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (Motion.reduced(context)) return widget.child;
    return AnimatedBuilder(
      animation: _progress,
      child: widget.child,
      builder: (context, child) => Opacity(
        opacity: _progress.value,
        child: Transform.translate(
          offset: Offset(0, 8 * (1 - _progress.value)),
          child: child,
        ),
      ),
    );
  }
}
