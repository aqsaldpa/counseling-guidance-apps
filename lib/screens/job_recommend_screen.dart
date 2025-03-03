import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:myapp/constant/color.dart';
import 'package:myapp/model/job_recommend.dart';
import 'package:myapp/model/personality_model.dart';
import 'package:myapp/model/user_model.dart';
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
  late Animation<double> slideAnimation;

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

    slideAnimation = Tween<double>(
      begin: 30.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutQuint,
    ));

    loadData();
  }

  @override
  void dispose() {
    _controller.dispose();
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
        return;
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
        backgroundColor: greenBorders,
        title: const Text(
          'Rekomendasi Karir',
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
          if (!isLoading && !isError)
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: loadData,
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
              : _buildJobRecommendationsView(),
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
            if (errorMessage.contains('belum memiliki hasil tes kepribadian'))
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/test_intro');
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
              )
            else
              ElevatedButton.icon(
                onPressed: loadData,
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

  Widget _buildJobRecommendationsView() {
    if (jobRecommendations.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.work_off_outlined,
                size: 80,
                color: Colors.grey.shade400,
              ),
              const Gap(16),
              Text(
                'Belum Ada Rekomendasi',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700,
                ),
                textAlign: TextAlign.center,
              ),
              const Gap(16),
              Text(
                'Kami belum memiliki rekomendasi karir untuk tipe kepribadian Anda. Silakan periksa kembali nanti.',
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
                icon: const Icon(
                  Icons.arrow_back,
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
            ],
          ),
        ),
      );
    }

    final personalityType = user!.kepribadian!;
    final Color typeColor = PersonalityModel.getTypeColor(personalityType);

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
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
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: typeColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.work_outline,
                        color: typeColor,
                        size: 32,
                      ),
                    ),
                    const Gap(16),
                    Text(
                      'Rekomendasi Karir untuk',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const Gap(4),
                    Text(
                      'Tipe ${personalityType}',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: typeColor,
                      ),
                    ),
                    const Gap(16),
                    Text(
                      'Berikut adalah pekerjaan dan keterampilan yang cocok dengan kepribadian Anda.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const Gap(24),

              // Count of jobs found
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: [
                    Text(
                      'Karir yang Sesuai ',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: typeColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${jobRecommendations.length}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: typeColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Detailed job cards
              ...jobRecommendations.asMap().entries.map((entry) {
                final index = entry.key;
                final job = entry.value;

                // Create staggered animation delay based on index
                final delay = index * 0.15;
                final start = delay.clamp(0.0, 0.9);
                final end = (delay + 0.4).clamp(0.0, 1.0);

                return AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    final animationValue = Curves.easeOutQuart.transform(
                        (((_controller.value - start) / (end - start))
                            .clamp(0.0, 1.0)));

                    return Opacity(
                      opacity: animationValue.clamp(0.0, 1.0),
                      child: Transform.translate(
                        offset: Offset(
                            0, 20 * (1 - animationValue.clamp(0.0, 1.0))),
                        child: child,
                      ),
                    );
                  },
                  child: _buildJobCard(job, typeColor, index),
                );
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildJobCard(JobRecommendationModel job, Color typeColor, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: typeColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Job title
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: typeColor.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 16,
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: typeColor,
                    ),
                  ),
                ),
                const Gap(12),
                Expanded(
                  child: Text(
                    job.pekerjaan,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Job image if available
          if (job.linkGambar.isNotEmpty &&
              job.linkGambar.trim().startsWith('http'))
            Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                border: Border(
                  bottom: BorderSide(
                    color: Colors.grey.shade200,
                    width: 1,
                  ),
                ),
              ),
              child: ClipRRect(
                child: Image.network(
                  job.linkGambar,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.image_not_supported_outlined,
                            color: Colors.grey.shade400,
                            size: 40,
                          ),
                          const Gap(8),
                          Text(
                            'Gambar tidak tersedia',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                        color: typeColor,
                      ),
                    );
                  },
                ),
              ),
            ),

          // Job description
          if (job.deskripsi.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Deskripsi:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const Gap(8),
                  Text(
                    job.deskripsi,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),

          // Next steps
          if (job.nextStep.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Langkah Selanjutnya:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const Gap(8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.amber.shade200,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.lightbulb_outline,
                          color: Colors.amber.shade700,
                          size: 20,
                        ),
                        const Gap(8),
                        Expanded(
                          child: Text(
                            job.nextStep,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
