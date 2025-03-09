import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:myapp/constant/color.dart';
import 'package:myapp/model/job_recommend.dart';
import 'package:myapp/model/personality_model.dart';
import 'package:myapp/routes/routes_name.dart';
import 'package:myapp/service/job_recommend_service.dart';
import 'package:myapp/service/personality_service.dart';
import 'package:myapp/service/sheet_service.dart';
import 'package:myapp/service/test_service.dart';
import 'package:myapp/service/user_service.dart';
import 'package:myapp/widgets/custom_scaffold.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:url_launcher/url_launcher.dart';

class RiasecResultsScreen extends StatefulWidget {
  final Map<String, int> scores;
  final List<PersonalityModel> personalityTypes;

  const RiasecResultsScreen({
    super.key,
    required this.scores,
    required this.personalityTypes,
  });

  @override
  State<RiasecResultsScreen> createState() => RiasecResultsScreenState();
}

class RiasecResultsScreenState extends State<RiasecResultsScreen>
    with SingleTickerProviderStateMixin {
  bool isSavingResult = false;
  bool isLoadingDetails = true;
  final RiasecTestService testService = RiasecTestService();
  late TabController _tabController;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Add variables for personality details
  PersonalityModel? primaryPersonalityDetails;
  List<JobRecommendationModel> jobRecommendations = [];

  @override
  void initState() {
    super.initState();
    initializeData();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> initializeData() async {
    setState(() {
      isLoadingDetails = true;
    });

    await testService.initialize();

    // Get the primary personality category
    final sortedScores = getSortedScores();
    if (sortedScores.isNotEmpty) {
      final primaryCategory = sortedScores[0].key;
      final primaryFullName = testService.getCategoryFullName(primaryCategory);

      // Load personality details using PersonalityService
      try {
        // Import the PersonalityService
        primaryPersonalityDetails =
            await PersonalityService.getPersonalityByCategory(primaryFullName);

        // Load job recommendations
        try {
          // Import JobRecommendationService
          jobRecommendations =
              await JobRecommendationService.getJobsByPersonality(
                  primaryFullName);
        } catch (e) {
          debugPrint('Error loading job recommendations: $e');
          // Fallback to empty list - already initialized
        }
      } catch (e) {
        debugPrint('Error loading personality details: $e');
        // primaryPersonalityDetails remains null
      }
    }

    if (mounted) {
      setState(() {
        isLoadingDetails = false;
      });
    }
  }

  List<MapEntry<String, int>> getSortedScores() {
    final scoreEntries = widget.scores.entries.toList();
    scoreEntries.sort((a, b) => b.value.compareTo(a.value));
    return scoreEntries;
  }

  Future<bool> savePersonalityType(String personalityCode) async {
    if (isSavingResult) return false;

    setState(() {
      isSavingResult = true;
    });

    try {
      final String fullPersonalityType =
          testService.getCategoryFullName(personalityCode);

      final success =
          await SheetService.savePersonalityType(fullPersonalityType);

      if (success) {
        await SheetService.refreshCurrentUser();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Hasil kepribadian "$fullPersonalityType" berhasil disimpan'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              margin: const EdgeInsets.all(10),
            ),
          );
        }
        return true;
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Gagal menyimpan hasil kepribadian'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              margin: const EdgeInsets.all(10),
            ),
          );
        }
        return false;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.all(10),
          ),
        );
      }
      return false;
    } finally {
      if (mounted) {
        setState(() {
          isSavingResult = false;
        });
      }
    }
  }

  Future<void> navigateToSplashScreen() async {
    try {
      await SheetService.init();
      await UserService.getCurrentUser();

      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          RoutesName.splashScreen,
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error navigating to home: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.all(10),
          ),
        );
      }
    }
  }

  void navigateToPersonalityScreen() {
    if (mounted) {
      Navigator.pushReplacementNamed(context, RoutesName.splashScreen);
    }
  }

  @override
  Widget build(BuildContext context) {
    final sortedScores = getSortedScores();
    final totalChecked =
        sortedScores.fold<int>(0, (sum, entry) => sum + entry.value);
    final topThreeCategories = sortedScores.take(3).toList();

    final primaryCategory =
        topThreeCategories.isNotEmpty ? topThreeCategories[0].key : 'R';
    final primaryColor = PersonalityModel.getTypeColor(
        testService.getCategoryFullName(primaryCategory));

    // Use the fetched detailed data or fallback to basic service data
    final primaryDescription = primaryPersonalityDetails?.deskripsi ??
        testService.getCategoryDescription(primaryCategory);

    return CustomScaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: greenBorders,
        title: const Text(
          'Hasil Tes RIASEC',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(24),
          ),
        ),
        automaticallyImplyLeading: false,
      ),
      child: isLoadingDetails
          ? const Center(
              child: CircularProgressIndicator(
                color: greenBorders,
              ),
            )
          : Column(
              children: [
                buildResultsHeader(primaryCategory, primaryColor),
                Expanded(
                  child: NestedScrollView(
                    headerSliverBuilder: (context, innerBoxScrolled) {
                      return [
                        SliverToBoxAdapter(
                          child: TabBar(
                            controller: _tabController,
                            labelColor: primaryColor,
                            unselectedLabelColor: Colors.grey,
                            indicatorColor: primaryColor,
                            indicatorWeight: 3,
                            tabs: const [
                              Tab(
                                text: 'Hasil Utama',
                                icon: Icon(Icons.psychology),
                              ),
                              Tab(
                                text: 'Detail Semua Tipe',
                                icon: Icon(Icons.pie_chart),
                              ),
                            ],
                          ),
                        ),
                      ];
                    },
                    body: TabBarView(
                      controller: _tabController,
                      children: [
                        // Tab 1: Main Results
                        SingleChildScrollView(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              buildPrimaryResult(primaryCategory, primaryColor,
                                  primaryDescription),
                              const Gap(24),
                              buildActionButtons(primaryCategory, primaryColor),
                            ],
                          ),
                        ),
                        // Tab 2: All Scores & Secondary Types
                        SingleChildScrollView(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              buildPieChart(primaryCategory, primaryColor,
                                  totalChecked, sortedScores),
                              const Gap(24),
                              if (topThreeCategories.length > 1) ...[
                                buildSecondaryResults(topThreeCategories),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget buildResultsHeader(String primaryCategory, Color primaryColor) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            primaryColor.withOpacity(0.8),
            primaryColor.withOpacity(0.6),
            primaryColor.withOpacity(0.4),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.25),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                primaryCategory,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const Gap(16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  testService.getCategoryFullName(primaryCategory),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const Gap(4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Tipe Kepribadian Dominan',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withOpacity(0.9),
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

  Widget buildPrimaryResult(
      String primaryCategory, Color primaryColor, String primaryDescription) {
    return Card(
      color: Colors.white,
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(width: 2, color: primaryColor.withOpacity(0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Description Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.grey.shade200,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.psychology,
                        size: 20,
                        color: primaryColor,
                      ),
                      const Gap(8),
                      Text(
                        'Deskripsi Tipe Kepribadian',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  Text(
                    primaryDescription,
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.5,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),
            const Gap(24),

            // Characteristics Section (if we have detailed data)
            if (primaryPersonalityDetails != null &&
                primaryPersonalityDetails!.characteristic.isNotEmpty)
              buildCharacteristicsSection(primaryColor),

            if (primaryPersonalityDetails != null &&
                primaryPersonalityDetails!.characteristic.isNotEmpty)
              const Gap(24),

            // Job Recommendations Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: primaryColor.withOpacity(0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.work,
                        size: 20,
                        color: primaryColor,
                      ),
                      const Gap(8),
                      Flexible(
                        child: Text(
                          'Karir yang Sesuai',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(
                    height: 24,
                    color: Colors.black12,
                    thickness: 1,
                  ),

                  // Display real job recommendations if we have them
                  if (jobRecommendations.isNotEmpty)
                    buildJobRecommendationsList(primaryColor)
                  else
                    // Fallback to the old behavior if no recommendations
                    buildLegacyCareerPath(primaryCategory, primaryColor),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildCharacteristicsSection(Color primaryColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: primaryColor.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                size: 20,
                color: primaryColor,
              ),
              const Gap(8),
              Text(
                'Karakteristik Utama',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          ...primaryPersonalityDetails!.characteristic
              .map((trait) => Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: primaryColor,
                          size: 18,
                        ),
                        const Gap(8),
                        Expanded(
                          child: Text(
                            trait,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ))
              .toList(),

          // Display Strengths if available
          if (primaryPersonalityDetails!.strengths.isNotEmpty) ...[
            const Gap(16),
            Text(
              'Kekuatan:',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            const Gap(8),
            ...primaryPersonalityDetails!.strengths
                .map((strength) => Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.star,
                            color: primaryColor,
                            size: 18,
                          ),
                          const Gap(8),
                          Expanded(
                            child: Text(
                              strength,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ))
                .toList(),
          ],
        ],
      ),
    );
  }

  Widget buildJobRecommendationsList(Color primaryColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: jobRecommendations.take(6).map((job) {
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.work,
                      size: 16,
                      color: primaryColor,
                    ),
                    const Gap(6),
                    Text(
                      job.pekerjaan.trim(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
        // Show a note about more options if there are more than 6 jobs
        if (jobRecommendations.length > 6) ...[
          const Gap(12),
          Center(
            child: Text(
              '... dan ${jobRecommendations.length - 6} pilihan karir lainnya',
              style: TextStyle(
                fontSize: 13,
                fontStyle: FontStyle.italic,
                color: Colors.grey.shade600,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget buildLegacyCareerPath(String primaryCategory, Color primaryColor) {
    final primaryRecommendation =
        testService.getRecommendedCareerPath(primaryCategory);

    return Center(
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        alignment: WrapAlignment.center,
        children: primaryRecommendation.split(', ').map((subject) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle,
                  size: 16,
                  color: primaryColor,
                ),
                const Gap(6),
                Text(
                  subject.trim(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget buildPieChart(String primaryCategory, Color primaryColor,
      int totalChecked, List<MapEntry<String, int>> sortedScores) {
    return Card(
      elevation: 2,
      color: Colors.white,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Distribusi Tipe Kepribadian',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            const Divider(height: 24),
            SizedBox(
              height: 300,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                      startDegreeOffset: -90,
                      sections: widget.scores.entries
                          .where((entry) => entry.value > 0)
                          .map((entry) {
                        final categoryColor = PersonalityModel.getTypeColor(
                          testService.getCategoryFullName(entry.key),
                        );
                        final percentage = totalChecked > 0
                            ? (entry.value / totalChecked) * 100
                            : 0.0;
                        final isPrimary = entry.key == primaryCategory;

                        return PieChartSectionData(
                          color: categoryColor,
                          value: entry.value.toDouble(),
                          title: '${percentage.toStringAsFixed(1)}%',
                          radius: isPrimary ? 80 : 70,
                          titleStyle: TextStyle(
                            fontSize: isPrimary ? 14 : 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                blurRadius: 2,
                                color: Colors.black.withOpacity(0.3),
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          badgeWidget: isPrimary
                              ? Container(
                                  padding: const EdgeInsets.all(4),
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
                                  child: Icon(
                                    Icons.star,
                                    color: categoryColor,
                                    size: 16,
                                  ),
                                )
                              : null,
                          badgePositionPercentageOffset: 0.95,
                        );
                      }).toList(),
                    ),
                  ),
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.white, Colors.grey.shade50],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: primaryColor.withOpacity(0.2),
                            child: Text(
                              primaryCategory,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: primaryColor,
                              ),
                            ),
                          ),
                          const Gap(4),
                          Text(
                            'Dominan',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Gap(20),
            Center(child: buildLegend(sortedScores, totalChecked)),
          ],
        ),
      ),
    );
  }

  Widget buildLegend(
      List<MapEntry<String, int>> sortedScores, int totalChecked) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'Keterangan:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const Gap(12),
          Wrap(
            spacing: 8,
            runSpacing: 12,
            children: sortedScores.where((e) => e.value > 0).map((entry) {
              final categoryColor = PersonalityModel.getTypeColor(
                testService.getCategoryFullName(entry.key),
              );
              final percentage =
                  totalChecked > 0 ? (entry.value / totalChecked) * 100 : 0.0;

              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: categoryColor.withOpacity(0.3)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: categoryColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const Gap(8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${entry.key}: ${entry.value}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${percentage.toStringAsFixed(1)}%',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget buildSecondaryResults(List<MapEntry<String, int>> topThreeCategories) {
    return Card(
      elevation: 2,
      color: Colors.white,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tipe Kepribadian Lainnya',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            const Divider(height: 24),
            if (topThreeCategories.length > 1)
              buildSecondaryResult(topThreeCategories[1]),
            if (topThreeCategories.length > 2) ...[
              const Gap(16),
              buildSecondaryResult(topThreeCategories[2]),
            ],
          ],
        ),
      ),
    );
  }

  Widget buildSecondaryResult(MapEntry<String, int> category) {
    final color = PersonalityModel.getTypeColor(
      testService.getCategoryFullName(category.key),
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Text(
              category.key,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: color,
              ),
            ),
          ),
          const Gap(16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      testService.getCategoryFullName(category.key),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: color,
                      ),
                    ),
                    const Gap(8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Skor: ${category.value}',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                    ),
                  ],
                ),
                const Gap(8),
                Text(
                  testService.getCategoryDescription(category.key),
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
      ),
    );
  }

  Widget buildActionButtons(String primaryCategory, Color primaryColor) {
    return Card(
      elevation: 2,
      color: Colors.white,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.touch_app,
                  size: 20,
                  color: primaryColor,
                ),
                const Gap(8),
                Text(
                  'Tindakan Selanjutnya',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            ElevatedButton.icon(
              onPressed: isSavingResult
                  ? null
                  : () async {
                      final success =
                          await savePersonalityType(primaryCategory);
                      if (success) {
                        await Future.delayed(const Duration(seconds: 1));
                        await navigateToSplashScreen();
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: greenBorders,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                elevation: 3,
                shadowColor: Colors.black.withOpacity(0.3),
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: isSavingResult
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.save_alt, color: Colors.white),
              label: Text(
                isSavingResult
                    ? 'Menyimpan...'
                    : 'Simpan Hasil Tes dan Kembali ke Menu',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            const Gap(16),
            OutlinedButton.icon(
              onPressed: isSavingResult
                  ? null
                  : () async {
                      await savePersonalityType(primaryCategory);
                      navigateToPersonalityScreen();
                    },
              style: OutlinedButton.styleFrom(
                foregroundColor: primaryColor,
                side: BorderSide(color: primaryColor, width: 1.5),
                padding: const EdgeInsets.symmetric(vertical: 16),
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: Icon(
                testService.getCategoryIcon(primaryCategory),
                color: primaryColor,
              ),
              label: Text(
                'Lihat Detail Kepribadian',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: primaryColor,
                ),
              ),
            ),
            const Gap(16),
            ElevatedButton.icon(
              onPressed: () async {
                final Uri url = Uri.parse(
                    'https://wa.me/62895391442221/?text=${Uri.parse('Halo Kak, Saya mau bimbingan')}');
                await launchUrl(url);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                elevation: 3,
                shadowColor: Colors.black.withOpacity(0.3),
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: const Icon(
                Icons.calendar_month_rounded,
                color: Colors.white,
              ),
              label: const Text(
                'Jadwalkan Konsultasi dengan Guru',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            const Gap(16),
            Center(
              child: TextButton.icon(
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    RoutesName.menuScreen,
                    (route) => false,
                  );
                  Navigator.pushNamed(
                    context,
                    RoutesName.testIntroScreen,
                  );
                },
                icon: const Icon(
                  Icons.refresh,
                  color: Colors.blue,
                ),
                label: const Text(
                  'Lakukan Tes Lagi',
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
