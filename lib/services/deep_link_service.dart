import 'dart:convert';
import 'dart:typed_data';
import 'package:app_links/app_links.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/fidelity_card.dart';

class DeepLinkService {
  static const String webHost = 'app.auxrideum.ddns.ms';

  static const _barcodeTypeToEnum = {
    'ean13': 0, 'upcA': 1, 'code128': 2, 'qrCode': 3, 'ean8': 4, 'code39': 5,
    'itf': 6, 'pdf417': 7, 'codabar': 8, 'aztec': 9, 'dataMatrix': 10, 'code93': 11,
  };
  static const _barcodeTypeFromEnum = [
    'ean13', 'upcA', 'code128', 'qrCode', 'ean8', 'code39',
    'itf', 'pdf417', 'codabar', 'aztec', 'dataMatrix', 'code93',
  ];

  // Provider per gestire lo stato del Deep Link
  static final deepLinkProvider = StateProvider<String?>((ref) => null);

  // Metodo per inizializzare il listener dei Deep Links
  static Future<void> initDeepLinks(WidgetRef ref) async {
    try {
      final appLinks = AppLinks();

      // Gestione dei Deep Links quando l'app è in background
      appLinks.uriLinkStream.listen((Uri uri) {
        _handleDeepLink(uri, ref);
      }, onError: (err) {
        print('Error handling deep links: $err');
      });

      // Gestione dei Deep Links quando l'app è in foreground
      final initialUri = await appLinks.getInitialAppLink();
      if (initialUri != null) {
        _handleDeepLink(initialUri, ref);
      }
    } on PlatformException catch (e) {
      print('Failed to initialize deep links: $e');
    }
  }

  // Metodo per gestire il Deep Link ricevuto
  static void _handleDeepLink(Uri uri, WidgetRef ref) {
    if (uri.scheme == 'https' && uri.host == webHost) {
      ref.read(deepLinkProvider.notifier).state = uri.toString();
    }
  }

  // Ritorna null se i campi eccedono 255 byte UTF-8
  static Uint8List? _encodeV1(FidelityCard card) {
    final nameBytes = utf8.encode(card.name);
    final descBytes = utf8.encode(card.description);
    final barcodeBytes = card.barcode != null ? utf8.encode(card.barcode!) : null;
    if (nameBytes.length > 255 || descBytes.length > 255) return null;
    if (barcodeBytes != null && barcodeBytes.length > 255) return null;

    int flags = 0;
    if (barcodeBytes != null) flags |= 0x01;
    if (card.barcodeType != null && _barcodeTypeToEnum.containsKey(card.barcodeType)) flags |= 0x02;
    if (card.colorValue != null) flags |= 0x04;

    final buf = BytesBuilder();
    buf.addByte(0x01);
    buf.addByte(flags);
    buf.addByte(nameBytes.length);
    buf.add(nameBytes);
    buf.addByte(descBytes.length);
    buf.add(descBytes);
    if (flags & 0x01 != 0) {
      buf.addByte(barcodeBytes!.length);
      buf.add(barcodeBytes);
    }
    if (flags & 0x02 != 0) {
      buf.addByte(_barcodeTypeToEnum[card.barcodeType!]!);
    }
    if (flags & 0x04 != 0) {
      final bd = ByteData(4);
      bd.setUint32(0, card.colorValue!, Endian.big);
      buf.add(bd.buffer.asUint8List());
    }
    return buf.toBytes();
  }

  static FidelityCard _decodeV1(Uint8List bytes) {
    int off = 1; // salta version
    final flags = bytes[off++];
    final nameLen = bytes[off++];
    final name = utf8.decode(bytes.sublist(off, off + nameLen));
    off += nameLen;
    final descLen = bytes[off++];
    final desc = utf8.decode(bytes.sublist(off, off + descLen));
    off += descLen;
    String? barcode;
    if (flags & 0x01 != 0) {
      final l = bytes[off++];
      barcode = utf8.decode(bytes.sublist(off, off + l));
      off += l;
    }
    String? barcodeType;
    if (flags & 0x02 != 0) {
      final e = bytes[off++];
      barcodeType = e < _barcodeTypeFromEnum.length ? _barcodeTypeFromEnum[e] : null;
    }
    int? colorValue;
    if (flags & 0x04 != 0) {
      colorValue = ByteData.sublistView(bytes, off, off + 4).getUint32(0, Endian.big);
    }
    return FidelityCard(
      id: '',
      name: name,
      description: desc,
      barcode: barcode,
      barcodeType: barcodeType,
      colorValue: colorValue,
      openCount: 0,
      createdAt: DateTime.now(),
    );
  }

  // Metodo per generare un Deep Link per una tessera
  static String generateDeepLink(FidelityCard card) {
    final bytes = _encodeV1(card);
    final encoded = bytes != null
        ? base64UrlEncode(bytes).replaceAll('=', '')
        : base64UrlEncode(utf8.encode(json.encode({
            'name': card.name,
            'description': card.description,
            if (card.barcode != null) 'barcode': card.barcode,
            if (card.barcodeType != null) 'barcodeType': card.barcodeType,
            if (card.colorValue != null) 'colorValue': card.colorValue,
          }))).replaceAll('=', '');
    return 'https://$webHost/import/$encoded';
  }

  // Metodo per decodificare i dati della tessera da un Deep Link
  static FidelityCard? decodeDeepLink(String deepLink) {
    try {
      final uri = Uri.parse(deepLink);
      if (uri.scheme == 'https' && uri.host == webHost) {
        final raw = uri.pathSegments.isNotEmpty ? uri.pathSegments.last : '';
        final normalized = base64Url.normalize(raw.replaceAll('+', '-').replaceAll('/', '_'));
        final bytes = base64Url.decode(normalized);
        if (bytes.isNotEmpty && bytes[0] == 0x01) {
          return _decodeV1(Uint8List.fromList(bytes));
        } else {
          // Vecchio formato JSON (primo byte '{' = 0x7B)
          final cardData = json.decode(utf8.decode(bytes)) as Map<String, dynamic>;
          if (cardData.containsKey('name')) return FidelityCard.fromJson(cardData);
          return FidelityCard(
            id: '',
            name: cardData['n'] as String,
            description: cardData['d'] as String? ?? '',
            barcode: cardData['b'] as String?,
            barcodeType: cardData['bt'] as String?,
            colorValue: cardData['c'] as int?,
            openCount: 0,
            createdAt: DateTime.now(),
          );
        }
      }
    } catch (e) {
      print('Error decoding deep link: $e');
    }
    return null;
  }
}
