import 'package:flutter/material.dart';
import 'package:myapp/model/personality_model.dart';
import 'package:myapp/service/personality_service.dart';
import 'package:myapp/service/sheet_service.dart';

class RiasecTestService {
  // Singleton instance
  static final RiasecTestService _instance = RiasecTestService._internal();
  factory RiasecTestService() => _instance;
  RiasecTestService._internal();

  // Cache for loaded questions to avoid multiple fetches
  Map<String, List<Map<String, dynamic>>> _questionCache = {};
  List<PersonalityModel> _personalityTypesCache = [];
  bool _isInitialized = false;

  // Check if the service is initialized
  bool get isInitialized => _isInitialized;

  // Get all personality types
  List<PersonalityModel> get personalityTypes => _personalityTypesCache;

  // Initialize the service by fetching data from the sheet
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Make sure SheetService is initialized
      if (SheetService.kepribadianRekomSheet == null) {
        await SheetService.init();
        if (SheetService.kepribadianRekomSheet == null) {
          debugPrint(
              "Could not initialize RiasecTestService - Sheet not available");
          return;
        }
      }

      // Load all personality types via PersonalityService
      await _loadPersonalityTypes();

      // Load the questions from the Google Sheet
      await _loadQuestionsFromSheet();

      _isInitialized = true;
      debugPrint(
          "RiasecTestService initialized successfully with ${_questionCache.length} categories");
    } catch (e) {
      debugPrint("Error initializing RiasecTestService: $e");
    }
  }

  // Load all RIASEC personality types
  Future<void> _loadPersonalityTypes() async {
    try {
      final List<String> typeNames = [
        'Realistic',
        'Investigative',
        'Artistic',
        'Social',
        'Enterprising',
        'Conventional'
      ];

      List<PersonalityModel> types = [];

      for (String typeName in typeNames) {
        final typeData =
            await PersonalityService.getPersonalityByCategory(typeName);
        if (typeData != null) {
          types.add(typeData);
        }
      }

      _personalityTypesCache = types;
      debugPrint("Loaded ${_personalityTypesCache.length} personality types");
    } catch (e) {
      debugPrint("Error loading personality types: $e");
    }
  }

  // Load questions from the Test Riasec sheet
  Future<void> _loadQuestionsFromSheet() async {
    try {
      final rows = await SheetService.kepribadianRekomSheet!.values.allRows();

      // Skip the header row
      if (rows.isEmpty || rows.length <= 1) {
        debugPrint("No data found in Test Riasec sheet");
        return;
      }

      // Determine column indices
      int idColumn = 0;
      int categoryColumn = 1;
      int questionColumn = 2;
      int videoUrlColumn = 3;

      // Clear existing cache
      _questionCache.clear();

      // Process rows and organize by category
      for (int i = 1; i < rows.length; i++) {
        if (rows[i].length <= categoryColumn) continue;

        final row = rows[i];
        final id = row.isNotEmpty && row.length > idColumn
            ? row[idColumn]
            : i.toString();
        final category = row.length > categoryColumn ? row[categoryColumn] : "";

        // Skip empty categories
        if (category.isEmpty) continue;

        // Normalize category name to get code
        final categoryCode = _getCategoryCode(category);

        // Create question data
        final Map<String, dynamic> questionData = {
          'id': id,
          'category': category,
          'text': row.length > questionColumn ? row[questionColumn] : "",
          'videoUrl': row.length > videoUrlColumn ? row[videoUrlColumn] : "",
          'isChecked': false,
        };

        // Add to the appropriate category
        if (!_questionCache.containsKey(categoryCode)) {
          _questionCache[categoryCode] = [];
        }

        _questionCache[categoryCode]!.add(questionData);
      }

      debugPrint(
          "Loaded questions for categories: ${_questionCache.keys.join(", ")}");
      for (var key in _questionCache.keys) {
        debugPrint(
            "Category $key has ${_questionCache[key]?.length} questions");
      }
    } catch (e) {
      debugPrint("Error loading questions from sheet: $e");
    }
  }

  // Get category code from category name
  String _getCategoryCode(String category) {
    if (category.isEmpty) return "";

    // Check if it's already a single letter code
    if (category.length == 1 && 'RIASEC'.contains(category.toUpperCase())) {
      return category.toUpperCase();
    }

    // Otherwise try to match with known categories
    final normalizedCategory = category.toLowerCase().trim();

    if (normalizedCategory.contains('realistic')) return 'R';
    if (normalizedCategory.contains('investigative')) return 'I';
    if (normalizedCategory.contains('artistic')) return 'A';
    if (normalizedCategory.contains('social')) return 'S';
    if (normalizedCategory.contains('enterprising')) return 'E';
    if (normalizedCategory.contains('conventional')) return 'C';

    // If not found, return first letter
    return category.substring(0, 1).toUpperCase();
  }

  // Get questions for a specific category code
  List<Map<String, dynamic>> getQuestionsForCategory(String categoryCode) {
    if (!_isInitialized) {
      debugPrint(
          "Warning: RiasecTestService not initialized when getting questions");
    }

    return _questionCache[categoryCode] ?? [];
  }

  // Get all RIASEC questions
  Map<String, List<Map<String, dynamic>>> getAllQuestions() {
    if (!_isInitialized) {
      debugPrint(
          "Warning: RiasecTestService not initialized when getting all questions");
    }

    return _questionCache;
  }

  // Reset all test data
  void resetTest() {
    for (final key in _questionCache.keys) {
      for (int i = 0; i < _questionCache[key]!.length; i++) {
        _questionCache[key]![i]['isChecked'] = false;
      }
    }
  }

  // Get personality type data by code
  PersonalityModel? getPersonalityByCode(String code) {
    for (var type in _personalityTypesCache) {
      if (type.kategori.substring(0, 1).toUpperCase() == code.toUpperCase()) {
        return type;
      }
    }
    return null;
  }

  // Get full category name from code
  String getCategoryFullName(String code) {
    final personalityType = getPersonalityByCode(code);
    if (personalityType != null) {
      return personalityType.kategori;
    }

    // Fallback to static mapping
    switch (code) {
      case 'R':
        return 'Realistic';
      case 'I':
        return 'Investigative';
      case 'A':
        return 'Artistic';
      case 'S':
        return 'Social';
      case 'E':
        return 'Enterprising';
      case 'C':
        return 'Conventional';
      default:
        return code;
    }
  }

  // Get category color from code
  Color getCategoryColor(String code) {
    final personalityType = getPersonalityByCode(code);
    if (personalityType != null) {
      return PersonalityModel.getTypeColor(personalityType.kategori);
    }

    // Fallback colors
    switch (code) {
      case 'R':
        return Colors.blue;
      case 'I':
        return Colors.purple;
      case 'A':
        return Colors.orange;
      case 'S':
        return Colors.green;
      case 'E':
        return Colors.red;
      case 'C':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  // Get category icon from code
  IconData getCategoryIcon(String code) {
    switch (code) {
      case 'R':
        return Icons.handyman;
      case 'I':
        return Icons.psychology;
      case 'A':
        return Icons.palette;
      case 'S':
        return Icons.people;
      case 'E':
        return Icons.business_center;
      case 'C':
        return Icons.table_chart;
      default:
        return Icons.help_outline;
    }
  }

  // Get recommended career paths for a category
  String getRecommendedCareerPath(String code) {
    final personalityType = getPersonalityByCode(code);
    if (personalityType != null && personalityType.characteristic.isNotEmpty) {
      // Here you could retrieve recommended careers from the personality type data
      // For now we'll stick with the static mapping
    }

    // Fallback career paths
    switch (code) {
      case 'R':
        return 'Kriya Kayu, Elektronika, Pertukangan';
      case 'I':
        return 'Ilmu Pengetahuan, Komputer, Matematika';
      case 'A':
        return 'Seni Rupa, Musik, Tari';
      case 'S':
        return 'Layanan Sosial, Pendidikan';
      case 'E':
        return 'Kewirausahaan, Pemasaran';
      case 'C':
        return 'Administrasi, Pembukuan, Pengarsipan';
      default:
        return '';
    }
  }

  // Get description for a category
  String getCategoryDescription(String code) {
    final personalityType = getPersonalityByCode(code);
    if (personalityType != null && personalityType.deskripsi.isNotEmpty) {
      return personalityType.deskripsi;
    }

    // Fallback descriptions
    switch (code) {
      case 'R':
        return 'Praktis, menyukai pekerjaan dengan alat dan mesin';
      case 'I':
        return 'Analitis, suka memecahkan masalah dan berpikir logis';
      case 'A':
        return 'Kreatif, suka mengekspresikan diri dan berimajinasi';
      case 'S':
        return 'Suka membantu dan bekerja dengan orang lain';
      case 'E':
        return 'Persuasif, suka memimpin dan mempengaruhi orang lain';
      case 'C':
        return 'Rapi, suka mengatur dan bekerja dengan data';
      default:
        return '';
    }
  }
}
