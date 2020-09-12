import 'package:flutter/material.dart';
import 'package:safe_work_together/bloc/bloc.dart';
import 'package:safe_work_together/constants/StringConstants.dart';
import 'package:safe_work_together/constants/sharedprefkey.dart';
import 'package:safe_work_together/repository/company_repository.dart';
import 'package:safe_work_together/repository/repository.dart';
import 'package:safe_work_together/screen/companycretaeuser/component/company_create_employee.dart';
import 'package:safe_work_together/screen/companyuserlist/component/company_employee_list.dart';
import 'package:safe_work_together/screen/employee_entry_list/employee_entry_list.dart';
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
  EntryRepository _entryRepository;
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

  BlocProvider<EmployeeEntryListBloc> _widgetEntryList() {
    return BlocProvider<EmployeeEntryListBloc>(
      bloc: EmployeeEntryListBloc(
          companyRepository: _companyRepository,
          entryRepository: _entryRepository),
      child: EmployeeEntryList(),
    );
  }

  Widget getWidget() {
    return StreamBuilder(
        stream: _bloc.isGetCompanySuccess,
        builder: (context, AsyncSnapshot<bool> snapshot) {
          var isGetCompanySuccess = snapshot.hasData ? snapshot.data : false;
          return generateWidget(isGetCompanySuccess);
        });
  }

  void init() {
    if(_bloc==null) {
      _bloc = BlocProvider.of<CompanyHomeBloc>(context);
      _employeeRepository = _bloc.employeeRepository;
      _companyRepository = _bloc.companyRepository;
      _entryRepository = _bloc.entryRepository;
      _bloc.getCompany();
    }
  }

  Widget generateWidget(bool isGetCompanySuccess) {
    Widget widget;
    if (isGetCompanySuccess) {
      switch (_selectedIndex) {
        case 0:
          widget = _widgetEntryList();
          break;
        case 1:
          widget = _widgetCreateEmployee();
          break;
        case 2:
          widget = _widgetEmployeeList();
          break;
      }
    } else {
      widget = SizedBox(
        height: 10,
      );
    }
    return widget;
  }
}
