import 'package:flutter/material.dart';
import 'package:safe_work_together/bloc/bloc_provider/bloc_provider.dart';
import 'package:safe_work_together/repository/repository.dart';

class CompanyHomeBloc extends BlocBase {
  final EmployeeRepository employeeRepository;
  final CompanyRepository companyRepository;

  CompanyHomeBloc({
    @required EmployeeRepository employeeRepository,
    @required CompanyRepository companyRepository,
  })  : assert(employeeRepository != null),
        employeeRepository = employeeRepository,
        assert(companyRepository != null),
        companyRepository = companyRepository;

  @override
  void dispose() {}
}
