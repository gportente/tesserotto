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

  @override
  String get driveBackupSection => 'Google Drive';

  @override
  String get driveSignIn => 'Accedi con Google';

  @override
  String get driveSignOut => 'Disconnetti';

  @override
  String get driveBackupNow => 'Esegui backup';

  @override
  String get driveRestoreButton => 'Ripristina da Drive';

  @override
  String driveSignedInAs(String email) {
    return 'Connesso come $email';
  }

  @override
  String driveLastBackup(String date) {
    return 'Ultimo backup: $date';
  }

  @override
  String get driveBackupSuccess => 'Backup completato';

  @override
  String get driveRestoreSuccess => 'Ripristino completato';

  @override
  String get driveBackupError => 'Errore durante il backup';

  @override
  String get driveRestoreError => 'Errore durante il ripristino';

  @override
  String get driveNoBackupFound => 'Nessun backup trovato su Drive';

  @override
  String get driveRestoreConfirmTitle => 'Ripristina da Drive';

  @override
  String get driveRestoreConfirmContent => 'Questa operazione sostituirà tutte le tessere esistenti con quelle del backup. Continuare?';

  @override
  String get addToFavorites => 'Aggiungi ai preferiti';

  @override
  String get removeFromFavorites => 'Rimuovi dai preferiti';

  @override
  String get deleteCardAction => 'Elimina tessera';

  @override
  String get pinToWidget => 'Imposta come widget';

  @override
  String get pinnedToWidget => 'Tessera impostata come widget';
}
