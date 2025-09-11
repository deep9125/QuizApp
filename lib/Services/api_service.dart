import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb; // To check platform

class ApiService {
  static String get _baseUrl {
    if (kIsWeb) {
      return 'http://localhost:3000/api';
    } else {
      // For Android Emulator. For iOS Simulator, use 'http://localhost:3000/api'
      // For physical device, use your computer's network IP: 'http://YOUR_COMPUTER_IP:3000/api'
      return 'http://10.0.2.2:3000/api';
    }
  }

  Future<List<dynamic>> fetchQuizzes() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/quizzes'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as List<dynamic>;
      } else {
        print('Failed to load quizzes: ${response.statusCode} ${response.body}');
        throw Exception('Failed to load quizzes (${response.statusCode})');
      }
    } catch (e) {
      print('Error fetching quizzes: $e');
      throw Exception('Error fetching quizzes: $e');
    }
  }

  Future<Map<String, dynamic>> createQuiz(Map<String, dynamic> quizData) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/quizzes'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(quizData),
      );
      if (response.statusCode == 201) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        print('Failed to create quiz: ${response.statusCode} ${response.body}');
        throw Exception('Failed to create quiz (${response.statusCode}): ${response.body}');
      }
    } catch (e) {
      print('Error creating quiz: $e');
      throw Exception('Error creating quiz: $e');
    }
  }

  Future<Map<String, dynamic>?> fetchQuizById(String id) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/quizzes/$id'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else if (response.statusCode == 404) {
        return null;
      } else {
        print('Failed to load quiz $id: ${response.statusCode} ${response.body}');
        throw Exception('Failed to load quiz $id (${response.statusCode})');
      }
    } catch (e) {
      print('Error fetching quiz $id: $e');
      throw Exception('Error fetching quiz $id: $e');
    }
  }
}
