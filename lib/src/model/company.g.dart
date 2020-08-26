// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'company.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Company _$CompanyFromJson(Map<String, dynamic> json) {
  return Company()
    ..name = json['name'] as String
    ..licenceNumber = json['licenceNumber'] as String
    ..country = json['country'] == null
        ? null
        : Country.fromJson(json['country'] as Map<String, dynamic>)
    ..mobileNumber = json['mobileNumber'] as String
    ..documentUrl = json['documentUrl'] as String
    ..siteList = (json['siteList'] as List)
        ?.map(
            (e) => e == null ? null : Site.fromJson(e as Map<String, dynamic>))
        ?.toList()
    ..isToTrackTemperature = json['isToTrackTemperature'] as bool
    ..isToTrackHeartRate = json['isToTrackHeartRate'] as bool
    ..isToTrackOxygenLevel = json['isToTrackOxygenLevel'] as bool
    ..isToTrackCough = json['isToTrackCough'] as bool
    ..isToTrackRunningNose = json['isToTrackRunningNose'] as bool
    ..isToTrackSoreThroat = json['isToTrackSoreThroat'] as bool
    ..isToTrackShortnessOfBreath = json['isToTrackShortnessOfBreath'] as bool;
}

Map<String, dynamic> _$CompanyToJson(Company instance) => <String, dynamic>{
      'name': instance.name,
      'licenceNumber': instance.licenceNumber,
      'country': instance.country?.toJson(),
      'mobileNumber': instance.mobileNumber,
      'documentUrl': instance.documentUrl,
      'siteList': instance.siteList?.map((e) => e?.toJson())?.toList(),
      'isToTrackTemperature': instance.isToTrackTemperature,
      'isToTrackHeartRate': instance.isToTrackHeartRate,
      'isToTrackOxygenLevel': instance.isToTrackOxygenLevel,
      'isToTrackCough': instance.isToTrackCough,
      'isToTrackRunningNose': instance.isToTrackRunningNose,
      'isToTrackSoreThroat': instance.isToTrackSoreThroat,
      'isToTrackShortnessOfBreath': instance.isToTrackShortnessOfBreath,
    };
