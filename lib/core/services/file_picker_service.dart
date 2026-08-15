import 'dart:io';

import 'package:file_picker/file_picker.dart';

class FilePickerService {
  Future<File?> pickPdf() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: false,
    );
    final path = result?.files.single.path;
    if (path == null) return null;
    return File(path);
  }
}
