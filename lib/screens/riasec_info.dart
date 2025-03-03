import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:myapp/constant/color.dart';
import 'package:myapp/model/personality_model.dart';
import 'package:myapp/service/personality_service.dart';
import 'package:myapp/widgets/custom_scaffold.dart';

class RiasecInfoScreen extends StatefulWidget {
  const RiasecInfoScreen({super.key});

  @override
  State<RiasecInfoScreen> createState() => _RiasecInfoScreenState();
}

class _RiasecInfoScreenState extends State<RiasecInfoScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  bool isLoading = true;
  bool isError = false;
  String errorMessage = '';
  List<PersonalityModel> riasecTypes = [];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );

    loadRiasecData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> loadRiasecData() async {
    setState(() {
      isLoading = true;
      isError = false;
    });

    try {
      // Load data for each RIASEC type
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

      setState(() {
        riasecTypes = types;
        isLoading = false;
      });

      _animationController.forward();
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
          'Tipe Kepribadian RIASEC',
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
              onPressed: loadRiasecData,
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
              bottomLeft: Radius.circular(28),
              bottomRight: Radius.circular(28),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.green.withOpacity(0.2),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
        ),
      ),
      child: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: greenBorders,
              ),
            )
          : isError
              ? _buildErrorView()
              : FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    children: [
                      // Introduction section
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: greenBorders.withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.info_outline,
                                      color: greenBorders,
                                      size: 20,
                                    ),
                                  ),
                                  const Gap(12),
                                  Expanded(
                                    child: Text(
                                      'Tentang Teori RIASEC',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey.shade800,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const Gap(12),
                              Text(
                                'Teori RIASEC dikembangkan oleh John Holland adalah kerangka kerja untuk memahami hubungan antara kepribadian dan pilihan karir. Teori ini membagi kepribadian menjadi enam tipe dasar yang dapat membantu mengidentifikasi jalur karir yang cocok.',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade700,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Color legend
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: riasecTypes.map((type) {
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                child: CircleAvatar(
                                  radius: 16,
                                  backgroundColor:
                                      PersonalityModel.getTypeColor(
                                              type.kategori)
                                          .withOpacity(0.2),
                                  child: Text(
                                    type.kategori.substring(0, 1),
                                    style: TextStyle(
                                      color: PersonalityModel.getTypeColor(
                                          type.kategori),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),

                      const Gap(8),

                      // RIASEC types list
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          physics: const BouncingScrollPhysics(),
                          itemCount: riasecTypes.length,
                          itemBuilder: (context, index) {
                            final type = riasecTypes[index];
                            return _buildRiasecCard(type);
                          },
                        ),
                      ),
                    ],
                  ),
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
              onPressed: loadRiasecData,
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

  Widget _buildRiasecCard(PersonalityModel type) {
    final Color typeColor = PersonalityModel.getTypeColor(type.kategori);
    final String letter = type.kategori.substring(0, 1);
    final String characteristics = type.characteristic.isNotEmpty
        ? type.characteristic.join(', ')
        : 'Tidak ada data karakteristik';

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
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          leading: CircleAvatar(
            backgroundColor: typeColor.withOpacity(0.2),
            child: Text(
              letter,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: typeColor,
              ),
            ),
          ),
          title: Text(
            type.kategori,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(
            characteristics,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
          backgroundColor: Colors.white,
          collapsedBackgroundColor: Colors.white,
          iconColor: typeColor,
          textColor: Colors.grey.shade800,
          collapsedIconColor: typeColor,
          collapsedTextColor: Colors.grey.shade800,
          children: [
            const Gap(8),
            _buildDetailSection(
              icon: Icons.description_outlined,
              title: 'Deskripsi',
              content: type.deskripsi,
            ),
            const Gap(12),
            if (type.characteristic.isNotEmpty)
              _buildDetailSection(
                icon: Icons.psychology_outlined,
                title: 'Karakteristik',
                content: type.characteristic.join('\n'),
              ),
            const Gap(12),
            if (type.strengths.isNotEmpty)
              _buildDetailSection(
                icon: Icons.star_border,
                title: 'Kekuatan',
                content: type.strengths.join('\n'),
              ),
            const Gap(12),
            if (type.weaknesses.isNotEmpty)
              _buildDetailSection(
                icon: Icons.warning_amber_outlined,
                title: 'Hal yang Perlu Diperhatikan',
                content: type.weaknesses.join('\n'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailSection({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 18,
          color: Colors.grey.shade700,
        ),
        const Gap(8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              const Gap(4),
              Text(
                content.isEmpty ? 'Tidak ada data tersedia' : content,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade700,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
