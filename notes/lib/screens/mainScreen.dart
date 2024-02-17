import 'package:flutter/material.dart';
import 'package:notes/services/loginOrRegister.dart';
import 'package:notes/components/myTreeview.dart';

class MainScreen extends StatelessWidget {
  static const appTitle = 'Notes';

  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(appTitle),
      ),
      drawer: Drawer(
        child: ListView(
          padding: const EdgeInsets.all(0),
          children: [
            const DrawerHeader(
                decoration: BoxDecoration(color: Colors.blue),
                child: UserAccountsDrawerHeader(
                    accountName: Text('Lukas Runt'),
                    accountEmail: Text('lukas.runt@gmail.com'))),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const LoginOrRegister()),
                );
              },
              child: const Text('Login'),
            ),
            const MyTreeView(),
          ],
        ),
      ),
      body: const Center(
        child: Text(
          'Here will be rich editor',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 32.0,
          ),
          textAlign: TextAlign.center,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
    );
  }
}
