import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:ans_mobile/l10n/app_localizations.dart';
import 'package:ans_mobile/presentation/widgets/app_toast.dart';

/// Stylized bottom navigation with floating center Home button.
class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  const AppBottomNav({Key? key, required this.currentIndex}) : super(key: key);

  static const int notificationsIndex = 3;
  static const int calendarIndex = 1;
  static const int homeIndex = 2;
  static const int profileIndex = 4;
  static const int historyIndex = 0;

  void _onTap(BuildContext context, int index) {
    if (index == currentIndex) return;
    switch (index) {
      case notificationsIndex:
        Navigator.of(context).pushReplacementNamed('/notifications');
        break;
      case calendarIndex:
        Navigator.of(context).pushReplacementNamed('/poi_list');
        break;
      case homeIndex:
        Navigator.of(context).pushReplacementNamed('/map');
        break;
      case profileIndex:
        Navigator.of(context).pushReplacementNamed('/profile');
        break;
      case historyIndex:
        Navigator.of(context).pushReplacementNamed('/history');
        break;
    }
  }

  Widget _buildNavItem(BuildContext context, int index, IconData icon) {
    final selected = index == currentIndex;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _onTap(context, index),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 220),
            tween: Tween(begin: 1.0, end: selected ? 1.15 : 1.0),
            builder: (context, val, child) =>
                Transform.scale(scale: val, child: child),
            child: Icon(
              icon,
              color: selected
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bg = Theme.of(context).colorScheme.surface.withOpacity(0.95);
    final rawGap = MediaQuery.of(context).viewPadding.bottom;
    final bottomGap = rawGap + 12;
    final totalHeight = 72 + bottomGap;

    return SizedBox(
      height: totalHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Bottom gap fill: keep spacing but make it transparent when there is no system inset.
          // If the system inset exists (rawGap > 0) we keep the nav background so it blends with the system area.
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(height: bottomGap),
          ),
          // Extend nav container to bottom to avoid showing a visible seam.
          Positioned.fill(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  padding: EdgeInsets.fromLTRB(12, 12, 12, 12),
                  margin: EdgeInsets.fromLTRB(12, 12, 12, rawGap + 12),
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      _buildNavItem(context, historyIndex, Icons.history),
                      _buildNavItem(
                        context,
                        calendarIndex,
                        Icons.calendar_today,
                      ),
                      const SizedBox(width: 72), // space for center button
                      _buildNavItem(
                        context,
                        notificationsIndex,
                        Icons.notifications,
                      ),
                      _buildNavItem(context, profileIndex, Icons.person),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Floating center Home button
          Positioned(
            bottom: bottomGap + 12,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: () => _onTap(context, homeIndex),
                child: TweenAnimationBuilder<double>(
                  tween: Tween(
                    begin: 1.0,
                    end: currentIndex == homeIndex ? 1.05 : 1.0,
                  ),
                  duration: const Duration(milliseconds: 220),
                  builder: (context, val, child) =>
                      Transform.scale(scale: val, child: child),
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).colorScheme.primary,
                          Theme.of(context).colorScheme.tertiary,
                        ],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withOpacity(0.28),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.home,
                      color: Theme.of(context).colorScheme.onPrimary,
                      size: 28,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
