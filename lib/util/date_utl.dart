import 'package:safe_work_together/constants/StringConstants.dart';

class DateUtil {
  static final DateUtil _navigation = DateUtil._internal();

  factory DateUtil() {
    return _navigation;
  }

  DateUtil._internal();

  String generateGreeting() {
    var hour = DateTime
        .now()
        .hour;
    var session;
    if (hour < 12) {
      session = MORNING;
    }
    if (hour < 17) {
      session = AFTERNOON;
    } else {
      session = EVENING;
    }

    return GOOD + WHITE_SPACE + session + SYMBOL_EXCELEMETRY;
  }
}