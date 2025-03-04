import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:myapp/constant/color.dart';
import 'package:myapp/model/personality_model.dart';
import 'package:myapp/screens/question_item.dart';
import 'package:myapp/screens/test_result_screen.dart';
import 'package:myapp/service/personality_service.dart';
import 'package:myapp/service/test_service.dart';
import 'package:myapp/widgets/custom_scaffold.dart';
import 'dart:math' as math;

import 'package:myapp/widgets/video_player.dart';

class RiasecTestScreen extends StatefulWidget {
  const RiasecTestScreen({super.key});

  @override
  State<RiasecTestScreen> createState() => _RiasecTestScreenState();
}

class _RiasecTestScreenState extends State<RiasecTestScreen> {
  int _currentCategoryIndex = 0;
  int _currentQuestionIndex = 0;
  bool _showResults = false;
  bool _isLoading = true;
  String _loadingMessage = "Memuat tes kepribadian...";

  // The RiasecTestService instance
  final RiasecTestService _testService = RiasecTestService();

  // Test data
  Map<String, List<Map<String, dynamic>>> _questions = {};
  List<PersonalityModel> _personalityTypes = [];

  // Score tracking
  final Map<String, int> _scores = {
    'R': 0, // Realistic
    'I': 0, // Investigative
    'A': 0, // Artistic
    'S': 0, // Social
    'E': 0, // Enterprising
    'C': 0, // Conventional
  };

  // Track completion per category
  final Map<String, int> _questionsCompleted = {
    'R': 0,
    'I': 0,
    'A': 0,
    'S': 0,
    'E': 0,
    'C': 0,
  };

  // Get current category code
  String get _currentCategoryCode {
    if (_personalityTypes.isEmpty ||
        _currentCategoryIndex >= _personalityTypes.length) {
      return 'R'; // Default fallback
    }
    return _personalityTypes[_currentCategoryIndex].kategori.substring(0, 1);
  }

  // Current questions for the category
  List<Map<String, dynamic>> get _currentCategoryQuestions =>
      _questions[_currentCategoryCode] ?? [];

  // Get current page questions (only 2 per page)
  List<Map<String, dynamic>> get _currentPageQuestions {
    final startIndex = _currentQuestionIndex;
    final endIndex = math.min(startIndex + 2,
        _currentCategoryQuestions.length); // 2 questions per page
    return _currentCategoryQuestions.sublist(startIndex, endIndex);
  }

  bool get _isLastQuestionPage {
    return _currentQuestionIndex >= _currentCategoryQuestions.length - 2;
  }

  @override
  void initState() {
    super.initState();
    _loadTestData();
  }

  @override
  void dispose() {
    // Clean up resources when the screen is disposed
    _resetTest();
    super.dispose();
  }

  void _resetTest() {
    // Reset the state to default values
    _currentCategoryIndex = 0;
    _currentQuestionIndex = 0;
    _showResults = false;

    // Reset all scores
    for (final key in _scores.keys) {
      _scores[key] = 0;
      _questionsCompleted[key] = 0;
    }

    // Reset all question checkboxes
    for (final categoryKey in _questions.keys) {
      for (int i = 0; i < _questions[categoryKey]!.length; i++) {
        _questions[categoryKey]![i]['isChecked'] = false;
      }
    }

    // Make sure to stop any playing videos
    VideoControllerManager().pauseAll();
    VideoControllerManager().disposeAll();
  }

