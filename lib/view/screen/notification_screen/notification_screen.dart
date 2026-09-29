// ignore_for_file: prefer_const_constructors, must_be_immutable, prefer_const_constructors_in_immutables, avoid_print

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:store_go_app/utils/colors.dart';
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

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
      child: Scaffold(
        backgroundColor:
        isDark ? DarkThemeColor.cBackGround : AppColor.cBackGround,
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
              color: AppColor.themeGreenColor,
              backgroundColor:
              isDark ? DarkThemeColor.cCardBackground : Colors.white,
              onRefresh: () async {
                await notificationController.getNotifications();
              },
              child: ListView.builder(
                padding:
                EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                itemCount:
                notificationController.notificationList.length,
                itemBuilder: (context, index) {
                  final notification =
                  notificationController.notificationList[index];
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
      backgroundColor:
      isDark ? DarkThemeColor.cBackGround : AppColor.cBackGround,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: widget.isBack
          ? GestureDetector(
        onTap: () {
          Get.back();
        },
        child: Padding(
          padding: EdgeInsets.all(9.w),
          child: Container(
            height: 10.h,
            width: 10.w,
            decoration: BoxDecoration(
              border: Border.all(color: AppColor.cBorder),
              borderRadius: BorderRadius.circular(15.r),
            ),
            child: Icon(Icons.arrow_back,color: AppColor.themeNavyBlueColor),
          ),
        ),
      )
          : null,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "notifications".tr,
            style: pSemiBold18.copyWith(
              color: isDark ? DarkThemeColor.cText : AppColor.cText,
            ),
          ),
          Obx(() {
            final count = notificationController.notificationList.length;
            return Text(
              '$count notification${count == 1 ? '' : 's'}',
              style: pRegular12.copyWith(
                color: isDark
                    ? DarkThemeColor.cSecondaryText
                    : AppColor.cFont,
              ),
            );
          }),
        ],
      ),
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(1),
        child: Container(
          height: 1,
          color: isDark
              ? DarkThemeColor.cBorder
              : AppColor.cDivider.withValues(alpha: 0.5),
        ),
      ),
      actions: [
        Obx(() {
          // إظهار الزر فقط إذا كانت هناك إشعارات غير مضغوطة
          final hasUntapped = notificationController.notificationList.any(
                  (n) => !notificationController.isNotificationTapped(n.id ?? -1)
          );

          if (!hasUntapped) return SizedBox();

          return TextButton.icon(
            onPressed: () {
              // فقط يجعل الإشعارات تبدو مضغوطة بصرياً
              // لا يؤثر على حالة القراءة أو عداد الجرس
              notificationController.markAllAsTapped();
            },
            icon: Icon(
              Icons.done_all,
              size: 20.sp,
              color: isDark
                  ? DarkThemeColor.cText
                  : AppColor.themeGreenColor,
            ),
            label: Text(
              "mark_all_tapped".tr,
              style: pMedium14.copyWith(
                color: isDark
                    ? DarkThemeColor.cText
                    : AppColor.themeGreenColor,
              ),
            ),
          );
        }),
        SizedBox(width: 8.w),
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
          ? (isDark ? DarkThemeColor.cCardBackground : Colors.white)
          : (isDark
          ? DarkThemeColor.cCardBackground
          : typeColor.withValues(alpha: 0.06));

      return GestureDetector(
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
        child: AnimatedContainer(
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
          margin: EdgeInsets.only(bottom: 10.h),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: isTapped
                  ? (isDark ? DarkThemeColor.cBorder : AppColor.cDivider)
                  : typeColor.withValues(alpha: 0.45),
              width: isTapped ? 1 : 1.5,
            ),
            boxShadow: isTapped
                ? []
                : [
              BoxShadow(
                color: typeColor.withValues(alpha: 0.1),
                blurRadius: 14,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              // ── Header Row ──
              Padding(
                padding:
                EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
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
                            children: [
                              Expanded(
                                child: Text(
                                  notification.title ?? '',
                                  style: pSemiBold16.copyWith(
                                    color: isDark
                                        ? DarkThemeColor.cText
                                        : AppColor.cText,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              SizedBox(width: 8.w),
                              // نقطة "لم يُضغط عليه" مرتبطة بـ tappedNotificationIds
                              if (!isTapped)
                                Container(
                                  width: 8.w,
                                  height: 8.w,
                                  decoration: BoxDecoration(
                                    color: typeColor,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                            ],
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            notification.message ?? '',
                            style: pRegular14.copyWith(
                              color: isDark
                                  ? DarkThemeColor.cSecondaryText
                                  : AppColor.cFont,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 8.h),
                          Row(
                            children: [
                              Icon(
                                Icons.access_time_rounded,
                                size: 13.sp,
                                color: isDark
                                    ? DarkThemeColor.cSecondaryText
                                    : AppColor.cFont,
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                _formatDate(notification.createdAt),
                                style: pRegular12.copyWith(
                                  color: isDark
                                      ? DarkThemeColor.cSecondaryText
                                      : AppColor.cFont,
                                ),
                              ),
                              if (isOrderNotif) ...[
                                SizedBox(width: 8.w),
                                Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  size: 11.sp,
                                  color: typeColor.withValues(alpha: 0.7),
                                ),
                                SizedBox(width: 2.w),
                                Text(
                                  'view_order'.tr,
                                  style: pRegular12.copyWith(
                                    color: typeColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
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
                _buildOrderDetailsFooter(
                    notification.data!, isDark, typeColor),
            ],
          ),
        ),
      );
    });
  }


  Widget _buildTypeIcon(String? type, Color color, {bool dimmed = false}) {
    return Container(
      width: 46.w,
      height: 46.w,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: dimmed
              ? [
            color.withValues(alpha: 0.08),
            color.withValues(alpha: 0.14),
          ]
              : [
            color.withValues(alpha: 0.18),
            color.withValues(alpha: 0.32),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: color.withValues(alpha: dimmed ? 0.15 : 0.35),
          width: 1,
        ),
      ),
      child: Icon(
        _getNotificationIcon(type),
        color: color.withValues(alpha: dimmed ? 0.5 : 1.0),
        size: 22.sp,
      ),
    );
  }


  Widget _buildOrderDetailsFooter(
      NotificationDataDetails details,
      bool isDark,
      Color accentColor,
      ) {
    final footerBg = isDark
        ? Colors.black.withValues(alpha: 0.25)
        : accentColor.withValues(alpha: 0.04);

    return Container(
      decoration: BoxDecoration(
        color: footerBg,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(16.r),
          bottomRight: Radius.circular(16.r),
        ),
        border: Border(
          top: BorderSide(
            color: isDark
                ? DarkThemeColor.cBorder
                : AppColor.cDivider.withValues(alpha: 0.6),
            width: 1,
          ),
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      child: Row(
        children: [
          // السعر النهائي
          if (details.finalPrice != null)
            Expanded(
              child: _buildDetailChip(
                icon: Icons.attach_money_rounded,
                label: details.finalPrice!,
                isDark: isDark,
                color: Colors.green.shade600,
              ),
            ),

          // نوع الدفع
          if (details.paymentType != null)
            Expanded(
              child: _buildDetailChip(
                icon: Icons.credit_card_rounded,
                label: details.paymentType!,
                isDark: isDark,
                color: accentColor,
              ),
            ),

          // حالة الدفع
          if (details.paymentStatus != null)
            _buildPaymentStatusBadge(details.paymentStatus!, isDark),
        ],
      ),
    );
  }

  Widget _buildDetailChip({
    required IconData icon,
    required String label,
    required bool isDark,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, size: 13.sp, color: color),
        SizedBox(width: 3.w),
        Flexible(
          child: Text(
            label,
            style: pRegular12.copyWith(
              color:
              isDark ? DarkThemeColor.cSecondaryText : AppColor.cFont,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentStatusBadge(String status, bool isDark) {
    final lower = status.toLowerCase();
    final Color bgColor;
    final Color textColor;

    if (lower == 'paid') {
      bgColor = Colors.green.withValues(alpha: 0.15);
      textColor = Colors.green.shade700;
    } else if (lower == 'pending') {
      bgColor = Colors.orange.withValues(alpha: 0.15);
      textColor = Colors.orange.shade700;
    } else {
      bgColor = Colors.red.withValues(alpha: 0.15);
      textColor = Colors.red.shade700;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5.w,
            height: 5.w,
            decoration: BoxDecoration(
              color: textColor,
              shape: BoxShape.circle,
            ),
          ),
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
        return AppColor.themeGreenColor;
      case 'order_updated':
        return Colors.orange.shade600;
      case 'order_cancelled':
        return Colors.red.shade500;
      case 'payment_received':
        return Colors.green.shade600;
      default:
        return AppColor.themeGreenColor;
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

  String _formatDate(String? dateString) {
    if (dateString == null) return '';
    try {
      DateTime date = DateTime.parse(dateString);
      DateTime now = DateTime.now();
      Duration difference = now.difference(date);

      if (difference.inMinutes < 1) {
        return 'just_now'.tr;
      } else if (difference.inMinutes < 60) {
        return '${difference.inMinutes} ${'minutes_ago'.tr}';
      } else if (difference.inHours < 24) {
        return '${difference.inHours} ${'hours_ago'.tr}';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} ${'days_ago'.tr}';
      } else {
        return '${date.day}/${date.month}/${date.year}';
      }
    } catch (e) {
      return dateString;
    }
  }
}
