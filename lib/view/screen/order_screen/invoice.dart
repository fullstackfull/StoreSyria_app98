// ignore_for_file: prefer_const_constructors, avoid_print

import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:get/get.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
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
    double couponAmount) async {

  final products = <ProductData>[];
  productList.forEach((data) {
    products.add(ProductData(
        data.productId.toString(),
        data.name!,
        double.parse(data.finalPrice.toString()),
        int.parse(data.qty.toString())));
  });

  final PdfColor brandPrimary = PdfColor.fromInt(0xFF172C4E);
  final PdfColor brandAccent = PdfColor.fromInt(0xFF172C4E);
  final PdfColor textDark = PdfColor.fromInt(0xFF1E222B);
  final PdfColor textGrey = PdfColor.fromInt(0xFF66728c);

  final invoice = Invoice(
      invoiceNumber: orderDetailData.orderId!,
      products: products,
      customerName: orderDetailData.billingInformations!.name!,
      customerAddress:
      "${orderDetailData.deliveryInformations!.city!}, ${orderDetailData.deliveryInformations!.state!}, ${orderDetailData.deliveryInformations!.country!}, ${orderDetailData.deliveryInformations!.postCode!}",
      paymentInfo: orderDetailData.paymnetType!,
      tax: double.parse(tax),
      baseColor: brandPrimary,
      accentColor: brandAccent,
      textColor: textDark,
      subTextColor: textGrey,
      deliveryCharge: deliveryCharge,
      couponAmount: couponAmount);

  return await invoice.buildPdf(pageFormat);
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
  });

  final List<ProductData> products;
  final String customerName;
  final String customerAddress;
  final String invoiceNumber;
  final double tax;
  final double deliveryCharge;
  final double couponAmount;
  final String paymentInfo;

  final PdfColor baseColor;
  final PdfColor accentColor;
  final PdfColor textColor;
  final PdfColor subTextColor;

  double get _total =>
      products.map<double>((p) => p.total).reduce((a, b) => a + b);

  double get _grandTotal => _total + tax + deliveryCharge - couponAmount;

  String? _logo;

  Future<Uint8List> buildPdf(PdfPageFormat pageFormat) async {
    final doc = pw.Document();

    try {
      _logo = await rootBundle.loadString(DefaultImages.sLogoIcn);
    } catch (e) {
      _logo = null;
    }

    doc.addPage(
      pw.MultiPage(
        pageTheme: _buildTheme(
          pageFormat,
          await PdfGoogleFonts.robotoRegular(),
          await PdfGoogleFonts.robotoBold(),
          await PdfGoogleFonts.robotoItalic(),
        ),
        header: _buildHeader,
        footer: _buildFooter,
        build: (context) => [
          _contentHeader(context),
          pw.SizedBox(height: 20),
          _contentTable(context),
          pw.SizedBox(height: 30),
          _contentFooter(context),
          pw.SizedBox(height: 20),
          _termsAndConditions(context),
        ],
      ),
    );

    return doc.save();
  }

  pw.Widget _buildHeader(pw.Context context) {
    return pw.Column(
      children: [
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'invoice_title'.tr.toUpperCase(),
                    style: pw.TextStyle(
                      color: baseColor,
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 28,
                    ),
                  ),
                  pw.SizedBox(height: 5),
                  pw.Text(
                    invoiceNumber,
                    style: pw.TextStyle(
                      color: subTextColor,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
            pw.Expanded(
              child: pw.Column(
                mainAxisSize: pw.MainAxisSize.min,
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Container(
                    alignment: pw.Alignment.center,
                    width: 100,
                    child: pw.Column(
                      mainAxisSize: pw.MainAxisSize.min,
                      children: [
                        if (_logo != null)
                          pw.Container(
                            height: 50,
                            width: 50,
                            child: pw.SvgImage(svg: _logo!),
                          )
                        else
                          pw.SizedBox(height: 50),

                        pw.SizedBox(height: 5),

                        pw.Text(
                          "Store Syria",
                          textAlign: pw.TextAlign.center,
                          style: pw.TextStyle(
                              color: baseColor,
                              fontSize: 14,
                              fontWeight: pw.FontWeight.bold
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 15),
        pw.Container(
          height: 2,
          width: double.infinity,
          color: accentColor,
        ),
        pw.SizedBox(height: 15),
      ],
    );
  }

  pw.Widget _buildFooter(pw.Context context) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          'generated_by'.tr,
          style: pw.TextStyle(fontSize: 8, color: subTextColor),
        ),
        pw.Text(
          '${'page_label'.tr} ${context.pageNumber}/${context.pagesCount}',
          style: pw.TextStyle(fontSize: 8, color: baseColor),
        ),
      ],
    );
  }

  pw.PageTheme _buildTheme(
      PdfPageFormat pageFormat, pw.Font base, pw.Font bold, pw.Font italic) {
    return pw.PageTheme(
      pageFormat: pageFormat,
      theme: pw.ThemeData.withFont(
        base: base,
        bold: bold,
        italic: italic,
      ),
      margin: pw.EdgeInsets.all(20),
    );
  }

  pw.Widget _contentHeader(pw.Context context) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
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
                  fontSize: 10,
                ),
              ),
              pw.SizedBox(height: 5),
              pw.Text(
                customerName,
                style: pw.TextStyle(
                  color: textColor,
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              pw.SizedBox(height: 3),
              pw.Text(
                customerAddress,
                style: pw.TextStyle(
                  color: subTextColor,
                  fontSize: 9,
                  lineSpacing: 2,
                ),
              ),
            ],
          ),
        ),

        pw.Expanded(
          flex: 1,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              _infoRow('date_label'.tr, dateFormatted(
                  date: DateTime.now().toString(),
                  formatType: formatForDateTime(FormatType.date))),
              _infoRow('payment_method'.tr, paymentInfo),
            ],
          ),
        ),
      ],
    );
  }

  pw.Widget _infoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.end,
        children: [
          pw.Text('$label: ', style: pw.TextStyle(color: subTextColor, fontSize: 9)),
          pw.Text(value, style: pw.TextStyle(color: textColor, fontWeight: pw.FontWeight.bold, fontSize: 9)),
        ],
      ),
    );
  }

  pw.Widget _contentFooter(pw.Context context) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(
          flex: 2,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'thank_you_msg'.tr,
                style: pw.TextStyle(
                  color: baseColor,
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 11,
                ),
              ),
              pw.SizedBox(height: 5),
              pw.Text(
                'support_msg'.tr,
                style: pw.TextStyle(fontSize: 8, color: subTextColor),
              ),
            ],
          ),
        ),
        pw.Expanded(
          flex: 1,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _totalRow('sub_total'.tr, _total),
              _totalRow('delivery'.tr, deliveryCharge),
              if (couponAmount > 0) _totalRow('coupon'.tr, -couponAmount, isNegative: true),
              _totalRow('tax'.tr, tax),
              pw.Divider(color: baseColor, thickness: 1),
              _totalRow('grand_total'.tr, _grandTotal, isGrand: true),
            ],
          ),
        ),
      ],
    );
  }

  pw.Widget _totalRow(String label, double amount, {bool isGrand = false, bool isNegative = false}) {
    String formattedAmount = isNegative ? "- \$${amount.abs().toStringAsFixed(2)}" : "\$${amount.toStringAsFixed(2)}";

    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              color: isGrand ? baseColor : subTextColor,
              fontWeight: isGrand ? pw.FontWeight.bold : pw.FontWeight.normal,
              fontSize: isGrand ? 12 : 9,
            ),
          ),
          pw.Text(
            formattedAmount,
            style: pw.TextStyle(
              color: isGrand ? baseColor : textColor,
              fontWeight: isGrand ? pw.FontWeight.bold : pw.FontWeight.normal,
              fontSize: isGrand ? 12 : 9,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _termsAndConditions(pw.Context context) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Divider(color: accentColor, thickness: 1),
        pw.SizedBox(height: 5),
        pw.Text(
          'terms_title'.tr,
          style: pw.TextStyle(
            fontSize: 10,
            color: baseColor,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 3),
        pw.Text(
          'terms_text'.tr,
          textAlign: pw.TextAlign.justify,
          style: pw.TextStyle(
            fontSize: 8,
            color: subTextColor,
          ),
        ),
      ],
    );
  }

  pw.Widget _contentTable(pw.Context context) {
    final headers = [
      'sku_col'.tr,
      'desc_col'.tr,
      'price_col'.tr,
      'qty_col'.tr,
      'total_col'.tr
    ];

    return pw.TableHelper.fromTextArray(
      border: null,
      cellAlignment: pw.Alignment.centerLeft,
      headerDecoration: pw.BoxDecoration(
        color: baseColor,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
      ),
      headerHeight: 25,
      cellHeight: 30,
      cellAlignments: {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.centerLeft,
        2: pw.Alignment.centerRight,
        3: pw.Alignment.center,
        4: pw.Alignment.centerRight,
      },
      headerStyle: pw.TextStyle(
        color: PdfColors.white,
        fontSize: 9,
        fontWeight: pw.FontWeight.bold,
      ),
      cellStyle: pw.TextStyle(
        color: textColor,
        fontSize: 8,
      ),
      rowDecoration: pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(
            color: subTextColor,
            width: .5,
          ),
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

class ProductData {
  const ProductData(
      this.sku,
      this.productName,
      this.price,
      this.quantity,
      );

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