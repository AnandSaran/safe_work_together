import 'dart:async';
import 'dart:io';

import 'package:country_pickers/country.dart' as CountryEntity;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:progress_state_button/progress_button.dart';
import 'package:rxdart/rxdart.dart';
import 'package:safe_work_together/bloc/bloc_provider/bloc_provider.dart';
import 'package:safe_work_together/constants/StringConstants.dart';
import 'package:safe_work_together/repository/company_repository.dart';
import 'package:safe_work_together/repository/firebase_user_repository.dart';
import 'package:safe_work_together/repository/repository.dart';
import 'package:safe_work_together/src/model/company.dart';
import 'package:safe_work_together/src/model/models.dart';

class EmployeeLoginBloc extends BlocBase {
  final CompanyRepository _companyRepository;
  final FirebaseUserRepository _firebaseAuthRepository;
  final EmployeeRepository _employeeRepository;
  final duration = Duration(minutes: 1);

  EmployeeLoginBloc({@required CompanyRepository companyRepository,
    @required FirebaseUserRepository firebaseAuthRepository,
    @required EmployeeRepository employeeRepository})
      : assert(companyRepository != null),
        _companyRepository = companyRepository,
        assert(firebaseAuthRepository != null),
        _firebaseAuthRepository = firebaseAuthRepository,
        assert(employeeRepository != null),
        _employeeRepository = employeeRepository;

  final errorMessage = BehaviorSubject<String>();
  final _employeeId = BehaviorSubject<String>();
  final _countryCode = BehaviorSubject<CountryEntity.Country>();
  final _mobileNumber = BehaviorSubject<String>();
  final company = BehaviorSubject<Company>();

  final verificationId = BehaviorSubject<String>();
  final isShowOtpDialog = BehaviorSubject<bool>();
  var otp = BehaviorSubject<String>();
  final isOtpVerified = BehaviorSubject<bool>();
  var logInSuccess = BehaviorSubject<bool>();
  var progressButtonState = BehaviorSubject<ButtonState>();
  var companyList = BehaviorSubject<List<Company>>();

  Stream<String> get employeeId =>
      _employeeId.stream.transform(_streamValidateEmployeeId);

  Stream<CountryEntity.Country> get countryCode =>
      _countryCode.stream.transform(_streamValidateCountryCode);

  Stream<String> get mobileNumber =>
      _mobileNumber.stream.transform(_streamValidateMobileNumber);

  // Change data
  Function(ButtonState) get changeProgressButtonState =>
      progressButtonState.sink.add;

  Function(String) get changeErrorMessage => errorMessage.sink.add;

  Function(String) get changeEmployeeId => _employeeId.sink.add;

  Function(CountryEntity.Country) get changeCountryCode =>
      _countryCode.sink.add;

  Function(String) get changeMobileNumber => _mobileNumber.sink.add;

  Function(Company) get changeCompany => company.sink.add;

  Function(String) get changeVerificationId => verificationId.sink.add;

  Function(bool) get changeShowOtpDialog => isShowOtpDialog.sink.add;

  Function(String) get changeOtp => otp.sink.add;

  Function(bool) get changeOtpVerified => isOtpVerified.sink.add;

  Function(bool) get changeLogInSuccess => logInSuccess.sink.add;

  Function(List<Company>) get changeCompanyList => companyList.sink.add;

  final _streamValidateEmployeeId =
  StreamTransformer<String, String>.fromHandlers(
      handleData: (employeeId, sink) {
        if (employeeId
            .trim()
            .isNotEmpty) {
          sink.add(employeeId);
        } else {
          sink.addError(ERROR_EMPLOYEE_ID);
        }
      });

  final _streamValidateCountryCode = StreamTransformer<CountryEntity.Country,
      CountryEntity.Country>.fromHandlers(handleData: (countryCode, sink) {
    if (countryCode != null) {
      sink.add(countryCode);
    } else {
      sink.addError(ERROR_COUNTRY_CODE);
    }
  });

  final _streamValidateMobileNumber =
  StreamTransformer<String, String>.fromHandlers(
      handleData: (mobileNumber, sink) {
        if (mobileNumber
            .trim()
            .isNotEmpty && mobileNumber.length > 3) {
          sink.add(mobileNumber);
        } else {
          sink.addError(ERROR_MOBILE_NUMBER);
        }
      });

  bool validateOtpForm() {
    return _validateOtp();
  }

  void validateLoginForm() {
    bool validEmployeeId = _validateEmployeeId();
    bool validMobileNumber = _validateMobileNumber();
    bool validCompany = _validateCompany();
    if (validEmployeeId && validMobileNumber && validCompany) {
      loginEmployee();
    }
  }

