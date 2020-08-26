import 'package:flutter/material.dart';
import 'package:safe_work_together/bloc/bloc.dart';
import 'package:safe_work_together/constants/StringConstants.dart';
import 'package:safe_work_together/screen/companyhome/company_home_screen.dart';
import 'package:safe_work_together/screen/companyregistration/company_registration.dart';
import 'package:safe_work_together/screen/employeelogin/employee_login_screen.dart';
import 'package:safe_work_together/screen/splash/splash_screen.dart';
import 'repository/repository.dart';
import 'screen/employeehome/employee_home_screen.dart';

import 'constants/NavigatorConstants.dart';
import 'screen/companylogin/company_login_screen.dart';

void main() {
  runApp(App());
}

class App extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final EmployeeRepository _employeeRepository = new EmployeeRepository();
    final EntryRepository _entryRepository = new EntryRepository();
    final CompanyRepository _companyRepository = new CompanyRepository();
    final FirebaseUserRepository _firebaseUserRepository =
        new FirebaseUserRepository();

    return MaterialApp(
      title: APP_NAME,
      theme: ThemeData(
        primarySwatch: Colors.orange,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      //  home: Wrapper(),
      initialRoute: '/',
      routes: {
        ROUTE_INITIAL: (context) => SplashScreen(),
        ROUTE_LOGIN_EMPLOYEE: (context) => BlocProvider<EmployeeLoginBloc>(
            bloc: EmployeeLoginBloc(
                companyRepository: _companyRepository,
                employeeRepository: _employeeRepository,
                firebaseAuthRepository: _firebaseUserRepository),
            child: EmployeeLoginScreen()),
        ROUTE_LOGIN_COMPANY: (context) => BlocProvider<CompanyLoginBloc>(
              bloc: CompanyLoginBloc(
                  companyRepository: _companyRepository,
                  firebaseUserRepository: _firebaseUserRepository),
              child: CompanyLoginScreen(),
            ),
        ROUTE_COMPANY_REGISTRATION: (context) =>
            BlocProvider<CompanyRegisterBloc>(
              bloc: CompanyRegisterBloc(
                  companyRepository: _companyRepository,
                  firebaseUserRepository: _firebaseUserRepository),
              child: CompanyRegistrationScreen(),
            ),
        ROUTE_COMPANY_HOME: (context) => BlocProvider<CompanyHomeBloc>(
              bloc: CompanyHomeBloc(
                  companyRepository: _companyRepository,
                  employeeRepository: _employeeRepository),
              child: CompanyHomeScreen(),
            ),
        ROUTE_EMPLOYEE_HOME: (context) => BlocProvider<EmployeeHomeBloc>(
              bloc: EmployeeHomeBloc(employeeRepository: _employeeRepository,entryRepository: _entryRepository,companyRepository: _companyRepository),
              child: EmployeeHomeScreen(),
            )
      },
    );
  }
}
