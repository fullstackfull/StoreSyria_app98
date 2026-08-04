// ignore_for_file: prefer_const_constructors, avoid_print

import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart'; // للترجمة
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/foundation.dart';
import 'package:open_file/open_file.dart';
import 'package:store_go_app/core/model/order_detail_model.dart';
import 'package:store_go_app/utils/colors.dart';
import 'package:store_go_app/view/screen/order_screen/invoice.dart';
import 'package:store_go_app/view/widget/common_appbar_widget.dart';
import 'package:store_go_app/view/widget/common_snak_bar_widget.dart';
import 'package:store_go_app/view/widget/loading_widget.dart';

class InvoicePdfViewScreen extends StatefulWidget {
  final List<Product> productList;
  final OrderDetailData orderDetailData;
  final String tax;
  final double deliveryCharge;
  final double couponAmount;

  const InvoicePdfViewScreen({
    Key? key,
    required this.productList,
    required this.orderDetailData,
    required this.tax,
    required this.deliveryCharge,
    required this.couponAmount
  }) : super(key: key);

  @override
  InvoicePdfViewScreenState createState() => InvoicePdfViewScreenState();
}

class InvoicePdfViewScreenState extends State<InvoicePdfViewScreen> {
  PrintingInfo? printingInfo;
  final _data = const CustomData();

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final info = await Printing.info();
    if (mounted) {
      setState(() {
        printingInfo = info;
      });
    }
  }

  Future<void> _saveAsFile(
      BuildContext context,
      LayoutCallback build,
      PdfPageFormat pageFormat,
      ) async {
    final bytes = await build(pageFormat);

    // تحديد مسار التحميل
    final directory = Directory('/storage/emulated/0/Download');
    if (!directory.existsSync()) {
      directory.createSync();
    }

    final file = File('${directory.path}/Invoice_${widget.orderDetailData.orderId}.pdf');
    await file.writeAsBytes(bytes);

    if (mounted) {
      commonToast("document_saved".tr); // ترجمة رسالة الحفظ
      await OpenFile.open(file.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? DarkThemeColor.cBackGround : AppColor.cBackGround;

    final actions = <PdfPreviewAction>[
      if (!kIsWeb)
        PdfPreviewAction(
          icon: Icon(Icons.download, size: 20.sp),
          onPressed: _saveAsFile,
        )
    ];

    return Scaffold(
      backgroundColor: bgColor,
      appBar: simpleAppBar(title: 'invoice'.tr), // ترجمة عنوان الشاشة
      body: Padding(
        padding: EdgeInsets.only(top: 10.h),
        child: PdfPreview(
          maxPageWidth: 700,
          pdfPreviewPageDecoration: BoxDecoration(
            color: Colors.grey.shade200, // خلفية محايدة لعرض الـ PDF
            boxShadow: [BoxShadow(blurRadius: 10, color: Colors.black12)],
          ),
          scrollViewDecoration: BoxDecoration(color: bgColor),
          actions: actions,
          canChangeOrientation: false,
          canDebug: false,
          loadingWidget: Center(child: LoadingWidget()),
          onPrinted: _showPrintedToast,
          onShared: _showSharedToast,
          build: (PdfPageFormat format) {
            return generateInvoice(
                format,
                _data,
                widget.productList,
                widget.orderDetailData,
                widget.tax,
                widget.deliveryCharge,
                widget.couponAmount
            );
          },
        ),
      ),
    );
  }

  _showSharedToast(BuildContext context) {
    commonToast("document_shared_success".tr); // ترجمة رسالة المشاركة
  }

  _showPrintedToast(BuildContext context) {
    commonToast('document_printed_success'.tr); // ترجمة رسالة الطباعة
  }
}