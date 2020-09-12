import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:safe_work_together/constants/fire_store_collection.dart';
import 'package:safe_work_together/constants/fire_store_key.dart';
import 'package:safe_work_together/constants/sharedprefkey.dart';
import 'package:safe_work_together/src/model/entry.dart';
import 'package:jiffy/jiffy.dart';
import 'package:safe_work_together/src/model/site.dart';
import 'package:safe_work_together/util/date_utl.dart';
import 'package:safe_work_together/util/sharedpreference.dart';
import 'abstract/abstract_repository.dart';
import 'package:supercharged/supercharged.dart';

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
    final QuerySnapshot result = await _entryCollection
        .where(FS_KEY_EMPLOYEE_ID, isEqualTo: empId)
        .where(FS_KEY_EMPLOYER_ID, isEqualTo: employerId)
        .where(FS_KEY_DATE,
            isGreaterThanOrEqualTo: DateUtil().generateTodayStartTime())
        .where(FS_KEY_DATE,
            isLessThanOrEqualTo: DateUtil().generateTodayEndTime())
        .getDocuments();
    print(result.documents.length);

    return result.documents.length;
  }

  Future<Map<String, List<Entry>>> getTodayEntryBySite(Site site, String id) async {
    var todayEntryDocumentSnapshot = (await _entryCollection
            .where(FS_KEY_SITE_LIST, arrayContains: site.toJson())
            .where(FS_KEY_EMPLOYER_ID, isEqualTo: id)
            .where(FS_KEY_DATE,
                isGreaterThanOrEqualTo: DateUtil().generateTodayStartTime())
            .where(FS_KEY_DATE,
                isLessThanOrEqualTo: DateUtil().generateTodayEndTime())
            .orderBy(FS_KEY_DATE)
            .orderBy(FS_KEY_EMPLOYEE_NAME)
            .getDocuments())
        .documents;
    if(todayEntryDocumentSnapshot.length>0) {
      try {

        List<Entry> entryList = todayEntryDocumentSnapshot
          .map((e) {
        Entry entry = Entry.fromJson(e.data);
        entry.id = e.documentID;
        return entry;
      }).toList();
      print("Size:" + entryList.toString());
        final newMap = entryList.groupBy<String, Entry>(
              (item) => item.employeeId,
        );
        newMap.forEach((k, v) => print("Key : $k, Value : $v"));
        return newMap;
      } catch (e) {
        print(e);
      }
    }
    return Map();
  }
}
