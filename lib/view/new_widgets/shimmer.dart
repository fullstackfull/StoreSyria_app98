import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:store_go_app/utils/colors.dart';

class ShimmerColors {
  final Color base;
  final Color highlight;
  final Color card;

  const ShimmerColors({
    required this.base,
    required this.highlight,
    required this.card,
  });

  static ShimmerColors of(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark
        ? ShimmerColors(
      base: const Color(0xFF262B36),
      highlight: const Color(0xFF363C4B),
      card: DarkThemeColor.cCardBackground,
    )
        : const ShimmerColors(
      base: Color(0xFFE2E8F0),
      highlight: Color(0xFFF6F8FB),
      card: Colors.white,
    );
  }
}

// ============================================================
// ROOT
// ============================================================

class AppShimmer extends StatefulWidget {
  final Widget child;

  /// لو false بيرجع العظام ثابتة بدون حركة
  final bool enabled;
  final Duration period;
  final Color? baseColor;
  final Color? highlightColor;

  const AppShimmer({
    super.key,
    required this.child,
    this.enabled = true,
    this.period = const Duration(milliseconds: 1400),
    this.baseColor,
    this.highlightColor,
  });

  static AppShimmerState? maybeOf(BuildContext context) {
    return context.findAncestorStateOfType<AppShimmerState>();
  }

  @override
  State<AppShimmer> createState() => AppShimmerState();
}

class AppShimmerState extends State<AppShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  Listenable get animation => _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController.unbounded(vsync: this);
    if (widget.enabled) _start();
  }

  void _start() {
    _controller.repeat(min: -0.5, max: 1.5, period: widget.period);
  }

  @override
  void didUpdateWidget(covariant AppShimmer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.enabled && !_controller.isAnimating) {
      _start();
    } else if (!widget.enabled && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get enabled => widget.enabled;

  Color baseColor(BuildContext context) =>
      widget.baseColor ?? ShimmerColors.of(context).base;

  Color highlightColor(BuildContext context) =>
      widget.highlightColor ?? ShimmerColors.of(context).highlight;

  Size? get size {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return null;
    return box.size;
  }

  Offset descendantOffset(RenderBox descendant) {
    final root = context.findRenderObject() as RenderBox;
    return descendant.localToGlobal(Offset.zero, ancestor: root);
  }

  LinearGradient gradient(BuildContext context) {
    final base = baseColor(context);
    final highlight = highlightColor(context);
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    // باللغة العربية اللمعة بتمشي من اليمين لليسار
    final percent = isRtl ? 1.0 - _controller.value : _controller.value;
    return LinearGradient(
      begin: const Alignment(-1.0, -0.3),
      end: const Alignment(1.0, 0.3),
      colors: [base, highlight, base],
      stops: const [0.1, 0.3, 0.4],
      transform: _SlidingGradientTransform(percent),
    );
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class _SlidingGradientTransform extends GradientTransform {
  final double percent;

  const _SlidingGradientTransform(this.percent);

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * percent, 0.0, 0.0);
  }
}

// ============================================================
// BONES
// ============================================================

/// المربع الأساسي. أي عظمة تانية مبنية عليه.
class ShimmerBox extends StatelessWidget {
  final double? width;
  final double? height;
  final double? radius;
  final BoxShape shape;

  const ShimmerBox({
    super.key,
    this.width,
    this.height,
    this.radius,
    this.shape = BoxShape.rectangle,
  });

  @override
  Widget build(BuildContext context) {
    final shimmer = AppShimmer.maybeOf(context);
    final base = shimmer?.baseColor(context) ?? ShimmerColors.of(context).base;

    final bone = Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: base,
        shape: shape,
        borderRadius: shape == BoxShape.circle
            ? null
            : BorderRadius.circular(radius ?? 8.r),
      ),
    );

    if (shimmer == null || !shimmer.enabled) return bone;

    return AnimatedBuilder(
      animation: shimmer.animation,
      child: bone,
      builder: (context, child) {
        final gradient = shimmer.gradient(context);
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          // بينحسب وقت الرسم، لما يكون كل شي أخد مكانه
          shaderCallback: (bounds) {
            final rootSize = shimmer.size;
            final box = context.findRenderObject() as RenderBox?;
            if (rootSize == null || box == null || !box.hasSize) {
              return gradient.createShader(bounds);
            }
            final offset = shimmer.descendantOffset(box);
            return gradient.createShader(
              Rect.fromLTWH(
                -offset.dx,
                -offset.dy,
                rootSize.width,
                rootSize.height,
              ),
            );
          },
          child: child,
        );
      },
    );
  }
}

/// سطر نص
class ShimmerLine extends StatelessWidget {
  final double? width;
  final double? height;

  const ShimmerLine({super.key, this.width, this.height});

  @override
  Widget build(BuildContext context) {
    return ShimmerBox(
      width: width ?? double.infinity,
      height: height ?? 12.h,
      radius: 6.r,
    );
  }
}

