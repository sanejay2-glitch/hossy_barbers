import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';

class AdminImageFile {
  const AdminImageFile({required this.name, required this.bytes});

  final String name;
  final Uint8List bytes;
}

class AdminImagePicker {
  const AdminImagePicker();

  Future<AdminImageFile?> pick() async {
    final file = await FilePicker.pickFile(type: FileType.image);
    if (file == null) return null;
    return AdminImageFile(name: file.name, bytes: await file.readAsBytes());
  }
}
