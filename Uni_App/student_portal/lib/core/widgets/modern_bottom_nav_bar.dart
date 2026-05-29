import 'dart:ui';
import 'package:flutter/material.dart';

class ModernBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;
  final List<ModernNavItem> items;

  const ModernBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      decoration: BoxDecoration(
        color: (isDark ? const Color(0xFF1E1E1E) : Colors.white).withValues(
          alpha: 0.8,
        ),
        borderRadius: BorderRadius.circular(30),
        border: isDark
            ? Border.all(
                color: Colors.white.withValues(alpha: 0.1),
                width: 1,
              ) // Subtle light border
            : null,
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Theme.of(context).primaryColor.withValues(
                    alpha: 0.2,
                  ) // Subtle colored glow
                : Colors.black.withValues(alpha: 0.1),
            blurRadius: isDark ? 15 : 20,
            offset: isDark ? const Offset(0, 0) : const Offset(0, 10),
            spreadRadius: isDark ? 2 : 0,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: items.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                final isSelected = selectedIndex == index;

                return GestureDetector(
                  onTap: () => onItemSelected(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutQuart, // Smoother curve
                    padding: EdgeInsets.symmetric(
                      horizontal: isSelected ? 16 : 12,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? (isDark
                                ? const Color(
                                    0xFF64FFDA,
                                  ).withValues(alpha: 0.15)
                                : Theme.of(
                                    context,
                                  ).primaryColor.withValues(alpha: 0.15))
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isSelected ? item.selectedIcon : item.icon,
                          color: isSelected
                              ? (isDark
                                    ? const Color(0xFF64FFDA)
                                    : Theme.of(context).primaryColor)
                              : (isDark ? Colors.grey[400] : Colors.grey[600]),
                          size: 26,
                        ),
                        if (isSelected) ...[
                          const SizedBox(width: 6),
                          Text(
                            item.label,
                            style: TextStyle(
                              color: isDark
                                  ? const Color(0xFF64FFDA)
                                  : Theme.of(context).primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}

class ModernNavItem {
  final IconData icon;
  final IconData selectedIcon;
  final String label;

  ModernNavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });
}
