import 'package:flutter/material.dart';

class Language {
  final String flag;
  final String name;
  final String langCode;

  Language(this.flag, this.name, this.langCode);

  static List<Language> languageList() {
    return <Language>[
      Language("🇬🇧", "English", "en"),
      Language("🇨🇿", "Czech", "cs")
    ];
  }
}
