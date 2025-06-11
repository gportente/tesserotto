import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          onPressed: () => Navigator.pop(context, true),
          child: Text(loc.deleteCardConfirm),
        ),
      ],
    );
  }
} 