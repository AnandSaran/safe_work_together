import 'package:safe_work_together/constants/StringConstants.dart';
import 'package:safe_work_together/src/model/company.dart';
import 'package:safe_work_together/src/model/employee.dart';

extension EmployeeExtension on Employee{
  String get compoundName{
   return   HELLO + WHITE_SPACE + employeeName + SYMBOL_COMMA;
  }
}