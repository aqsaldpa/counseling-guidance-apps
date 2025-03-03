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

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  UserModel? user;
  bool isLoading = true;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  PersonalityModel? personalityData;
  List<JobRecommendationModel> jobRecommendations = [];

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
    });

    try {
      final userData = await UserService.getCurrentUser();

      // Inisialisasi data user
      setState(() {
        user = userData;
      });

      // Jika user memiliki data kepribadian, ambil detailnya dari sheet
      if (user != null &&
          user!.kepribadian != null &&
          user!.kepribadian!.isNotEmpty) {
        try {
          // Load personality details dari sheet
          final personality = await PersonalityService.getPersonalityByCategory(
              user!.kepribadian!);

          // Load job recommendations
          final jobs = await JobRecommendationService.getJobsByPersonality(
              user!.kepribadian!);

          setState(() {
            personalityData = personality;
            jobRecommendations = jobs;
          });
        } catch (e) {
          print('Error loading personality data: $e');
        }
      }

      setState(() {
        isLoading = false;
      });
      _controller.forward();
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _controller.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    print(user?.tglLahir ?? '-');
    return CustomScaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: greenBorders,
        title: const Text(
          'Profil',
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
      child: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: greenBorders,
              ),
            )
          : FadeTransition(
              opacity: _fadeAnimation,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Gap(24),

                      // Personal information
                      Text(
                        'Informasi Pribadi',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800,
                        ),
                      ),

                      const Gap(12),

                      // Profile details card
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // Added name to the personal information section
                            _buildInfoItem(
                                'Nama', user?.nama ?? '-', Icons.person),
                            _buildDivider(),
                            _buildInfoItem('ID Siswa', user?.id ?? '-',
                                Icons.badge_outlined),
                            _buildDivider(),
                            _buildInfoItem('Kelas', user?.kelas ?? '-',
                                Icons.school_outlined),
                            _buildDivider(),
                            _buildInfoItem(
                                'Jenis Kelamin',
                                user?.jenisKelamin ?? '-',
                                Icons.person_outline),
                            _buildDivider(),
                            _buildInfoItem(
                                'Tempat Lahir',
                                user?.tempatLahir ?? '-',
                                Icons.location_city_outlined),
                            _buildDivider(),
                            _buildInfoItem(
                                'Tanggal Lahir',
                                user?.formattedBirthDate ?? '-',
                                Icons.calendar_today_outlined),
                            _buildDivider(),
                            _buildInfoItem(
                                'Umur',
                                '${user?.umur.toString()} Tahun',
                                Icons.cake_outlined),
                          ],
                        ),
                      ),

                      const Gap(24),

                      // Personality type section (if available)
                      Text(
                        'Hasil Tes Kepribadian',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800,
                        ),
                      ),

                      const Gap(12),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
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
                                  Icons.psychology_alt,
                                  color: Colors.orange.shade700,
                                  size: 20,
                                ),
                                const Gap(8),
                                Text(
                                  'Tipe RIASEC',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey.shade800,
                                  ),
                                ),
                              ],
                            ),
                            const Gap(16),

                            // Show personality type if available
                            if (user?.kepribadian != null &&
                                user!.kepribadian!.isNotEmpty)
                              _buildPersonalityResult(user!.kepribadian!)
                            else
                              _buildNoPersonalityData(),
                          ],
                        ),
                      ),
                      const Gap(24),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildPersonalityResult(String personalityType) {
    // Gunakan model kepribadian untuk mendapatkan warna
    final color = PersonalityModel.getTypeColor(personalityType);
    final typeCode = personalityType.substring(0, 1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: color.withOpacity(0.2),
          child: Text(
            typeCode,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
        const Gap(16),
        Text(
          personalityType,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
          textAlign: TextAlign.center,
        ),
        const Gap(8),
        // Gunakan data deskripsi dari model personality jika tersedia
        Text(
          personalityData?.deskripsi ?? "Memuat deskripsi...",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.grey.shade700,
            fontSize: 14,
          ),
        ),
        const Gap(16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              const Text(
                'Mata Pelajaran Keterampilan yang Sesuai:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const Gap(8),
              if (jobRecommendations.isNotEmpty)
                Column(
                  children: [
                    for (int i = 0; i < jobRecommendations.length && i < 3; i++)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          jobRecommendations[i].pekerjaan,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                          textAlign: TextAlign.center,
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
                )
              else
                Text(
                  'Memuat rekomendasi...',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                  textAlign: TextAlign.center,
                ),
            ],
          ),
        ),
        const Gap(16),
        ElevatedButton.icon(
          onPressed: () {
            Navigator.pushNamed(context, RoutesName.kepribadianScreen);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 45),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          icon: const Icon(
            Icons.psychology_alt_outlined,
            color: Colors.white,
          ),
          label: const Text(
            'Lihat Detail Kepribadian',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNoPersonalityData() {
    return Center(
      child: Column(
        children: [
          Icon(
            Icons.quiz_outlined,
            size: 40,
            color: Colors.grey.shade400,
          ),
          const Gap(8),
          Text(
            'Belum ada data kepribadian',
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 14,
            ),
          ),
          const Gap(16),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/test_intro');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: greenBorders,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Mulai Tes Kepribadian'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 12,
        horizontal: 16,
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: greenBorders.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: greenBorders,
              size: 18,
            ),
          ),
          const Gap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                const Gap(2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      color: Colors.grey.shade200,
      height: 1,
      indent: 16,
      endIndent: 16,
    );
  }
}