  // Load the test data from the service
  Future<void> _loadTestData() async {
    setState(() {
      _isLoading = true;
      _loadingMessage = "Mempersiapkan tes RIASEC...";
    });

    try {
      // Initialize the test service
      await _testService.initialize();

      setState(() {
        _loadingMessage = "Memuat pertanyaan tes...";
      });

      // Get the questions and personality types
      _questions = _testService.getAllQuestions();
      _personalityTypes = _testService.personalityTypes;

      // If we don't have personality types loaded, get them one by one
      if (_personalityTypes.isEmpty) {
        setState(() {
          _loadingMessage = "Memuat tipe kepribadian...";
        });

        final List<String> typeNames = [
          'Realistic',
          'Investigative',
          'Artistic',
          'Social',
          'Enterprising',
          'Conventional'
        ];

        for (String typeName in typeNames) {
          final typeData =
              await PersonalityService.getPersonalityByCategory(typeName);
          if (typeData != null) {
            _personalityTypes.add(typeData);
          }
        }
      }

      // Make sure we have at least some questions loaded
      if (_questions.isEmpty) {
        setState(() {
          _loadingMessage =
              "Tidak ada pertanyaan yang tersedia. Silakan coba lagi nanti.";
        });
        return;
      }

      // Initialize scores and completion counters for all categories
      for (var code in _scores.keys) {
        _scores[code] = 0;
        _questionsCompleted[code] = 0;
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _loadingMessage = "Terjadi kesalahan saat memuat tes: $e";
      });
      debugPrint("Error loading test data: $e");
    }
  }

  void _nextPage() {
    print("Navigating to next page - pausing all videos");
    // Only pause videos, don't dispose them
    VideoControllerManager().pauseAll();

    // Mark all videos in current view as needing reset
    _resetCurrentPageVideos();

    if (_isLastQuestionPage) {
      _nextCategory();
    } else {
      setState(() {
        _currentQuestionIndex += 2;
      });
    }
  }

  void _previousPage() {
    print("Navigating to previous page - pausing all videos");
    // Only pause videos, don't dispose them
    VideoControllerManager().pauseAll();

    // Mark all videos in current view as needing reset
    _resetCurrentPageVideos();

    if (_currentQuestionIndex > 0) {
      setState(() {
        _currentQuestionIndex = math.max(0, _currentQuestionIndex - 2);
      });
    } else if (_currentCategoryIndex > 0) {
      _previousCategory();
    }
  }

// Helper method to reset videos on current page
  void _resetCurrentPageVideos() {
    // We'll notify question items that they need to reset their video state
    // This is handled by adding a new field to track when navigation happens
    _navigationCounter++;
  }

