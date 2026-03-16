// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appTitle => 'Tesserotto';

  @override
  String get settings => 'Impostazioni';

  @override
  String get darkMode => 'Modalità scura';

  @override
  String get searchHint => 'Cerca tessere...';

  @override
  String get noCards => 'Nessuna tessera. Tocca + per aggiungerne una!';

  @override
  String get addCard => 'Aggiungi Tessera';

  @override
  String get editCard => 'Modifica Tessera';

  @override
  String get saveChanges => 'Salva Modifiche';

  @override
  String get cardName => 'Nome Tessera';

  @override
  String get description => 'Descrizione';

  @override
  String get cardColor => 'Colore Tessera';

  @override
  String get barcode => 'Codice a barre';

  @override
  String get type => 'Tipo';

  @override
  String get scan => 'Scansiona';

  @override
  String get rescan => 'Riscansiona';

  @override
  String get cancelScanning => 'Annulla Scansione';

  @override
  String get cardInfo => 'Info Tessera';

  @override
  String get deleteCard => 'Elimina Tessera';

  @override
  String get deleteCardConfirm => 'Elimina';

  @override
  String get cancel => 'Annulla';

  @override
  String get delete => 'Elimina';

  @override
  String get sortAZ => 'A-Z';

  @override
  String get sortMostOpened => 'Più Aperte';

  @override
  String get language => 'Lingua';

  @override
  String get deleteCardTitle => 'Elimina Tessera';

  @override
  String deleteCardMessage(Object cardName) {
    return 'Sei sicuro di voler eliminare \"$cardName\"?';
  }

  @override
  String get deleteCardCancel => 'Annulla';

  @override
  String get importExport => 'Importa/Esporta';

  @override
  String get exportCards => 'Esporta Carte';

  @override
  String get exportDescription => 'Esporta le tue carte in un file di backup';

  @override
  String get export => 'Esporta';

  @override
  String get exportSuccess => 'Carte esportate con successo';

  @override
  String get exportError => 'Errore durante l\'esportazione delle carte';

  @override
  String get importCards => 'Importa Carte';

  @override
  String get importDescription => 'Importa carte da un file di backup';

  @override
  String get importCard => 'Importa Tessera';

  @override
  String get importCardMessage => 'Vuoi importare questa tessera?';

  @override
  String get importSuccess => 'Carte importate con successo';

  @override
  String get importError => 'Errore durante l\'importazione delle carte';

  @override
  String get importFromCatima => 'Importa da Catima';

  @override
  String get importFromCatimaDescription => 'Importa carte da un file di backup di Catima';

  @override
  String get deleteAllCardsTitle => 'Elimina Tessere';

  @override
  String get deleteAllCardsContent => 'Sei sicuro di voler eliminare tutte le tessere? Questa azione è irreversibile.';

  @override
  String get deleteAllCardsConfirm => 'Conferma';

  @override
  String get shareCardMessage => 'Dai un\'occhiata a questa tessera fedeltà';

  @override
  String get shareViaQr => 'Condividi tramite QR';

  @override
  String get shareViaLink => 'Condividi tramite link';
}
