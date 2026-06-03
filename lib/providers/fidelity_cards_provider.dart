import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/fidelity_card.dart';
import '../models/card_location.dart';
import '../database/database_helper.dart';
import '../services/home_widget_service.dart';

final fidelityCardsProvider =
    StateNotifierProvider<FidelityCardsNotifier, List<FidelityCard>>((ref) {
  return FidelityCardsNotifier();
});

class FidelityCardsNotifier extends StateNotifier<List<FidelityCard>> {
  FidelityCardsNotifier() : super([]) {
    _loadCards();
  }

  Future<void> _loadCards() async {
    final cards = await DatabaseHelper.instance.getAllCards();
    final withLocations = await Future.wait(cards.map((card) async {
      final locs = await DatabaseHelper.instance.getLocationsForCard(card.id);
      return card.copyWith(locations: locs);
    }));
    state = withLocations;
  }

  Future<void> addCard(FidelityCard card) async {
    await addCardWithLocations(card, const []);
  }

  Future<void> addCardWithLocations(
      FidelityCard card, List<CardLocation> locations) async {
    final newId =
        '${DateTime.now().millisecondsSinceEpoch}_${card.id.hashCode}';
    final locs =
        locations.map((l) => l.copyWith(cardId: newId)).toList();
    final newCard =
        card.copyWith(id: newId, createdAt: DateTime.now(), locations: locs);

    await DatabaseHelper.instance.insertCard(newCard);
    for (final loc in locs) {
      await DatabaseHelper.instance.insertLocation(loc);
    }
    state = [...state, newCard];
  }

  Future<void> removeCard(String id) async {
    await DatabaseHelper.instance.deleteCard(id);
    state = state.where((card) => card.id != id).toList();
    await HomeWidgetService.unpinIfDeleted(id);
  }

  Future<void> updateCard(FidelityCard updatedCard) async {
    await DatabaseHelper.instance.updateCard(updatedCard);
    state =
        state.map((c) => c.id == updatedCard.id ? updatedCard : c).toList();
  }

  Future<void> updateCardWithLocations(
      FidelityCard card, List<CardLocation> locations) async {
    final locs =
        locations.map((l) => l.copyWith(cardId: card.id)).toList();
    final updated = card.copyWith(locations: locs);

    await DatabaseHelper.instance.updateCard(updated);
    await DatabaseHelper.instance.deleteLocationsForCard(card.id);
    for (final loc in locs) {
      await DatabaseHelper.instance.insertLocation(loc);
    }
    state = state.map((c) => c.id == card.id ? updated : c).toList();
  }

  Future<void> incrementOpenCount(String id) async {
    final card = state.firstWhere((c) => c.id == id);
    final updatedCard = card.copyWith(openCount: card.openCount + 1);
    await updateCard(updatedCard);
  }

  Future<void> toggleFavorite(String id) async {
    final card = state.firstWhere((c) => c.id == id);
    final updated = card.copyWith(isFavorite: !card.isFavorite);
    await DatabaseHelper.instance.updateCard(updated);
    state = state.map((c) => c.id == id ? updated : c).toList();
  }

  Future<void> clearAll() async {
    final db = await DatabaseHelper.instance.database;
    await db.delete('card_locations');
    await db.delete('fidelity_cards');
    state = [];
    await HomeWidgetService.unpinCard();
  }

  Future<void> importCards(List<FidelityCard> cards) async {
    final db = await DatabaseHelper.instance.database;
    await db.delete('card_locations');
    await db.delete('fidelity_cards');
    for (final card in cards) {
      await DatabaseHelper.instance.insertCard(card);
    }
    state = cards;
  }
}
