import 'package:flutter/material.dart';
import 'package:myapp/screens/menu_screen.dart';
import 'dart:math' as math;

class MenuGrid extends StatefulWidget {
  final List<MenuItem> menuItems;
  final bool hasPersonalityData;
  final AnimationController controller;
  final int gridCrossAxisCount;
  final bool isTooSmall;
  final Function(BuildContext, MenuItem) onMenuItemTap;

  const MenuGrid({
    Key? key,
    required this.menuItems,
    required this.hasPersonalityData,
    required this.controller,
    required this.gridCrossAxisCount,
    required this.isTooSmall,
    required this.onMenuItemTap,
  }) : super(key: key);

  @override
  State<MenuGrid> createState() => _MenuGridState();
}

class _MenuGridState extends State<MenuGrid> with TickerProviderStateMixin {
  // Controllers for locked item animations
  late AnimationController _pulseController;
  late Animation<double> pulseAnimation;

  // Controller for shine effect
  late AnimationController _shineController;
  late Animation<double> _shineAnimation;

  @override
  void initState() {
    super.initState();

    // Efek pulse untuk item yang terkunci
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    pulseAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    // Efek shine untuk item yang terkunci
    _shineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    _shineAnimation = Tween<double>(
      begin: -0.2,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _shineController,
      curve: Curves.easeInOut,
    ));

    // Mulai animasi
    _pulseController.repeat(reverse: true);
    _shineController.repeat(reverse: false);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _shineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: GridView.builder(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 16),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: widget.gridCrossAxisCount,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.0,
        ),
        itemCount: widget.menuItems.length,
        itemBuilder: (context, index) {
          // Staggered animation for each item
          final delay = index * 0.15;
          final animationStart = delay.clamp(0.0, 0.9);
          final animationEnd = (delay + 0.4).clamp(0.0, 1.0);

          return AnimatedBuilder(
            animation: widget.controller,
            builder: (context, child) {
              final animationValue = Curves.easeOutQuart.transform(
                  ((widget.controller.value - animationStart) /
                          (animationEnd - animationStart))
                      .clamp(0.0, 1.0));

              return Opacity(
                opacity: animationValue.clamp(0.0, 1.0),
                child: Transform.translate(
                  offset: Offset(0, 20 * (1 - animationValue.clamp(0.0, 1.0))),
                  child: child,
                ),
              );
            },
            child: _buildModernGridMenuItem(
              widget.menuItems[index],
              context,
            ),
          );
        },
      ),
    );
  }

  Widget _buildModernGridMenuItem(MenuItem item, BuildContext context) {
    final bool isLocked =
        item.requiresPersonalityData && !widget.hasPersonalityData;

    // Widget untuk locked items dengan animasi
    if (isLocked) {
      return AnimatedBuilder(
        animation: Listenable.merge([_pulseController, _shineController]),
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: item.color.withOpacity(0.15),
                  blurRadius: 12,
                  spreadRadius: 1,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => widget.onMenuItemTap(context, item),
                borderRadius: BorderRadius.circular(24),
                splashColor: item.backgroundColor,
                highlightColor: item.backgroundColor.withOpacity(0.5),
                child: Ink(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white,
                        item.backgroundColor.withOpacity(0.5),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: item.color.withOpacity(0.5),
                      width: 2,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Stack(
                      children: [
                        // Shine effect animation
                        Positioned.fill(
                          child: Transform.translate(
                            offset: Offset(
                              MediaQuery.of(context).size.width *
                                  _shineAnimation.value *
                                  1.5,
                              0,
                            ),
                            child: Transform.rotate(
                              angle: -math.pi / 4,
                              child: Container(
                                width: 80,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.transparent,
                                      Colors.white.withOpacity(0.1),
                                      Colors.white.withOpacity(0.5),
                                      Colors.white.withOpacity(0.1),
                                      Colors.transparent,
                                    ],
                                    stops: const [0.0, 0.35, 0.5, 0.65, 1.0],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Polygon background pattern
                        Positioned(
                          right: -20,
                          bottom: -20,
                          child: Opacity(
                            opacity: 0.05,
                            child: Icon(
                              item.icon,
                              size: 100,
                              color: item.color,
                            ),
                          ),
                        ),

                        // Content with large icon on top-left
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Icon in top-left
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      item.color,
                                      Color.lerp(
                                          item.color, Colors.black, 0.2)!,
                                    ],
                                  ),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: item.color.withOpacity(0.4),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  item.icon,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),

                              const Spacer(),

                              // Title and lock status at bottom
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.title,
                                    style: TextStyle(
                                      fontSize: widget.isTooSmall ? 15 : 17,
                                      fontWeight: FontWeight.bold,
                                      color: item.color,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: item.color.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.lock,
                                          size: 12,
                                          color: item.color,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          "Terkunci",
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: item.color,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Star badge
                        Positioned(
                          top: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: item.color,
                              borderRadius: const BorderRadius.only(
                                topRight: Radius.circular(24),
                                bottomLeft: Radius.circular(20),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: item.color.withOpacity(0.3),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.star,
                              size: 14,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      );
    }

    // Regular modern menu items - Fixed with container and proper padding
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: item.color.withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(24),
          child: InkWell(
            onTap: () => widget.onMenuItemTap(context, item),
            borderRadius: BorderRadius.circular(24),
            splashColor: item.backgroundColor,
            highlightColor: item.backgroundColor.withOpacity(0.2),
            child: Ink(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Stack(
                children: [
                  // Background pattern
                  Positioned(
                    right: -30,
                    bottom: -30,
                    child: Opacity(
                      opacity: 0.04,
                      child: Icon(
                        item.icon,
                        size: 130,
                        color: item.color,
                      ),
                    ),
                  ),

                  // Subtle gradient overlay
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white,
                            item.backgroundColor.withOpacity(0.15),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Content with modern styling
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Modern icon design
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                item.color,
                                Color.lerp(item.color, Colors.white, 0.3)!,
                              ],
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: item.color.withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Icon(
                            item.icon,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),

                        const Spacer(),

                        // Title with modern styling
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              style: TextStyle(
                                fontSize: widget.isTooSmall ? 15 : 17,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade800,
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Colored indicator line
                            Container(
                              height: 4,
                              width: 40,
                              decoration: BoxDecoration(
                                color: item.color,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // External link indicator for WhatsApp with modern styling
                  if (item.isWhatsApp)
                    Positioned(
                      top: 16,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: item.color,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: item.color.withOpacity(0.3),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.open_in_new,
                          size: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
