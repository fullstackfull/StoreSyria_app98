import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:store_go_app/utils/colors.dart';
import 'package:store_go_app/utils/helper.dart';
import 'package:store_go_app/utils/text_style.dart';
import 'package:store_go_app/core/model/notification_model.dart';
import 'package:store_go_app/core/controller/notification_controller/notification_controller.dart';
import 'package:store_go_app/view/screen/order_screen/order_detail_screen.dart';
import '../../new_widgets/shimmer.dart';
import '../../widget/error_empty_state.dart';

class NotificationScreen extends StatefulWidget {
  final bool isBack;

  NotificationScreen({super.key, required this.isBack});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> with AutomaticKeepAliveClientMixin {
  final NotificationController notificationController = Get.find<NotificationController>();
  bool _isFirstLoad = true;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      if (_isFirstLoad) {
        _isFirstLoad = false;
        await notificationController.getNotifications();
        notificationController.markAllAsRead();
        // لا تحدد الكل كمقروء تلقائياً
      }
    });
  }

  // ── ألوان مشتركة ──
  Color _textColor(bool isDark) => isDark ? DarkThemeColor.cText : AppColor.cText;

  Color _subTextColor(bool isDark) => isDark ? DarkThemeColor.cSecondaryText : AppColor.cFont;

  Color _borderColor(bool isDark) => isDark ? DarkThemeColor.cBorder : AppColor.cDivider.withValues(alpha: 0.7);

  Color _cardColor(bool isDark) => isDark ? DarkThemeColor.cCardBackground : Colors.white;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
      child: Scaffold(
        backgroundColor: isDark ? DarkThemeColor.cBackGround : AppColor.cBackGround,
        appBar: _buildAppBar(isDark),
        body: SafeArea(
          child: Obx(() {
            if (notificationController.isLoading.value) {
              return ShimmerList(
                trailing: false,
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              );
            }

            if (notificationController.notificationList.isEmpty) {
              return EmptyState(
                message: "no_notifications".tr,
                icon: Icons.notifications_off_outlined,
              );
            }

            return RefreshIndicator(
              color: AppColor.themeNavyBlueColor,
              backgroundColor: isDark ? DarkThemeColor.cCardBackground : Colors.white,
              onRefresh: () async {
                await notificationController.getNotifications();
              },
              child: ListView.separated(
                physics: AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 24.h),
                itemCount: notificationController.notificationList.length,
                separatorBuilder: (_, __) => SizedBox(height: 12.h),
                itemBuilder: (context, index) {
                  final notification = notificationController.notificationList[index];
                  return _buildNotificationCard(notification, isDark);
                },
              ),
            );
          }),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isDark) {
    return AppBar(
      backgroundColor: isDark ? DarkThemeColor.cBackGround : AppColor.cBackGround,
      elevation: 0,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      titleSpacing: widget.isBack ? 0 : 16.w,
      leadingWidth: widget.isBack ? 64.w : 0,
      leading: widget.isBack
          ? Center(
        child: Material(
          color: _cardColor(isDark),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
            side: BorderSide(color: isDark ? DarkThemeColor.cBorder : AppColor.cBorder),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(12.r),
            onTap: () {
              Get.back();
            },
            child: SizedBox(
              width: 40.w,
              height: 40.w,
              child: Icon(
                Icons.arrow_back_rounded,
                size: 20.sp,
                color: isDark ? DarkThemeColor.cText : AppColor.blueColor,
              ),
            ),
          ),
        ),
      )
          : null,
      title: Row(
        children: [
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "notifications".tr,
                  style: pSemiBold18.copyWith(color: _textColor(isDark)),
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 2.h),
                Obx(() {
                  final count = notificationController.notificationList.length;
                  return Text(
                    '$count notification${count == 1 ? '' : 's'}',
                    style: pRegular12.copyWith(color: _subTextColor(isDark)),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(1),
        child: Container(
          height: 1,
          color: isDark ? DarkThemeColor.cBorder : AppColor.cDivider.withValues(alpha: 0.5),
        ),
      ),
      actions: [
        Obx(() {
          // إظهار الزر فقط إذا كانت هناك إشعارات غير مضغوطة
          final hasUntapped = notificationController.notificationList.any(
                (n) => !notificationController.isNotificationTapped(n.id ?? -1),
          );

          if (!hasUntapped) return SizedBox();

          final accent = isDark ? DarkThemeColor.cText : AppColor.blueColor;

          return Padding(
            padding: EdgeInsetsDirectional.only(end: 12.w),
            child: Material(
              color: AppColor.blueColor.withValues(alpha: isDark ? 0.18 : 0.1),
              borderRadius: BorderRadius.circular(20.r),
              child: InkWell(
                borderRadius: BorderRadius.circular(20.r),
                onTap: () {
                  // فقط يجعل الإشعارات تبدو مضغوطة بصرياً
                  // لا يؤثر على حالة القراءة أو عداد الجرس
                  notificationController.markAllAsTapped();
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.done_all_rounded, size: 16.sp, color: accent),
                      SizedBox(width: 6.w),
                      Text(
                        "mark_all_tapped".tr,
                        style: pMedium12.copyWith(color: accent),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildNotificationCard(NotificationData notification, bool isDark) {
    final isOrderNotif = notification.referenceType == 'order';
    final isRead = notification.isRead == true;
    final typeColor = _getTypeColor(notification.type);

    // 👆 نستخدم tappedNotificationIds للتحكم في المظهر البصري فقط
    // بينما is_read يتحكم في عداد الجرس كما هو
    return Obx(() {
      final isTapped = notificationController.isNotificationTapped(notification.id ?? -1);

      final cardBg = isTapped
          ? _cardColor(isDark)
          : (isDark
          ? Color.alphaBlend(typeColor.withValues(alpha: 0.08), DarkThemeColor.cCardBackground)
          : Color.alphaBlend(typeColor.withValues(alpha: 0.04), Colors.white));

      return AnimatedContainer(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(
            color: isTapped ? _borderColor(isDark) : typeColor.withValues(alpha: isDark ? 0.4 : 0.3),
            width: 1,
          ),
          boxShadow: isDark
              ? []
              : [
            BoxShadow(
              color: isTapped ? Colors.black.withValues(alpha: 0.03) : typeColor.withValues(alpha: 0.08),
              blurRadius: isTapped ? 8 : 16,
              offset: Offset(0, isTapped ? 2 : 6),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(18.r),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            splashColor: typeColor.withValues(alpha: 0.08),
            highlightColor: typeColor.withValues(alpha: 0.04),
            onTap: () {
              // تسجيل الضغط الفعلي (للمظهر البصري فقط)
              if (notification.id != null) {
                notificationController.markNotificationTapped(notification.id!);
              }
              // تحديد كمقروء (لعداد الجرس) فقط عند الضغط الفعلي على الإشعار
              if (!isRead) {
                notificationController.markAsRead(notification.id!);
              }
              // الانتقال لتفاصيل الطلب إذا كان reference_type == 'order'
              if (isOrderNotif && notification.data?.orderId != null) {
                Get.to(
                      () => OrderDetailScreen(
                    orderId: notification.data!.orderId.toString(),
                  ),
                  transition: Transition.rightToLeft,
                );
              }
            },
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ── Header Row ──
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(14.w, 14.h, 14.w, 12.h),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // أيقونة الإشعار
                          _buildTypeIcon(notification.type, typeColor, dimmed: isTapped),
                          SizedBox(width: 12.w),

                          // محتوى النص
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        notification.title ?? '',
                                        style: pSemiBold16.copyWith(
                                          color: _textColor(isDark),
                                          fontWeight: isTapped ? FontWeight.w500 : FontWeight.w600,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    SizedBox(width: 8.w),
                                    if (!isTapped)
                                      Container(
                                        width: 9.w,
                                        height: 9.w,
                                        decoration: BoxDecoration(
                                          color: typeColor,
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: typeColor.withValues(alpha: 0.4),
                                              blurRadius: 6,
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                                SizedBox(height: 5.h),
                                Text(
                                  notification.message ?? '',
                                  style: pRegular14.copyWith(
                                    color: _subTextColor(isDark),
                                    height: 1.45,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 10.h),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.schedule_rounded,
                                      size: 13.sp,
                                      color: _subTextColor(isDark).withValues(alpha: 0.8),
                                    ),
                                    SizedBox(width: 4.w),
                                    Text(
                                      textDirection: TextDirection.ltr,
                                      dateFormatted(date: notification.createdAt ?? "",formatType:
                                      formatForDateTime(
                                        FormatType.dateTime2,
                                      )),
                                      style: pRegular12.copyWith(
                                        color: _subTextColor(isDark).withValues(alpha: 0.9),
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    if (isOrderNotif) ...[
                                      Spacer(),
                                      _buildViewOrderPill(typeColor, isDark),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ── Order Details Footer ──
                    if (isOrderNotif && notification.data != null)
                      _buildOrderDetailsFooter(notification.data!, isDark, typeColor),
                  ],
                ),
                // شريط جانبي ملوّن للإشعارات غير المضغوطة (يتبع اتجاه اللغة)
                PositionedDirectional(
                  start: 0,
                  top: 0,
                  bottom: 0,
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    width: isTapped ? 0 : 4.w,
                    color: typeColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildViewOrderPill(Color color, bool isDark) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.18 : 0.1),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'view_order'.tr,
            style: pRegular12.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(width: 4.w),
          Icon(
            Icons.arrow_forward_ios_rounded,
            size: 10.sp,
            color: color,
          ),
        ],
      ),
    );
  }

  Widget _buildTypeIcon(String? type, Color color, {bool dimmed = false}) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      width: 48.w,
      height: 48.w,
      decoration: BoxDecoration(
        color: color.withValues(alpha: dimmed ? 0.08 : 0.14),
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Icon(
        _getNotificationIcon(type),
        color: color.withValues(alpha: dimmed ? 0.55 : 1.0),
        size: 23.sp,
      ),
    );
  }

  Widget _buildOrderDetailsFooter(
      NotificationDataDetails details,
      bool isDark,
      Color accentColor,
      ) {
    final footerBg = isDark ? Colors.black.withValues(alpha: 0.2) : AppColor.cBackGround.withValues(alpha: 0.7);

    return Container(
      decoration: BoxDecoration(
        color: footerBg,
        border: Border(
          top: BorderSide(color: _borderColor(isDark), width: 1),
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      child: Row(
        children: [
          Expanded(
            child: Wrap(
              spacing: 8.w,
              runSpacing: 6.h,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                // السعر النهائي
                if (details.finalPrice != null)
                  _buildDetailChip(
                    icon: Icons.payments_outlined,
                    label: details.finalPrice!,
                    isDark: isDark,
                    color: Colors.green.shade600,
                    emphasize: true,
                  ),

                // نوع الدفع
                if (details.paymentType != null)
                  _buildDetailChip(
                    icon: Icons.credit_card_rounded,
                    label: details.paymentType!,
                    isDark: isDark,
                    color: accentColor,
                  ),
              ],
            ),
          ),

          // حالة الدفع
          if (details.paymentStatus != null) ...[
            SizedBox(width: 8.w),
            _buildPaymentStatusBadge(details.paymentStatus!, isDark),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailChip({
    required IconData icon,
    required String label,
    required bool isDark,
    required Color color,
    bool emphasize = false,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: _cardColor(isDark),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: _borderColor(isDark)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13.sp, color: color),
          SizedBox(width: 4.w),
          Flexible(
            child: Text(
              label,
              style: pRegular12.copyWith(
                color: emphasize ? _textColor(isDark) : _subTextColor(isDark),
                fontWeight: emphasize ? FontWeight.w600 : FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentStatusBadge(String status, bool isDark) {
    final lower = status.toLowerCase();
    final Color bgColor;
    final Color textColor;
    final IconData icon;

    if (lower == 'paid') {
      bgColor = Colors.green.withValues(alpha: isDark ? 0.2 : 0.12);
      textColor = isDark ? Colors.green.shade300 : Colors.green.shade700;
      icon = Icons.check_circle_rounded;
    } else if (lower == 'pending') {
      bgColor = Colors.orange.withValues(alpha: isDark ? 0.2 : 0.12);
      textColor = isDark ? Colors.orange.shade300 : Colors.orange.shade700;
      icon = Icons.hourglass_top_rounded;
    } else {
      bgColor = Colors.red.withValues(alpha: isDark ? 0.2 : 0.12);
      textColor = isDark ? Colors.red.shade300 : Colors.red.shade700;
      icon = Icons.error_rounded;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12.sp, color: textColor),
          SizedBox(width: 4.w),
          Text(
            status,
            style: pRegular12.copyWith(
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Color _getTypeColor(String? type) {
    switch (type) {
      case 'order_created':
        return AppColor.blueColor;
      case 'order_updated':
        return Colors.orange.shade600;
      case 'order_cancelled':
        return Colors.red.shade500;
      case 'payment_received':
        return Colors.green.shade600;
      default:
        return AppColor.blueColor;
    }
  }

  IconData _getNotificationIcon(String? type) {
    switch (type) {
      case 'order_created':
        return Icons.shopping_bag_rounded;
      case 'order_updated':
        return Icons.edit_note_rounded;
      case 'order_cancelled':
        return Icons.cancel_rounded;
      case 'payment_received':
        return Icons.payments_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }
}