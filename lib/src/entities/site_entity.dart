import 'package:cloud_firestore/cloud_firestore.dart';

class SiteEntity {
  final String id;
  final String name;
  final int perDaySubmit;

  SiteEntity(this.id,this.name, this.perDaySubmit);
  Map<String, Object> toJson() {
    return {
      'id': id,
      'name': name,
      'perDaySubmit': perDaySubmit,
    };
  }
  static SiteEntity fromJson(Map<String, Object> json){
    return SiteEntity(
      json['id'] as String,
      json['name'] as String,
      json['perDaySubmit'] as int,
    );
  }

  static SiteEntity fromSnapshot(DocumentSnapshot snap) {
    return SiteEntity(
      snap.documentID,
      snap.data['name'],
      snap.data['perDaySubmit'],
    );
  }

  Map<String, Object> toDocument() {
    return {
      'name': name,
      'perDaySubmit': perDaySubmit,
    };
  }

}