import 'dart:async';
import 'dart:io';

import 'package:country_pickers/country.dart' as CountryEntity;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:progress_state_button/progress_button.dart';
import 'package:rxdart/rxdart.dart';
import 'package:safe_work_together/bloc/bloc_provider/bloc_provider.dart';
import 'package:safe_work_together/constants/FireStorageConstants.dart';
import 'package:safe_work_together/constants/StringConstants.dart';
import 'package:safe_work_together/repository/company_repository.dart';
import 'package:safe_work_together/extension/file_extensions.dart';
import 'package:safe_work_together/repository/firebase_user_repository.dart';
import 'package:safe_work_together/src/model/company.dart';
import 'package:safe_work_together/src/model/country.dart';
import 'package:safe_work_together/src/model/models.dart';
import 'package:safe_work_together/src/model/site.dart';

class CompanyRegisterBloc extends BlocBase {
  final CompanyRepository _companyRepository;
  final FirebaseUserRepository _firebaseUserRepository;
  final duration = Duration(minutes: 1);

  CompanyRegisterBloc({@required CompanyRepository companyRepository,
    @required FirebaseUserRepository firebaseUserRepository})
      : assert(companyRepository != null),
        _companyRepository = companyRepository,
        assert(firebaseUserRepository != null),
        _firebaseUserRepository = firebaseUserRepository;

  final errorMessage = BehaviorSubject<String>();
  final _companyName = BehaviorSubject<String>();
  final _licenceNumber = BehaviorSubject<String>();
  final _countryCode = BehaviorSubject<CountryEntity.Country>();
  final _mobileNumber = BehaviorSubject<String>();

  final documentUrl = BehaviorSubject<String>();
  final siteList = BehaviorSubject<List<Site>>();

  var _siteName = BehaviorSubject<String>();
  var _perDayEntry = BehaviorSubject<int>();

  final isCompanyCreated = BehaviorSubject<bool>();
  final isToTrackTemperature = BehaviorSubject<bool>();
  final isToTrackHeartRate = BehaviorSubject<bool>();
  final isToTrackOxygenLevel = BehaviorSubject<bool>();
  final isToTrackCough = BehaviorSubject<bool>();
  final isToTrackRunningNose = BehaviorSubject<bool>();
  final isToTrackSoreThroat = BehaviorSubject<bool>();
  final isToTrackShortnessOfBreath = BehaviorSubject<bool>();

  final verificationId = BehaviorSubject<String>();
  final isShowOtpDialog = BehaviorSubject<bool>();
  var otp = BehaviorSubject<String>();
  final isOtpVerified = BehaviorSubject<bool>();
  var progressButtonState = BehaviorSubject<ButtonState>();

  Stream<String> get companyName =>
      _companyName.stream.transform(_streamValidateCompanyName);

  Stream<String> get licenceNumber =>
      _licenceNumber.stream.transform(_streamValidateCompanyLicenceNumber);

  Stream<CountryEntity.Country> get countryCode =>
      _countryCode.stream.transform(_streamValidateCountryCode);

  Stream<String> get mobileNumber =>
      _mobileNumber.stream.transform(_streamValidateCompanyMobileNumber);

  Stream<String> get siteName =>
      _siteName.stream.transform(_streamValidateSiteName);

  Stream<int> get perDayEntry =>
      _perDayEntry.stream.transform(_streamValidateEntryPerDay);

  // Change data
  Function(ButtonState) get changeProgressButtonState =>
      progressButtonState.sink.add;

  Function(String) get changeErrorMessage => errorMessage.sink.add;

  Function(String) get changeCompanyName => _companyName.sink.add;

  Function(String) get changeLicenceNumber => _licenceNumber.sink.add;

  Function(CountryEntity.Country) get changeCountryCode =>
      _countryCode.sink.add;

  Function(String) get changeMobileNumber => _mobileNumber.sink.add;

  Function(String) get changeDocumentUrl => documentUrl.sink.add;

  Function(List<Site>) get changeSiteList => siteList.sink.add;

  Function(bool) get changeIsCompanyCreated => isCompanyCreated.sink.add;

  Function(bool) get changeToTrackTemperature => isToTrackTemperature.sink.add;

