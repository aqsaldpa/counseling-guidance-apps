import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:myapp/routes/routes_name.dart';
import 'package:myapp/service/user_service.dart';
import 'package:myapp/widgets/custom_scaffold.dart';
import 'dart:math' as math;
import 'package:url_launcher/url_launcher.dart';

import '../widgets/header_menu.dart';
import '../widgets/menu_grid.dart';

class MenuItem {
  final String title;
  final IconData icon;
  final String route;
  final Color color;
  final Color backgroundColor;
  final bool requiresPersonalityData;
  final bool isWhatsApp;

  MenuItem({
    required this.title,
    required this.icon,
    required this.route,
    required this.color,
    required this.backgroundColor,
    this.requiresPersonalityData = false,
    this.isWhatsApp = false,
  });
}

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> with TickerProviderStateMixin {
  String username = '';
  bool hasPersonalityData = false;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  // Tips motivasi yang berganti secara acak
  final List<String> _motivationalTips = [
    "Jangan takut untuk mencoba hal baru dan keluar dari zona nyaman!",
    "Mengenali kepribadianmu adalah langkah awal menemukan karir yang tepat.",
    "Semakin kamu memahami dirimu, semakin mudah menentukan pilihan karir.",
    "Tes kepribadian dapat membantumu menemukan potensi tersembunyi.",
    "Kecocokan kepribadian dengan karir dapat meningkatkan kepuasan kerjamu.",
  ];
  late String _currentTip;

  final List<MenuItem> menuItems = [
    MenuItem(
      title: 'Tes Kepribadian',
      icon: Icons.psychology,
      route: RoutesName.testIntroScreen,
      color: Color(0xFF4361EE),
      backgroundColor: Color(0xFFEEF2FF),
    ),
    MenuItem(
      title: 'Profil',
      icon: Icons.person,
      route: RoutesName.profileScreen,
      color: Color(0xFF9C27B0),
      backgroundColor: Color(0xFFF3E5F5),
    ),
    MenuItem(
      title: 'Tentang RIASEC',
      icon: Icons.info_outline,
      route: RoutesName.riasecInfoScreen,
      color: Color(0xFF00BFA5),
      backgroundColor: Color(0xFFE0F2F1),
    ),
    MenuItem(
      title: 'Kepribadian',
      icon: Icons.psychology_alt,
      route: RoutesName.kepribadianScreen,
      color: Color(0xFFFF6D00),
      backgroundColor: Color(0xFFFFF3E0),
      requiresPersonalityData: true,
    ),
    MenuItem(
      title: 'Rekomendasi Karir',
      icon: Icons.work,
      route: RoutesName.careerScreen,
      color: Color(0xFFE91E63),
      backgroundColor: Color(0xFFFCE4EC),
      requiresPersonalityData: true,
    ),
    MenuItem(
      title: 'Jadwal Bimbingan',
      icon: HugeIcons.strokeRoundedWhatsapp,
      route: 'whatsapp://send?phone=+62895391442221',
      color: Color(0xFF4CAF50),
      backgroundColor: Color(0xFFE8F5E9),
      isWhatsApp: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    loadUser();

    _currentTip =
        _motivationalTips[math.Random().nextInt(_motivationalTips.length)];

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

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> loadUser() async {
    final user = await UserService.getCurrentUser();
    if (user != null && mounted) {
      setState(() {
        username = user.nama;
        hasPersonalityData =
            user.kepribadian != null && user.kepribadian!.isNotEmpty;
      });
    }
  }

  void _handleMenuItemTap(BuildContext context, MenuItem item) async {
    if (item.isWhatsApp) {
      final Uri url = Uri.parse(
          'https://wa.me/62895391442221/?text=${Uri.parse('Halo Kak, Saya mau bimbingan')}');
      await launchUrl(url);
    } else if (item.requiresPersonalityData && !hasPersonalityData) {
      _showPersonalityTestRequiredDialog(context, item);
    } else {
      Navigator.pushNamed(context, item.route);
    }
  }

  void _showPersonalityTestRequiredDialog(BuildContext context, MenuItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(
              Icons.lock,
              color: item.color,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Fitur Terkunci',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Fitur ${item.title} akan terbuka setelah Anda menyelesaikan tes kepribadian.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: item.backgroundColor.withOpacity(0.7),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: item.color.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    color: item.color,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Tes kepribadian akan membantu Anda menemukan potensi terbaik untuk masa depan karir Anda!',
                      style: TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: Colors.grey.shade800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Nanti',
              style: TextStyle(color: Colors.grey[700]),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, RoutesName.testIntroScreen);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: item.color,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child:
                const Text('Mulai Tes', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isLargeScreen = screenSize.width > 600;
    final isTooSmall = screenSize.width < 360;
    final gridCrossAxisCount = isLargeScreen ? 3 : 2;

    return CustomScaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      child: Column(
        children: [
          // Header with welcome message
          HeaderMenu(
            username: username,
            mounted: mounted,
            controller: _controller,
            fadeAnimation: _fadeAnimation,
            slideAnimation: _slideAnimation,
            currentTip: _currentTip,
          ),

          // Main menu
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Menu title with modern styling
                Padding(
                  padding: const EdgeInsets.only(
                      left: 25, bottom: 20, right: 25, top: 25),
                  child: Row(
                    children: [
                      Container(
                        width: 5,
                        height: 24,
                        decoration: BoxDecoration(
                          color: const Color(0xFF4CAF50),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        "Menu Aplikasi",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),
                ),

                // Grid menu - moved to a separate class
                Expanded(
                  child: MenuGrid(
                    menuItems: menuItems,
                    hasPersonalityData: hasPersonalityData,
                    controller: _controller,
                    gridCrossAxisCount: gridCrossAxisCount,
                    isTooSmall: isTooSmall,
                    onMenuItemTap: _handleMenuItemTap,
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
