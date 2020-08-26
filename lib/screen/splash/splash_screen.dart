import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:safe_work_together/constants/NavigatorConstants.dart';
import 'package:safe_work_together/constants/sharedprefkey.dart';
import 'package:safe_work_together/util/Navigation.dart';
import 'package:safe_work_together/util/sharedpreference.dart';

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SharedPreferenceUtil().init();
    showUserLoginScreen(context);
    return Column();
  }

  void showUserLoginScreen(BuildContext context) {
    Timer(Duration(seconds: 3), () {
      if (SharedPreferenceUtil().getString(SHARED_PREF_KEY_COMPANY_ID).isNotEmpty) {
        Navigation().pushPage(context, ROUTE_COMPANY_HOME, isToReplace: true);
      } else if (SharedPreferenceUtil().getString(SHARED_PREF_KEY_EMPLOYEE_ID).isNotEmpty) {
        Navigation().pushPage(context, ROUTE_EMPLOYEE_HOME, isToReplace: true);
      } else {
        Navigation().pushPage(context, ROUTE_LOGIN_EMPLOYEE, isToReplace: true);
      }
    });
  }
}
