// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Entry _$EntryFromJson(Map<String, dynamic> json) {
  return Entry(
    employeeId: json['employeeId'] as String,
    employeeName: json['employeeName'] as String,
    employerId: json['employerId'] as String,
    temperature: (json['temperature'] as num)?.toDouble(),
    heartRate: (json['heartRate'] as num)?.toDouble(),
    oxygenLevel: (json['oxygenLevel'] as num)?.toDouble(),
    cough: json['cough'] as int,
    runningNose: json['runningNose'] as int,
    soreThroat: json['soreThroat'] as int,
    shortnessOfBreath: json['shortnessOfBreath'] as int,
  )..siteList = (json['siteList'] as List)
      ?.map((e) => e == null ? null : Site.fromJson(e as Map<String, dynamic>))
      ?.toList();
}

Map<String, dynamic> _$EntryToJson(Entry instance) => <String, dynamic>{
      'employeeId': instance.employeeId,
      'employeeName': instance.employeeName,
      'employerId': instance.employerId,
      'temperature': instance.temperature,
      'heartRate': instance.heartRate,
      'oxygenLevel': instance.oxygenLevel,
      'cough': instance.cough,
      'runningNose': instance.runningNose,
      'soreThroat': instance.soreThroat,
      'shortnessOfBreath': instance.shortnessOfBreath,
      'siteList': instance.siteList?.map((e) => e?.toJson())?.toList(),
    };
