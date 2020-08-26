import 'package:safe_work_together/src/model/company.dart';

abstract class CompanyRepositoryAbstract{

  Future<void> addCompany(Company company);

  Future<Company> getCompany(String companyId);

  Future<void> updateCompany(Company company);

  Future<void> deleteCompany(String companyId);

  Future<bool> isCompanyNotRegistered(Company company);

}