/// دائرة (صورة بروفايل / أيقونة)
class ShimmerCircle extends StatelessWidget {
  final double size;

  const ShimmerCircle({super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    return ShimmerBox(width: size, height: size, shape: BoxShape.circle);
  }
}

/// كرت بلون الكرت الحقيقي، جواه عظام
class ShimmerCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? height;
  final double? width;
  final double? radius;

  const ShimmerCard({
    super.key,
    required this.child,
    this.padding,
    this.height,
    this.width,
    this.radius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? double.infinity,
      height: height,
      padding: padding ?? EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: ShimmerColors.of(context).card,
        borderRadius: BorderRadius.circular(radius ?? 16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

// ============================================================
// BUILDING BLOCKS
// ============================================================

enum ShimmerLeading { none, circle, square }

/// صف واحد يشبه ListTile: صورة/أيقونة + سطور + شي عالطرف
class ShimmerListTile extends StatelessWidget {
  final ShimmerLeading leading;
  final int lines;
  final bool trailing;
  final double? leadingSize;

  const ShimmerListTile({
    super.key,
    this.leading = ShimmerLeading.circle,
    this.lines = 2,
    this.trailing = true,
    this.leadingSize,
  });

  @override
  Widget build(BuildContext context) {
    final size = leadingSize ?? 48.w;
    return ShimmerCard(
      child: Row(
        children: [
          if (leading == ShimmerLeading.circle) ShimmerCircle(size: size),
          if (leading == ShimmerLeading.square)
            ShimmerBox(width: size, height: size, radius: 12.r),
          if (leading != ShimmerLeading.none) SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                for (int i = 0; i < lines; i++) ...[
                  if (i > 0) SizedBox(height: 8.h),
                  FractionallySizedBox(
                    alignment: AlignmentDirectional.centerStart,
                    widthFactor: i == 0 ? 0.7 : (i.isOdd ? 0.45 : 0.6),
                    child: ShimmerLine(height: i == 0 ? 14.h : 10.h),
                  ),
                ],
              ],
            ),
          ),
          if (trailing) ...[
            SizedBox(width: 12.w),
            ShimmerBox(width: 56.w, height: 24.h, radius: 12.r),
          ],
        ],
      ),
    );
  }
}

// ============================================================
// READY TEMPLATES
// ============================================================

/// ليستة كروت (طلبات، زبائن، منتجات، إشعارات، ...)
class ShimmerList extends StatelessWidget {
  final int itemCount;
  final ShimmerLeading leading;
  final int lines;
  final bool trailing;
  final EdgeInsetsGeometry padding;
  final double? spacing;

  /// لو true بترجع Column بطولها (للاستعمال جوا Sliver أو ScrollView)
  final bool shrinkWrap;

  /// لو بدك كرت مخصص بدل ShimmerListTile
  final IndexedWidgetBuilder? itemBuilder;

  const ShimmerList({
    super.key,
    this.itemCount = 8,
    this.leading = ShimmerLeading.circle,
    this.lines = 2,
    this.trailing = true,
    this.padding = EdgeInsets.zero,
    this.spacing,
    this.shrinkWrap = false,
    this.itemBuilder,
  });

  Widget _item(BuildContext context, int index) {
    return itemBuilder?.call(context, index) ??
        ShimmerListTile(leading: leading, lines: lines, trailing: trailing);
  }

  @override
  Widget build(BuildContext context) {
    final gap = spacing ?? 12.h;

    if (shrinkWrap) {
      return AppShimmer(
        child: Padding(
          padding: padding,
          child: Column(
            children: [
              for (int i = 0; i < itemCount; i++) ...[
                if (i > 0) SizedBox(height: gap),
                _item(context, i),
              ],
            ],
          ),
        ),
      );
    }

    return AppShimmer(
      child: ListView.separated(
        padding: padding,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: itemCount,
        separatorBuilder: (_, __) => SizedBox(height: gap),
        itemBuilder: _item,
      ),
    );
  }
}

/// شبكة كروت (منتجات / تصنيفات)
class ShimmerGrid extends StatelessWidget {
  final int itemCount;
  final int crossAxisCount;
  final double childAspectRatio;
  final EdgeInsetsGeometry padding;

