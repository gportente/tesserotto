import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../l10n/app_localizations.dart';
import '../providers/fidelity_cards_provider.dart';
import '../providers/google_drive_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:io';
import '../models/fidelity_card.dart';

class ImportExportScreen extends ConsumerStatefulWidget {
  const ImportExportScreen({super.key});

  @override
  ConsumerState<ImportExportScreen> createState() =>
      _ImportExportScreenState();
}

class _ImportExportScreenState extends ConsumerState<ImportExportScreen> {
  String? _lastBackup;
  bool _isDriveLoading = false;

  bool get _isMobile =>
      !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  @override
  void initState() {
    super.initState();
    _loadLastBackup();
  }

  Future<void> _loadLastBackup() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _lastBackup = prefs.getString('drive_last_backup');
    });
  }

  Future<void> _saveLastBackup() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now().toIso8601String();
    await prefs.setString('drive_last_backup', now);
    setState(() {
      _lastBackup = now;
    });
  }

  Future<void> _googleSignIn() async {
    await ref.read(driveAuthProvider.notifier).signIn();
  }

  Future<void> _googleSignOut() async {
    await ref.read(driveAuthProvider.notifier).signOut();
  }

  Future<void> _backupToDrive() async {
    setState(() => _isDriveLoading = true);
    try {
      final cards = ref.read(fidelityCardsProvider);
      final service = ref.read(googleDriveServiceProvider);
      await service.backupCards(cards);
      await _saveLastBackup();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(AppLocalizations.of(context)!.driveBackupSuccess),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(AppLocalizations.of(context)!.driveBackupError),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      setState(() => _isDriveLoading = false);
    }
  }

  Future<void> _restoreFromDrive() async {
    final loc = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(loc.driveRestoreConfirmTitle),
        content: Text(loc.driveRestoreConfirmContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(loc.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(loc.driveRestoreButton),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isDriveLoading = true);
    try {
      final service = ref.read(googleDriveServiceProvider);
      final cards = await service.restoreCards();
      if (cards == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text(AppLocalizations.of(context)!.driveNoBackupFound),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
        return;
      }
      await ref
          .read(fidelityCardsProvider.notifier)
          .importCards(cards);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(AppLocalizations.of(context)!.driveRestoreSuccess),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(AppLocalizations.of(context)!.driveRestoreError),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      setState(() => _isDriveLoading = false);
    }
  }

  Future<void> _exportCards() async {
    try {
      final cards = ref.read(fidelityCardsProvider);
      final json = jsonEncode(cards.map((c) => c.toJson()).toList());
      String? outputPath = await FilePicker.platform.saveFile(
        dialogTitle: 'Select where to save the backup',
        fileName: 'backup_tessere.json',
        type: FileType.custom,
        allowedExtensions: ['json'],
        bytes: Uint8List.fromList(json.codeUnits),
      );
      if (outputPath == null) {
        return;
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(AppLocalizations.of(context)!.exportSuccess),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.exportError),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _importCards() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null) {
        final file = File(result.files.single.path!);
        String jsonString;
        try {
          jsonString = await file.readAsString(encoding: utf8);
        } catch (e) {
          try {
            jsonString = await file.readAsString(encoding: latin1);
          } catch (e) {
            throw Exception(
                'Impossibile leggere il file. Formato non supportato.');
          }
        }

        try {
          final List<dynamic> jsonList = jsonDecode(jsonString);
          final cards =
              jsonList.map((json) => FidelityCard.fromJson(json)).toList();
          await ref
              .read(fidelityCardsProvider.notifier)
              .importCards(cards);

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content:
                    Text(AppLocalizations.of(context)!.importSuccess),
                backgroundColor: Theme.of(context).colorScheme.primary,
              ),
            );
          }
        } catch (e) {
          throw Exception('Formato JSON non valido: ${e.toString()}');
        }
      }
    } catch (e) {
      if (mounted) {
        print(e.toString());
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(AppLocalizations.of(context)!.importError),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _importFromCatima() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['txt', 'csv'],
      );

      if (result != null) {
        final file = File(result.files.single.path!);
        final content = await file.readAsString();
        final lines = content.split('\n');

        int startIndex = 0;
        for (int i = 0; i < lines.length; i++) {
          if (lines[i].contains('_id,store,note')) {
            startIndex = i;
            break;
          }
        }

        final cards = <FidelityCard>[];
        int counter = 0;
        for (int i = startIndex + 1; i < lines.length; i++) {
          final line = lines[i].trim();
          if (line.isEmpty) continue;

          final parts = line.split(',');
          if (parts.length < 4) continue;

          final store = parts[1];
          final note = parts[2];
          final barcode = parts[7];
          final barcodeType = _mapCatimaBarcodeType(parts[9]);
          final colorValue = int.tryParse(parts[10]);

          cards.add(FidelityCard(
            id: 'catima_${DateTime.now().millisecondsSinceEpoch}_$counter',
            name: store,
            description: note,
            barcode: barcode,
            barcodeType: barcodeType,
            openCount: 0,
            colorValue: colorValue,
            createdAt: DateTime.now(),
          ));
          counter++;
        }

        await ref
            .read(fidelityCardsProvider.notifier)
            .importCards(cards);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text(AppLocalizations.of(context)!.importSuccess),
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(AppLocalizations.of(context)!.importError),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  String? _mapCatimaBarcodeType(String? catimaType) {
    if (catimaType == null) return null;

    switch (catimaType.toUpperCase()) {
      case 'UPC_A':
        return 'upcA';
      case 'EAN_13':
        return 'ean13';
      case 'EAN_8':
        return 'ean8';
      case 'UPC_E':
        return 'upcE';
      case 'CODE_128':
        return 'code128';
      case 'CODE_39':
        return 'code39';
      case 'ITF':
        return 'itf';
      case 'PDF_417':
        return 'pdf417';
      case 'AZTEC':
        return 'aztec';
      case 'DATA_MATRIX':
        return 'dataMatrix';
      case 'CODABAR':
        return 'codabar';
      case 'QR_CODE':
        return 'qrCode';
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;
    final driveAccount = ref.watch(driveAuthProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.importExport),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_isMobile) ...[
              _buildDriveSection(context, theme, loc, driveAccount),
              const SizedBox(height: 16),
            ],
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      loc.exportCards,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      loc.exportDescription,
                      style: GoogleFonts.poppins(
                        color:
                            theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _exportCards,
                      icon: const Icon(Icons.upload_file),
                      label: Text(loc.export),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                        minimumSize: const Size(double.infinity, 48),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      loc.importCards,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      loc.importDescription,
                      style: GoogleFonts.poppins(
                        color:
                            theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _importCards,
                      icon: const Icon(Icons.download),
                      label: Text(loc.importCard),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                        minimumSize: const Size(double.infinity, 48),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            /*
            const SizedBox(height: 16),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      loc.importFromCatima,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      loc.importFromCatimaDescription,
                      style: GoogleFonts.poppins(
                        color:
                            theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _importFromCatima,
                      icon: const Icon(Icons.download),
                      label: Text(loc.importFromCatima),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.secondary,
                        foregroundColor: theme.colorScheme.onSecondary,
                        minimumSize: const Size(double.infinity, 48),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            */
          ],
        ),
      ),
    );
  }

  Widget _buildDriveSection(
    BuildContext context,
    ThemeData theme,
    AppLocalizations loc,
    dynamic driveAccount,
  ) {
    final isLoggedIn = driveAccount != null;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.cloud, size: 22),
                const SizedBox(width: 8),
                Text(
                  loc.driveBackupSection,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (!isLoggedIn)
              ElevatedButton.icon(
                onPressed: _googleSignIn,
                icon: const Icon(Icons.login),
                label: Text(loc.driveSignIn),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  minimumSize: const Size(double.infinity, 48),
                ),
              )
            else ...[
              Row(
                children: [
                  Expanded(
                    child: Chip(
                      avatar: const Icon(Icons.account_circle, size: 18),
                      label: Text(
                        loc.driveSignedInAs(driveAccount.email),
                        style: GoogleFonts.poppins(fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: _googleSignOut,
                    child: Text(loc.driveSignOut),
                  ),
                ],
              ),
            ],
            if (_lastBackup != null) ...[
              const SizedBox(height: 8),
              Text(
                loc.driveLastBackup(
                  _formatDate(_lastBackup!),
                ),
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
            const SizedBox(height: 12),
            if (_isDriveLoading)
              const Center(child: CircularProgressIndicator())
            else ...[
              ElevatedButton.icon(
                onPressed: isLoggedIn ? _backupToDrive : null,
                icon: const Icon(Icons.backup),
                label: Text(loc.driveBackupNow),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: isLoggedIn ? _restoreFromDrive : null,
                icon: const Icon(Icons.restore),
                label: Text(loc.driveRestoreButton),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.secondary,
                  foregroundColor: theme.colorScheme.onSecondary,
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(String isoString) {
    try {
      final dt = DateTime.parse(isoString).toLocal();
      return '${dt.day.toString().padLeft(2, '0')}/'
          '${dt.month.toString().padLeft(2, '0')}/'
          '${dt.year} '
          '${dt.hour.toString().padLeft(2, '0')}:'
          '${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return isoString;
    }
  }
}
