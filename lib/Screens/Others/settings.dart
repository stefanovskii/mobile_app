import 'package:flutter/material.dart';
import '../../Constants/app_colors.dart';

class SettingsScreen extends StatelessWidget {
  final ValueNotifier<bool> darkModeNotifier;

  const SettingsScreen({Key? key, required this.darkModeNotifier}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.titles),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Settings',
          style: TextStyle(color: AppColors.titles, fontSize: 28),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Activate Dark Mode',
              style: TextStyle(
                fontSize: 22.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8.0),
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
            const SizedBox(height: 25.0),
            const Text(
              'Application Information',
              style: TextStyle(
                fontSize: 22.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8.0),
            const Divider(
              color: Colors.black,
              thickness: 1.0,
            ),
            const ListTile(
              title: Text('Version'),
              subtitle: Text('1.0.0'),
              leading: Icon(Icons.info_outline),
            ),
            const ListTile(
              title: Text('Student'),
              subtitle: Text('Faculty of Computer Science & Engineering'),
              leading: Icon(Icons.developer_mode),
            ),
            const SizedBox(height: 25.0),
            const Text(
              'About the Application',
              style: TextStyle(
                fontSize: 22.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8.0),
            const Divider(
              color: Colors.black,
              thickness: 1.0,
            ),
            const Padding(
              padding: EdgeInsets.all(3.0),
              child: Text(
                'This social app allows users to connect with others, post where they are at, explore the content shared by their connections and discover new places.',
                style: TextStyle(
                  fontSize: 18.0,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const Spacer(),
            const Center(
              child: Text(
                'On The Spot',
                style: TextStyle(
                  fontSize: 28.0,
                  fontWeight: FontWeight.bold,
                  color: AppColors.titles,
                ),
              ),
            ),
            const SizedBox(height: 16.0),
          ],
        ),
      ),
    );
  }
}
