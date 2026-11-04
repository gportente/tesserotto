import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../l10n/app_localizations.dart';
import '../providers/fidelity_cards_provider.dart';
import '../providers/google_drive_provider.dart';
import '../theme/app_theme.dart';
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

  bool get _isMobile => !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  @override
  void initState() {
    super.initState();
    _loadLastBackup();
  }

  Future<void> _loadLastBackup() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _lastBackup = prefs.getString('drive_last_backup'));
  }

  Future<void> _saveLastBackup() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now().toIso8601String();
    await prefs.setString('drive_last_backup', now);
    setState(() => _lastBackup = now);
  }

  Future<void> _googleSignIn() async {
    await ref.read(driveAuthProvider.notifier).signIn();
  }

  Future<void> _googleSignOut() async {
    await ref.read(driveAuthProvider.notifier).signOut();
  }

  void _snack(String message, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
            error ? context.palette.danger : context.palette.accent,
      ),
    );
  }

  Future<void> _backupToDrive() async {
    setState(() => _isDriveLoading = true);
    try {
      final cards = ref.read(fidelityCardsProvider);
      final service = ref.read(googleDriveServiceProvider);
      await service.backupCards(cards);
      await _saveLastBackup();
      _snack(AppLocalizations.of(context)!.driveBackupSuccess);
    } catch (e) {
      debugPrint('DRIVE BACKUP ERROR: $e');
      _snack(AppLocalizations.of(context)!.driveBackupError, error: true);
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
          ElevatedButton(
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
        _snack(AppLocalizations.of(context)!.driveNoBackupFound, error: true);
        return;
      }
      await ref.read(fidelityCardsProvider.notifier).importCards(cards);
      _snack(AppLocalizations.of(context)!.driveRestoreSuccess);
    } catch (e) {
      _snack(AppLocalizations.of(context)!.driveRestoreError, error: true);
    } finally {
      setState(() => _isDriveLoading = false);
    }
  }

  Future<void> _exportCards() async {
    try {
      final cards = ref.read(fidelityCardsProvider);
      final json = jsonEncode(cards.map((c) => c.toJson()).toList());
      final outputPath = await FilePicker.platform.saveFile(
        dialogTitle: 'Select where to save the backup',
        fileName: 'backup_tessere.json',
        type: FileType.custom,
        allowedExtensions: ['json'],
        bytes: Uint8List.fromList(json.codeUnits),
      );
      if (outputPath == null) return;
      _snack(AppLocalizations.of(context)!.exportSuccess);
    } catch (e) {
      _snack(AppLocalizations.of(context)!.exportError, error: true);
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
          await ref.read(fidelityCardsProvider.notifier).importCards(cards);
          _snack(AppLocalizations.of(context)!.importSuccess);
        } catch (e) {
          throw Exception('Formato JSON non valido: ${e.toString()}');
        }
      }
    } catch (e) {
      _snack(AppLocalizations.of(context)!.importError, error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final loc = AppLocalizations.of(context)!;
    final driveAccount = ref.watch(driveAuthProvider);

    return Scaffold(
      appBar: AppBar(title: Text(loc.importExport)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_isMobile) ...[
              _buildDriveSection(context, p, loc, driveAccount),
              const SizedBox(height: AppSpacing.lg),
            ],
            _sectionCard(
              context: context,
              p: p,
              icon: Icons.ios_share_rounded,
              title: loc.exportCards,
              description: loc.exportDescription,
              child: ElevatedButton.icon(
                onPressed: _exportCards,
                icon: const Icon(Icons.upload_file_rounded),
                label: Text(loc.export),
                style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 52)),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            _sectionCard(
              context: context,
              p: p,
              icon: Icons.download_rounded,
              title: loc.importCards,
              description: loc.importDescription,
              child: ElevatedButton.icon(
                onPressed: _importCards,
                icon: const Icon(Icons.file_open_rounded),
                label: Text(loc.importCard),
                style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 52)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionCard({
    required BuildContext context,
    required AppPalette p,
    required IconData icon,
    required String title,
    String? description,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: p.hairline),
      ),
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: p.accentSoft,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Icon(icon, color: p.accent, size: 20),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                  child: Text(title, style: context.text.titleMedium)),
            ],
          ),
          if (description != null) ...[
            const SizedBox(height: AppSpacing.md),
            Text(description, style: context.text.bodyMedium),
          ],
          const SizedBox(height: AppSpacing.lg),
          child,
        ],
      ),
    );
  }

  Widget _buildDriveSection(
    BuildContext context,
    AppPalette p,
    AppLocalizations loc,
    dynamic driveAccount,
  ) {
    final isLoggedIn = driveAccount != null;

    return _sectionCard(
      context: context,
      p: p,
      icon: Icons.cloud_rounded,
      title: loc.driveBackupSection,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!isLoggedIn)
            ElevatedButton.icon(
              onPressed: _googleSignIn,
              icon: const Icon(Icons.login_rounded),
              label: Text(loc.driveSignIn),
              style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 52)),
            )
          else ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.account_circle_rounded, size: 20, color: p.inkSoft),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    driveAccount.email,
                    style: context.text.bodyMedium,
                    softWrap: true,
                  ),
                ),
              ],
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _googleSignOut,
                child: Text(loc.driveSignOut),
              ),
            ),
          ],
          if (_lastBackup != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              loc.driveLastBackup(_formatDate(_lastBackup!)),
              style: context.text.bodySmall?.copyWith(color: p.inkFaint),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          if (_isDriveLoading)
            const Center(child: Padding(
              padding: EdgeInsets.all(AppSpacing.sm),
              child: CircularProgressIndicator(),
            ))
          else ...[
            ElevatedButton.icon(
              onPressed: isLoggedIn ? _backupToDrive : null,
              icon: const Icon(Icons.backup_rounded),
              label: Text(loc.driveBackupNow),
              style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 52)),
            ),
            const SizedBox(height: AppSpacing.md),
            FilledButton.icon(
              onPressed: isLoggedIn ? _restoreFromDrive : null,
              icon: const Icon(Icons.restore_rounded),
              label: Text(loc.driveRestoreButton),
              style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 52)),
            ),
          ],
        ],
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
