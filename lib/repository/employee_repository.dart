import 'dart:collection';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:safe_work_together/constants/fire_store_key.dart';
import 'package:safe_work_together/constants/sharedprefkey.dart';
import 'package:safe_work_together/constants/fire_store_collection.dart';
import 'package:safe_work_together/repository/abstract/abstract_repository.dart';
import 'package:safe_work_together/repository/company_repository.dart';
import 'package:safe_work_together/src/model/company.dart';
import 'package:safe_work_together/src/model/models.dart';
import 'package:safe_work_together/util/sharedpreference.dart';

import 'abstract/employee_repository.dart';

class EmployeeRepository implements EmployeeRepositoryAbstract {
  final _employeeCollection = Firestore.instance.collection(COL_EMPLOYEE);
  List<DocumentSnapshot> employeeListDocumentSnapshot = List();
  List<Employee> employeeList = List();

  @override
  Future<void> deleteEmployee(String documentId) {
    return _employeeCollection.document(documentId).delete();
  }

  @override
  Future<bool> addEmployee(Employee employee) async {
    return _employeeCollection.add(employee.toJson()).then((value) {
      print("Employee created");
      return true;
    }).catchError((error) {
      print("Failed to add employee: $error");
      return false;
    });
  }

  @override
  Future<bool> isEmployeeNotRegistered(
      Employee employee, String employerId) async {
    final QuerySnapshot result = await _employeeCollection
        .where(FS_KEY_EMPLOYEE_ID, isEqualTo: employee.employeeId)
        .where(FS_KEY_EMPLOYER_ID, isEqualTo: employerId)
        .getDocuments();
    final List<DocumentSnapshot> docs = result.documents;
    if (docs.length == 0) {
      return true;
    } else {
      SharedPreferenceUtil()
          .containsKey(SHARED_PREF_KEY_COMPANY_ID)
          .asStream()
          .listen((event) {
        if (!event) {
          SharedPreferenceUtil()
              .setString(SHARED_PREF_KEY_EMPLOYEE_ID, docs[0].documentID);
        }
      });
      return false;
    }
  }

  Future<List<Employee>> fetchFirstList() async {
    var employerId=SharedPreferenceUtil().getString(SHARED_PREF_KEY_COMPANY_ID);
    try {
      clearEmployeeList();
      final QuerySnapshot result=(await _employeeCollection
          .orderBy(FS_KEY_EMPLOYEE_NAME)
          .where(FS_KEY_EMPLOYER_ID, isEqualTo: employerId)
          .limit(10)
          .getDocuments());
      employeeListDocumentSnapshot = result.documents;
      employeeList.addAll(employeeListDocumentSnapshot.map((e) {
        var employee = Employee.fromJson(e.data);
        return employee;
      }));
      return employeeList;
    } catch (e) {
      print(e.toString());
      return employeeList;
    }
  }

  void clearEmployeeList() {
    employeeListDocumentSnapshot.clear();
    employeeList.clear();
  }

  Future<List<Employee>> fetchNextEmployeeList() async {
    var employerId=SharedPreferenceUtil().getString(SHARED_PREF_KEY_COMPANY_ID);

    try {
      List<DocumentSnapshot> newDocumentList = (await _employeeCollection
              .orderBy(FS_KEY_EMPLOYEE_NAME)
          .where(FS_KEY_EMPLOYER_ID, isEqualTo: employerId)
          .startAfterDocument(employeeListDocumentSnapshot[
                  employeeListDocumentSnapshot.length - 1])
              .limit(10)
              .getDocuments())
          .documents;

      employeeListDocumentSnapshot.addAll(newDocumentList);
      employeeList.addAll(newDocumentList.map((e) {
        var employee = Employee.fromJson(e.data);
        return employee;
      }));
      return employeeList;
    } catch (e) {
      print(e.toString());
      return employeeList;
    }
  }

  Future<void> updateEmployeeMobileNumber(String mobileNumber) async {
    Map<String, String> mobile = {FS_KEY_MOBILE_NUMBER: mobileNumber};
    await (_employeeCollection
        .document(SharedPreferenceUtil().getString(SHARED_PREF_KEY_EMPLOYEE_ID))
        .updateData(mobile));
  }

  Future<Employee> fetchEmployee() async {
    final DocumentSnapshot result = await (_employeeCollection
        .document(SharedPreferenceUtil().getString(SHARED_PREF_KEY_EMPLOYEE_ID))
        .get());
    var employee = Employee.fromJson(result.data);
    employee.id = result.documentID;
    return employee;
  }
}
