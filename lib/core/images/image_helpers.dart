import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';

/// Icons and avatars are sent to the API as base64 strings and are kept small
/// on the device: at most [maxImageSize] px on the longest side, as JPEG.
const int maxImageSize = 256;
const int _jpegQuality = 85;

final ImagePicker _picker = ImagePicker();

/// Lets the user pick an image from the gallery and returns it resized and
/// JPEG-encoded, or null when the picker is cancelled.
Future<Uint8List?> pickCompressedImage() async {
  final picked = await _picker.pickImage(
    source: ImageSource.gallery,
    maxWidth: 1024,
    maxHeight: 1024,
  );
  if (picked == null) return null;
  return compressImage(await picked.readAsBytes());
}

/// Resizes [bytes] to fit within [maxImageSize] and re-encodes them as JPEG.
/// Returns the original bytes when they cannot be decoded.
Uint8List compressImage(Uint8List bytes) {
  final decoded = img.decodeImage(bytes);
  if (decoded == null) return bytes;

  final resized =
      decoded.width > maxImageSize || decoded.height > maxImageSize
          ? (decoded.width >= decoded.height
              ? img.copyResize(decoded, width: maxImageSize)
              : img.copyResize(decoded, height: maxImageSize))
          : decoded;
  final jpeg = Uint8List.fromList(img.encodeJpg(resized, quality: _jpegQuality));
  debugPrint('Image compressed: ${bytes.length} -> ${jpeg.length} bytes');
  return jpeg;
}

/// Encodes image bytes for the API.
String encodeImage(Uint8List bytes) => base64Encode(bytes);

/// Decodes a base64 image (a data URI prefix is tolerated) returned by the
/// API, or null when [value] is empty or malformed.
Uint8List? decodeImage(String? value) {
  if (value == null || value.isEmpty) return null;
  var data = value;
  final comma = data.indexOf(',');
  if (data.startsWith('data:') && comma != -1) {
    data = data.substring(comma + 1);
  }
  try {
    return base64Decode(base64.normalize(data.replaceAll(RegExp(r'\s+'), '')));
  } catch (_) {
    return null;
  }
}
