// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'employee.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Employee _$EmployeeFromJson(Map<String, dynamic> json) {
  return Employee(
    name: json['name'] as String,
    email: json['email'] as String,
    imageUrl: json['imageUrl'] as String,
    mobileNumber: json['mobileNumber'] as String,
  )
    ..employeeId = json['employeeId'] as String
    ..employeeName = json['employeeName'] as String
    ..employerId = json['employerId'] as String
    ..siteList = (json['siteList'] as List)
        ?.map(
            (e) => e == null ? null : Site.fromJson(e as Map<String, dynamic>))
        ?.toList();
}

Map<String, dynamic> _$EmployeeToJson(Employee instance) => <String, dynamic>{
      'name': instance.name,
      'email': instance.email,
      'imageUrl': instance.imageUrl,
      'mobileNumber': instance.mobileNumber,
      'employeeId': instance.employeeId,
      'employeeName': instance.employeeName,
      'employerId': instance.employerId,
      'siteList': instance.siteList?.map((e) => e?.toJson())?.toList(),
    };
