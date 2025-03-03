import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:myapp/constant/img_const.dart';
import 'package:myapp/routes/routes_name.dart';
import 'package:myapp/service/sheet_service.dart';
import 'package:myapp/service/user_service.dart';
import 'package:myapp/widgets/custom_scaffold.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    initializeSheet();
  }

  Future<void> initializeSheet() async {
    await SheetService.init();
    await navigate();
  }

  Future<void> navigate() async {
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    final userData = await UserService.getCurrentUser();

    if (userData != null) {
      Navigator.of(context).pushReplacementNamed(RoutesName.menuScreen);
    } else {
      Navigator.of(context).pushReplacementNamed(RoutesName.loginScreen);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      backgroundColor: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          Padding(
            padding: const EdgeInsets.all(70),
            child: Image.asset(
              ImageConstants.instance.logoApp,
            ),
          ),
        ],
      ),
    );
  }
}
