import 'package:json_annotation/json_annotation.dart';
import 'package:safe_work_together/src/model/site.dart';
part 'employee.g.dart';

@JsonSerializable(explicitToJson: true)
class Employee {
  @JsonKey(ignore: true)
   String id;
   String email;
   String imageUrl;
   String mobileNumber;
   String employeeId;
   String employeeName;
   String employerId;
   List<Site> siteList;

  Employee({this.id, this.employeeName, this.email, this.imageUrl,this.mobileNumber});

  factory Employee.fromJson(Map<String, dynamic> json) =>
      _$EmployeeFromJson(json);

  Map<String, dynamic> toJson() => _$EmployeeToJson(this);
}
