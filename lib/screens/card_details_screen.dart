import 'package:fidelity_cards_manager/screens/add_card_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/card_gradient_header.dart';
import '../widgets/page_transition.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../models/fidelity_card.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/fidelity_cards_provider.dart';
import '../providers/settings_provider.dart';
import '../l10n/app_localizations.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:share_plus/share_plus.dart';
import '../services/deep_link_service.dart';

class CardDetailsScreen extends ConsumerStatefulWidget {
  final FidelityCard card;
  const CardDetailsScreen({super.key, required this.card});

  @override
  ConsumerState<CardDetailsScreen> createState() => _CardDetailsScreenState();
}

class _CardDetailsScreenState extends ConsumerState<CardDetailsScreen> {
  late FidelityCard card;
  double? _previousBrightness;

  bool _brightnessBoosted = false;

  @override
  void initState() {
    super.initState();
    card = widget.card;
    if (ref.read(settingsProvider).autoBrightness) {
      _setMaxBrightness();
    }
  }

  Future<void> _setMaxBrightness() async {
    try {
      _previousBrightness = await ScreenBrightness().current;
      await ScreenBrightness().setScreenBrightness(1.0);
      _brightnessBoosted = true;
    } catch (e) {
      debugPrint('Failed to set brightness: $e');
    }
  }

