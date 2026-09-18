import 'dart:io';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

class MediaService {
  final _uuid = const Uuid();

  /// Compresses and saves an image to the local sandbox file system.
  /// Returns the *relative* path to the file to ensure resilience against
  /// iOS sandbox directory UUID changes between app updates.
  Future<String> saveCompressedImage({
    required File rawFile,
    required String albumId,
    required String placeId,
  }) async {
    final appDir = await getApplicationDocumentsDirectory();
    final targetDir = Directory(
      p.join(appDir.path, 'albums', albumId, 'places', placeId),
    );

    if (!await targetDir.exists()) {
      await targetDir.create(recursive: true);
    }

    final filename = '${_uuid.v4()}.webp';
    final targetPath = p.join(targetDir.path, filename);

    // Compress the image (max 1920x1080) and convert to WebP
    final result = await FlutterImageCompress.compressAndGetFile(
      rawFile.absolute.path,
      targetPath,
      quality: 80,
      minWidth: 1920,
      minHeight: 1080,
      format: CompressFormat.webp,
    );

    if (result == null) {
      throw Exception('Failed to compress image');
    }

    // Return the relative path
    return p.relative(result.path, from: appDir.path);
  }

  /// Resolves a relative path (stored in Drift) back into an absolute file
  /// path for rendering in the UI.
  Future<File> getAbsoluteFile(String relativePath) async {
    final appDir = await getApplicationDocumentsDirectory();
    final absolutePath = p.join(appDir.path, relativePath);
    return File(absolutePath);
  }
}
