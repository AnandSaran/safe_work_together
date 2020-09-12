import 'dart:io';

import 'package:safe_work_together/constants/StringConstants.dart';

extension DoubleExtension on double {
  String get getTempSymbol {
    var tempSymbol =
        this.toString() + WHITE_SPACE + (this < 50 ? SYMBOL_CELSIUS : SYMBOL_FAHRENHEIT);
    return tempSymbol;
  }
}
