// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'site.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Site _$SiteFromJson(Map<String, dynamic> json) {
  return Site(
    json['name'] as String,
    json['perDaySubmit'] as int,
  );
}

Map<String, dynamic> _$SiteToJson(Site instance) => <String, dynamic>{
      'name': instance.name,
      'perDaySubmit': instance.perDaySubmit,
    };