// Add this field to the class variables section at the top of the class
  int _navigationCounter = 0;
  void _nextCategory() {
    // Pause all videos when changing categories
    VideoControllerManager().pauseAll();

    if (_currentCategoryIndex < _personalityTypes.length - 1) {
      setState(() {
        _currentCategoryIndex++;
        _currentQuestionIndex = 0; // Reset to first question in new category
      });
    } else {
      // Navigate to the separate results screen instead of showing results inline
      // This avoids issues with state management when navigating back
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => RiasecResultsScreen(
            scores: Map.from(_scores),
            personalityTypes: _personalityTypes,
          ),
        ),
      );

      // Make sure we dispose video controllers, etc.
      VideoControllerManager().pauseAll();
      VideoControllerManager().disposeAll();
    }
  }

  void _previousCategory() {
    // Pause all videos when changing categories
    VideoControllerManager().pauseAll();

    if (_currentCategoryIndex > 0) {
      setState(() {
        _currentCategoryIndex--;
        // Set to last page of questions in the previous category
        final prevCategoryCode =
            _personalityTypes[_currentCategoryIndex].kategori.substring(0, 1);
        final questionsInPrevCategory =
            _questions[prevCategoryCode]?.length ?? 0;
        // Make sure we never try to access a negative index
        _currentQuestionIndex = questionsInPrevCategory > 0
            ? math.max(0, ((questionsInPrevCategory - 1) ~/ 2) * 2)
            : 0;
      });
    }
  }

  void _toggleQuestion(int absoluteIndex) {
    final categoryCode = _currentCategoryCode;
    if (_questions[categoryCode] == null ||
        absoluteIndex >= _questions[categoryCode]!.length) {
      return;
    }

    final isCurrentlyChecked =
        _questions[categoryCode]![absoluteIndex]['isChecked'];

    setState(() {
      _questions[categoryCode]![absoluteIndex]['isChecked'] =
          !isCurrentlyChecked;

      // Update score
      if (!isCurrentlyChecked) {
        _scores[categoryCode] = (_scores[categoryCode] ?? 0) + 1;
        _questionsCompleted[categoryCode] =
            (_questionsCompleted[categoryCode] ?? 0) + 1;
      } else {
        _scores[categoryCode] = (_scores[categoryCode] ?? 0) - 1;
        _questionsCompleted[categoryCode] =
            (_questionsCompleted[categoryCode] ?? 0) - 1;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: greenBorders,
        title: const Text(
          'Tes Kepribadian RIASEC',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            // Show confirmation dialog if test is in progress
            if (!_showResults &&
                _questionsCompleted.values.any((count) => count > 0)) {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Keluar dari Tes?'),
                  content: const Text(
                      'Kemajuan tes Anda tidak akan disimpan. Apakah Anda yakin ingin keluar?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context), // Close dialog
                      child: const Text('Tidak'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context); // Close dialog
                        _resetTest();
                        Navigator.pop(context); // Go back
                      },
                      style:
                          ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      child: const Text('Keluar',
                          style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              );
            } else {
              _resetTest();
              Navigator.pop(context);
            }
          },
        ),
      ),
      child: _isLoading ? _buildLoadingScreen() : _buildTestScreen(),
    );
  }

  Widget _buildLoadingScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: greenBorders),
          const Gap(16),
          Text(
            _loadingMessage,
            style: const TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTestScreen() {
    if (_personalityTypes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.warning_amber_rounded,
                size: 48, color: Colors.amber),
            const Gap(16),
            const Text(
              'Tidak dapat memuat data kepribadian RIASEC',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const Gap(24),
            ElevatedButton(
              onPressed: _loadTestData,
              style: ElevatedButton.styleFrom(
                backgroundColor: greenBorders,
                foregroundColor: Colors.white,
              ),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    // Get current personality type
    final currentType = _personalityTypes[_currentCategoryIndex];
    final currentCode = currentType.kategori.substring(0, 1);
    final Color categoryColor =
        PersonalityModel.getTypeColor(currentType.kategori);

    return Column(
      children: [
        // Category header
        Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: categoryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: categoryColor.withOpacity(0.5)),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(
                    _testService.getCategoryIcon(currentCode),
                    color: categoryColor,
                    size: 32,
                  ),
                  const Gap(12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          currentType.kategori,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Questions for current page
        Expanded(
          child: _currentPageQuestions.isEmpty
              ? Center(
                  child: Text(
                    'Tidak ada pertanyaan untuk kategori ${currentType.kategori}',
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      const Text(
                        'Pilih pernyataan yang sesuai dengan diri anda',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const Gap(16),
                      ..._currentPageQuestions.asMap().entries.map((entry) {
                        final int pageIndex = entry.key;
                        final int absoluteIndex =
                            _currentQuestionIndex + pageIndex;
                        final question = entry.value;

                        return QuestionItem(
                          question: question,
                          index: absoluteIndex,
                          categoryColor: categoryColor,
                          onToggle: _toggleQuestion,
                          currentCategory: currentType.kategori,
                          navigationCounter: _navigationCounter,
                        );
                      }),
                    ],
                  ),
                ),
        ),

        // Navigation buttons
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Back button
              _currentQuestionIndex > 0 || _currentCategoryIndex > 0
                  ? TextButton.icon(
                      onPressed: _previousPage,
                      icon: const Icon(Icons.arrow_back_rounded),
                      label: const Text('Kembali'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.grey.shade700,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                    )
                  : const SizedBox(width: 100),

              // Next button
              ElevatedButton.icon(
                onPressed: _nextPage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: greenBorders,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: _isLastQuestionPage &&
                        _currentCategoryIndex == _personalityTypes.length - 1
                    ? const Icon(Icons.check_circle, color: Colors.white)
                    : const Icon(Icons.arrow_forward_rounded,
                        color: Colors.white),
                label: Text(
                  _isLastQuestionPage &&
                          _currentCategoryIndex == _personalityTypes.length - 1
                      ? 'Lihat Hasil'
                      : _isLastQuestionPage
                          ? 'Kategori Berikutnya'
                          : 'Lanjut',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
