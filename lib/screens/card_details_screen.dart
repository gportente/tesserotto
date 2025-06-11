import 'package:fidelity_cards_manager/screens/add_card_screen.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../models/fidelity_card.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/fidelity_cards_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../widgets/delete_card_dialog.dart';
import 'package:screen_brightness/screen_brightness.dart';

class CardDetailsScreen extends ConsumerStatefulWidget {
  final FidelityCard card;
  const CardDetailsScreen({super.key, required this.card});

  @override
  ConsumerState<CardDetailsScreen> createState() => _CardDetailsScreenState();
}

class _CardDetailsScreenState extends ConsumerState<CardDetailsScreen> {
  late FidelityCard card;
  double? _previousBrightness;

  @override
  void initState() {
    super.initState();
    card = widget.card;
    _setMaxBrightness();
  }

  Future<void> _setMaxBrightness() async {
    try {
      // Save current brightness
      _previousBrightness = await ScreenBrightness().current;
      // Set brightness to maximum
      await ScreenBrightness().setScreenBrightness(1.0);
    } catch (e) {
      debugPrint('Failed to set brightness: $e');
    }
  }

  Future<void> _restoreBrightness() async {
    if (_previousBrightness != null) {
      try {
        await ScreenBrightness().setScreenBrightness(_previousBrightness!);
      } catch (e) {
        debugPrint('Failed to restore brightness: $e');
      }
    }
  }

  @override
  void dispose() {
    _restoreBrightness();
    super.dispose();
  }

  Color _getCardColor(String name) {
    final colors = [
      const Color(0xFF4F8FFF),
      const Color(0xFF6FE7DD),
      const Color(0xFFFFB86B),
      const Color(0xFFFC5C7D),
      const Color(0xFF43E97B),
      const Color(0xFF38F9D7),
      const Color(0xFF667EEA),
      const Color(0xFF764BA2),
      const Color(0xFFFF6A6A),
      const Color(0xFF36D1C4),
    ];
    final hash = name.isNotEmpty ? name.codeUnits.reduce((a, b) => a + b) : 0;
    return colors[hash % colors.length];
  }

  bool _isValidBarcode(String data, String? type) {
    switch (type) {
      case 'upcA':
        return RegExp(r'^\d{12}$').hasMatch(data);
      case 'ean13':
        return RegExp(r'^\d{13}$').hasMatch(data);
      case 'ean8':
        return RegExp(r'^\d{8}$').hasMatch(data);
      case 'upcE':
        return RegExp(r'^\d{8}$').hasMatch(data);
      case 'code128':
      case 'code39':
      case 'code93':
        return data.isNotEmpty;
      case 'itf':
        return data.isNotEmpty && data.length % 2 == 0;
      case 'qrCode':
      case 'aztec':
      case 'dataMatrix':
      case 'pdf417':
        return data.isNotEmpty;
      case 'codabar':
        return data.isNotEmpty;
      default:
        return false;
    }
  }

