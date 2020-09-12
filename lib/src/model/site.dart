import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:safe_work_together/src/entities/site_entity.dart';

part 'site.g.dart';

@JsonSerializable(explicitToJson: true)
class Site {

  @JsonKey(ignore: true)
  String id;
  String name;
  int perDaySubmit;
  @JsonKey(ignore: true)
  bool isSelected = false;

  Site(this.name, this.perDaySubmit);

  factory Site.fromJson(Map<String, dynamic> json) => _$SiteFromJson(json);

  Map<String, dynamic> toJson() => _$SiteToJson(this);
}
