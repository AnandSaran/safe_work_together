import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:safe_work_together/constants/fire_store_key.dart';
import 'package:safe_work_together/constants/sharedprefkey.dart';
import 'package:safe_work_together/constants/fire_store_collection.dart';
import 'package:safe_work_together/repository/abstract/abstract_repository.dart';
import 'package:safe_work_together/repository/company_repository.dart';
import 'package:safe_work_together/src/model/company.dart';
import 'package:safe_work_together/util/sharedpreference.dart';

class CompanyRepository implements CompanyRepositoryAbstract {
  final _companyCollection = Firestore.instance.collection(COL_COMPANY);
  Company company;

  @override
  Future<void> deleteCompany(String documentId) {
    return _companyCollection.document(documentId).delete();
  }

  @override
  Future<bool> addCompany(Company company) async {
    return _companyCollection.add(company.toJson()).then((value) {
      SharedPreferenceUtil()
          .setString(SHARED_PREF_KEY_COMPANY_ID, value.documentID);
      print("Company Added");
      return true;
    }).catchError((error) {
      print("Failed to add company: $error");
      return false;
    });
  }

  @override
  Future<bool> isCompanyNotRegistered(Company company) async {
    final QuerySnapshot result = await _companyCollection
        .where(FS_KEY_LICENCE_NUMBER, isEqualTo: company.licenceNumber)
        .where(FS_KEY_MOBILE_NUMBER, isEqualTo: company.mobileNumber)
        .getDocuments();
    final List<DocumentSnapshot> docs = result.documents;
    if (docs.length == 0) {
      return true;
    } else {
      SharedPreferenceUtil()
          .setString(SHARED_PREF_KEY_COMPANY_ID, docs[0].documentID);
      return false;
    }
  }

  @override
  Future<Company> getCompany(String companyId) async {
    final DocumentSnapshot result =
        await _companyCollection.document(companyId).get();
    company = Company.fromJson(result.data);
    company.id = result.documentID;
    return company;
  }

  @override
  Future<void> updateCompany(Company company) {
    // TODO: implement updateCompany
    throw UnimplementedError();
  }

  Future<List<Company>> fetchCompanyList() async {
    try {
      var companyListDocumentSnapshot =
          (await _companyCollection.orderBy(FS_KEY_NAME).getDocuments())
              .documents;
      var companyList = companyListDocumentSnapshot.map((e) {
        Company company = Company.fromJson(e.data);
        company.id = e.documentID;
        return company;
      }).toList();
      return companyList;
    } catch (e) {
      print(e.toString());
      return List();
    }
  }
}
