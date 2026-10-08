import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// أنيميشن تبديل الثيم: بياخد صورة للشاشة قبل التبديل،
/// وبعدين الثيم الجديد بينكشف بدائرة عم تكبر من أعلى الشاشة.
class ThemeSwitchOverlay extends StatefulWidget {
  final Widget child;

  const ThemeSwitchOverlay({super.key, required this.child});

  static final GlobalKey _boundaryKey = GlobalKey();
  static _ThemeSwitchOverlayState? _state;

  /// بينادى قبل ما يتغيّر الثيم مباشرة.
  static void capture() => _state?._capture();

  @override
  State<ThemeSwitchOverlay> createState() => _ThemeSwitchOverlayState();
}

class _ThemeSwitchOverlayState extends State<ThemeSwitchOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 650),
  );
  late final Animation<double> _progress = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeInOutCubic,
  );

  ui.Image? _oldFrame;

  @override
  void initState() {
    super.initState();
    ThemeSwitchOverlay._state = this;
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) _clear();
    });
  }

  void _capture() {
    try {
      final boundary = ThemeSwitchOverlay._boundaryKey.currentContext
          ?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null || !boundary.hasSize) return;

      final ratio = MediaQuery.maybeDevicePixelRatioOf(context) ?? 1.0;
      final image = boundary.toImageSync(pixelRatio: ratio);

      _oldFrame?.dispose();
      setState(() => _oldFrame = image);
      _controller.forward(from: 0);
    } catch (_) {
      // إذا فشل التصوير بيتبدّل الثيم بدون أنيميشن
      _clear();
    }
  }

  void _clear() {
    if (!mounted) return;
    final img = _oldFrame;
    setState(() => _oldFrame = null);
    img?.dispose();
  }

  @override
  void dispose() {
    if (ThemeSwitchOverlay._state == this) ThemeSwitchOverlay._state = null;
    _controller.dispose();
    _oldFrame?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final oldFrame = _oldFrame;

    return Stack(
      textDirection: TextDirection.ltr,
      fit: StackFit.expand,
      children: [
        RepaintBoundary(
          key: ThemeSwitchOverlay._boundaryKey,
          child: widget.child,
        ),
        if (oldFrame != null)
          IgnorePointer(
            child: AnimatedBuilder(
              animation: _progress,
              builder: (context, _) => ClipPath(
                clipper: _RevealClipper(_progress.value),
                child: RawImage(image: oldFrame, fit: BoxFit.fill),
              ),
            ),
          ),
      ],
    );
  }
}

/// بيقص الصورة القديمة كلها ما عدا دائرة عم تكبر،
/// فالثيم الجديد بيبين من جوّا الدائرة.
class _RevealClipper extends CustomClipper<Path> {
  final double progress;

  _RevealClipper(this.progress);

  @override
  Path getClip(Size size) {
    final center = Offset(size.width / 2, size.height * 0.12);
    final maxRadius = math.sqrt(
      math.pow(size.width, 2) + math.pow(size.height, 2),
    );
    return Path()
      ..fillType = PathFillType.evenOdd
      ..addRect(Offset.zero & size)
      ..addOval(Rect.fromCircle(center: center, radius: maxRadius * progress));
  }

  @override
  bool shouldReclip(_RevealClipper old) => old.progress != progress;
}
