import 'package:flutter/material.dart';
import 'package:notes/data/userDatabase.dart';
import 'package:notes/main.dart';
import 'package:notes/model/language.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  UserDatabase userDB = UserDatabase();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Nastavení"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      "Jazyk",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  DropdownButton(
                    items: Language.languageList()
                        .map(
                          (e) => DropdownMenuItem(
                              value: e,
                              child: Row(
                                children: [
                                  Text(
                                    e.flag,
                                    style: const TextStyle(fontSize: 30),
                                  ),
                                  const SizedBox(width: 10.0),
                                  Text(e.name)
                                ],
                              )),
                        )
                        .toList(),
                    onChanged: (Language? language) {
                      if (language != null) {
                        MyApp.setLocale(context, Locale(language.langCode));
                        userDB.saveLocale(language.langCode);
                      }
                    },
                  ),
                ],
              ),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      "Smazat data",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {},
                    child: const Text('Smazat'),
                  ),
                ],
              ),
            ),
            const Divider(),
          ],
        ),
      ),
    );
  }
}
