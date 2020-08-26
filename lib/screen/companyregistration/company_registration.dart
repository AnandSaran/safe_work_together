
import 'package:flutter/material.dart';
import 'package:safe_work_together/constants/StringConstants.dart';

import 'components/body.dart';
import 'package:safe_work_together/style/theme.dart' as Theme;

class CompanyRegistrationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Body(),
      appBar: AppBar(
        title:  Text(TITTLE_REGISTRATION),
        backgroundColor: Theme.Colors.homeNavigationBarBackgroundColor,
      ),
    );
  }
}