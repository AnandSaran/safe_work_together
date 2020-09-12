import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:progress_state_button/progress_button.dart';
import 'package:rxdart/rxdart.dart';
import 'package:safe_work_together/bloc/bloc_provider/bloc_provider.dart';
import 'package:safe_work_together/constants/IntegerConstant.dart';
import 'package:safe_work_together/constants/StringConstants.dart';
import 'package:safe_work_together/repository/repository.dart';
import 'package:safe_work_together/src/model/entry.dart';
import 'package:safe_work_together/src/model/models.dart';
import 'package:safe_work_together/extension/list_site_extension.dart';

class EmployeeHomeBloc extends BlocBase {
  final EmployeeRepository _employeeRepository;
  final EntryRepository _entryRepository;
  final CompanyRepository _companyRepository;
  final duration = Duration(minutes: 1);

  EmployeeHomeBloc(
      {@required EmployeeRepository employeeRepository,
      @required EntryRepository entryRepository,
      @required CompanyRepository companyRepository})
      : assert(employeeRepository != null),
        _employeeRepository = employeeRepository,
        assert(entryRepository != null),
        _entryRepository = entryRepository,
        assert(companyRepository != null),
        _companyRepository = companyRepository;

  final errorMessage = BehaviorSubject<String>();
  var progressButtonState = BehaviorSubject<ButtonState>();
  var employee = BehaviorSubject<Employee>();
  var company = BehaviorSubject<Company>();

  final cough = BehaviorSubject<int>();
  final soreThroat = BehaviorSubject<int>();
  final runningNose = BehaviorSubject<int>();
  final shortnessOfBreath = BehaviorSubject<int>();
  final perDaySubmit = BehaviorSubject<int>();

  final temperature = BehaviorSubject<double>();
  final oxygen = BehaviorSubject<double>();
  final heartRate = BehaviorSubject<double>();

  // Change data
  Function(ButtonState) get changeProgressButtonState =>
      progressButtonState.sink.add;

  Function(String) get changeErrorMessage => errorMessage.sink.add;

  Function(Employee) get changeEmployee => employee.sink.add;

  Function(Company) get changeCompany => company.sink.add;

  Function(int) get changeCough => cough.sink.add;

  Function(int) get changeSoreThroat => soreThroat.sink.add;

  Function(int) get changeRunningNose => runningNose.sink.add;

  Function(int) get changeShortnessOfBreath => shortnessOfBreath.sink.add;

  Function(int) get changePerDaySubmit => perDaySubmit.sink.add;

  Function(double) get changeTemperature => temperature.sink.add;

  Function(double) get changeOxygen => oxygen.sink.add;

  Function(double) get changeHeartRate => heartRate.sink.add;

  @override
  Future<void> dispose() async {
    await temperature.drain();
    temperature.close();

    await oxygen.drain();
    oxygen.close();

    await heartRate.drain();
    heartRate.close();

    await errorMessage.drain();
    errorMessage.close();

    await progressButtonState.drain();
    progressButtonState.close();

    await employee.drain();
    employee.close();

    await cough.drain();
    cough.close();

    await soreThroat.drain();
    soreThroat.close();

    await runningNose.drain();
    runningNose.close();

    await shortnessOfBreath.drain();
    shortnessOfBreath.close();

    await perDaySubmit.drain();
    perDaySubmit.close();

    await company.drain();
    company.close();
  }

  void getEmployee() {
    _employeeRepository.fetchEmployee().asStream().listen((event) {
      changeEmployee(event);
      getCompany(event.employerId);
    });
  }

  void validateForm() {
    var validTemperature = validateTemperature();
    var validOxygen = validateOxygen();
    var validHeartRate = validateHeartRate();

    if (!progressButtonState.hasValue &&
        validTemperature &&
        validOxygen &&
        validHeartRate) {
      addEntry();
    }
  }

  bool validateTemperature() {
    if (!company.value.isToTrackTemperature) {
      return true;
    } else if (temperature.hasValue &&
        temperature.value.toString().isNotEmpty &&
        ((25 < temperature.value && temperature.value < 45) ||
            (90 < temperature.value && temperature.value < 120))) {
      return true;
    } else {
      temperature.addError(ERROR_INVALID);
      return false;
    }
  }

