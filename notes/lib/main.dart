import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static const appTitle = 'Notes';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text(appTitle),
        ),
        drawer: Drawer(
          child: ListView(
            padding: const EdgeInsets.all(0),
            children: const [
              DrawerHeader(decoration: BoxDecoration(color: Colors.blue),
                  child: UserAccountsDrawerHeader(accountName: Text('Lukas Runt'), accountEmail: Text('lukas.runt@gmail.com')))
            ],
          ),
        ),
        body: Card(
          child: Column(children: <Widget>[
            const Text('Nová poznámka bude zde...')
          ],),
        ),
      ),
    );
  }
}
