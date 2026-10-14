import 'dart:async';
import 'dart:js_interop';
import 'package:web/web.dart' as web;

import 'custom_image_picker.dart';

Future<PickedFileData?> platformPickImage() async {
  final completer = Completer<PickedFileData?>();
  final input = web.document.createElement('input') as web.HTMLInputElement;
  input.type = 'file';
  input.accept = '.jpg,.jpeg,.png,.webp,image/jpeg,image/png,image/webp';

  input.addEventListener(
    'change',
    (web.Event _) {
      final files = input.files;
      if (files == null || files.length == 0) {
        if (!completer.isCompleted) completer.complete(null);
        return;
      }
      final file = files.item(0);
      if (file == null) {
        if (!completer.isCompleted) completer.complete(null);
        return;
      }

      final reader = web.FileReader();
      reader.addEventListener(
        'loadend',
        (web.Event _) {
          final result = reader.result;
          if (result != null) {
            final arrayBuffer = result as JSArrayBuffer;
            final byteList = arrayBuffer.toDart.asUint8List();
            if (!completer.isCompleted) {
              completer.complete(
                PickedFileData(fileName: file.name, bytes: byteList),
              );
            }
          } else {
            if (!completer.isCompleted) completer.complete(null);
          }
        }.toJS,
      );

      reader.addEventListener(
        'error',
        (web.Event _) {
          if (!completer.isCompleted) {
            completer.completeError('Failed to read selected file.');
          }
        }.toJS,
      );

      reader.readAsArrayBuffer(file);
    }.toJS,
  );

  input.click();
  return completer.future;
}
