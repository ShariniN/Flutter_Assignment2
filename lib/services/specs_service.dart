import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';

class TechSpecsService {
  final Dio _dio = Dio();
  final String apiUrl = "https://phone-specs-api.vercel.app/latest";

  // Get local file path
  Future<File> _getLocalFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/offline_specs.json');
  }

  Future<List<Map<String, dynamic>>> fetchTechData({bool offlineFallback = true}) async {
    try {
      final response = await _dio.get(apiUrl);
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['status'] == true && data['data'] != null && data['data']['phones'] != null) {
          final List<Map<String, dynamic>> phoneList =
              (data['data']['phones'] as List<dynamic>).cast<Map<String, dynamic>>();

          // Save to local JSON
          await _saveToLocalFile(data['data']);
          return phoneList;
        }
        throw Exception('Unexpected API response structure');
      }
      throw Exception('Invalid response from server');
    } catch (e) {
      print('⚠️ Using offline data due to: $e');

      if (offlineFallback) {
        try {
          // Try local JSON file first
          final file = await _getLocalFile();
          if (await file.exists()) {
            final jsonData = json.decode(await file.readAsString());
            if (jsonData['phones'] != null) {
              return List<Map<String, dynamic>>.from(jsonData['phones']);
            }
          }

          // Fallback to bundled asset
          final localJson = await rootBundle.loadString('assets/offline_specs.json');
          final jsonData = json.decode(localJson);
          if (jsonData['phones'] != null) {
            return List<Map<String, dynamic>>.from(jsonData['phones']);
          }
        } catch (jsonError) {
          print('Error loading offline JSON: $jsonError');
        }
      }

      return [];
    }
  }

  Future<Map<String, dynamic>> fetchPhoneSpecs(String phoneSlug) async {
    try {
      final response = await _dio.get('https://phone-specs-api.vercel.app/$phoneSlug');
      if (response.statusCode == 200 && response.data['status'] == true) {
        return response.data['data'];
      }
      throw Exception('Invalid phone specs response');
    } catch (e) {
      print('Error fetching phone specs: $e');
      return {};
    }
  }

  Future<void> _saveToLocalFile(Map<String, dynamic> data) async {
    try {
      final file = await _getLocalFile();
      await file.writeAsString(json.encode(data), flush: true);
    } catch (e) {
      print('⚠️ Failed to save offline JSON: $e');
    }
  }
}
