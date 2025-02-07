import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
// import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:walpaper_app_api/api/storage_permisson.dart';
import 'package:walpaper_app_api/api/unplash_api.dart';
import 'package:walpaper_app_api/utils/keyboard_manager.dart';

import 'constants/appconstants.dart';
import 'model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String querry = '';
  TextEditingController controller = TextEditingController();

  void _showdialog(String ImageUrl) {
    showDialog(
      context: context,
      barrierDismissible: true,
      // barrierDismissible: barrierDismissible,
      // false = user must tap button, true = tap outside dialog
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Container(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.network(ImageUrl, fit: BoxFit.cover),
            ),
          ),
          content: Text('GetWall'),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.blue, fontSize: 15),
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Dismiss alert dialog
              },
            ),
            TextButton(
              child: Text(
                'Downlaod',
                style: TextStyle(color: Colors.blue, fontSize: 20),
              ),
              onPressed: () async {
                bool haspermission =
                    await AppPermission.requestStoragePermission();
                if (haspermission) {
                  // Dismiss alert dialog
                  await AppPermission.downloadImage(ImageUrl, 'image');
                } else {
                  print('Storage permission denied');
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // requestPermissions();
    req();
  }
  Future<void> req ()async{
    await Permission.storage.request();
    await Permission.manageExternalStorage.request();
    await Permission.photos.request();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.blue),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: controller,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.all(20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),

                  onPressed: () {
                    KeyboardManager.keyboarmanager(context);
                    setState(() {
                      querry = controller.text.trim();
                    });
                  },
                  child: Icon(Icons.send, color: Colors.white),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<ImageData>>(
              future: MyApiData.fetchImages(querry),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.connectionState == ConnectionState.none) {
                  return Center(child: Text('Search Images'));
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('Search Images'));
                }

                final images = snapshot.data!;

                return MasonryGridView.builder(
                  gridDelegate: SliverSimpleGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                  ),
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(5),
                      child: GestureDetector(
                        onLongPress: () {
                          _showdialog(images[index].imageUrl);
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Image.network(images[index].imageUrl),
                        ),
                      ),
                    );
                  },
                  itemCount: images.length,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ImageGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: MasonryGridView.builder(
        gridDelegate: SliverSimpleGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // Number of columns
        ),
        itemCount: imageUrls.length,
        itemBuilder: (context, index) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(15), // Rounded corners
            child: Image.network(imageUrls[index], fit: BoxFit.cover),
          );
        },
      ),
    );
  }
}
