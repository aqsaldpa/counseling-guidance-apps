// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:myapp/constant/color.dart';
import 'package:myapp/routes/routes_name.dart';
import 'package:myapp/widgets/custom_scaffold.dart';

class TestIntroScreen extends StatefulWidget {
  const TestIntroScreen({super.key});

  @override
  State<TestIntroScreen> createState() => _TestIntroScreenState();
}

class _TestIntroScreenState extends State<TestIntroScreen>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  int _currentPage = 0;
  final int _totalPages = 4;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    } else {
      // Navigate to the actual test
      Navigator.pushNamed(context, RoutesName.testScreen);
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: greenBorders,
        title: const Text(
          'Panduan Tes Kepribadian',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(25),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      child: Column(
        children: [
          // Main content
          Expanded(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                children: [
                  // Welcome page
                  _buildWelcomePage(),

                  // About the test
                  _buildAboutTestPage(),

                  // How to take the test
                  _buildHowToTakePage(),

                  // Get ready
                  _buildGetReadyPage(),
                ],
              ),
            ),
          ),

          // Page indicator
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _totalPages,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: _currentPage == index ? 24 : 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: _currentPage == index
                        ? greenBorders
                        : Colors.grey.shade300,
                  ),
                ),
              ),
            ),
          ),
          // Navigation buttons
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Back button (hidden on first page)
                _currentPage == 0
                    ? const SizedBox(width: 100)
                    : TextButton.icon(
                        onPressed: _previousPage,
                        icon: const Icon(Icons.arrow_back_rounded),
                        label: const Text('Kembali'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.grey.shade700,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),

                // Next/Start button
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: greenBorders.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton.icon(
                    onPressed: _nextPage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: greenBorders,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    icon: _currentPage == _totalPages - 1
                        ? const Icon(
                            Icons.play_arrow_rounded,
                            color: Colors.white,
                          )
                        : const Icon(
                            Icons.arrow_forward_rounded,
                            color: Colors.white,
                          ),
                    label: Text(
                      _currentPage == _totalPages - 1 ? 'Mulai Tes' : 'Lanjut',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomePage() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Header image with gradient overlay
          Container(
            height: 200,
            margin: const EdgeInsets.only(bottom: 32),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
              image: const DecorationImage(
                image: AssetImage('assets/img_test.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.6),
                  ],
                ),
              ),
              child: const Padding(
                padding: EdgeInsets.all(20),
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Text(
                    'Temukan Karir\nTerbaik Anda',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Welcome title
          Text(
            'Tes Kepribadian RIASEC',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
            textAlign: TextAlign.center,
          ),

          const Gap(16),

          // Welcome description
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Tes ini akan membantu Anda menemukan tipe kepribadian karir dan rekomendasi yang sesuai dengan minat serta potensi Anda. Anda tidak perlu menjawab semua pertanyaan jika tidak yakin - ini tentang minat dan bakat Anda.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade700,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          const Gap(36),

          // Key features with modern styling
          _buildFeatureItem(
            icon: Icons.psychology,
            title: 'Kenali Diri Anda',
            description:
                'Temukan tipe kepribadian karir yang mencerminkan minat dan kekuatan Anda',
            color: Colors.blue.shade600,
          ),

          _buildFeatureItem(
            icon: Icons.work_outline_rounded,
            title: 'Rekomendasi Karir',
            description:
                'Dapatkan saran karir yang sesuai dengan tipe kepribadian Anda',
            color: Colors.green.shade600,
          ),

          _buildFeatureItem(
            icon: Icons.school_rounded,
            title: 'Panduan Pendidikan',
            description:
                'Petunjuk jalur pendidikan yang dapat mendukung pilihan karir Anda',
            color: Colors.orange.shade600,
          ),
        ],
      ),
    );
  }

  Widget _buildAboutTestPage() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // About test card with modern styling
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.blue.shade400,
                  Colors.blue.shade700,
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.shade200.withOpacity(0.5),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.lightbulb_outline,
                    size: 44,
                    color: Colors.white,
                  ),
                ),
                const Gap(20),
                const Text(
                  'Tentang Tes RIASEC',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const Gap(16),
                const Text(
                  'Tes ini berdasarkan Teori Holland yang membagi tipe kepribadian karir menjadi 6 kelompok: Realistic, Investigative, Artistic, Social, Enterprising, dan Conventional (RIASEC).',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.white,
                    height: 1.6,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          const Gap(32),

          Text(
            'Durasi & Format',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),

          const Gap(16),

          _buildInfoCard(
            icon: Icons.timer_outlined,
            title: 'Durasi Tes',
            content:
                'Tes ini membutuhkan waktu sekitar 10-15 menit untuk diselesaikan. Jawab pada tingkat kenyamanan Anda.',
            color: Colors.green.shade600,
          ),

          const Gap(16),

          _buildInfoCard(
            icon: Icons.question_answer_outlined,
            title: 'Format Pertanyaan',
            content:
                'Anda akan menjawab serangkaian pertanyaan tentang minat, aktivitas, dan preferensi Anda. Jawab yang Anda rasa paling sesuai.',
            color: Colors.purple.shade600,
          ),

          const Gap(32),

          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline,
                  color: Colors.red.shade700,
                  size: 24,
                ),
                const Gap(16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Penting',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.red.shade700,
                        ),
                      ),
                      const Gap(6),
                      Text(
                        'Anda tidak perlu menjawab semua pertanyaan. Jawablah hanya yang Anda merasa yakin karena tes ini tentang minat dan bakat pribadi Anda.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade800,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const Gap(32),

          Text(
            'Manfaat Tes',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),

          const Gap(16),

          _buildInfoCard(
            icon: Icons.psychology_alt,
            title: 'Pemahaman Diri',
            content:
                'Mengenali minat dan kecenderungan alami yang mungkin belum Anda sadari.',
            color: Colors.amber.shade600,
          ),

          const Gap(16),

          _buildInfoCard(
            icon: Icons.trending_up,
            title: 'Keputusan Karir',
            content:
                'Mendapatkan panduan dalam memilih jalur karir yang sesuai dengan kepribadian Anda.',
            color: Colors.red.shade600,
          ),
        ],
      ),
    );
  }

  Widget _buildHowToTakePage() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              'Cara Mengerjakan Tes',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
          ),
          const Gap(32),

          // Modern steps with gradient background
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  greenBorders.withOpacity(0.8),
                  greenBorders,
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: greenBorders.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildStepItem(
                  number: '1',
                  title: 'Persiapan',
                  description:
                      'Pastikan Anda berada di lingkungan yang tenang dan tidak terganggu selama mengerjakan tes.',
                  isLast: false,
                ),
                _buildStepItem(
                  number: '2',
                  title: 'Jawab dengan Jujur',
                  description:
                      'Pilih jawaban yang benar-benar menggambarkan diri Anda, bukan yang Anda anggap "benar".',
                  isLast: false,
                ),
                _buildStepItem(
                  number: '3',
                  title: 'Ikuti Naluri',
                  description:
                      'Jangan terlalu lama memikirkan satu pertanyaan. Jawaban pertama biasanya yang terbaik.',
                  isLast: false,
                ),
                _buildStepItem(
                  number: '4',
                  title: 'Jawab Sesuai Kenyamanan',
                  description:
                      'Anda tidak perlu menjawab semua pertanyaan. Jawab sesuai dengan yang Anda merasa yakin.',
                  isLast: true,
                ),
              ],
            ),
          ),

          const Gap(32),

          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.amber.shade200),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.tips_and_updates_outlined,
                    color: Colors.amber.shade800,
                    size: 24,
                  ),
                ),
                const Gap(16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tips',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber.shade800,
                        ),
                      ),
                      const Gap(8),
                      Text(
                        'Tidak ada jawaban benar atau salah dalam tes ini. Semua pilihan adalah tentang preferensi dan minat Anda. Lewati pertanyaan yang membuat Anda ragu.',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey.shade800,
                          height: 1.5,
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

  Widget _buildGetReadyPage() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Ready illustration with animated effect
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  greenBorders.withOpacity(0.7),
                  greenBorders,
                ],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: greenBorders.withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Icon(
              Icons.rocket_launch,
              size: 70,
              color: Colors.white,
            ),
          ),

          const Gap(32),

          Text(
            'Siap Untuk Memulai!',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
            textAlign: TextAlign.center,
          ),

          const Gap(16),

          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Anda akan menjawab serangkaian pertanyaan untuk mengidentifikasi tipe kepribadian RIASEC Anda. Ingat, Anda tidak perlu menjawab semua pertanyaan karena ini tentang minat dan bakat pribadi Anda.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade700,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          const Gap(32),

          // Final tips card with modern styling
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  'Pengingat Terakhir',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                const Gap(20),
                _buildReminderItem(
                  icon: Icons.access_time_rounded,
                  text: 'Luangkan waktu 10-15 menit',
                ),
                _buildReminderItem(
                  icon: Icons.check_circle_rounded,
                  text: 'Jawab pertanyaan dengan jujur',
                ),
                _buildReminderItem(
                  icon: Icons.skip_next_rounded,
                  text: 'Lewati pertanyaan yang membuat Anda ragu',
                ),
                _buildReminderItem(
                  icon: Icons.notifications_off_rounded,
                  text: 'Matikan notifikasi selama mengerjakan tes',
                ),
              ],
            ),
          ),

          const Gap(24),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Colors.orange.shade300,
                  Colors.orange.shade500,
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Colors.white,
                  size: 24,
                ),
                Gap(12),
                Expanded(
                  child: Text(
                    'Ingat: Tes ini tentang minat dan bakat Anda. Jawab sesuai kenyamanan.',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Gap(24),

          Text(
            'Tekan "Mulai Tes" di bawah saat Anda siap!',
            style: TextStyle(
              fontSize: 15,
              fontStyle: FontStyle.italic,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 26,
                ),
              ),
              const Gap(16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    const Gap(4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String content,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const Gap(16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                const Gap(8),
                Text(
                  content,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepItem({
    required String number,
    required String title,
    required String description,
    required bool isLast,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.5),
                  width: 2,
                ),
              ),
              child: Center(
                child: Text(
                  number,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: greenBorders,
                  ),
                ),
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 50,
                color: Colors.white.withOpacity(0.5),
                margin: const EdgeInsets.only(top: 4, bottom: 4),
              ),
          ],
        ),
        const Gap(16),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const Gap(8),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReminderItem({
    required IconData icon,
    required String text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: greenBorders.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 18,
              color: greenBorders,
            ),
          ),
          const Gap(16),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
