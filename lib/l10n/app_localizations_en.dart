// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Tesserotto';

  @override
  String get settings => 'Settings';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get searchHint => 'Search cards...';

  @override
  String get noCards => 'No cards yet. Tap + to add your first card!';

  @override
  String get addCard => 'Add Card';

  @override
  String get editCard => 'Edit Card';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get cardName => 'Card Name';

  @override
  String get description => 'Description';

  @override
  String get cardColor => 'Card Color';

  @override
  String get barcode => 'Barcode';

  @override
  String get type => 'Type';

  @override
  String get scan => 'Scan';

  @override
  String get rescan => 'Rescan';

  @override
  String get cancelScanning => 'Cancel Scanning';

  @override
  String get cardInfo => 'Card Info';

  @override
  String get deleteCard => 'Delete Card';

  @override
  String get deleteCardConfirm => 'Delete';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get sortAZ => 'A-Z';

  @override
  String get sortMostOpened => 'Most Opened';

  @override
  String get language => 'Language';

  @override
  String get deleteCardTitle => 'Delete Cardx2';

  @override
  String deleteCardMessage(Object cardName) {
    return 'Are you sure you want to delete \"$cardName\"?';
  }

  @override
  String get deleteCardCancel => 'Cancel';

  @override
  String get importExport => 'Import/Export';

  @override
  String get exportCards => 'Export Cards';

  @override
  String get exportDescription => 'Export your cards to a backup file';

  @override
  String get export => 'Export';

  @override
  String get exportSuccess => 'Cards exported successfully';

  @override
  String get exportError => 'Error exporting cards';

  @override
  String get importCards => 'Import Cards';

  @override
  String get importDescription => 'Import cards from a backup file';

  @override
  String get importCard => 'Import Card';

  @override
  String get importCardMessage => 'Do you want to import this card?';

  @override
  String get importSuccess => 'Cards imported successfully';

  @override
  String get importError => 'Error importing cards';

  @override
  String get importFromCatima => 'Import from Catima';

  @override
  String get importFromCatimaDescription => 'Import cards from a Catima backup file';

  @override
  String get deleteAllCardsTitle => 'Delete Cards';

  @override
  String get deleteAllCardsContent => 'Are you sure you want to delete all cards? This action cannot be undone.';

  @override
  String get deleteAllCardsConfirm => 'Confirm';

  @override
  String get shareCardMessage => 'Check out this loyalty card';

  @override
  String get shareViaQr => 'Share via QR code';

  @override
  String get shareViaLink => 'Share via link';

  @override
  String get driveBackupSection => 'Google Drive';

  @override
  String get driveSignIn => 'Sign in with Google';

  @override
  String get driveSignOut => 'Sign out';

  @override
  String get driveBackupNow => 'Back up now';

  @override
  String get driveRestoreButton => 'Restore from Drive';

  @override
  String driveSignedInAs(String email) {
    return 'Signed in as $email';
  }

  @override
  String driveLastBackup(String date) {
    return 'Last backup: $date';
  }

  @override
  String get driveBackupSuccess => 'Backup completed';

  @override
  String get driveRestoreSuccess => 'Restore completed';

  @override
  String get driveBackupError => 'Backup failed';

  @override
  String get driveRestoreError => 'Restore failed';

  @override
  String get driveNoBackupFound => 'No backup found on Drive';

  @override
  String get driveRestoreConfirmTitle => 'Restore from Drive';

  @override
  String get driveRestoreConfirmContent => 'This will replace all existing cards with the backup. Continue?';

  @override
  String get addToFavorites => 'Add to favorites';

  @override
  String get removeFromFavorites => 'Remove from favorites';

  @override
  String get deleteCardAction => 'Delete card';

  @override
  String get pinToWidget => 'Set as home screen widget';

  @override
  String get pinnedToWidget => 'Card set as widget';
}
