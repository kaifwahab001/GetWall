import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:gallery_saver_updated/gallery_saver.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';

class AppPermission {


  /// using http
  static Future<void> dowonlaod(String ImageUrl) async {
    try {
      var status = await Permission.storage.request();
      var mediafile = await Permission.photos.request();
      var storgerpermission = await Permission.manageExternalStorage.request();
      if (status.isDenied || mediafile.isDenied || storgerpermission.isDenied) {
        Get.snackbar('Permission Denied', 'Please give Storage permission');
        return;
      }
      Directory? directory = await getExternalStorageDirectory();
      if (directory == null) {
        Get.snackbar('Please give direcory', 'failed to get storage directory');
        await getExternalStorageDirectory();
        return;
      }
      // file path
      String fileName = ImageUrl.split('/').last;
      String filepath = '${directory.path}/$fileName';

      var response = await http.get(Uri.parse(ImageUrl));
      if (response.statusCode == 200) {
        File file = File(filepath);
        await file.writeAsBytes(response.bodyBytes);
        Get.snackbar('Successful', 'Downloaded file at ${filepath} location');
      }
    } catch (e) {
      print('Error in downloading ${e.toString()}');
    }
  }

  /// using dio
  static Future<void> downloadFile(String imageUrl) async {
    try {
      // Request storage permissions (for Android 13+)
      var storageStatus = await Permission.storage.request();
      var mediaStatus = await Permission.photos.request();
      var storgerpermission =
          await Permission.manageExternalStorage
              .request(); // Request media permissions for images

      // If permissions are denied, show a snackbar and return
      if (Platform.isAndroid) {
        if (storageStatus.isDenied || mediaStatus.isDenied ||!await Permission.manageExternalStorage.isGranted) {
          Get.snackbar('Permission Denied', 'Please grant storage permission');
          await Permission.manageExternalStorage.request();
          storageStatus;
          mediaStatus;
          storgerpermission;
          return;
        }
        else{
          Directory? directory = Directory(
            '/storage/emulated/0/Download/Wallpaper',
          );
          if (!await directory.exists()) {
            await directory.create(
              recursive: true,
            ); // Create the directory if it doesn't exist
          }

          // Sanitize file name (handle any URL query parameters)
          String fileName = imageUrl.split('/').last.split('?').first;
          String filePath = '${directory.path}/$fileName.jpeg';

          // Create a Dio instance to download the file
          Dio dio = Dio();

          // Download the file
          final response = await dio.download(imageUrl, filePath);

          // for galarry save
          await GallerySaver.saveImage(filePath);

          if (response.statusCode == 200) {
            Get.snackbar(
              'Successful',
              'File downloaded at $filePath',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: CupertinoColors.systemBlue,
              colorText: CupertinoColors.white,
            );
          } else {
            Get.snackbar('Not Successful', 'File not downloaded at $filePath');
          }

        }
      }

      // Request MANAGE_EXTERNAL_STORAGE permission for broader access (Android 10+)

      // Get the Download directory path (specific to Android)

      print('File downloaded to your phone');
    } catch (e) {
      print('Error downloading file: $e');
      Get.snackbar('Error', 'Error downloading file: $e');
    }
  }


  // ... for permission
  static  Future<bool> requestStoragePermission() async {
    if (await Permission.storage.request().isGranted || await Permission.photos.isGranted || await Permission.manageExternalStorage.isGranted) {
      return true;
    } else {
      return false;
    }
  }


/// new method
 static  Future<void> downloadImage(String url, String fileName) async {
    try {

      Dio dio = Dio();
      Directory? directory = Directory('/storage/emulated/0/Pictures/GetWall');
      // Use getApplicationDocumentsDirectory() for app-specific storage
      if(!await directory.exists()){
        directory.create(
          recursive: true
        );
      }
      String filename  = url.split('/').last.split('?').first;
      String savePath = '${directory?.path}/$filename.jpg';
      EasyLoading.show(status: 'Loading');
      await dio.download(
        url,
        savePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            print('Download progress: ${(received / total * 100).toStringAsFixed(0)}%');
          }
        },
      );
      // await GallerySaver.saveImage(savePath);/// we can only use one
      EasyLoading.dismiss();
    Get.snackbar('Successfull', 'Image downlaoded');
      print('Image downloaded and saved to $savePath');
    } catch (e) {
      EasyLoading.dismiss();
      print('Error downloading image: $e');
    }
  }



}
