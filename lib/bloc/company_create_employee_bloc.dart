import 'dart:async';
import 'package:flutter/material.dart';
import 'package:progress_state_button/progress_button.dart';
import 'package:rxdart/rxdart.dart';
import 'package:safe_work_together/bloc/bloc_provider/bloc_provider.dart';
import 'package:safe_work_together/constants/StringConstants.dart';
import 'package:safe_work_together/constants/sharedprefkey.dart';
import 'package:safe_work_together/repository/repository.dart';
import 'package:safe_work_together/src/model/models.dart';
import 'package:safe_work_together/src/model/site.dart';
import 'package:safe_work_together/util/sharedpreference.dart';

class CompanyCreateEmployeeBloc extends BlocBase {
  final EmployeeRepository _employeeRepository;
  final CompanyRepository _companyRepository;

  CompanyCreateEmployeeBloc({
    @required EmployeeRepository employeeRepository,
    @required CompanyRepository companyRepository,
  })  : assert(employeeRepository != null),
        _employeeRepository = employeeRepository,
        assert(companyRepository != null),
        _companyRepository = companyRepository;

  final errorMessage = BehaviorSubject<String>();

  final _employeeId = BehaviorSubject<String>();
  final _employeeName = BehaviorSubject<String>();
  var createEmployeeSuccess = BehaviorSubject<bool>();
  var progressButtonState = BehaviorSubject<ButtonState>();
  var siteList = BehaviorSubject<List<Site>>();

  Stream<String> get employeeId =>
      _employeeId.stream.transform(_streamValidateEmployeeId);

  Stream<String> get employeeName =>
      _employeeName.stream.transform(_streamValidateEmployeeName);

  // Change data
  Function(ButtonState) get changeProgressButtonState =>
      progressButtonState.sink.add;

  Function(String) get changeErrorMessage => errorMessage.sink.add;

  Function(String) get changeEmployeeId => _employeeId.sink.add;

  Function(String) get changeEmployeeName => _employeeName.sink.add;

  Function(bool) get changeCreateEmployeeSuccess => createEmployeeSuccess.sink.add;

  Function(List<Site>) get changeSiteList => siteList.sink.add;

  final _streamValidateEmployeeId =
      StreamTransformer<String, String>.fromHandlers(
          handleData: (employeeId, sink) {
    if (employeeId.trim().isNotEmpty) {
      sink.add(employeeId);
    } else {
      sink.addError(ERROR_EMPLOYEE_ID_EMPTY);
    }
  });

  final _streamValidateEmployeeName =
      StreamTransformer<String, String>.fromHandlers(
          handleData: (employeeName, sink) {
    if (employeeName.trim().isNotEmpty) {
      sink.add(employeeName);
    } else {
      sink.addError(ERROR_EMPLOYEE_NAME_EMPTY);
    }
  });

  void validateCreateEmployeeForm() {
    bool isValidEmployeeId = _validateEmployeeId();
    bool isValidEmployeeName = _validateEmployeeName();
    bool validSite = _validateSite();
    if (isValidEmployeeId && isValidEmployeeName && validSite) {
      addEmployee();
    }
  }

  bool _validateEmployeeId() {
    if (_employeeId.hasValue && _employeeId.value.trim().isNotEmpty) {
      return true;
    } else {
      _employeeId.sink.addError(ERROR_EMPLOYEE_ID_EMPTY);
      return false;
    }
  }

  bool _validateEmployeeName() {
    if (_employeeName.hasValue && _employeeName.value.trim().isNotEmpty) {
      return true;
    } else {
      _employeeName.sink.addError(ERROR_EMPLOYEE_NAME_EMPTY);
      return false;
    }
  }

  bool _validateSite() {
    var sites = siteList.value.where((element) => element.isSelected).toList();
    if (siteList.hasValue && sites.length > 0) {
      return true;
    } else {
      changeErrorMessage(ERROR_SELECT_SITE_LIST);
      return false;
    }
  }

  @override
  Future<void> dispose() async {
    await errorMessage.drain();
    errorMessage.close();

    await _employeeId.drain();
    _employeeId.close();

    await _employeeName.drain();
    _employeeName.close();

    await createEmployeeSuccess.drain();
    createEmployeeSuccess.close();

    await progressButtonState.drain();
    progressButtonState.close();

    await siteList.drain();
    siteList.close();

  }

  addEmployee() {
    changeProgressButtonState(ButtonState.loading);
    Employee employee = new Employee();
    employee.employeeId = _employeeId.value.toUpperCase().trim();
    employee.employeeName = _employeeName.value.trim();
    employee.siteList =
        siteList.value.where((element) => element.isSelected).toList();
    employee.employerId =
        SharedPreferenceUtil().getString(SHARED_PREF_KEY_COMPANY_ID);
    _employeeRepository
        .isEmployeeNotRegistered(employee, _companyRepository.company.id)
        .then((isEmployeeNotRegistered) => {
              if (isEmployeeNotRegistered)
                {
                  _employeeRepository.addEmployee(employee).asStream().listen((event) {
                    changeCreateEmployeeSuccess(event);
                  })
                }
              else
                {_setEmployeeAlreadyRegisteredContent()}
            });
  }

  _setEmployeeAlreadyRegisteredContent() {
    changeErrorMessage(ERROR_EMPLOYEE_ALREADY_REGISTERED);
    changeProgressButtonState(ButtonState.fail);
  }

  void resetData() {
    changeEmployeeId("");
    changeEmployeeName("");
    _employeeId.sink.addError("");
    _employeeName.sink.addError("");
    changeProgressButtonState(ButtonState.idle);
  }

  getSiteList() {
    changeSiteList(_companyRepository.company.siteList);
  }
}
