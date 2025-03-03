import 'package:flutter/material.dart';
import 'package:myapp/screens/job_recommend_screen.dart';
import 'package:myapp/screens/personality_screen.dart';
import 'package:myapp/screens/login_screen.dart';
import 'package:myapp/screens/menu_screen.dart';
import 'package:myapp/screens/profile_screen.dart';
import 'package:myapp/screens/register_screen.dart';
import 'package:myapp/screens/riasec_info.dart';
import 'package:myapp/screens/splash_screen.dart';
import 'package:myapp/screens/test_intro_screen.dart';
import 'package:myapp/screens/test_screen.dart';
import 'routes_name.dart';

class Routes {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;
    switch (settings.name) {
      case RoutesName.splashScreen:
        return _buildPageRoute(const SplashScreen(), settings);
      case RoutesName.registerScreen:
        return _buildPageRoute(const RegisterScreen(), settings);
      case RoutesName.loginScreen:
        return _buildPageRoute(const LoginScreen(), settings);
      case RoutesName.menuScreen:
        return _buildPageRoute(const MenuScreen(), settings);
      case RoutesName.profileScreen:
        return _buildPageRoute(const ProfileScreen(), settings);
      case RoutesName.testIntroScreen:
        return _buildPageRoute(const TestIntroScreen(), settings);
      case RoutesName.riasecInfoScreen:
        return _buildPageRoute(const RiasecInfoScreen(), settings);
      case RoutesName.testScreen:
        return _buildPageRoute(const RiasecTestScreen(), settings);
      case RoutesName.careerScreen:
        return _buildPageRoute(const JobRecommendationScreen(), settings);
      case RoutesName.kepribadianScreen:
        return _buildPageRoute(const PersonalityScreen(), settings);

      default:
        return errorRoute();
    }
  }

  static Route<dynamic> errorRoute() {
    return MaterialPageRoute(builder: (_) {
      return Scaffold(
        appBar: AppBar(title: const Text("Error")),
        body: const Center(child: Text('Error page')),
      );
    });
  }

  static PageRouteBuilder _buildPageRoute(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        if (Theme.of(context).platform == TargetPlatform.iOS) {
          return _buildIosTransition(animation, child);
        } else {
          return _buildAndroidTransition(animation, child);
        }
      },
    );
  }

  static Widget _buildIosTransition(Animation<double> animation, Widget child) {
    const begin = Offset(1.0, 0.0);
    const end = Offset.zero;
    const curve = Curves.easeInOut;

    final tween = Tween(begin: begin, end: end);
    final curvedAnimation = CurvedAnimation(
      parent: animation,
      curve: curve,
    );

    return SlideTransition(
      position: tween.animate(curvedAnimation),
      child: child,
    );
  }

  static Widget _buildAndroidTransition(
      Animation<double> animation, Widget child) {
    return FadeTransition(
      opacity: animation,
      child: child,
    );
  }
}
