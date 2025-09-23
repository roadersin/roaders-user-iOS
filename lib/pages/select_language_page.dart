import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../l10n/l10n.dart';
import '../provider/locale_provider.dart';
import '../widgets/language_picker_widget.dart';

class SelectLanguagePage extends StatelessWidget {
  const SelectLanguagePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          AppLocalizations.of(context)!.changeLanguage,
          style: const TextStyle(color: Colors.black),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Image.asset(
              'assets/img/multilanguage.jpg',
              width: 250,
              height: 250,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              AppLocalizations.of(context)!.selectLanguage,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Expanded(
            child: LanguageSelectionList(),
          ),
        ],
      ),
    );
  }
}

class LanguageSelectionList extends StatelessWidget {
  const LanguageSelectionList({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<LocaleProvider>(context);
    final selectedLocale = provider.locale ?? const Locale('en');

    return ListView.builder(
      itemCount: L10n.all.length,
      itemBuilder: (context, index) {
        final locale = L10n.all[index];
        final languageNameNative = L10n.getFlag(locale.languageCode);
        final languageNameEnglish = L10n.getEnglishName(locale.languageCode);

        return RadioListTile<Locale>(
          value: locale,
          groupValue: selectedLocale,
          title: Text(
            languageNameNative,
            style: const TextStyle(fontSize: 18),
          ),
          subtitle: Text(
            languageNameEnglish,
            style: const TextStyle(color: Colors.grey),
          ),
          onChanged: (Locale? value) {
            if (value != null) {
              provider.setLocale(value);
            }
          },
        );
      },
    );
  }
}
