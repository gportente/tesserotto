import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/fidelity_card.dart';
import '../database/database_helper.dart';

final fidelityCardsProvider = StateNotifierProvider<FidelityCardsNotifier, List<FidelityCard>>((ref) {
  return FidelityCardsNotifier();
});

class FidelityCardsNotifier extends StateNotifier<List<FidelityCard>> {
  FidelityCardsNotifier() : super([]) {
    _loadCards();
  }

  Future<void> _loadCards() async {
    final cards = await DatabaseHelper.instance.getAllCards();
    state = cards;
  }

  Future<void> addCard(FidelityCard card) async {
    await DatabaseHelper.instance.insertCard(card);
    state = [...state, card];
  }

  Future<void> removeCard(String id) async {
    await DatabaseHelper.instance.deleteCard(id);
    state = state.where((card) => card.id != id).toList();
  }

  Future<void> updateCard(FidelityCard updatedCard) async {
    await DatabaseHelper.instance.updateCard(updatedCard);
    state = state.map((card) => card.id == updatedCard.id ? updatedCard : card).toList();
  }

  Future<void> incrementOpenCount(String id) async {
    final card = state.firstWhere((c) => c.id == id);
    final updatedCard = card.copyWith(openCount: card.openCount + 1);
    await updateCard(updatedCard);
  }

  Future<void> clearAll() async {
    final db = await DatabaseHelper.instance.database;
    await db.delete('fidelity_cards');
    state = [];
  }

  Future<void> importCards(List<FidelityCard> cards) async {
    final db = await DatabaseHelper.instance.database;
    await db.delete('fidelity_cards'); // Clear existing cards
    for (final card in cards) {
      await DatabaseHelper.instance.insertCard(card);
    }
    state = cards;
  }
} 