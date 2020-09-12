import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:safe_work_together/bloc/bloc_provider/bloc_provider.dart';
import 'package:safe_work_together/repository/company_repository.dart';
import 'package:safe_work_together/repository/repository.dart';
import 'package:safe_work_together/src/model/models.dart';
import 'package:safe_work_together/src/model/site.dart';

class EmployeeEntryListBloc extends BlocBase {
  final CompanyRepository _companyRepository;
  final EntryRepository _entryRepository;

  EmployeeEntryListBloc({
    @required CompanyRepository companyRepository,
    @required EntryRepository entryRepository,
  })  : assert(companyRepository != null),
        _companyRepository = companyRepository,
        assert(entryRepository != null),
        _entryRepository = entryRepository;

  final errorMessage = BehaviorSubject<String>();
  var siteList = BehaviorSubject<List<Site>>();
  var entryList = BehaviorSubject<List<Entry>>();
  var selectedSite = BehaviorSubject<Site>();
  var todayEntryListOfSite = BehaviorSubject<Map<String, List<Entry>>>();

  Function(String) get changeErrorMessage => errorMessage.sink.add;

  Function(List<Site>) get changeSiteList => siteList.sink.add;

  Function(List<Entry>) get changeEmployeeList => entryList.sink.add;

  Function(Site) get changeSelectedSite => selectedSite.sink.add;

  Function(Map<String, List<Entry>>) get changeTodayEntryListOfSite =>
      todayEntryListOfSite.sink.add;

  @override
  Future<void> dispose() async {
    await errorMessage.drain();
    errorMessage.close();

    await siteList.drain();
    siteList.close();

    await entryList.drain();
    entryList.close();

    await selectedSite.drain();
    selectedSite.close();

    await todayEntryListOfSite.drain();
    todayEntryListOfSite.close();
  }

  getSiteList() {
    changeSiteList(_companyRepository.company.siteList);
    changeSelectedSite(_companyRepository.company.siteList.first);
    fetchEntry(selectedSite.value);
  }

  bool isToTrackTemp() {
    return _companyRepository.company.isToTrackTemperature;
  }

  bool isToTrackOxygenLevel() {
    return _companyRepository.company.isToTrackOxygenLevel;
  }

  bool isToTrackHeartRate() {
    return _companyRepository.company.isToTrackHeartRate;
  }

  void fetchEntry(Site site) {
    _entryRepository
        .getTodayEntryBySite(site, _companyRepository.company.id)
        .asStream()
        .listen((event) {
      changeTodayEntryListOfSite(event);
    });
  }

  bool isValidTrackData(double value) {
    return value != -1;
  }

  getTrackColor(int value) {
    return  value == 0 ? Colors.red : Colors.black;
  }
}
