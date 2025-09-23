import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../l10n/l10n.dart';

class LocaleProvider extends ChangeNotifier {
  static const String _localeKey = 'locale';
  Locale? _locale;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  Locale? get locale => _locale;

  LocaleProvider() {
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    try {
      final localeCode = await _secureStorage.read(key: _localeKey);
      if (localeCode != null) {
        final locale = L10n.all.firstWhere(
          (loc) => loc.languageCode == localeCode,
          orElse: () => L10n.all.first,
        );
        _locale = locale;
        notifyListeners();
      }
    } catch (e) {
      // Handle any potential errors when reading from secure storage
      debugPrint('Error loading locale: $e');
    }
  }

  Future<void> setLocale(Locale locale) async {
    if (!L10n.all.contains(locale)) return;

    try {
      _locale = locale;
      await _secureStorage.write(key: _localeKey, value: locale.languageCode);
      notifyListeners();
    } catch (e) {
      // Handle any potential errors when writing to secure storage
      debugPrint('Error saving locale: $e');
    }
  }

  Future<void> clearLocale() async {
    try {
      _locale = null;
      await _secureStorage.delete(key: _localeKey);
      notifyListeners();
    } catch (e) {
      // Handle any potential errors when deleting from secure storage
      debugPrint('Error clearing locale: $e');
    }
  }
}