  const ShimmerGrid({
    super.key,
    this.itemCount = 6,
    this.crossAxisCount = 2,
    this.childAspectRatio = 0.75,
    this.padding = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: GridView.builder(
        padding: padding,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: itemCount,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 12.w,
          mainAxisSpacing: 12.h,
          childAspectRatio: childAspectRatio,
        ),
        itemBuilder: (_, __) => ShimmerCard(
          padding: EdgeInsets.all(10.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(child: ShimmerBox(width: double.infinity)),
              SizedBox(height: 10.h),
              const FractionallySizedBox(
                alignment: AlignmentDirectional.centerStart,
                widthFactor: 0.8,
                child: ShimmerLine(),
              ),
              SizedBox(height: 8.h),
              FractionallySizedBox(
                alignment: AlignmentDirectional.centerStart,
                widthFactor: 0.5,
                child: ShimmerLine(height: 10.h),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// صفحة تفاصيل: هيدر (صورة + عنوان) وتحته أقسام معلومات
class ShimmerDetails extends StatelessWidget {
  /// صورة كبيرة فوق (منتج) بدل الأفاتار الدائري (زبون/طلب)
  final bool bigImage;
  final int sections;
  final int rowsPerSection;
  final EdgeInsetsGeometry? padding;

  const ShimmerDetails({
    super.key,
    this.bigImage = false,
    this.sections = 3,
    this.rowsPerSection = 3,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: ListView(
        padding: padding ??
            EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        physics: const NeverScrollableScrollPhysics(),
        children: [
          if (bigImage) ...[
            ShimmerBox(width: double.infinity, height: 220.h, radius: 16.r),
            SizedBox(height: 16.h),
            FractionallySizedBox(
              alignment: AlignmentDirectional.centerStart,
              widthFactor: 0.7,
              child: ShimmerLine(height: 18.h),
            ),
            SizedBox(height: 10.h),
            FractionallySizedBox(
              alignment: AlignmentDirectional.centerStart,
              widthFactor: 0.35,
              child: ShimmerLine(height: 14.h),
            ),
          ] else
            ShimmerCard(
              child: Row(
                children: [
                  ShimmerCircle(size: 60.w),
                  SizedBox(width: 14.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FractionallySizedBox(
                          alignment: AlignmentDirectional.centerStart,
                          widthFactor: 0.6,
                          child: ShimmerLine(height: 16.h),
                        ),
                        SizedBox(height: 10.h),
                        FractionallySizedBox(
                          alignment: AlignmentDirectional.centerStart,
                          widthFactor: 0.4,
                          child: ShimmerLine(height: 10.h),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          for (int s = 0; s < sections; s++) ...[
            SizedBox(height: 16.h),
            ShimmerCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerLine(width: 110.w, height: 14.h),
                  for (int r = 0; r < rowsPerSection; r++) ...[
                    SizedBox(height: 14.h),
                    Row(
                      children: [
                        ShimmerLine(width: 80.w, height: 10.h),
                        const Spacer(),
                        ShimmerLine(width: 60.w + (r * 15).w, height: 10.h),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// الداشبورد: كروت إحصائيات + شارت + ليستة
class ShimmerDashboard extends StatelessWidget {
  final EdgeInsetsGeometry? padding;

  const ShimmerDashboard({super.key, this.padding});

  @override
  Widget build(BuildContext context) {
    Widget statCard() => Expanded(
      child: ShimmerCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            ShimmerCircle(size: 28.w),
            SizedBox(height: 12.h),
            ShimmerLine(width: 70.w, height: 16.h),
            SizedBox(height: 8.h),
            ShimmerLine(width: 50.w, height: 10.h),
          ],
        ),
      ),
    );

    return AppShimmer(
      child: ListView(
        padding: padding ??
            EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        physics: const NeverScrollableScrollPhysics(),
        children: [
          // هيدر (ترحيب)
          Row(
            children: [
              ShimmerCircle(size: 44.w),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerLine(width: 90.w, height: 10.h),
                    SizedBox(height: 8.h),
                    ShimmerLine(width: 140.w, height: 16.h),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          Row(children: [statCard(), SizedBox(width: 12.w), statCard()]),
          SizedBox(height: 12.h),
          Row(children: [statCard(), SizedBox(width: 12.w), statCard()]),
          SizedBox(height: 16.h),
          ShimmerCard(
            height: 200.h,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerLine(width: 120.w, height: 14.h),
                SizedBox(height: 16.h),
                const Expanded(child: ShimmerBox(width: double.infinity)),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          for (int i = 0; i < 3; i++) ...[
            if (i > 0) SizedBox(height: 12.h),
            const ShimmerListTile(),
          ],
        ],
      ),
    );
  }
}

/// جدول (الضرائب مثلاً)
class ShimmerTable extends StatelessWidget {
  final int rows;
  final int columns;
  final EdgeInsetsGeometry padding;

  const ShimmerTable({
    super.key,
    this.rows = 8,
    this.columns = 4,
    this.padding = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: ListView(
        padding: padding,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          ShimmerCard(
            child: Column(
              children: [
                for (int r = 0; r < rows; r++) ...[
                  if (r > 0) SizedBox(height: 16.h),
                  Row(
                    children: [
                      for (int c = 0; c < columns; c++) ...[
                        if (c > 0) SizedBox(width: 12.w),
                        Expanded(
                          child: ShimmerLine(height: r == 0 ? 14.h : 10.h),
                        ),
                      ],
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}