import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:safe_work_together/bloc/bloc_provider/bloc_provider.dart';
import 'package:safe_work_together/repository/company_repository.dart';
import 'package:safe_work_together/repository/repository.dart';
import 'package:safe_work_together/src/model/models.dart';
import 'package:safe_work_together/src/model/site.dart';

class CompanyEmployeeListBloc extends BlocBase {
  final EmployeeRepository _employeeRepository;
  final CompanyRepository _companyRepository;

  CompanyEmployeeListBloc({
    @required EmployeeRepository employeeRepository,
    @required CompanyRepository companyRepository,
  })  : assert(employeeRepository != null),
        _employeeRepository = employeeRepository,
        assert(companyRepository != null),
        _companyRepository = companyRepository;

  final errorMessage = BehaviorSubject<String>();
  var siteList = BehaviorSubject<List<Site>>();
    var employeeList = BehaviorSubject<List<Employee>>();

  Function(String) get changeErrorMessage => errorMessage.sink.add;

  Function(List<Site>) get changeSiteList => siteList.sink.add;

  Function(List<Employee>) get changeEmployeeList => employeeList.sink.add;


  @override
  Future<void> dispose() async {
    await errorMessage.drain();
    errorMessage.close();

    await siteList.drain();
    siteList.close();

    await employeeList.drain();
    employeeList.close();
  }

  getSiteList() {
    changeSiteList(_companyRepository.company.siteList);
  }


  void getFirstEmployeeList() {
    _employeeRepository.fetchFirstList().asStream().listen((event) {
      changeEmployeeList(event);
    });
  }

  void getNextEmployeeList() {
    _employeeRepository.fetchNextEmployeeList().asStream().listen((event) {
      changeEmployeeList(event);
    });
  }
}
