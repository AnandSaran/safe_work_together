import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:safe_work_together/src/entities/site_entity.dart';
import 'package:safe_work_together/src/model/country.dart';
import 'package:safe_work_together/src/model/site.dart';

part 'company.g.dart';

@JsonSerializable(explicitToJson: true)
class Company {
  @JsonKey(ignore: true)
  String id;
  String name;
  String licenceNumber;
  Country country;
  String mobileNumber;
  String documentUrl;
  List<Site> siteList;
  bool isToTrackTemperature;
  bool isToTrackHeartRate;
  bool isToTrackOxygenLevel;
  bool isToTrackCough;
  bool isToTrackRunningNose;
  bool isToTrackSoreThroat;
  bool isToTrackShortnessOfBreath;

  Company();

  factory Company.fromJson(Map<String, dynamic> json) =>
      _$CompanyFromJson(json);

  Map<String, dynamic> toJson() => _$CompanyToJson(this);

}
