// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'country.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Country _$CountryFromJson(Map<String, dynamic> json) {
  return Country(
    json['name'] as String,
    json['isoCode'] as String,
    json['iso3Code'] as String,
    json['phoneCode'] as String,
  );
}

Map<String, dynamic> _$CountryToJson(Country instance) => <String, dynamic>{
      'name': instance.name,
      'isoCode': instance.isoCode,
      'iso3Code': instance.iso3Code,
      'phoneCode': instance.phoneCode,
    };
