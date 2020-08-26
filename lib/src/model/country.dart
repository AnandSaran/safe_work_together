import 'package:json_annotation/json_annotation.dart';

part 'country.g.dart';

@JsonSerializable(explicitToJson: true)
class Country {
   String name;
   String isoCode;
   String iso3Code;
   String phoneCode;


   Country(this.name, this.isoCode, this.iso3Code, this.phoneCode);

  factory Country.fromJson(Map<String, dynamic> json) => _$CountryFromJson(json);

  Map<String, dynamic> toJson() => _$CountryToJson(this);

  }
