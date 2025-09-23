import 'package:flutter/material.dart';

class L10n {
  static final all = [
    const Locale('en'),
    const Locale('hi'),
    const Locale('mr'),
    const Locale('ta'),
    const Locale('te'),
    const Locale('kn'),
    const Locale('gu'),
  ];

  static String getFlag(String code) {
    switch (code) {
      case 'hi':
        return 'हिन्दी';
      case 'mr':
        return 'मराठी';
      case 'ta':
        return 'தமிழ்';
      case 'te':
        return 'తెలుగు';
      case 'kn':
        return 'ಕನ್ನಡ';
      case 'gu':
        return 'ગુજરાતી';
      default:
        return 'ENG';
    }
  }

  static String getEnglishName(String code) {
    switch (code) {
      case 'hi':
        return 'Hindi';
      case 'mr':
        return 'Marathi';
      case 'ta':
        return 'Tamil';
      case 'te':
        return 'Telugu';
      case 'kn':
        return 'Kannada';
      case 'gu':
        return 'Gujarati';
      default:
        return 'English';
    }
  }
}
