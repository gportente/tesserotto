import 'dart:convert';
import 'package:app_links/app_links.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/fidelity_card.dart';

class DeepLinkService {
  static const String webHost = 'app.auxrideum.ddns.ms';
  
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

  // Metodo per generare un Deep Link per una tessera
  static String generateDeepLink(FidelityCard card) {
    final cardData = card.toJson();
    final encodedData = base64Encode(utf8.encode(json.encode(cardData)));
    return 'https://$webHost/import/$encodedData';
  }

  // Metodo per decodificare i dati della tessera da un Deep Link
  static FidelityCard? decodeDeepLink(String deepLink) {
    try {
      final uri = Uri.parse(deepLink);
      if (uri.scheme == 'https' && uri.host == webHost) {
        final encodedData = uri.pathSegments.isNotEmpty ? uri.pathSegments.last : '';
        final decodedData = utf8.decode(base64Decode(encodedData));
        final cardData = json.decode(decodedData);
        return FidelityCard.fromJson(cardData);
      }
    } catch (e) {
      print('Error decoding deep link: $e');
    }
    return null;
  }
} 