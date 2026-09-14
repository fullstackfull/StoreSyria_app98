import 'package:fluttertoast/fluttertoast.dart';
import '../../utils/colors.dart';
import '../new_widgets/app_snackbar.dart';

// Future<void> commonToast(String msg){
//  return Fluttertoast.showToast(
//       msg:msg,
//       toastLength: Toast.LENGTH_SHORT,
//       gravity: ToastGravity.CENTER,
//       timeInSecForIosWeb: 1,
//       backgroundColor: AppColor.themeNavyBlueColor,
//       textColor: AppColor.cWhiteFont,
//       fontSize: 16.0
//   );
// }

Future<void> commonToast(String msg) async {
 AppSnackBar.success(
  title: msg,
 );
}
//Future<void> commonToast(
//   String msg, {
//   AppSnackBarType type = AppSnackBarType.success,
// }) async {
//   AppSnackBar.show(
//     type: type,
//     title: msg,
//     message: '',
//     duration: const Duration(seconds: 3),
//   );
// }
