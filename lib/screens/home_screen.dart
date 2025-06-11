import 'dart:typed_data';

import 'package:fidelity_cards_manager/screens/import_export_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:convert';
import 'dart:io';
import '../models/fidelity_card.dart';
import '../providers/fidelity_cards_provider.dart';
import '../widgets/animated_card.dart';
import '../widgets/page_transition.dart';
import 'add_card_screen.dart';
import 'card_details_screen.dart';
import 'settings_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../widgets/delete_card_dialog.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String _search = '';
  String _sort = 'name'; // 'name' or 'openCount'

  @override
  Widget build(BuildContext context) {
    final cards = ref.watch(fidelityCardsProvider);
    List<FidelityCard> filteredCards = (_search.isEmpty
        ? cards
        : cards.where((c) => c.name.toLowerCase().contains(_search.toLowerCase())))
      .whereType<FidelityCard>()
      .toList();
    if (_sort == 'name') {
      filteredCards.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    } else if (_sort == 'openCount') {
      filteredCards.sort((b, a) => a.openCount.compareTo(b.openCount));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.appTitle),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const SizedBox(height: 32),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  PageTransition(
                    page: const SettingsScreen(),
                  ),
                );
              },
            ),
            ListTile(
							leading: const Icon(Icons.import_export),
							title: Text(AppLocalizations.of(context)!.importExport),
							onTap: () {
								Navigator.push(
									context,
									PageTransition(
										page: const ImportExportScreen(),
									),
								);
							},
						),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: Material(
                    elevation: 2,
                    borderRadius: BorderRadius.circular(30),
                    color: Colors.transparent,
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(context)!.searchHint,
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _search.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  setState(() {
                                    _search = '';
                                  });
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _search = value;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.sort),
                  tooltip: 'Sort',
                  onSelected: (value) {
                    setState(() {
                      _sort = value;
                    });
                  },
                  itemBuilder: (context) => [
                    CheckedPopupMenuItem(
                      value: 'name',
                      checked: _sort == 'name',
                      child: Text(AppLocalizations.of(context)!.sortAZ),
                    ),
                    CheckedPopupMenuItem(
                      value: 'openCount',
                      checked: _sort == 'openCount',
                      child: Text(AppLocalizations.of(context)!.sortMostOpened),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: filteredCards.isEmpty
                ? Padding(
									padding: EdgeInsets.only(left: 15, right: 15),
									child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 240,
                        child: SvgPicture.asset(
                          'assets/empty_cards.svg',
                          semanticsLabel: 'No cards',
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        AppLocalizations.of(context)!.noCards,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
								)
                : Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.3,
                      ),
                      itemCount: filteredCards.length,
                      itemBuilder: (context, index) {
                        final card = filteredCards[index];
                        final cardColor = card.colorValue != null
                            ? Color(card.colorValue!)
                            : _getRandomCardColor(card.name);
                        return AnimatedCard(
                          card: card,
                          cardColor: cardColor,
                          onTap: () async {
                            await ref.read(fidelityCardsProvider.notifier).incrementOpenCount(card.id);
                            Navigator.push(
                              context,
                              PageTransition(
                                page: CardDetailsScreen(card: card),
                              ),
                            );
                          },
                          onLongPress: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (context) => DeleteCardDialog(
                                cardName: card.name,
                                loc: AppLocalizations.of(context)!,
                              ),
                            );
                            if (confirm == true) {
                              ref.read(fidelityCardsProvider.notifier).removeCard(card.id);
                            }
                          },
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            PageTransition(
              page: const AddCardScreen(),
            ),
          );
        },
        tooltip: 'Add Card',
        child: const Icon(Icons.add_rounded),
      ),
    );
  }
}

Color _getRandomCardColor(String name) {
  final colors = [
    const Color(0xFF4F8FFF),
    const Color(0xFF6FE7DD),
    const Color(0xFFFFB86B),
    const Color(0xFFFC5C7D),
    const Color(0xFF43E97B),
    const Color(0xFF38F9D7),
    const Color(0xFF667EEA),
    const Color(0xFF764BA2),
    const Color(0xFFFF6A6A),
    const Color(0xFF36D1C4),
  ];
  final hash = name.isNotEmpty ? name.codeUnits.reduce((a, b) => a + b) : 0;
  return colors[hash % colors.length];
} 