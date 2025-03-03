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
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _totalPages,
                (index) => Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
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
            padding: const EdgeInsets.all(16.0),
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
                        ),
                      ),

                // Next/Start button
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
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Header image
          Container(
            height: 180,
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              image: const DecorationImage(
                image: AssetImage('assets/img_test.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Welcome title
          Text(
            'Selamat Datang di Tes Kepribadian RIASEC',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
            textAlign: TextAlign.center,
          ),

          const Gap(16),

          // Welcome description
          Text(
            'Tes ini akan membantu Anda menemukan tipe kepribadian karir dan rekomendasi yang sesuai dengan minat serta potensi Anda.',
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey.shade700,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),

          const Gap(24),

          // Key features
          _buildFeatureItem(
            icon: Icons.psychology,
            title: 'Kenali Diri Anda',
            description:
                'Temukan tipe kepribadian karir yang mencerminkan minat dan kekuatan Anda',
            color: Colors.blue,
          ),

          _buildFeatureItem(
            icon: Icons.work,
            title: 'Rekomendasi Karir',
            description:
                'Dapatkan saran karir yang sesuai dengan tipe kepribadian Anda',
            color: Colors.green,
          ),

          _buildFeatureItem(
            icon: Icons.school,
            title: 'Panduan Pendidikan',
            description:
                'Petunjuk jalur pendidikan yang dapat mendukung pilihan karir Anda',
            color: Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildAboutTestPage() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // About test card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 40,
                  color: Colors.blue.shade700,
                ),
                const Gap(16),
                const Text(
                  'Tentang Tes RIASEC',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const Gap(12),
                Text(
                  'Tes ini berdasarkan Teori Holland yang membagi tipe kepribadian karir menjadi 6 kelompok: Realistic, Investigative, Artistic, Social, Enterprising, dan Conventional (RIASEC).',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade800,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          const Gap(24),

          Text(
            'Durasi & Format',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),

          const Gap(12),

          _buildInfoCard(
            icon: Icons.timer_outlined,
            title: 'Durasi Tes',
            content:
                'Tes ini membutuhkan waktu sekitar 10-15 menit untuk diselesaikan.',
            color: Colors.green,
          ),

          const Gap(12),

          _buildInfoCard(
            icon: Icons.question_answer_outlined,
            title: 'Format Pertanyaan',
            content:
                'Anda akan menjawab serangkaian pertanyaan tentang minat, aktivitas, dan preferensi Anda.',
            color: Colors.purple,
          ),

          const Gap(24),

          Text(
            'Manfaat Tes',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),

          const Gap(12),

          _buildInfoCard(
            icon: Icons.lightbulb_outline,
            title: 'Pemahaman Diri',
            content:
                'Mengenali minat dan kecenderungan alami yang mungkin belum Anda sadari.',
            color: Colors.amber,
          ),

          const Gap(12),

          _buildInfoCard(
            icon: Icons.trending_up,
            title: 'Keputusan Karir',
            content:
                'Mendapatkan panduan dalam memilih jalur karir yang sesuai dengan kepribadian Anda.',
            color: Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildHowToTakePage() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cara Mengerjakan Tes',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
            textAlign: TextAlign.center,
          ),
          const Gap(24),
          _buildStepCard(
            number: '1',
            title: 'Persiapan',
            description:
                'Pastikan Anda berada di lingkungan yang tenang dan tidak terganggu selama mengerjakan tes.',
          ),
          _buildStepCard(
            number: '2',
            title: 'Jawab dengan Jujur',
            description:
                'Pilih jawaban yang benar-benar menggambarkan diri Anda, bukan yang Anda anggap "benar".',
          ),
          _buildStepCard(
            number: '3',
            title: 'Ikuti Naluri',
            description:
                'Jangan terlalu lama memikirkan satu pertanyaan. Jawaban pertama biasanya yang terbaik.',
          ),
          _buildStepCard(
            number: '4',
            title: 'Selesaikan Semua',
            description:
                'Pastikan untuk menjawab semua pertanyaan untuk mendapatkan hasil yang akurat.',
          ),
          const Gap(24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.amber.shade200),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.tips_and_updates_outlined,
                  color: Colors.amber.shade800,
                  size: 24,
                ),
                const Gap(12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tips',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber.shade800,
                        ),
                      ),
                      const Gap(4),
                      Text(
                        'Tidak ada jawaban benar atau salah dalam tes ini. Semua pilihan adalah tentang preferensi dan minat Anda.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade800,
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
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Ready illustration
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: greenBorders.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.rocket_launch_outlined,
              size: 60,
              color: greenBorders,
            ),
          ),

          const Gap(24),

          Text(
            'Siap Untuk Memulai!',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
            textAlign: TextAlign.center,
          ),

          const Gap(16),

          Text(
            'Anda akan menjawab serangkaian pertanyaan untuk mengidentifikasi tipe kepribadian RIASEC Anda.',
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey.shade700,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),

          const Gap(24),

          // Final tips card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  'Pengingat Terakhir',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                const Gap(12),
                _buildReminderItem(
                  icon: Icons.access_time,
                  text: 'Luangkan waktu 10-15 menit',
                ),
                _buildReminderItem(
                  icon: Icons.check_circle_outline,
                  text: 'Jawab semua pertanyaan dengan jujur',
                ),
                _buildReminderItem(
                  icon: Icons.battery_full,
                  text: 'Pastikan baterai perangkat cukup',
                ),
                _buildReminderItem(
                  icon: Icons.notifications_off_outlined,
                  text: 'Matikan notifikasi jika perlu',
                ),
              ],
            ),
          ),

          const Gap(24),

          Text(
            'Tekan "Mulai Tes" di bawah saat Anda siap!',
            style: TextStyle(
              fontSize: 14,
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
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
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
                const Gap(4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
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
      padding: const EdgeInsets.all(16),
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
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 18,
            ),
          ),
          const Gap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                const Gap(4),
                Text(
                  content,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepCard({
    required String number,
    required String title,
    required String description,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
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
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: greenBorders,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const Gap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                const Gap(4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReminderItem({
    required IconData icon,
    required String text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: greenBorders,
          ),
          const Gap(8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
