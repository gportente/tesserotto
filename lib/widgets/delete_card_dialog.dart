import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

class DeleteCardDialog extends StatelessWidget {
  final String cardName;
  final AppLocalizations loc;
  const DeleteCardDialog({super.key, required this.cardName, required this.loc});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(loc.deleteCardTitle),
      content: Text(loc.deleteCardMessage(cardName)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(loc.deleteCardCancel),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.error,
            foregroundColor: Theme.of(context).colorScheme.onError,
          ),
          onPressed: () => Navigator.pop(context, true),
          child: Text(loc.deleteCardConfirm),
        ),
      ],
    );
  }
} 