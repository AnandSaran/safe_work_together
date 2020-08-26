import 'package:safe_work_together/src/model/models.dart';
import 'package:safe_work_together/constants/StringConstants.dart';

extension ListSiteExtension on List<Site> {
  String get generateSiteList {
    String site = ASSIGNED_SITES;
    for (var i = 0; i < length; i++) {
      site += this[i].name;
      if (i != length - 1) {
        site += SYMBOL_COMMA + WHITE_SPACE;
      } else {
        site += SYMBOL_DOT;
      }
    }
    return site;
  }
  
  int get generateMaxPerDaySubmit {
    int perDaySubmit = 0;
    for (var i = 0; i < length; i++) {
      if(perDaySubmit<this[i].perDaySubmit){
        perDaySubmit=this[i].perDaySubmit;
      }
    }
    return perDaySubmit;
  }
}
