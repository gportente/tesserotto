import 'dart:async';
import 'package:fidelity_cards_manager/screens/import_export_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:home_widget/home_widget.dart';
import '../main.dart';
import '../models/fidelity_card.dart';
import '../providers/fidelity_cards_provider.dart';
import '../widgets/animated_card.dart';
import '../widgets/page_transition.dart';
import 'add_card_screen.dart';
import 'card_details_screen.dart';
import 'settings_screen.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../providers/settings_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String _search = '';
  StreamSubscription<Uri?>? _widgetClickSub;
  String? _pendingWidgetCardId;

  @override
  void initState() {
    super.initState();
    // App launched cold by tapping a card in the widget.
    HomeWidget.initiallyLaunchedFromHomeWidget().then(_onWidgetLaunch);
    // App already running when a widget card is tapped.
    _widgetClickSub = HomeWidget.widgetClicked.listen(_onWidgetLaunch);
  }

  @override
  void dispose() {
    _widgetClickSub?.cancel();
    super.dispose();
  }

  /// Parses a `tesserotto://card?id=<id>` launch URI coming from the widget.
  void _onWidgetLaunch(Uri? uri) {
    if (uri == null || uri.host != 'card') return;
    final id = uri.queryParameters['id'];
    if (id == null || id.isEmpty) return;
    _pendingWidgetCardId = id;
    _openPendingWidgetCard();
  }

  /// Opens the pending widget card once it's available in the provider.
  /// On a cold start the card list may still be loading, so this is retried
  /// from [build] via `ref.listen` whenever the list changes.
  void _openPendingWidgetCard() {
    final id = _pendingWidgetCardId;
    if (id == null) return;
    final cards = ref.read(fidelityCardsProvider);
    final match = cards.where((c) => c.id == id);
    if (match.isEmpty) return; // not loaded yet — retry on next change
    _pendingWidgetCardId = null;
    final card = match.first;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final nav = navigatorKey.currentState;
      if (nav == null) return;
      ref.read(fidelityCardsProvider.notifier).incrementOpenCount(card.id);
      nav.push(PageTransition(page: CardDetailsScreen(card: card)));
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final loc = AppLocalizations.of(context)!;
    final cards = ref.watch(fidelityCardsProvider);

    // Retry opening a widget-launched card once the list finishes loading.
    ref.listen(fidelityCardsProvider, (_, __) {
      if (_pendingWidgetCardId != null) _openPendingWidgetCard();
    });
    final sort = ref.watch(settingsProvider).defaultSort;

    List<FidelityCard> filteredCards = (_search.isEmpty
            ? cards
            : cards.where((c) {
                final q = _search.toLowerCase();
                return c.name.toLowerCase().contains(q) ||
                    c.description.toLowerCase().contains(q);
              }))
        .whereType<FidelityCard>()
        .toList();
    filteredCards.sort((a, b) {
      if (a.isFavorite && !b.isFavorite) return -1;
      if (!a.isFavorite && b.isFavorite) return 1;
      if (sort == 'name') {
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      }
      return b.openCount.compareTo(a.openCount);
    });

    final isSearching = cards.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: AppSpacing.xl,
        title: Text(loc.appTitle),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu_rounded),
            tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      drawer: _buildDrawer(context, loc, p),
      body: Column(
        children: [
          if (isSearching)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.md),
              child: Row(
                children: [
                  Expanded(child: _searchField(loc, p)),
                  const SizedBox(width: AppSpacing.sm),
                  _sortButton(loc, p, sort),
                ],
              ),
            ),
          Expanded(
            child: filteredCards.isEmpty
                ? (_search.isEmpty
                    ? _emptyState(context, loc, p)
                    : _noResults(loc, p))
                : GridView.builder(
                    padding: const EdgeInsets.fromLTRB(AppSpacing.lg,
                        AppSpacing.xs, AppSpacing.lg, 100),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: AppSpacing.md,
                      mainAxisSpacing: AppSpacing.md,
                      childAspectRatio: 1.42,
                    ),
                    itemCount: filteredCards.length,
                    itemBuilder: (context, index) {
                      final card = filteredCards[index];
                      final cardColor = card.colorValue != null
                          ? Color(card.colorValue!)
                          : cardColorFromName(card.name);
                      return AnimatedCard(
                        key: ValueKey(card.id),
                        index: index,
                        card: card,
                        cardColor: cardColor,
                        onTap: () async {
                          await ref
                              .read(fidelityCardsProvider.notifier)
                              .incrementOpenCount(card.id);
                          if (!context.mounted) return;
                          Navigator.push(
                            context,
                            PageTransition(page: CardDetailsScreen(card: card)),
                          );
                        },
                        onLongPress: () => _showCardActions(context, card, loc),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          PageTransition(page: const AddCardScreen()),
        ),
        icon: const Icon(Icons.add_rounded),
        label: Text(loc.addCard),
      ),
    );
  }

  Widget _searchField(AppLocalizations loc, AppPalette p) {
    return TextField(
      textInputAction: TextInputAction.search,
      style: context.text.bodyLarge,
      decoration: InputDecoration(
        hintText: loc.searchHint,
        prefixIcon: Icon(Icons.search_rounded, color: p.inkFaint),
        suffixIcon: _search.isNotEmpty
            ? IconButton(
                icon: Icon(Icons.close_rounded, color: p.inkSoft),
                onPressed: () => setState(() => _search = ''),
              )
            : null,
        filled: true,
        fillColor: p.surfaceMuted,
        contentPadding: const EdgeInsets.symmetric(vertical: 0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.pill),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.pill),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.pill),
          borderSide: BorderSide(color: p.accent, width: 1.5),
        ),
      ),
      onChanged: (value) => setState(() => _search = value),
    );
  }

  Widget _sortButton(AppLocalizations loc, AppPalette p, String sort) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: p.surfaceMuted,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: PopupMenuButton<String>(
        icon: Icon(Icons.sort_rounded, color: p.ink),
        tooltip: loc.sortAZ,
        onSelected: (value) =>
            ref.read(settingsProvider.notifier).setDefaultSort(value),
        itemBuilder: (context) => [
          CheckedPopupMenuItem(
            value: 'name',
            checked: sort == 'name',
            child: Text(loc.sortAZ),
          ),
          CheckedPopupMenuItem(
            value: 'openCount',
            checked: sort == 'openCount',
            child: Text(loc.sortMostOpened),
          ),
        ],
      ),
    );
  }

  Widget _emptyState(BuildContext context, AppLocalizations loc, AppPalette p) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 200,
              child: SvgPicture.asset('assets/empty_cards.svg',
                  semanticsLabel: 'No cards'),
            ),
            const SizedBox(height: AppSpacing.xxl),
            Text(
              loc.noCards,
              style: context.text.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xxl),
            ElevatedButton.icon(
              onPressed: () => Navigator.push(
                context,
                PageTransition(page: const AddCardScreen()),
              ),
              icon: const Icon(Icons.add_rounded),
              label: Text(loc.addCard),
            ),
          ],
        ),
      ),
    );
  }

  Widget _noResults(AppLocalizations loc, AppPalette p) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search_off_rounded, size: 56, color: p.inkFaint),
          const SizedBox(height: AppSpacing.lg),
          Text(loc.noCards,
              style: context.text.titleMedium?.copyWith(color: p.inkSoft)),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context, AppLocalizations loc, AppPalette p) {
    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.xxl,
                  AppSpacing.xl, AppSpacing.xl),
              child: Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: p.accentSoft,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Icon(Icons.wallet_rounded, color: p.accent),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Text(loc.appTitle, style: context.text.titleLarge),
                ],
              ),
            ),
            Divider(color: p.hairline, indent: AppSpacing.xl, endIndent: AppSpacing.xl),
            const SizedBox(height: AppSpacing.sm),
            _drawerItem(
              icon: Icons.settings_outlined,
              label: loc.settings,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                    context, PageTransition(page: const SettingsScreen()));
              },
            ),
            _drawerItem(
              icon: Icons.sync_alt_rounded,
              label: loc.importExport,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                    context, PageTransition(page: const ImportExportScreen()));
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _drawerItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.xs),
      child: ListTile(
        leading: Icon(icon),
        title: Text(label),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      ),
    );
  }

  /// Optimistic delete with an Undo affordance — no confirmation dialog.
  void _deleteWithUndo(FidelityCard card, AppLocalizations loc) {
    HapticFeedback.mediumImpact();
    ref.read(fidelityCardsProvider.notifier).removeCard(card.id);
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        content: Text(loc.cardDeleted),
        action: SnackBarAction(
          label: loc.undo,
          onPressed: () =>
              ref.read(fidelityCardsProvider.notifier).addCard(card),
        ),
      ),
    );
  }

  Future<void> _showCardActions(
      BuildContext context, FidelityCard card, AppLocalizations loc) async {
    final p = context.palette;
    await showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: AppSpacing.md),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: p.hairline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xxl, AppSpacing.md, AppSpacing.xxl, AppSpacing.xs),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(card.name, style: context.text.titleMedium),
              ),
            ),
            ListTile(
              leading: Icon(
                card.isFavorite
                    ? Icons.star_rounded
                    : Icons.star_border_rounded,
                color: p.star,
              ),
              title: Text(card.isFavorite
                  ? loc.removeFromFavorites
                  : loc.addToFavorites),
              onTap: () {
                Navigator.pop(ctx);
                HapticFeedback.selectionClick();
                ref.read(fidelityCardsProvider.notifier).toggleFavorite(card.id);
              },
            ),
            ListTile(
              leading: Icon(Icons.delete_outline_rounded, color: p.danger),
              title: Text(loc.deleteCardAction,
                  style: TextStyle(color: p.danger)),
              onTap: () {
                Navigator.pop(ctx);
                _deleteWithUndo(card, loc);
              },
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
        ),
      ),
    );
  }
}
