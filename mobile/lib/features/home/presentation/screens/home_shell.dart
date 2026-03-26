import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../config/theme.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../gym/presentation/screens/gym_plan_screen.dart';
import '../../../map/presentation/screens/territory_run_screen.dart';
import '../../../nutrition/presentation/screens/nutrition_screen.dart';
import '../../../profile/data/user_repository.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import '../../../social/presentation/screens/social_hub_screen.dart';
import 'today_overview_screen.dart';

class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key});

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> {
  int _currentIndex = 0;

  static const _destinations = [
    NavigationDestination(icon: Icon(Icons.dashboard_outlined), label: 'Today'),
    NavigationDestination(
        icon: Icon(Icons.fitness_center_outlined), label: 'Gym'),
    NavigationDestination(
        icon: Icon(Icons.restaurant_outlined), label: 'Nutrition'),
    NavigationDestination(icon: Icon(Icons.map_outlined), label: 'Run'),
    NavigationDestination(icon: Icon(Icons.groups_outlined), label: 'Hub'),
    NavigationDestination(icon: Icon(Icons.person_outline), label: 'Profile'),
  ];

  final _screens = const [
    TodayOverviewScreen(),
    GymPlanScreen(),
    NutritionScreen(),
    TerritoryRunScreen(),
    SocialHubScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final sessionUser = ref.watch(currentUserProvider);
    final liveUser =
        ref.watch(currentAppUserProvider).valueOrNull ?? sessionUser;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
              decoration: const BoxDecoration(
                color: AppColors.background,
                border: Border(
                  bottom: BorderSide(color: AppColors.border),
                ),
              ),
              child: Row(
                children: [
                  const Expanded(child: _Wordmark()),
                  _HeaderChip(
                    color: AppColors.amber,
                    background: AppColors.amberDim,
                    label: '${liveUser?.streak ?? 0}',
                    icon: Icons.local_fire_department_rounded,
                  ),
                  const SizedBox(width: 10),
                  _AvatarBadge(initials: _initialsFor(liveUser?.displayName)),
                  const SizedBox(width: 8),
                  _HeaderIconButton(
                    icon: Icons.logout_rounded,
                    onPressed: () {
                      ref.read(authControllerProvider.notifier).signOut();
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: IndexedStack(
                index: _currentIndex,
                children: _screens,
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(6, 10, 6, 22),
              decoration: const BoxDecoration(
                color: Color(0xFA080A10),
                border: Border(
                  top: BorderSide(color: AppColors.borderStrong),
                ),
              ),
              child: SafeArea(
                top: false,
                child: Row(
                  children: [
                    for (var index = 0; index < _destinations.length; index++)
                      Expanded(
                        child: _BottomNavItem(
                          destination: _destinations[index],
                          isActive: index == _currentIndex,
                          onTap: () {
                            setState(() {
                              _currentIndex = index;
                            });
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Wordmark extends StatelessWidget {
  const _Wordmark();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Colors.white, AppColors.lime],
          ).createShader(bounds),
          child: Text(
            'FITSTRIKE',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.8,
                  color: Colors.white,
                ),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.limeDim,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.lime.withOpacity(0.22)),
          ),
          child: Text(
            'PRO',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: AppColors.lime,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
          ),
        ),
      ],
    );
  }
}

class _HeaderChip extends StatelessWidget {
  const _HeaderChip({
    required this.color,
    required this.background,
    required this.label,
    required this.icon,
  });

  final Color color;
  final Color background;
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.22)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w800,
                ),
          ),
        ],
      ),
    );
  }
}

class _AvatarBadge extends StatelessWidget {
  const _AvatarBadge({required this.initials});

  final String initials;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.violet, AppColors.cyan],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.violet.withOpacity(0.35), width: 2),
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    required this.icon,
    required this.onPressed,
  });

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderStrong),
        ),
        alignment: Alignment.center,
        child: Icon(icon, size: 18, color: AppColors.textSecondary),
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  const _BottomNavItem({
    required this.destination,
    required this.isActive,
    required this.onTap,
  });

  final NavigationDestination destination;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final icon = isActive
        ? destination.selectedIcon ?? destination.icon
        : destination.icon;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: isActive ? AppColors.limeDim : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconTheme(
              data: IconThemeData(
                color: isActive ? AppColors.lime : AppColors.textTertiary,
                size: 22,
              ),
              child: icon,
            ),
            const SizedBox(height: 4),
            Text(
              destination.label.toUpperCase(),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isActive ? AppColors.lime : AppColors.textTertiary,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

String _initialsFor(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'FS';
  }

  final parts = value
      .trim()
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty)
      .toList();

  if (parts.length == 1) {
    return parts.first
        .substring(0, parts.first.length >= 2 ? 2 : 1)
        .toUpperCase();
  }

  return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
}
