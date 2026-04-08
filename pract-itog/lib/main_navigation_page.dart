import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'core/constants/app_colors.dart';
import 'features/cart/presentation/pages/cart_page.dart';
import 'features/catalog/presentation/pages/home_page.dart';
import 'features/profile/presentation/pages/profile_page.dart';
import 'features/wishlist/presentation/pages/wishlist_page.dart';

class MainNavigationPage extends StatefulWidget {
  final int currentIndex;
  const MainNavigationPage({super.key, required this.currentIndex});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  late int _currentIndex;

  final List<Widget> _pages = const [
    HomePage(),
    WishlistPage(),
    CartPage(),
    ProfilePage(),
  ];

  final List<_NavItem> _navItems = const [
    _NavItem(
        icon: Icons.library_books_outlined,
        activeIcon: Icons.library_books,
        label: 'Каталог'),
    _NavItem(
        icon: Icons.bookmark_border,
        activeIcon: Icons.bookmark,
        label: 'Список'),
    _NavItem(
        icon: Icons.shopping_bag_outlined,
        activeIcon: Icons.shopping_bag,
        label: 'Корзина'),
    _NavItem(
        icon: Icons.person_outline, activeIcon: Icons.person, label: 'Профиль'),
  ];

  static const List<String> _routes = [
    '/home',
    '/wishlist-tab',
    '/cart',
    '/profile'
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.currentIndex.clamp(0, _pages.length - 1);
  }

  @override
  void didUpdateWidget(MainNavigationPage old) {
    super.didUpdateWidget(old);
    if (old.currentIndex != widget.currentIndex) {
      setState(() =>
          _currentIndex = widget.currentIndex.clamp(0, _pages.length - 1));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        switchInCurve: Curves.easeIn,
        switchOutCurve: Curves.easeOut,
        child: KeyedSubtree(
          key: ValueKey(_currentIndex),
          child: _pages[_currentIndex],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.divider, width: 0.5)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() => _currentIndex = index);
            context.go(_routes[index]);
          },
          items: _navItems
              .map(
                (item) => BottomNavigationBarItem(
                  icon: Icon(item.icon),
                  activeIcon: Icon(item.activeIcon),
                  label: item.label,
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}
