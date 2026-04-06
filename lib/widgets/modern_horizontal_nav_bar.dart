import 'package:flutter/material.dart';

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

    // Calculate suitable width for the nav bar - pill shape looks better when not full width
    final navWidth = isMobile ? screenWidth * 0.92 : screenWidth * 0.5;
    final maxNavWidth = 500.0;
    
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Theme-aware colors
    final Color backgroundColor = Theme.of(context).cardColor;
    final Color selectedBgColor = isDark ? Colors.white10 : const Color(0xFFF7F8ED);
    
    // Prioritize activeColor if provided, otherwise fallback to defaults
    final Color activeIconColor = activeColor ?? (isDark ? const Color(0xFFCBD77E) : const Color(0xFF282828));
    final Color inactiveColor = Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5) ?? Colors.grey;

    return Container(
      width: navWidth > maxNavWidth ? maxNavWidth : navWidth,
      height: 85,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(42.5), // Perfect pill shape
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.06),
            blurRadius: 25,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: navItems.map((item) {
          bool isActive = activeTab == item.id;

          return Flexible(
            child: GestureDetector(
              onTap: () => onTabChanged(item.id),
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                width: 80,
                height: 70,
                decoration: BoxDecoration(
                  color: isActive ? selectedBgColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(35),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      item.icon,
                      size: 26,
                      color: isActive ? activeIconColor : inactiveColor,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.label,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                        color: isActive ? activeIconColor : inactiveColor,
                      ),
                    ),
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



