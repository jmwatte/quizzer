import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as path;
import 'package:provider/provider.dart';
import 'package:quizzer/src/sample_feature/changnotifiers.dart';
import '../settings/settings_view.dart';
import 'sample_item.dart';
import 'sample_item_details_view.dart';

/// Displays a list of SampleItems.
class SampleItemListView extends StatelessWidget {
  const SampleItemListView({Key? key}) : super(key: key);
//  amethod that loads all the json files from the assets folder

  static const routeName = '/';

  Future<List<ShortcutCategory>> loadShortcuts() async {
    final items = <ShortcutCategory>[];
    // Get the asset manifest
    final manifestContent = await rootBundle.loadString('AssetManifest.json');
    final Map<String, dynamic> manifestMap = json.decode(manifestContent);

    // Get the paths of all JSON files in the assets folder
    final jsonPaths = manifestMap.keys
        .where((String key) => path.extension(key) == '.json')
        .where((String key) => key.startsWith('assets/VSCodeShortcuts/'))
        .toList();

    // Load each JSON file and convert it to a ShortcutCategory object
    for (var jsonPath in jsonPaths) {
      final jsonString = await rootBundle.loadString(jsonPath);
      final jsonData = json.decode(jsonString);

      if (jsonData is List) {
        final shortcutCategories = jsonData
            .map((item) =>
                ShortcutCategory.fromJson(item as Map<String, dynamic>))
            .toList();
        items.addAll(shortcutCategories);
      } else if (jsonData is Map) {
        final shortcutCategory =
            ShortcutCategory.fromJson(jsonData as Map<String, dynamic>);
        items.add(shortcutCategory);
      }
    }
    // Return the completed list
    return items;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ShortcutCategory>>(
      future: loadShortcuts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child:
                  CircularProgressIndicator(), // Show a loading spinner while waiting
            ),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text(
                  'Error: ${snapshot.error}'), // Show an error message if something went wrong
            ),
          );
        } else {
          final items = snapshot.data!;
          return Scaffold(
            appBar: AppBar(
              title: const Text('Shortcut categories'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.settings),
                  onPressed: () {
                    Navigator.restorablePushNamed(
                        context, SettingsView.routeName);
                  },
                ),
              ],
            ),
            body: ListView.builder(
              restorationId: 'sampleItemListView',
              itemCount: items.length,
              itemBuilder: (BuildContext context, int index) {
                final item = items[index];

                return ListTile(
                  title: Text(
                      item.category), 
                        subtitle: Text('${item.shortcuts.length} questions'), // Changed to use category from ShortcutCategory
                  leading: Container(
                    width: 40, // Set the width you want
                    height: 40, // Set the height you want
                    decoration: const BoxDecoration(
                      shape: BoxShape.rectangle,
                      image: DecorationImage(
                        image: AssetImage('assets/images/Designer.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  onTap: () {
                      Provider.of<CategoryProvider>(context, listen: false).selectCategory(item);
                    Navigator.restorablePushNamed(
                      context,
                      QuizItemDetailsView.routeName,
                    );
                  },
                );
              },
            ),
          );
        }
      },
    );
  }
}
