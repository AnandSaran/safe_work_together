import 'dart:io';

import 'package:safe_work_together/constants/StringConstants.dart';

extension IntExtension on int{
  String get entryPerDay {
    return EMPLOYEE_PER_DAY_ENTRY +
        WHITE_SPACE +
        SYMBOL_COLON +
        WHITE_SPACE +
        this.toString();
  }
}