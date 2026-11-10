import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:store_go_app/core/model/order_detail_model.dart';
import 'package:store_go_app/view/screen/order_screen/invoice_pdf_view.dart';

import '../support/golden_harness.dart';
import '../support/nested_fixtures.dart';
import '../support/screen_harness.dart';

/// P2.5-FLUTTER-INVOICE — the invoice viewer.
/// =================================================================================================
///
/// **THE PDF ITSELF CANNOT BE CAPTURED HERE, AND THAT IS MEASURED, NOT ASSUMED.** Driven in all
/// four combinations the screen throws nothing and renders its chrome, but the body is the
/// `loadingWidget` shimmer and the whole screen holds **two** `Text` widgets. `PdfPreview`
/// rasterises through the `printing` plugin's platform channel (`Printing.info()` at
/// invoice_pdf_view.dart:51), which a widget test does not provide, so the preview never
/// resolves. A capture of that is a picture of a placeholder, and photographing it four times
/// would be coverage without evidence.
///
/// The row is therefore BLOCKED on a device or emulator rather than PENDING on a design pass —
/// recorded with that reason in the coverage matrix.
///
/// **WHAT THE CHROME DID SHOW WAS WORTH THE TRIP.** The page-format control read `Letter` — the
/// US paper size — to an Arabic merchant, while the screen's own loading placeholder is built at
/// `aspectRatio: 1 / 1.414`, with the comment `// A4`, two lines above (:112). `PdfPreview` was
/// given no `initialPageFormat`, so it fell back to the package default. Syria, like the rest of
/// the region, uses A4; an invoice that prints at Letter is cropped or margined wrongly on every
/// sheet a merchant feeds it.
///
/// This test pins the format rather than the picture, because the format is the part a widget
/// test can actually see.
void main() {
  setUpAll(initScreenHarness);
  tearDownAll(disposeScreenHarness);
  tearDown(resetScreenHarness);

  OrderDetailData buildOrderDetail() {
    final model = OrderDetailModel.fromJson(orderDetailResponse());
    return model.data!;
  }

  Widget invoice(OrderDetailData detail) => InvoicePdfViewScreen(
        productList: detail.product ?? const <Product>[],
        orderDetailData: detail,
        tax: '15',
        deliveryCharge: 5,
        couponAmount: 0,
      );

  for (final combination in kFourCombinations) {
    testWidgets('the invoice viewer builds its chrome in ${combination.name}', (tester) async {
      final detail = buildOrderDetail();

      await pumpScreen(
        tester,
        Builder(builder: (_) => invoice(detail)),
        api: ApiStub(),
        combination: combination,
      );

      await pumpFrames(tester, frames: 20);
      await drainToasts(tester);

      expect(tester.takeException(), isNull,
          reason: 'the invoice viewer threw in ${combination.name}');

      final context = tester.element(find.byType(InvoicePdfViewScreen));
      expect(Directionality.of(context), combination.direction,
          reason: 'the invoice viewer rendered the wrong direction in ${combination.name}');

      expect(find.byType(PdfPreview), findsOneWidget,
          reason: 'the invoice viewer no longer builds a PdfPreview in ${combination.name}');

      // DELIBERATELY NOT CAPTURED HERE, and that is the finding rather than a gap.
      //
      // `captureScreen` runs inside `tester.runAsync`, which lets the real plugin call proceed
      // instead of hanging on the fake clock -- so capturing is the only point at which the
      // missing platform channel surfaces:
      //
      //   MissingPluginException(No implementation found for method rasterPdf
      //                          on channel net.nfet.printing)
      //
      // It is raised ASYNCHRONOUSLY, after the test body returns, so no amount of
      // `takeException()` draining inside the body reaches it -- measured: draining eight frames
      // still left light-ltr failing at teardown while the other three passed, which is a flaky
      // test dressed up as a limitation. Four documenting captures were taken in a one-off run
      // and live in evidence/flutter-invoice-2026-11-10/after/; they show the chrome around a
      // shimmer, which is exactly why the coverage matrix calls this row BLOCKED rather than
      // PENDING. Capturing it for real needs a device or emulator.

    });
  }

  testWidgets('the invoice previews at A4, not US Letter', (tester) async {
    final detail = buildOrderDetail();

    await pumpScreen(
      tester,
      Builder(builder: (_) => invoice(detail)),
      api: ApiStub(),
      combination: kFourCombinations.first,
    );

    await pumpFrames(tester, frames: 20);

    final PdfPreview preview = tester.widget<PdfPreview>(find.byType(PdfPreview));

    expect(preview.initialPageFormat, isNotNull,
        reason: 'PdfPreview was given no initialPageFormat, so it falls back to the printing '
            "package's own default. MEASURED before this was pinned: the format control read "
            '"Letter" -- the US paper size -- in the Arabic capture, while this screen\'s own '
            'loading placeholder is built at aspectRatio 1 / 1.414 with the comment "// A4" '
            '(invoice_pdf_view.dart:112). Syria uses A4.');

    expect(preview.initialPageFormat, equals(PdfPageFormat.a4),
        reason: 'the invoice must preview and print at A4. It opened at '
            '${preview.initialPageFormat}, which is not the paper this market uses.');
  });
}
