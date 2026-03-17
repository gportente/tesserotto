import 'dart:convert';
import 'dart:io';
import 'package:home_widget/home_widget.dart';
import '../models/fidelity_card.dart';

class HomeWidgetService {
  static Future<void> pinCard(FidelityCard card) async {
    if (!Platform.isAndroid && !Platform.isIOS) return;
    final data = {
      'id': card.id,
      'name': card.name,
      'description': card.description,
      'colorValue': card.colorValue,
    };
    await HomeWidget.saveWidgetData<String>('pinned_card', jsonEncode(data));
    await HomeWidget.updateWidget(androidName: 'TesserottoWidgetProvider');
  }

  static Future<void> unpinCard() async {
    if (!Platform.isAndroid && !Platform.isIOS) return;
    await HomeWidget.saveWidgetData<String>('pinned_card', null);
    await HomeWidget.updateWidget(androidName: 'TesserottoWidgetProvider');
  }

  /// Called when a card is deleted — unpin it if it was the pinned one.
  static Future<void> unpinIfDeleted(String cardId) async {
    if (!Platform.isAndroid && !Platform.isIOS) return;
    final raw = await HomeWidget.getWidgetData<String>('pinned_card');
    if (raw == null) return;
    try {
      final data = jsonDecode(raw) as Map<String, dynamic>;
      if (data['id'] == cardId) await unpinCard();
    } catch (_) {}
  }

  // Keep backward-compat signature used by provider (no-op now — widget is
  // only updated when user explicitly pins a card).
  static Future<void> updateWidget(List<FidelityCard> cards) async {}
}
