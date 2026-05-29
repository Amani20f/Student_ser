import 'package:flutter/material.dart';
import 'screens/dashboard_screen.dart';
import 'package:university_app/l10n/app_localizations.dart';
import 'package:university_app/features/settings/screens/settings_screen.dart';
import 'package:university_app/features/requests/screens/requests_list_screen.dart';
import 'package:university_app/features/requests/screens/announcements/announcements_screen.dart';
import '../../core/widgets/modern_bottom_nav_bar.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    DashboardScreen(),
    RequestsListScreen(),
    AnnouncementsScreen(),
    SettingsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: ModernBottomNavBar(
        selectedIndex: _selectedIndex,
        onItemSelected: _onItemTapped,
        items: [
          ModernNavItem(
            icon: Icons.home_rounded,
            selectedIcon: Icons.home_rounded,
            label: AppLocalizations.of(context)!.navHome,
          ),
          ModernNavItem(
            icon: Icons.description_rounded,
            selectedIcon: Icons.description_rounded,
            label: AppLocalizations.of(context)!.navRequests,
          ),
          ModernNavItem(
            icon: Icons.campaign_rounded,
            selectedIcon: Icons.campaign_rounded,
            label: AppLocalizations.of(context)!.navAnnouncements,
          ),
          ModernNavItem(
            icon: Icons.settings_rounded,
            selectedIcon: Icons.settings_rounded,
            label: AppLocalizations.of(context)!.navSettings,
          ),
        ],
      ),
    );
  }
}