  Future<void> _restoreBrightness() async {
    if (_brightnessBoosted && _previousBrightness != null) {
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
            style: TextStyle(color: context.palette.danger, fontSize: 13),
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
            backgroundColor: Colors.white);
      case 'ean13':
        return BarcodeWidget(
            barcode: Barcode.ean13(),
            data: data,
            width: 250,
            height: 80,
            backgroundColor: Colors.white);
      case 'ean8':
        return BarcodeWidget(
            barcode: Barcode.ean8(),
            data: data,
            width: 200,
            height: 80,
            backgroundColor: Colors.white);
      case 'code128':
        return BarcodeWidget(
            barcode: Barcode.code128(),
            data: data,
            width: 250,
            height: 80,
            backgroundColor: Colors.white);
      case 'code39':
        return BarcodeWidget(
            barcode: Barcode.code39(),
            data: data,
            width: 250,
            height: 80,
            backgroundColor: Colors.white);
      case 'upcA':
        return BarcodeWidget(
            barcode: Barcode.upcA(),
            data: data,
            width: 250,
            height: 80,
            backgroundColor: Colors.white);
      case 'upcE':
        return BarcodeWidget(
            barcode: Barcode.upcE(),
            data: data,
            width: 200,
            height: 80,
            backgroundColor: Colors.white);
      case 'itf':
        return BarcodeWidget(
            barcode: Barcode.itf(),
            data: data,
            width: 250,
            height: 80,
            backgroundColor: Colors.white);
      case 'pdf417':
        return BarcodeWidget(
            barcode: Barcode.pdf417(),
            data: data,
            width: 250,
            height: 80,
            backgroundColor: Colors.white);
      case 'codabar':
        return BarcodeWidget(
            barcode: Barcode.codabar(),
            data: data,
            width: 250,
            height: 80,
            backgroundColor: Colors.white);
      case 'aztec':
        return BarcodeWidget(
            barcode: Barcode.aztec(),
            data: data,
            width: 250,
            height: 80,
            backgroundColor: Colors.white);
      case 'dataMatrix':
        return BarcodeWidget(
            barcode: Barcode.dataMatrix(),
            data: data,
            width: 250,
            height: 80,
            backgroundColor: Colors.white);
      case 'code93':
        return BarcodeWidget(
            barcode: Barcode.code93(),
            data: data,
            width: 250,
            height: 80,
            backgroundColor: Colors.white);
      default:
        return QrImageView(
            data: data,
            version: QrVersions.auto,
            size: 200.0,
            backgroundColor: Colors.white);
    }
  }

  void _showQrShareSheet(BuildContext context) {
    final shareUrl = DeepLinkService.generateDeepLink(card);
    final cardColor = card.colorValue != null
        ? Color(card.colorValue!)
        : cardColorFromName(card.name);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.xxl, AppSpacing.lg, AppSpacing.xxl, AppSpacing.xxxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: AppSpacing.xxl),
              decoration: BoxDecoration(
                  color: context.palette.hairline,
                  borderRadius: BorderRadius.circular(2)),
            ),
            Text(card.name,
                style: context.text.headlineSmall?.copyWith(color: cardColor)),
            const SizedBox(height: AppSpacing.xxl),
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              child: QrImageView(
                  data: shareUrl,
                  version: QrVersions.auto,
                  size: 240.0,
                  backgroundColor: Colors.white),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(AppLocalizations.of(context)!.shareViaQr,
                style: context.text.bodyMedium),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final loc = AppLocalizations.of(context)!;
    final cards = ref.watch(fidelityCardsProvider);
    final updated = cards.firstWhere((c) => c.id == card.id, orElse: () => card);
    card = updated;
    final cardColor = card.colorValue != null
        ? Color(card.colorValue!)
        : cardColorFromName(card.name);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.ios_share_rounded),
            tooltip: loc.shareViaLink,
            onPressed: () {
              final deepLink = DeepLinkService.generateDeepLink(card);
              Share.share(
                '${loc.shareCardMessage}\n\n🔗 $deepLink',
                subject: card.name,
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: loc.editCard,
            onPressed: () async {
              final result = await Navigator.push(
                context,
                PageTransition(page: AddCardScreen(cardToEdit: card)),
              );
              if (result == true && mounted) Navigator.pop(context);
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded),
            onSelected: (value) async {
              switch (value) {
                case 'favorite':
                  HapticFeedback.selectionClick();
                  ref
                      .read(fidelityCardsProvider.notifier)
                      .toggleFavorite(card.id);
                case 'qr':
                  _showQrShareSheet(context);
                case 'delete':
                  final deleted = card;
                  final messenger = ScaffoldMessenger.of(context);
                  HapticFeedback.mediumImpact();
                  ref
                      .read(fidelityCardsProvider.notifier)
                      .removeCard(deleted.id);
                  if (mounted) Navigator.pop(context);
                  messenger.clearSnackBars();
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text(loc.cardDeleted),
                      action: SnackBarAction(
                        label: loc.undo,
                        onPressed: () => ref
                            .read(fidelityCardsProvider.notifier)
                            .addCard(deleted),
                      ),
                    ),
                  );
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'favorite',
                child: _menuRow(
                  card.isFavorite
                      ? Icons.star_rounded
                      : Icons.star_border_rounded,
                  card.isFavorite ? loc.removeFromFavorites : loc.addToFavorites,
                ),
              ),
              PopupMenuItem(
                value: 'qr',
                child: _menuRow(Icons.qr_code_rounded, loc.shareViaQr),
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                value: 'delete',
                child: _menuRow(Icons.delete_outline_rounded, loc.deleteCard,
                    color: p.danger),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          CardGradientHeader(
            cardColor: cardColor,
            title: card.name,
            watermarkChar: card.name.isNotEmpty ? card.name[0].toUpperCase() : '?',
            height: 190,
            titleFontSize: 30,
            watermarkFontSize: 170,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.xxl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (card.description.isNotEmpty) ...[
                    Text(card.description, style: context.text.bodyLarge),
                    const SizedBox(height: AppSpacing.xxl),
                  ],
                  if (card.barcode != null)
                    _barcodeTicket(context, loc, p, cardColor),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _barcodeTicket(BuildContext context, AppLocalizations loc,
      AppPalette p, Color cardColor) {
    return Container(
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: p.hairline),
        boxShadow: AppShadow.soft(p),
      ),
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.storefront_rounded, size: 18, color: cardColor),
              const SizedBox(width: AppSpacing.sm),
              Text(loc.barcode, style: context.text.titleMedium),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: _buildBarcodeWidget(card.barcode!, card.barcodeType),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            card.barcode!,
            style: context.text.titleMedium?.copyWith(
              letterSpacing: 2,
              fontFeatures: const [],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _menuRow(IconData icon, String label, {Color? color}) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: AppSpacing.md),
        Text(label, style: color != null ? TextStyle(color: color) : null),
      ],
    );
  }
}
