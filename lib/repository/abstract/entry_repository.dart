
import 'package:safe_work_together/src/model/models.dart';

abstract class EntryRepositoryAbstract{
  Future<bool> addEntry(Entry entry);
  Future<int> getEmployeeTodayEntry(String empId, String employerId);
}