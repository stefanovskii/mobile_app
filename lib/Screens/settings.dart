import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  final ValueNotifier<bool> darkModeNotifier;

  const SettingsScreen({Key? key, required this.darkModeNotifier}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF163D37)),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Settings',
          style: TextStyle(color: Color(0xFF163D37), fontSize: 28),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Activate Dark Mode',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12.0),
            const Divider(
              color: Colors.black,
              thickness: 1.0,
            ),
            ValueListenableBuilder<bool>(
              valueListenable: darkModeNotifier,
              builder: (context, isDarkMode, child) {
                return SwitchListTile(
                  title: const Text(
                    'Dark Mode',
                    style: TextStyle(fontSize: 18.0),
                  ),
                  value: isDarkMode,
                  onChanged: (bool value) {
                    darkModeNotifier.value = value;
                  },
                  activeColor: Colors.green,
                  inactiveThumbColor: Colors.grey,
                  activeTrackColor: Colors.greenAccent,
                  inactiveTrackColor: Colors.grey.shade400,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
