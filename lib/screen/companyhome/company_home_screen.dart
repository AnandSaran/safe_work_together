import 'package:flutter/material.dart';
import 'package:safe_work_together/bloc/bloc.dart';
import 'package:safe_work_together/constants/StringConstants.dart';
import 'package:safe_work_together/constants/sharedprefkey.dart';
import 'package:safe_work_together/repository/company_repository.dart';
import 'package:safe_work_together/repository/repository.dart';
import 'package:safe_work_together/screen/companycretaeuser/component/company_create_employee.dart';
import 'package:safe_work_together/screen/companyuserlist/component/company_employee_list.dart';
import 'package:safe_work_together/style/theme.dart' as Theme;
import 'package:safe_work_together/util/sharedpreference.dart';

class CompanyHomeScreen extends StatefulWidget {
  @override
  _CompanyHomeState createState() => _CompanyHomeState();
}

class _CompanyHomeState extends State<CompanyHomeScreen> {
  int _selectedIndex = 0;
  EmployeeRepository _employeeRepository;
  CompanyRepository _companyRepository;
  CompanyHomeBloc _bloc;
  BlocProvider<CompanyEmployeeListBloc> widgetEmployeeList;
  BlocProvider<CompanyCreateEmployeeBloc> widgetCreateEmployee;

  @override
  void initState() {
    super.initState();
    init();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(APP_NAME),
        backgroundColor: Theme.Colors.homeNavigationBarBackgroundColor,
      ),
      body: Center(
        child: getWidget(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            title: Text(ACTION_EMPLOYEE_ENTRY),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.create),
            title: Text(ACTION_CREATE_EMPLOYEE),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            title: Text(ACTION_EMPLOYEE_LIST),
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.Colors.buttonColorIdle,
        onTap: (newIndex) {
          if (_selectedIndex != newIndex) {
            _onItemTapped(newIndex);
          }
        },
      ),
    );
  }

  BlocProvider<CompanyCreateEmployeeBloc> _widgetCreateEmployee() {
    return BlocProvider<CompanyCreateEmployeeBloc>(
      bloc: CompanyCreateEmployeeBloc(
          employeeRepository: _employeeRepository,
          companyRepository: _companyRepository),
      child: CompanyCreateEmployee(),
    );
  }

  BlocProvider<CompanyEmployeeListBloc> _widgetEmployeeList() {
    return BlocProvider<CompanyEmployeeListBloc>(
      bloc: CompanyEmployeeListBloc(
          employeeRepository: _employeeRepository,
          companyRepository: _companyRepository),
      child: CompanyEmployeeList(),
    );
  }

  Widget getWidget() {
    switch (_selectedIndex) {
      case 0:
        break;
      case 1:
        return _widgetCreateEmployee();
      case 2:
        return _widgetEmployeeList();
    }
  }

  void getCompanyData() {
    _companyRepository.getCompany(
        SharedPreferenceUtil().getString(SHARED_PREF_KEY_COMPANY_ID));
  }

  void init() {
    _bloc = BlocProvider.of<CompanyHomeBloc>(context);
    _employeeRepository = _bloc.employeeRepository;
    _companyRepository = _bloc.companyRepository;
    getCompanyData();
  }
}
