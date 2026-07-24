import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../models/fidelity_card.dart';
import '../providers/fidelity_cards_provider.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/card_gradient_header.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:barcode/barcode.dart' as bc;

class AddCardScreen extends ConsumerStatefulWidget {
  final FidelityCard? cardToEdit;
  const AddCardScreen({super.key, this.cardToEdit});

  @override
  ConsumerState<AddCardScreen> createState() => _AddCardScreenState();
}

class _AddCardScreenState extends ConsumerState<AddCardScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _barcodeController = TextEditingController();
  String? _barcode;
  String? _barcodeType;
  String? _barcodeError;
  int? _selectedColorValue;
  bool _isScanning = false;
  bool _manualEntry = false;
  bool _showAdvanced = false;

  static const _barcodeTypes = [
    'aztec',
    'codabar',
    'code39',
    'code93',
    'code128',
    'dataMatrix',
    'ean8',
    'ean13',
    'itf',
    'pdf417',
    'qrCode',
    'upcA',
    'upcE',
  ];

  static const _colorPalette = kCardPalette;

  bool get _hasCode => _barcode != null && _barcode!.isNotEmpty;

  bool _validateBarcode(String value, String type) {
    if (value.isEmpty) return true;
    switch (type) {
      case 'ean13':
        return bc.Barcode.ean13().isValid(value);
      case 'ean8':
        return bc.Barcode.ean8().isValid(value);
      case 'upcA':
        return bc.Barcode.upcA().isValid(value);
      case 'upcE':
        return bc.Barcode.upcE().isValid(value);
      case 'code128':
        return bc.Barcode.code128().isValid(value);
      case 'code39':
        return bc.Barcode.code39().isValid(value);
      case 'code93':
        return bc.Barcode.code93().isValid(value);
      case 'itf':
        return bc.Barcode.itf().isValid(value);
      case 'qrCode':
        return bc.Barcode.qrCode().isValid(value);
      case 'aztec':
        return bc.Barcode.aztec().isValid(value);
      case 'dataMatrix':
        return bc.Barcode.dataMatrix().isValid(value);
      case 'pdf417':
        return bc.Barcode.pdf417().isValid(value);
      case 'codabar':
        return bc.Barcode.codabar().isValid(value);
      default:
        return true;
    }
  }

  String? _getBarcodeErrorMessage(String value, String type) {
    if (value.isEmpty) return null;
    switch (type) {
      case 'ean13':
        return 'EAN-13 must be exactly 13 digits';
      case 'ean8':
        return 'EAN-8 must be exactly 8 digits';
      case 'upcA':
        return 'UPC-A must be exactly 12 digits';
      case 'upcE':
        return 'UPC-E must be exactly 8 digits';
      case 'code128':
        return 'Code 128 can only contain ASCII characters';
      case 'code39':
        return 'Code 39 can only contain uppercase letters, numbers, and -./\$+%';
      case 'code93':
        return 'Code 93 can only contain ASCII characters';
      case 'itf':
        return 'ITF must contain an even number of digits';
      case 'codabar':
        return 'Codabar can only contain 0-9, - \$ : / . +';
      default:
        return "Barcode is not valid";
    }
  }

  @override
  void initState() {
    super.initState();
    // Form-first: never ambush the user with the camera. Scanning is an
    // explicit choice from within the form.
    if (widget.cardToEdit != null) {
      _nameController.text = widget.cardToEdit!.name;
      _descriptionController.text = widget.cardToEdit!.description;
      _selectedColorValue =
          widget.cardToEdit!.colorValue ?? _colorPalette[0].value;
      _barcode = widget.cardToEdit!.barcode;
      _barcodeType = widget.cardToEdit!.barcodeType;
      _barcodeController.text = widget.cardToEdit!.barcode ?? '';
      _validateCurrentBarcode();
    }
  }

  void _validateCurrentBarcode() {
    if (_barcodeType != null && _barcode != null) {
      _barcodeError = _validateBarcode(_barcode!, _barcodeType!)
          ? null
          : _getBarcodeErrorMessage(_barcode!, _barcodeType!);
    } else {
      _barcodeError = null;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _barcodeController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      if (_hasCode && _barcodeType != null && _barcodeError != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_barcodeError!),
            backgroundColor: context.palette.danger,
          ),
        );
        return;
      }
      final colorValue = _selectedColorValue ??
          (List.of(_colorPalette)..shuffle()).first.value;
      final card = FidelityCard(
        id: widget.cardToEdit?.id ?? const Uuid().v4(),
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        barcode: _hasCode ? _barcode : null,
        barcodeType: _hasCode ? _barcodeType : null,
        colorValue: colorValue,
        createdAt: widget.cardToEdit?.createdAt ?? DateTime.now(),
      );
      if (widget.cardToEdit != null) {
        ref.read(fidelityCardsProvider.notifier).updateCard(card);
      } else {
        ref.read(fidelityCardsProvider.notifier).addCard(card);
      }
      Navigator.pop(context);
    }
  }

  void _startScanning() {
    FocusScope.of(context).unfocus();
    setState(() => _isScanning = true);
  }

  void _stopScanning() => setState(() => _isScanning = false);

  String mapBarcodeFormatToType(BarcodeFormat format) {
    switch (format) {
      case BarcodeFormat.aztec:
        return 'aztec';
      case BarcodeFormat.codabar:
        return 'codabar';
      case BarcodeFormat.code39:
        return 'code39';
      case BarcodeFormat.code93:
        return 'code93';
      case BarcodeFormat.code128:
        return 'code128';
      case BarcodeFormat.dataMatrix:
        return 'dataMatrix';
      case BarcodeFormat.ean8:
        return 'ean8';
      case BarcodeFormat.ean13:
        return 'ean13';
      case BarcodeFormat.itf:
        return 'itf';
      case BarcodeFormat.pdf417:
        return 'pdf417';
      case BarcodeFormat.qrCode:
        return 'qrCode';
      case BarcodeFormat.upcA:
        return 'upcA';
      case BarcodeFormat.upcE:
        return 'upcE';
      default:
        return 'qrCode';
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final loc = AppLocalizations.of(context)!;
    final cardColor = _selectedColorValue != null
        ? Color(_selectedColorValue!)
        : _colorPalette[0];

    if (_isScanning) {
      return Scaffold(body: _scannerView(loc, cardColor));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.cardToEdit != null ? loc.editCard : loc.addCard),
      ),
      body: _formView(context, loc, p, cardColor),
      bottomNavigationBar: _saveBar(context, loc, cardColor),
    );
  }

  // ── Scanner ────────────────────────────────────────────────────────────────
  Widget _scannerView(AppLocalizations loc, Color cardColor) {
    return Stack(
      children: [
        MobileScanner(
          onDetect: (capture) {
            final barcodes = capture.barcodes;
            if (barcodes.isNotEmpty) {
              final value = barcodes.first.rawValue;
              final format = barcodes.first.format;
              if (value == null) return;
              setState(() {
                _barcode = value;
                _barcodeType = mapBarcodeFormatToType(format);
                _barcodeController.text = value;
                _manualEntry = true;
                _isScanning = false;
                _validateCurrentBarcode();
              });
            }
          },
        ),
        Center(
          child: Container(
            width: 260,
            height: 180,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white, width: 3),
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: AppSpacing.huge + AppSpacing.huge,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.55),
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.qr_code_scanner_rounded,
                      color: Colors.white, size: 18),
                  const SizedBox(width: AppSpacing.sm),
                  Text(loc.scanBarcode,
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          left: AppSpacing.xxl,
          right: AppSpacing.xxl,
          bottom: AppSpacing.xxl,
          child: SafeArea(
            child: FilledButton.icon(
              onPressed: _stopScanning,
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black87,
                minimumSize: const Size(double.infinity, 52),
              ),
              icon: const Icon(Icons.close_rounded),
              label: Text(loc.cancel),
            ),
          ),
        ),
      ],
    );
  }

  // ── Sticky save bar ─────────────────────────────────────────────────────────
  Widget _saveBar(BuildContext context, AppLocalizations loc, Color cardColor) {
    final p = context.palette;
    return Container(
      decoration: BoxDecoration(
        color: p.paper,
        border: Border(top: BorderSide(color: p.hairline)),
      ),
      child: SafeArea(
        minimum: const EdgeInsets.fromLTRB(
            AppSpacing.xl, AppSpacing.md, AppSpacing.xl, AppSpacing.md),
        child: ElevatedButton.icon(
          onPressed: _submitForm,
          style: ElevatedButton.styleFrom(
            backgroundColor: cardColor,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 56),
          ),
          icon: const Icon(Icons.check_rounded),
          label: Text(
              widget.cardToEdit != null ? loc.saveChanges : loc.addCard),
        ),
      ),
    );
  }

  // ── Form ─────────────────────────────────────────────────────────────────
  Widget _formView(
      BuildContext context, AppLocalizations loc, AppPalette p, Color cardColor) {
    return SingleChildScrollView(
      child: Column(
        children: [
          CardGradientHeader(
            cardColor: cardColor,
            title: _nameController.text.isNotEmpty
                ? _nameController.text
                : (widget.cardToEdit?.name ?? loc.cardName),
            watermarkChar: _nameController.text.isNotEmpty
                ? _nameController.text[0].toUpperCase()
                : '?',
            height: 140,
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _sectionLabel(context, loc.cardName),
                  TextFormField(
                    controller: _nameController,
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(hintText: loc.cardName),
                    style: context.text.bodyLarge
                        ?.copyWith(fontWeight: FontWeight.w600),
                    validator: (value) => (value == null || value.trim().isEmpty)
                        ? loc.nameRequired
                        : null,
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  _sectionLabel(context, loc.barcode),
                  _codeSection(context, loc, p, cardColor),
                  const SizedBox(height: AppSpacing.xl),

                  _sectionLabel(context, loc.description, optional: loc.optional),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: InputDecoration(hintText: loc.description),
                    maxLines: 2,
                    style: context.text.bodyLarge,
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  _sectionLabel(context, loc.cardColor),
                  _colorPicker(context, p),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(BuildContext context, String text, {String? optional}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm, left: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Text(text, style: context.text.titleSmall),
          if (optional != null) ...[
            const SizedBox(width: AppSpacing.sm),
            Text('· $optional',
                style: context.text.bodySmall
                    ?.copyWith(color: context.palette.inkFaint)),
          ],
        ],
      ),
    );
  }

  // ── Barcode: scan-or-type chooser, then a captured/editable state ────────────
  Widget _codeSection(BuildContext context, AppLocalizations loc, AppPalette p,
      Color cardColor) {
    // Nothing captured yet and not typing → offer the two clear paths.
    if (!_hasCode && !_manualEntry) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ScanTile(
            label: loc.scanBarcode,
            color: cardColor,
            onTap: _startScanning,
          ),
          const SizedBox(height: AppSpacing.sm),
          Align(
            child: TextButton.icon(
              onPressed: () => setState(() => _manualEntry = true),
              icon: const Icon(Icons.keyboard_rounded, size: 18),
              label: Text(loc.enterManually),
            ),
          ),
        ],
      );
    }

    // Captured or typing → show the value, a rescan action and advanced options.
    return Container(
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: p.hairline),
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_hasCode && _barcodeError == null)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: Row(
                children: [
                  Icon(Icons.check_circle_rounded, size: 18, color: cardColor),
                  const SizedBox(width: AppSpacing.sm),
                  Text(loc.codeCaptured,
                      style: context.text.labelMedium
                          ?.copyWith(color: cardColor)),
                ],
              ),
            ),
          TextFormField(
            controller: _barcodeController,
            decoration: InputDecoration(
              hintText: loc.barcode,
              errorText: _barcodeError,
              prefixIcon: const Icon(Icons.tag_rounded),
            ),
            style: context.text.bodyLarge?.copyWith(letterSpacing: 1),
            onChanged: (value) => setState(() {
              _barcode = value;
              _validateCurrentBarcode();
            }),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _startScanning,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: cardColor,
                    side: BorderSide(color: cardColor.withOpacity(0.5)),
                    minimumSize: const Size(0, 48),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md)),
                  ),
                  icon: const Icon(Icons.qr_code_scanner_rounded, size: 18),
                  label: Text(loc.rescan),
                ),
              ),
            ],
          ),
          // Advanced: barcode type (auto-detected on scan; editable if needed).
          const SizedBox(height: AppSpacing.xs),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () => setState(() => _showAdvanced = !_showAdvanced),
              style: TextButton.styleFrom(foregroundColor: p.inkSoft),
              icon: Icon(
                  _showAdvanced
                      ? Icons.expand_less_rounded
                      : Icons.expand_more_rounded,
                  size: 18),
              label: Text(loc.advancedOptions),
            ),
          ),
          if (_showAdvanced)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.sm),
              child: DropdownButtonFormField<String>(
                value: _barcodeType,
                isExpanded: true,
                decoration: InputDecoration(labelText: loc.type),
                borderRadius: BorderRadius.circular(AppRadius.md),
                items: _barcodeTypes
                    .map((type) => DropdownMenuItem<String>(
                          value: type,
                          child: Text(type.toUpperCase()),
                        ))
                    .toList(),
                onChanged: (value) => setState(() {
                  _barcodeType = value;
                  _validateCurrentBarcode();
                }),
              ),
            ),
        ],
      ),
    );
  }

  Widget _colorPicker(BuildContext context, AppPalette p) {
    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.md,
      children: [
        for (final color in _colorPalette)
          _swatch(
            color: color,
            selected: _selectedColorValue == color.value,
            onTap: () => setState(() => _selectedColorValue = color.value),
          ),
        GestureDetector(
          onTap: _pickCustomColor,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _selectedColorValue != null &&
                      !_colorPalette.any((c) => c.value == _selectedColorValue)
                  ? Color(_selectedColorValue!)
                  : p.surfaceMuted,
              shape: BoxShape.circle,
              border: Border.all(color: p.hairline, width: 1.5),
            ),
            child: Icon(Icons.tune_rounded, color: p.inkSoft, size: 20),
          ),
        ),
      ],
    );
  }

  Widget _swatch({
    required Color color,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppDuration.fast,
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: selected
              ? Border.all(color: context.palette.ink, width: 2.5)
              : null,
          boxShadow: selected ? AppShadow.tinted(color) : null,
        ),
        child: selected
            ? const Icon(Icons.check_rounded, color: Colors.white, size: 20)
            : null,
      ),
    );
  }

  Future<void> _pickCustomColor() async {
    Color pickerColor = _selectedColorValue != null
        ? Color(_selectedColorValue!)
        : _colorPalette[0];
    final result = await showDialog<Color>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.cardColor),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: pickerColor,
            onColorChanged: (color) => pickerColor = color,
            enableAlpha: false,
            showLabel: false,
            pickerAreaHeightPercent: 0.8,
          ),
        ),
        actions: [
          TextButton(
            child: Text(AppLocalizations.of(context)!.cancel),
            onPressed: () => Navigator.of(context).pop(),
          ),
          ElevatedButton(
            child: Text(AppLocalizations.of(context)!.saveChanges),
            onPressed: () => Navigator.of(context).pop(pickerColor),
          ),
        ],
      ),
    );
    if (result != null) {
      setState(() => _selectedColorValue = result.value);
    }
  }
}

/// Big, obvious "scan" call-to-action used when no code has been captured yet.
class _ScanTile extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ScanTile(
      {required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withOpacity(0.08),
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Container(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg, vertical: AppSpacing.xxl),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: color.withOpacity(0.4), width: 1.5),
          ),
          child: Column(
            children: [
              Icon(Icons.qr_code_scanner_rounded, size: 34, color: color),
              const SizedBox(height: AppSpacing.md),
              Text(
                label,
                textAlign: TextAlign.center,
                style: context.text.titleMedium?.copyWith(color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
