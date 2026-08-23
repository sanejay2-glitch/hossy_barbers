import 'dart:async';
import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

class AdminImageFile {
  const AdminImageFile({required this.name, required this.bytes});

  final String name;
  final Uint8List bytes;
}

class AdminImagePicker {
  const AdminImagePicker();

  Future<AdminImageFile?> pick() {
    final input = web.HTMLInputElement()
      ..type = 'file'
      ..accept = 'image/png,image/jpeg,image/webp'
      ..style.display = 'none';
    final completer = Completer<AdminImageFile?>();

    void finish(AdminImageFile? result) {
      input.remove();
      if (!completer.isCompleted) completer.complete(result);
    }

    input.addEventListener(
      'change',
      ((web.Event _) {
        final file = input.files?.item(0);
        if (file == null) {
          finish(null);
          return;
        }
        final reader = web.FileReader();
        reader.addEventListener(
          'loadend',
          ((web.Event _) {
            final buffer = reader.result as JSArrayBuffer?;
            final bytes = buffer?.toDart.asUint8List();
            if (bytes == null || bytes.isEmpty) {
              if (!completer.isCompleted) {
                completer.completeError(
                  StateError('The selected image could not be read.'),
                );
              }
              input.remove();
              return;
            }
            finish(AdminImageFile(name: file.name, bytes: bytes));
          }).toJS,
        );
        reader.addEventListener(
          'error',
          ((web.Event _) {
            input.remove();
            if (!completer.isCompleted) {
              completer.completeError(
                StateError('The selected image could not be read.'),
              );
            }
          }).toJS,
        );
        reader.readAsArrayBuffer(file);
      }).toJS,
    );

    web.document.body?.append(input);
    input.click();
    return completer.future;
  }
}
