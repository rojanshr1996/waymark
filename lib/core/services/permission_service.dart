import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  /// Requests location permission (When In Use).
  Future<bool> requestLocationPermission() async {
    final status = await Permission.locationWhenInUse.request();
    return status.isGranted;
  }

  /// Requests photos permission.
  /// On iOS this requests photo library, on Android it requests read media.
  Future<bool> requestPhotosPermission() async {
    final status = await Permission.photos.request();
    if (status.isGranted) return true;

    // Fallback for older Android versions
    final storageStatus = await Permission.storage.request();
    return storageStatus.isGranted;
  }

  /// Requests camera permission.
  Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  /// Checks if location is already granted.
  Future<bool> get isLocationGranted async {
    return await Permission.locationWhenInUse.isGranted;
  }

  /// Checks if photos is already granted.
  Future<bool> get isPhotosGranted async {
    return await Permission.photos.isGranted ||
        await Permission.storage.isGranted;
  }

  /// Checks if camera is already granted.
  Future<bool> get isCameraGranted async {
    return await Permission.camera.isGranted;
  }
}
