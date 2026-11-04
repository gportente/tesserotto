import 'dart:convert';
import 'dart:io';
import 'package:home_widget/home_widget.dart';
import '../models/fidelity_card.dart';

/// Keeps the home-screen widget in sync with the app's cards.
///
/// The widget always shows the [maxCards] most-used cards (favorites first,
/// then by open count). Tapping a specific card opens it directly in the app
/// via a `tesserotto://card?id=<id>` launch URI handled on the Flutter side.
class HomeWidgetService {
  static const String androidName = 'TesserottoWidgetProvider';
  static const String _dataKey = 'top_cards';
  static const int maxCards = 5;

  static bool get _supported => Platform.isAndroid || Platform.isIOS;

  /// Recomputes the top cards from [cards] and refreshes the widget.
  static Future<void> syncTopCards(List<FidelityCard> cards) async {
    if (!_supported) return;

    final sorted = [...cards]..sort((a, b) {
        if (a.isFavorite != b.isFavorite) return a.isFavorite ? -1 : 1;
        final byCount = b.openCount.compareTo(a.openCount);
        if (byCount != 0) return byCount;
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      });

    final top = sorted
        .take(maxCards)
        .map((c) => {
              'id': c.id,
              'name': c.name,
              'description': c.description,
              'colorValue': c.colorValue,
            })
        .toList();

    await HomeWidget.saveWidgetData<String>(_dataKey, jsonEncode(top));
    await HomeWidget.updateWidget(androidName: androidName);
  }
}
