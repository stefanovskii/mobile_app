import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:project/Services/profiles_service.dart';

import '../../Constants/app_colors.dart';

class ArchivesScreen extends StatefulWidget {
  final User user;
  const ArchivesScreen({Key? key, required this.user}) : super(key: key);

  @override
  _ArchivesScreenState createState() => _ArchivesScreenState();
}

class _ArchivesScreenState extends State<ArchivesScreen> {
  final ProfilesService _profilesService = ProfilesService();

  Future<List<String>> _fetchArchivedLocations() async {
    return await _profilesService.fetchArchivedLocations(widget.user.uid);
  }

  Future<void> _removeArchive(String archive) async {
    try {
      await _profilesService.removeFromArchives(widget.user.uid, archive);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$archive removed from archives')),
      );
      setState(() {});
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error')),
      );
    }
  }

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
          'Archived Locations',
          style: TextStyle(color: AppColors.titles, fontSize: 28),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<List<String>>(
        future: _fetchArchivedLocations(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.archive_outlined, size: 50, color: Colors.grey),
                  SizedBox(height: 20),
                  Text('No archived locations found', style: TextStyle(fontSize: 18, color: Colors.grey)),
                ],
              ),
            );
          }

          final archives = snapshot.data!;
          return ListView.separated(
            itemCount: archives.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(archives[index]),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _removeArchive(archives[index]),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
