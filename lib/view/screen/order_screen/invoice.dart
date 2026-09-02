// ignore_for_file: prefer_const_constructors, avoid_print

import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:get/get.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:store_go_app/utils/helper.dart';
import 'package:store_go_app/utils/images.dart';

import '../../../core/model/order_detail_model.dart';

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
    ) async {
  final products = <ProductData>[];

  for (final product in productList) {
    products.add(
      ProductData(
        product.productId?.toString() ?? '',
        product.name?.toString() ?? '',
        double.tryParse(product.finalPrice?.toString() ?? '0') ?? 0,
        int.tryParse(product.qty?.toString() ?? '0') ?? 0,
      ),
    );
  }

  final PdfColor brandPrimary = PdfColor.fromInt(0xFF172C4E);
  final PdfColor brandAccent = PdfColor.fromInt(0xFF172C4E);
  final PdfColor textDark = PdfColor.fromInt(0xFF1E222B);
  final PdfColor textGrey = PdfColor.fromInt(0xFF66728C);

  // تحديد ما إذا كانت اللغة عربية لضبط الاتجاهات
  final bool isArabic = Get.locale?.languageCode == 'ar';

  final invoice = Invoice(
    invoiceNumber: orderDetailData.orderId?.toString() ?? '',
    products: products,
    customerName: orderDetailData.billingInformations?.name?.toString() ?? '',
    customerAddress:
    "${orderDetailData.deliveryInformations?.city?.toString() ?? ''}, "
        "${orderDetailData.deliveryInformations?.state?.toString() ?? ''}, "
        "${orderDetailData.deliveryInformations?.country?.toString() ?? ''}, "
        "${orderDetailData.deliveryInformations?.postCode?.toString() ?? ''}",
    paymentInfo: orderDetailData.paymnetType?.toString() ?? '',
    tax: double.tryParse(tax) ?? 0,
    baseColor: brandPrimary,
    accentColor: brandAccent,
    textColor: textDark,
    subTextColor: textGrey,
    deliveryCharge: deliveryCharge,
    couponAmount: couponAmount,
    isArabic: isArabic, // تمرير حالة اللغة
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
  });

  final List<ProductData> products;
  final String customerName;
  final String customerAddress;
  final String invoiceNumber;
  final double tax;
  final double deliveryCharge;
  final double couponAmount;
  final String paymentInfo;
  final bool isArabic; // متغير لتحديد اللغة

  final PdfColor baseColor;
  final PdfColor accentColor;
  final PdfColor textColor;
  final PdfColor subTextColor;

  double get _total {
    if (products.isEmpty) return 0;
    return products.map<double>((product) => product.total).reduce((a, b) => a + b);
  }

  double get _grandTotal => _total + tax + deliveryCharge - couponAmount;

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

    // ضبط اتجاه الصفحة بناءً على اللغة
    final textDirection = isArabic ? pw.TextDirection.rtl : pw.TextDirection.ltr;

    doc.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          pageFormat: pageFormat,
          theme: theme,
          margin: const pw.EdgeInsets.all(20),
          textDirection: textDirection,
        ),
        header: _buildHeader,
        footer: _buildFooter,
        build: (context) => [
          _contentHeader(context),
          pw.SizedBox(height: 25),
          _contentTable(context),
          pw.SizedBox(height: 30),
          _contentFooter(context),
          pw.SizedBox(height: 25),
          _termsAndConditions(context),
        ],
      ),
    );

    return doc.save();
  }

  // ============================================================
  // HEADER (Modified to align Title and Logo on same line properly)
  // ============================================================

  pw.Widget _buildHeader(pw.Context context) {
    return pw.Column(
      children: [
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.center, // محاذاة عمودية في المنتصف
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, // توزيع المسافة بين الطرفين
          children: [
            // القسم الأول: عنوان الفاتورة ورقمها
            pw.Column(
              crossAxisAlignment: isArabic
                  ? pw.CrossAxisAlignment.end   // عربي: النص يحاذي اليسار (نهاية السطر)
                  : pw.CrossAxisAlignment.start, // إنجليزي: النص يحاذي اليسار (بداية السطر)
              mainAxisSize: pw.MainAxisSize.min,
              children: [
                pw.Text(
                  'invoice_title'.tr.toUpperCase(),
                  style: pw.TextStyle(
                    color: baseColor,
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 28, // حجم مناسب للعنوان
                  ),
                ),
                pw.SizedBox(height: 5),
                pw.Text(
                  invoiceNumber,
                  style: pw.TextStyle(
                    color: subTextColor,
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ],
            ),

            // القسم الثاني: الشعار واسم المتجر
            pw.Column(
              mainAxisSize: pw.MainAxisSize.min,
              children: [
                if (_logo != null)
                  pw.Container(
                    height: 60,
                    width: 60,
                    child: pw.SvgImage(svg: _logo!),
                  )
                else
                  pw.SizedBox(height: 60),

                pw.SizedBox(height: 5),

                pw.Text(
                  "Store Syria",
                  textAlign: pw.TextAlign.center,
                  style: pw.TextStyle(
                    color: baseColor,
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),

        pw.SizedBox(height: 15),

        // الخط الفاصل
        pw.Container(height: 2.5, width: double.infinity, color: accentColor),

        pw.SizedBox(height: 15),
      ],
    );
  }

  // ============================================================
  // FOOTER
  // ============================================================

  pw.Widget _buildFooter(pw.Context context) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          'generated_by'.tr,
          style: pw.TextStyle(
            fontSize: 10,
            color: subTextColor,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.Text(
          '${'page_label'.tr} ${context.pageNumber}/${context.pagesCount}',
          style: pw.TextStyle(
            fontSize: 10,
            color: baseColor,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // CUSTOMER INFORMATION
  // ============================================================

  pw.Widget _contentHeader(pw.Context context) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // معلومات العميل
        pw.Expanded(
          flex: 2,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'bill_to'.tr,
                style: pw.TextStyle(
                  color: accentColor,
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              pw.SizedBox(height: 7),
              pw.Text(
                customerName,
                style: pw.TextStyle(
                  color: textColor,
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              pw.SizedBox(height: 5),
              pw.Text(
                customerAddress,
                textAlign: isArabic
                    ? pw.TextAlign.right
                    : pw.TextAlign.left,
                style: pw.TextStyle(
                  color: subTextColor,
                  fontSize: isArabic ? 12 : 11,
                  fontWeight: pw.FontWeight.bold,
                  lineSpacing: isArabic ? 6 : 3,
                  height: isArabic ? 1.45 : 1.2,
                ),
              ),
            ],
          ),
        ),

        pw.SizedBox(width: 15),

        // معلومات التاريخ والدفع
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
    );
  }

  // ============================================================
  // INFO ROW
  // ============================================================

  pw.Widget _infoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 9),
      child: pw.Container(
        width: double.infinity,
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.end,
          children: [
            pw.Text(
              '$label: ',
              textAlign: isArabic
                  ? pw.TextAlign.right
                  : pw.TextAlign.left,
              style: pw.TextStyle(
                color: subTextColor,
                fontSize: isArabic ? 11 : 10,
                fontWeight: pw.FontWeight.bold,
                height: isArabic ? 1.3 : 1.1,
              ),
            ),
            pw.Text(
              value,
              textAlign: isArabic
                  ? pw.TextAlign.right
                  : pw.TextAlign.left,
              style: pw.TextStyle(
                color: textColor,
                fontSize: isArabic ? 11 : 10,
                fontWeight: pw.FontWeight.bold,
                height: isArabic ? 1.3 : 1.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
  // ============================================================
  // BOTTOM CONTENT
  // ============================================================

  pw.Widget _contentFooter(pw.Context context) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // رسالة الشكر
        pw.Expanded(
          flex: 3,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start, // ثابتة دائمًا - تحاذي الحافة الخارجية (يمين بالعربي بفضل RTL)
            children: [
              pw.Text(
                'thank_you_msg'.tr,
                textAlign: isArabic ? pw.TextAlign.right : pw.TextAlign.left,
                style: pw.TextStyle(
                  color: baseColor,
                  fontWeight: pw.FontWeight.bold,
                  fontSize: isArabic ? 14 : 13,
                  height: isArabic ? 1.4 : 1.2,
                ),
              ),
              pw.SizedBox(height: 7),
              pw.Text(
                'support_msg'.tr,
                textAlign: isArabic ? pw.TextAlign.right : pw.TextAlign.left,
                style: pw.TextStyle(
                  fontSize: isArabic ? 11.5 : 10,
                  color: subTextColor,
                  fontWeight: pw.FontWeight.bold,
                  lineSpacing: isArabic ? 6 : 2,
                  height: isArabic ? 1.45 : 1.2,
                ),
              ),
            ],
          ),
        ),

        pw.SizedBox(width: 15), // فراغ فاصل حقيقي بين العمودين

        // الإجماليات
        pw.Expanded(
          flex: 2,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end, // ثابتة دائمًا - تحاذي الحافة الخارجية (يسار بالعربي بفضل RTL)
            children: [
              _totalRow('sub_total'.tr, _total),
              _totalRow('delivery'.tr, deliveryCharge),
              if (couponAmount > 0)
                _totalRow('coupon'.tr, -couponAmount, isNegative: true),
              _totalRow('tax'.tr, tax),
              pw.SizedBox(height: 4),
              pw.Divider(color: baseColor, thickness: 1.5),
              pw.SizedBox(height: 3),
              _totalRow('grand_total'.tr, _grandTotal, isGrand: true),
            ],
          ),
        ),
      ],
    );
  }
  // ============================================================
  // TOTAL ROW
  // ============================================================

  pw.Widget _totalRow(String label, double amount, {bool isGrand = false, bool isNegative = false}) {
    final String formattedAmount = isNegative
        ? "- \$${amount.abs().toStringAsFixed(2)}"
        : "\$${amount.toStringAsFixed(2)}";

    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 3),
      child: pw.Container(
        width: double.infinity, // يجبر الـ Row ياخد كل عرض العمود
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              label,
              style: pw.TextStyle(
                color: isGrand ? baseColor : subTextColor,
                fontWeight: pw.FontWeight.bold,
                fontSize: isGrand ? 14 : 10,
                height: isArabic ? 1.3 : 1.1,
              ),
            ),
            pw.Text(
              formattedAmount,
              style: pw.TextStyle(
                color: isGrand ? baseColor : textColor,
                fontWeight: pw.FontWeight.bold,
                fontSize: isGrand ? 14 : 10,
                height: isArabic ? 1.3 : 1.1,
              ),
            ),
          ],
        ),
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
        pw.Divider(color: accentColor, thickness: 1),
        pw.SizedBox(height: 7),
        pw.Text(
          'terms_title'.tr,
          style: pw.TextStyle(
            fontSize: 12,
            color: baseColor,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 5),
        pw.Text(
          'terms_text'.tr,
          textAlign: isArabic
              ? pw.TextAlign.right
              : pw.TextAlign.justify,
          style: pw.TextStyle(
            fontSize: isArabic ? 11.5 : 10,
            color: subTextColor,
            fontWeight: pw.FontWeight.bold,
            lineSpacing: isArabic ? 6 : 2,
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

    // ضبط محاذاة الخلايا بناءً على اللغة
    final Map<int, pw.Alignment> cellAlignments = isArabic ? {
      0: pw.Alignment.centerRight, // SKU
      1: pw.Alignment.centerRight, // Description
      2: pw.Alignment.centerLeft,  // Price
      3: pw.Alignment.center,      // Qty
      4: pw.Alignment.centerLeft,  // Total
    } : {
      0: pw.Alignment.centerLeft,
      1: pw.Alignment.centerLeft,
      2: pw.Alignment.centerRight,
      3: pw.Alignment.center,
      4: pw.Alignment.centerRight,
    };

    // نسب عرض كل عمود (فليكس) — الوصف ياخد أكبر مساحة، وباقي الأعمدة أضيق
    final Map<int, pw.TableColumnWidth> columnWidths = {
      0: const pw.FlexColumnWidth(1.3), // رمز المنتج
      1: const pw.FlexColumnWidth(4),   // الوصف — الأكبر، بيلف سطور لو طويل
      2: const pw.FlexColumnWidth(1.4), // السعر
      3: const pw.FlexColumnWidth(0.9), // الكمية
      4: const pw.FlexColumnWidth(1.4), // الإجمالي
    };

    return pw.TableHelper.fromTextArray(
      border: null,
      columnWidths: columnWidths,
      cellAlignment: isArabic ? pw.Alignment.centerRight : pw.Alignment.centerLeft,
      headerDecoration: pw.BoxDecoration(
        color: baseColor,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
      ),
      headerHeight: isArabic ? 40 : 32,
      cellHeight: isArabic ? 48 : 38, // هاد حد أدنى فقط — الصف بيكبر تلقائياً لو النص لف أكتر من سطر
      cellAlignments: cellAlignments,
      headerStyle: pw.TextStyle(
        color: PdfColors.white,
        fontSize: isArabic ? 12 : 11,
        fontWeight: pw.FontWeight.bold,
        height: 1.2,
      ),
      cellStyle: pw.TextStyle(
        color: textColor,
        fontSize: isArabic ? 11 : 10,
        fontWeight: pw.FontWeight.bold,
        lineSpacing: isArabic ? 3 : 1,
        height: isArabic ? 1.3 : 1.1,
      ),
      rowDecoration: pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(color: subTextColor, width: .5),
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
    );
  }
}

// ================================================================
// PRODUCT DATA
// ================================================================

class ProductData {
  const ProductData(this.sku, this.productName, this.price, this.quantity);

  final String sku;
  final String productName;
  final double price;
  final int quantity;

  double get total => price * quantity;

  String getIndex(int index) {
    switch (index) {
      case 0:
        return sku;
      case 1:
        return productName;
      case 2:
        return '\$${price.toStringAsFixed(2)}';
      case 3:
        return quantity.toString();
      case 4:
        return '\$${total.toStringAsFixed(2)}';
    }
    return '';
  }
}