  Widget _buildBarcodeWidget(String data, String? type) {
    if (!_isValidBarcode(data, type)) {
      return Column(
        children: [
          QrImageView(
            data: data,
            version: QrVersions.auto,
            size: 200.0,
            backgroundColor: Colors.white,
          ),
          const SizedBox(height: 8),
          Text(
            'Invalid for $type, shown as QR',
            style: const TextStyle(color: Colors.red, fontSize: 13),
          ),
        ],
      );
    }
    switch (type) {
      case 'qrCode':
        return QrImageView(
          data: data,
          version: QrVersions.auto,
          size: 200.0,
          backgroundColor: Colors.white,
        );
      case 'ean13':
        return BarcodeWidget(
          barcode: Barcode.ean13(),
          data: data,
          width: 250,
          height: 80,
          backgroundColor: Colors.white,
        );
      case 'ean8':
        return BarcodeWidget(
          barcode: Barcode.ean8(),
          data: data,
          width: 200,
          height: 80,
          backgroundColor: Colors.white,
        );
      case 'code128':
        return BarcodeWidget(
          barcode: Barcode.code128(),
          data: data,
          width: 250,
          height: 80,
          backgroundColor: Colors.white,
        );
      case 'code39':
        return BarcodeWidget(
          barcode: Barcode.code39(),
          data: data,
          width: 250,
          height: 80,
          backgroundColor: Colors.white,
        );
      case 'upcA':
        return BarcodeWidget(
          barcode: Barcode.upcA(),
          data: data,
          width: 250,
          height: 80,
          backgroundColor: Colors.white,
        );
      case 'upcE':
        return BarcodeWidget(
          barcode: Barcode.upcE(),
          data: data,
          width: 200,
          height: 80,
          backgroundColor: Colors.white,
        );
      case 'itf':
        return BarcodeWidget(
          barcode: Barcode.itf(),
          data: data,
          width: 250,
          height: 80,
          backgroundColor: Colors.white,
        );
      case 'pdf417':
        return BarcodeWidget(
          barcode: Barcode.pdf417(),
          data: data,
          width: 250,
          height: 80,
          backgroundColor: Colors.white,
        );
      case 'codabar':
        return BarcodeWidget(
          barcode: Barcode.codabar(),
          data: data,
          width: 250,
          height: 80,
          backgroundColor: Colors.white,
        );
      case 'aztec':
	  	return BarcodeWidget(
          barcode: Barcode.aztec(),
          data: data,
          width: 250,
          height: 80,
          backgroundColor: Colors.white,
        );
      case 'dataMatrix':
	  	return BarcodeWidget(
          barcode: Barcode.dataMatrix(),
          data: data,
          width: 250,
          height: 80,
          backgroundColor: Colors.white,
        );
      case 'code93':
        return BarcodeWidget(
          barcode: Barcode.code93(),
          data: data,
          width: 250,
          height: 80,
          backgroundColor: Colors.white,
        );
      default:
        return QrImageView(
          data: data,
          version: QrVersions.auto,
          size: 200.0,
          backgroundColor: Colors.white,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cards = ref.watch(fidelityCardsProvider);
    // Aggiorna la card se è cambiata nel provider
    final updated = cards.firstWhere((c) => c.id == card.id, orElse: () => card);
    card = updated;
    final theme = Theme.of(context);
    final cardColor = card.colorValue != null
        ? Color(card.colorValue!)
        : _getCardColor(card.name);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: cardColor,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(AppLocalizations.of(context)!.cardInfo),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Edit Card',
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddCardScreen(cardToEdit: card),
                ),
              );
              setState(() {}); // forza il rebuild dopo la modifica
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            tooltip: 'Delete Cardd',
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => DeleteCardDialog(
                  cardName: card.name,
                  loc: AppLocalizations.of(context)!,
                ),
              );
              if (confirm == true) {
                ref.read(fidelityCardsProvider.notifier).removeCard(card.id);
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            height: 140,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [cardColor, cardColor.withOpacity(0.7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(36),
                bottomRight: Radius.circular(36),
              ),
            ),
            child: Stack(
              children: [
                // Faint initial watermark
                Positioned(
                  left: 32,
                  top: 0,
                  bottom: 0,
                  child: Opacity(
                    opacity: 0.10,
                    child: Text(
                      card.name.isNotEmpty ? card.name[0].toUpperCase() : '?',
                      style: TextStyle(
                        fontSize: 110,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -8,
                        color: theme.colorScheme.onPrimary.withOpacity(0.15),
                      ),
                    ),
                  ),
                ),
                // Card name
                Center(
                  child: Text(
                    card.name,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (card.description.isNotEmpty) ...[
                    Text(
                      card.description,
                      style: GoogleFonts.poppins(fontSize: 18, color: theme.colorScheme.onSurface),
                    ),
                    const SizedBox(height: 24),
                  ],
                  if (card.barcode != null) ...[
                    Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      color: theme.colorScheme.surface,
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          children: [
                            Text(
                              AppLocalizations.of(context)!.barcode,
                              style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface),
                            ),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: _buildBarcodeWidget(card.barcode!, card.barcodeType),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              card.barcode!,
                              style: GoogleFonts.poppins(fontSize: 16, color: theme.colorScheme.onSurface),
                            ),
                            if (card.barcodeType != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                'Type: ${card.barcodeType}',
                                style: GoogleFonts.poppins(fontSize: 14, color: theme.colorScheme.onSurface.withOpacity(0.7)),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
} 