  bool validateOxygen() {
    if (!company.value.isToTrackOxygenLevel) {
      return true;
    } else if (oxygen.hasValue &&
        oxygen.value.toString().isNotEmpty &&
        50 < oxygen.value &&
        oxygen.value < 150) {
      return true;
    } else {
      oxygen.addError(ERROR_INVALID);
      return false;
    }
  }

  bool validateHeartRate() {
    if (!company.value.isToTrackHeartRate) {
      return true;
    } else if (heartRate.hasValue &&
        heartRate.value.toString().isNotEmpty &&
        50 < heartRate.value &&
        heartRate.value < 150) {
      return true;
    } else {
      heartRate.addError(ERROR_INVALID);
      return false;
    }
  }

  void setFormData(Company company) {
    if (company.isToTrackCough) {
      changeCough(DEFAULT_RADIO_BUTTON);
    }
    if (company.isToTrackSoreThroat) {
      changeSoreThroat(DEFAULT_RADIO_BUTTON);
    }
    if (company.isToTrackRunningNose) {
      changeRunningNose(DEFAULT_RADIO_BUTTON);
    }
    if (company.isToTrackShortnessOfBreath) {
      changeShortnessOfBreath(DEFAULT_RADIO_BUTTON);
    }
    /*if (!company.isToTrackTemperature) {
      changeTemperature(DEFAULT_INT_VALUE.toDouble());
    }
    if (!company.isToTrackHeartRate) {
      changeHeartRate(DEFAULT_INT_VALUE.toDouble());
    }
    if (!company.isToTrackOxygenLevel) {
      changeOxygen(DEFAULT_INT_VALUE.toDouble());
    }*/
  }

  void getCompany(String companyId) {
    _companyRepository.getCompany(companyId).asStream().listen((event) {
      setFormData(event);
      changeCompany(event);
      getTodayEntry();
    });
  }

  void addEntry() {
    changeProgressButtonState(ButtonState.loading);
    Entry entry = new Entry();
    entry.employerId = employee.value.employerId;
    entry.employeeId = employee.value.employeeId;
    entry.employeeName = employee.value.employeeName;
    entry.siteList = company.value.siteList;
    if (company.value.isToTrackTemperature) {
      entry.temperature = temperature.value;
    }
    if (company.value.isToTrackOxygenLevel) {
      entry.oxygenLevel = oxygen.value;
    }
    if (company.value.isToTrackHeartRate) {
      entry.heartRate = heartRate.value;
    }

    if (company.value.isToTrackCough) {
      entry.cough = cough.value;
    }
    if (company.value.isToTrackRunningNose) {
      entry.runningNose = runningNose.value;
    }

    if (company.value.isToTrackSoreThroat) {
      entry.soreThroat = soreThroat.value;
    }

    if (company.value.isToTrackShortnessOfBreath) {
      entry.shortnessOfBreath = shortnessOfBreath.value;
    }
    _entryRepository.addEntry(entry).asStream().listen((isAdded) {
      if (isAdded) {
        changeProgressButtonState(ButtonState.success);
        generatePerDatSubmit(perDaySubmit.value - 1);
      } else {
        changeErrorMessage(ERROR_MESSAGE);
        changeProgressButtonState(ButtonState.fail);
      }
    });
  }

  void getTodayEntry() {
    _entryRepository
        .getEmployeeTodayEntry(
            employee.value.employeeId, employee.value.employerId)
        .asStream()
        .listen((event) {
      generatePerDatSubmit(
          employee.value.siteList.generateMaxPerDaySubmit - event);
    });
  }

  void hideAllView() {
    company.value.isToTrackTemperature = false;
    company.value.isToTrackOxygenLevel = false;
    company.value.isToTrackHeartRate = false;
    company.value.isToTrackCough = false;
    company.value.isToTrackSoreThroat = false;
    company.value.isToTrackRunningNose = false;
    company.value.isToTrackShortnessOfBreath = false;
    changeCompany(company.value);
    changeProgressButtonState(ButtonState.success);
  }

  void generatePerDatSubmit(int remainingSubmit) {
    changePerDaySubmit(remainingSubmit);
    if (perDaySubmit.value == 0) {
      hideAllView();
    }
  }
}
