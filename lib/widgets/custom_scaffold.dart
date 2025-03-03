import 'package:flutter/material.dart';

class CustomScaffold extends StatelessWidget {
  final String? backgroundImage;
  final Color? backgroundColor;
  final Widget? child;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;

  final PreferredSizeWidget? appBar;
  const CustomScaffold({
    super.key,
    this.backgroundImage,
    this.backgroundColor,
    this.child,
    this.floatingActionButton,
    this.appBar,
    this.floatingActionButtonLocation,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      body: Stack(
        children: [
          if (backgroundImage != null)
            SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Image.asset(
                backgroundImage!,
                fit: BoxFit.cover,
              ),
            ),
          if (backgroundColor != null)
            Container(
              color: backgroundColor,
            ),
          child!
        ],
      ),
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
    );
  }
}
