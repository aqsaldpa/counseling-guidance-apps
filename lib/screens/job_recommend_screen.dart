import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:myapp/constant/color.dart';
import 'package:myapp/model/job_recommend.dart';
import 'package:myapp/model/personality_model.dart';
import 'package:myapp/model/user_model.dart';
import 'package:myapp/routes/routes_name.dart';
import 'package:myapp/service/job_recommend_service.dart';
import 'package:myapp/service/user_service.dart';
import 'package:myapp/widgets/custom_scaffold.dart';

class JobRecommendationScreen extends StatefulWidget {
  const JobRecommendationScreen({super.key});

  @override
  State<JobRecommendationScreen> createState() =>
      _JobRecommendationScreenState();
}

class _JobRecommendationScreenState extends State<JobRecommendationScreen>
    with SingleTickerProviderStateMixin {
  UserModel? user;
  List<JobRecommendationModel> jobRecommendations = [];
  bool isLoading = true;
  bool isError = false;
  String errorMessage = '';
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  // For smooth animations
  final PageController _pageController = PageController(viewportFraction: 0.93);
  int _currentPage = 0;

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

    loadData();
  }

  @override
  void dispose() {
    _controller.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> loadData() async {
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

      if (user?.kepribadian != null && user!.kepribadian!.isNotEmpty) {
        final jobs = await JobRecommendationService.getJobsByPersonality(
            user?.kepribadian ?? "");

        setState(() {
          jobRecommendations = jobs;
          isLoading = false;
        });
        _controller.forward();
      } else {
        setState(() {
          isLoading = false;
          isError = true;
          errorMessage =
              'Anda belum memiliki hasil tes kepribadian. Silakan lakukan tes kepribadian terlebih dahulu.';
        });
      }
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
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: const Text(
          'Rekomendasi Karir',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (!isLoading && !isError)
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              onPressed: loadData,
              tooltip: 'Refresh data',
            ),
        ],
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                greenBorders,
                greenSecondary,
              ],
            ),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
            boxShadow: [
              BoxShadow(
                color: greenBorders.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
        ),
      ),
      child: isLoading
          ? _buildLoadingView()
          : isError
              ? _buildErrorView()
              : _buildJobRecommendationsView(),
    );
  }

  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 60,
            height: 60,
            child: CircularProgressIndicator(
              color: greenBorders,
              strokeWidth: 4,
            ),
          ),
          const Gap(24),
          Text(
            'Memuat rekomendasi karir...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 64,
                color: Colors.red.shade400,
              ),
            ),
            const Gap(24),
            Text(
              'Terjadi Kesalahan',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
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
            const Gap(32),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: greenBorders.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: errorMessage
                        .contains('belum memiliki hasil tes kepribadian')
                    ? ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(
                              context, RoutesName.testIntroScreen);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: greenBorders,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        icon: const Icon(Icons.quiz_rounded),
                        label: const Text(
                          'Mulai Tes Kepribadian',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    : ElevatedButton.icon(
                        onPressed: loadData,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: greenBorders,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text(
                          'Coba Lagi',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJobRecommendationsView() {
    if (jobRecommendations.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.work_off_rounded,
                  size: 64,
                  color: Colors.grey.shade400,
                ),
              ),
              const Gap(24),
              Text(
                'Belum Ada Rekomendasi',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
                textAlign: TextAlign.center,
              ),
              const Gap(16),
              Text(
                'Kami belum memiliki rekomendasi karir untuk tipe kepribadian Anda. Silakan periksa kembali nanti.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const Gap(32),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: greenBorders.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: greenBorders,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  icon: const Icon(
                    Icons.arrow_back_rounded,
                    color: Colors.white,
                  ),
                  label: const Text(
                    'Kembali',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final personalityType = user!.kepribadian!;
    final Color typeColor = PersonalityModel.getTypeColor(personalityType);

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        children: [
          // Personality Type Card - Original style
          Container(
            margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  typeColor.withOpacity(0.1),
                  typeColor.withOpacity(0.2),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: typeColor.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                // Left side - Type Avatar
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        typeColor.withOpacity(0.7),
                        typeColor,
                      ],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: typeColor.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      personalityType.substring(0, 1),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                const Gap(16),

                // Right side - Type info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Tipe ${personalityType}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: typeColor,
                        ),
                      ),
                      const Gap(4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: typeColor.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${jobRecommendations.length} Karir',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: typeColor,
                              ),
                            ),
                          ),
                          const Gap(8),
                          Text(
                            'yang sesuai untuk Anda',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Card progress indicator - Modern, minimalist design
          if (jobRecommendations.length > 1)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  ...List.generate(
                    jobRecommendations.length,
                    (index) => Expanded(
                      child: Container(
                        height: 4,
                        margin: EdgeInsets.only(
                          right: index < jobRecommendations.length - 1 ? 4 : 0,
                        ),
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? typeColor
                              : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Visual page indicator + swipe hint
          if (jobRecommendations.length > 1)
            Container(
              margin: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Page numbers
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: typeColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${_currentPage + 1} dari ${jobRecommendations.length}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: typeColor,
                      ),
                    ),
                  ),

                  // Swipe indicator
                  Row(
                    children: [
                      Icon(
                        Icons.swipe,
                        size: 16,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Geser untuk melihat semua',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

          // Main content - Page view with cards
          Expanded(
            child: Container(
              margin: const EdgeInsets.fromLTRB(0, 16, 0, 16),
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                physics: const BouncingScrollPhysics(),
                itemCount: jobRecommendations.length,
                itemBuilder: (context, index) {
                  final job = jobRecommendations[index];
                  return _buildHybridJobCard(job, typeColor, index);
                },
              ),
            ),
          ),

          // Navigation controls at bottom - Simplified and modern
          if (jobRecommendations.length > 1)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Previous button
                  if (_currentPage > 0)
                    _buildNavButton(
                      icon: Icons.arrow_back_rounded,
                      text: 'Sebelumnya',
                      onTap: () {
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      isOutlined: true,
                      typeColor: typeColor,
                    ),

                  if (_currentPage > 0 &&
                      _currentPage < jobRecommendations.length - 1)
                    const SizedBox(width: 16),

                  // Next button
                  if (_currentPage < jobRecommendations.length - 1)
                    _buildNavButton(
                      icon: Icons.arrow_forward_rounded,
                      text: 'Berikutnya',
                      onTap: () {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      isOutlined: false,
                      typeColor: typeColor,
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNavButton({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
    required bool isOutlined,
    required Color typeColor,
  }) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: isOutlined
              ? null
              : LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    typeColor.withOpacity(0.8),
                    typeColor,
                  ],
                ),
          border: isOutlined
              ? Border.all(
                  color: typeColor.withOpacity(0.3),
                  width: 1,
                )
              : null,
          boxShadow: isOutlined
              ? null
              : [
                  BoxShadow(
                    color: typeColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isOutlined && icon == Icons.arrow_back_rounded)
                    Icon(
                      icon,
                      size: 16,
                      color: typeColor,
                    ),
                  if (isOutlined && icon == Icons.arrow_back_rounded)
                    const Gap(4),
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isOutlined ? typeColor : Colors.white,
                    ),
                  ),
                  if (!isOutlined || icon == Icons.arrow_forward_rounded)
                    const Gap(4),
                  if (!isOutlined || icon == Icons.arrow_forward_rounded)
                    Icon(
                      icon,
                      size: 16,
                      color: isOutlined ? typeColor : Colors.white,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHybridJobCard(
      JobRecommendationModel job, Color typeColor, int index) {
    // Parsing mapel dengan pemisah baris (\n) seperti di PersonalityService
    List<String> mapelList = [];
    if (job.mapel.isNotEmpty) {
      mapelList = job.mapel
          .split('\n')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.15),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Modern header with gradient overlay for image
            if (job.linkGambar.isNotEmpty &&
                job.linkGambar.trim().startsWith('http'))
              Stack(
                children: [
                  // Image
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                    child: SizedBox(
                      height: 180,
                      width: double.infinity,
                      child: Image.network(
                        job.linkGambar,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey.shade200,
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.image_not_supported_outlined,
                                    color: Colors.grey.shade400,
                                    size: 32,
                                  ),
                                  const Gap(8),
                                  Text(
                                    'Gambar tidak tersedia',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            color: Colors.grey.shade100,
                            child: Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes !=
                                        null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                                color: typeColor,
                                strokeWidth: 3,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  // Gradient overlay with title
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(20, 40, 20, 20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withOpacity(0.85),
                            Colors.transparent,
                          ],
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          // Job number badge
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                '${index + 1}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: typeColor,
                                ),
                              ),
                            ),
                          ),
                          const Gap(12),

                          // Job title
                          Expanded(
                            child: Text(
                              job.pekerjaan,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),

                          // Type pill
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.65),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.work_outline_rounded,
                                  size: 16,
                                  color: Colors.white.withOpacity(0.85),
                                ),
                                const Gap(6),
                                Text(
                                  user?.kepribadian ?? 'RIASEC',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white.withOpacity(0.85),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              )
            else
              // Fallback colored header if no image
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      typeColor.withOpacity(0.8),
                      typeColor,
                    ],
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    // Job number badge
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: typeColor,
                          ),
                        ),
                      ),
                    ),
                    const Gap(12),
                    Expanded(
                      child: Text(
                        job.pekerjaan,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Content area with description
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Content sections with consistent padding
                    Container(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Job description - Original style
                          if (job.deskripsi.isNotEmpty)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildSectionHeader(
                                  'Deskripsi',
                                  Icons.description_outlined,
                                  typeColor,
                                ),
                                const Gap(12),
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade50,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: Colors.grey.shade200,
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    job.deskripsi,
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.grey.shade700,
                                      height: 1.5,
                                    ),
                                  ),
                                ),
                                const Gap(24),
                              ],
                            ),

                          // Mapel yang Direkomendasikan - Original style
                          if (mapelList.isNotEmpty)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildSectionHeader(
                                  'Mata Pelajaran Pendukung',
                                  Icons.school_outlined,
                                  Colors.blue.shade700,
                                ),
                                const Gap(12),
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Colors.blue.shade50,
                                        Colors.blue.shade100.withOpacity(0.3),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: Colors.blue.shade200,
                                      width: 1,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.info_outline_rounded,
                                            size: 16,
                                            color: Colors.blue.shade700,
                                          ),
                                          const Gap(8),
                                          Expanded(
                                            child: Text(
                                              'Untuk mengejar karir ini, sebaiknya fokus pada:',
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontStyle: FontStyle.italic,
                                                color: Colors.blue.shade800,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      ...mapelList.map((mapel) {
                                        return Container(
                                          margin:
                                              const EdgeInsets.only(bottom: 8),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Icon(
                                                Icons.check_circle_rounded,
                                                size: 16,
                                                color: Colors.blue.shade700,
                                              ),
                                              const SizedBox(width: 10),
                                              Expanded(
                                                child: Text(
                                                  mapel,
                                                  style: TextStyle(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors.blue.shade900,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                    ],
                                  ),
                                ),
                                const Gap(24),
                              ],
                            ),

                          // Next steps - Original style
                          if (job.nextStep.isNotEmpty)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildSectionHeader(
                                  'Langkah Selanjutnya',
                                  Icons.lightbulb_outline,
                                  Colors.amber.shade700,
                                ),
                                const Gap(12),
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Colors.amber.shade50,
                                        Colors.amber.shade100.withOpacity(0.3),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: Colors.amber.shade200,
                                      width: 1,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Icon(
                                            Icons.arrow_right_rounded,
                                            size: 20,
                                            color: Colors.amber.shade700,
                                          ),
                                          const SizedBox(width: 6),
                                          Expanded(
                                            child: Text(
                                              job.nextStep,
                                              style: TextStyle(
                                                fontSize: 15,
                                                color: Colors.grey.shade800,
                                                height: 1.5,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            size: 18,
            color: color,
          ),
        ),
        const Gap(10),
        Text(
          title,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
      ],
    );
  }
}
