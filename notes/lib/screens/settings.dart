import 'package:flutter/material.dart';
import 'package:notes/main.dart';
import 'package:notes/model/language.dart';

class Settings extends StatelessWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Nastavení"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              Row(
                children: [
                  const Text("Jazyk"),
                  DropdownButton(
                    items: Language.languageList()
                        .map(
                          (e) => DropdownMenuItem(
                            value: e,
                            child: Text(
                              e.flag,
                              style: const TextStyle(fontSize: 30),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (Language? language) {
                      if (language != null) {
                        MyApp.setLocale(context, Locale(language.langCode));
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
