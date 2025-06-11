import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../providers/fidelity_cards_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:convert';
import 'dart:io';
import '../models/fidelity_card.dart';
import 'dart:typed_data';

class ImportExportScreen extends ConsumerWidget {
  const ImportExportScreen({super.key});
	

  Future<void> _exportCards(BuildContext context, WidgetRef ref) async {
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
        // Utente ha annullato
        return;
      }
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.exportSuccess),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.exportError),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _importCards(BuildContext context, WidgetRef ref) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null) {
        final file = File(result.files.single.path!);
        String jsonString;
        try {
          // Prova prima con UTF-8
          jsonString = await file.readAsString(encoding: utf8);
        } catch (e) {
          try {
            // Se fallisce, prova con Latin1
            jsonString = await file.readAsString(encoding: latin1);
          } catch (e) {
            throw Exception('Impossibile leggere il file. Formato non supportato.');
          }
        }

        try {
          final List<dynamic> jsonList = jsonDecode(jsonString);
          final cards = jsonList.map((json) => FidelityCard.fromJson(json)).toList();
          await ref.read(fidelityCardsProvider.notifier).importCards(cards);

          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(AppLocalizations.of(context)!.importSuccess),
                backgroundColor: Colors.green,
              ),
            );
          }
        } catch (e) {
          throw Exception('Formato JSON non valido: ${e.toString()}');
        }
      }
    } catch (e) {
      if (context.mounted) {
				print(e.toString());
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.importError),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _importFromCatima(BuildContext context, WidgetRef ref) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['txt', 'csv'],
      );

      if (result != null) {
        final file = File(result.files.single.path!);
        final content = await file.readAsString();
        final lines = content.split('\n');
        
        // Skip header lines until we find the data
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

        await ref.read(fidelityCardsProvider.notifier).importCards(cards);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.importSuccess),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.importError),
            backgroundColor: Colors.red,
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
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.importExport),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => _exportCards(context, ref),
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
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 16),
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
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => _importCards(context, ref),
                      icon: const Icon(Icons.download),
                      label: Text(loc.import),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                        minimumSize: const Size(double.infinity, 48),
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: () => _importFromCatima(context, ref),
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
          ],
        ),
      ),
    );
  }
} 