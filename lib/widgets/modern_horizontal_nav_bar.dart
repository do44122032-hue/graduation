import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class ModernNavItem {
  final String id;
  final IconData icon;
  final String label;

  ModernNavItem({required this.id, required this.icon, required this.label});
}

class ModernHorizontalNavBar extends StatelessWidget {
  final String activeTab;
  final List<ModernNavItem> navItems;
  final Function(String) onTabChanged;
  final String languageCode;
  final Color? activeColor;

  const ModernHorizontalNavBar({
    Key? key,
    required this.activeTab,
    required this.navItems,
    required this.onTabChanged,
    required this.languageCode,
    this.activeColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    // Calculate suitable width for the nav bar
    final navWidth = isMobile ? screenWidth * 0.98 : screenWidth * 0.6;
    final maxNavWidth = isMobile ? 480.0 : 600.0;
    final showLabels = screenWidth > 350;
    final horizontalPadding = screenWidth < 380 ? 8.0 : 12.0;

    final Color effectiveActiveColor = activeColor ?? AppColors.mainButton;
    final Color effectiveActiveTextColor =
        effectiveActiveColor.computeLuminance() > 0.5
        ? Colors.black
        : Colors.white;

    return Container(
      width: navWidth > maxNavWidth ? maxNavWidth : navWidth,
      height: 70,
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(35),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.08),
            blurRadius: 20,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: navItems.map((item) {
          bool isActive = activeTab == item.id;

          return Flexible(
            child: GestureDetector(
              onTap: () => onTabChanged(item.id),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                height: 54,
                decoration: BoxDecoration(
                  color: isActive ? effectiveActiveColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(27),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      item.icon,
                      size: 24,
                      color: isActive
                          ? effectiveActiveTextColor
                          : const Color(0xFF2D3748),
                    ),
                    if (isActive && showLabels) ...[
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          item.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: isMobile ? 12 : 14,
                            fontWeight: FontWeight.bold,
                            color: effectiveActiveTextColor,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
