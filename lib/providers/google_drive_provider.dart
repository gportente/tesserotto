import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../services/google_drive_service.dart';

final googleDriveServiceProvider = Provider<GoogleDriveService>((ref) {
  return GoogleDriveService();
});

class DriveAuthNotifier extends StateNotifier<GoogleSignInAccount?> {
  final GoogleDriveService _service;

  DriveAuthNotifier(this._service) : super(null) {
    _trySilentSignIn();
  }

  Future<void> _trySilentSignIn() async {
    final account = await _service.signInSilently();
    state = account;
  }

  Future<void> signIn() async {
    final account = await _service.signIn();
    state = account;
  }

  Future<void> signOut() async {
    await _service.signOut();
    state = null;
  }
}

final driveAuthProvider =
    StateNotifierProvider<DriveAuthNotifier, GoogleSignInAccount?>(
  (ref) => DriveAuthNotifier(ref.read(googleDriveServiceProvider)),
);
