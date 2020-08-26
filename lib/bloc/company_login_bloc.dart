import 'dart:async';
import 'dart:io';

import 'package:country_pickers/country.dart' as CountryEntity;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:progress_state_button/progress_button.dart';
import 'package:rxdart/rxdart.dart';
import 'package:safe_work_together/bloc/bloc_provider/bloc_provider.dart';
import 'package:safe_work_together/constants/StringConstants.dart';
import 'package:safe_work_together/repository/company_repository.dart';
import 'package:safe_work_together/repository/firebase_user_repository.dart';
import 'package:safe_work_together/src/model/company.dart';
import 'package:safe_work_together/src/model/models.dart';

class CompanyLoginBloc extends BlocBase {
  final CompanyRepository _companyRepository;
  final FirebaseUserRepository _firebaseUserRepository;
  final duration = Duration(minutes: 1);

  CompanyLoginBloc(
      {@required CompanyRepository companyRepository,
      @required FirebaseUserRepository firebaseUserRepository})
      : assert(companyRepository != null),
        _companyRepository = companyRepository,
        assert(firebaseUserRepository != null),
        _firebaseUserRepository = firebaseUserRepository;

  final errorMessage = BehaviorSubject<String>();
  final _licenceNumber = BehaviorSubject<String>();
  final _countryCode = BehaviorSubject<CountryEntity.Country>();
  final _mobileNumber = BehaviorSubject<String>();

  final verificationId = BehaviorSubject<String>();
  final isShowOtpDialog = BehaviorSubject<bool>();
  var otp = BehaviorSubject<String>();
  final isOtpVerified = BehaviorSubject<bool>();
  var logInSuccess = BehaviorSubject<bool>();
  var progressButtonState = BehaviorSubject<ButtonState>();

  Stream<String> get licenceNumber =>
      _licenceNumber.stream.transform(_streamValidateCompanyLicenceNumber);

  Stream<CountryEntity.Country> get countryCode =>
      _countryCode.stream.transform(_streamValidateCountryCode);

  Stream<String> get mobileNumber =>
      _mobileNumber.stream.transform(_streamValidateCompanyMobileNumber);

  // Change data
  Function(ButtonState) get changeProgressButtonState =>
      progressButtonState.sink.add;

  Function(String) get changeErrorMessage => errorMessage.sink.add;

  Function(String) get changeLicenceNumber => _licenceNumber.sink.add;

  Function(CountryEntity.Country) get changeCountryCode =>
      _countryCode.sink.add;

  Function(String) get changeMobileNumber => _mobileNumber.sink.add;

  Function(String) get changeVerificationId => verificationId.sink.add;

  Function(bool) get changeShowOtpDialog => isShowOtpDialog.sink.add;

  Function(String) get changeOtp => otp.sink.add;

  Function(bool) get changeOtpVerified => isOtpVerified.sink.add;

  Function(bool) get changeLogInSuccess => logInSuccess.sink.add;

  final _streamValidateCompanyLicenceNumber =
      StreamTransformer<String, String>.fromHandlers(
          handleData: (licenceNumber, sink) {
    if (licenceNumber.trim().isNotEmpty) {
      sink.add(licenceNumber);
    } else {
      sink.addError(ERROR_COMPANY_LICENCE_NUMBER);
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

  final _streamValidateCompanyMobileNumber =
      StreamTransformer<String, String>.fromHandlers(
          handleData: (mobileNumber, sink) {
    if (mobileNumber.trim().isNotEmpty && mobileNumber.length > 3) {
      sink.add(mobileNumber);
    } else {
      sink.addError(ERROR_MOBILE_NUMBER);
    }
  });

  bool validateOtpForm() {
    return _validateOtp();
  }

  void validateLoginForm() {
    bool validCompanyLicenceNumber = _validateCompanyLicenceNumber();
    bool validCompanyMobileNumber = _validateCompanyMobileNumber();
    if (validCompanyLicenceNumber && validCompanyMobileNumber) {
      loginCompany();
    }
  }

  bool _validateCompanyLicenceNumber() {
    if (_licenceNumber.hasValue && _licenceNumber.value.trim().isNotEmpty) {
      return true;
    } else {
      _licenceNumber.sink.addError(ERROR_COMPANY_LICENCE_NUMBER);
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
    if (_validateCompanyMobileNumber()) {
      changeShowOtpDialog(true);
      _firebaseUserRepository.signInWithMobileNumber(
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
      AuthResult authResult =
          await _firebaseUserRepository.verifyOtp(verificationId.value, otp.value);
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

    await _licenceNumber.drain();
    _licenceNumber.close();

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
  }

  bool _validateCompanyMobileNumber() {
    if (_mobileNumber.hasValue && _mobileNumber.value.length > 3) {
      return true;
    } else {
      _mobileNumber.sink.addError(ERROR_MOBILE_NUMBER);
      return false;
    }
  }

  loginCompany() {
    changeProgressButtonState(ButtonState.loading);
    Company company = new Company();
    company.licenceNumber = _licenceNumber.value.toUpperCase().trim();
    company.mobileNumber =
    (SYMBOL_PLUS + _countryCode.value.phoneCode + _mobileNumber.value).trim();

    _companyRepository
        .isCompanyNotRegistered(company)
        .then((isCompanyNotRegistered) => {
              if (isCompanyNotRegistered)
                {_setCompanyNotRegisteredContent()}
              else
                {changeLogInSuccess(true)}
            });
  }

  void showToast(BuildContext context, String message) {
    Scaffold.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  _setCompanyNotRegisteredContent() {
    changeErrorMessage(ERROR_COMPANY_NOT_REGISTERED);
    changeProgressButtonState(ButtonState.fail);
  }
}