  Function(bool) get changeToTrackHeartRate => isToTrackHeartRate.sink.add;

  Function(bool) get changeToTrackOxygenLevel => isToTrackOxygenLevel.sink.add;

  Function(bool) get changeToTrackCough => isToTrackCough.sink.add;

  Function(bool) get changeToTrackRunningNose => isToTrackRunningNose.sink.add;

  Function(bool) get changeToTrackSoreThroat => isToTrackSoreThroat.sink.add;

  Function(bool) get changeToTrackShortnessOfBreath =>
      isToTrackShortnessOfBreath.sink.add;

  Function(String) get changeSiteName => _siteName.sink.add;

  Function(int) get changePerDayEntry => _perDayEntry.sink.add;

  Function(String) get changeVerificationId => verificationId.sink.add;

  Function(bool) get changeShowOtpDialog => isShowOtpDialog.sink.add;

  Function(String) get changeOtp => otp.sink.add;

  Function(bool) get changeOtpVerified => isOtpVerified.sink.add;

  final _streamValidateCompanyName =
  StreamTransformer<String, String>.fromHandlers(
      handleData: (companyName, sink) {
        if (companyName.trim().isNotEmpty) {
          sink.add(companyName);
        } else {
          sink.addError(ERROR_COMPANY_NAME);
        }
      });

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
        if (mobileNumber.trim().isNotEmpty && mobileNumber.trim().length > 3) {
          sink.add(mobileNumber);
        } else {
          sink.addError(ERROR_MOBILE_NUMBER);
        }
      });

  final _streamValidateSiteName =
  StreamTransformer<String, String>.fromHandlers(
      handleData: (siteName, sink) {
        if (siteName.trim().isNotEmpty) {
          sink.add(siteName);
        } else {
          sink.addError(ERROR_SITE_NAME);
        }
      });

  final _streamValidateEntryPerDay =
  StreamTransformer<int, int>.fromHandlers(handleData: (entryPerDay, sink) {
    if (entryPerDay
        .toString()
        .isNotEmpty && entryPerDay > 0) {
      sink.add(entryPerDay);
    } else {
      sink.addError(ERROR_ENTRY_PER_DAY);
    }
  });

  uploadImage(String path) {
    File documentImage = File(path);
    _uploadFileToFireStorage(documentImage);
  }

  _uploadFileToFireStorage(File file) async {
    StorageReference storageReference =
    FirebaseStorage.instance.ref().child(COMPANY_DOCUMENT + file.name);
    StorageUploadTask uploadTask = storageReference.putFile(file);
    await uploadTask.onComplete
        .then((value) =>
        storageReference.getDownloadURL().then((fileURL) {
          changeDocumentUrl(fileURL);
        }));
  }

  void addSite() {
    Site site = Site(_siteName.value, _perDayEntry.value);
    if (!siteList.hasValue) {
      changeSiteList(new List());
    }
    List<Site> sites = siteList.value;
    sites.add(site);
    changeSiteList(sites);
    _siteName = BehaviorSubject<String>();
    _perDayEntry = BehaviorSubject<int>();
  }

  bool validateSite() {
    var isValidSiteName = validateSiteName();
    var isValidSiteEntryPerDay = validateSiteEntryPerDay();
    return (isValidSiteName && isValidSiteEntryPerDay);
  }

  bool validateSiteName() {
    if (_siteName.hasValue && _siteName.value.trim().isNotEmpty) {
      return true;
    } else {
      _siteName.sink.addError(ERROR_SITE_NAME);
      return false;
    }
  }

  bool validateSiteEntryPerDay() {
    if (_perDayEntry.hasValue &&
        _perDayEntry.value
            .toString()
            .isNotEmpty &&
        _perDayEntry.value > 0) {
      return true;
    } else {
      _perDayEntry.sink.addError(ERROR_ENTRY_PER_DAY);
      return false;
    }
  }

  bool validateOtpForm() {
    return _validateOtp();
  }

  void validateRegistrationForm() {
    bool validCompanyName = _validateCompanyName();
    bool validCompanyLicenceNumber = _validateCompanyLicenceNumber();
    bool validCompanyMobileNumber = _validateCompanyMobileNumber();
    bool validCompanyDocument = _validateCompanyDocument();
    bool validSite= _validateSite();
    if (validCompanyName &&
        validCompanyLicenceNumber &&
        validCompanyMobileNumber &&
        validCompanyDocument&&
        validSite) {
      addCompany();
    }
  }

  bool _validateCompanyName() {
    if (_companyName.hasValue && _companyName.value.trim().isNotEmpty) {
      return true;
    } else {
      _companyName.sink.addError(ERROR_COMPANY_NAME);
      return false;
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

  bool _validateCompanyDocument() {
    if (documentUrl.hasValue && documentUrl.value.trim().isNotEmpty) {
      return true;
    } else {
      documentUrl.sink.addError(ERROR_COMPANY_LICENCE_NUMBER);
      return false;
    }
  }
  bool _validateSite(){
    if (siteList.hasValue &&siteList.value.length>0) {
      return true;
    } else {
      changeErrorMessage(ERROR_SITE_LIST);
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

    await _companyName.drain();
    _companyName.close();

    await _licenceNumber.drain();
    _licenceNumber.close();

    await _countryCode.drain();
    _countryCode.close();

    await _mobileNumber.drain();
    _mobileNumber.close();

    await documentUrl.drain();
    documentUrl.close();

    await siteList.drain();
    siteList.close();

    await isCompanyCreated.drain();
    isCompanyCreated.close();

    await isToTrackTemperature.drain();
    isToTrackTemperature.close();

    await isToTrackHeartRate.drain();
    isToTrackHeartRate.close();

    await isToTrackOxygenLevel.drain();
    isToTrackOxygenLevel.close();

    await isToTrackCough.drain();
    isToTrackCough.close();

    await isToTrackRunningNose.drain();
    isToTrackRunningNose.close();

    await isToTrackSoreThroat.drain();
    isToTrackSoreThroat.close();

    await isToTrackShortnessOfBreath.drain();
    isToTrackShortnessOfBreath.close();

    await _siteName.drain();
    _siteName.close();

    await _perDayEntry.drain();
    _perDayEntry.close();

    await verificationId.drain();
    verificationId.close();

    await isShowOtpDialog.drain();
    isShowOtpDialog.close();

    await otp.drain();
    otp.close();

    await isOtpVerified.drain();
    isOtpVerified.close();

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

  addCompany() {
    changeProgressButtonState(ButtonState.loading);
    Company company = new Company();
    company.name = _companyName.value.toUpperCase().trim();
    company.licenceNumber = _licenceNumber.value.toUpperCase().trim();
    company.country = _country();
    company.mobileNumber =
    (SYMBOL_PLUS + company.country.phoneCode + _mobileNumber.value).trim();
    company.documentUrl = documentUrl.value;
    company.siteList = siteList.value;
    company.isToTrackTemperature = isToTrackTemperature.value;
    company.isToTrackHeartRate = isToTrackHeartRate.value;
    company.isToTrackOxygenLevel = isToTrackOxygenLevel.value;
    company.isToTrackCough = isToTrackCough.value;
    company.isToTrackRunningNose = isToTrackRunningNose.value;
    company.isToTrackSoreThroat = isToTrackSoreThroat.value;
    company.isToTrackShortnessOfBreath = isToTrackShortnessOfBreath.value;

    _companyRepository
        .isCompanyNotRegistered(company)
        .then((isCompanyNotRegistered) => {
    if (isCompanyNotRegistered)
    {
    _companyRepository
        .addCompany(company)
        .asStream()
        .listen((event) {
    changeIsCompanyCreated(event);
    })
    } else{
        _setCompanyAlreadyRegisteredContent()
  }});
  }

  Country _country() {
    var countryEntity = _countryCode.value;
    Country country = new Country(countryEntity.name, countryEntity.isoCode,
        countryEntity.iso3Code, countryEntity.phoneCode);
    return country;
  }

  _setCompanyAlreadyRegisteredContent() {
    changeErrorMessage(ERROR_COMPANY_ALREADY_REGISTERED);
    changeProgressButtonState(ButtonState.fail);
  }
}
