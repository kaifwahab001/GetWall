import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:walpaper_app_api/constants/appconstants.dart';
import 'package:http/http.dart' as http;
import 'package:walpaper_app_api/model.dart';

class MyApiData {
  static Future<List<ImageData>>  fetchImages(String querry) async {
      final response = await http.get(
        Uri.parse(
          'https://api.unsplash.com/search/photos?query=${querry}&client_id=${myAccessKey}&page=1&per_page=20',
        ),
        headers: {
          'Authorization': 'Client-ID ${myAccessKey}',
          'Content-Type': 'application/json',
        }
      );
      if(response.statusCode==200){
        final List<dynamic> jsonData = jsonDecode( response.body)['results'];
        return jsonData.map((json)=>ImageData.fromJson(json)).toList();
      }else {
        return [];
      }
  }
}
