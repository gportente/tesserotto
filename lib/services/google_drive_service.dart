import 'dart:convert';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import '../models/fidelity_card.dart';

class GoogleDriveService {
  static const String _backupFileName = 'backup_tessere.json';
  static const String _appDataFolder = 'appDataFolder';

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [drive.DriveApi.driveAppdataScope],
  );

  GoogleSignIn get googleSignIn => _googleSignIn;

  Future<GoogleSignInAccount?> signIn() async {
    return await _googleSignIn.signIn();
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
  }

  Future<bool> isSignedIn() async {
    return await _googleSignIn.isSignedIn();
  }

  Future<GoogleSignInAccount?> signInSilently() async {
    return await _googleSignIn.signInSilently();
  }

  Future<drive.DriveApi> _getDriveApi() async {
    final client = await _googleSignIn.authenticatedClient();
    if (client == null) {
      throw Exception('Not signed in');
    }
    return drive.DriveApi(client);
  }

  Future<void> backupCards(List<FidelityCard> cards) async {
    final api = await _getDriveApi();
    final json = jsonEncode(cards.map((c) => c.toJson()).toList());
    final bytes = utf8.encode(json);
    final media = drive.Media(
      Stream.fromIterable([bytes]),
      bytes.length,
      contentType: 'application/json',
    );

    final fileList = await api.files.list(
      spaces: _appDataFolder,
      q: "name='$_backupFileName'",
      $fields: 'files(id)',
    );

    if (fileList.files != null && fileList.files!.isNotEmpty) {
      final fileId = fileList.files!.first.id!;
      await api.files.update(drive.File(), fileId, uploadMedia: media);
    } else {
      final file = drive.File()
        ..name = _backupFileName
        ..parents = [_appDataFolder];
      await api.files.create(file, uploadMedia: media);
    }
  }

  Future<List<FidelityCard>?> restoreCards() async {
    final api = await _getDriveApi();

    final fileList = await api.files.list(
      spaces: _appDataFolder,
      q: "name='$_backupFileName'",
      $fields: 'files(id)',
    );

    if (fileList.files == null || fileList.files!.isEmpty) {
      return null;
    }

    final fileId = fileList.files!.first.id!;
    final response = await api.files.get(
      fileId,
      downloadOptions: drive.DownloadOptions.fullMedia,
    ) as drive.Media;

    final List<int> bytes = [];
    await for (final chunk in response.stream) {
      bytes.addAll(chunk);
    }

    final jsonString = utf8.decode(bytes);
    final List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList.map((json) => FidelityCard.fromJson(json)).toList();
  }
}
