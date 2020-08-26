import 'package:safe_work_together/src/model/company.dart';
import 'package:safe_work_together/src/model/models.dart';

abstract class EmployeeRepositoryAbstract{

  Future<void> addEmployee(Employee employee);

  Future<void> deleteEmployee(String employeeId);

  Future<dynamic> isEmployeeNotRegistered(Employee employee,String licenceNumber);

}