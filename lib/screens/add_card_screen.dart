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
  late bool _isScanning;

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
    if (widget.cardToEdit != null) {
      _isScanning = false;
      _nameController.text = widget.cardToEdit!.name;
      _descriptionController.text = widget.cardToEdit!.description;
      _selectedColorValue =
          widget.cardToEdit!.colorValue ?? _colorPalette[0].value;
      _barcode = widget.cardToEdit!.barcode;
      _barcodeType = widget.cardToEdit!.barcodeType;
      _barcodeController.text = widget.cardToEdit!.barcode ?? '';
      _validateCurrentBarcode();
    } else {
      _isScanning = true;
    }
  }

  void _validateCurrentBarcode() {
    if (_barcodeType != null && _barcode != null) {
      if (!_validateBarcode(_barcode!, _barcodeType!)) {
        _barcodeError = _getBarcodeErrorMessage(_barcode!, _barcodeType!);
      } else {
        _barcodeError = null;
      }
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
      if (_barcode != null && _barcodeType != null && _barcodeError != null) {
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
        name: _nameController.text,
        description: _descriptionController.text,
        barcode: _barcode,
        barcodeType: _barcodeType,
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

  void _startScanning() => setState(() => _isScanning = true);
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
    final cardColor =
        _selectedColorValue != null ? Color(_selectedColorValue!) : _colorPalette[0];

    return Scaffold(
      appBar: AppBar(
        title: Text(
            widget.cardToEdit != null ? loc.editCard : loc.addCard),
      ),
      body: _isScanning
          ? _scannerView(loc, cardColor)
          : _formView(context, loc, p, cardColor),
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
                _isScanning = false;
                _validateCurrentBarcode();
              });
            }
          },
        ),
        // Viewfinder + hint.
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
                  Text(loc.scan,
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
              icon: const Icon(Icons.edit_rounded),
              label: Text(loc.cancelScanning),
            ),
          ),
        ),
      ],
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
            height: 150,
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
                    decoration: InputDecoration(hintText: loc.cardName),
                    style: context.text.bodyLarge
                        ?.copyWith(fontWeight: FontWeight.w600),
                    validator: (value) =>
                        (value == null || value.isEmpty) ? loc.cardName : null,
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  _sectionLabel(context, loc.description),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: InputDecoration(hintText: loc.description),
                    maxLines: 3,
                    style: context.text.bodyLarge,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  _sectionLabel(context, loc.cardColor),
                  _colorPicker(context, p),
                  const SizedBox(height: AppSpacing.xl),
                  _sectionLabel(context, loc.barcode),
                  _barcodeSection(context, loc, p, cardColor),
                  const SizedBox(height: AppSpacing.xxxl),
                  ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: cardColor,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 56),
                    ),
                    child: Text(widget.cardToEdit != null
                        ? loc.saveChanges
                        : loc.addCard),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm, left: 2),
      child: Text(text, style: context.text.titleSmall),
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
        // Custom colour.
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

  Widget _barcodeSection(BuildContext context, AppLocalizations loc,
      AppPalette p, Color cardColor) {
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
          ElevatedButton.icon(
            onPressed: _startScanning,
            style: ElevatedButton.styleFrom(
              backgroundColor: cardColor,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 52),
            ),
            icon: const Icon(Icons.qr_code_scanner_rounded),
            label:
                Text(_barcode == null ? loc.scan : loc.rescan),
          ),
          const SizedBox(height: AppSpacing.lg),
          TextFormField(
            controller: _barcodeController,
            decoration: InputDecoration(
              hintText: loc.barcode,
              errorText: _barcodeError,
              suffixIcon: IconButton(
                icon: Icon(Icons.check_rounded, color: p.accent),
                onPressed: () =>
                    setState(() => _barcode = _barcodeController.text),
              ),
            ),
            onChanged: (value) => setState(() => _barcode = value),
          ),
          const SizedBox(height: AppSpacing.lg),
          DropdownButtonFormField<String>(
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
        ],
      ),
    );
  }
}