  bool _validateEmployeeId() {
    if (_employeeId.hasValue && _employeeId.value
        .trim()
        .isNotEmpty) {
      return true;
    } else {
      _employeeId.sink.addError(ERROR_EMPLOYEE_ID);
      return false;
    }
  }

  bool _validateOtp() {
    if (otp.hasValue && otp.value.length == 6) {
      return true;
    } else {
      otp.sink.addError(ERROR_ENTER_6_DIGIT_OTP);
      return false;
    }
  }

  void generateOtp() {
    if (_validateMobileNumber()) {
      changeShowOtpDialog(true);
      _firebaseAuthRepository.signInWithMobileNumber(
          SYMBOL_PLUS + _countryCode.value.phoneCode + _mobileNumber.value,
          duration,
          _phoneVerificationSuccess,
          _phoneVerificationFailed,
          _phoneCodeSent,
          _phoneCodeAutoRetrievalTimeout);
    }
  }

  void verifyOtp() async {
    try {
      AuthResult authResult = await _firebaseAuthRepository.verifyOtp(
          verificationId.value, otp.value);
      verifyAuthResult(authResult);
    } catch (e) {
      switch (e.code) {
        case "ERROR_SESSION_EXPIRED":
          otp.sink.addError(ERROR_OTP_SESSION_EXPIRED);
          generateOtp();
          break;
        default:
          otp.sink.addError(ERROR_INVALID_OTP);
          break;
      }
      print(e);
    }
  }

  void verifyAuthResult(AuthResult result) {
    if (result.user != null) {
      changeOtpVerified(true);
    } else {
      otp.sink.addError(ERROR_INVALID_OTP);
    }
  }

  _phoneVerificationSuccess(AuthCredential authCredential) {
    changeOtpVerified(true);
  }

  _phoneVerificationFailed(AuthException authException) {
    otp.sink.addError(authException.message);
  }

  _phoneCodeSent(String verId, [int forceResent]) {
    verificationId.sink.add(verId);
  }

  _phoneCodeAutoRetrievalTimeout(String verId) {
    verificationId.sink.add(verId);
  }

  void resetOtp() {
    otp = BehaviorSubject<String>();
  }

  @override
  Future<void> dispose() async {
    await errorMessage.drain();
    errorMessage.close();

    await _employeeId.drain();
    _employeeId.close();

    await _countryCode.drain();
    _countryCode.close();

    await _mobileNumber.drain();
    _mobileNumber.close();

    await verificationId.drain();
    verificationId.close();

    await isShowOtpDialog.drain();
    isShowOtpDialog.close();

    await otp.drain();
    otp.close();

    await isOtpVerified.drain();
    isOtpVerified.close();

    await logInSuccess.drain();
    logInSuccess.close();

    await progressButtonState.drain();
    progressButtonState.close();

    await company.drain();
    company.close();

    await companyList.drain();
    companyList.close();
  }

  bool _validateMobileNumber() {
    if (_mobileNumber.hasValue && _mobileNumber.value.length > 3) {
      return true;
    } else {
      _mobileNumber.sink.addError(ERROR_MOBILE_NUMBER);
      return false;
    }
  }

  bool _validateCompany() {
    if (company.hasValue) {
      return true;
    } else {
      changeErrorMessage(TITTLE_SELECT_COMPANY);
      return false;
    }
  }

  loginEmployee() {
    changeProgressButtonState(ButtonState.loading);
    Employee employee = new Employee();
    employee.employeeId = _employeeId.value.toUpperCase().trim();
    employee.mobileNumber =
        (SYMBOL_PLUS + _countryCode.value.phoneCode + _mobileNumber.value)
            .trim();

    _employeeRepository
        .isEmployeeNotRegistered(employee, company.value.id)
        .then((isEmployeeNotRegistered) => {
    if (isEmployeeNotRegistered)
    {
    _setEmployeeNotRegisteredContent()
    }
    else
    {
        updateEmployeeMobileNumber(employee)
  }});
  }

  void showToast(BuildContext context, String message) {
    Scaffold.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  _setEmployeeNotRegisteredContent() {
    changeErrorMessage(ERROR_EMPLOYEE_NOT_REGISTERED);
    changeProgressButtonState(ButtonState.fail);
  }

  void getCompanyList() {
    _companyRepository.fetchCompanyList().asStream().listen((event) {
      changeCompanyList(event);
    });
  }

  updateEmployeeMobileNumber(Employee employee) {
    _employeeRepository.updateEmployeeMobileNumber(employee.mobileNumber);
    changeLogInSuccess(true);
  }
}
