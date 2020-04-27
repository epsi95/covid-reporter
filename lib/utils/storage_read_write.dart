import 'dart:async';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

class StorageReadWrite {
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/covid_app_data.txt');
  }

  // read from file
  Future<String> readFile() async {
    try {
      final file = await _localFile;

      // Read the file.
      String contents = await file.readAsString();

      return contents;
    } catch (e) {
      // If encountering an error, return 0.
      print("no such file exists");
      return "error";
    }
  }

  //write to file
  Future<File> writeFile(String encryptedUserID) async {
    final file = await _localFile;

    // Write the file.
    return file.writeAsString(encryptedUserID);
  }
}
