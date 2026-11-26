import 'package:store_go_app/core/model/customer_model.dart';
import 'package:store_go_app/core/model/delivery_boy_model.dart';
import 'package:store_go_app/core/model/wallet_model.dart';

/// The list-card fixtures, in ONE place.
/// =================================================================================================
///
/// These lived as private closures inside `test/golden/customer_card_golden_test.dart`. They are
/// shared now because a second file measures the same two cards
/// (`test/ui/card_intrinsic_height_test.dart`), and two copies of a fixture that has ALREADY BEEN
/// WRONG TWICE is how the two files come to measure different widgets while reporting the same
/// name.
///
/// BOTH MISTAKES ARE WORTH KEEPING, because both produced a green run and a wrong picture:
///
///  * `email` and `state_name` SIT AT THE ROOT, NOT INSIDE `customer_info`. `CustomerInfo` carries
///    only name and mobile (`customer_model.dart:130-142`) and the API puts both of these beside
///    that object (`Api/DashboardController.php:6128-6132`). The first version nested `email`, so
///    it was never read — and because the card also bound its e-mail row to `city`, all four
///    customer baselines rendered a literal `--` where the address belongs. Two defects stacked,
///    and only the picture showed them.
///
///  * `contact`, NOT `mobile`, on the delivery man. `DeliveryBoyData.fromJson` reads
///    `json['contact']` (`delivery_boy_model.dart:70`) and `delivery_boy_widget.dart:34` reads
///    `.contact`, falling back to `--`. The first version passed `mobile`, copied from the CUSTOMER
///    model beside it, so the phone row in all four delivery-boy baselines was a blank dash — a
///    baseline that freezes an empty cell where real data belongs, and that a reviewer might well
///    have approved without noticing.
///
/// Arabic names and a Syrian mobile number, because half of the baselines are the Arabic half and
/// Latin placeholder text would not exercise the Tajawal faces or the RTL run at all. Every value
/// is invented: no real customer data goes in a fixture or a screenshot.
CustomerData sampleCustomer() => CustomerData.fromJson(<String, dynamic>{
      'id': 1,
      'customer_info': <String, dynamic>{
        'name': 'أمينة حداد',
        'mobile': '0911222333',
      },
      'email': 'amina@example.test',
      'state_name': 'دمشق',
      'status': 1,
    });

/// See [sampleCustomer] for why `contact` and not `mobile`.
DeliveryBoyData sampleDeliveryBoy() => DeliveryBoyData.fromJson(<String, dynamic>{
      'id': 2,
      'name': 'سامر خليل',
      'email': 'samer@example.test',
      'contact': '0933444555',
      'status': 1,
    });

/// A wallet transaction for the third card this project measures.
///
/// `description` is Arabic with a Latin order reference inside it, which is the real shape on
/// /finance and the one that exercises the bidi run.
WalletTransaction sampleTransaction() => WalletTransaction.fromJson(<String, dynamic>{
      'id': 1,
      'type': 'order',
      'direction': 'credit',
      'amount': '150.00',
      'currency_code': 'SYP',
      'balance_before': '0.00',
      'balance_after': '150.00',
      'description': 'طلب #ORD-2043',
      'status': 'completed',
      'created_at': '2026-11-06 10:00:00',
    });

/// THE OTHER HALF OF THE TRANSACTION CARD, and every value in it drives a different branch.
///
/// `transactionCard` is not one picture: it is a switch with two sides, and [sampleTransaction]
/// exercises only the green one. Four code paths are reachable solely through a DEBIT row with a
/// status that is not `completed`, and none of them had ever been rendered:
///
///  * `tx.isCredit` is false, so `amountColor` becomes `danger` (#EF4444) and the arrow flips from
///    `arrow_downward_rounded` to `arrow_upward_rounded` (`transactions_widget.dart:20`, `:115-117`).
///  * `_iconForType` takes a NAMED case rather than its fallback. `'manual_withdrawal'` returns
///    `Icons.indeterminate_check_box_outlined` (`:207`); `'order'` on the credit fixture falls
///    through to the default and draws the same arrow twice.
///  * `_formatType` is handed a SNAKE_CASE type, which is the real shape on the wire — every value
///    its sibling `_iconForType` switches on has an underscore in it. `'order'` cannot show that
///    the split-capitalise-rejoin produces "Manual Withdrawal".
///  * `_statusBadge` takes its `else` branch, which prints **`status` raw and untranslated**
///    (`:189`) rather than `'completed'.tr`, and paints `warning` instead of `success`.
///
/// `'pending'` IS A REAL HOST VALUE and is deliberately a word that also exists as a translation
/// key: if a future repair routes this through `.tr` the picture changes from `pending` to
/// `قيد الانتظار` in the Arabic baselines, and the diff says so.
///
/// The description is plain Arabic with no Latin run, as a CONTROL for the credit fixture's
/// `طلب #ORD-2043`: the two rows in one image show the bidi reorder happening to one of them and
/// not the other, which is what makes it legible as a defect rather than as a font oddity.
/// Invented values throughout: no real merchant data goes in a fixture or a screenshot.
WalletTransaction sampleWithdrawalTransaction() => WalletTransaction.fromJson(<String, dynamic>{
      'id': 2,
      'type': 'manual_withdrawal',
      'direction': 'debit',
      'amount': '75.50',
      'currency_code': 'SYP',
      'balance_before': '150.00',
      'balance_after': '74.50',
      'description': 'سحب يدوي من المحفظة',
      'status': 'pending',
      'created_at': '2026-11-07 16:45:00',
    });
