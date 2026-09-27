// ignore_for_file: prefer_const_constructors, avoid_print

import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:get/get.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:store_go_app/utils/helper.dart';
import 'package:store_go_app/utils/images.dart';

import '../../../core/model/order_detail_model.dart';

String _fixRtl(String text, bool isArabic) {
  if (!isArabic || text.trim().isEmpty) return text;
  return String.fromCharCodes(text.runes.toList().reversed);
}

class CustomData {
  const CustomData({this.name = 'Store Syria'});

  final String name;
}

Future<Uint8List> generateInvoice(
    PdfPageFormat pageFormat,
    CustomData data,
    List<Product> productList,
    OrderDetailData orderDetailData,
    String tax,
    double deliveryCharge,
    double couponAmount,
    String currencySymbol,
    ) async {
  final bool isArabic = Get.locale?.languageCode == 'ar';
  final products = <ProductData>[];

  for (final product in productList) {
    products.add(
      ProductData(
        product.productId?.toString() ?? '',
        product.name?.toString() ?? '',
        double.tryParse(product.finalPrice?.toString() ?? '0') ?? 0,
        int.tryParse(product.qty?.toString() ?? '0') ?? 0,
        currencySymbol,
        isArabic,
      ),
    );
  }

  final PdfColor navyBlue = PdfColor.fromInt(0xFF172C4E);
  final PdfColor greenAccent = PdfColor.fromInt(0xFF00B4D8);
  final PdfColor textDark = PdfColor.fromInt(0xFF1E222B);
  final PdfColor textGrey = PdfColor.fromInt(0xFF66728C);

  final double subTotalFromModel =
      double.tryParse(orderDetailData.subTotal?.toString() ?? '0') ?? 0;
  final double grandTotalFromModel =
      double.tryParse(orderDetailData.finalPrice?.toString() ?? '0') ?? 0;

  final invoice = Invoice(
    invoiceNumber: orderDetailData.orderId?.toString() ?? '',
    products: products,
    customerName:
    orderDetailData.billingInformations?.name?.toString() ?? '',
    customerAddress:
    "${orderDetailData.deliveryInformations?.city?.toString() ?? ''}, "
        "${orderDetailData.deliveryInformations?.state?.toString() ?? ''}, "
        "${orderDetailData.deliveryInformations?.country?.toString() ?? ''}, "
        "${orderDetailData.deliveryInformations?.postCode?.toString() ?? ''}",
    paymentInfo: orderDetailData.paymnetType?.toString() ?? '',
    tax: double.tryParse(tax) ?? 0,
    baseColor: navyBlue,
    accentColor: greenAccent,
    textColor: textDark,
    subTextColor: textGrey,
    deliveryCharge: deliveryCharge,
    couponAmount: couponAmount,
    isArabic: isArabic,
    currencySymbol: currencySymbol,
    subTotalOverride: subTotalFromModel,
    grandTotalOverride: grandTotalFromModel,
  );

  return invoice.buildPdf(pageFormat);
}

class Invoice {
  Invoice({
    required this.products,
    required this.customerName,
    required this.customerAddress,
    required this.invoiceNumber,
    required this.tax,
    required this.deliveryCharge,
    required this.couponAmount,
    required this.paymentInfo,
    required this.baseColor,
    required this.accentColor,
    required this.textColor,
    required this.subTextColor,
    required this.isArabic,
    required this.currencySymbol,
    required this.subTotalOverride,
    required this.grandTotalOverride,
  });

  final List<ProductData> products;
  final String customerName;
  final String customerAddress;
  final String invoiceNumber;
  final double tax;
  final double deliveryCharge;
  final double couponAmount;
  final String paymentInfo;
  final bool isArabic;

  final String currencySymbol;

  final PdfColor baseColor;
  final PdfColor accentColor;
  final PdfColor textColor;
  final PdfColor subTextColor;

  final double subTotalOverride;
  final double grandTotalOverride;

  double get _total => subTotalOverride;

  double get _grandTotal => grandTotalOverride;

  String? _logo;

