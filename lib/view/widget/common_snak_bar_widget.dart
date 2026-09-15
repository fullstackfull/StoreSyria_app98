import 'package:store_go_app/view/new_widgets/app_snackbar.dart';


enum AppSnackBarType {
 success,
 error,
 warning,
 info,
}

void commonToast(
    String msg, {
     AppSnackBarType type = AppSnackBarType.success,
    }) {
 switch (type) {
  case AppSnackBarType.success:
   AppSnackBar.success(
    title: msg,
    message: '',
   );
   break;

  case AppSnackBarType.error:
   AppSnackBar.error(
    title: msg,
    message: '',
   );
   break;

  case AppSnackBarType.warning:
   AppSnackBar.warning(
    title: msg,
    message: '',
   );
   break;

  case AppSnackBarType.info:
   AppSnackBar.info(
    title: msg,
    message: '',
   );
   break;
 }
}