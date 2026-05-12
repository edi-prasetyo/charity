import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';

import 'core/constants/app_color.dart';
import 'core/services/auth_service.dart';

// IMPORT PROVIDER KAMU (Sesuaikan path-nya)
import 'modules/auth/controllers/auth_controller.dart';
import 'modules/campaign/controllers/campaign_controller.dart'; // Contoh provider campaign

// import 'modules/donation/controllers/donation_controller.dart';
import 'modules/donation/controllers/donation_controller.dart';
import 'modules/home/pages/home_page.dart';
import 'modules/campaign/pages/campaign_page.dart';
import 'modules/donation/pages/donation_page.dart';
import 'modules/profile/pages/profile_page.dart';
import 'modules/auth/pages/login_page.dart';

class MainNavigation extends ConsumerStatefulWidget {
  final int initialIndex;
  const MainNavigation({super.key, this.initialIndex = 0});

  @override
  ConsumerState<MainNavigation> createState() => _MainNavigationState();
}

class MenuItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  MenuItem({required this.icon, required this.activeIcon, required this.label});
}

class _MainNavigationState extends ConsumerState<MainNavigation> {
  late int selectedIndex;

  @override
  void initState() {
    super.initState();
    selectedIndex = widget.initialIndex;
  }

  // FUNGSI UNTUK REFRESH DATA
  void _refreshTabData(int index) {
    switch (index) {
      case 0:
        // Ganti campaignProvider menjadi campaignListProvider
        ref.invalidate(campaignListProvider);
        break;
      case 1:
        // Ganti campaignProvider menjadi campaignListProvider
        ref.invalidate(campaignListProvider);
        break;
      case 2:
        ref.invalidate(myDonationsProvider);
        break;
      case 3:
        // ref.invalidate(authControllerProvider);
        break;
    }
  }

  void onItemTapped(int index) async {
    final authService = ref.read(authServiceProvider);
    bool loggedIn = await authService.isLoggedIn();

    if ((index == 2 || index == 3) && !loggedIn) {
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    } else {
      // SETIAP KALI MENU DIKLIK:
      _refreshTabData(index); // 1. Trigger Refresh Data

      setState(() {
        selectedIndex = index; // 2. Pindah Halaman
      });
    }
  }

  final List<Widget> _pages = [
    const HomePage(),
    const CampaignPage(),
    const DonationPage(),
    const ProfilePage(),
  ];

  final List<MenuItem> menus = [
    MenuItem(
      icon: MingCuteIcons.mgc_home_4_line,
      activeIcon: MingCuteIcons.mgc_home_4_fill,
      label: "Home",
    ),
    MenuItem(
      icon: MingCuteIcons.mgc_heart_hand_line,
      activeIcon: MingCuteIcons.mgc_heart_hand_fill,
      label: "Campaign",
    ),
    MenuItem(
      icon: MingCuteIcons.mgc_bill_2_line,
      activeIcon: MingCuteIcons.mgc_bill_2_fill,
      label: "Donasi Saya",
    ),
    MenuItem(
      icon: MingCuteIcons.mgc_user_2_line,
      activeIcon: MingCuteIcons.mgc_user_2_fill,
      label: "Profile",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    ref.listen(authControllerProvider, (previous, next) {
      if (next.value == null) {
        // Jika state auth jadi null (logout), paksa balik ke tab Home (index 0)
        setState(() {
          selectedIndex = 0;
        });
      }
    });

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (selectedIndex != 0) {
          setState(() => selectedIndex = 0);
        } else {
          await SystemNavigator.pop();
        }
      },
      child: Scaffold(
        // Gunakan IndexedStack agar state halaman tidak hilang,
        // tapi data tetap refresh karena kita invalidate providernya.
        body: IndexedStack(index: selectedIndex, children: _pages),
        bottomNavigationBar: buildCustomBottomNavBar(),
      ),
    );
  }

  Widget buildCustomBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: List.generate(menus.length, (index) {
            final isActive = selectedIndex == index;
            return Expanded(
              child: InkWell(
                onTap: () => onItemTapped(index),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      height: 4,
                      width: isActive ? 30 : 0,
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor,
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(10),
                          bottomRight: Radius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Icon(
                      isActive ? menus[index].activeIcon : menus[index].icon,
                      size: 24,
                      color: isActive
                          ? AppColors.primaryColor
                          : AppColors.primaryTextColorGrey,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      menus[index].label,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: isActive
                            ? FontWeight.w600
                            : FontWeight.normal,
                        color: isActive
                            ? AppColors.primaryColor
                            : AppColors.primaryTextColorGrey,
                      ),
                    ),
                    const SizedBox(height: 6),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
