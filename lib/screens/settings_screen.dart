import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../theme/app_theme.dart';
import 'login_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // UI-only toggles — not wired to any backend/preferences yet.
  bool _pushNotifications = true;
  bool _messageSound = true;
  bool _readReceipts = true;
  bool _onlineStatus = true;

  Future<void> _confirmLogout(BuildContext context) async {
    final colors = context.colors;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: colors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Log out?'),
        content: const Text('You can always log back in with your account.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text('Log out', style: TextStyle(color: colors.error)),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    await context.read<AuthProvider>().logout();

    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      backgroundColor: colors.bgBottom,
      appBar: AppBar(
        backgroundColor: colors.bgBottom,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          if (user != null) _ProfileHeader(name: user.name, email: user.email),
          const SizedBox(height: 28),
          const _SectionHeader('Appearance'),
          const SizedBox(height: 10),
          const _AppearanceSelector(),
          const SizedBox(height: 28),
          const _SectionHeader('Notifications'),
          const SizedBox(height: 10),
          _SettingsGroup(
            children: [
              _ToggleTile(
                icon: Icons.notifications_outlined,
                title: 'Push notifications',
                value: _pushNotifications,
                onChanged: (v) => setState(() => _pushNotifications = v),
              ),
              _ToggleTile(
                icon: Icons.volume_up_outlined,
                title: 'Message sound',
                value: _messageSound,
                onChanged: (v) => setState(() => _messageSound = v),
              ),
            ],
          ),
          const SizedBox(height: 28),
          const _SectionHeader('Privacy & Security'),
          const SizedBox(height: 10),
          _SettingsGroup(
            children: [
              _ToggleTile(
                icon: Icons.done_all,
                title: 'Read receipts',
                value: _readReceipts,
                onChanged: (v) => setState(() => _readReceipts = v),
              ),
              _ToggleTile(
                icon: Icons.circle,
                title: 'Show online status',
                value: _onlineStatus,
                onChanged: (v) => setState(() => _onlineStatus = v),
              ),
              _NavTile(icon: Icons.block_outlined, title: 'Blocked contacts'),
              _NavTile(
                  icon: Icons.lock_outline, title: 'Two-factor authentication'),
            ],
          ),
          const SizedBox(height: 28),
          const _SectionHeader('Support'),
          const SizedBox(height: 10),
          _SettingsGroup(
            children: const [
              _NavTile(icon: Icons.help_outline, title: 'Help center'),
              _NavTile(icon: Icons.flag_outlined, title: 'Report a problem'),
              _NavTile(icon: Icons.info_outline, title: 'About chat_app'),
            ],
          ),
          const SizedBox(height: 28),
          _SettingsGroup(
            children: [
              _NavTile(
                icon: Icons.logout_rounded,
                title: 'Log out',
                destructive: true,
                onTap: () => _confirmLogout(context),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final String name;
  final String email;
  const _ProfileHeader({required this.name, required this.email});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
                gradient: colors.primaryGradient, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : '?',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: colors.textPrimary)),
                const SizedBox(height: 2),
                Text(email,
                    style:
                        TextStyle(color: colors.textSecondary, fontSize: 13)),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: colors.textSecondary),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title.toUpperCase(),
      style: TextStyle(
        fontSize: 12.5,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.6,
        color: context.colors.textSecondary,
      ),
    );
  }
}

/// Rounded card wrapping a group of settings rows with dividers between them.
class _SettingsGroup extends StatelessWidget {
  final List<Widget> children;
  const _SettingsGroup({required this.children});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            children[i],
            if (i != children.length - 1)
              Divider(height: 1, color: colors.border),
          ],
        ],
      ),
    );
  }
}

class _ToggleTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: colors.textSecondary),
          const SizedBox(width: 14),
          Expanded(
            child: Text(title,
                style: TextStyle(color: colors.textPrimary, fontSize: 14.5)),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeColor: colors.primaryStart,
          ),
        ],
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool destructive;
  final VoidCallback? onTap;

  const _NavTile({
    required this.icon,
    required this.title,
    this.destructive = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final color = destructive ? colors.error : colors.textPrimary;

    return InkWell(
      onTap: onTap ?? () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon,
                size: 20,
                color: destructive ? colors.error : colors.textSecondary),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                    color: color,
                    fontSize: 14.5,
                    fontWeight:
                        destructive ? FontWeight.w600 : FontWeight.w400),
              ),
            ),
            if (!destructive)
              Icon(Icons.chevron_right, size: 20, color: colors.textSecondary),
          ],
        ),
      ),
    );
  }
}

/// The one functional control on this screen: switches ThemeMode and
/// persists it via ThemeProvider.
class _AppearanceSelector extends StatelessWidget {
  const _AppearanceSelector();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final themeProvider = context.watch<ThemeProvider>();

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          _ModeOption(
            label: 'Light',
            icon: Icons.light_mode_outlined,
            selected: themeProvider.themeMode == ThemeMode.light,
            onTap: () => themeProvider.setThemeMode(ThemeMode.light),
          ),
          _ModeOption(
            label: 'Dark',
            icon: Icons.dark_mode_outlined,
            selected: themeProvider.themeMode == ThemeMode.dark,
            onTap: () => themeProvider.setThemeMode(ThemeMode.dark),
          ),
          _ModeOption(
            label: 'System',
            icon: Icons.smartphone_outlined,
            selected: themeProvider.themeMode == ThemeMode.system,
            onTap: () => themeProvider.setThemeMode(ThemeMode.system),
          ),
        ],
      ),
    );
  }
}

class _ModeOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _ModeOption({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            gradient: selected ? colors.primaryGradient : null,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(icon,
                  size: 20,
                  color: selected ? Colors.white : colors.textSecondary),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: selected ? Colors.white : colors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
