import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';
import '../models/fidelity_card.dart';
import '../providers/fidelity_cards_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
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

  static const _colorPalette = [
    Color(0xFF4F8FFF),
    Color(0xFF6FE7DD),
    Color(0xFFFFB86B),
    Color(0xFFFC5C7D),
    Color(0xFF43E97B),
    Color(0xFF38F9D7),
    Color(0xFF667EEA),
    Color(0xFF764BA2),
    Color(0xFFFF6A6A),
    Color(0xFF36D1C4),
  ];

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
      _nameController.text = widget.cardToEdit!.name;
      _descriptionController.text = widget.cardToEdit!.description;
      _selectedColorValue = widget.cardToEdit!.colorValue ?? _colorPalette[0].value;
      _barcode = widget.cardToEdit!.barcode;
      _barcodeType = widget.cardToEdit!.barcodeType;
      _barcodeController.text = widget.cardToEdit!.barcode ?? '';
      _validateCurrentBarcode();
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

  String _generateRandomBarcodeValue(String type) {
    final rand = Random();
    switch (type) {
      case 'ean13':
        final base = List.generate(12, (_) => rand.nextInt(10));
        final check = _ean13CheckDigit(base);
        return [...base, check].join();
      case 'ean8':
        final base = List.generate(7, (_) => rand.nextInt(10));
        final check = _ean8CheckDigit(base);
        return [...base, check].join();
      case 'upcA':
        final base = List.generate(11, (_) => rand.nextInt(10));
        final check = _upcACheckDigit(base);
        return [...base, check].join();
      case 'upcE':
        return '04210005';
      case 'code128':
        return String.fromCharCodes(List.generate(10, (_) => rand.nextInt(94) + 33)); // ASCII 33-126
      case 'code39':
        const chars39 = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ-. \$/+%';
        return List.generate(8, (_) => chars39[rand.nextInt(chars39.length)]).join();
      case 'code93':
        const chars93 = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ-. \$/+%';
        return List.generate(8, (_) => chars93[rand.nextInt(chars93.length)]).join();
      case 'itf':
        final len = (rand.nextInt(5) + 2) * 2; // even length, min 4
        return List.generate(len, (_) => rand.nextInt(10)).join();
      case 'qrCode':
        return 'QR-${rand.nextInt(1000000)}';
      case 'aztec':
        return 'AZTEC-${rand.nextInt(1000000)}';
      case 'dataMatrix':
        return 'DM-${rand.nextInt(1000000)}';
      case 'pdf417':
        return 'PDF417-${rand.nextInt(1000000)}';
      case 'codabar':
        const charsCodabar = '0123456789-\$:/.+';
        return List.generate(8, (_) => charsCodabar[rand.nextInt(charsCodabar.length)]).join();
      default:
        return '1234567890';
    }
  }

  int _ean13CheckDigit(List<int> digits) {
    int sum = 0;
    for (int i = 0; i < 12; i++) {
      sum += digits[i] * ((i % 2 == 0) ? 1 : 3);
    }
    return (10 - (sum % 10)) % 10;
  }

  int _ean8CheckDigit(List<int> digits) {
    int sum = 0;
    for (int i = 0; i < 7; i++) {
      sum += digits[i] * ((i % 2 == 0) ? 3 : 1);
    }
    return (10 - (sum % 10)) % 10;
  }

  int _upcACheckDigit(List<int> digits) {
    int sum = 0;
    for (int i = 0; i < 11; i++) {
      sum += digits[i] * ((i % 2 == 0) ? 3 : 1);
    }
    return (10 - (sum % 10)) % 10;
  }

  void _setRandomBarcode() {
    final rand = Random();
    final type = _barcodeTypes[rand.nextInt(_barcodeTypes.length)];
    final value = _generateRandomBarcodeValue(type);
    setState(() {
      _barcodeType = type;
      _barcode = value;
      _barcodeController.text = value;
    });
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
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      final colorValue = _selectedColorValue ?? (List.of(_colorPalette)..shuffle()).first.value;
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

  void _startScanning() {
    setState(() {
      _isScanning = true;
    });
  }

  void _stopScanning() {
    setState(() {
      _isScanning = false;
    });
  }

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
    final cardColor = _selectedColorValue != null
        ? Color(_selectedColorValue!)
        : (_selectedColorValue == null && _formKey.currentState == null
            ? _colorPalette[0]
            : (_colorPalette[0]));
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(widget.cardToEdit != null
            ? AppLocalizations.of(context)!.editCard
            : AppLocalizations.of(context)!.addCard),
        backgroundColor: cardColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isScanning
          ? Column(
              children: [
                Expanded(
                  child: MobileScanner(
                    onDetect: (capture) {
                      final List<Barcode> barcodes = capture.barcodes;
                      if (barcodes.isNotEmpty) {
                        final value = barcodes.first.rawValue;
                        final format = barcodes.first.format;
                        final inferredType = mapBarcodeFormatToType(format);
                        setState(() {
                          _barcode = value;
                          _barcodeType = inferredType;
                          _barcodeController.text = value!;
													_isScanning = false;

                          _validateCurrentBarcode();
                        });
                      }
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    onPressed: _stopScanning,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: cardColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(AppLocalizations.of(context)!.cancelScanning),
                  ),
                ),
              ],
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    height: 120,
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
                              _nameController.text.isNotEmpty ? _nameController.text[0].toUpperCase() : '?',
                              style: TextStyle(
                                fontSize: 100,
                                fontWeight: FontWeight.bold,
                                letterSpacing: -8,
                                color: theme.colorScheme.onPrimary.withOpacity(0.15),
                              ),
                            ),
                          ),
                        ),
                        // Live preview of card name
                        Center(
                          child: Text(
                            _nameController.text.isNotEmpty ? _nameController.text : (widget.cardToEdit?.name ?? AppLocalizations.of(context)!.cardName),
                            style: GoogleFonts.poppins(
                              color: theme.colorScheme.onPrimary,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24),
                    child: Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      color: theme.cardColor,
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              TextFormField(
                                controller: _nameController,
                                decoration: InputDecoration(
                                  labelText: AppLocalizations.of(context)!.cardName,
                                  labelStyle: GoogleFonts.poppins(),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  fillColor: theme.inputDecorationTheme.fillColor ?? theme.colorScheme.surface,
                                ),
                                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return AppLocalizations.of(context)!.cardName;
                                  }
                                  return null;
                                },
                                onChanged: (_) => setState(() {}),
                              ),
                              const SizedBox(height: 18),
                              TextFormField(
                                controller: _descriptionController,
                                decoration: InputDecoration(
                                  labelText: AppLocalizations.of(context)!.description,
                                  labelStyle: GoogleFonts.poppins(),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  fillColor: theme.inputDecorationTheme.fillColor ?? theme.colorScheme.surface,
                                ),
                                maxLines: 3,
                                style: GoogleFonts.poppins(),
                              ),
                              const SizedBox(height: 18),
                              Text(
                                AppLocalizations.of(context)!.cardColor,
                                style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16, color: theme.colorScheme.onSurface),
                              ),
                              const SizedBox(height: 10),
                              Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      for (int i = 0; i < 5; i++)
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 5),
                                          child: GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                _selectedColorValue = _colorPalette[i].value;
                                              });
                                            },
                                            child: Container(
                                              width: 32,
                                              height: 32,
                                              decoration: BoxDecoration(
                                                color: _colorPalette[i],
                                                shape: BoxShape.circle,
                                                border: _selectedColorValue == _colorPalette[i].value
                                                    ? Border.all(color: Colors.black, width: 2)
                                                    : null,
                                              ),
                                              child: _selectedColorValue == _colorPalette[i].value
                                                  ? const Icon(Icons.check, color: Colors.white, size: 20)
                                                  : null,
                                            ),
                                          ),
                                        ),
                                      // Custom color button
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 5),
                                        child: GestureDetector(
                                          onTap: () async {
                                            Color pickerColor = _selectedColorValue != null
                                                ? Color(_selectedColorValue!)
                                                : _colorPalette[0];
                                            final result = await showDialog<Color>(
                                              context: context,
                                              builder: (context) {
                                                return AlertDialog(
                                                  title: Text(AppLocalizations.of(context)!.cardColor),
                                                  content: SingleChildScrollView(
                                                    child: ColorPicker(
                                                      pickerColor: pickerColor,
                                                      onColorChanged: (color) {
                                                        pickerColor = color;
                                                      },
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
                                                );
                                              },
                                            );
                                            if (result != null) {
                                              setState(() {
                                                _selectedColorValue = result.value;
                                              });
                                            }
                                          },
                                          child: Container(
                                            width: 32,
                                            height: 32,
                                            decoration: BoxDecoration(
                                              color: _selectedColorValue != null && !_colorPalette.any((c) => c.value == _selectedColorValue)
                                                  ? Color(_selectedColorValue!)
                                                  : Colors.grey[300],
                                              shape: BoxShape.circle,
                                              border: Border.all(color: Colors.black, width: 2),
                                            ),
                                            child: const Icon(Icons.add, color: Colors.black, size: 20),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      for (int i = 5; i < 10; i++)
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 5),
                                          child: GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                _selectedColorValue = _colorPalette[i].value;
                                              });
                                            },
                                            child: Container(
                                              width: 32,
                                              height: 32,
                                              decoration: BoxDecoration(
                                                color: _colorPalette[i],
                                                shape: BoxShape.circle,
                                                border: _selectedColorValue == _colorPalette[i].value
                                                    ? Border.all(color: Colors.black, width: 2)
                                                    : null,
                                              ),
                                              child: _selectedColorValue == _colorPalette[i].value
                                                  ? const Icon(Icons.check, color: Colors.white, size: 20)
                                                  : null,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 18),
                              Container(
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.surface,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: cardColor.withOpacity(0.2)),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.qr_code, color: cardColor, size: 28),
                                        const SizedBox(width: 10),
                                        ElevatedButton(
                                          onPressed: _startScanning,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: cardColor,
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(16),
                                            ),
                                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                            elevation: 0,
                                          ),
                                          child: Text(_barcode == null ? AppLocalizations.of(context)!.scan : AppLocalizations.of(context)!.rescan),
                                        ),
                                        const SizedBox(width: 8),
                                        OutlinedButton(
                                          onPressed: _setRandomBarcode,
                                          style: OutlinedButton.styleFrom(
                                            foregroundColor: cardColor,
                                            side: BorderSide(color: cardColor, width: 1.5),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(16),
                                            ),
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                          ),
                                          child: Text(AppLocalizations.of(context)!.random),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    TextFormField(
                                      controller: _barcodeController,
                                      decoration: InputDecoration(
                                        labelText: AppLocalizations.of(context)!.barcode,
                                        labelStyle: GoogleFonts.poppins(),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                        fillColor: theme.inputDecorationTheme.fillColor ?? theme.colorScheme.surface,
                                        suffixIcon: IconButton(
                                          icon: const Icon(Icons.check),
                                          onPressed: () {
                                            setState(() {
                                              _barcode = _barcodeController.text;
                                            });
                                          },
                                        ),
                                        errorText: _barcodeError,
                                      ),
                                      onChanged: (value) {
                                        setState(() {
                                          _barcode = value;
                                        });
                                      },
                                    ),
                                    const SizedBox(height: 16),
                                    DropdownButtonFormField<String>(
                                      value: _barcodeType,
                                      decoration: InputDecoration(
                                        labelText: AppLocalizations.of(context)!.type,
                                        labelStyle: GoogleFonts.poppins(),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                        fillColor: theme.inputDecorationTheme.fillColor ?? theme.colorScheme.surface,
                                      ),
                                      items: _barcodeTypes.map((type) {
                                        return DropdownMenuItem<String>(
                                          value: type,
                                          child: Text(type),
                                        );
                                      }).toList(),
                                      onChanged: (value) {
                                        setState(() {
                                          _barcodeType = value;
                                          _validateCurrentBarcode();
                                        });
                                      },
                                    ),
                                    
                                  ],
                                ),
                              ),
                              const SizedBox(height: 28),
                              ElevatedButton(
                                onPressed: _submitForm,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: cardColor,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 18),
                                  textStyle: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
                                  elevation: 2,
                                ),
                                child: Text(widget.cardToEdit != null ? AppLocalizations.of(context)!.saveChanges : AppLocalizations.of(context)!.addCard),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
} 