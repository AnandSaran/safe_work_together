import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:safe_work_together/constants/fire_store_collection.dart';
import 'package:safe_work_together/constants/fire_store_key.dart';
import 'package:safe_work_together/constants/sharedprefkey.dart';
import 'package:safe_work_together/src/model/entry.dart';
import 'package:jiffy/jiffy.dart';
import 'package:safe_work_together/util/sharedpreference.dart';
import 'abstract/abstract_repository.dart';

class EntryRepository implements EntryRepositoryAbstract {
  final _entryCollection = Firestore.instance.collection(COL_ENTRY);

  @override
  Future<bool> addEntry(Entry entry) async {
    var entryMap = entry.toJson();
    entryMap.putIfAbsent(FS_KEY_DATE, () => FieldValue.serverTimestamp());
    return _entryCollection.add(entryMap).then((value) {
      print("Entry created");
      return true;
    }).catchError((error) {
      print("Failed to add entry: $error");
      return false;
    });
  }

  @override
  Future<int> getEmployeeTodayEntry(String empId, String employerId) async {
    var startTime = (Jiffy().startOf(Units.DAY));
    var endTime = (Jiffy().endOf(Units.DAY).toUtc());

    final QuerySnapshot result = await _entryCollection
        .where(FS_KEY_EMPLOYEE_ID, isEqualTo: empId)
        .where(FS_KEY_EMPLOYER_ID, isEqualTo: employerId)
        .where(FS_KEY_DATE,
            isGreaterThanOrEqualTo: DateTime.fromMicrosecondsSinceEpoch(
                    startTime.microsecondsSinceEpoch)
                .toUtc())
        .where(FS_KEY_DATE,
            isLessThanOrEqualTo: DateTime.fromMicrosecondsSinceEpoch(
                    endTime.microsecondsSinceEpoch)
                .toUtc())
        .getDocuments();
    print(result.documents.length);

    return result.documents.length;
  }
}
