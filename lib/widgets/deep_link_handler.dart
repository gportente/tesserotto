import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../l10n/app_localizations.dart';
import '../services/deep_link_service.dart';
import '../providers/fidelity_cards_provider.dart';

class DeepLinkHandler extends ConsumerStatefulWidget {
  final Widget child;
  
  const DeepLinkHandler({
    super.key,
    required this.child,
  });

  @override
  ConsumerState<DeepLinkHandler> createState() => _DeepLinkHandlerState();
}

class _DeepLinkHandlerState extends ConsumerState<DeepLinkHandler> {
  @override
  void initState() {
    super.initState();
    // Inizializza il servizio Deep Links
    DeepLinkService.initDeepLinks(ref);
  }

  @override
  Widget build(BuildContext context) {
    // Ascolta i Deep Links ricevuti
    ref.listen(DeepLinkService.deepLinkProvider, (previous, next) {
      if (next != null) {
        final card = DeepLinkService.decodeDeepLink(next);
        if (card != null) {
          // Usa un delay per assicurarsi che il context sia pronto
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              // Mostra un dialog per confermare l'importazione
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(AppLocalizations.of(context)?.importCard ?? 'Import Card'),
                  content: Text('${AppLocalizations.of(context)?.importCardMessage ?? 'Do you want to import this card?'}\n\n${card.name}'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(AppLocalizations.of(context)?.cancel ?? 'Cancel'),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: card.colorValue != null 
                            ? Color(card.colorValue!) 
                            : Colors.indigo,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () async {
                        // Importa la tessera
                        ref.read(fidelityCardsProvider.notifier).addCard(card);
                        Navigator.pop(context);
                        // L'importazione è completata, l'utente vedrà la tessera nella lista
                      },
                      child: Text(AppLocalizations.of(context)?.importCard ?? 'Import'),
                    ),
                  ],
                ),
              );
            }
          });
        }
      }
    });

    return widget.child;
  }
} 