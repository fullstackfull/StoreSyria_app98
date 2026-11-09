import 'package:store_go_app/core/model/customer_model.dart';
import 'package:store_go_app/core/model/delivery_boy_model.dart';

/// The two list-card fixtures, in ONE place.
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
