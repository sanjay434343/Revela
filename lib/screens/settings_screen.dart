import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/theme_manager.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final themeManager = Provider.of<ThemeManager>(context);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar.large(
            floating: false,
            pinned: true,
            backgroundColor: colorScheme.surface,
            title: Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Text(
                'Settings',
                style: textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 38,
                ),
              ),
            ),
            centerTitle: false,
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Appearance Section
                Padding(
                  padding: const EdgeInsets.only(left: 4.0, bottom: 16.0),
                  child: Text(
                    'Appearance',
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                
                // Theme Selection Card
                Container(
                  decoration: BoxDecoration(
                    color: colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.primary.withOpacity(0.1),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: colorScheme.primary.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(
                              Icons.palette_outlined,
                              color: colorScheme.primary,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Theme Mode',
                                style: textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Customize your visual experience',
                                style: textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      
                      // Theme options as cards
                      _ThemeOptionCard(
                        icon: Icons.light_mode_rounded,
                        title: 'Light',
                        description: 'Bright and clear',
                        isSelected: themeManager.themeMode == ThemeMode.light,
                        onTap: () => themeManager.setThemeMode(ThemeMode.light),
                        colorScheme: colorScheme,
                        textTheme: textTheme,
                      ),
                      const SizedBox(height: 12),
                      _ThemeOptionCard(
                        icon: Icons.dark_mode_rounded,
                        title: 'Dark',
                        description: 'Easy on the eyes',
                        isSelected: themeManager.themeMode == ThemeMode.dark,
                        onTap: () => themeManager.setThemeMode(ThemeMode.dark),
                        colorScheme: colorScheme,
                        textTheme: textTheme,
                      ),
                      const SizedBox(height: 12),
                      _ThemeOptionCard(
                        icon: Icons.brightness_auto_rounded,
                        title: 'System',
                        description: 'Follow device settings',
                        isSelected: themeManager.themeMode == ThemeMode.system,
                        onTap: () => themeManager.setThemeMode(ThemeMode.system),
                        colorScheme: colorScheme,
                        textTheme: textTheme,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 48),
                
                // About Section
                Padding(
                  padding: const EdgeInsets.only(left: 4.0, bottom: 16.0),
                  child: Text(
                    'About',
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                
                // App Info Cards
                Container(
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceVariant.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: colorScheme.outline.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      _InfoTile(
                        icon: Icons.info_outline_rounded,
                        title: 'App Version',
                        subtitle: '1.0.0',
                        colorScheme: colorScheme,
                        textTheme: textTheme,
                        showDivider: true,
                      ),
                      _InfoTile(
                        icon: Icons.qr_code_scanner_rounded,
                        title: 'About Revela',
                        subtitle: 'AI-powered product scanner',
                        colorScheme: colorScheme,
                        textTheme: textTheme,
                        trailing: Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 18,
                          color: colorScheme.primary,
                        ),
                        onTap: () {
                          showAboutDialog(
                            context: context,
                            applicationName: 'Revela',
                            applicationVersion: '1.0.0',
                            applicationIcon: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Icon(
                                Icons.qr_code_scanner_rounded,
                                size: 48,
                                color: colorScheme.primary,
                              ),
                            ),
                            children: [
                              const SizedBox(height: 16),
                              const Text(
                                'AI-powered product scanner for health and ingredient analysis. '
                                'Scan products to get detailed ingredient information and health insights.',
                                style: TextStyle(height: 1.5),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 48),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _ThemeOptionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final bool isSelected;
  final VoidCallback onTap;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  const _ThemeOptionCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.isSelected,
    required this.onTap,
    required this.colorScheme,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: isSelected 
                ? colorScheme.primary 
                : colorScheme.surface.withOpacity(0.5),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected 
                  ? colorScheme.primary 
                  : colorScheme.outline.withOpacity(0.3),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isSelected 
                    ? colorScheme.onPrimary 
                    : colorScheme.onSurface,
                size: 28,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isSelected 
                            ? colorScheme.onPrimary 
                            : colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      description,
                      style: textTheme.bodySmall?.copyWith(
                        color: isSelected 
                            ? colorScheme.onPrimary.withOpacity(0.8) 
                            : colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle_rounded,
                  color: colorScheme.onPrimary,
                  size: 24,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final ColorScheme colorScheme;
  final TextTheme textTheme;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool showDivider;

  const _InfoTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.colorScheme,
    required this.textTheme,
    this.trailing,
    this.onTap,
    this.showDivider = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: colorScheme.primary,
              size: 26,
            ),
          ),
          title: Text(
            title,
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              subtitle,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          trailing: trailing,
          onTap: onTap,
        ),
        if (showDivider)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Divider(
              height: 1,
              thickness: 1,
              color: colorScheme.outline.withOpacity(0.2),
            ),
          ),
      ],
    );
  }
}
