import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/items/presentation/item_feed_screen.dart';
import '../../features/reservations/presentation/my_reservations_screen.dart';
import '../../features/chat/presentation/chat_list_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/profile/domain/app_user.dart';
import '../../features/auth/presentation/auth_providers.dart';
import '../../features/profile/presentation/profile_providers.dart';
import '../../core/theme/theme_provider.dart';

class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key});

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> {
  int _currentIndex = 0;

  static const _screens = [
    ItemFeedScreen(),
    MyReservationsScreen(),
    ChatListScreen(),
    ProfileScreen(),
  ];

  static const _navItems = [
    _NavItem(label: 'Explorar', icon: Icons.explore_outlined, selectedIcon: Icons.explore),
    _NavItem(label: 'Reservas', icon: Icons.calendar_month_outlined, selectedIcon: Icons.calendar_month),
    _NavItem(label: 'Chats', icon: Icons.chat_bubble_outline, selectedIcon: Icons.chat_bubble),
    _NavItem(label: 'Perfil', icon: Icons.person_outline, selectedIcon: Icons.person),
  ];

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 800;
    final authUser = ref.watch(authStateProvider).valueOrNull;
    final userData = authUser != null
        ? ref.watch(currentUserProvider(authUser.uid))
        : const AsyncData<AppUser?>(null);
    final appUser = userData.valueOrNull;
    final themeMode = ref.watch(themeModeProvider).valueOrNull ?? ThemeMode.light;

    return Scaffold(
      appBar: _buildAppBar(isDesktop, appUser, themeMode),
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: isDesktop ? null : NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        destinations: _navItems.map((item) => NavigationDestination(
          icon: Icon(item.icon),
          selectedIcon: Icon(item.selectedIcon),
          label: item.label,
        )).toList(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isDesktop, AppUser? appUser, ThemeMode themeMode) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (isDesktop) {
      return PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: Material(
          color: theme.colorScheme.surface,
          elevation: 1,
          shadowColor: colorScheme.shadow.withValues(alpha: 0.08),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  // Logo izquierda
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.handshake_outlined, size: 30, color: colorScheme.primary),
                      const SizedBox(width: 10),
                      Text(
                        'RentMyStuff',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  // Nav centro
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: _navItems.asMap().entries.map((entry) {
                        final index = entry.key;
                        final item = entry.value;
                        final isSelected = _currentIndex == index;
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: TextButton.icon(
                            onPressed: () => setState(() => _currentIndex = index),
                            icon: Icon(isSelected ? item.selectedIcon : item.icon, size: 18),
                            label: Text(item.label),
                            style: TextButton.styleFrom(
                              foregroundColor: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
                              backgroundColor: isSelected ? colorScheme.primaryContainer.withValues(alpha: 0.35) : null,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  // Acciones derecha
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          themeMode == ThemeMode.dark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                        ),
                        tooltip: themeMode == ThemeMode.dark ? 'Modo claro' : 'Modo oscuro',
                        onPressed: () => ref.read(themeModeProvider.notifier).toggle(),
                      ),
                      const SizedBox(width: 4),
                      if (appUser != null)
                        InkWell(
                          onTap: () => setState(() => _currentIndex = 3),
                          borderRadius: BorderRadius.circular(24),
                          child: Padding(
                            padding: const EdgeInsets.all(4),
                            child: CircleAvatar(
                              radius: 20,
                              backgroundColor: colorScheme.primaryContainer,
                              backgroundImage: appUser.photoUrl.isNotEmpty ? NetworkImage(appUser.photoUrl) : null,
                              child: appUser.photoUrl.isEmpty
                                  ? Text(
                                      appUser.displayName.isNotEmpty ? appUser.displayName[0].toUpperCase() : '?',
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: colorScheme.onPrimaryContainer,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )
                                  : null,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return AppBar(
      title: Row(
        children: [
          Icon(Icons.handshake_outlined, size: 26, color: colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            'RentMyStuff',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.primary,
            ),
          ),
        ],
      ),
      centerTitle: false,
      actions: [
        IconButton(
          icon: Icon(
            themeMode == ThemeMode.dark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
          ),
          tooltip: themeMode == ThemeMode.dark ? 'Modo claro' : 'Modo oscuro',
          onPressed: () => ref.read(themeModeProvider.notifier).toggle(),
        ),
      ],
    );
  }
}

class _NavItem {
  final String label;
  final IconData icon;
  final IconData selectedIcon;
  const _NavItem({required this.label, required this.icon, required this.selectedIcon});
}
