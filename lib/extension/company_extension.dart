import 'package:safe_work_together/constants/StringConstants.dart';
import 'package:safe_work_together/src/model/company.dart';

extension CompanyExtension on Company{
  String get compoundName{
   return name +
        WHITE_SPACE +
        HYPHEN +
        WHITE_SPACE +
       country.name;
  }
}