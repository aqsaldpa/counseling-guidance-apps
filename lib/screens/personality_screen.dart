import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:myapp/constant/color.dart';
import 'package:myapp/model/job_recommend.dart';
import 'package:myapp/model/personality_model.dart';
import 'package:myapp/model/user_model.dart';
import 'package:myapp/routes/routes_name.dart';
import 'package:myapp/service/job_recommend_service.dart';
import 'package:myapp/service/personality_service.dart';
import 'package:myapp/service/user_service.dart';
import 'package:myapp/widgets/custom_scaffold.dart';

class PersonalityScreen extends StatefulWidget {
  const PersonalityScreen({Key? key}) : super(key: key);

  @override
  State<PersonalityScreen> createState() => _PersonalityScreenState();
}

class _PersonalityScreenState extends State<PersonalityScreen>
    with SingleTickerProviderStateMixin {
  UserModel? user;
  PersonalityModel? personalityData;
  List<JobRecommendationModel> jobRecommendations = [];
  bool isLoading = true;
  bool isError = false;
  String errorMessage = '';

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _slideAnimation = Tween<double>(
      begin: 30.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutQuint,
    ));

    loadUserData();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> loadUserData() async {
    setState(() {
      isLoading = true;
      isError = false;
    });

    try {
      // Load user data
      final userData = await UserService.getCurrentUser();

      if (userData == null) {
        setState(() {
          isLoading = false;
          isError = true;
          errorMessage = 'Tidak dapat memuat data pengguna';
        });
        return;
      }

      user = userData;

      // Check if user has personality data
      if (user?.kepribadian == null || user!.kepribadian!.isEmpty) {
        setState(() {
          isLoading = false;
        });
        return;
      }

      // Load personality details from sheet
      final personality =
          await PersonalityService.getPersonalityByCategory(user!.kepribadian!);

      // Load job recommendations
      final jobs = await JobRecommendationService.getJobsByPersonality(
          user!.kepribadian!);

      setState(() {
        personalityData = personality;
        jobRecommendations = jobs;
        isLoading = false;
      });

      _controller.forward();
    } catch (e) {
      setState(() {
        isLoading = false;
        isError = true;
        errorMessage = 'Terjadi kesalahan: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: greenBorders,
        title: const Text(
          'Kepribadian',
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
            Navigator.pop(context);
          },
        ),
        actions: [
          if (!isLoading && !isError && personalityData != null)
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: loadUserData,
              tooltip: 'Refresh data',
            ),
        ],
      ),
      child: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: greenBorders,
              ),
            )
          : isError
              ? _buildErrorView()
              : (user?.kepribadian == null || user!.kepribadian!.isEmpty)
                  ? _buildNoPersonalityData()
                  : _buildPersonalityData(),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: Colors.red.shade300,
            ),
            const Gap(16),
            Text(
              'Terjadi Kesalahan',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
              textAlign: TextAlign.center,
            ),
            const Gap(16),
            Text(
              errorMessage,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            const Gap(24),
            ElevatedButton.icon(
              onPressed: loadUserData,
              style: ElevatedButton.styleFrom(
                backgroundColor: greenBorders,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.refresh),
              label: const Text(
                'Coba Lagi',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoPersonalityData() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.psychology_alt,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const Gap(16),
            Text(
              'Belum Ada Data Kepribadian',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
              textAlign: TextAlign.center,
            ),
            const Gap(16),
            Text(
              'Anda perlu menyelesaikan tes RIASEC terlebih dahulu untuk melihat hasil kepribadian Anda.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            const Gap(24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, RoutesName.testIntroScreen);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: greenBorders,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.quiz),
              label: const Text(
                'Mulai Tes Kepribadian',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalityData() {
    final personalityType = user!.kepribadian!;

    // If personalityData is null, we can't continue
    if (personalityData == null) {
      return Center(
        child: Text(
          'Data kepribadian tidak ditemukan',
          style: TextStyle(
            fontSize: 18,
            color: Colors.grey.shade700,
          ),
        ),
      );
    }

    // Get color and icon using helper methods
    final Color typeColor = PersonalityModel.getTypeColor(personalityType);
    final String typeCode = personalityType.substring(0, 1);

    // Get actual data from the spreadsheet
    final List<String> strengths = personalityData!.strengths;
    final List<String> weaknesses = personalityData!.weaknesses;
    final List<String> characteristic = personalityData!.characteristic;
    final String description = personalityData!.deskripsi;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with personality type
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      typeColor,
                      typeColor.withOpacity(0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: typeColor.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.white.withOpacity(0.3),
                      child: Text(
                        typeCode,
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const Gap(16),
                    Text(
                      personalityType,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Gap(8),
                    Text(
                      description.isNotEmpty
                          ? description
                          : "Tidak ada deskripsi yang tersedia",
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const Gap(24),

              // Characteristics
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Opacity(
                    opacity: _fadeAnimation.value,
                    child: Transform.translate(
                      offset: Offset(0, _slideAnimation.value),
                      child: child,
                    ),
                  );
                },
                child: _buildSectionCard(
                  'Karakteristik Utama',
                  'Berikut adalah karakteristik umum dari kepribadian ${personalityType}:',
                  characteristic,
                  Icons.psychology,
                  typeColor,
                ),
              ),

              const Gap(16),

              // Strengths
              if (strengths.isNotEmpty)
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _fadeAnimation.value,
                      child: Transform.translate(
                        offset: Offset(0, _slideAnimation.value * 0.7),
                        child: child,
                      ),
                    );
                  },
                  child: _buildSectionCard(
                    'Kekuatan',
                    'Kekuatan dari kepribadian ${personalityType}:',
                    strengths,
                    Icons.star,
                    typeColor,
                  ),
                ),

              const Gap(16),

              // Challenges/Weaknesses
              if (weaknesses.isNotEmpty)
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _fadeAnimation.value,
                      child: Transform.translate(
                        offset: Offset(0, _slideAnimation.value * 0.5),
                        child: child,
                      ),
                    );
                  },
                  child: _buildSectionCard(
                    'Tantangan',
                    'Tantangan yang mungkin dihadapi kepribadian ${personalityType}:',
                    weaknesses,
                    Icons.warning_amber,
                    typeColor,
                  ),
                ),

              const Gap(16),

              // Career paths section
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Opacity(
                    opacity: _fadeAnimation.value,
                    child: Transform.translate(
                      offset: Offset(0, _slideAnimation.value * 0.3),
                      child: child,
                    ),
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                    border: Border.all(
                      color: typeColor.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.work,
                            color: typeColor,
                            size: 24,
                          ),
                          const Gap(12),
                          Text(
                            'Karir yang Sesuai',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade800,
                            ),
                          ),
                        ],
                      ),
                      const Gap(16),
                      if (jobRecommendations.isNotEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: typeColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Rekomendasi Pekerjaan',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: typeColor,
                                ),
                              ),
                              const Gap(12),
                              for (int i = 0;
                                  i < jobRecommendations.length && i < 3;
                                  i++)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.check_circle,
                                        color: typeColor,
                                        size: 16,
                                      ),
                                      const Gap(8),
                                      Text(
                                        jobRecommendations[i].pekerjaan,
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.grey.shade800,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              if (jobRecommendations.length > 3)
                                Text(
                                  '... dan ${jobRecommendations.length - 3} lainnya',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade600,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                            ],
                          ),
                        )
                      else
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Belum ada rekomendasi pekerjaan untuk tipe kepribadian ini',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade700,
                              fontStyle: FontStyle.italic,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      const Gap(16),
                      Text(
                        'Untuk informasi lebih lengkap tentang jalur karir yang sesuai dengan kepribadian Anda:',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const Gap(12),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pushNamed(context, RoutesName.careerScreen);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: typeColor,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(
                          Icons.arrow_forward,
                          color: Colors.white,
                        ),
                        label: const Text(
                          'Lihat Rekomendasi Karir',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const Gap(24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard(String title, String subtitle, List<String> items,
      IconData icon, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: color,
                size: 24,
              ),
              const Gap(12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
          const Gap(12),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          const Gap(16),
          ...items.map((item) => _buildListItem(item, color)).toList(),
        ],
      ),
    );
  }

  Widget _buildListItem(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check_circle,
            color: color,
            size: 20,
          ),
          const Gap(12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
