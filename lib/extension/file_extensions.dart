import 'dart:io';

extension FileExtention on FileSystemEntity{
  String get name {
    return this?.path?.split("/")?.last;
  }
}