import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import 'settings_screen.dart';

/// Placeholder chat preview model — purely for UI mockup until the real
/// conversations API/model exists. Replace with the real Conversation
/// model once the chat domain is built.
class _ChatPreview {
  final String name;
  final String lastMessage;
  final String time;
  final int unreadCount;
  final Color avatarColor;

  const _ChatPreview({
    required this.name,
    required this.lastMessage,
    required this.time,
    required this.unreadCount,
    required this.avatarColor,
  });
}

const _mockChats = [
  _ChatPreview(
    name: 'Sarah Chen',
    lastMessage: 'Sounds good, see you then! 👍',
    time: '09:41',
    unreadCount: 2,
    avatarColor: Color(0xFF6C5CE7),
  ),
  _ChatPreview(
    name: 'Design Team',
    lastMessage: "Yacine: I've pushed the new mockups",
    time: '08:15',
    unreadCount: 5,
    avatarColor: Color(0xFFFF6B81),
  ),
  _ChatPreview(
    name: 'Marc Dubois',
    lastMessage: 'Typing…',
    time: 'Yesterday',
    unreadCount: 0,
    avatarColor: Color(0xFF00B894),
  ),
  _ChatPreview(
    name: 'Amel Boudiaf',
    lastMessage: 'Thanks for the update 🙏',
    time: 'Yesterday',
    unreadCount: 0,
    avatarColor: Color(0xFFFDA085),
  ),
  _ChatPreview(
    name: 'Family 👨‍👩‍👧',
    lastMessage: "Dad: Don't forget Sunday lunch",
    time: 'Monday',
    unreadCount: 0,
    avatarColor: Color(0xFF4834D4),
  ),
];

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.bgBottom,
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Hey, ${user.name.split(' ').first} 👋',
                                style:
                                    Theme.of(context).textTheme.headlineSmall,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '@${user.username}',
                                style: TextStyle(
                                    color: colors.textSecondary, fontSize: 14),
                              ),
                            ],
                          ),
                          _IconAction(
                            icon: Icons.settings_outlined,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (_) => const SettingsScreen()),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
                      child: Text('Chats',
                          style: Theme.of(context).textTheme.titleLarge),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    sliver: SliverList.separated(
                      itemCount: _mockChats.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) =>
                          _ChatTile(chat: _mockChats[index]),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 24)),
                ],
              ),
            ),
    );
  }
}

class _ChatTile extends StatelessWidget {
  final _ChatPreview chat;
  const _ChatTile({required this.chat});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final hasUnread = chat.unreadCount > 0;

    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {}, // placeholder — wire up once conversation screens exist
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: chat.avatarColor.withOpacity(0.16),
                child: Text(
                  chat.name.characters.first.toUpperCase(),
                  style: TextStyle(
                      color: chat.avatarColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 16),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            chat.name,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                              color: colors.textPrimary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          chat.time,
                          style: TextStyle(
                            fontSize: 12,
                            color: hasUnread
                                ? colors.primaryStart
                                : colors.textSecondary,
                            fontWeight:
                                hasUnread ? FontWeight.w600 : FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            chat.lastMessage,
                            style: TextStyle(
                              fontSize: 13.5,
                              color: hasUnread
                                  ? colors.textPrimary
                                  : colors.textSecondary,
                              fontWeight:
                                  hasUnread ? FontWeight.w500 : FontWeight.w400,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (hasUnread) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              gradient: colors.primaryGradient,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${chat.unreadCount}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IconAction extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _IconAction({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Material(
      color: colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: colors.border),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, size: 20, color: colors.textPrimary),
        ),
      ),
    );
  }
}
