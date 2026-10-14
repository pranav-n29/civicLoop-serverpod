import 'dart:typed_data';

import 'custom_image_picker_stub.dart'
    if (dart.library.js_interop) 'custom_image_picker_web.dart';

/// Data representing an image picked by the citizen.
class PickedFileData {
  final String fileName;
  final Uint8List bytes;

  const PickedFileData({required this.fileName, required this.bytes});
}

/// Function signature for picking an image.
typedef ImagePickerFn = Future<PickedFileData?> Function();

/// Provides file picking for custom user photos across web and test environments.
class CustomImagePicker {
  /// Test hook to simulate file selection in widget/unit tests.
  static ImagePickerFn? pickCustomImageOverride;

  /// Prompts the user to pick an image or delegates to [pickCustomImageOverride].
  static Future<PickedFileData?> pickImage() async {
    if (pickCustomImageOverride != null) {
      return pickCustomImageOverride!();
    }
    return platformPickImage();
  }
}
