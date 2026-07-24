import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';

class DeleteCardDialog extends StatelessWidget {
  final String cardName;
  final AppLocalizations loc;
  const DeleteCardDialog({super.key, required this.cardName, required this.loc});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return AlertDialog(
      icon: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: p.danger.withOpacity(0.12),
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.delete_outline_rounded, color: p.danger, size: 26),
      ),
      title: Text(loc.deleteCardTitle, textAlign: TextAlign.center),
      content: Text(
        loc.deleteCardMessage(cardName),
        textAlign: TextAlign.center,
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        TextButton(
          style: TextButton.styleFrom(
            foregroundColor: p.inkSoft,
            minimumSize: const Size(0, 48),
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          ),
          onPressed: () => Navigator.pop(context, false),
          child: Text(loc.deleteCardCancel),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: p.danger,
            foregroundColor: Colors.white,
            minimumSize: const Size(0, 48),
          ),
          onPressed: () => Navigator.pop(context, true),
          child: Text(loc.deleteCardConfirm),
        ),
      ],
    );
  }
}
