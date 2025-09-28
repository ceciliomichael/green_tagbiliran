import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:developer' as developer;

class GeminiAiService {
  static final GeminiAiService _instance = GeminiAiService._internal();
  factory GeminiAiService() => _instance;
  GeminiAiService._internal();

  late String _apiUrl;
  late String _apiKey;
  late String _model;

  /// Initialize the service with environment variables
  Future<void> initialize() async {
    await dotenv.load(fileName: '.env');

    _apiUrl = dotenv.env['GOOGLE_API_URL'] ?? '';
    _apiKey = dotenv.env['GOOGLE_API_KEY'] ?? '';
    _model = dotenv.env['GOOGLE_MODEL'] ?? 'gemini-flash-lite-latest';

    if (_apiUrl.isEmpty || _apiKey.isEmpty) {
      throw Exception('Gemini API configuration not found in .env file');
    }
  }

  /// Send a message to GreenTea Bot and get response
  Future<String> sendMessage(
    String message,
    List<ChatMessage> chatHistory, {
    String? userBarangay,
    String? userName,
  }) async {
    try {
      // Prepare messages for API
      final messages = <Map<String, dynamic>>[];

      // Add system message with current time context and user info
      final now = DateTime.now();
      final currentDate = "${now.day}/${now.month}/${now.year}";
      final currentTime =
          "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";
      final dayOfWeek = [
        'Monday',
        'Tuesday',
        'Wednesday',
        'Thursday',
        'Friday',
        'Saturday',
        'Sunday',
      ][now.weekday - 1];

      // Get user's collection schedule based on barangay
      final userSchedule = _getUserCollectionSchedule(userBarangay);
      final nextCollectionInfo = _getNextCollectionInfo(userBarangay, now);

      messages.add({
        'role': 'system',
        'content':
            '''You are **GreenTea Bot** 🌱, the dedicated AI assistant for the Green Tagbilaran waste management app in Tagbilaran City, Bohol.

**CURRENT TIME CONTEXT:**
- **Today is**: $dayOfWeek, $currentDate
- **Current time**: $currentTime (Philippine Time)
- **Time zone**: Asia/Manila (UTC+8)

**USER CONTEXT:**
- **User name**: ${userName ?? 'User'}
- **User's barangay**: ${userBarangay ?? 'Unknown'}
- **User's collection days**: ${userSchedule['days'] ?? 'Not available'}
- **User's collection time**: ${userSchedule['time'] ?? 'Not available'}
- **Next collection**: ${nextCollectionInfo['next'] ?? 'Unknown'}
- **Days until next collection**: ${nextCollectionInfo['daysUntil'] ?? 'Unknown'}

**COMPLETE GARBAGE COLLECTION SCHEDULES FOR Tagbilaran CITY:**

**Morning Collections (6:00 AM - 10:00 AM):**
• **Monday & Friday**: Booy, Dampas, Dao, Mansasa, Taloto, Cogon Proper
• **Tuesday & Saturday**: Bool, Cabawan, Manga, San Isidro, Tiptip, Ubujan

**Evening Collections (6:00 PM - 10:00 PM):**  
• **Monday, Wednesday & Friday**: Poblacion 1, Poblacion 2, Poblacion 3, Centro

**Bi-Weekly Collections:**
• **Alternating Tuesdays**: Lindaville Phase 1 & 2, Dampas Extension
• **Alternating Saturdays**: Booy Extension, Mansasa Extension

Use this contextual information to:
- Address the user by name when appropriate
- Provide specific collection information for their barangay
- Calculate exact days until their next collection
- Give personalized scheduling advice
- Determine if TODAY is their collection day
- Provide time-sensitive reminders specific to their schedule

**YOUR CORE IDENTITY:**
- You are **ONLY** focused on being GreenTea Bot - this is your primary and sole identity
- You assist users specifically with the Green Tagbilaran app and its features
- You help with waste management topics relevant to Tagbilaran City
- You provide guidance on app navigation and functionality

**WHAT YOU HELP WITH:**
- **App navigation** and feature explanations
- **Waste collection schedules** for Tagbilaran City barangays
- **Reporting issues** through the app
- **User account** and profile management
- **Notifications** and alerts
- **General waste management** guidance for the city

**WHAT YOU DON'T DO:**
- Don't focus primarily on recycling or detailed environmental topics
- Don't provide general life advice unrelated to waste management
- Don't discuss topics outside of your GreenTea Bot identity

**MARKDOWN FORMATTING REQUIREMENTS:**
- **ALWAYS** use markdown formatting in your responses
- Use **bold** for important terms, app features, and key points
- Use *italics* for emphasis and tips
- Use `code formatting` for button names, menu items, and app actions
- Use bullet points (•) for lists and options
- Use numbered lists (1. 2. 3.) for step-by-step instructions
- Use ### for section headers when organizing information
- Use > for important notices or pro tips

**TONE:**
Be friendly, helpful, and professional. Keep responses concise but informative. Always maintain your identity as GreenTea Bot for the Green Tagbilaran app.''',
      });

      // Add chat history
      for (final chatMessage in chatHistory) {
        messages.add({
          'role': chatMessage.isUser ? 'user' : 'assistant',
          'content': chatMessage.message,
        });
      }

      // Add current message
      messages.add({'role': 'user', 'content': message});

      final requestBody = {
        'model': _model,
        'messages': messages,
        'max_tokens': 500,
        'temperature': 0.7,
      };

      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final content = responseData['choices']?[0]?['message']?['content'];

        if (content != null && content.toString().trim().isNotEmpty) {
          return content.toString().trim();
        } else {
          return 'I apologize, but I couldn\'t generate a response. Please try asking your question again.';
        }
      } else {
        developer.log(
          'Gemini API Error: ${response.statusCode} - ${response.body}',
          name: 'GeminiAiService',
        );
        return 'I\'m having trouble connecting right now. Please check your internet connection and try again.';
      }
    } on SocketException {
      return 'No internet connection. Please check your network and try again.';
    } on FormatException {
      return 'I received an unexpected response. Please try again.';
    } catch (e) {
      developer.log('GeminiAiService Error: $e', name: 'GeminiAiService');
      return 'Something went wrong. Please try again later.';
    }
  }

  /// Get user's collection schedule based on barangay
  Map<String, String> _getUserCollectionSchedule(String? barangay) {
    if (barangay == null) return {'days': 'Unknown', 'time': 'Unknown'};

    final barangayLower = barangay.toLowerCase();

    // Morning collections (6:00 AM - 10:00 AM)
    if ([
      'booy',
      'dampas',
      'dao',
      'mansasa',
      'taloto',
      'cogon proper',
    ].contains(barangayLower)) {
      return {'days': 'Monday & Friday', 'time': '6:00 AM - 10:00 AM'};
    }

    if ([
      'bool',
      'cabawan',
      'manga',
      'san isidro',
      'tiptip',
      'ubujan',
    ].contains(barangayLower)) {
      return {'days': 'Tuesday & Saturday', 'time': '6:00 AM - 10:00 AM'};
    }

    // Evening collections (6:00 PM - 10:00 PM)
    if ([
      'poblacion 1',
      'poblacion 2',
      'poblacion 3',
      'centro',
    ].contains(barangayLower)) {
      return {
        'days': 'Monday, Wednesday & Friday',
        'time': '6:00 PM - 10:00 PM',
      };
    }

    // Bi-weekly collections
    if ([
      'lindaville phase 1',
      'lindaville phase 2',
      'dampas extension',
    ].contains(barangayLower)) {
      return {'days': 'Alternating Tuesdays', 'time': '6:00 AM - 10:00 AM'};
    }

    if (['booy extension', 'mansasa extension'].contains(barangayLower)) {
      return {'days': 'Alternating Saturdays', 'time': '6:00 AM - 10:00 AM'};
    }

    return {'days': 'Schedule not available', 'time': 'Contact support'};
  }

  /// Get next collection information
  Map<String, String> _getNextCollectionInfo(String? barangay, DateTime now) {
    if (barangay == null) return {'next': 'Unknown', 'daysUntil': 'Unknown'};

    final barangayLower = barangay.toLowerCase();
    final currentWeekday = now.weekday; // 1 = Monday, 7 = Sunday

    List<int> collectionDays = [];

    // Determine collection days based on barangay
    if ([
      'booy',
      'dampas',
      'dao',
      'mansasa',
      'taloto',
      'cogon proper',
    ].contains(barangayLower)) {
      collectionDays = [1, 5]; // Monday & Friday
    } else if ([
      'bool',
      'cabawan',
      'manga',
      'san isidro',
      'tiptip',
      'ubujan',
    ].contains(barangayLower)) {
      collectionDays = [2, 6]; // Tuesday & Saturday
    } else if ([
      'poblacion 1',
      'poblacion 2',
      'poblacion 3',
      'centro',
    ].contains(barangayLower)) {
      collectionDays = [1, 3, 5]; // Monday, Wednesday & Friday
    } else if ([
      'lindaville phase 1',
      'lindaville phase 2',
      'dampas extension',
    ].contains(barangayLower)) {
      collectionDays = [2]; // Tuesdays (alternating)
    } else if ([
      'booy extension',
      'mansasa extension',
    ].contains(barangayLower)) {
      collectionDays = [6]; // Saturdays (alternating)
    }

    if (collectionDays.isEmpty) {
      return {'next': 'Schedule not available', 'daysUntil': 'Unknown'};
    }

    // Find next collection day
    int? nextCollectionDay;
    int daysUntil = 8; // Max days to check

    for (int day in collectionDays) {
      int diff = day - currentWeekday;
      if (diff < 0) diff += 7; // Next week if past
      if (diff == 0) {
        // Today is collection day
        return {'next': 'Today!', 'daysUntil': '0'};
      }
      if (diff < daysUntil) {
        daysUntil = diff;
        nextCollectionDay = day;
      }
    }

    if (nextCollectionDay == null) {
      return {'next': 'Unknown', 'daysUntil': 'Unknown'};
    }

    final dayNames = [
      '',
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    final nextDayName = dayNames[nextCollectionDay];

    if (daysUntil == 1) {
      return {'next': 'Tomorrow ($nextDayName)', 'daysUntil': '1'};
    } else {
      return {'next': nextDayName, 'daysUntil': daysUntil.toString()};
    }
  }

  /// Get a quick tip about waste management
  Future<String> getWasteTip() async {
    const tipPrompts = [
      'Give me a quick waste management tip for households',
      'Share an eco-friendly recycling tip',
      'What\'s a simple way to reduce waste at home?',
      'Give me a composting tip for beginners',
      'How can I reduce plastic waste in my daily life?',
    ];

    final randomPrompt =
        tipPrompts[DateTime.now().millisecond % tipPrompts.length];
    return await sendMessage(randomPrompt, []);
  }
}

/// Chat message model for conversation history
class ChatMessage {
  final String message;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.message,
    required this.isUser,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'message': message,
    'isUser': isUser,
    'timestamp': timestamp.toIso8601String(),
  };

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
    message: json['message'] ?? '',
    isUser: json['isUser'] ?? false,
    timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
  );
}
