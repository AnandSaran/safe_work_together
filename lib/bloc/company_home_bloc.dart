import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:safe_work_together/bloc/bloc_provider/bloc_provider.dart';
import 'package:safe_work_together/constants/sharedprefkey.dart';
import 'package:safe_work_together/repository/repository.dart';
import 'package:safe_work_together/util/sharedpreference.dart';

class CompanyHomeBloc extends BlocBase {
  final EmployeeRepository employeeRepository;
  final CompanyRepository companyRepository;
  final EntryRepository entryRepository;

  final isGetCompanySuccess = BehaviorSubject<bool>();

  CompanyHomeBloc({
    @required EmployeeRepository employeeRepository,
    @required CompanyRepository companyRepository,
    @required EntryRepository entryRepository,
  })  : assert(employeeRepository != null),
        employeeRepository = employeeRepository,
        assert(companyRepository != null),
        companyRepository = companyRepository,
        assert(entryRepository != null),
        entryRepository = entryRepository;

  Function(bool) get changeGetCompanySuccess => isGetCompanySuccess.sink.add;

  @override
  Future<void> dispose() async {
    await isGetCompanySuccess.drain();
    isGetCompanySuccess.close();
  }

  getCompany() {
    companyRepository
        .getCompany(
            SharedPreferenceUtil().getString(SHARED_PREF_KEY_COMPANY_ID))
        .asStream()
        .listen((event) {
      changeGetCompanySuccess(true);
    });
  }
}