  Future<Uint8List> buildPdf(PdfPageFormat pageFormat) async {
    final doc = pw.Document();

    try {
      _logo = await rootBundle.loadString(DefaultImages.sLogoIcn);
    } catch (e) {
      _logo = null;
    }

    final regularFontData = await rootBundle.load('assets/fonts/Tajawal-Regular.ttf');
    final boldFontData = await rootBundle.load('assets/fonts/Tajawal-Bold.ttf');

    final regularFont = pw.Font.ttf(regularFontData);
    final boldFont = pw.Font.ttf(boldFontData);

    final theme = pw.ThemeData.withFont(base: regularFont, bold: boldFont);
    final textDirection = isArabic ? pw.TextDirection.rtl : pw.TextDirection.ltr;

    doc.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          pageFormat: pageFormat,
          theme: theme,
          margin: const pw.EdgeInsets.all(24),
          textDirection: textDirection,
        ),
        header: _buildHeader,
        footer: _buildFooter,
        build: (context) => [
          _contentHeader(context),
          pw.SizedBox(height: 22),
          _sectionLabel('order_items'.tr),
          pw.SizedBox(height: 10),
          _contentTable(context),
          pw.SizedBox(height: 22),
          _sectionLabel('payment_summary'.tr),
          pw.SizedBox(height: 10),
          _totalsCard(context),
          pw.SizedBox(height: 22),
          _thankYouCard(context),
          pw.SizedBox(height: 20),
          _termsAndConditions(context),
        ],
      ),
    );

    return doc.save();
  }

  // ============================================================
  // SECTION LABEL — عنوان قسم بلون الأخضر متل التطبيق
  // ============================================================
  pw.Widget _sectionLabel(String text) {
    return pw.Text(
      text,
      style: pw.TextStyle(
        color: accentColor,
        fontWeight: pw.FontWeight.bold,
        fontSize: 13,
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  pw.Widget _buildHeader(pw.Context context) {
    return pw.Column(
      children: [
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Column(
              crossAxisAlignment: isArabic
                  ? pw.CrossAxisAlignment.end
                  : pw.CrossAxisAlignment.start,
              mainAxisSize: pw.MainAxisSize.min,
              children: [
                pw.Text(
                  'invoice_title'.tr.toUpperCase(),
                  style: pw.TextStyle(
                    color: baseColor,
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 26,
                  ),
                ),
                pw.SizedBox(height: 6),
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: pw.BoxDecoration(
                    color: PdfColor.fromInt(0xFFEFF2F8),
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(20)),
                  ),
                  child: pw.Text(
                    invoiceNumber,
                    style: pw.TextStyle(
                      color: baseColor,
                      fontSize: 11,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            pw.Column(
              mainAxisSize: pw.MainAxisSize.min,
              children: [
                if (_logo != null)
                  pw.Container(
                    height: 56,
                    width: 56,
                    padding: const pw.EdgeInsets.all(6),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColor.fromInt(0xFFE3E7EF), width: 1),
                      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(14)),
                    ),
                    child: pw.SvgImage(svg: _logo!),
                  )
                else
                  pw.SizedBox(height: 56),
                pw.SizedBox(height: 6),
                pw.Text(
                  "Store Syria",
                  textAlign: pw.TextAlign.center,
                  style: pw.TextStyle(
                    color: baseColor,
                    fontSize: 13,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
        pw.SizedBox(height: 16),
        pw.Container(height: 3, width: double.infinity, decoration: pw.BoxDecoration(
          color: baseColor,
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(3)),
        )),
        pw.SizedBox(height: 16),
      ],
    );
  }

  // ============================================================
  // FOOTER
  // ============================================================

  pw.Widget _buildFooter(pw.Context context) {
    return pw.Column(
      children: [
        pw.Divider(color: PdfColor.fromInt(0xFFE3E7EF), thickness: .7),
        pw.SizedBox(height: 8),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'generated_by'.tr,
              style: pw.TextStyle(fontSize: 9, color: subTextColor, fontWeight: pw.FontWeight.bold),
            ),
            pw.Text(
              '${'page_label'.tr} ${context.pageNumber}/${context.pagesCount}',
              style: pw.TextStyle(fontSize: 9, color: baseColor, fontWeight: pw.FontWeight.bold),
            ),
          ],
        ),
      ],
    );
  }

  // ============================================================
  // CUSTOMER INFORMATION — بشكل كارد فاتح متل كاردات التطبيق
  // ============================================================

  pw.Widget _contentHeader(pw.Context context) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(14),
      decoration: pw.BoxDecoration(
        color: PdfColors.white,
        border: pw.Border.all(color: PdfColor.fromInt(0xFFE3E7EF), width: 1),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(12)),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(
            flex: 2,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'bill_to'.tr,
                  style: pw.TextStyle(color: accentColor, fontWeight: pw.FontWeight.bold, fontSize: 11),
                ),
                pw.SizedBox(height: 6),
                pw.Text(
                  customerName,
                  style: pw.TextStyle(color: textColor, fontWeight: pw.FontWeight.bold, fontSize: 13),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  customerAddress,
                  textAlign: isArabic ? pw.TextAlign.right : pw.TextAlign.left,
                  style: pw.TextStyle(
                    color: subTextColor,
                    fontSize: isArabic ? 11 : 10,
                    fontWeight: pw.FontWeight.bold,
                    lineSpacing: isArabic ? 5 : 2,
                    height: isArabic ? 1.4 : 1.2,
                  ),
                ),
              ],
            ),
          ),
          pw.SizedBox(width: 14),
          pw.Container(width: 1, height: 60, color: PdfColor.fromInt(0xFFE3E7EF)),
          pw.SizedBox(width: 14),
          pw.Expanded(
            flex: 1,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                _infoRow('date_label'.tr, dateFormatted(
                  date: DateTime.now().toString(),
                  formatType: formatForDateTime(FormatType.date),
                )),
                _infoRow('payment_method'.tr, paymentInfo),
              ],
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _infoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 8),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(color: subTextColor, fontSize: 9, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 2),
          pw.Text(
            value,
            style: pw.TextStyle(color: textColor, fontSize: isArabic ? 11 : 10, fontWeight: pw.FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TOTALS CARD — صندوق كحلي كامل متل grandTotalsWidget بالتطبيق
  // ============================================================

  pw.Widget _totalsCard(pw.Context context) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(18),
      decoration: pw.BoxDecoration(
        color: baseColor,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(14)),
      ),
      child: pw.Column(
        children: [
          _totalRowWhite('sub_total'.tr, _formatAmount(_total)),
          _totalRowWhite('shipping'.tr, _formatAmount(deliveryCharge)),
          _totalRowWhite('tax'.tr, _formatAmount(tax)),
          _totalRowWhite('coupon'.tr, "- ${_formatAmount(couponAmount)}", isCoupon: true),
          pw.SizedBox(height: 6),
          pw.Container(height: 1, color: PdfColors.white.shade(0.7)),
          pw.SizedBox(height: 10),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'grand_total'.tr,
                style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.white),
              ),
              pw.Text(
                _formatAmount(_grandTotal),
                style: pw.TextStyle(fontSize: 17, fontWeight: pw.FontWeight.bold, color: PdfColors.white),
              ),
            ],
          ),
          pw.SizedBox(height: 12),
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: pw.BoxDecoration(
              color: PdfColors.white.shade(0.85),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
            ),
            child: pw.Text(
              '${'paid_by'.tr} $paymentInfo',
              style: pw.TextStyle(fontSize: 10, color: PdfColors.white),
            ),
          ),
        ],
      ),
    );
  }

  String _formatAmount(double amount) {
    final symbol = _fixRtl(currencySymbol, isArabic);
    return "${amount.toStringAsFixed(2)} $symbol";
  }

  pw.Widget _totalRowWhite(String label, String value, {bool isCoupon = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(fontSize: 11, color: PdfColors.white.shade(0.7)),
          ),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 11,
              color: isCoupon ? PdfColor.fromInt(0xFF7FE0A0) : PdfColors.white,
              fontWeight: isCoupon ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // THANK YOU CARD
  // ============================================================

  pw.Widget _thankYouCard(pw.Context context) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(14),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromInt(0xFFF5F8F6),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(12)),
        border: pw.Border.all(color: accentColor.shade(0.7), width: 1),
      ),
      child: pw.Column(
        crossAxisAlignment: isArabic ? pw.CrossAxisAlignment.end : pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'thank_you_msg'.tr,
            textAlign: isArabic ? pw.TextAlign.right : pw.TextAlign.left,
            style: pw.TextStyle(
              color: accentColor,
              fontWeight: pw.FontWeight.bold,
              fontSize: isArabic ? 13 : 12,
              height: isArabic ? 1.4 : 1.2,
            ),
          ),
          pw.SizedBox(height: 6),
          pw.Text(
            'support_msg'.tr,
            textAlign: isArabic ? pw.TextAlign.right : pw.TextAlign.left,
            style: pw.TextStyle(
              fontSize: isArabic ? 11 : 10,
              color: subTextColor,
              fontWeight: pw.FontWeight.bold,
              lineSpacing: isArabic ? 5 : 2,
              height: isArabic ? 1.4 : 1.2,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TERMS
  // ============================================================

  pw.Widget _termsAndConditions(pw.Context context) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Divider(color: PdfColor.fromInt(0xFFE3E7EF), thickness: 1),
        pw.SizedBox(height: 7),
        pw.Text(
          'terms_title'.tr,
          style: pw.TextStyle(fontSize: 11, color: baseColor, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 5),
        pw.Text(
          'terms_text'.tr,
          textAlign: isArabic ? pw.TextAlign.right : pw.TextAlign.justify,
          style: pw.TextStyle(
            fontSize: isArabic ? 10.5 : 9.5,
            color: subTextColor,
            fontWeight: pw.FontWeight.bold,
            lineSpacing: isArabic ? 5 : 2,
            height: isArabic ? 1.5 : 1.2,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // PRODUCTS TABLE
  // ============================================================

  pw.Widget _contentTable(pw.Context context) {
    final headers = [
      'sku_col'.tr,
      'desc_col'.tr,
      'price_col'.tr,
      'qty_col'.tr,
      'total_col'.tr,
    ];

    final Map<int, pw.Alignment> cellAlignments = isArabic ? {
      0: pw.Alignment.centerRight,
      1: pw.Alignment.centerRight,
      2: pw.Alignment.centerLeft,
      3: pw.Alignment.center,
      4: pw.Alignment.centerLeft,
    } : {
      0: pw.Alignment.centerLeft,
      1: pw.Alignment.centerLeft,
      2: pw.Alignment.centerRight,
      3: pw.Alignment.center,
      4: pw.Alignment.centerRight,
    };

    final Map<int, pw.TableColumnWidth> columnWidths = {
      0: const pw.FlexColumnWidth(1.3),
      1: const pw.FlexColumnWidth(4),
      2: const pw.FlexColumnWidth(1.4),
      3: const pw.FlexColumnWidth(0.9),
      4: const pw.FlexColumnWidth(1.4),
    };

    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColor.fromInt(0xFFE3E7EF), width: 1),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(12)),
      ),
      padding: const pw.EdgeInsets.all(4),
      child: pw.TableHelper.fromTextArray(
        border: null,
        columnWidths: columnWidths,
        cellAlignment: isArabic ? pw.Alignment.centerRight : pw.Alignment.centerLeft,
        headerDecoration: pw.BoxDecoration(
          color: baseColor,
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
        ),
        headerHeight: isArabic ? 38 : 32,
        cellHeight: isArabic ? 44 : 36,
        cellAlignments: cellAlignments,
        headerStyle: pw.TextStyle(
          color: PdfColors.white,
          fontSize: isArabic ? 11 : 10,
          fontWeight: pw.FontWeight.bold,
          height: 1.2,
        ),
        cellStyle: pw.TextStyle(
          color: textColor,
          fontSize: isArabic ? 10.5 : 9.5,
          fontWeight: pw.FontWeight.bold,
          lineSpacing: isArabic ? 3 : 1,
          height: isArabic ? 1.3 : 1.1,
        ),
        oddRowDecoration: pw.BoxDecoration(
          color: PdfColor.fromInt(0xFFF7F8FA),
        ),
        rowDecoration: pw.BoxDecoration(
          border: pw.Border(
            bottom: pw.BorderSide(color: PdfColor.fromInt(0xFFEDEFF3), width: .5),
          ),
        ),
        headers: headers,
        data: List<List<String>>.generate(
          products.length,
              (row) => List<String>.generate(
            headers.length,
                (col) => products[row].getIndex(col),
          ),
        ),
      ),
    );
  }
}

// ================================================================
// PRODUCT DATA
// ================================================================

class ProductData {
  const ProductData(
      this.sku,
      this.productName,
      this.price,
      this.quantity,
      this.currencySymbol,
      this.isArabic,
      );

  final String sku;
  final String productName;
  final double price;
  final int quantity;
  final String currencySymbol;
  final bool isArabic;

  double get total => price * quantity;

  String get _fixedCurrency => _fixRtl(currencySymbol, isArabic);

  String getIndex(int index) {
    switch (index) {
      case 0:
        return sku;
      case 1:
        return productName;
      case 2:
        return '${price.toStringAsFixed(2)} $_fixedCurrency';
      case 3:
        return quantity.toString();
      case 4:
        return '${total.toStringAsFixed(2)} $_fixedCurrency';
    }
    return '';
  }
}