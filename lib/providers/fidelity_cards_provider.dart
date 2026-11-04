import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/fidelity_card.dart';
import '../database/database_helper.dart';
import '../services/home_widget_service.dart';

final fidelityCardsProvider = StateNotifierProvider<FidelityCardsNotifier, List<FidelityCard>>((ref) {
  return FidelityCardsNotifier();
});

class FidelityCardsNotifier extends StateNotifier<List<FidelityCard>> {
  FidelityCardsNotifier() : super([]) {
    _loadCards();
  }

  /// Pushes the current card list to the home-screen widget.
  void _syncWidget() {
    HomeWidgetService.syncTopCards(state);
  }

  Future<void> _loadCards() async {
    final cards = await DatabaseHelper.instance.getAllCards();
    state = cards;
    _syncWidget();
  }

  Future<void> addCard(FidelityCard card) async {
    // Genera un nuovo ID univoco per evitare conflitti
    final newId = '${DateTime.now().millisecondsSinceEpoch}_${card.id.hashCode}';
    // New cards go to the end of the custom order.
    final nextOrder = state.isEmpty
        ? 0
        : state.map((c) => c.orderIndex).reduce((a, b) => a > b ? a : b) + 1;
    final newCard = card.copyWith(
      id: newId,
      orderIndex: card.orderIndex != 0 ? card.orderIndex : nextOrder,
      createdAt: DateTime.now(),
    );

    await DatabaseHelper.instance.insertCard(newCard);
    state = [...state, newCard];
    _syncWidget();
  }

  /// Persists a manual drag-and-drop reordering of the whole list.
  ///
  /// [oldIndex]/[newIndex] refer to positions in the current custom order
  /// (i.e. [state], which is stored in `orderIndex` order). Uses the
  /// reorderable_grid_view convention: remove at old, insert at new directly.
  Future<void> reorder(int oldIndex, int newIndex) async {
    final list = [...state];
    if (oldIndex < 0 || oldIndex >= list.length) return;
    newIndex = newIndex.clamp(0, list.length - 1);
    if (oldIndex == newIndex) return;

    final moved = list.removeAt(oldIndex);
    list.insert(newIndex, moved);

    // Reassign sequential indices and update the UI *synchronously* so the grid
    // never flashes the old order while we persist to the DB.
    final reindexed = <FidelityCard>[];
    final toPersist = <FidelityCard>[];
    for (var i = 0; i < list.length; i++) {
      final c = list[i];
      if (c.orderIndex != i) {
        final updated = c.copyWith(orderIndex: i);
        reindexed.add(updated);
        toPersist.add(updated);
      } else {
        reindexed.add(c);
      }
    }
    state = reindexed;
    _syncWidget();

    // Persist only the cards that actually moved, after the UI has updated.
    for (final updated in toPersist) {
      await DatabaseHelper.instance.updateCard(updated);
    }
  }

  Future<void> removeCard(String id) async {
    await DatabaseHelper.instance.deleteCard(id);
    state = state.where((card) => card.id != id).toList();
    _syncWidget();
  }

  Future<void> updateCard(FidelityCard updatedCard) async {
    await DatabaseHelper.instance.updateCard(updatedCard);
    state = state.map((card) => card.id == updatedCard.id ? updatedCard : card).toList();
    _syncWidget();
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
    _syncWidget();
  }

  Future<void> clearAll() async {
    final db = await DatabaseHelper.instance.database;
    await db.delete('fidelity_cards');
    state = [];
    _syncWidget();
  }

  Future<void> importCards(List<FidelityCard> cards) async {
    final db = await DatabaseHelper.instance.database;
    await db.delete('fidelity_cards'); // Clear existing cards
    final ordered = <FidelityCard>[];
    for (var i = 0; i < cards.length; i++) {
      final card = cards[i].copyWith(orderIndex: i);
      await DatabaseHelper.instance.insertCard(card);
      ordered.add(card);
    }
    state = ordered;
    _syncWidget();
  }
}
