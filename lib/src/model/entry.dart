import 'package:json_annotation/json_annotation.dart';
import 'package:safe_work_together/src/model/models.dart';

part 'entry.g.dart';


@JsonSerializable(explicitToJson: true)
class Entry {
  String employeeId;
  String employeeName;
  String employerId;
  double temperature;
  double heartRate;
  double oxygenLevel;
  int cough;
  int runningNose;
  int soreThroat;
  int shortnessOfBreath;
  @JsonKey(ignore: true)
  DateTime date;
  @JsonKey(ignore: true)
  String id;
  List<Site> siteList;

  Entry({
      this.employeeId,
      this.employeeName,
      this.employerId,
      this.temperature=-1,
      this.heartRate=-1,
      this.oxygenLevel=-1,
      this.cough=-1,
      this.runningNose=-1,
      this.soreThroat=-1,
      this.shortnessOfBreath=-1});


  factory Entry.fromJson(Map<String, dynamic> json) =>
      _$EntryFromJson(json);

  Map<String, dynamic> toJson() => _$EntryToJson(this);
}
